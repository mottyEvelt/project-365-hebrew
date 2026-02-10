@echo off
setlocal enabledelayedexpansion

set ANDROID_HOME=C:\Android\Sdk
set ANDROID_SDK_ROOT=C:\Android\Sdk
set PATH=C:\flutter\bin;%PATH%

echo ANDROID_HOME: %ANDROID_HOME%
echo Building APK...

cd /d "C:\Users\MordechaiGreenbaum\Downloads\Project-365-1.1.1\Project-365-1.1.1"
call flutter build apk --release

echo.
echo Build complete! APK location:
echo build\app\outputs\flutter-apk\app-release.apk
pause
