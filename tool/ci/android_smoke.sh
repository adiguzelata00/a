#!/usr/bin/env bash
# Installs the release APK on the running emulator, starts it and fails
# (printing the crash log) if the app is not alive after a while.
set -u
PKG=com.tengritaslari.tengri_taslari
APK=build/app/outputs/flutter-apk/app-release.apk

adb install -r "$APK" || exit 1
adb logcat -c
adb shell am start -W -n "$PKG/.MainActivity"
sleep 30
adb shell screencap -p /sdcard/smoke.png && adb pull /sdcard/smoke.png smoke.png
adb logcat -d > logcat.txt
echo "===== crash buffer ====="
adb logcat -d -b crash | tee crash.txt
echo "===== AndroidRuntime / flutter ====="
grep -E "AndroidRuntime|FATAL|flutter|Ads|UserMessaging" logcat.txt | tail -n 150
if adb shell pidof "$PKG" > /dev/null; then
  echo "SMOKE OK: app is running"
else
  echo "SMOKE FAILED: app is not running"
  exit 1
fi
