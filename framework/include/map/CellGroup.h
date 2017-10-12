#ifndef _MAP_GRID_COMMON_H_
#define _MAP_GRID_COMMON_H_
#include <vector>
#include "map/Layer.h"
#include "cocos2d.h"
namespace cmap
{
	//class cocos2d::CCRect;
	class CellGroup : public Layer
	{
	public:
		CellGroup();
		~CellGroup();

		virtual void Destory();
		void SetCellWHAndNum(int w, int h,int wnum, int hnum);
		void SetCellWHAndMapSize(int colNum, int rowNum, int tileWidth, int tileHeight);
		void SetViewCenter(int x, int y);
		void SetViewSize(int w, int h);

		void ClearCell(int indexx, int indexy);
		void ClearAllCell();
		int GetCellNumW() const { return this->cellNumW;}
		int GetCellNumH() const { return this->cellNumH;}
		int GetCellSizeW() const { return this->cellSizeW;}
		int GetCellSizeH() const { return this->cellSizeH;}
		int GetMapSizeW() const { return this->mapSizeW;}
		int GetMapSizeH() const { return this->mapSizeH;}
		int GetBufferSize() const { return this->cellNumW * this->cellNumH * this->sizeofcell;}
		bool GetDirty() const { return this->viewOrSizeChanged;}
		void SetDirty(bool d) { this->viewOrSizeChanged = d;}

	protected:

		char* GetCellInfo(int index, int indexy);
		const char* GetCellInfo(int index, int indexy) const;
	
		bool GetVisibleInfoX(int& viewBeginX, int& viewBeginIndixX, int& viewNumX);
		bool GetVisibleInfoY(int& viewBeginY, int& viewBeginIndixY, int& viewNumX);
		
		void BuildCellRectBuff(int xbeingindex, int xviewnum, int ybeingindex, int yviewnum);
		void BuildCellBuf();

		virtual void InternalRender();
		virtual void InternalBuildBuf(int xbeingindex, int xviewnum, int ybeingindex, int yviewnum);
		virtual void InternalBuildCellBuf(int beginx, int beginy, void* cellinfo) = 0;
		virtual void backgroudLoadCell(int beginx, int beginy, void* cellinfo) = 0;
		virtual void InternalBuildCellRectBuff(int x, int y, int x2, int y2) = 0;
		virtual void InternalClearCell(char* cell) {};
		virtual void PreClearAllCell() {};
		virtual void CreateBuf();
		virtual void ReleaseBuf();

	protected:
		char* mcellbuflist;
		int sizeofcell;
		int mapSizeW;
		int mapSizeH;
		int cellNumW;
		int cellNumH;
		int cellSizeW;
		int cellSizeH;
		int viewCenterX;
		int viewCenterY;
		int viewSizeW;
		int viewSizeH;
		int viewSizeWHalf;
		int viewSizeHHalf;
		bool viewOrSizeChanged;

		cocos2d::CCRect	m_viewRect;
	public:
		cocos2d::CCRect m_loadRect;
	};
}

#endif
