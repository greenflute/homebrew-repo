class TokcosCli < Formula
  LATEST_RELEASE_URL = "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/latest.json".freeze

  desc "Token-efficient AI coding assistant for the terminal"
  homepage "https://www.tokcos.com/"
  version "0.5.8"

  livecheck do
    url LATEST_RELEASE_URL
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on :macos

  on_macos do
    on_arm do
      url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/#{version}/tokcos-cli-darwin-arm64.tar.gz"
      sha256 "cdb6e61e534d864280051a06fb92e98168273518e367426a0d0d1b5826f3a7fc"
    end

    on_intel do
      url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/#{version}/tokcos-cli-darwin-x64.tar.gz"
      sha256 "c43ca64b1d0fdfb2608fc2d8a4e354f24269ba650db9f5ff226207541f3e3d67"
    end
  end

  def install
    libexec.install buildpath.children
    chmod 0755, libexec/"tokcos-cli"
    bin.install_symlink libexec/"tokcos-cli"
  end

  test do
    assert_match "no TTY", shell_output("#{bin}/tokcos-cli </dev/null 2>&1")
  end
end
