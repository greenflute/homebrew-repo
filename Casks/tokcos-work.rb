cask "tokcos-work" do
  version "1.2.5"

  on_arm do
    sha256 "80b093e75916618b8e7f0c46f5d35f05cd930f3e405ead803434c49c2729203b"

    url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/" \
        "tokcos-gui/release/#{version}/Tokcos%20Work-#{version}-arm64-mac.zip"
  end
  on_intel do
    sha256 "6ccd6c4a6dabe86832a00996468c25b5ecf2bd01ef3c013c0716cc8aec967348"

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
