cask "devly" do
  version "1.0.1"
  sha256 "1c151380e36f26d78668cb3ff4c2e378b8c8edd0424eb85295d06434acc44016"

  url "https://github.com/twan-nguyen/Devly/releases/download/v#{version}/Devly-v#{version}.zip"
  name "Devly"
  desc "Quản lý /etc/hosts và .env files cho dev trên macOS"
  homepage "https://github.com/twan-nguyen/Devly"

  depends_on macos: ">= :ventura"

  app "Devly.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Devly.app"]
  end

  zap trash: [
    "~/Library/Caches/com.devly.app",
    "~/Library/Preferences/com.devly.app.plist",
    "~/Library/Saved Application State/com.devly.app.savedState",
  ]
end
