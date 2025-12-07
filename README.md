# pencil_flutter

# Dev setup
1. From inside wsl > ubuntu.
   Run cursor to open the IDE.
2. From WSL connect to device directly.
   flutter run
   flutter run --release   
   (add --device-user 0 to install only on main user profile)

## WIFI Debug
Settings > System > Developer options > Wireless Debugging 
adb pair 192.168.4.90:port
adb connect 192.168.4.90:port
adb devices
Hint: Turn on USB debug - it helps to keep conneciton even if screen is locked

## Work Profile Issue
When using `adb connect` to connect to devices with work profiles, Flutter may install apps to the work profile 
- `flutter run --device-user 0` (installs to main user profile)
- `flutter run --release --device-user 0` (for release builds)

The `--device-user 0` flag tells Flutter/ADB to install to the main user profile (user 0) instead of the work profile.

# DEV
Set IS_WIDGET_DEV = false in main.dart
Or set it to true and modify the page in dev.dart
flutter run

# ICON 
1. Generate with https://app.recraft.ai/ with large size, background white
   Crop so that icon take all space (Android will add extra padding) and resize to 512x512
   Resize: using Krita
2. Copy image to C:\repos\pencil_flutter\assets\icons\launcher.png
3. Run `flutter pub run flutter_launcher_icons`

# EMULATOR
1. Run LDPlayer, Settings > AdbConnection
