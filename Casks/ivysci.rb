cask "ivysci" do
  version "3.10.10"
  
  arch arm: "-arm64", intel: ""
  url "https://package.cdn.ivysci.com/ikran/ivySCI-#{version}#{arch}.dmg"
  
  name "ivySCI"
  desc "ivySCI 你贴心的论文助理"
  homepage "https://www.ivysci.com"

  app "ivySCI.app"
end

