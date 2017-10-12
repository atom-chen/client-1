#include "resource/SFLoadResourceModule.h"
#include "map/RenderCommon.h"
//#include "resource/GameResource.h"
#include "map/SFMapService.h"

USING_NS_CC;
SFLoadTextureModule::SFLoadTextureModule()
	: mbackshow(0)
{
}

SFLoadTextureModule::~SFLoadTextureModule()
{
	m_loadImageId.clear();
	m_gid.clear();
	m_removveImageId.clear();
}

int SFLoadTextureModule::loadingObjectCount()
{
	return m_loadImageId.size() + m_removveImageId.size();
}

int SFLoadTextureModule::loadingRemainderObject()
{
	return m_loadImageId.size() + m_removveImageId.size();
}

int SFLoadTextureModule::loadObject()
{
	if (!m_loadImageId.empty())
	{
		int imageid = m_loadImageId.front();
		m_loadImageId.pop_front();

		int gid = m_gid.front();
		m_gid.pop_front();
		std::string path = cmap::iMapFactory::inst->GetImageSetInfo()->GetStaticImagePath(imageid);
		if ( path.length())
		{
			cocos2d::CCTexture2D* texture2d = (cocos2d::CCTexture2D*)cocos2d::CCTextureCache::sharedTextureCache()->addImage(path.c_str());
			if (texture2d){
				texture2d->retain();
				mbackshow->updateTexture(gid,texture2d);
			}
			else
				CCLOG("ERROR : SFLoadTextureModule load image[%d], path is NULL", imageid);
		}
		else
			CCLOG("ERROR : SFLoadTextureModule load image[%d], path is NULL", imageid);
		return loadingRemainderObject();
	}
	else if(!m_removveImageId.empty())
	{
		int imageid = m_removveImageId.front();
		m_removveImageId.pop_front();
		cmap::iMapFactory::inst->GetImageSetInfo()->clearStaticImage(imageid);
		return m_removveImageId.size();
	}
	else
		return 0;
}

void SFLoadTextureModule::addLoadObject( int texId, int gid )
{
	m_loadImageId.push_back(texId);
	m_gid.push_back(gid);
}

void SFLoadTextureModule::removeObject( int texId )
{
	m_removveImageId.push_back(texId);
	//CCLOG("SFLoadTextureModule::removeObject texid:%d",texId);
}

void SFLoadTextureModule::clearObject()
{
	m_loadImageId.clear();
	m_gid.clear();
	//m_removveImageId.clear();
}

void SFLoadTextureModule::addBackgroundShow( cmap::iBackgroundShow* backshow )
{
	mbackshow = backshow;
}

int SFLoadSpriteModule::loadingObjectCount()
{
	return 0;
}

int SFLoadSpriteModule::loadingRemainderObject()
{
	return m_removeModel.size();
}

int SFLoadSpriteModule::loadObject()
{
	if (!this->m_removeModel.empty())
	{
		int modelId = m_removeModel.front();
		m_removeModel.pop_front();
		UsedModelMap::iterator iter = m_usedModel.find(modelId);
		if(iter != m_usedModel.end())
		{
			if(iter->second->useCount > 0)
			{
				--iter->second->useCount;
				if(iter->second->useCount == 0)
				{
					CCSpriteFrameCache::sharedSpriteFrameCache()->removeSpriteFramesFromFile(iter->second->plist.c_str());
					CCLOG("SFLoadSpriteModule removeObject: %s", iter->second->plist.c_str());
					//CCTextureCache::sharedTextureCache()->removeTexture(iter->second->texture);
					//CC_SAFE_RELEASE_NULL(iter->second->texture);
				}
			}
		}
	}
	return loadingRemainderObject();
}

int SFLoadSpriteModule::addLoadObject( int modelId, const char* plist )
{
	int ret = 0;
	UsedModelMap::iterator iter = m_usedModel.find(modelId);
	if(iter != m_usedModel.end())
	{
		ret = ++iter->second->useCount;
	}
	else
	{
		UsedModel* data = new UsedModel;
		data->useCount = 1;
		data->plist = plist;
		m_usedModel.insert(std::pair<int, UsedModel*>(modelId, data));
		ret = 1;
	}
	if(ret == 1)
		CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile(plist);
	return ret;
}

void SFLoadSpriteModule::removeLoadObject( int modelId )
{
	m_removeModel.push_back(modelId);
}

SFLoadConfigModule::SFLoadConfigModule()
{

}

SFLoadConfigModule::~SFLoadConfigModule()
{
	m_loadConfig.clear();
}

int SFLoadConfigModule::loadingObjectCount()
{
	return m_loadConfig.size();
}

int SFLoadConfigModule::loadingRemainderObject()
{
	return m_loadConfig.size();
}

int SFLoadConfigModule::loadObject()
{
	if (!m_loadConfig.empty())
	{
		ConfigData data = m_loadConfig.front();
		m_loadConfig.pop_front();

		GAME_RESOURCE->loadCSV(data.filemane.c_str(), data.target, data.callFunc);
		return m_loadConfig.size();
	}
	return 0;
}

void SFLoadConfigModule::addConfig( const char* filename, CCObject *target, SEL_CallFuncND callFunc )
{
	ConfigData data;
	data.filemane = filename;
	data.target = target;
	data.callFunc = callFunc;
	m_loadConfig.push_back(data);
}

void SFRenderSpriteModule::addLoadObject( CCNode* renderSpr, int luaHandler )
{
	m_loadRenderSprite.insert(std::pair<CCNode*, int>(renderSpr, luaHandler));
	//m_loadRenderSprite.insert(renderSpr);
}

bool SFRenderSpriteModule::removeLoadObject( CCNode* renderSpr )
{
	std::map<CCNode*, int>::iterator iter = m_loadRenderSprite.find(renderSpr);
	if (iter != m_loadRenderSprite.end())
	{
		iter->first->autorelease();
		m_loadRenderSprite.erase(iter);
		return true;
	}
	return false;
}

void SFRenderSpriteModule::clearAllObject()
{
	m_loadRenderSprite.clear();
}

SFRenderSpriteModule::~SFRenderSpriteModule()
{
	clearAllObject();
}

SFRenderSpriteModule::SFRenderSpriteModule()
{

}

int SFRenderSpriteModule::loadObject()
{
	if (!m_loadRenderSprite.empty())
	{
		std::map<CCNode*, int>::iterator iter = m_loadRenderSprite.begin();

		CCNode* node = iter->first;
		node->autorelease();
		if (0 != iter->second)
		{
			CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
			pEngine->executeRenderSprLoad(iter->second, node, (eRenderLayerTag)node->getTag());
		}
		else
		{
			SFMapService::instance()->getShareMap()->enterMap(node, (eRenderLayerTag)node->getTag());
		}
		m_loadRenderSprite.erase(iter);
	}
	return m_loadRenderSprite.size();
}

int SFRenderSpriteModule::loadingRemainderObject()
{
	return m_loadRenderSprite.size();
}

int SFRenderSpriteModule::loadingObjectCount()
{
	return m_loadRenderSprite.size();
}


