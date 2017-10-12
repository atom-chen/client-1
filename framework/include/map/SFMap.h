#ifndef _MFMAP_H_
#define _MFMAP_H_
#include <string>
#include <list>
#include "SFMapDef.h"
#include "utils/SFGeometry.h"
#include "resource/GameResource.h"
//#include "SFSpriteEvent.h"
#include "map/MapLoadingInterface.h"
#include "script_support/CCScriptSupport.h"
#include "resource/SFLoadResourceModule.h"
namespace cmap
{
	class Map;
	class iMapFactory;
}

namespace core
{
	class RenderScene;
	class RenderSprite;
}

class SFMapLoadInterface
{
public:
	virtual void*	getBlobBuf() = 0;
	virtual int		getBlobSize() = 0;
	virtual bool	getBlobCompress() = 0;
};

class SFMapLoadForSQL : public SFMapLoadInterface
{
protected:
	void*		blobBuf;
	int			blobSize;
	bool		bCompress;
public:
	SFMapLoadForSQL() : blobBuf(NULL), blobSize(0) , bCompress(false)
	{
	}
	virtual ~SFMapLoadForSQL()
	{
		CC_SAFE_DELETE(blobBuf);
	}
	virtual void*	getBlobBuf(){return blobBuf;};
	virtual int		getBlobSize(){return blobSize;};
	virtual bool	getBlobCompress(){return bCompress;};
};

// for lua
enum eMapTouchEvent
{
	eMapTouchEventBegin,
	eMapTouchEventMove,
	eMapTouchEventEnd
};

enum eMapRenderDelMode
{
	eMapRenderDelMode_NPC,
	eMapRenderDelMode_Monster, // render sprite background
	eMapRenderDelMode_Player,
	eMapRenderDelMode_Effect,// 特效层
	eMapRenderDelMode_Normal,		
};

//地图接口类
// 地图不读取Sqlite了，直接读取流文件 map/data 下的文件
class SFMap : public IReadBinaryFileCallBack
{
private:
	core::RenderScene*	m_pRenderScene;				//渲染的场景
	int					m_nTouchHandler;			//lua
public:
	SFMap();
	~SFMap();
public:
	//公用部分
	//---------------------------------------------------------------
	static SFPoint coodMap2Cell( int mapx, int mapy );
	static SFPoint coodCell2Map( int cellx, int celly );

	//加载地图 
	bool loadMap(int id);
	bool saveMap(int id);
	//加载地图
	bool loadMap(SFMapLoadInterface* load);

	void setDefaultId(int monsterId){m_defaultId = monsterId;}
	bool loadCharacterModel(int modelId,eMapRenderDelMode mode);
	core::RenderSprite* enterMap(int modelId, int x, int y, int callbackHander,eRenderLayerTag tag, eMapRenderDelMode mode);
	bool EnterMap(cocos2d::CCNode* sprite, eRenderLayerTag tag);
	bool leaveMap(cocos2d::CCNode* sprite, eMapRenderDelMode mode);
	//进入地图
	bool enterMap(cocos2d::CCNode* sprite, eRenderLayerTag tag= eRenderLayer_Sprite, bool filter = false);
	//用于lua的异步加载加入地图的精灵
	bool enterMapAsyn(cocos2d::CCNode* sprite, int callbackHander, eRenderLayerTag tag = eRenderLayer_Sprite, bool filter = false);
	bool leaveMap(core::RenderSprite* sprite);
	bool leaveMap(cocos2d::CCNode* sprite);
	bool LeaveMap(cocos2d::CCNode* sprite);

	//地图信息
	const char* getMapName();
	int getMapId();
	unsigned int getMapWidth() const;
	unsigned int getMapHeight() const;

	//设置视窗口中心点
	void setViewCenter(unsigned int x, unsigned int y);
	unsigned int getViewCenterX() const;
	unsigned int getViewCenterY() const;

	//设置视窗口左上角
	void setViewBegin(unsigned int x, unsigned int y);
	unsigned int getViewBeginX() const;
	unsigned int getViewBeginY() const;

	//设置视窗口尺寸
	void setViewSize(unsigned int w, unsigned int h);
	unsigned int getViewSizeW() const;
	unsigned int getViewSizeH() const;

	//设置点击事件回调
	void setMapLoadingCallback(IMapLoadingCompleteEvent* callback);

	// lua的点击回调
	void setScriptHandler(int nHandler);

	//是否阻挡点
	bool IsBlock(int cellx, int celly);
	//是否直线阻挡
	bool IsHaveBlock(int startX, int startY, int endX, int endY);
	SFPoint findBlock(int startX, int startY, int endX, int endY);
public:
	//内部调用部分
	//-------------------------------------------------------------
	void init();

	//链接cocos2d，显示到屏幕
	void attach(cocos2d::CCNode* parent);
	void dettach();
	
	bool injectTouchBegin(int sceenX, int sceenY);
	bool injectTouchEnd(int sceenX, int sceenY);

public:
	core::RenderScene* getRenderScene();
	void OnMapDataLoaded();
private:
	// SQLite 的CallBack，继承于ISqlReadStreamCallBack，已经停用
	// 地图文件*.cm的CallBack
	virtual void onBinaryFileLoad(MemoryStream& msback);
	//精灵异步加载支持
	SFRenderSpriteModule*			m_backgroundLoad;
	//SFLoadSpriteModule*				m_bgTextureDeleage;
protected:
	// npc可以常驻，切换场景替换变换量
	// 第二次场景的时候，可能需要重新加载相关的
	typedef std::list<core::RenderSprite*> MapSprite;
	typedef std::map<int, MapSprite> MapMonster;

	//NPC npc不多情况下，可以用list解决
	MapSprite m_useNpc;
	MapSprite m_idleNpc;
	//monster
	MapMonster m_idleMonster;		//空闲的怪物，以modelID做索引
	std::list<core::RenderSprite*> m_effect;
	std::list<core::RenderSprite*> m_player;
	CCArray*		m_renderLayer;
	int				m_defaultId;
};

#endif