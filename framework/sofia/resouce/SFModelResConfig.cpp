#include "resource/SFModelResConfig.h"
#include "sofia/SofiaMacro.h"
#include "cocos2d.h"
#include "cocos-ext.h"
#include "resource/SFLoadResourceModule.h"
#include "resource/SFResourceLoad.h"
static SFLoadSpriteModule*	bgTextureDeleage = NULL;
USING_NS_CC;
USING_NS_CC_EXT;
SFModelResConfig::SFModelResConfig()
	: m_lessUsed(50)
{
	bgTextureDeleage = new SFLoadSpriteModule;
	SFResourceLoad::sharedResourceLoadCache()->addLoadingModule(bgTextureDeleage);
}

SFModelResConfig::~SFModelResConfig()
{
	SFResourceLoad::sharedResourceLoadCache()->removeLoadingModule(bgTextureDeleage);
	bgTextureDeleage = NULL;
}

static SFModelResConfig *g_sharedModelRes = NULL;
SFModelResConfig* SFModelResConfig::sharedSFModelResConfig()
{
	if (!g_sharedModelRes)
	{
		g_sharedModelRes = new SFModelResConfig();
	}
	return g_sharedModelRes;
}

void SFModelResConfig::purgeSharedSFModelResConfig()
{
	CC_SAFE_DELETE(g_sharedModelRes);
}

void SFModelResConfig::setActionConfig( unsigned int modelId, char modelIndex )
{
	m_actionMap.insert(std::pair<unsigned int, char>(modelId, modelIndex));
}

signed char SFModelResConfig::getActionConfig( unsigned int action )
{
	ActionConfig::iterator iter;
	iter = m_actionMap.find(action);
	if (iter != m_actionMap.end())
		return m_actionMap[action];
	return -1;
}

void SFModelResConfig::removeActionConfig( unsigned int modelId )
{
	ActionConfig::iterator iter;
	iter = m_actionMap.find(modelId);
	if (iter != m_actionMap.end())
		m_actionMap.erase(iter);
}

void SFModelResConfig::setModelType( char type, const char* path, const char* name)
{
	ModelTypeConfig config;
	config.modelPath = path;
	config.modelName = name;
	m_modelType.insert(std::pair<char, ModelTypeConfig>(type, config));
	std::string fileName = config.modelPath + config.modelName + ".ExportJson";
	CCArmatureDataManager::sharedArmatureDataManager()->addArmatureFileInfo(fileName.c_str());
}

ModelTypeConfig SFModelResConfig::getModelType( char type )
{
	ModelType::iterator iter;
	iter = m_modelType.find(type);
	if (iter != m_modelType.end())
		return m_modelType[type];
	return ModelTypeConfig();
}

void SFModelResConfig::removeModelType( char type )
{
	ModelType::iterator iter;
	iter = m_modelType.find(type);
	if (iter != m_modelType.end())
	{
		std::string fileName = iter->second.modelPath + iter->second.modelName;
		CCArmatureDataManager::sharedArmatureDataManager()->removeArmatureFileInfo(fileName.c_str());
		m_modelType.erase(iter);
	}
}

void SFModelResConfig::setModelId( int id )
{
	m_modelId.insert(std::pair<int, char>(id, 0));
}

bool SFModelResConfig::checkModelId( int id )
{
	ModelId::iterator iter;
	iter = m_modelId.find(id);
	if (iter != m_modelId.end())
		return true;
	return false;
}

void SFModelResConfig::setModelOffset( signed char actionId, short offsetX, short offsetY )
{
	ModelOffset::iterator iter = m_modelOffset.find(actionId);
	ActionOffset* ao;
	if (iter == m_modelOffset.end())
	{
		ao = new std::vector<cocos2d::CCPoint>();
		m_modelOffset[actionId] = ao;
	}
	else
		ao = iter->second;
	ao->push_back(ccp(offsetX, offsetY));
}

