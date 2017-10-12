@echo off
set APP_ANDROID_ROOT=E:\Sophia\client\trunk\framework
set COCOS2DX_ROOT=E:\Sophia\client\trunk\
set APP_ROOT=E:\Sophia\client\trunk\mf.game
set NDK_MODULE_PATH=%COCOS2DX_ROOT%;%COCOS2DX_ROOT%\cocos2dx\platform\third_party\android\prebuilt
set NDK_ROOT=D:\android-ndk-r9\

echo Print Environment Variable:
echo 1. APP_ANDROID_ROOT=%APP_ANDROID_ROOT%
echo 2. COCOS2DX_ROOT=%COCOS2DX_ROOT%
echo 3. APP_ROOT=%APP_ROOT%

if exist %APP_ANDROID_ROOT%\assets (
rem rd %APP_ANDROID_ROOT%\assets /s/q
)

rem mkdir %APP_ANDROID_ROOT%\assets

if exist %APP_ROOT%\Resources (
echo Copying Resources...
rem xcopy %APP_ROOT%\Resources\*.* %APP_ANDROID_ROOT%\assets /s /y /q
)

echo Copying Icons...
if exist %APP_ANDROID_ROOT%\assets\Icon-72.png (
cpoy %APP_ANDROID_ROOT%\assets\Icon-72.png %APP_ANDROID_ROOT%\res\drawable-hdpi\icon.png
)

if exist %APP_ANDROID_ROOT%\assets\Icon-48.png (
cpoy %APP_ANDROID_ROOT%\assets\Icon-48.png %APP_ANDROID_ROOT%\res\drawable-mdpi\icon.png
)

if exist %APP_ANDROID_ROOT%\assets\Icon-32.png (
cpoy %APP_ANDROID_ROOT%\assets\Icon-32.png %APP_ANDROID_ROOT%\res\drawable-ldpi\icon.png
)

echo Start Compile...
%NDK_ROOT%\ndk-build.cmd -C "%APP_ANDROID_ROOT%"