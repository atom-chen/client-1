#ifndef Layer_h__
#define Layer_h__

#include <vector>
#include "map/RenderInterface.h"
#include "stream/iStream.h"
#include "resource/SFLoadResourceModule.h"
#include "map/sap/SAP.h"
namespace cmap
{
	struct renderElem;
	class Layer : public cocos2d::CCNode
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
		Layer(int layerType);
		virtual ~Layer();

		virtual bool Load(cocos2d::iStream& stream) = 0;
		virtual bool Save(cocos2d::iStream& stream) = 0;
		virtual bool SaveBlockData(cocos2d::iStream& stream) { return true; }
		bool IsMetaLayer() { return MetaLayerType == mLayerType; }

		virtual void setResourceLoadHandle(SFLoadTextureModule* resourceLoad);

	public:
		virtual void ClearAdornmentRenderInfo(renderElem* ae){};
		virtual void BuildAdornmentRenderInfo(renderElem* ae){};
	protected:
		int mLayerType;
		SFLoadTextureModule* m_map_bg_loader;
	};
}

#endif // Layer_h__
