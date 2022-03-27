cask "synergy" do
  version "1.14.3"
  sha256 "1247917397174014840f5c24b583ec76c6a7c456c0bd6065ad2337334ff84667"


  url "https://s3.us-east-1.amazonaws.com/binaries.symless.com/synergy/v1-core-standard/#{version}-stable.218fa800/synergy_#{version}-stable.218fa800_macos_x86-64.dmg"
  name "synergy"
  desc "Share one mouse and keyboard across multiple computers"
  homepage "https://symless.com/synergy"

  app "Synergy.app"
end

