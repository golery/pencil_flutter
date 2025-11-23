@echo off
REM Batch script to run Flutter app on main user profile (not work profile)
REM Usage: run.bat [additional flutter run arguments]
REM Example: run.bat --release

flutter run --device-user 0 %*

