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
	class iBackgroundShow;
	class iMapRender;

	class Background : public CellGroup
	{
	public:
		Background();
		virtual~Background();

		int CreateShow(int layerNum);
		void DestroyShow();
		virtual void Destory();

		virtual bool Load(cocos2d::iStream& stream);
		virtual bool Save(cocos2d::iStream& stream);

		virtual void SetIsVisible(bool draw);
		//virtual void SetIsShowGrid(bool draw);

		virtual void SetCellImage(int imageid, int flag, int cell_x, int cell_y);
		virtual void SetCellFlag(int flag, int cell_x, int cell_y );

		void ClearCell(int cellX, int cellY);

		void gatherImageIds( int left, int top, int right, int bottom, std::set<int>& images);

		virtual void Render();
		virtual void setResourceLoadHandle(SFLoadTextureModule* resourceLoad);
		bool addSprite(cocos2d::CCNode* renderSpr, int layer);
	protected:
		virtual void InternalBuildBuf(int xbeingindex, int xviewnum, int ybeingindex, int yviewnum);
		virtual void InternalBuildCellBuf(int beginx, int beginy, void* cellinfo);
		virtual void backgroudLoadCell(int beginx, int beginy, void* cellinfo);
		virtual void InternalBuildCellRectBuff(int x, int y, int x2, int y2);
		virtual void InternalClearCell(char* cell);
		virtual void PreClearAllCell();
		virtual void CreateBuf();
		virtual void ReleaseBuf();
		//void releaseTexture(int gid);
		void removeObject(int gid, int texId);
		//交集运算。剔除出需要加载和需要卸载的内容。交集不变
		void mixedOperation(int xbeginIndex, int ybeginIndex, int xSize, int ySize);
	private:
		typedef std::vector<int> ElemInfoVector;	//暂时不支持多纹理贴图

		struct CellInfo
		{
			CellInfo()
				: flag(0), gid(-1)//, tex(NULL)
			{

			}
			int gid;
			ElemInfoVector elemInfoList;
			int flag;
		};

	private:
		typedef std::map<int, CellInfo*> CellInfoListType;
		CellInfoListType showingCellList;
		iBackgroundShow* mbackshow;

		typedef std::list<cocos2d::CCNode*> gidObjectList;
		typedef std::vector<gidObjectList> sceneGidObject;
		sceneGidObject		m_sceneObject;
	};
}

#endif
