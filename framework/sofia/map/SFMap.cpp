#include "cocos2d.h"
#include "map/SFMap.h"
#include "map/Map.h"
#include "map/SpriteMove.h"
#include "map/SFSpriteEvent.h"
#include "core/RenderSprite.h"
#include "core/RenderScene.h"
#include "stream/iStream.h"
#include "stream/MemoryStream.h"
#include "stream/BinaryReader.h"
#include "stream/BinaryWriter.h"
#include "sofia/utils/SFLog.h"
#include "resource/SFModelResConfig.h"
using namespace core;
USING_NS_CC;

SFMap::SFMap():m_pRenderScene(0), m_nTouchHandler(0),m_backgroundLoad(NULL)
	,m_defaultId(0)//, m_bgTextureDeleage(NULL)
{
	m_renderLayer = CCArray::create();
	m_renderLayer->retain();
}

SFMap::~SFMap()
{
	CC_SAFE_RELEASE_NULL(m_renderLayer);
	CC_SAFE_RELEASE(m_pRenderScene);
	SFResourceLoad::sharedResourceLoadCache()->removeLoadingModule(m_backgroundLoad);
	//SFResourceLoad::sharedResourceLoadCache()->removeLoadingModule(m_bgTextureDeleage);
	//CC_SAFE_RELEASE_NULL(m_backgroundLoad);
}

void SFMap::init()
{
	if(m_pRenderScene == NULL)
	{
		m_pRenderScene = new core::RenderScene;

		//m_pRenderScene->setScale(0.5f);
		//精灵layer，scene析构时候自动析构
		core::RenderSceneLayer* layer = new core::RenderSceneLayer;
		layer->autorelease();
		m_pRenderScene->addChild(layer, 0, eRenderLayer_Sprite);
		m_renderLayer->addObject(layer);

		// 在地图和精灵之间显示的层
		core::RenderSceneLayerBase* layer2 = new core::RenderSceneLayerBase;
		layer2->autorelease();
		m_pRenderScene->addChild(layer2, -1, eRenderLayer_SpriteBackground);
		m_renderLayer->addObject(layer2);


		//特效layer，scene析构时候自动析构
		core::RenderSceneLayerBase* layer3 = new core::RenderSceneLayerBase;
		layer3->autorelease();
		m_pRenderScene->addChild(layer3, 1, eRenderLayer_Effect);
		m_renderLayer->addObject(layer3);

		if(m_backgroundLoad == NULL)
		{
			m_backgroundLoad = new SFRenderSpriteModule;
			SFResourceLoad::sharedResourceLoadCache()->addLoadingModule(m_backgroundLoad);
		}
// 		if(m_bgTextureDeleage == NULL)
// 		{
// 			m_bgTextureDeleage = new SFLoadSpriteModule;
// 			SFResourceLoad::sharedResourceLoadCache()->addLoadingModule(m_bgTextureDeleage);
// 		}
	}
}

bool SFMap::loadMap(int id)
{
	//回收所有的npc,清楚父子节点关系又其副解决
	m_idleNpc.swap(m_useNpc);
	m_useNpc.clear();

	CCObject* child;
	CCARRAY_FOREACH(m_pRenderScene->getChildren(), child)
	{
		CCNode* pNode = (CCNode*) child;
		if(pNode)
			pNode->removeAllChildren();
	}
	m_backgroundLoad->clearAllObject();

	//清理现在所有的怪物
	//to do 清理后，需要加入到异步中把资源删除。
	//rendersprite 的析构对引用计算做统计来做释放
	MapMonster::iterator iter = m_idleMonster.begin();
	for ( ; iter != m_idleMonster.end(); ++iter)
	{
		MapSprite::iterator itr = iter->second.begin();
		for (; itr != iter->second.end(); ++itr)
		{
			CC_SAFE_RELEASE_NULL((*itr));
		}
	}
	m_idleMonster.clear();
	//CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFrames();
	SFModelResConfig::sharedSFModelResConfig()->resetSFRecord();
	bool ret = GAME_RESOURCE->loadMapFile(id, this);
	CCTextureCache::sharedTextureCache()->removeUnusedTextures();

	return ret;
}

