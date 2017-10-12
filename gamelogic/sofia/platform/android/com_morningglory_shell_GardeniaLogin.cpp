#include "platform/android/jni/JniHelper.h"
#include "platform/CCCommon.h"
//#include "Object/Config/GameConfigMgr.h"
//#include "Util/LoadingMrg.h"
#include "SFLoginManager.h"
#include "SFGameHelper.h"
#include "android/com_morningglory_shell_GardeniaLogin.h"

using namespace cocos2d;

#define LoginClassName "com/morningglory/shell/GardeniaLogin"
#define PayClassName "com/morningglory/shell/GardeniaPay"

//登陆成功， 去桥接认证
JNIEXPORT void JNICALL Java_com_morningglory_shell_GardeniaLogin_native_1loginSuccess
	(JNIEnv *env, jclass)
{
	SFLoginSchedule::getInstance()->runInSchedule(1);
}

void jni_getSrvListSuccess(const char* str)
{
	if (!str)
		return;

	CCLog("****Android JNI Call getSrvListSuccess****");

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "getSrvListSuccess", "(Ljava/lang/String;)V"))
	{
		jstring jstr = method.env->NewStringUTF(str);
		method.env->CallStaticVoidMethod(method.classID, method.methodID, jstr);
		method.env->DeleteLocalRef(jstr);
		method.env->DeleteLocalRef(method.classID);
	}
}

void jni_bridgeAuthSuccess(const char* response)
{
	if (!response)
		return;

	CCLog("notify sdk bridge auth success");

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "bridgeAuthSuccess", "(Ljava/lang/String;)V"))
	{
		jstring jstr = method.env->NewStringUTF(response);
		method.env->CallStaticVoidMethod(method.classID, method.methodID, jstr);
		method.env->DeleteLocalRef(jstr);
		method.env->DeleteLocalRef(method.classID);
	}
}

std::string jni_getLoginSettingUrl()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "getLoginSettingUrl", "()Ljava/lang/String;"))
	{
		jstring jstrUrl = (jstring)method.env->CallStaticObjectMethod(method.classID, method.methodID);
		const char* strUrl = method.env->GetStringUTFChars(jstrUrl, 0);
		if (strUrl)
		{
			ret = strUrl;
			method.env->ReleaseStringUTFChars(jstrUrl, strUrl);
		}

		method.env->DeleteLocalRef(jstrUrl);
		method.env->DeleteLocalRef(method.classID);
	}

	return ret;
}

std::string jni_getBackupSettingUrl()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "getBackupLoginSettingUrl", "()Ljava/lang/String;"))
	{
		jstring jstrUrl = (jstring)method.env->CallStaticObjectMethod(method.classID, method.methodID);
		const char* strUrl = method.env->GetStringUTFChars(jstrUrl, 0);
		if (strUrl)
		{
			ret = strUrl;
			method.env->ReleaseStringUTFChars(jstrUrl, strUrl);
		}

		method.env->DeleteLocalRef(jstrUrl);
		method.env->DeleteLocalRef(method.classID);
	}

	return ret;
}

std::string jni_getBridgeUrl()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "getBridgeUrl", "()Ljava/lang/String;"))
	{
		jstring jstrUrl = (jstring)method.env->CallStaticObjectMethod(method.classID, method.methodID);
		const char* strUrl = method.env->GetStringUTFChars(jstrUrl, 0);
		if (strUrl)
		{
			ret = strUrl;
			method.env->ReleaseStringUTFChars(jstrUrl, strUrl);
		}

		method.env->DeleteLocalRef(jstrUrl);
		method.env->DeleteLocalRef(method.classID);
	}
	CCLog("****android jni getBridUrl = %s", ret.c_str());
	return ret;
}

std::string jni_getQDKey()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "getQDKey", "()Ljava/lang/String;"))
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

std::string jni_getGameKey()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "getGameKey", "()Ljava/lang/String;"))
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

std::string jni_getUUid()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "getUUid", "()Ljava/lang/String;"))
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

std::string jni_getSuffix()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "getSuffix", "()Ljava/lang/String;"))
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

int jni_getQDCode1()
{
	int ret = 0;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "getQDCode1", "()I"))
	{
		ret = (int)method.env->CallStaticObjectMethod(method.classID, method.methodID);
		method.env->DeleteLocalRef(method.classID);
	}

	return ret;
}

int jni_getQDCode2()
{
	int ret = 0;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "getQDCode2", "()I"))
	{
		ret = (int)method.env->CallStaticObjectMethod(method.classID, method.methodID);
		method.env->DeleteLocalRef(method.classID);
	}

	return ret;
}


JNIEXPORT void JNICALL Java_com_morningglory_shell_GardeniaLogin_native_1getServerList( JNIEnv *, jclass )
{
	SFLoginManager::getInstance()->requestServerList();
}

bool jni_isAccountManager()
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "isAccountManger", "()Z"))
	{
		bool bRet = method.env->CallStaticBooleanMethod(method.classID, method.methodID, NULL);
		method.env->DeleteLocalRef(method.classID);
		return bRet;
	}
	else
	{
		CCLog("Can not Find isAccountManger");
		return false;
	}
}

void jni_showAccountManager()
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "showAccountManger", "()V"))
	{
		method.env->CallStaticVoidMethod(method.classID, method.methodID, NULL);
		method.env->DeleteLocalRef(method.classID);
	}
	else
	{
		CCLog("Can not Find showAccountManger");
	}
}

