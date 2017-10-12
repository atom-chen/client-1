/********************************************************************
	created:	2013/05/15
	created:	15:5:2013   10:01
	filename: 	E:\jiuxian\client_sulation\trunk\mf.game\Classes\platform\SFGameHelper.h
	file path:	E:\jiuxian\client_sulation\trunk\mf.game\Classes\platform
	file base:	SFGameHelper
	file ext:	h
	author:		Liu Rui
	
	purpose:	平台相关的辅助类
*********************************************************************/

#ifndef _SFGAMEHELPER_H__h__
#define _SFGAMEHELPER_H__h__
//#include "../../trunk/cocos2dx/include/cocos2d.h"
#include "cocos2d.h"
#include <string>

enum NetType {
    kNotNetwork = 1,
    kWifi,
    kNotWifi,
    };

class BaiduResultHandler
{
public:
	virtual void onEvent(int eventType, int code, const char* param){};
};

class BaiduPushResultHandler: public BaiduResultHandler
{
public:
	virtual void onEvent(int eventType, int code, const char* param);
private:
	void handleBindEvent(int code, const char* param);
	void handleTagEvnet(int code, const char* param);
	void handleNotificationClicked(int code, const char* param);
};

class BaiduShareResultHandler: public BaiduResultHandler
{
public:
	virtual void onEvent(int eventType, int code, const char* param);
private:
	void handleShareEvent(int code, const char* param);
};



class SFGameHelper
{
public:
	// 获取存储打包资源和用户配置的路径
	static std::string getExtStoragePath();
	static bool isDirExist(const char* path);
	static bool createDir(const char* path);
	static void copyResouce(const char* resPath, const char* destPath,int handler);
	static std::string getClientVersion();
	static int getMainVersion();
	static int getSubVersion();
	static void updateClient(const char* pszUrl, const char* pszNewVersion, bool bForce);
    static int getCurrentNetWork();
    static void moveFile(const char* resPath, const char* destPath,int handler);
    static void deleteFile(const char* resPath,int handler);
    // 更新客户端

	//推送
	static void setPushResultHandler(BaiduResultHandler handler);
	static void setShareResultHandler(BaiduResultHandler handler);
	static void setTag(cocos2d::CCArray* tags);   //设置推送组
	static void removeTag(const char* tag);				//删除推送组
	static void startPush();							//启动推送
	static void stopPush();								//停止推送
	// 分享
	static void showMenu(const char* title, const char* content, const char* linkUrl, const char* imgUrl, int handler);						//显示分享菜单
	static void share(const char* platform, bool bEdit,const char* title, const char* content, const char* linkUrl, const char* imgUrl, int handler);//分享到指定的平台
	static void executeShareCallback(int handler, int state); //取消state=0， 成功state=1, 失败state=2
	//统计
	static void setSessionTimeout(int timeout);    //应用停留在后台期间用户无操作的时长，必须在startStatistics()之前调用才会生效
    static void enableExceptionLog();  //开启抛出异常日志
	static void startStatistics(const char* reportId,const char* channelId); //开始统计
	//拷贝到粘贴板
    static void copy2PasteBoard(const char* str); //将字符串复制到系统粘贴板
	//后台统计相关
	static float getDensity();//获取屏幕像素密度 （0.75 / 1.0 / 1.5）
	static int getDensityDpi();//获取屏幕像素密度dpi（120 / 160 / 240）
	static std::string getManuFactuer(); //获取厂商信息
	static std::string getModel();//获取手机型号
	static std::string getSystemVer();//获取系统版本号
	static void setAppUpdateType(int type, int tag);//type = 1 表示app自动更新还是手动更新, tag=1自动， tag=2手动
													//type = 2表示统计app下载状态  tag=1开始 tag=2结束  tag=3异常
	static void setAppCallback(int handler); //将更新的类型通知lua向后台发送http请求

	//编解码
	static std::string urlEncode(const char* str);
	static std::string urlDecode(const char* str);
	static std::string base64Encode(const char* str);
	static std::string base64Decode(const char* str);

	static void setFloatBtnVisible(bool bVisible);
    static long long getRomFreeSpace();
	static long long getRamSpace();
    
private:
	static int m_callBackHandler;
};


class SFLoginSchedule:public cocos2d::CCObject
{
public:
	~SFLoginSchedule();
	static SFLoginSchedule* getInstance();
	void runInSchedule(int type);
	void gotoBridgeAuth();
private :
	SFLoginSchedule();
	int scheduleId;
	static SFLoginSchedule * _instance;
};

#endif // _SFGAMEHELPER_H__h__
