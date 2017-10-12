#include "map/CellGroup.h"
#include "map/StructCommon.h"

#include <algorithm>
namespace cmap
{

	CellGroup::CellGroup()
		: Layer(TileLayerType)
		,cellSizeH(0)	,cellSizeW(0)
		,cellNumH(0)	,cellNumW(0)
		,mapSizeW(0)	,mapSizeH(0)
		,viewCenterX(0)	,viewCenterY(0)
		,viewSizeH(0)	,viewSizeW(0)
		,viewSizeWHalf(0),viewSizeHHalf(0)
		,mcellbuflist(NULL)
		,sizeofcell(0)
		,viewOrSizeChanged(true)
	{
	}

	CellGroup::~CellGroup()
	{

	}

	void CellGroup::Destory()
	{
		this->ClearAllCell();
		this->ReleaseBuf();
	}

	void CellGroup::CreateBuf()
	{
		int bufsize = this->sizeofcell * this->cellNumW * this->cellNumH;
		if (bufsize > 0)
		{
			this->mcellbuflist = (char*)malloc(bufsize);
			::memset(this->mcellbuflist, 0, bufsize);
		}
	}

	void CellGroup::ReleaseBuf()
	{
		if (this->mcellbuflist)
		{
			free(this->mcellbuflist);
			this->mcellbuflist = 0;
		}
	}

	void CellGroup::SetCellWHAndNum(int w, int h,int wnum, int hnum)
	{
		this->cellSizeW = w;
		this->cellSizeH = h;
		this->cellNumW = wnum;
		this->cellNumH = hnum;
		this->mapSizeH = this->cellSizeH * this->cellNumH;
		this->mapSizeW = this->cellSizeW * this->cellNumW;
		this->ReleaseBuf();
		this->CreateBuf();
		
		this->viewOrSizeChanged = true;

	}

	void CellGroup::SetCellWHAndMapSize(int colNum, int rowNum, int tileWidth, int tileHeight)
	{
		this->cellSizeW = tileWidth;
		this->cellSizeH = tileHeight;
		this->cellNumW = colNum;
		this->cellNumH = rowNum;
		this->mapSizeW = colNum * tileWidth;
		this->mapSizeH = rowNum * tileHeight;
		this->ReleaseBuf();
		this->CreateBuf();
		this->viewOrSizeChanged = true;
	}

	void CellGroup::SetViewCenter( int x, int y )
	{
		if (this->viewCenterX == x && this->viewCenterY == y)
		{
			return;
		}

		this->viewCenterX = x;
		this->viewCenterY = y;
		this->viewOrSizeChanged = true;
	}

	void CellGroup::SetViewSize( int w, int h )
	{
		if (this->viewSizeW == w && this->viewSizeH == h)
		{
			return ;
		}

		this->viewSizeW = w;
		this->viewSizeH = h;
		this->viewSizeWHalf = w * 0.5;
		this->viewSizeHHalf = h * 0.5;
		this->viewOrSizeChanged = true;
	}

	char* CellGroup::GetCellInfo( int cell_x, int cell_y )
	{
		if (cell_x >= this->cellNumW || cell_y >= this->cellNumH)
		{
			return 0;
		}

		return this->mcellbuflist + (cell_x + cell_y * this->cellNumW) *  this->sizeofcell;
	}

	const char* CellGroup::GetCellInfo( int cell_x, int cell_y ) const 
	{
		if (cell_x >= this->cellNumW || cell_y >= this->cellNumH)
		{
			return 0;
		}

		return this->mcellbuflist + (cell_x + cell_y * this->cellNumW) *  this->sizeofcell;
	}

	void CellGroup::ClearCell(int indexx, int indexy)
	{
		char* cellinfo = GetCellInfo(indexx, indexy);
		if (cellinfo != 0)
		{
			this->InternalClearCell(cellinfo);
			::memset(cellinfo, 0, this->sizeofcell);
		}
	}

	void CellGroup::ClearAllCell()
	{
		char* temp = this->mcellbuflist;
		if (temp)
		{
			this->PreClearAllCell();
			int num = this->cellNumH * this->cellNumW;

			for (int i = 0; i < num; ++i)
			{
				this->InternalClearCell(temp);
				temp += this->sizeofcell;
			}
			::memset(this->mcellbuflist, 0, num * this->sizeofcell);
		}
		
	}

	bool CellGroup::GetVisibleInfoX(int& viewBeginX, int& viewBeginIndixX, int& viewNumX)
	{
		viewBeginX = this->viewCenterX - this->viewSizeWHalf;
		GetViewInfo(this->cellSizeW, viewBeginX, this->viewSizeW, viewBeginIndixX, viewNumX);
		return true;
	}

	bool CellGroup::GetVisibleInfoY(int& viewBeginY, int& viewBeginIndixY, int& viewNumY)
	{
		viewBeginY = this->viewCenterY - this->viewSizeHHalf;
		GetViewInfo(this->cellSizeH, viewBeginY, this->viewSizeH, viewBeginIndixY, viewNumY);
		return true;
	}

