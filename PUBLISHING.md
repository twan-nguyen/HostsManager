# Hướng dẫn phát hành lên Homebrew

## Tổng quan

Hosven được phân phối qua Homebrew Cask thông qua một tap riêng.

## Các bước phát hành

### 1. Tạo Homebrew Tap Repository

Tạo repo trên GitHub tên `homebrew-hosven`, copy thư mục `homebrew/` vào repo đó:

```
homebrew-hosven/
├── Casks/
│   └── hosven.rb
└── .github/workflows/
    └── update-cask.yml
```

### 2. Cấu hình GitHub Secrets

Trong repo chính (`Hosven`), thêm secret:
- `TAP_REPO_TOKEN`: Personal Access Token có quyền `repo` để dispatch event sang tap repo

### 3. Phát hành phiên bản mới

```bash
./scripts/release.sh 1.0.0
```

Script sẽ:
- Cập nhật version trong `project.yml` và `Makefile`
- Tạo git commit + tag
- Push lên GitHub → trigger GitHub Actions

### 4. GitHub Actions tự động

1. **release.yml**: Build universal binary → tạo ZIP + DMG → tạo GitHub Release
2. **update-homebrew.yml**: Tính SHA256 → gửi event sang tap repo
3. **update-cask.yml** (tap repo): Cập nhật formula → tạo PR

### 5. Merge PR trong tap repo

Review và merge PR tự động trong repo `homebrew-hosven`.

## Cài đặt thủ công (không qua CI)

```bash
# Build
make release

# Lấy SHA256
make checksum

# Cập nhật formula
./scripts/update-homebrew.sh 1.0.0 <sha256>

# Upload ZIP lên GitHub Release thủ công
# Push thay đổi formula lên tap repo
```
