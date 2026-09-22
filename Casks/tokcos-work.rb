cask "tokcos-work" do
  version "1.2.2"

  on_arm do
    url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/" \
        "tokcos-gui/release/#{version}/Tokcos%20Work-#{version}-arm64-mac.zip"
  end

  on_intel do
    url "https://tokcos-1328134559.cos.ap-guangzhou.myqcloud.com/" \
        "tokcos-gui/release/#{version}/Tokcos%20Work-#{version}-x64-mac.zip"
  end

  sha256 :no_check

  name "Tokcos Work"
  desc "Tokcos desktop application"
  homepage "https://www.tokcos.com/"

  livecheck do
    url :homepage
    regex(%r{tokcos-gui/release/(\d+(?:\.\d+)+)/}i)
  end

  app "Tokcos Work.app"
end
