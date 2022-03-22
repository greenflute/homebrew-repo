cask "nicepage" do
  version "4.7.1"
  sha256 "a1db864fe638701fa2f039c4e5bd2394bbf03489576abde46833ccef90432814"

  url "https://get.nicepage.com/Nicepage-#{version}.dmg"
  name "nicepage"
  desc "Web Site Builder Software"
  homepage "https://www.nicepage.com/"

  livecheck do
    url "https://nicepage.com/get/mac"
    strategy :header_match
    regex(/Nicepage-(\d+(?:\.\d+)+)\.dmg/i)
  end

  app "Nicepage.app"
end

