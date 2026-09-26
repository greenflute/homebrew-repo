class TokcosCli < Formula
  LATEST_RELEASE_URL = "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/latest.json".freeze

  desc "Token-efficient AI coding assistant for the terminal"
  homepage "https://www.tokcos.com/"
  version "0.5.9"

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
      sha256 "cc7a84ec1864a0b63836da71e0368d1977da458610416b82bd6878e4bc9017a7"
    end

    on_intel do
      url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-cli/release/#{version}/tokcos-cli-darwin-x64.tar.gz"
      sha256 "48d777e0731bf51486e64b5d171fcb4d523a0fa5034a490c3c7b7afd45f9e0e8"
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
