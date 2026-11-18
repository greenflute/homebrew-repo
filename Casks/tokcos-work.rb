cask "tokcos-work" do
  version "1.4.21"

  on_arm do
    sha256 "ddb68206c1fd4124c16313081cbafa4b878cc587722747736e9517a230fb5336"

    url "https://tokcos-agent-1328134559.cos.eu-frankfurt.myqcloud.com/" \
        "tokcos-gui/release/#{version}/Tokcos%20Work-#{version}-arm64-mac.zip"
  end
  on_intel do
    sha256 "234755076884bca3cffaa62fae621c5eae3d02712eecf24281d6afc939068329"

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
