class Moonbit < Formula
  MOONBIT_VERSION = "0.10.14+7d59c7ec9".freeze
  COMMANDS = %w[
    moon
    moonx
    moon-cram
    moon-ide
    moon-lsp
    moon-wasm-opt
    moon_cove_report
    moonc
    mooncake
    moondoc
    moonfmt
    mooninfo
    moonrun
  ].freeze

  desc "Programming language toolchain for cloud and edge computing"
  homepage "https://www.moonbitlang.com/"
  url "https://cli.moonbitlang.com/binaries/0.10.14%2B7d59c7ec9/moonbit-darwin-aarch64.tar.gz"
  version MOONBIT_VERSION
  sha256 "20967f9389ac54508899ee2fc051a3470d051452bac5818a9696ed4c144f3ec3"
  license :cannot_represent

  livecheck do
    skip "MoonBit does not publish a machine-readable toolchain version endpoint"
  end

  depends_on arch: :arm64
  depends_on :macos

  resource "core" do
    url "https://cli.moonbitlang.com/cores/core-0.10.14%2B7d59c7ec9.tar.gz"
    sha256 "6f18b8fdea18f85e628a75e4a1bd3977c5a5c9c6a836fd8824192b0e6bd91b14"
  end

  def install
    libexec.install buildpath.children
    resource("core").stage do
      (libexec/"lib/core").install Dir["*"]
    end

    chmod 0755, (libexec/"bin").children.select(&:file?)
    chmod 0755, libexec/"bin/internal/tcc"
    ln_s "moon", libexec/"bin/moonx"

    ENV["MOON_TOOLCHAIN_ROOT"] = libexec
    ENV.prepend_path "PATH", libexec/"bin"
    system libexec/"bin/moon", "-C", libexec/"lib/core", "bundle", "--warn-list", "-a", "--all"
    system libexec/"bin/moon", "-C", libexec/"lib/core", "bundle", "--warn-list", "-a",
                                     "--target", "wasm-gc", "--quiet"

    COMMANDS.each do |command|
      bin.install_symlink libexec/"bin/#{command}"
    end
  end

  test do
    ENV["MOON_HOME"] = testpath/"moon-home"
    assert_match version.to_s, shell_output("#{bin}/moonc -v")
    assert_match "The build system and package manager for MoonBit", shell_output("#{bin}/moon help")

    system bin/"moon", "new", "--user", "homebrew", "hello"
    (testpath/"hello").cd do
      assert_equal "Hello\n", shell_output("#{bin}/moon run cmd/main")
    end
  end
end
