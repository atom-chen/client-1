/********************************************************************
	created:	2013/07/25
	created:	25:7:2013   12:52
	filename: 	D:\youai\dev\game_client\trunk\engine\base\map\MapBackgroundLoading.h
	file path:	D:\youai\dev\game_client\trunk\engine\base\map
	file base:	MapBackgroundLoading
	file ext:	h
	author:		
	
	purpose:	for load map image in asynchronous way
*********************************************************************/
#ifndef _MapBackgroundLoading_h__
#define _MapBackgroundLoading_h__

#include <list>
#include "cocos2d.h"
#include "map/MapLoadingInterface.h"

namespace cmap{

	class Map;
	class BgLoading;

class CMapResourceLoading : public cocos2d::CCObject
{
public:
	CMapResourceLoading();
	~CMapResourceLoading();

// 	void addLoadingModule(ILoadingModule* module);
// 	bool removeLoadingModule(ILoadingModule* module);
// 	void clearLoadingModule();

	void backgroundLoadImage(int id_);
	void backgroundReleaseImage(int id);
	void start(bool isSwitchScene);
	bool isLoading();
	void setMap( cmap::Map* map );

	//void setLoadingEventCallback(IMapLoadingCompleteEvent *loadingEvent);
	
private:
	void tick(float dt);
	
private:
	//IMapLoadingCompleteEvent *m_map_loadingEvent;
	cmap::Map* m_map;
	std::list<int> m_need_load_image_ids;
	std::list<int> m_need_release_image_ids;
	bool m_start_switch_scene;
};

}// end namespace cmap

#endif // _MapBackgroundLoading_h__