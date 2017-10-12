#ifndef _MAP_GRID_COMMON_H_
#define _MAP_GRID_COMMON_H_
#include <vector>
#include "map/Layer.h"
#include "cocos2d.h"
namespace cmap
{
	class CellGroup : public Layer
	{
	public:
		CellGroup();
		virtual ~CellGroup();

		virtual void Destory();
		void SetCellWHAndNum(int w, int h,int wnum, int hnum);

		void ClearAllCell();
		int GetCellNumW() const { return this->cellNumW;}
		int GetCellNumH() const { return this->cellNumH;}
		int GetBufferSize() const { return this->cellNumW * this->cellNumH * this->sizeofcell;}
	protected:

		char* GetCellInfo(int index, int indexy);
		const char* GetCellInfo(int index, int indexy) const;
	
		virtual void CreateBuf();
		virtual void ReleaseBuf();

	protected:
		char* mcellbuflist;
		int sizeofcell;
		int cellNumW;
		int cellNumH;
		int cellSizeW;
		int cellSizeH;
	};
}

#endif
