#ifndef _MFMAPSERVICE_H_
#define _MFMAPSERVICE_H_
#include "utils/Singleton.h"
#include "SFMap.h"
//#include "SFMapResourceSlave.h"
#include "MapResouceManager.h"
//==========================================================================
/**
*MapService是单例，Map和SpriteFactory也是单例
* purpose : 加载配置信息，获取精灵工厂，地图
*/
//==========================================================================

class SFMapService  : public cocos2d::Singleton<SFMapService>
{
public:
	SFMapService();
	~SFMapService();

	// lua不支持模板，这里取巧一下
	static SFMapService* instance();

public:
	void startUp(const char* config);
	void shutDown();
	//set lua callback
	void setScriptHandler(int scriptHander);
	SFMap* getShareMap() { return m_pMap; }

	MapResouceManager* getMapResouceSlave();
private:
	void clear();
private:
	SFMap* m_pMap;
	MapResouceManager*	m_pResouceSlave;
	bool m_bStartUp;
};

//#define getShareMap() SFMapService::getInstancePtr()->getShareMap()
#endif