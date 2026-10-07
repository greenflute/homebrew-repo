cask "tokcos-work" do
  version "1.2.7"

  on_arm do
    sha256 "f34cce200754c1ee74aecd7c313a928593ffa2d0475b70809941c5e7417dfd5c"

    url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/" \
        "tokcos-gui/release/#{version}/Tokcos%20Work-#{version}-arm64-mac.zip"
  end
  on_intel do
    sha256 "6707206e66fc622e4e1d8374267eccb09b4b4674812e92416150da41e09c7af8"

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
