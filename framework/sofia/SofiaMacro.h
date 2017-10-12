#ifndef SofiaMacro_h__
#define SofiaMacro_h__

#include "cocos2d.h"
#include "platform/CCPlatformConfig.h"

#define NS_SF_BEGIN namespace sf{
#define NS_SF_END	};
#define USING_NS_SF	using namespace sf

static char s_msgBuff[1024];

#define SFMsgBox(content, title)		cocos2d::CCMessageBox(content, title)
#define SFLog(format, ...)					CCLOG(format, ##__VA_ARGS__)

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#define SFAssert(condition, format, ...)	\
	if (!(condition))\
{\
	sprintf_s(s_msgBuff, sizeof(s_msgBuff), format, ##__VA_ARGS__); \
	SFMsgBox(s_msgBuff, "error");\
}
#else
#define SFAssert(condition, format, ...)
#endif

#define SF_SAFE_DELETE_ARRAY(p)			CC_SAFE_DELETE_ARRAY(p)
#define SF_SAFE_DELETE(p)							CC_SAFE_DELETE(p)
#define SF_SAFE_RELEASE(p)						CC_SAFE_RELEASE_NULL(p)
#define SF_SAFE_FREE(p)								CC_SAFE_FREE(p)
#define SF_BREAK_IF(cond)							CC_BREAK_IF(cond)


#define SF_CLEAR_CONTAINER(CONTAINER_TYPE, CONTAINER_INSTANCE)	\
{																\
	CONTAINER_TYPE::iterator itr = (CONTAINER_INSTANCE).begin();\
	while ( itr != (CONTAINER_INSTANCE).end() )					\
	{															\
		CC_SAFE_DELETE( (*itr) );								\
		itr++;													\
	}															\
	(CONTAINER_INSTANCE).clear();								\
}

#define SF_RELEASE_CONTAINER(CONTAINER_TYPE, CONTAINER_INSTANCE)	\
{																\
	CONTAINER_TYPE::iterator itr = (CONTAINER_INSTANCE).begin();\
	while ( itr != (CONTAINER_INSTANCE).end() )					\
	{															\
		CC_SAFE_RELEASE_NULL( (*itr) );								\
		itr++;													\
	}															\
	(CONTAINER_INSTANCE).clear();								\
}

#endif // SofiaMacro_h__