bool SFMap::loadMap( SFMapLoadInterface* load )
{
	if (load->getBlobSize() <= 0)
		return false;

	MemoryStream msback;
	msback.SetAccessMode(iStream::ReadWriteAccess);
	msback.Open();
	msback.Seek(0, iStream::Begin);
	cocos2d::BinaryWriter write;
	write.SetStream(&msback, false);
	write.Open();

	write.WriteRawData(load->getBlobBuf(), load->getBlobSize());
	write.Close();
	msback.Seek(0, iStream::Begin);

	m_pRenderScene->load(msback);

	return true;
}

bool SFMap::saveMap(int id)
{
	return true;
}

void SFMap::setViewCenter( unsigned int x, unsigned int y )
{
	m_pRenderScene->setViewCenter(x,y);
}

unsigned int SFMap::getViewCenterX() const
{
	return m_pRenderScene->getMap()->GetViewCenterX();
}

unsigned int SFMap::getViewCenterY() const
{
	return m_pRenderScene->getMap()->GetViewCenterY();
}

void SFMap::setViewBegin( unsigned int x, unsigned int y )
{
	m_pRenderScene->getMap()->SetViewBegin(x, y);
}

unsigned int SFMap::getViewBeginX() const
{
	return m_pRenderScene->getMap()->GetViewBeginX();
}

unsigned int SFMap::getViewBeginY() const
{
	return m_pRenderScene->getMap()->GetViewBeginY();
}

void SFMap::setViewSize( unsigned int w, unsigned int h )
{
	m_pRenderScene->getMap()->SetViewSize(w, h);
}

unsigned int SFMap::getViewSizeW() const
{
	return m_pRenderScene->getMap()->GetViewSizeW();
}

unsigned int SFMap::getViewSizeH() const
{
	return m_pRenderScene->getMap()->GetViewSizeH();
}

unsigned int SFMap::getMapWidth() const
{
	return m_pRenderScene->getMap()->GetMapWidth();
}

unsigned int SFMap::getMapHeight() const
{
	return m_pRenderScene->getMap()->GetMapHeight();
}

bool SFMap::enterMap( cocos2d::CCNode* sprite, eRenderLayerTag  tag, bool filter)
{
	if(!sprite) return false;
	if (filter)
	{
		//如果需要筛选，加入到筛选列表中
		m_pRenderScene->getMap()->addSprite(sprite, tag);
	}
	else
	{
		//如果不需要筛选，直接加入渲染
		RenderSceneLayerBase* layer = static_cast<RenderSceneLayerBase* >(m_renderLayer->objectAtIndex(tag));
		if(layer)
		{
			SFAssert(layer , "SFMap::enterMap layer can't be NULL");
			if(sprite->getParent()){
				sprite->retain();
				sprite->removeFromParent();
			}
			layer->addChild(sprite, 0, tag);
		}
	}
	return true;
}

bool SFMap::loadCharacterModel( int modelId,eMapRenderDelMode mode )
{
	RenderSprite* spr = NULL;
	bool ret = false;
	switch (mode)
	{
	case eMapRenderDelMode_NPC:
		break;
	case eMapRenderDelMode_Monster:
		{
			MapMonster::iterator iter = m_idleMonster.find(modelId);
			if (iter == m_idleMonster.end())
			{
				spr = new RenderSprite();
				spr->load(modelId,m_defaultId);
				spr->changeAction(0,1.0f,true);
				spr->changeAction(9,1.0f,true);
				//spr->changeAction(2,1.0f,true);
				ret = true;
				m_idleMonster[modelId].push_back(spr);
			}
		}
		break;
	case eMapRenderDelMode_Player:
		break;
	case eMapRenderDelMode_Effect:
		break;
	case eMapRenderDelMode_Normal:
		break;
	default:
		break;
	}
	return ret;
}

