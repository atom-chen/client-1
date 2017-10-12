#ifndef _MAP_ADORNMENT_H_
#define _MAP_ADORNMENT_H_
#include <vector>
#include "map/ElemGroup.h"
namespace cocos2d
{
	class iStream;
}

namespace cmap
{
	class iMapRender;
	class iSpriteShowCell;
	class iSpriteShow;
	class iRectShow;
}

namespace cmap
{
	class AdornmentGroup;
	class iMapRender;

	class AdornmentElem : public BasisPosWHElemBase
	{
	public:
		AdornmentElem(AdornmentGroup* owner);
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

		AdornmentGroup* owner;
		iSpriteShowCell* rendershowcell;
	};

	class AdornmentGroup : public ElemGroup
	{
	public:
		AdornmentGroup();
		~AdornmentGroup();

		enum
		{
			FarLayer = 0,
			BackSurfaceLayer,
			MiddleSurfaceLayer,
			TopSurfaceLayer,
			SpriteLayer,
			FrontLayer,
			LayerNum,
		};
	public:
		//void Init(cmap::iMapRender* maprender, int farlayer, int backlayer, int middlelayer, int frontlayer);
		int CreateShow(int layerId);
		void DestroyShow();
		virtual bool Load(cocos2d::iStream& stream);
		virtual bool Save(cocos2d::iStream& stream);
		static bool loadAdornmentGroup(cocos2d::iStream& stream);
		virtual ElemBase* Create();
		virtual bool Release(ElemBase* eb);

		virtual void Render();
		
		virtual void SetIsVisible(bool val);

		void gatherImageIds( int left, int top, int right, int bottom, std::set<int>& images);

		virtual void OnSetViewBegin(int beginx, int beginy);
		virtual void OnBeforeRemoveElem(ElemBase* eb);
		virtual void OnBeforeAddElem(ElemBase* eb);
		virtual void OnElemGotoPossibleList(ElemBase* eb);
		virtual void OnElemNoInPossibleList(ElemBase* eb);
		virtual void OnBeforeElemRender(ElemBase* eb);
		virtual void OnElemRender(ElemBase* eb);
		virtual void OnElemLostRender(ElemBase* eb);
	private:
		void ClearAdornmentRenderInfo(AdornmentElem* ae);
		void BuildAdornmentRenderInfo(AdornmentElem* ae);

	private:
		cmap::iSpriteShow* spriteshow;
	};
}

#endif
