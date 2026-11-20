# Cozy Focus Room — Godot 4.7 Desktop Client

Phiên bản desktop viết bằng **Godot 4.7.2 (Forward+)** của **Cozy Focus Room: Lo-Fi & Together**, kết nối chung backend multiplayer, cơ sở dữ liệu phòng và xác thực Google với dự án gốc.

## Kết nối dùng chung
- **Multiplayer & Storage Backend (Railway):** `https://cozy-focus-server-production.up.railway.app` (Socket.IO v4 / Engine.IO v4 qua WebSocket + PostgreSQL)
- **Google OAuth 2.0:** Luồng xác thực qua endpoint `/auth/google/start` của server với cùng `GOOGLE_CLIENT_ID`

## Phát hành tự động (CI/CD & Auto-Updater)
- Mọi commit push lên nhánh `main` (trừ `[skip release]`) tự động chạy workflow [release.yml](.github/workflows/release.yml):
  - Tự tăng phiên bản theo dạng `1.0.<GITHUB_RUN_NUMBER>` (ví dụ `v1.0.1`, `v1.0.2`).
  - Export **macOS** (`.dmg` + `_macos.app.zip`) và **Windows 64-bit** (`.exe`).
  - Tạo tệp `latest.json` và publish lên GitHub Releases.
- Trong game, `GameStore` kiểm tra `releases/latest/download/latest.json` định kỳ mỗi 60 giây, khi khởi động và khi cửa sổ được focus lại; khi có bản mới hơn `config/version`, banner cập nhật sẽ xuất hiện để người dùng tải về với thanh tiến trình và tự cài đặt.
