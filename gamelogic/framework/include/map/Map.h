#ifndef _MAP_MAP_H_
#define _MAP_MAP_H_
#include <list>
#include <vector>
#include <algorithm>
#include <string>
#include "map/StructCommon.h"
#include "stream/iStream.h"
#include "map/sap/SAP.h"
#include "stream/BinaryReaderNet.h"
#include "resource/SFResourceLoad.h"
class IMapLoadingCompleteEvent;
namespace cmap
{
	class Background;
	class Layer;
	class Mask;
	struct renderElem;

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
		bool LoadHeader(cocos2d::iStream& stream);
	public:
		void SetViewCenter(unsigned int x, unsigned int y);
		int GetViewCenterX() const;
		int GetViewCenterY() const;

		unsigned int GetViewBeginX() const;
		unsigned int GetViewBeginY() const;

		void SetViewSize(unsigned int w, unsigned int h);
		unsigned int GetViewSizeW() const;
		unsigned int GetViewSizeH() const;

		void SetMapSize( unsigned int tileColNum, unsigned int tileRowNum, unsigned int tileWidth, unsigned int tileHeight );
		unsigned int GetMapWidth() const;
		unsigned int GetMapHeight() const;

		void Render();

		void SetMapLoadingEvent(IMapLoadingCompleteEvent *callbackEvent);
		void onLoadCompleted();
		void OnMapDataLoaded();

		const char* GetName() { return this->name.c_str();}
		void SetName(const char* str) { this->name = str;}

		//添加layer
		void AddLayer(cmap::Layer* layer, int index);
		Layer* AddTileLayer(int index, int tileWidth, int tileHeight);
		Layer* AddAdornmentLayer(int index);
		Layer* AddMetaLayer(int index, int tileWidth, int tileHeight);
		//修改layer
		const cmap::LayerVector& GetLayers() const { return mLayers; }

		//删除layer
		void DelAllLayers();

		//mask
		Mask* GetMask();
		bool	IsMaskPoint(int cellx, int celly);

	public:
		//加入到的精灵，texture应该没有加载，在用到的时候再加载。减少内存消耗
		bool addSprite(cocos2d::CCNode* renderSpr, int layer);
		bool removeSprite(cocos2d::CCNode* renderSpr);
		void updateSprite(cocos2d::CCNode* renderSpr);
	private:
		unsigned int mapW;
		unsigned int mapH;

		int viewCenterX;
		int viewCenterY;
		unsigned int viewSizeWHalf;
		unsigned int viewSizeHHalf;

		std::string name;

		Mask* m_pMask;

		LayerVector mLayers;

		IMapLoadingCompleteEvent *m_map_loadingEvent;
		SFLoadTextureModule*	m_LoadModule;
		std::map<cocos2d::CCNode*, renderElem*>	m_object_map;
		// 数据版本
		//sap可视剔除
	private:
		class mapObjSAPListener:
			public SAPCommonListner,
			public SAPQueryListner
		{

		public:
			mapObjSAPListener();
			~mapObjSAPListener();

			void Init(Map *terrian_instance);

			virtual void* OnPairCreate(const void *object0, const void *object1);

			virtual void OnPairDelete(const void *object0, const void *object1, void *pPairData);

			virtual void OnQueryObject(const void *object0);

		private:
			Map *m_terrian_instance;

		};
	private:
		unsigned int m_cameraBoxHandle;
		mapObjSAPListener m_sap_listener;
		ArraySAP* m_sap;
	public:
		ArraySAP* getSap();
	};

}

#endif