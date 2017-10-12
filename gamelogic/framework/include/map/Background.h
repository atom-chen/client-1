#ifndef _MAP_BACKGROUND_H_
#define _MAP_BACKGROUND_H_
#include <vector>
#include "map/CellGroup.h"

namespace cocos2d
{
	class iStream;
}

namespace cmap
{
	struct renderElem;
	class Background : public CellGroup
	{
	public:
		Background();
		virtual~Background();

		virtual bool Load(cocos2d::iStream& stream);
		virtual bool Save(cocos2d::iStream& stream);
		virtual void setResourceLoadHandle(SFLoadTextureModule* resourceLoad);
	private:
		CCNode*		m_renderNode;
		std::map<unsigned int, renderElem*>	m_object_map;
	public:
		ArraySAP* m_sap;
		virtual void ClearAdornmentRenderInfo(renderElem* ae);
		virtual void BuildAdornmentRenderInfo(renderElem* ae);
	};
}

#endif
