#include "platform/SFGameHelper.h"
#include "platform/CCFileUtils.h"
#include "platform/android/jni/JniHelper.h"
#include "platform/CCCommon.h"
#include <sys/stat.h>
#include <sys/types.h>
#include "utils/Singleton.h"
#include "CCDirector.h"
#include "cocoa/CCObject.h"
#include "include/package/SFPackageManager.h"
#include "utils/SFExecutionThreadService.h"
#include "script_support/CCScriptSupport.h"
#include <vector>
#include <errno.h>
#include "SFLoginManager.h"

using namespace cocos2d;

#define kHelperClassName "com/morningglory/shell/GardeniaHelper"

int SFGameHelper::m_callBackHandler = 0;

// 开线程拷贝资源
class CopyThreadJob : public SFExecutionThreadService
{
public:
	CopyThreadJob():m_nHandler(0){

	}

	void copy(const char* resPath, const char* destPath, int handler){
		m_nHandler = handler;
		if (resPath && destPath && CCFileUtils::sharedFileUtils()->isFileExist(resPath))
		{
			m_strSrc = resPath;
			m_strDest = destPath;
			m_nHandler = handler;

			startUp();
		}
		else
		{
			// 通知拷贝失败
			notifyAndDelete(0);
		}
	}

	virtual bool doRun(){
		int ret = 0;
		if (CCFileUtils::sharedFileUtils()->isFileExist(m_strSrc))
		{
			unsigned long size = 0;
			unsigned char* pBytes = CCFileUtils::sharedFileUtils()->getFileData(m_strSrc.c_str()/*resPath*/, "rb", &size); //modify by yejunhua

			FILE *fp = fopen(m_strDest.c_str()/*destPath*/,"w+");
			if (fp)
			{
				size_t write = fwrite(pBytes, sizeof(char),size,fp);
				fflush(fp);
				fclose(fp);
			}

			delete []pBytes;

			ret = 1;
		}
		
		notifyAndDelete(ret);
		shutDown();
		return true;
	}

private:
	void notifyAndDelete(int ret){
		// 通知拷贝完成
		if (m_nHandler != 0){
			CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
			engine->executeControlEvent(m_nHandler, ret);
		}

		delete this;
	}

	virtual ~CopyThreadJob(){}

	std::string m_strSrc;
	std::string m_strDest;
	int m_nHandler;
};

std::string SFGameHelper::getExtStoragePath()
{
	// 把SFKeyPadDelegate的实例创建出来，来监听返回的按键消息
	static std::string strPath;

	if (strPath.length() <= 0)
	{
	//	SFKeyPadDelegate::getInstance().init();

		JniMethodInfo method;
		if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "getExtStoragePath", "()Ljava/lang/String;"))
		{
			jstring jstrRet = (jstring)method.env->CallStaticObjectMethod(method.classID, method.methodID, NULL);
			const char* strRet = method.env->GetStringUTFChars(jstrRet, 0);
			if (strRet)
				strPath = strRet;

			method.env->ReleaseStringUTFChars(jstrRet, strRet);
			method.env->DeleteLocalRef(jstrRet);
			method.env->DeleteLocalRef(method.classID);
		}
	}

	return strPath;
}

bool SFGameHelper::isDirExist(const char* path)
{
	if (path)
	{
		return 0 == access(path, 0);
	}
	
	return false;
}

bool SFGameHelper::createDir(const char* path)
{
	bool bRet = true;

	std::string tmp = path;
	int size = tmp.size();
	if (tmp[size-1] != '\\' && tmp[size-1] != '/')
	{
		tmp += "/";
	}

	size = tmp.size();
	for (int i = 0; i < size; ++i)
	{
		if (tmp[i] == '\\' || tmp[i] == '/')
		{
			if (0 != i)
			{
				tmp[i] = '\0';

				if (0 != access(tmp.c_str(), 0))
				{
					if (0 != mkdir(tmp.c_str(), 0755))
					{
						bRet = false;
						break;
					}
				}
			}

			tmp[i] = '/';
		}
	}

	return bRet;
}

