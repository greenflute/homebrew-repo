cask "nicepage" do
  version "4.19.3"

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

