#include "SFGameHelper.h"
#include "platform/CCFileUtils.h"
#include "include/utils/SFStringUtil.h"
#include "include/package/SFPackageManager.h"
#include "script_support/CCScriptSupport.h"
//#include "../../scripting/lua/cocos2dx_support/SFScriptManager.h"
#include <Shlobj.h>
static char s_pszResourcePath[MAX_PATH] = {0};

static void _checkPath()
{
	if (! s_pszResourcePath[0])
	{
		WCHAR  wszPath[MAX_PATH] = {0};
		int nNum = WideCharToMultiByte(CP_ACP, 0, wszPath,
			GetCurrentDirectoryW(sizeof(wszPath), wszPath),
			s_pszResourcePath, MAX_PATH, NULL, NULL);
		s_pszResourcePath[nNum] = '\\';
	}
}

std::string SFGameHelper::getExtStoragePath()
{
	//_checkPath();
	//std::string ret = s_pszResourcePath;
	//return ret + "data";
	return CCFileUtils::sharedFileUtils()->getWritablePath();
}

bool SFGameHelper::isDirExist(const char* path)
{
	return false;
}

bool SFGameHelper::createDir(const char* path)
{
	if (path)
		return CreateDirectoryA(path, NULL);
	
	return false;
}

void SFGameHelper::copyResouce( const char* resPath, const char* destPath,int handler )
{
	// windows不执行资源拷贝
	if (handler > 0)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->executeControlEvent(handler, 0);
	}
}

std::string SFGameHelper::getClientVersion()
{
	return "0.9.1";
}

void SFGameHelper::updateClient(const char* pszUrl, const char* pszNewVersion, bool bForce)
{

}

int SFGameHelper::getMainVersion()
{
	return 0;
	//return SFPackageManager::Instance()->getMainVersion();
}

int SFGameHelper::getSubVersion()
{
	return 0;
	//return SFPackageManager::Instance()->getSubVersion();
}

int SFGameHelper::getCurrentNetWork()
{
	return kWifi;
}

void SFGameHelper::moveFile(const char* resPath, const char* destPath,int handler)
{
	wchar_t restext[256];
	mbstowcs(restext, resPath, strlen(resPath)+1);
	LPWSTR res = restext;
	wchar_t destext[256];
	mbstowcs(destext, destPath, strlen(destPath)+1);
	LPWSTR des = destext;
	MoveFile(res,des);
	if (handler > 0)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->executeControlEvent(handler, 0);
	}
}
void SFGameHelper::deleteFile(const char* resPath,int handler)
{
	remove(resPath);
	if (handler > 0)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->executeControlEvent(handler, 0);
	}
}

void SFGameHelper::setPushResultHandler( BaiduResultHandler handler )
{

}

void SFGameHelper::setShareResultHandler( BaiduResultHandler handler )
{

}

void SFGameHelper::setTag( cocos2d::CCArray* tags )
{

}

void SFGameHelper::removeTag( const char* tag )
{

}

void SFGameHelper::startPush()
{

}

void SFGameHelper::stopPush()
{

}

void SFGameHelper::showMenu( const char* title, const char* content, const char* linkUrl, const char* imgUrl, int handler )
{

}

void SFGameHelper::share( const char* platform, bool bEdit,const char* title, const char* content, const char* linkUrl, const char* imgUrl, int handler )
{

}

void SFGameHelper::executeShareCallback(int handler, int state)
{

}

void SFGameHelper::setSessionTimeout( int timeout )
{

}

void SFGameHelper::enableExceptionLog()
{

}

void SFGameHelper::startStatistics( const char* reportId,const char* channelId )
{

}

void SFGameHelper::copy2PasteBoard(const char* str)
{
	CCLog("Not Implement");
}

float SFGameHelper::getDensity()
{
	return 0.0;
}

int SFGameHelper::getDensityDpi()
{
	return 0;
}

std::string SFGameHelper::getManuFactuer()
{
	return "microsoft";
}

std::string SFGameHelper::getModel()
{
	return "windows";
}

std::string SFGameHelper::getSystemVer()
{
	return "Win7";
}

