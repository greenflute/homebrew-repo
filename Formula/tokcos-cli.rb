class TokcosCli < Formula
  LATEST_RELEASE_URL = "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/latest.json".freeze

  desc "Token-efficient AI coding assistant for the terminal"
  homepage "https://www.tokcos.com/"
  version "2.0.9"

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
      sha256 "2e696c0a0fb90b472bc02488326679e9e9661b5c39b20c6c10d4ffcd9d7f6995"
    end

    on_intel do
      url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/#{version}/tokcos-cli-darwin-x64.tar.gz"
      sha256 "712667ef32ee2691efa22f0d9796ebef8744bcb1e31f24029ce0da2ebbb5026c"
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
