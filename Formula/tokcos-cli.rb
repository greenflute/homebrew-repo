class TokcosCli < Formula
  desc "Token-efficient AI coding assistant for the terminal"
  homepage "https://www.tokcos.com/"
  version "0.5.8"

  livecheck do
    url :homepage
    regex(%r{tokcos-cli/release/v?(\d+(?:\.\d+)+)/tokcos-cli-darwin-arm64\.tar\.gz}i)
  end

  on_macos do
    on_arm do
      url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/0.5.8/tokcos-cli-darwin-arm64.tar.gz"
      sha256 "这里填写 0.5.8 arm64 的 SHA256"
    end

    on_intel do
      url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/0.5.8/tokcos-cli-darwin-x64.tar.gz"
      sha256 "这里填写 0.5.8 x64 的 SHA256"
    end
  end

  depends_on :macos

  def install
    libexec.install buildpath.children
    chmod 0755, libexec/"tokcos-cli"
    bin.install_symlink libexec/"tokcos-cli"
  end

  test do
    assert_match "no TTY", shell_output("#{bin}/tokcos-cli </dev/null 2>&1")
  end
end
