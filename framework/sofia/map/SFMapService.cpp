#include "cocos2d.h"
#include "map/RenderInterface.h"
#include "map/RenderCocos.h"
#include "map/SpriteMove.h"
#include "map/MapResouceManager.h"
#include "map/SFMapService.h"
#include "resource/SFResourceLoad.h"

SFMapService::SFMapService():
	m_pMap(0),
	m_bStartUp(false),
	m_pResouceSlave(0)
{
	cmap::SpriteMove::Init();//初始化角色移动阻挡点信息
}

SFMapService::~SFMapService()
{
	this->clear();
	cmap::SpriteMove::End();
}

void SFMapService::startUp(const char* config)
{
	if (m_bStartUp)
		return;
	m_bStartUp = false;
	//this->clear();
	cocos2d::CCSize size = CCDirector::sharedDirector()->getVisibleSize();
	if(!cmap::iMapFactory::inst)
		cmap::iMapFactory::inst = new cmap::CCMapFactory();			//初始化引擎的地图渲染接口
	
	if(!m_pMap)
	{
		m_pMap = new SFMap;
		m_pMap->init();
		m_pMap->setViewSize(size.width, size.height);
	}

	MapResouceManager* manager = new MapResouceManager;
	manager->loadConfig(config);
	CC_SAFE_DELETE(m_pResouceSlave);
	m_pResouceSlave = manager;
}

void SFMapService::shutDown()
{
	m_bStartUp = false;
}

MapResouceManager* SFMapService::getMapResouceSlave()
{
	return m_pResouceSlave;
}

SFMapService* SFMapService::instance()
{
	return SFMapService::getInstancePtr();
}

void SFMapService::clear()
{
	CC_SAFE_DELETE(m_pResouceSlave);
	CC_SAFE_DELETE(m_pMap);
	CC_SAFE_DELETE(cmap::iMapFactory::inst);
	//CC_SAFE_DELETE(cmap::FrameAnimTempSet::inst);
}

void SFMapService::setScriptHandler( int scriptHander )
{
	SFResourceLoad::sharedResourceLoadCache()->setCompleteEventOnceHandler(scriptHander);
}
