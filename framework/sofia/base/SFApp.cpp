
#include "sofia/utils/SFLog.h"
#include "include/utils/SFTimeAxis.h"
#include "map/StructCommon.h"
#include "base/SFApp.h"
#include "SFSimulator.h"
//#include "download/mfDownloader.h"

using namespace cocos2d;


SFApp::SFApp()
{
	//this->init();
}

SFApp::~SFApp()
{
}

void SFApp::startRun()
{
	cocos2d::CCSize size = cocos2d::CCEGLView::sharedOpenGLView()->getFrameSize();
	m_width = size.width;
	m_height = size.height;

	getScheduler()->scheduleUpdateForTarget(this, kCCPrioritySystem, false);

	this->onInit();
}


// void SFApp::stopRun()
// {
// 	getScheduler()->unscheduleUpdateForTarget(this);
// }


int SFApp::getScreenResolutionX()
{
	return m_width;
}

int SFApp::getScreenResolutionY()
{
	return m_height;
}


void SFApp::onTick( int microSecs )
{
	//SFLog("SFApp::onTick %d", microSecs);
	SFGameSimulator::sharedGameSimulator()->tick();//网络tick
	//MFDownloader::instance()->tick();			// 下载的回调依赖tick
}

void SFApp::onDraw()
{

}

void SFApp::update( float dt )
{

	SFTimeAxis* pTimeAxis = SFTimeAxis::getInstancePtr();
	pTimeAxis->advance(dt* 1000);

	onTick(pTimeAxis->getDelayTime());
}

void SFApp::draw( void )
{
	cocos2d::CCScene::draw();
	onDraw();
}

void SFApp::onDestory()
{

}

void SFApp::onExit()
{
	this->removeAllChildrenWithCleanup(true);
	onDestory();
	cocos2d::CCScene::onExit();
}

bool SFApp::init()
{
	cocos2d::CCScene::init();
	startRun();
	return true;
}
