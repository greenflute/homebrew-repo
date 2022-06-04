cask "nicepage" do
  version "4.12.5"
  # sha256 "95437ed31561be1ef927ce17a3ed192246bdc72e650beebb0e349d754f81b6c6"

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

