#ifndef MapResouceManager_h__
#define MapResouceManager_h__
#include "resource/SFResourceLoad.h"
#include "resource/GameResource.h"
#include <string>
#include <map>

class MapResouceManager : public cocos2d::CCObject
{
public:
	MapResouceManager();
	virtual ~MapResouceManager();

	//set lua callback
	void loadConfig(const char* configfile);
	void onLoadCallback(CCNode* node, void* data);
private:
	//csv
	void onStaticLoad(CCNode* node, void* data);
	void onModelConfig(CCNode* node, void* data);
	void onModelId(CCNode* node, void* data);
	void onActionConfig(CCNode* node, void* data);
	void onLoaded(CCNode* node, void* data);
	void onModelOffset(CCNode* node, void* data);
private:
	SFLoadConfigModule* m_loadConfgModule;
};


#endif // MapResouceManager_h__