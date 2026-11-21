cask "tokcos-work" do
  version "1.4.30"

  on_arm do
    sha256 "2fe0e80bde486291930e84843374badf082480776f781b25cdac23b0da4f868f"

    url "https://tokcos-agent-1328134559.cos.eu-frankfurt.myqcloud.com/" \
        "tokcos-gui/release/#{version}/Tokcos%20Work-#{version}-arm64-mac.zip"
  end
  on_intel do
    sha256 "80702d2bcd7a39d822054dd2cf12db081d2341ef52a30d56c4f7ceaf2adce772"

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
