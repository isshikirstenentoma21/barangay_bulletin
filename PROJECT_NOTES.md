# Barangay Bulletin

Offline-first Flutter app for barangay announcements and issue reports.

## Open in VS Code

Open this folder:

`C:\Users\Dell\Documents\Codex\2026-05-27\files-mentioned-by-the-user-barangay\barangay_bulletin`

## What Is Included

- Bottom navigation with Announcements, Reports, and Archive tabs
- Separate navigator stack per tab
- Hive local storage with generated TypeAdapters
- Announcement CRUD with category filter, pinning, soft delete, restore, and hard delete
- Issue report CRUD with category/status filters, soft delete, restore, and hard delete
- Form validation and confirmation dialogs
- `setState` only for UI state management

## Useful Commands

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart analyze
flutter test
flutter run
```

## Local Setup Notes

The code has already passed `dart analyze` and `flutter test`.

APK building is currently blocked because this computer does not have an Android SDK configured. Install Android Studio or the Android command-line tools, then make sure Flutter can detect the SDK with:

```powershell
flutter doctor
```

Windows also reported that Developer Mode is off while preparing plugins. If `flutter pub get` shows a symlink warning, turn on Developer Mode in Windows Settings.
