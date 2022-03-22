cask "nicepage" do
  version "4.7.1"
  sha256 "aee9534eb0fecca35f60b59d50078ff618dc634d3c40cb4a5716fb06faca603d"

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