core::RenderSprite* SFMap::enterMap( int modelId, int x, int y,int callbackHander,  eRenderLayerTag tag,  eMapRenderDelMode mode )
{
	RenderSprite* spr = NULL;
	switch (mode)
	{
	case eMapRenderDelMode_NPC:
		{
			//CCLOG("SFMap::enterMap : %d", modelId);
			if (!m_idleNpc.empty())
			{
				spr = m_idleNpc.back();
				m_idleNpc.pop_back();
				m_useNpc.push_back(spr);
				spr->removeAllChildren();
			}
			else
			{
				spr = new RenderSprite();
				m_useNpc.push_back(spr);
				CCInteger* m = CCInteger::create(mode);
				spr->setUserObject(m);
			}
			spr->setPosition(x,y);
			if(spr->load(modelId))
			{
				spr->changeModel(modelId);
				m_pRenderScene->getMap()->addSprite(spr, tag);
			}
			else
				this->enterMap(spr, tag);
		}
		break;
	case eMapRenderDelMode_Monster:
		{
			MapMonster::iterator iter = m_idleMonster.find(modelId);
			if (iter != m_idleMonster.end() && !iter->second.empty())
			{
				spr = iter->second.back();
				iter->second.pop_back();
				spr->removeAllChildren();
			}
			else
			{
				spr = new RenderSprite();
			}
			spr->load(modelId,m_defaultId);
			spr->setPosition(x,y);
			spr->autorelease();
			this->enterMap(spr, tag);
		}
		break;
	case eMapRenderDelMode_Player:
		{

		}
		break;
	case eMapRenderDelMode_Effect:
		{

		}
		break;
	case eMapRenderDelMode_Normal:
		break;
	}
	return spr;
}

bool SFMap::EnterMap( CCNode* sprite,eRenderLayerTag tag )
{
	RenderSceneLayerBase* layer = static_cast<RenderSceneLayerBase* >(m_renderLayer->objectAtIndex(tag));
	layer->addChild(sprite, 0, tag);
	return true;
}

bool SFMap::enterMapAsyn( cocos2d::CCNode* sprite, int callbackHander, eRenderLayerTag tag /*= eRenderLayer_Sprite*/, bool filter /*= false*/ )
{
	sprite->setTag(tag);
	if(callbackHander)
	{
		sprite->retain();
		m_backgroundLoad->addLoadObject(sprite, callbackHander);
	}
	else
		this->enterMap(sprite, tag, filter);
	return true;
}

bool SFMap::leaveMap( core::RenderSprite* sprite )
{
	sprite->removeFromParentAndCleanup(true);
	sprite->setParent(NULL);
	return true;
}

bool SFMap::LeaveMap( cocos2d::CCNode* sprite )
{
	RenderSceneLayerBase* layer = static_cast<RenderSceneLayerBase* >(m_renderLayer->objectAtIndex(sprite->getTag()));
	layer->removeChild(sprite);
	return true;
}

bool SFMap::leaveMap( cocos2d::CCNode* sprite )
{
	if (!m_backgroundLoad->removeLoadObject(sprite) && sprite->getParent())
	{
		//RenderSprite* renderSpr = dynamic_cast<RenderSprite*>(sprite);
		RenderSceneLayerBase* layer = static_cast<RenderSceneLayerBase* >(m_renderLayer->objectAtIndex(sprite->getTag()));
		layer->removeChild(sprite);
	}
	return true;
}

bool SFMap::leaveMap( cocos2d::CCNode* sprite, eMapRenderDelMode mode /*= eMapRenderDelMode_Normal*/ )
{
	RenderSceneLayerBase* layer = static_cast<RenderSceneLayerBase* >(m_renderLayer->objectAtIndex(sprite->getTag()));
	switch (mode)
	{
	case eMapRenderDelMode_NPC:
		{
		}
		break;
	case eMapRenderDelMode_Monster:
		{
			RenderSprite* spr = (RenderSprite*)sprite;
			int modelId = spr->getModelId();
			sprite->retain();
			m_idleMonster[modelId].push_back(spr);
			if (!m_backgroundLoad->removeLoadObject(sprite))
			{
				//RenderSprite* renderSpr = dynamic_cast<RenderSprite*>(sprite);
				layer->removeChild(sprite);
			}
		}
		break;
	case eMapRenderDelMode_Player:
		break;
	case eMapRenderDelMode_Effect:
		break;
	case eMapRenderDelMode_Normal:
		break;
	default:
		break;
	}
	return true;
}

