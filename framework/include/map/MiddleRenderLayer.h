#ifndef _MAP_MIDDLE_RENDER_LAYER_H_
#define _MAP_MIDDLE_RENDER_LAYER_H_

#include <map>
#include <vector>

#include "map/MetaLayer.h"
#include "map/StructCommon.h"

namespace cocos2d
{
	class CCRenderTexture;
	class CCTexture2D;
}
namespace cmap
{
	class iMapRender;
	//class CCImage;
	//class CMapResourceLoading;

	class MiddleRenderLayer : public CellGroup
	{
	public:
		MiddleRenderLayer();
		~MiddleRenderLayer();

	public:
		struct MapChunkImageIds
		{
			std::map<unsigned int, std::vector<int> > chunkMap;
		};
		//static const int CHUNK_SIZE = 1024; // pixel
		

		void AddLayer(Layer* layer);
		cmap::iMapRender* GeRender() const { return mRender; }
		void SetRender(cmap::iMapRender* val) { mRender = val; }

		virtual int CreateShow(int layerNum);
		virtual void DestroyShow();
		virtual bool Load(cocos2d::iStream& stream){return false;}
		virtual bool Save(cocos2d::iStream& stream) {return false;}

		virtual void Render();
		//virtual void AfterRender();
		virtual void Tick();

		void onMapImagesLoaded();
		void gatherChunkImages(int mapId, int mapWidth, int mapHeight, SFLoadTextureModule* mapBgloader);

	protected:

		struct CellInfo
		{
			int dynamicId;
			int elemId;
			cocos2d::CCRenderTexture* target;
			unsigned int releaseTime;
		};
		virtual void InternalBuildBuf(int xbeingindex, int xviewnum, int ybeingindex, int yviewnum);
		virtual void InternalBuildCellBuf(int beginx, int beginy, void* cellinfo);
		virtual void backgroudLoadCell(int beginx, int beginy, void* cellinfo);
		void InternalBuildCellRectBuff(int x, int y, int x2, int y2) {}
		virtual void InternalClearCell(char* cell);
		void PreClearAllCell();
		void RemoveAllLayer();

		bool InitCellImage(int logicX, int logicY, CellInfo* info);
		void CreateRender();

		typedef std::vector<Layer*> LayerListType;
		typedef std::vector<CellInfo*> CellInfoListType;
		typedef std::vector<cocos2d::CCRenderTexture*> RendreTargetListType;

		LayerListType mLayerList;
		
		CellInfoListType showingCellList;
		CellInfoListType allCellList;
		RendreTargetListType mcachetargetlist;

		iBackgroundShow* mbackshow;
		cmap::iMapRender* mlayerlistrender;

		bool minitlayer;
		bool mloading_end;
		unsigned int last_tick;
		std::map<int,MapChunkImageIds> m_mapChunkImageIdsMap;
	};
}

#endif
