@echo off
set APP_ANDROID_ROOT=E:\Sophia\client\branch\0.4.6\gamelogic
set COCOS2DX_ROOT=E:\Sophia\client\branch\0.4.6\
set APP_ROOT=E:\Sophia\client\branch\0.4.6\mf.game
set NDK_MODULE_PATH=%COCOS2DX_ROOT%;%COCOS2DX_ROOT%\cocos2dx\platform\third_party\android\prebuilt
set NDK_ROOT=D:\android-ndk-r9\

echo Start Compile...
%NDK_ROOT%\ndk-build.cmd -j4 -C "%APP_ANDROID_ROOT%"