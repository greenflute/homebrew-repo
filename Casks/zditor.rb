cask "zditor" do
  version "2.0.10"
  sha256 :no_check # The official release metadata does not publish SHA256 checksums.

  on_arm do
    url "https://download.zditor.com/zditor-v#{version}/zditor_#{version}_aarch64.dmg"
  end
  on_intel do
    url "https://download.zditor.com/zditor-v#{version}/zditor_#{version}_x64.dmg"
  end

  name "Zditor"
  desc "Writing, drawing, and AI workspace"
  homepage "https://zditor.com/"

  livecheck do
    url "https://zditor.com/api/releases"
    regex(/"version"\s*:\s*"(\d+(?:\.\d+)+)"/i)
  end

  depends_on macos: :ventura

  app "Zditor.app"
end
