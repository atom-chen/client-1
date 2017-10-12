#ifndef _MAP_ELEM_GROUP_H_
#define _MAP_ELEM_GROUP_H_
#include <vector>
#include "map/StructCommon.h"
#include "map/Layer.h"
#include "sap/SAP.h"

namespace cmap
{
	enum ElemType
	{
		ET_Backgroud,
		ET_ElemGroup,
		ET_PlayerObject,
		ET_Size
	};

	struct renderElem
	{
		cocos2d::CCNode*		parent;
		cocos2d::CCSprite*		pSpr;
		unsigned int			sap_handle;
		ElemType				type;
	};
	
	class ElemGroup : public Layer
	{
	public:
		ElemGroup();
		virtual ~ElemGroup();
		virtual void Destory();
	public:
		void ClearAll();
	protected:
		std::map<unsigned int, renderElem*>	m_object_map;
	public:
		// 暂时只支持装饰层不跨其他层。
		virtual bool Load(cocos2d::iStream& stream);
		virtual bool Save(cocos2d::iStream& stream);
		static bool loadAdornmentGroup(cocos2d::iStream& stream);
	public:
		virtual void ClearAdornmentRenderInfo(renderElem* ae);
		virtual void BuildAdornmentRenderInfo(renderElem* ae);
	public:
		ArraySAP* m_sap;
	};
}

#endif
