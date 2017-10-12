#ifndef Layer_h__
#define Layer_h__

#include <vector>
#include <set>

#include "map/RenderInterface.h"
#include "stream/iStream.h"
#include "resource/SFLoadResourceModule.h"
namespace cmap
{
	//class CMapResourceLoading;
	class Layer
	{	
	public:
		enum
		{
			NullLayerType,
			TileLayerType,
			AdornmentLayerType,
			MetaLayerType,
			AreaLayerType,
		};
	public:
		static unsigned int memory_used_size;

		Layer(int layerType);
		virtual ~Layer();
		virtual void Destory() = 0;
		virtual void Render() = 0;
		virtual void SetViewSize(int width, int height) = 0;
		virtual void SetViewCenter(int x, int y) = 0;

		virtual int CreateShow(int layerNum) = 0;
		virtual void DestroyShow() = 0;

		virtual bool Load(cocos2d::iStream& stream) = 0;
		virtual bool Save(cocos2d::iStream& stream) = 0;
		virtual bool SaveBlockData(cocos2d::iStream& stream) { return true; }

		const std::string& GetName() { return mName; }
		void SetName(std::string val) { mName = val; }

		virtual bool GetIsVisible() const { return mIsVisible; }
		virtual void SetIsVisible(bool val) { mIsVisible = val; }
		cmap::iMapRender* GeRender() const { return mRender; }
		void SetRender(cmap::iMapRender* val) { mRender = val; }
		int GetLayerOrder() const { return mLayerOrder; }
		void SetLayerOrder(int val) { mLayerOrder = val; }
		int GetLayerType() const { return mLayerType; }
		void SetLayerType(int val) { mLayerType = val; }
		int GetLayerID() const { return mLayerID; }
		void SetLayerID(int val) { mLayerID = val; }
		bool IsMetaLayer() { return MetaLayerType == mLayerType; }

		void SetLayerDataSize(int dataSize) { mLayerDataSize = dataSize; };
		int GetLayerDataSize() { return mLayerDataSize; };

		virtual void gatherImageIds( int left, int top, int right, int bottom, std::set<int>& images) {}
		virtual void setResourceLoadHandle(SFLoadTextureModule* resourceLoad);
	protected:
		std::string mName;
		bool mIsVisible;

		cmap::iMapRender* mRender;
		int mLayerOrder;

		int mLayerType;

		int mLayerID;

		int mLayerDataSize;
		SFLoadTextureModule* m_map_bg_loader;
	};
}

#endif // Layer_h__
