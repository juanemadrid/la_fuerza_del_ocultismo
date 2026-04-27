@echo off
echo ========================================
echo  Construyendo APK de La Fuerza Del Ocultismo
echo ========================================
echo.
echo Construyendo APK en modo release...
echo (Esto puede tomar varios minutos)
echo.
flutter build apk --release
echo.
echo ========================================
echo  APK Construido Exitosamente!
echo ========================================
echo.
echo El APK esta en:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo Puedes:
echo 1. Instalarlo con: adb install build\app\outputs\flutter-apk\app-release.apk
echo 2. Copiarlo a tu celular e instalarlo manualmente
echo.
pause
