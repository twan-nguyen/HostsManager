<p align="center">
  <img src="design/app-icon-1024.png" width="180" alt="Hosven icon"/>
</p>

<h1 align="center">Hosven</h1>

<p align="center">
  Ứng dụng native macOS quản lý <code>/etc/hosts</code> và <code>.env</code> files cho developer.
</p>

<p align="center">
  <img src="design/screenshots/01-hosts.png" width="720" alt="Hosven screenshot"/>
</p>

## Tính năng

- Quản lý `/etc/hosts` theo **profile** (Release / Production / ...) với màu phân biệt
- Bật/tắt từng entry inline, apply 1 click (sudo cache 5 phút, tự flush DNS)
- Quản lý nhiều `.env` file theo repo, snapshot/restore bộ env vars
- **⌘K Command Palette**: fuzzy search profile, tab, entries
- Dark mode, custom title bar, ⌘1–9 switch profile nhanh

## Cài đặt

```bash
brew tap twan-nguyen/hosven
brew install hosven
```

Cập nhật: `brew upgrade hosven`

## Sử dụng

1. Mở app — entries từ `/etc/hosts` load tự động
2. Click profile sidebar để filter; ⌘0 xem tất cả; ⌘1–9 switch nhanh
3. Toggle entry inline → ⌘S để apply (nhập mật khẩu admin lần đầu)
4. ⌘K mở Command Palette, ⌘, mở Settings

## Build từ source

Yêu cầu: macOS 15+, Xcode 15+, [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
make build && make install
```

## Giấy phép

MIT