void SFGameHelper::copyResouce( const char* resPath, const char* destPath, int handler )
{
	if (resPath && destPath)
	{
		std::string strResPath = resPath;

		if (CCFileUtils::sharedFileUtils()->isFileExist(strResPath))
		{
			// 检查destPath是否带文件名
			std::string strDestPath = destPath;
			int pos = strDestPath.find('.');
			if (pos != -1)
			{
				strDestPath = strDestPath.substr(0, strDestPath.find_last_of("/"));
			}

			SFGameHelper::createDir(strDestPath.c_str());

			// CopyThreadJob会自己释放自己, 不需要担心内存泄露
			CopyThreadJob* threadJob = new CopyThreadJob();
			threadJob->copy(resPath, destPath, handler);
		}
		else if (handler != 0){
			// 通知拷贝完成
			CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
			engine->executeControlEvent(handler, 0);
		}
	}
}

std::string SFGameHelper::getClientVersion()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "getVersion", "()Ljava/lang/String;"))
	{
		jstring jstrRet = (jstring)method.env->CallStaticObjectMethod(method.classID, method.methodID, NULL);
		const char* strRet = method.env->GetStringUTFChars(jstrRet, 0);
		if (strRet)
			ret = strRet;

		method.env->ReleaseStringUTFChars(jstrRet, strRet);
		method.env->DeleteLocalRef(jstrRet);
		method.env->DeleteLocalRef(method.classID);
	}

	return ret;
}

void SFGameHelper::updateClient(const char* pszUrl, const char* pszNewVersion, bool bForce)
{
	if (!pszUrl || !pszNewVersion)
		return;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "updateClient", "(Ljava/lang/String;Ljava/lang/String;Z)V"))
	{
		jstring jUrl = method.env->NewStringUTF(pszUrl);
		jstring jVersion = method.env->NewStringUTF(pszNewVersion);
		method.env->CallStaticVoidMethod(method.classID, method.methodID, jUrl, jVersion, bForce);
		method.env->DeleteLocalRef(jUrl);
		method.env->DeleteLocalRef(jVersion);
		method.env->DeleteLocalRef(method.classID);
	}
}

int SFGameHelper::getSubVersion()
{
	return 0;
	//return SFPackageManager::Instance()->getSubVersion();
}

int SFGameHelper::getMainVersion()
{
	return 0;
	//return SFPackageManager::Instance()->getMainVersion();
}

int SFGameHelper::getCurrentNetWork()
{
	int ret = 1;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "getCurNetWork", "()I"))
	{
		ret = (int)method.env->CallStaticObjectMethod(method.classID, method.methodID);
		method.env->DeleteLocalRef(method.classID);
	}

	return ret;
}

void SFGameHelper::moveFile(const char* resPath, const char* destPath,int handler)
{
 	int ret = rename(resPath, destPath);
	if (ret == -1)
 	{
 		CCLog("moveFile fail,  errno = %d", errno);
 	}
  	CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
  	engine->executeControlEvent(handler, 0);
}

void SFGameHelper::deleteFile(const char* resPath,int handler)
{
 	int ret = remove(resPath);
 	if (ret == -1)
	{
 		CCLog("deleteFile fail,  errno = %d", errno);
 	}
	CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
	engine->executeControlEvent(handler, 0);
}


void  SFGameHelper::setTag(cocos2d::CCArray* tags)  //设置推送组
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "setTags", "(Ljava/lang/String;)V"))
	{
		int len = tags->count();
		std::string tagStr = "";
		for (int i=0; i<len; i++)
		{
			cocos2d::CCString *tag = (cocos2d::CCString *)tags->objectAtIndex(i);
			CCLog("tag = %s", tag->getCString());
			tagStr += tag->getCString();
			tagStr += ",";
		}
		CCLog("setTag, tag = %s", tagStr.c_str());
		jstring str = method.env->NewStringUTF(tagStr.c_str());
		method.env->CallStaticVoidMethod(method.classID, method.methodID, str);
		method.env->DeleteLocalRef(method.classID);
	}
}

