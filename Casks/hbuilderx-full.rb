cask "hbuilderx-full" do
  version "3.7.11.20230427"
  # sha256 "291e37b2ea283937472044ced78e9a29414ffd79e308d7c7c12fbd1cd684c819"

  url "https://download1.dcloud.net.cn/download/HBuilderX.#{version}.full.dmg",
      verified: "download1.dcloud.net.cn/"
  name "HBuilderX-Full"
  desc "HTML editor"
  homepage "https://www.dcloud.io/hbuilderx.html"

  livecheck do
    url "https://download1.dcloud.net.cn/hbuilderx/release.json"
    strategy :page_match do |page|
      JSON.parse(page)["version"]
    end
  end

  app "HBuilderX.app"
end
