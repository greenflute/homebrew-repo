class TokcosCli < Formula
  LATEST_RELEASE_URL = "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/latest.json".freeze

  desc "Token-efficient AI coding assistant for the terminal"
  homepage "https://www.tokcos.com/"
  version "0.6.0"

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
      sha256 "0a28fbffb373a835a6ce56f9a75115504282d7a79630318e757ee8e96097eff1"
    end

    on_intel do
      url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/#{version}/tokcos-cli-darwin-x64.tar.gz"
      sha256 "94b783d84931666190c92a230798992196326b0381389beacc47a39b8c792fed"
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