void SFGameHelper::removeTag(const char* tag)
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "removeTag", "(Ljava/lang/String;)V"))
	{
		jstring tagStr = method.env->NewStringUTF(tag);
		method.env->CallStaticVoidMethod(method.classID, method.methodID, tagStr);
		method.env->DeleteLocalRef(tagStr);
		method.env->DeleteLocalRef(method.classID);
	}
}

void SFGameHelper::startPush()
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "startPush", "()V"))
	{
		method.env->CallStaticVoidMethod(method.classID, method.methodID);
		method.env->DeleteLocalRef(method.classID);
	}
}

void SFGameHelper::stopPush()
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "stopPush", "()V"))
	{
		method.env->CallStaticVoidMethod(method.classID, method.methodID);
		method.env->DeleteLocalRef(method.classID);
	}
}

void SFGameHelper::showMenu(const char* title, const char* content, const char* linkUrl, const char* imgUrl, int handler)
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "showMenu", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"))
	{
		jstring jTitle = method.env->NewStringUTF(title);
		jstring jContent = method.env->NewStringUTF(content);
		jstring jLinkUrl = method.env->NewStringUTF(linkUrl);
		jstring jImgUrl = method.env->NewStringUTF(imgUrl);
		method.env->CallStaticVoidMethod(method.classID, method.methodID, jTitle, jContent, jLinkUrl, jImgUrl, (jint)handler);
		method.env->DeleteLocalRef(jTitle);
		method.env->DeleteLocalRef(jContent);
		method.env->DeleteLocalRef(jLinkUrl);
		method.env->DeleteLocalRef(jImgUrl);
		method.env->DeleteLocalRef(method.classID);
	}
}

void SFGameHelper::share(const char* platform, bool bEdit,const char* title, const char* content, const char* linkUrl, const char* imgUrl, int handler)
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "share", "(Ljava/lang/String;Z;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"))
	{
		jstring jPlatform = method.env->NewStringUTF(platform);
		jboolean jEdit = (jboolean)bEdit;
		jstring jTitle = method.env->NewStringUTF(title);
		jstring jContent = method.env->NewStringUTF(content);
		jstring jLinkUrl = method.env->NewStringUTF(linkUrl);
		jstring jImgUrl = method.env->NewStringUTF(imgUrl);
		method.env->CallStaticVoidMethod(method.classID, method.methodID, jPlatform, jEdit, jTitle, jContent, jLinkUrl, jImgUrl, (jint)handler);
		method.env->DeleteLocalRef(jPlatform);
		method.env->DeleteLocalRef(jTitle);
		method.env->DeleteLocalRef(jContent);
		method.env->DeleteLocalRef(jLinkUrl);
		method.env->DeleteLocalRef(jImgUrl);
		method.env->DeleteLocalRef(method.classID);
	}
}

//ok
void SFGameHelper::setSessionTimeout(int timeout)
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "setSessionTimeout", "(I)V"))
	{
		method.env->CallStaticVoidMethod(method.classID, method.methodID, (jint)timeout);
		method.env->DeleteLocalRef(method.classID);
	}
}

void SFGameHelper::enableExceptionLog()
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "enableExceptionLog", "()V"))
	{
		method.env->CallStaticVoidMethod(method.classID, method.methodID);
		method.env->DeleteLocalRef(method.classID);
	}
}

void SFGameHelper::startStatistics(const char* reportId,const char* channelId)
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "startStatistics", "(Ljava/lang/String;Ljava/lang/String;)V"))
	{
		jstring jReportId = method.env->NewStringUTF(reportId);
		jstring jChannelId = method.env->NewStringUTF(channelId);
		method.env->CallStaticVoidMethod(method.classID, method.methodID, jReportId, jChannelId);
		method.env->DeleteLocalRef(jReportId);
		method.env->DeleteLocalRef(jChannelId);
		method.env->DeleteLocalRef(method.classID);
	}
}

void SFGameHelper::executeShareCallback(int handler, int state)
{
	if (handler != 0)
	{
		cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeLoginCB(handler, "share", strlen("share"), state);
	}
}

