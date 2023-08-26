cask "synergy" do
  version "1.14.6"
  # sha256 "1247917397174014840f5c24b583ec76c6a7c456c0bd6065ad2337334ff84667"


  url "https://api2.prod.symless.com/aws-downloads/synergy/v1-core-standard/#{version}-stable.455c59b4/synergy_#{version}-stable.455c59b4_macos-#{arch}.dmg"
  name "synergy"
  desc "Share one mouse and keyboard across multiple computers"
  homepage "https://symless.com/synergy"

  app "Synergy.app"
end

