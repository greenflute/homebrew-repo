cask "tokcos-work" do
  version "1.4.31"

  on_arm do
    sha256 "86e36bafe249eff801f43ebe97e36de9514da6728b1b10a793e39dd14178e3db"

    url "https://tokcos-agent-1328134559.cos.eu-frankfurt.myqcloud.com/" \
        "tokcos-gui/release/#{version}/Tokcos%20Work-#{version}-arm64-mac.zip"
  end
  on_intel do
    sha256 "d6920326cda5849f1f0dbb8e9af19c25aa1056542a68e8fd9aef7dd027fcca2c"

    url "https://tokcos-agent-1328134559.cos.eu-frankfurt.myqcloud.com/" \
        "tokcos-gui/release/#{version}/Tokcos%20Work-#{version}-x64-mac.zip"
  end

  name "Tokcos Work"
  desc "Desktop app for building AI workflows and managing local MCP servers"
  homepage "https://www.tokcos.com/"

  livecheck do
    url "https://tokcos-agent-1328134559.cos.eu-frankfurt.myqcloud.com/tokcos-gui/release/latest.json"
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