void SFGameHelper::copy2PasteBoard(const char* str)
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "copy2PasteBoard", "(Ljava/lang/String;)V"))
	{
		jstring jStr = method.env->NewStringUTF(str);
		method.env->CallStaticVoidMethod(method.classID, method.methodID, jStr);
		method.env->DeleteLocalRef(jStr);
		method.env->DeleteLocalRef(method.classID);
	}
}


float SFGameHelper::getDensity()
{
	float ret;
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "getDensity", "()F"))
	{
		//ret = (jfloat)method.env->CallStaticObjectMethod(method.classID, method.methodID);
		ret = (jfloat)method.env->CallStaticFloatMethod(method.classID, method.methodID);
		method.env->DeleteLocalRef(method.classID);
	}

	return ret;
}

int SFGameHelper::getDensityDpi()
{
	int ret = 0;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "getDensityDpi", "()I"))
	{
		ret = (int)method.env->CallStaticObjectMethod(method.classID, method.methodID);
		method.env->DeleteLocalRef(method.classID);
	}

	return ret;
}

std::string SFGameHelper::getManuFactuer()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "getManuFactuer", "()Ljava/lang/String;"))
	{
		jstring jstrKey = (jstring)method.env->CallStaticObjectMethod(method.classID, method.methodID);
		const char* strKey = method.env->GetStringUTFChars(jstrKey, 0);
		if (strKey)
		{
			ret = strKey;
			method.env->ReleaseStringUTFChars(jstrKey, strKey);
		}

		method.env->DeleteLocalRef(jstrKey);
		method.env->DeleteLocalRef(method.classID);
	}
	return ret;
}

std::string SFGameHelper::getModel()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "getModel", "()Ljava/lang/String;"))
	{
		jstring jstrKey = (jstring)method.env->CallStaticObjectMethod(method.classID, method.methodID);
		const char* strKey = method.env->GetStringUTFChars(jstrKey, 0);
		if (strKey)
		{
			ret = strKey;
			method.env->ReleaseStringUTFChars(jstrKey, strKey);
		}

		method.env->DeleteLocalRef(jstrKey);
		method.env->DeleteLocalRef(method.classID);
	}
	return ret;
}

std::string SFGameHelper::getSystemVer()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "getSystemVer", "()Ljava/lang/String;"))
	{
		jstring jstrKey = (jstring)method.env->CallStaticObjectMethod(method.classID, method.methodID);
		const char* strKey = method.env->GetStringUTFChars(jstrKey, 0);
		if (strKey)
		{
			ret = strKey;
			method.env->ReleaseStringUTFChars(jstrKey, strKey);
		}

		method.env->DeleteLocalRef(jstrKey);
		method.env->DeleteLocalRef(method.classID);
	}
	return ret;
}

void SFGameHelper::setAppUpdateType(int type, int tag)
{
	cocos2d::CCLog("setAppUpdateType type = %d, tag = %d", type ,tag);
	if (m_callBackHandler != 0)
	{
		cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
		switch (type)
		{
		case 1:
			engine->executeLoginCB(m_callBackHandler, "appStatistics", strlen("appStatistics"), tag);
			break;
		case 2:
			engine->executeLoginCB(m_callBackHandler, "appDownloadState", strlen("appDownloadState"),tag);
			break;
		default:
			break;
		}
	}
}

void SFGameHelper::setAppCallback(int handler)
{
	m_callBackHandler = handler;
}

std::string SFGameHelper::urlEncode(const char* str)
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "urlEncode", "(Ljava/lang/String;)Ljava/lang/String;"))
	{
		jstring jUrl = method.env->NewStringUTF(str);
		jstring jstrKey = (jstring)method.env->CallStaticObjectMethod(method.classID, method.methodID, jUrl);
		const char* strKey = method.env->GetStringUTFChars(jstrKey, 0);
		if (strKey)
		{
			ret = strKey;
			method.env->ReleaseStringUTFChars(jstrKey, strKey);
		}
		method.env->DeleteLocalRef(jUrl);
		method.env->DeleteLocalRef(jstrKey);
		method.env->DeleteLocalRef(method.classID);
	}
	return ret;
}

