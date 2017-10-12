#ifndef _MAP_MAP_H_
#define _MAP_MAP_H_
#include <list>
#include <vector>
#include <algorithm>
#include <string>
#include "map/StructCommon.h"
#include "stream/iStream.h"
//#include "map/sap/SAP.h"
#include "stream/BinaryReaderNet.h"
//#include "map/SFSingleTileLayer.h"
#include "resource/SFResourceLoad.h"
class IMapLoadingCompleteEvent;
namespace cmap
{
	class Background;
	//class AdornmentGroup;
	//class iRectShow;
	class iMapRender;
	class iSpriteShow;
	class MultTypeAreaListRender;
	class Layer;
	class MiddleRenderLayer;
	class Mask;
	

	typedef std::vector<Layer*> LayerVector;

	enum RenderMode
	{
		RM_Normal,
		RM_Buffer,
	};
	class Map : public ISFLoadingCompleteEvent
	{

	public:
		Map();
		virtual ~Map();
		void Init(iMapRender *render, bool _inEditor);
		bool LoadHeader(cocos2d::iStream& stream);
		bool SaveHeader(cocos2d::iStream& stream);
	public:
		//bool GetDirty() const { return this->dirty;}
		void SetViewCenter(unsigned int x, unsigned int y);
		int GetViewCenterX() const;
		int GetViewCenterY() const;

		void SetViewBegin(unsigned int x, unsigned int y);
		unsigned int GetViewBeginX() const;
		unsigned int GetViewBeginY() const;

		void SetViewSize(unsigned int w, unsigned int h);
		unsigned int GetViewSizeW() const;
		unsigned int GetViewSizeH() const;

		void SetMapSize( unsigned int tileColNum, unsigned int tileRowNum, unsigned int tileWidth, unsigned int tileHeight );
		void SetMapSizeNew( unsigned int width, unsigned int height, unsigned int tileWidth, unsigned int tileHeight );
		unsigned int GetMapWidth() const;
		unsigned int GetMapHeight() const;

		unsigned int GetTileColNum() const;
		unsigned int GetTileRowNum() const;

		unsigned int GetTileWidth() const;
		unsigned int GetTileHeight() const;

		void setRenderMode(RenderMode rm);

		//void AdjustViewCenter();
		void Render();
		void Tick();

		void SetMapLoadingEvent(IMapLoadingCompleteEvent *callbackEvent);
		void onLoadCompleted();
		void OnMapDataLoaded();

		const char* GetName() { return this->name.c_str();}
		void SetName(const char* str) { this->name = str;}

		int GetId() { return this->id;}
		void SetId(int id_) { this->id = id_;}

		int GetLayerIndexByName(const char* name);
		Layer* GetLayerByName(const char* name);
		Layer* GetLayerByID(int id);
		int GetLayerNewID();

		//添加layer
		void AddLayer(cmap::Layer* layer, int index);
		Layer* AddTileLayer(int index, int tileWidth, int tileHeight);
		Layer* AddAdornmentLayer(int index);
		Layer* AddMetaLayer(int index, int tileWidth, int tileHeight);
		//修改layer
		void ResetLayersShow();
		//Layer* GetCurLayer();
		const cmap::LayerVector& GetLayers() const { return mLayers; }

		//删除layer
		void DelLayerByName(const char* name);
		void DelAllLayers();

		//mask
		Mask* GetMask();
		bool	IsMaskPoint(int cellx, int celly);

	public:
		//加入到的精灵，texture应该没有加载，在用到的时候再加载。减少内存消耗
		bool addSprite(cocos2d::CCNode* renderSpr, int layer);
		//是否需要，精灵可以自清除
		void removeSprite(cocos2d::CCNode* render);
	private:
		void CheckRenderRect();
		void SetRenderRect(unsigned int x, unsigned int y, unsigned int w, unsigned int h);

	protected:
	private:
		iMapRender* render;
		int id;
		unsigned int mapW;
		unsigned int mapH;

		unsigned int mTileWidth;
		unsigned int mTileHeight;

		int viewCenterX;
		int viewCenterY;
		unsigned int viewSizeW;
		unsigned int viewSizeH;

		std::string name;

		Mask* m_pMask;

		LayerVector mLayers;
		Background* mCurLayer;
		int mLayerNum;

		MiddleRenderLayer* mMiddleRenderLayer;
		RenderMode		m_renderMode;
		IMapLoadingCompleteEvent *m_map_loadingEvent;
		SFLoadTextureModule*	m_LoadModule;
		// 数据版本
		int m_version;
		char m_compress;
		int m_normalSize;
		int m_compressSize;
		//是否在加载过程中
		bool m_backgroundLoading;
	};

}

#endif