#ifndef _META_LAYER_H_
#define _META_LAYER_H_
#include <vector>
#include "map/CellGroup.h"

#define DRAW_META_LAYER 0
#ifdef _GAME_EDITOR
#undef DRAW_META_LAYER
#define DRAW_META_LAYER 1
#endif

namespace cocos2d
{
	class iStream;
}


typedef std::pair<int, int> IntIntPair;
typedef std::vector<IntIntPair> ColorInfoVector;

namespace cmap
{
	class LogicBlock;
	//class iMapRender;

	class MetaLayer : public CellGroup
	{
	public:
		// meta layer type
		enum
		{
			MetaBlockType = 1,
			MetaMaskType = 2,
		};
		MetaLayer();
		virtual ~MetaLayer();

		static int ver_0_flag;

	public:
		virtual int CreateShow(int layerNum);
		virtual void DestroyShow();

		virtual bool Load(cocos2d::iStream& stream);
		virtual bool Save(cocos2d::iStream& stream);
		virtual bool SaveBlockData(cocos2d::iStream& stream);

		//virtual void Render();
		virtual const unsigned char* getMetaBuf();

		unsigned char GetMetaType() const { return mMetaType; }
		void SetMetaType(unsigned char val) { mMetaType = val; }

		char* getCellBufflist(){return mcellbuflist;}
	protected:
		bool drawInfo;

		ColorInfoVector mColorInfos;
		unsigned char mMetaType;
	};
}

#endif
