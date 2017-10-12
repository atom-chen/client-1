#ifndef _MAP_ELEM_GROUP_H_
#define _MAP_ELEM_GROUP_H_
#include <vector>
#include "map/StructCommon.h"
#include "map/Layer.h"
namespace cmap
{
	class ElemGroup;
	class ElemBase;
	class AdornmentElem;

	class ElemGroup : public Layer
	{
	public:
		ElemGroup();
		virtual ~ElemGroup();

		typedef std::vector<ElemBase*> ElemListType;
		virtual void Destory();
	public:
		void SetPossibleWH(int w, int h) { this->possibleViewW = w; this->possibleViewH = h;}
		bool GetDirty() const { return this->viewAreaDirty;}
		void SetDirty(bool d) { this->viewAreaDirty = d;}

		void SetViewCenter(int x, int y);
		void SetViewSize(int w, int h);
		
		void ClearAll();

	protected:
		virtual void CheckPossibleListRender();
		virtual void OnElemRender(ElemBase* eb);
		
	protected:
		IntRect viewArea;
		IntRect possibleViewArea;
		ElemListType allElemList;

		int viewCenterX;
		int viewCenterY;
		int viewSizeWHalf;
		int viewSizeHHalf;
		int possibleViewW;
		int possibleViewH;
		bool viewAreaDirty;
		bool elemDirty;
	public:
		int CreateShow(int layerId);
		void DestroyShow();
		virtual bool Load(cocos2d::iStream& stream);
		virtual bool Save(cocos2d::iStream& stream);
		static bool loadAdornmentGroup(cocos2d::iStream& stream);

		virtual void Render();
		virtual void SetIsVisible(bool val);
		virtual void OnSetViewBegin(int beginx, int beginy);

	private:
		void ClearAdornmentRenderInfo(AdornmentElem* ae);
		void BuildAdornmentRenderInfo(AdornmentElem* ae);

	private:
		cmap::iSpriteShow* spriteshow;
	};

	class ElemBase
	{
	public:
		ElemBase() : m_draw(false) {}
		virtual ~ElemBase() {}

		virtual bool Intersect(const IntRect& r) = 0;
		virtual bool Intersect(int x, int y) = 0;
		virtual void BuildArea() {}	
		virtual bool GetDirty() const = 0;
		virtual void SetDirty(bool dirty_) = 0;
		
		void setOnDraw(bool bDraw){ m_draw = bDraw;};
		bool isOnDraw() const { return m_draw;}
	protected:
		bool m_draw;
	};

	class AreaElemBase : public ElemBase
	{
	public:
		AreaElemBase();
		virtual ~AreaElemBase();
		virtual bool Intersect(const IntRect& r);
		virtual bool Intersect(int x, int y);

		const IntRect& GetRect() { return this->area; }
		virtual bool GetDirty() const { return this->dirty;}
		virtual void SetDirty(bool dirty_) {this->dirty = dirty_;}
		//virtual int GetDistancePower(int x, int y);
	protected:
		IntRect area;
		bool dirty;
	};

	class PosElemBase : public AreaElemBase
	{
	public:
		PosElemBase();
		virtual ~PosElemBase();

		//virtual int GetDistancePower(int x, int y);

		void SetPos(int x, int y) { this->posx = x; this->posy = y;}
		int GetPosX() { return this->posx;}
		int GetPosY() { return this->posy;}
		int GetWidth() const {return this->width;}
		int GetHeight() const {return this->height;}
		void SetWH(int w, int h) { this->width = w;this->height = h;}
		virtual void BuildArea();
	protected:
		int posx;
		int posy;
		int width;
		int height;
	};

	class BasisPosWHElemBase : public PosElemBase
	{
	public:
		BasisPosWHElemBase();
		virtual ~BasisPosWHElemBase();

		void SetBasis(int x, int y) { this->basisx = x; this->basisy = y;}
		int GetBasisX() { return this->basisx;}
		int GetBasisY() { return this->basisy;}
	protected:
		int basisx;
		int basisy;
		friend class ElemGroup;
	};
	class AdornmentElem : public BasisPosWHElemBase
	{
	public:
		AdornmentElem();
		virtual ~AdornmentElem();

		void BuildArea();
		float GetScaleFloat();

		void SetImageId(int imageid_) { this->imageid = imageid_; this->dirty = true;}
		int GetImageId() { return this->imageid;}
		void SetDrawType(int drawtype_) { this->drawtype = drawtype_; this->dirty = true;}
		int GetDrawType() { return this->drawtype;}
		void SetFlag(int flag_) { this->drawflag = flag_; this->dirty = true;}
		int GetFlag() { return this->drawflag;}
		void SetLayer(int layer_);
		int GetLayer() const { return 0;}

		void setSpriteShowCell(iSpriteShowCell* cell){rendershowcell = cell;}
		iSpriteShowCell* getSpriteShowCell(){return rendershowcell;}
	protected:
		int imageid;
		int drawtype;//alphamodify 0x0ff; colormodify 0x0ff00;
		int drawflag;//xyturn 0x03; scale 0x0ff00; blendFun 0x0ff0000; blendEquationExt 0x07000000
		iSpriteShowCell* rendershowcell;
	};
}

#endif