void jni_submitExtendData(const char* extendData)
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "submitExtendData", "(Ljava/lang/String;)V"))
	{
		jstring data = method.env->NewStringUTF(extendData);
		method.env->CallStaticVoidMethod(method.classID, method.methodID, data);
		method.env->DeleteLocalRef(data);
		method.env->DeleteLocalRef(method.classID);
	}
}

void jni_selectServerId( int serverId )
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "selectServer", "(I)V"))
	{
		method.env->CallStaticVoidMethod(method.classID, method.methodID, (jint)serverId);
		method.env->DeleteLocalRef(method.classID);
	}
	else
	{
		CCLog("Can not Find selectServer");
	}
}

std::string jni_getPlatform()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "getPlatform", "()Ljava/lang/String;"))
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

std::string jni_getAuthData()
{
	std::string ret;

	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "getAuthData", "()Ljava/lang/String;"))
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

void jni_openPay(char* rechargeChannelJson, int handler)
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, PayClassName, "pay", "(Ljava/lang/String;I)V"))
	{
		jstring channel = method.env->NewStringUTF(rechargeChannelJson);
		method.env->CallStaticVoidMethod(method.classID, method.methodID, channel, (jint)handler);
		method.env->DeleteLocalRef(channel);
		method.env->DeleteLocalRef(method.classID);
	}
}

bool jni_needShowUserCenter()
{
	bool bRet = false;
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "needShowUserCenter", "()Z"))
	{
		bRet = method.env->CallStaticBooleanMethod(method.classID, method.methodID, NULL);
		method.env->DeleteLocalRef(method.classID);
	}
	return bRet;
}

void jni_showUserCenter()
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "showUserCenter", "()V"))
	{
		method.env->CallStaticVoidMethod(method.classID, method.methodID);
		method.env->DeleteLocalRef(method.classID);
	}
}

void jni_logout()
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "logout", "()V"))
	{
		method.env->CallStaticVoidMethod(method.classID, method.methodID);
		method.env->DeleteLocalRef(method.classID);
	}
}

bool jni_needShowCustomTopupView()
{
	bool bRet = false;
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "needShowCustomTopupView", "()Z"))
	{
		bRet = method.env->CallStaticBooleanMethod(method.classID, method.methodID, NULL);
		method.env->DeleteLocalRef(method.classID);
	}
	return bRet;
}

JNIEXPORT jint JNICALL Java_com_morningglory_shell_GardeniaLogin_native_1getSelectServer( JNIEnv *, jclass )
{
	//return getLoginManager->getSelectServer();
}

JNIEXPORT void JNICALL Java_com_morningglory_shell_GardeniaLogin_native_1cancelUpdate( JNIEnv *, jclass )
{
	// 连接游戏服
	//getLoginManager->requestBridgeAuth(getLoginManager->getSelectServer(), false);
}

JNIEXPORT void JNICALL Java_com_morningglory_shell_GardeniaLogin_native_1excuteLogOutCallBack(JNIEnv *evn, jclass)
{
	SFLoginManager::getInstance()->excuteLogOutCallBack();
}

void jni_loginError( int errCode )
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, LoginClassName, "loginError", "(I)V"))
	{
		method.env->CallStaticVoidMethod(method.classID, method.methodID, (jint)errCode);
		method.env->DeleteLocalRef(method.classID);
	}
	else
	{
		CCLog("Can not Find selectServer");
	}
}

JNIEXPORT void JNICALL Java_com_morningglory_shell_GardeniaLogin_native_1onPayState
	(JNIEnv *, jclass,jint handler, jint state)
{
	SFLoginManager::getInstance()->executePayCallback((int)handler,(int)state);
}

JNIEXPORT void JNICALL Java_com_morningglory_shell_GardeniaHelper_native_1baiduShareCallback
	(JNIEnv *, jclass, jint handler, jint state)
{
	SFGameHelper::executeShareCallback((int)handler,(int)state);
}

JNIEXPORT void JNICALL Java_com_morningglory_shell_GardeniaHelper_native_1appUpdateType
	(JNIEnv *, jclass, jint type, jint tag)
{
	SFGameHelper::setAppUpdateType((int)type, (int)tag);
}

JNIEXPORT void JNICALL Java_com_morningglory_shell_GardeniaLogin_native_1showWaitView( JNIEnv *, jclass, jint waitTimeSec )
{
	SFLoginManager::getInstance()->showWaitView(waitTimeSec);
}

JNIEXPORT void JNICALL Java_com_morningglory_shell_GardeniaLogin_native_1hideWaitView( JNIEnv *, jclass )
{
	SFLoginManager::getInstance()->hideWaitView();
}

JNIEXPORT jstring JNICALL Java_com_morningglory_shell_GardeniaLogin_native_1getCurrentPlayerInfo(JNIEnv *, jclass)
{
	
}

JNIEXPORT void JNICALL Java_com_morningglory_shell_GardeniaLogin_native_1disConnectGameServer(JNIEnv *, jclass)
{
	
}

JNIEXPORT void JNICALL Java_com_morningglory_shell_GardeniaLogin_native_1sdkLogout(JNIEnv *, jclass, jboolean bNeedShowLogin)
{
	SFLoginManager::getInstance()->excuteLogOutCallBack((bool)bNeedShowLogin);
}