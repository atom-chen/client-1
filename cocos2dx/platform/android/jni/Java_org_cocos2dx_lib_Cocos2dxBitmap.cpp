#include "JniHelper.h"
#include <string.h>
#include "CCDirector.h"
#include "../CCApplication.h"
#include "platform/CCFileUtils.h"
#include "CCEventType.h"
#include "support/CCNotificationCenter.h"
#include <jni.h>

using namespace cocos2d;


int getFontSizeAccordingHeightJni(int height) {
    int ret = 0;

    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, "org/cocos2dx/lib/Cocos2dxBitmap", "getFontSizeAccordingHeight", "(I)I")) {
        ret = t.env->CallStaticIntMethod(t.classID, t.methodID, height);
        t.env->DeleteLocalRef(t.classID);
    }

    return ret;
}

std::string getStringWithEllipsisJni(const char* pszText, float width, float fontSize) {
    std::string ret;
    JniMethodInfo t;

    if (JniHelper::getStaticMethodInfo(t, "org/cocos2dx/lib/Cocos2dxBitmap", "getStringWithEllipsis", "(Ljava/lang/String;FF)Ljava/lang/String;")) {
        jstring stringArg1;

        if (!pszText) {
            stringArg1 = t.env->NewStringUTF("");
        } else {
            stringArg1 = t.env->NewStringUTF(pszText);
        }

        jstring retFromJava = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID, stringArg1, width, fontSize);
        const char* str = t.env->GetStringUTFChars(retFromJava, 0);
        ret = str;

        t.env->ReleaseStringUTFChars(retFromJava, str);
        t.env->DeleteLocalRef(stringArg1);
        t.env->DeleteLocalRef(t.classID);
    }
    return ret;
}

std::string subString( const char* pszText, const char* pszFontName, int fontSize, int maxWidth )
{
	if (!pszText || !pszFontName)
		return "";

	CCLog("subString:%s, font:%s", pszText, pszFontName);

	std::string ret = pszText;

	JniMethodInfo t;
	if (0 != maxWidth && JniHelper::getStaticMethodInfo(t, "org/cocos2dx/lib/Cocos2dxBitmap", "subStringWithMaxWidth", "(Ljava/lang/String;Ljava/lang/String;II)Ljava/lang/String;"))
	{
		jstring jstrText = t.env->NewStringUTF(pszText);
		jstring jstrFontName = t.env->NewStringUTF(pszFontName);

		jstring retFromJava = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID, jstrText, jstrFontName, fontSize, maxWidth);
		ret  = JniHelper::jstring2string(retFromJava);

		t.env->DeleteLocalRef(jstrText);
		t.env->DeleteLocalRef(jstrFontName);
		t.env->DeleteLocalRef(t.classID);
	}

	return ret;
}


