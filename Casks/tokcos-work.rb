cask "tokcos-work" do
  version "1.3.15"

  on_arm do
    sha256 "3a54e3e36fc7826b3214e9af9a7d6de944a2bd50d44614633f1ecec3ca889e97"

    url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/" \
        "tokcos-gui/release/#{version}/Tokcos%20Work-#{version}-arm64-mac.zip"
  end
  on_intel do
    sha256 "d54dde2b9b8cae0c9a338030a5ef6b6f960ca4257d5b2ae8f404884477156d9d"

    url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/" \
        "tokcos-gui/release/#{version}/Tokcos%20Work-#{version}-x64-mac.zip"
  end

  name "Tokcos Work"
  desc "Desktop app for building AI workflows and managing local MCP servers"
  homepage "https://www.tokcos.com/"

  livecheck do
    url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/tokcos-gui/release/latest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on :macos

  app "Tokcos Work.app"

  caveats <<~EOS
    The upstream app is not signed with an Apple Developer ID and may be blocked by Gatekeeper.
  EOS
end