bool SFMap::injectTouchBegin( int screenX, int screenY )
{
	static int s_offsetX = -1;
	static int s_offsetY = -1;
	if(s_offsetX<0 || s_offsetY<0){
		cocos2d::CCDirector* pDirector = cocos2d::CCDirector::sharedDirector();
		CCSize winSize = pDirector->getWinSize();
		CCSize visSize = pDirector->getVisibleSize();
		CCPoint origin = pDirector->getVisibleOrigin();
		s_offsetX = (winSize.width-visSize.width-origin.x);
		s_offsetY = (winSize.height-visSize.height-origin.y);
	}

	SFTouchEvent e;
	e.screenX = screenX;
	e.screenY = screenY;

	int x = getViewBeginX() + e.screenX - s_offsetX;
	int y = getViewBeginY() + e.screenY - s_offsetY;

	e.mapX = x;
	e.mapY = y;

	if (0 != m_nTouchHandler)
	{
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		pEngine->executeFunctionWithObject(m_nTouchHandler, (void*)&e, eMapTouchEventBegin);
	}

	return true;
}

bool SFMap::injectTouchEnd( int x, int y )
{
	static int s_offsetX = -1;
	static int s_offsetY = -1;
	if(s_offsetX<0 || s_offsetY<0){
		cocos2d::CCDirector* pDirector = cocos2d::CCDirector::sharedDirector();
		CCSize winSize = pDirector->getWinSize();
		CCSize visSize = pDirector->getVisibleSize();
		CCPoint origin = pDirector->getVisibleOrigin();
		s_offsetX = (winSize.width-visSize.width-origin.x);
		s_offsetY = (winSize.height-visSize.height-origin.y);
	}
	SFTouchEvent e;
	e.screenX = x;
	e.screenY = y;

	int mapX = getViewBeginX() + e.screenX - s_offsetX;
	int mapY = getViewBeginY() + e.screenY - s_offsetY;

	e.mapX = mapX;
	e.mapY = mapY;

	if (0 != m_nTouchHandler)
	{
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		pEngine->executeFunctionWithObject(m_nTouchHandler, (void*)&e, eMapTouchEventEnd);
	}
	return true;
}

void SFMap::setMapLoadingCallback( IMapLoadingCompleteEvent* callback )
{
	m_pRenderScene->getMap()->SetMapLoadingEvent(callback);
}

const char* SFMap::getMapName()
{
	return m_pRenderScene->getMap()->GetName();
}

int SFMap::getMapId()
{
	return m_pRenderScene->getMap()->GetId();
}

SFPoint SFMap::coodMap2Cell( int mapx, int mapy )
{
	return SFPoint( Map2Cell(mapx), Map2Cell(mapy) );
}

SFPoint SFMap::coodCell2Map( int cellx, int celly )
{
	return SFPoint( Cell2Map(cellx), Cell2Map(celly) );
}

void SFMap::onBinaryFileLoad(MemoryStream& msback)
{
	m_pRenderScene->load(msback);
}

void SFMap::attach( cocos2d::CCNode* parent )
{
	parent->addChild(m_pRenderScene);
	m_pRenderScene->scheduleUpdate();
}

void SFMap::dettach()
{
	m_pRenderScene->removeFromParentAndCleanup(true);
}

bool SFMap::IsBlock( int cellx, int celly )
{
	return cmap::SpriteMove::IsBlock(cellx, celly);
}

bool SFMap::IsHaveBlock( int startX, int startY, int endX, int endY )
{
	return  cmap::SpriteMove::IsHaveBlock(startX, startY, endX, endY);
}

SFPoint SFMap::findBlock( int startX, int startY, int endX, int endY )
{
	cmap::IntPoint block = cmap::SpriteMove::finBlock(startX, startY, endX, endY);	
	SFPoint p(-1,-1);
	
	if(block.x>0 || block.y>0){
		p.x = block.x;
		p.y = block.y;
	}	
	return p;
}

void SFMap::setScriptHandler( int nHandler )
{
	m_nTouchHandler = nHandler;
}

core::RenderScene* SFMap::getRenderScene()
{
	return m_pRenderScene;
}

void SFMap::OnMapDataLoaded()
{
	m_pRenderScene->getMap()->OnMapDataLoaded();
}
