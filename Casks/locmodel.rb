cask "locmodel" do
  version "3.6.2"
  sha256 :no_check # The official download page does not publish a checksum.

  url "https://locmodel.com/LocModel_#{version}_universal.dmg"
  name "LocModel"
  desc "Local AI model deployment and studio"
  homepage "https://locmodel.com/"

  livecheck do
    # The homepage embeds schema.org JSON-LD for the app, and its
    # "softwareVersion" field is the machine-readable release number.  It is
    # used instead of the DMG filename because `url :url` inherits this cask's
    # `#{version}` template, so the page it fetched contained only the *old*
    # version and the check could never see a new release.
    url "https://locmodel.com/"
    regex(/"softwareVersion"\s*:\s*"(\d+(?:\.\d+)+)"/i)
  end

  depends_on :macos

  app "LocModel.app"

  caveats <<~EOS
    LocModel is not signed or notarized. macOS may block the first launch.
    The official instructions use:
      sudo xattr -rd com.apple.quarantine /Applications/LocModel.app
  EOS
end
