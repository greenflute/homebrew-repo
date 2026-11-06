cask "tokcos-work" do
  version "1.3.18"

  on_arm do
    sha256 "d33e3b8523f331cf94bff8d0dd3218c1763a3101210f7a3c4db165b6ecf482cc"

    url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/" \
        "tokcos-gui/release/#{version}/Tokcos%20Work-#{version}-arm64-mac.zip"
  end
  on_intel do
    sha256 "6a3675917603f37607b546b68fb184d47a2b85b3b7d33b1bdb9cd67b5f49c9e6"

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
