class TokcosCli < Formula
  LATEST_RELEASE_URL = "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/latest.json".freeze

  desc "Token-efficient AI coding assistant for the terminal"
  homepage "https://www.tokcos.com/"
  version "2.0.6"

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
      sha256 "73eb0b75e0e86f52a6fdecbc5d7085107167aec8b7ad581ca48d521fc1dd9149"
    end

    on_intel do
      url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/#{version}/tokcos-cli-darwin-x64.tar.gz"
      sha256 "1fa5a3f1490f4982494bb8ba42c7962f00d576760289b4e4b0ea4d255d25e2c1"
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