const cocos2d::CCPoint& SFModelResConfig::getModelOffset( signed char actionId, signed char index )
{
	ModelOffset::iterator iter = m_modelOffset.find(actionId);
	if (iter != m_modelOffset.end() && iter->second->size() > index)
	{
		return (*iter->second)[index];
	}
	return CCPointZero;
}

void SFModelResConfig::addSFRecord( std::string& jsonFile )
{
 	SFRSRecord::iterator iter = m_sfrUsedObj.find(jsonFile);
 	if (iter != m_sfrUsedObj.end())
 	{
		++iter->second->usedCount;
		++iter->second->reference;
 	}
	else
	{
		//如果没有的话，就要创建相应的内容
		SFRecord* record = new SFRecord;
		record->usedCount = 1;
		record->reference = 1;
		record->beCache = false;
		record->point = NULL;
		m_sfrUsedObj.insert(std::pair<std::string, SFRecord*>(jsonFile, record));
	}
}

void SFModelResConfig::removeSFRecord( std::string& jsonFile )
{
 	SFRSRecord::iterator iter = m_sfrUsedObj.find(jsonFile);
 	if (iter != m_sfrUsedObj.end() && iter->second->reference > 0)
 	{
		--iter->second->reference;
		if(iter->second->beCache == true)
			return;
		//如果使用次数大于最少使用次数，并且不是cache里面的
		if(iter->second->usedCount > m_lessUsed)
		{
			//加入到常用列表。不做释放
			iter->second->beCache = true;
			//如果列表大于10个，替代最少使用的一个。如果不满，直接插入
			if(m_sfrTempObj.size() > 10)
			{
				SFRecord* lessRecord = NULL;
				SFRSRecord::iterator it;
				for (SFRSRecord::iterator itr = m_sfrTempObj.begin(); itr != m_sfrTempObj.end(); ++itr)
				{
					if( !lessRecord && itr->second->usedCount <= m_lessUsed )
					{
						lessRecord = itr->second;
						m_lessUsed = iter->second->usedCount;
						it= itr;
					}
					m_lessUsed = MIN(itr->second->usedCount, m_lessUsed);
				}
				if(lessRecord)
				{
					lessRecord->beCache = false;
					CCAssert(lessRecord->reference>=0,"lessRecord->reference < 0 is error");
					if(lessRecord->reference == 0)
						m_sfrRemoveObj.push_back(it->first);
					m_sfrTempObj.erase(it);
					CC_SAFE_RELEASE_NULL(it->second->point);
				}
				else
				{
					CCLOG("SFModelResConfig::removeSFRecord error");
				}
			}
			size_t startPos = jsonFile.find_last_of("."); 
			jsonFile = jsonFile.erase(startPos);
			startPos = jsonFile.find_last_of("/");
			jsonFile = jsonFile.erase(0,startPos+1);
			CCArmature* armature = CCArmature::create(jsonFile.c_str());
			armature->retain();
			iter->second->point = armature;
			m_sfrTempObj.insert(std::pair<std::string, SFRecord*>(jsonFile, iter->second));
		}
 		else if(iter->second->reference == 0)
 		{
			m_sfrRemoveObj.push_back(iter->first);
 		}
 	}
}

void SFModelResConfig::resetSFRecord()
{
	while(!m_sfrRemoveObj.empty())
	{
		std::string str = m_sfrRemoveObj.front();
		m_sfrRemoveObj.pop_front();
		if( this->removeSFObj(str) )
			CCArmatureDataManager::sharedArmatureDataManager()->removeArmatureFileInfo(str.c_str());
	}
	//reset temp obj
}

bool SFModelResConfig::removeSFObj( std::string& str )
{
	SFRSRecord::iterator iter = m_sfrUsedObj.find(str);
	if (iter != m_sfrUsedObj.end() && iter->second->beCache == false && iter->second->reference == 0)
	{
		return true;
	}
	return false;
}

int SFModelResConfig::addSFRenderSprite(int modelId, const char* plist)
{
	return bgTextureDeleage->addLoadObject(modelId, plist);
}

void SFModelResConfig::removeSFRenderSprite(int modelId)
{
	return bgTextureDeleage->removeLoadObject(modelId);
}
