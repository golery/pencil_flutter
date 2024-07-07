# pencil_flutter

A new Flutter project.

# WIFI Debug
https://chatgpt.com/c/9bd0f808-9c15-4ca4-a50a-9182ecfe5335
adb pair 192.168.4.90:port
adb connect 192.168.4.90:port
adb devices
Hint: Turn on USB debug - it helps to keep conneciton even if screen is locked


# DEV
Set IS_WIDGET_DEV = false in main.dart
Or set it to true and modify the page in dev.dart
flutter run

# Install release version
flutter run --release

# ICON 
1. Generate with https://pixcap.com/, https://app.recraft.ai/ with large size, background white
   Crop so that icon take all space (Android will add extra padding) and resize to 512x512
2. Copy image to C:\repos\pencil_flutter\assets\icons\launcher.png
3. Run flutter pub run flutter_launcher_icons