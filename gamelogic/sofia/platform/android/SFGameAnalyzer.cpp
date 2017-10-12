#include "include/platform/SFGameAnalyzer.h"
#include "platform/android/jni/JniHelper.h"
#include "include/package/SFPackageManager.h"


using namespace cocos2d;
#define ANALYZER_CLASS "com/morningglory/shell/GardeniaAnalyzer"

void SFGameAnalyzer::logGameEvent( int eventId, std::string eventData )
{
	JniMethodInfo method;
	if (JniHelper::getStaticMethodInfo(method, ANALYZER_CLASS, "postEvent", "(ILjava/lang/String;)V"))
	{
		jstring jstr = method.env->NewStringUTF(eventData.c_str());
		method.env->CallStaticVoidMethod(method.classID, method.methodID, eventId, jstr);
		method.env->DeleteLocalRef(jstr);
		method.env->DeleteLocalRef(method.classID);
	}
}
