# Inter Font Installation Guide

## 📥 Download Inter Font

The Inter font family needs to be downloaded and added to the project.

### Option 1: Download from Google Fonts (Recommended)
1. Visit: https://fonts.google.com/specimen/Inter
2. Click "Download family"
3. Extract the ZIP file
4. Copy these files to `d:\Felona\felo_na\fonts\`:
   - `Inter-Regular.ttf` (weight 400)
   - `Inter-Medium.ttf` (weight 500)
   - `Inter-SemiBold.ttf` (weight 600)
   - `Inter-Bold.ttf` (weight 700)

### Option 2: Download from Official Site
1. Visit: https://rsms.me/inter/
2. Click "Download Inter"
3. Extract and find the TTF files in the `Inter Desktop` folder
4. Copy the required weights to `d:\Felona\felo_na\fonts\`

## 📁 Folder Structure

Create this structure:
```
d:\Felona\felo_na\
├── fonts\
│   ├── Inter-Regular.ttf
│   ├── Inter-Medium.ttf
│   ├── Inter-SemiBold.ttf
│   └── Inter-Bold.ttf
├── lib\
├── pubspec.yaml
```

## ✅ Verification

After adding the fonts:
1. Run `flutter pub get`
2. Restart the app
3. The Inter font will be applied automatically

## 🎨 Font Weights Used

- **Regular (400):** Body text
- **Medium (500):** Labels, small headings
- **SemiBold (600):** Headings, important text
- **Bold (700):** Display text, emphasis

## 🔄 Alternative: Use System Font Temporarily

If you want to test without downloading fonts, you can temporarily use the system font by commenting out the `fontFamily: 'Inter'` lines in:
- `lib/core/constants/app_theme.dart`

The app will fall back to the system default font (Roboto on Android, SF Pro on iOS).

---

**Status:** Font configured in pubspec.yaml, needs to be downloaded and placed in fonts folder.