	void CellGroup::BuildCellRectBuff(int xbeingindex, int xviewnum, int ybeingindex, int yviewnum)
	{
		int beginx = xbeingindex * this->cellSizeW;
		int endx = (xbeingindex + xviewnum) * this->cellSizeW;
		int beginy = ybeingindex * this->cellSizeH;
		int endy = (ybeingindex + yviewnum)* this->cellSizeH;
		int curx = beginx;
		for (int i = 0; i < xviewnum; ++i)
		{
			this->InternalBuildCellRectBuff(curx, beginy, curx, endy);
			curx += this->cellSizeW;
		}
		int cury = beginy;
		for (int i = 0; i < yviewnum; ++i)
		{
			this->InternalBuildCellRectBuff(beginx, cury, endx, cury);
			cury += this->cellSizeH;
		}
	}

	void CellGroup::BuildCellBuf()//生成cell的实际显示内容、;
	{
		//矩阵差
		//生成remove资源的set
		//生成loading资源的set
		//重置render的内容
		if ( this->mcellbuflist==0 )
		{
			return;
		}
		int xbeingindex = m_loadRect.getMinX();
		int xviewnum = m_loadRect.size.width;
		int ybeingindex = m_loadRect.getMinY();
		int yviewnum = m_loadRect.size.height;

		int minX = m_viewRect.getMinX() * this->cellSizeW;
		int maxX = m_viewRect.getMaxX() * this->cellSizeW;
		int minY = m_viewRect.getMinY() * this->cellSizeW;
		int maxY = m_viewRect.getMaxY() * this->cellSizeW;

		int beginy = ybeingindex * this->cellSizeH;
		for (int i = 0; i < yviewnum; ++i)
		{
			char* info = (this->mcellbuflist + ((ybeingindex + i) * this->cellNumW + xbeingindex) * this->sizeofcell);
			int beginx = xbeingindex * this->cellSizeW;
			for (int j = 0; j < xviewnum; ++j)
			{
// 				if (beginx >= minX && beginx < maxX
// 					&& beginy >= minY && beginy < maxY)
					this->InternalBuildCellBuf(beginx, beginy, info);//现在渲染的内容
// 				else
// 					this->backgroudLoadCell(beginx, beginy, info);	 //预加载的内容
				beginx += this->cellSizeW;
				info += this->sizeofcell;
			}
			beginy += this->cellSizeH;
		}
	}

	void CellGroup::InternalRender()
	{
		//这里应该计算矩阵差
		if (this->viewOrSizeChanged && this->cellNumH != 0 && this->cellNumW != 0 && this->cellSizeW != 0 && this->cellSizeH != 0)
		{
			//计算出view区域
			int viewbeginx, xbeginindex, xviewnum;
			this->GetVisibleInfoX(viewbeginx, xbeginindex, xviewnum);
			int viewbeginy, ybeginindex, yviewnum;
			this->GetVisibleInfoY(viewbeginy, ybeginindex, yviewnum);
			if(xbeginindex + xviewnum > cellNumW)
			{
				xviewnum = cellNumW - xbeginindex;
			}
			if(ybeginindex + yviewnum > cellNumH)
			{
				yviewnum = cellNumH - ybeginindex;
			}
			cocos2d::CCRect rectView = cocos2d::CCRectMake(xbeginindex,ybeginindex,xviewnum,yviewnum);
			//计算出loadview
			int viewBeginIndexX, viewNumX;
			GetViewInfo(this->cellSizeW, viewbeginx-(this->cellSizeW/2), this->viewSizeW + (this->cellSizeW/2), viewBeginIndexX, viewNumX);

			int viewBeginIndexY, viewNumY;
			GetViewInfo(this->cellSizeH, viewbeginy-(this->cellSizeH/2), this->viewSizeH + (this->cellSizeH/2), viewBeginIndexY, viewNumY);
			if(viewBeginIndexX + viewNumX > cellNumW)
			{
				viewNumX = cellNumW - viewBeginIndexX;
			}
			if(viewBeginIndexY + viewNumY > cellNumH)
			{
				viewNumY = cellNumH - viewBeginIndexY;
			}
			cocos2d::CCRect rectLoad = cocos2d::CCRectMake(viewBeginIndexX,viewBeginIndexY,viewNumX,viewNumY);
			// 对比是否有变化，有变化需要重构render的内容
			if(!m_viewRect.equals(rectView) || !m_loadRect.equals(rectLoad))
			{
				m_viewRect = rectView;
				
				this->InternalBuildBuf(viewBeginIndexX, viewNumX, viewBeginIndexY, viewNumY);
				m_loadRect = rectLoad;
			}

			this->viewOrSizeChanged = false;
		}
	}

	void CellGroup::InternalBuildBuf(int xbeingindex, int xviewnum, int ybeingindex, int yviewnum)
	{
#if DRAW_META_LAYER
		this->BuildCellRectBuff(xbeingindex, xviewnum, ybeingindex, yviewnum);
#endif
		this->BuildCellBuf();
	}

}
