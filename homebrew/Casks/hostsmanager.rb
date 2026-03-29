cask "hostsmanager" do
  version "1.0.0"
  sha256 "THAY_BANG_SHA256_THUC_TE"

  url "https://github.com/twannguyenba-hash/HostsManager/releases/download/v#{version}/HostsManager-v#{version}.zip"
  name "HostsManager"
  desc "Quản lý file /etc/hosts trên macOS"
  homepage "https://github.com/twannguyenba-hash/HostsManager"

  depends_on macos: ">= :ventura"

  app "HostsManager.app"

  zap trash: [
    "~/Library/Caches/com.hostsmanager.app",
    "~/Library/Preferences/com.hostsmanager.app.plist",
    "~/Library/Saved Application State/com.hostsmanager.app.savedState",
  ]
end
