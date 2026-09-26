#!/usr/bin/env python3
"""Sync the Tokcos Homebrew Cask/Formula in this tap with the latest upstream release.

Invoked by .github/workflows/bump-packages.yml.

Checksum policy
---------------
The *served artifact* is the source of truth for every checksum written here,
because that is what users actually download.  Upstream `latest.json` supplies the
version and is cross-checked, but it has been observed to be wrong -- e.g.
tokcos-cli 0.5.9 advertises a win32-x64 `archive` hash and `size` that do not
match the zip actually served.  Any such disagreement is surfaced as a GitHub
warning instead of being silently trusted or silently ignored.

For tokscos-cli the metadata additionally carries the sha256 of the *unpacked*
binary.  That value is treated as an identity check: if it does not match, the
artifact is not the build the metadata describes, and the run fails rather than
publishing an unverified package.

Cost
----
Artifacts are downloaded only when the declared version actually changed, so the
daily run normally performs two small JSON fetches and nothing else.

The two packages use two different metadata schemas, so they are handled by two
explicit functions rather than one generic scraper.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.parse
import urllib.request
import zipfile
from itertools import zip_longest
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
COS = "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com"
UA = {"User-Agent": "greenflute-homebrew-repo-bump"}

WORK_META_URL = f"{COS}/tokcos-gui/release/latest.json"
WORK_FILE = REPO / "Casks/tokcos-work.rb"
CLI_META_URL = f"{COS}/tokcos-cli/release/latest.json"
CLI_FILE = REPO / "Formula/tokcos-cli.rb"

VERSION_RE = r'(?m)^(\s*version )"([^"]+)"'
SHA256_RE = r'(?m)^(\s*sha256 )"[0-9a-f]{64}"'
URL_LINE_RE = re.compile(r"^\s*url\s")
HASH_LINE_RE = re.compile(r'^\s*sha256\s+"[0-9a-f]{64}"')


def log(message: str) -> None:
    print(message, flush=True)


def warn(message: str) -> None:
    print(f"::warning::{message}", flush=True)


def fail(message: str) -> None:
    print(f"::error::{message}", flush=True)
    raise SystemExit(1)


def set_output(name: str, value: str) -> None:
    path = os.environ.get("GITHUB_OUTPUT")
    if not path:
        return
    with open(path, "a", encoding="utf-8") as handle:
        handle.write(f"{name}={value}\n")


def fetch_json(url: str) -> dict:
    request = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(request, timeout=60) as response:
        return json.load(response)


def sha256_stream(stream) -> str:
    digest = hashlib.sha256()
    while chunk := stream.read(1 << 20):
        digest.update(chunk)
    return digest.hexdigest()


def download(url: str, dest: Path) -> tuple[str, int]:
    """Download url to dest; return (sha256 hex, byte count)."""
    request = urllib.request.Request(url, headers=UA)
    digest = hashlib.sha256()
    size = 0
    with urllib.request.urlopen(request, timeout=900) as response, dest.open("wb") as handle:
        while chunk := response.read(1 << 20):
            handle.write(chunk)
            digest.update(chunk)
            size += len(chunk)
    return digest.hexdigest(), size


def sha256_tar_member(archive: Path, member: str) -> str:
    with tarfile.open(archive, "r:gz") as tar:
        stream = tar.extractfile(member)
        if stream is None:
            fail(f"{archive.name}: member {member!r} not found")
        with stream:
            return sha256_stream(stream)


def manifest_fragment(filename: str, version: str) -> str:
    """The text a manifest must contain to name this artifact, version templated.

    Used both to prove the cask/formula already points at the file upstream
    publishes, and to bind each digest to that statement.
    """
    return urllib.parse.quote(filename.replace(version, "#{version}"), safe="#{}")


def validate_ruby(path: Path) -> None:
    ruby = shutil.which("ruby")
    if ruby is None:
        warn(f"{path.name}: ruby not on PATH, skipped the syntax check")
        return
    result = subprocess.run([ruby, "-c", str(path)], capture_output=True, text=True)
    if result.returncode != 0:
        fail(f"{path.name}: ruby -c failed\n{result.stdout}{result.stderr}")
    log(f"  {path.name}: ruby -c OK")


def version_tuple(version: str) -> tuple[int, ...]:
    return tuple(int(part) for part in re.findall(r"\d+", version))


def assert_not_a_downgrade(current: str, latest: str, what: str) -> None:
    """Refuse to move backwards if upstream appears to have rolled a release back.

    A downgrade is occasionally the right call after a retracted release, but it
    should be a deliberate edit rather than something a nightly job commits.
    """
    before, after = version_tuple(current), version_tuple(latest)
    if not before or not after:
        warn(f"{what}: cannot compare {current!r} with {latest!r} numerically")
        return
    for old, new in zip_longest(before, after, fillvalue=0):
        if old != new:
            if new < old:
                fail(
                    f"{what}: upstream reports {latest} which is older than the committed "
                    f"{current}; refusing to downgrade. Edit the file by hand if this is intended."
                )
            return


def read_declared_version(text: str, what: str) -> str:
    match = re.search(VERSION_RE, text)
    if match is None:
        fail(f"{what}: no `version \"...\"` line found")
    return match.group(2)


def rewrite(text: str, version: str, artifacts: list[tuple[str, str]], what: str) -> str:
    """Replace the version literal, and bind each digest to the artifact it belongs to.

    Digests are attached by proximity to the `url` line that names the same file,
    never by the order the platform blocks happen to appear in.  Assigning them
    positionally would silently swap the architectures if the blocks were ever
    reordered -- a cask that installs and then fails the checksum for the wrong CPU.
    """
    updated, count = re.subn(VERSION_RE, lambda m: f'{m.group(1)}"{version}"', text)
    if count != 1:
        fail(f"{what}: expected exactly 1 version line, found {count}")

    lines = updated.splitlines(keepends=True)
    url_indexes = [i for i, line in enumerate(lines) if URL_LINE_RE.match(line)]
    hash_indexes = [i for i, line in enumerate(lines) if HASH_LINE_RE.match(line)]
    if len(hash_indexes) != len(artifacts):
        fail(f"{what}: found {len(hash_indexes)} sha256 lines for {len(artifacts)} artifacts")

    assigned: dict[int, str] = {}
    for fragment, digest in artifacts:
        naming = [i for i, line in enumerate(lines) if fragment in line]
        if len(naming) != 1:
            fail(f"{what}: expected exactly 1 line naming {fragment!r}, found {len(naming)}")
        fragment_line = naming[0]

        # A cask may split the url over continuation lines, so anchor on the nearest
        # preceding `url` statement rather than on the fragment's own line.
        anchors = [i for i in url_indexes if i <= fragment_line]
        if not anchors:
            fail(f"{what}: {fragment!r} is not inside a url statement")
        anchor = anchors[-1]

        best: tuple[int, int] | None = None
        for index in hash_indexes:
            if index in assigned:
                continue
            low, high = sorted((anchor, index))
            if any(low < other < high for other in url_indexes):
                continue  # that hash belongs to a different url statement
            distance = abs(anchor - index)
            if best is None or distance < best[0]:
                best = (distance, index)
        if best is None:
            fail(f"{what}: no sha256 line could be bound to {fragment!r}")

        line = lines[best[1]]
        updated_line, count = re.subn(r'"[0-9a-f]{64}"', f'"{digest}"', line, count=1)
        if count != 1:
            fail(f"{what}: could not replace the sha256 literal for {fragment!r}")
        lines[best[1]] = updated_line
        assigned[best[1]] = digest

    if len(assigned) != len(hash_indexes):
        fail(f"{what}: {len(hash_indexes) - len(assigned)} sha256 line(s) were left unassigned")

    result = "".join(lines)

    # Re-derive the binding from the rewritten text and require it to agree, so a
    # digest can never land next to the wrong artifact unnoticed.
    verify_bindings(result, artifacts, what)
    if result.count(f'version "{version}"') != 1:
        fail(f"{what}: rewritten file does not declare exactly one version {version}")
    return result


def verify_bindings(text: str, artifacts: list[tuple[str, str]], what: str) -> None:
    lines = text.splitlines()
    url_indexes = [i for i, line in enumerate(lines) if URL_LINE_RE.match(line)]
    for fragment, digest in artifacts:
        naming = [i for i, line in enumerate(lines) if fragment in line]
        if len(naming) != 1:
            fail(f"{what}: expected exactly 1 line naming {fragment!r} after rewrite")
        anchors = [i for i in url_indexes if i <= naming[0]]
        if not anchors:
            fail(f"{what}: {fragment!r} lost its url statement")
        anchor = anchors[-1]
        candidates = [i for i, line in enumerate(lines) if HASH_LINE_RE.match(line)]
        bound = [
            lines[i]
            for i in candidates
            if not any(sorted((anchor, i))[0] < other < sorted((anchor, i))[1] for other in url_indexes)
        ]
        if not any(digest in line for line in bound):
            fail(f"{what}: {digest} is not bound to {fragment!r} after rewrite")


def validate_no_leftovers(updated: str, previous: str, old_hashes: list[str], what: str) -> None:
    if f'version "{previous}"' in updated:
        fail(f"{what}: old version {previous} still present after rewrite")
    for value in old_hashes:
        if value in updated:
            fail(f"{what}: old sha256 {value} still present after rewrite")


# --------------------------------------------------------------------------- #
# tokscos-work  (Cask, macOS)
#
# metadata: files.<platform>.name / .sha256 / .size, where .sha256 is the hash of
# the downloadable zip itself.
# --------------------------------------------------------------------------- #
def bump_work() -> str | None:
    meta = fetch_json(WORK_META_URL)
    latest = meta["version"]
    text = WORK_FILE.read_text(encoding="utf-8")
    current = read_declared_version(text, "tokcos-work")

    if current == latest:
        log(f"tokcos-work: already at {latest}")
        return None

    log(f"tokcos-work: {current} -> {latest}")
    assert_not_a_downgrade(current, latest, "tokcos-work")
    artifacts: list[tuple[str, str]] = []
    old_hashes = re.findall(r'sha256 "([0-9a-f]{64})"', text)

    with tempfile.TemporaryDirectory() as workdir:
        for platform in ("darwin-arm64", "darwin-x64"):
            info = meta["files"][platform]
            name = info["name"]  # e.g. "1.2.4/Tokcos Work-1.2.4-arm64-mac.zip"
            filename = name.split("/", 1)[-1]
            url = f"{COS}/tokcos-gui/release/" + urllib.parse.quote(name, safe="/")

            # The cask must reference the very file upstream published.  Compare its
            # `#{version}` template against the metadata name so a rename upstream
            # fails here instead of silently producing a cask pointing at a 404.
            fragment = manifest_fragment(filename, latest)
            if fragment not in text:
                fail(
                    f"tokcos-work {platform}: Cask does not reference {fragment!r}; "
                    "upstream renamed the artifact, update Casks/tokcos-work.rb by hand"
                )

            real, size = download(url, Path(workdir) / filename)
            if real != info["sha256"]:
                warn(
                    f"tokcos-work {platform}: upstream sha256 {info['sha256']} != artifact "
                    f"{real}; using the artifact value"
                )
            if "size" in info and size != info["size"]:
                warn(f"tokcos-work {platform}: upstream size {info['size']} != artifact {size}")
            log(f"  {platform}: {real} ({size} bytes)")
            artifacts.append((fragment, real))

    updated = rewrite(text, latest, artifacts, "tokcos-work")
    validate_no_leftovers(updated, current, old_hashes, "tokcos-work")
    WORK_FILE.write_text(updated, encoding="utf-8")
    validate_ruby(WORK_FILE)
    return latest


# --------------------------------------------------------------------------- #
# tokscos-cli  (Formula, macOS)
#
# metadata: platforms.<platform>.sha256 (hash of the *unpacked* binary),
#           platforms.<platform>.archive (hash of the downloadable tarball),
#           platforms.<platform>.size    (tarball size).
# The Formula needs the tarball hash, i.e. `.archive`, never `.sha256`.
# --------------------------------------------------------------------------- #
def bump_cli() -> str | None:
    meta = fetch_json(CLI_META_URL)
    latest = meta["version"]
    text = CLI_FILE.read_text(encoding="utf-8")
    current = read_declared_version(text, "tokcos-cli")

    if current == latest:
        log(f"tokcos-cli: already at {latest}")
        return None

    log(f"tokcos-cli: {current} -> {latest}")
    assert_not_a_downgrade(current, latest, "tokcos-cli")
    artifacts: list[tuple[str, str]] = []
    old_hashes = re.findall(r'sha256 "([0-9a-f]{64})"', text)

    for platform in ("darwin-arm64", "darwin-x64"):
        info = meta["platforms"][platform]
        filename = f"tokcos-cli-{platform}.tar.gz"
        fragment = manifest_fragment(filename, latest)
        if fragment not in text:
            fail(f"tokcos-cli {platform}: Formula does not reference {filename}")
        url = f"{COS}/tokcos-cli/release/{latest}/{filename}"

        with tempfile.TemporaryDirectory() as workdir:
            archive = Path(workdir) / filename
            real, size = download(url, archive)

            inner = sha256_tar_member(archive, f"{platform}/tokcos-cli")
            if inner != info["sha256"]:
                fail(
                    f"tokcos-cli {platform}: unpacked binary hashes to {inner} but upstream "
                    f"declares {info['sha256']}; the artifact is not the declared build, refusing to bump"
                )

            if real != info["archive"]:
                warn(
                    f"tokcos-cli {platform}: upstream archive {info['archive']} != artifact "
                    f"{real}; using the artifact value"
                )
            if size != info["size"]:
                warn(f"tokcos-cli {platform}: upstream size {info['size']} != artifact {size}")
            log(f"  {platform}: archive {real} ({size} bytes), binary {inner} verified")

        artifacts.append((fragment, real))

    updated = rewrite(text, latest, artifacts, "tokcos-cli")
    validate_no_leftovers(updated, current, old_hashes, "tokcos-cli")
    CLI_FILE.write_text(updated, encoding="utf-8")
    validate_ruby(CLI_FILE)
    return latest


def main() -> int:
    work = bump_work()
    cli = bump_cli()

    set_output("work_changed", "true" if work else "false")
    set_output("work_version", work or "")
    set_output("cli_changed", "true" if cli else "false")
    set_output("cli_version", cli or "")
    set_output("changed", "true" if (work or cli) else "false")

    if not work and not cli:
        log("All Tokcos Homebrew packages are already up to date.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
