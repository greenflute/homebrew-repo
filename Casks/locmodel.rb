cask "locmodel" do
  version "3.5.0"
  sha256 :no_check # The official download page does not publish a checksum.

  url "https://locmodel.com/LocModel_#{version}_universal.dmg"
  name "LocModel"
  desc "Local AI model deployment and studio"
  homepage "https://locmodel.com/"

  livecheck do
    url "https://locmodel.com/changelog.html"
    regex(/v(\d+(?:\.\d+)+)\s+LATEST/i)
  end

  depends_on :macos

  app "LocModel.app"

  caveats <<~EOS
    LocModel is not signed or notarized. macOS may block the first launch.
    The official instructions use:
      sudo xattr -rd com.apple.quarantine /Applications/LocModel.app
  EOS
end