std::string SFGameHelper::urlDecode(const char* str)
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "urlDecode", "(Ljava/lang/String;)Ljava/lang/String;"))
	{
		jstring jUrl = method.env->NewStringUTF(str);
		jstring jstrKey = (jstring)method.env->CallStaticObjectMethod(method.classID, method.methodID, jUrl);
		const char* strKey = method.env->GetStringUTFChars(jstrKey, 0);
		if (strKey)
		{
			ret = strKey;
			method.env->ReleaseStringUTFChars(jstrKey, strKey);
		}
		method.env->DeleteLocalRef(jUrl);
		method.env->DeleteLocalRef(jstrKey);
		method.env->DeleteLocalRef(method.classID);
	}
	return ret;
}

void SFGameHelper::setFloatBtnVisible(bool bVisible)
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "setFloatBtnVisible", "(Z;)V"))
	{
		jboolean jVisible = (jboolean)bVisible;
		method.env->CallStaticObjectMethod(method.classID, method.methodID, jVisible);
		method.env->DeleteLocalRef(method.classID);
	}
}

SFLoginSchedule* SFLoginSchedule::_instance=NULL;
SFLoginSchedule::SFLoginSchedule()
{

}

SFLoginSchedule::~SFLoginSchedule()
{

}

SFLoginSchedule* SFLoginSchedule::getInstance()
{
	if (_instance == NULL)
	{

		_instance = new SFLoginSchedule();
	}
	return _instance;
}

void SFLoginSchedule::runInSchedule(int type)
{
	if (type == 1 )
	{
		CCDirector::sharedDirector()->getScheduler()->scheduleSelector(schedule_selector(SFLoginSchedule::gotoBridgeAuth), SFLoginSchedule::getInstance(), 0.0, 0, 0.0, false);
	}
}

void SFLoginSchedule::gotoBridgeAuth()
{
	CCLog("****Andoid Login loginSuccess, go to bridge auth now****");
	SFLoginManager::getInstance()->gotoBridgeAuth();
}


long long SFGameHelper::getRomFreeSpace()
{
	long long ret = 0;
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "getRomFreeSpace", "()J"))
	{
		ret = method.env->CallStaticLongMethod(method.classID, method.methodID);
		method.env->DeleteLocalRef(method.classID);
	}
	return ret;
}
long long SFGameHelper::getRamSpace()
{
	long long ret = 0;
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "getRamSpace", "()J"))
	{
		ret = method.env->CallStaticLongMethod(method.classID, method.methodID);
		method.env->DeleteLocalRef(method.classID);
	}
	return ret;
}

std::string SFGameHelper::base64Encode(const char* str)
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "base64Encode", "(Ljava/lang/String;)Ljava/lang/String;"))
	{
		jstring jUrl = method.env->NewStringUTF(str);
		jstring jstrKey = (jstring)method.env->CallStaticObjectMethod(method.classID, method.methodID, jUrl);
		const char* strKey = method.env->GetStringUTFChars(jstrKey, 0);
		if (strKey)
		{
			ret = strKey;
			method.env->ReleaseStringUTFChars(jstrKey, strKey);
		}
		method.env->DeleteLocalRef(jUrl);
		method.env->DeleteLocalRef(jstrKey);
		method.env->DeleteLocalRef(method.classID);
	}
	return ret;
}

std::string SFGameHelper::base64Decode(const char* str)
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, kHelperClassName, "base64Decode", "(Ljava/lang/String;)Ljava/lang/String;"))
	{
		jstring jUrl = method.env->NewStringUTF(str);
		jstring jstrKey = (jstring)method.env->CallStaticObjectMethod(method.classID, method.methodID, jUrl);
		const char* strKey = method.env->GetStringUTFChars(jstrKey, 0);
		if (strKey)
		{
			ret = strKey;
			method.env->ReleaseStringUTFChars(jstrKey, strKey);
		}
		method.env->DeleteLocalRef(jUrl);
		method.env->DeleteLocalRef(jstrKey);
		method.env->DeleteLocalRef(method.classID);
	}
	return ret;
}