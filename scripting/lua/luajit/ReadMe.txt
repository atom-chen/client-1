Juchao@20140423:
一 编译ios注意点：
1. luagit所在目录（包括所有上级目录），目录名不能出现中文字符，否则build_ios.sh会报错找不到对应目录。
   如client (trunk)要改成client-trunk
2. 打开build_ios.sh，需要根据你当前的SDK版本做相应改动
3. 生成的库放在ios目录下，包括三个CPU架构的库以及一个用这三个库打包而成的通用的库。所有使用这个通用的库会
   产生额外的磁盘占用


二 编译android注意点：
1. 需要下载android的工具链:NDK
2. 配置系统环境变量:按以下格式编辑.bash_profile文件
export NDK_ROOT="/Users/huangjuchao/Documents/Soft/adt-bundle-mac-x86_64-20131030/android-ndk-r9c"  
export PATH=$PATH:$NDK_ROOT 
export SDK_ROOT="/Users/huangjuchao/Documents/Soft/adt-bundle-mac-x86_64-20131030/sdk" 
export PATH=$PATH:$SDK_ROOT
3. 编译时可能会使用到类似以下的工具链：
/Users/huangjuchao/Documents/Soft/adt-bundle-mac-x86_64-20131030/android-ndk-r9c/toolchains/arm-linux-androideabi-4.6/prebuilt/darwin-x86_64, 如果没有darwin-86_64目录，可以将prebuilt/下得darwin-86拷贝一份命名为darwin-86_64
