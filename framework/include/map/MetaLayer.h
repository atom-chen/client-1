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
	//namespace eng
	//{
		class iStream;
	//}
}


typedef std::pair<int, int> IntIntPair;
typedef std::vector<IntIntPair> ColorInfoVector;

namespace cmap
{
	//class iRectShow;
	//class iLineShow;
	class LogicBlock;
	class iMapRender;

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

		//virtual void SetIsShowGrid(bool drawGrid);
		virtual void SetIsVisible(bool drawBlock);
		virtual void SetShowInfo(bool drawInfo);

		virtual bool GetShowInfo() const;

		void SetValueByColor(int x, int y, int color);
		virtual void SetValue(int x, int y, unsigned char value);

		virtual unsigned char GetMetaValue(int x , int y) const;
		virtual void ClearMetaValue();

		virtual bool HasProblem() const;

		virtual void Render();
		virtual const unsigned char* getMetaBuf();

		bool AddColorInfo(int color, int v);
		void SetValues(int vfrom, int vto);
		bool DelColorInfoByColor(int color);
		bool DelColorInfoByValue(int v);
		IntIntPair* GetColorInfoByColor(int color);
		IntIntPair* GetColorInfoByValue(int v);
		ColorInfoVector& GetColorInfos() { return mColorInfos; }

		unsigned char GetMetaType() const { return mMetaType; }
		void SetMetaType(unsigned char val) { mMetaType = val; }

		char* getCellBufflist(){return mcellbuflist;}
	protected:
		virtual void InternalBuildBuf(int xbeingindex, int xviewnum, int ybeingindex, int yviewnum);
		virtual void InternalBuildCellBuf(int beginx, int beginy, void* cellinfo);
		virtual void backgroudLoadCell(int beginx, int beginy, void* cellinfo);
		virtual void InternalBuildCellRectBuff(int x, int y, int x2, int y2);
		virtual void InternalClearCell(char* cell);
	private:
		void BuildRenderBuffer();
		void BuildBlockBuffer(int xbeingindex, int xviewnum, int ybeingindex, int yviewnum);

	protected:
		//iRectShow* mrectshow;
		//iLineShow* mlineshow;

		bool dirty;

		bool drawInfo;

		ColorInfoVector mColorInfos;
		unsigned char mMetaType;
	};
}

#endif
