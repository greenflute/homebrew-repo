cask "elasticvue" do
  version "1.6.0"

  if Hardware::CPU.intel?
    url "https://github.com/cars10/elasticvue/releases/download/v#{version}/elasticvue_#{version}_x64.dmg"
  else
    url "https://github.com/cars10/elasticvue/releases/download/v#{version}/elasticvue_#{version}_aarch64.dmg"
  end

  name "elasticvue"
  desc "Elasticsearch gui for the browser"
  homepage "https://elasticvue.com"

  livecheck do
    url "https://github.com/cars10/elasticvue"
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :big_sur

  app "Elasticvue.app"
end
