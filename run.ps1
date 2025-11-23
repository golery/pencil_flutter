# PowerShell script to run Flutter app on main user profile (not work profile)
# Usage: .\run.ps1 [additional flutter run arguments]
# Example: .\run.ps1 --release

flutter run --device-user 0 $args

