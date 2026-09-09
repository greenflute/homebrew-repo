class TokcosCli < Formula
  desc "Token-efficient AI coding assistant for the terminal"
  homepage "https://www.tokcos.com/"
  version "0.5.5"

  on_macos do
    on_arm do
      url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/0.5.5/tokcos-cli-darwin-arm64.tar.gz"
      sha256 "0d6feb22ac2e03bd405f5ced68c8db91d5048236b812d5ec5bdbfefad87a52b9"
    end

    on_intel do
      url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/0.5.5/tokcos-cli-darwin-x64.tar.gz"
      sha256 "47261d123b138b8d12b55f476c7db39be5ba037a5c1701a99a38c0593699b42e"
    end
  end

  depends_on :macos

  def install
    # Homebrew strips the archive's single enclosing platform directory.
    # Pathname#children includes .env and preserves all adjacent runtime assets.
    libexec.install buildpath.children
    chmod 0755, libexec/"tokcos-cli"
    bin.install_symlink libexec/"tokcos-cli"
  end

  test do
    # The CLI requires a TTY, even when passed --version.
    assert_match "no TTY", shell_output("#{bin}/tokcos-cli </dev/null 2>&1")
  end
end