void SFGameHelper::setAppUpdateType(int type, int tag)
{

}
void SFGameHelper::setAppCallback(int handler)
{

}

std::string SFGameHelper::urlEncode(const char* str)
{
	return str;
}
std::string SFGameHelper::urlDecode(const char* str)
{
	return str;
}

void SFGameHelper::setFloatBtnVisible(bool bVisible)
{

}

std::string SFGameHelper::base64Encode(const char* Data)
{
	const char EncodeTable[]="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	unsigned int in_len = std::string(Data).length();
	CCLog("lenggth c++ = %d", in_len);
	std::string ret;
	int i = 0;
	int j = 0;
	unsigned char char_array_3[3];
	unsigned char char_array_4[4];

	while (in_len--) {
		char_array_3[i++] = *(Data++);
		if (i == 3) {
			char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
			char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
			char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
			char_array_4[3] = char_array_3[2] & 0x3f;

			for(i = 0; (i <4) ; i++)
				ret += EncodeTable[char_array_4[i]];
			i = 0;
		}
	}

	if (i)
	{
		for(j = i; j < 3; j++)
			char_array_3[j] = '\0';

		char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
		char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
		char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
		char_array_4[3] = char_array_3[2] & 0x3f;

		for (j = 0; (j < i + 1); j++)
			ret += EncodeTable[char_array_4[j]];

		while((i++ < 3))
			ret += '=';

	}

	return ret;



//  	int DataByte = std::string(Data).length();
//  	CCLog("decode len = %d", DataByte);
//  	//编码表
//  	const char EncodeTable[]="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
//  	//返回值
//  	std::string strEncode;
//  	unsigned char Tmp[4]={0};
//  	//int LineLength=0;
//  	for(int i=0;i<(int)(DataByte / 3);i++)
//  	{
//  		Tmp[1] = *Data++;
//  		Tmp[2] = *Data++;
//  		Tmp[3] = *Data++;
//  		strEncode+= EncodeTable[Tmp[1] >> 2];
//  		strEncode+= EncodeTable[((Tmp[1] << 4) | (Tmp[2] >> 4)) & 0x3F];
//  		strEncode+= EncodeTable[((Tmp[2] << 2) | (Tmp[3] >> 6)) & 0x3F];
//  		strEncode+= EncodeTable[Tmp[3] & 0x3F];
//  		//if(LineLength+=4,LineLength==76) {strEncode+="\r\n";LineLength=0;}
//  	}
//  	//对剩余数据进行编码
//  	int Mod=DataByte % 3;
//  	if(Mod==1)
//  	{
//  		Tmp[1] = *Data++;
//  		strEncode+= EncodeTable[(Tmp[1] & 0xFC) >> 2];
//  		strEncode+= EncodeTable[((Tmp[1] & 0x03) << 4)];
//  		strEncode+= "==";
//  	}
//  	else if(Mod==2)
//  	{
//  		Tmp[1] = *Data++;
//  		Tmp[2] = *Data++;
//  		strEncode+= EncodeTable[(Tmp[1] & 0xFC) >> 2];
//  		strEncode+= EncodeTable[((Tmp[1] & 0x03) << 4) | ((Tmp[2] & 0xF0) >> 4)];
//  		strEncode+= EncodeTable[((Tmp[2] & 0x0F) << 2)];
//  		strEncode+= "=";
//  	}
//  
//  	return strEncode;
}
std::string SFGameHelper::base64Decode(const char* str)
{
	return str;
}

long long SFGameHelper::getRomFreeSpace()
{
	return 1024 * 1024 * 1024;
}

long long SFGameHelper::getRamSpace()
{
	return 1024 * 1024 * 1024;
}


/*windows 不需要实现SFLoginSchedule*/
SFLoginSchedule::SFLoginSchedule()
{

}

SFLoginSchedule::~SFLoginSchedule()
{

}

SFLoginSchedule* SFLoginSchedule::getInstance()
{
	return NULL;
}

void SFLoginSchedule::runInSchedule(int type)
{
	(void)type;
}

void SFLoginSchedule::gotoBridgeAuth()
{

}