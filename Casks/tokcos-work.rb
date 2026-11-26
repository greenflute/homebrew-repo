cask "tokcos-work" do
  version "1.5.1"

  on_arm do
    sha256 "9547a46fb91b222f70adaebf9b600cbbf57187c8378310db7c701f964f7940a0"

    url "https://tokcos-agent-1328134559.cos.eu-frankfurt.myqcloud.com/" \
        "tokcos-gui/release/#{version}/Tokcos%20Work-#{version}-arm64-mac.zip"
  end
  on_intel do
    sha256 "25fec4fa43352de72132332a4d282f69e4e9f7d08c50845b42a5e9fff7c20b93"

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
