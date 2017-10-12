#include "map/MapResouceManager.h"
#include "include/utils/SFStringUtil.h"
#include "sofia/utils/SFLog.h"
#include "map/SFMapDef.h"
#include "resource/EntityData.h"
#include "stream/iStream.h"
#include "stream/MemoryStream.h"
#include "resource/SFModelResConfig.h"

MapResouceManager::MapResouceManager()
	: m_loadConfgModule(NULL)
{

}

MapResouceManager::~MapResouceManager()
{
}

void MapResouceManager::onLoaded( CCNode* node, void* data )
{
	CsvReader* pReader = (CsvReader*)data;

	int id = pReader->readAsInt("type", 0);
	std::string path = pReader->readAsString("name", "");
	if (id == 1)
	{
		if ( SFStringUtil::isEqual("zpk/config/static.csv", path.c_str()) )
			GAME_RESOURCE->loadCSV(path.c_str(), this,callfuncND_selector(MapResouceManager::onStaticLoad));
		else if(SFStringUtil::isEqual("zpk/config/modelConfig.csv", path.c_str()))
			GAME_RESOURCE->loadCSV(path.c_str(), this,callfuncND_selector(MapResouceManager::onModelConfig));
		else if(SFStringUtil::isEqual("zpk/config/modelId.csv", path.c_str()))
			GAME_RESOURCE->loadCSV(path.c_str(), this,callfuncND_selector(MapResouceManager::onModelId));
		else if(SFStringUtil::isEqual("zpk/config/actionConfig.csv", path.c_str()))
			GAME_RESOURCE->loadCSV(path.c_str(), this,callfuncND_selector(MapResouceManager::onActionConfig));
		else if(SFStringUtil::isEqual("zpk/config/weaponOffset.csv", path.c_str()))
			GAME_RESOURCE->loadCSV(path.c_str(), this,callfuncND_selector(MapResouceManager::onModelOffset));
	}
	else if (id == 0)
	{
		GAME_RESOURCE->setMapPath(path.c_str());
	}
}

void MapResouceManager::loadConfig( const char* configfile )
{
	m_pImagesetInfo = cmap::iMapFactory::inst->GetImageSetInfo();
	CC_SAFE_RELEASE_NULL(m_loadConfgModule);
	m_loadConfgModule = new SFLoadConfigModule();
	m_loadConfgModule->setAutoDel(true);
	SFResourceLoad::sharedResourceLoadCache()->addLoadingModule(m_loadConfgModule);
	GAME_RESOURCE->loadCSV(configfile, this, callfuncND_selector(MapResouceManager::onLoaded));
}

void MapResouceManager::onLoadCallback( CCNode* node, void* data )
{
	CsvReader* pReader = (CsvReader*)data;
}

void MapResouceManager::onStaticLoad( CCNode* node, void* data )
{
	CsvReader* pReader = (CsvReader*)data;
	int id = pReader->readAsInt("id", 0);
	CC_ASSERT(id!=0);
	const char* path = pReader->readAsString("path", "");
	const char* type = pReader->readAsString("type", "");
	m_pImagesetInfo->SetStaticImage(id, path, type);
}

void MapResouceManager::onModelConfig( CCNode* node, void* data )
{
	CsvReader* pReader = (CsvReader*)data;
	int id = pReader->readAsInt("modelId", 0);
	SFModelResConfig::sharedSFModelResConfig()->setModelType(id, pReader->readAsString("path", ""), pReader->readAsString("filename", ""));
}

void MapResouceManager::onModelId( CCNode* node, void* data )
{
	CsvReader* pReader = (CsvReader*)data;
	int id = pReader->readAsInt("id", 0);
	SFModelResConfig::sharedSFModelResConfig()->setModelId(id);
}

void MapResouceManager::onActionConfig( CCNode* node, void* data )
{
	CsvReader* pReader = (CsvReader*)data;
	int actionId= pReader->readAsInt("actionId", 0);
	char modelId= pReader->readAsInt("modelId", 0);
	SFModelResConfig::sharedSFModelResConfig()->setActionConfig(actionId, modelId);
}

void MapResouceManager::onModelOffset( CCNode* node, void* data )
{
	CsvReader* pReader = (CsvReader*)data;
	signed char actionId= pReader->readAsInt("actionId", 0);
	short offsetX= pReader->readAsInt("offsetX", 0);
	short offsetY= pReader->readAsInt("offsetY", 0);
	SFModelResConfig::sharedSFModelResConfig()->setModelOffset(actionId, offsetX, offsetY);
}
