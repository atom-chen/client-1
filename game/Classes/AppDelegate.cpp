#include "cocos2d.h"
#include "CCEGLView.h"
#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SFScriptManager.h"
#include "SimpleAudioEngine.h"
#include "SFGameApp.h"
#include "scene/SFGamePresenter.h"
#include "SFSimulator.h"
#include "SFScriptManager.h"
#include "package/SFPackageManager.h"
#include "textures/CCTexture2D.h"


//Juchao@20131225: 打开此宏，测试UI控件的内存
//#define  TEST_WIDGET_MEM
#ifdef TEST_WIDGET_MEM
#include "TestWidget.h"
#endif //


using namespace CocosDenshion;

USING_NS_CC;

AppDelegate::AppDelegate()
{
    
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    CCDirector *pDirector = CCDirector::sharedDirector();
	CCEGLView* pEGLView = CCEGLView::sharedOpenGLView();
    pDirector->setOpenGLView(pEGLView);
    
	CCTexture2D::PVRImagesHavePremultipliedAlpha(true);
    
    
	CCSize frameSize = pEGLView->getFrameSize();
	// 设置 LsSize 固定值
	CCSize lsSize = CCSizeMake(960, 640);
    
	float scaleX = (float) frameSize.width / lsSize.width;
	float scaleY = (float) frameSize.height / lsSize.height;
    
	// 定义 scale 变量
	float scale = 0.0f; // MAX(scaleX, scaleY);
	if (scaleX > scaleY) {
		// 如果是 X 方向偏大，那么 scaleX 需要除以一个放大系数，放大系数可以由枞方向获取，
		// 因为此时 FrameSize 和 LsSize 的上下边是重叠的
		scale = scaleX / (frameSize.height / (float) lsSize.height);
	} else {
		scale = scaleY / (frameSize.width / (float) lsSize.width);
	}
    
	// 根据 LsSize 和屏幕宽高比动态设定 WinSize
	CCEGLView::sharedOpenGLView()->setDesignResolutionSize(lsSize.width * scale,
                                                           lsSize.height * scale, kResolutionNoBorder);
	
    // set FPS. the default value is 1.0/60 if you don't call this
    //pDirector->setAnimationInterval(1.0 / 60);
    
#if(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	CCUserDefault::sharedUserDefault()->setStringForKey("PlatForm", "WIN32");
    
	SFPackageManager::Instance()->addPackageName("extend.zpk");
	SFPackageVersion version = SFPackageManager::Instance()->addPackageName("base.zpk");
	if (version.mainVersion == 0 && version.subVersion == 0)
	{
		// 没有找到资源包, 要设置搜索路径给getFileData查找资源
		std::string basePath = CCFileUtils::sharedFileUtils()->fullPathForFilename("base");
		std::string extentPath = CCFileUtils::sharedFileUtils()->fullPathForFilename("extend");
		CCFileUtils::sharedFileUtils()->addSearchPath(extentPath.c_str());
		CCFileUtils::sharedFileUtils()->addSearchPath(basePath.c_str());
	}
	else
	{
		SFScriptManager::shareScriptManager()->setZpkSupport(true);
		
	}
	// turn on display FPS
	pDirector->setDisplayStats(true);
	
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCUserDefault::sharedUserDefault()->setStringForKey("PlatForm", "ANDROID");
	SFScriptManager::shareScriptManager()->setZpkSupport(true);
#else
	CCUserDefault::sharedUserDefault()->setStringForKey("PlatForm", "NotWIN32");
#endif
    
#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	CCUserDefault::sharedUserDefault()->setStringForKey("PlatForm", "IOS");
    SFScriptManager::shareScriptManager()->setZpkSupport(true);
#endif
	CCUserDefault::sharedUserDefault()->flush();
    
	CCScene* scene = SFGameApp::createGameApp();
	CCDirector::sharedDirector()->runWithScene(scene);
	SFGameSimulator::sharedGameSimulator()->getGamePresenter()->replaceScene(scene);
    
	// register lua engine
	CCLuaEngine* pEngine = CCLuaEngine::defaultEngine();
	CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);
	SFScriptManager::shareScriptManager()->excuteZpkLua("loginScript/main.lua");

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    CCDirector::sharedDirector()->stopAnimation();
    
    SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    CCDirector::sharedDirector()->startAnimation();
    
    SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
}
