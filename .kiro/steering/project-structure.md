# FeloNa Project Structure

This is a **full-stack project** with two main parts:

## Flutter Frontend (Mobile + Web)
- **Location:** `d:\Felona\felo_na\` (project root)
- **Language:** Dart/Flutter
- **Run command:** `flutter run -d chrome` (for web)
- **Config:** `pubspec.yaml`

## Node.js Backend (API Server)
- **Location:** `d:\Felona\felo_na\backend\`
- **Language:** JavaScript (CommonJS)
- **Run command:** `npm run dev` (uses nodemon)
- **Config:** `backend/package.json`
- **Framework:** Express.js
- **Database:** PostgreSQL (via Sequelize)
- **AI:** Google Generative AI

## Running Both Together
- **Batch script:** `run_all.bat` at project root — launches both in separate terminal windows
- **VS Code Tasks:** Use `Ctrl+Shift+B` to run "Run All (Backend + Flutter)" task which starts both in parallel

## Key Directories
- `lib/` — Flutter/Dart source code
- `backend/src/` — Node.js source code
- `backend/uploads/` — File uploads directory
- `Assets/` — Flutter assets (fonts, images, backgrounds)
- `scripts/` — Utility scripts
