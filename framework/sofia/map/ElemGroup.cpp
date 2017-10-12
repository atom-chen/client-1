#include "map/ElemGroup.h"
#include <algorithm>
#include "stream/BinaryReaderNet.h"
#include "stream/BinaryWriterNet.h"
namespace cmap
{
	ElemGroup::ElemGroup()
		: Layer(AdornmentLayerType)
		,possibleViewW(128)
		,possibleViewH(128)
		,spriteshow(NULL)
	{
	}

	ElemGroup::~ElemGroup()
	{
		this->DestroyShow();
		this->Destory();
	}

	void ElemGroup::DestroyShow()
	{
		if (mRender)
		{
			mRender->GetShowManager()->DestroySprite(spriteshow);
			spriteshow = NULL;
		}
	}

	void ElemGroup::Destory()
	{
		this->ClearAll();
	}

	void ElemGroup::ClearAll()
	{
		//清理全部的元素
		for (ElemListType::iterator itr = this->allElemList.begin(); itr != this->allElemList.end(); ++itr)
		{
			CC_SAFE_DELETE((*itr));
		}
		this->allElemList.clear();
		this->elemDirty = true;
	}

	void ElemGroup::SetViewCenter( int x, int y )
	{
		if (this->viewCenterX == x && this->viewCenterY == y)
		{
			return;
		}
		this->viewCenterX = x;
		this->viewCenterY = y;
		this->viewAreaDirty = true;
	}

	void ElemGroup::SetViewSize( int w, int h )
	{
		this->viewSizeWHalf = w * 0.5;
		this->viewSizeHHalf = h * 0.5;
		this->viewAreaDirty = true;
	}

	void ElemGroup::CheckPossibleListRender()
	{
		if (this->GetIsVisible())
		{
			this->viewArea.left = this->viewCenterX - this->viewSizeWHalf;
			this->viewArea.top = this->viewCenterY - this->viewSizeHHalf;
			this->viewArea.right = this->viewCenterX + this->viewSizeWHalf;
			this->viewArea.bottom = this->viewCenterY + this->viewSizeHHalf;
			this->OnSetViewBegin(this->viewArea.left, this->viewArea.top);
			if (!this->possibleViewArea.IsInclude(this->viewArea))
			{
				this->possibleViewArea.left = this->viewArea.left - this->possibleViewW;
				this->possibleViewArea.right = this->viewArea.right + this->possibleViewW;
				this->possibleViewArea.top = this->viewArea.top - this->possibleViewH;
				this->possibleViewArea.bottom = this->viewArea.bottom + this->possibleViewH;
				for (ElemListType::iterator itr = this->allElemList.begin(); itr != this->allElemList.end(); ++itr)
				{
					ElemBase* m = *itr;
					if (m->Intersect(this->possibleViewArea))
					{
						if(!m->isOnDraw())
						{
							m->setOnDraw(true);
							this->OnElemRender(m);
						}
					}
					else
					{
						if (m->isOnDraw())
						{
							m->setOnDraw(false);
							this->ClearAdornmentRenderInfo((AdornmentElem*)m);
						}
					}
				}	
			}
		}
	}

	int ElemGroup::CreateShow( int layerId )
	{
		DestroyShow();
		if (mRender)
		{
			spriteshow = mRender->GetShowManager()->CreateSprite(layerId);
			SetLayerOrder(layerId);
		}
		SetDirty(true);

		return 3;
	}

	bool ElemGroup::Load( cocos2d::iStream& stream )
	{
		Layer::Load(stream);

		cocos2d::BinaryReaderNet reader;
		reader.SetStream(&stream, false);
		if (!reader.Open() || reader.Eof())
		{
			return false;
		}

		int adornNum = reader.ReadUInt();
		this->ClearAll();
		for (int i = 0; i < adornNum; ++i)
		{
			int imageid = reader.ReadInt();
			if(!cmap::iMapFactory::inst->GetImageSetInfo()->checkStaticImagePath(imageid))
			{
				// fixme
				reader.ReadInt();
				reader.ReadInt();
				reader.ReadInt();
				reader.ReadInt();
				reader.ReadInt();
				reader.ReadInt();
				reader.ReadInt();
				reader.ReadInt();
				continue;
			}
			AdornmentElem* ae = new AdornmentElem();
			ae->SetImageId(imageid);
			ae->SetDrawType(reader.ReadInt());
			ae->SetFlag(reader.ReadInt());
			int basisx = reader.ReadInt();
			int basisy = reader.ReadInt();
			ae->SetBasis(basisx, basisy);
			int posx = reader.ReadInt();
			int posy = reader.ReadInt();
			ae->SetPos(posx, posy);
			int width = reader.ReadInt();
			int height = reader.ReadInt();
			ae->SetWH(width,height);
			ae->BuildArea();
			this->allElemList.push_back(ae);
		}
		this->possibleViewArea.Empty();
		this->elemDirty = true;
		this->viewAreaDirty = true;
		return true;
	}

	bool ElemGroup::Save( cocos2d::iStream& stream )
	{
		Layer::Save(stream);

		cocos2d::BinaryWriterNet writer;
		writer.SetStream(&stream, false);
		if (!writer.Open())
		{
			return false;
		}

		writer.WriteUInt(this->allElemList.size());
		for (ElemListType::iterator itr = this->allElemList.begin(); itr != this->allElemList.end(); ++itr)
		{
			ElemBase* eb = *itr;
			AdornmentElem* ae = (AdornmentElem*)eb;
			writer.WriteInt(ae->GetImageId());// = reader.ReadInt();
			writer.WriteInt(ae->GetDrawType());// = reader.ReadInt();
			writer.WriteInt(ae->GetFlag());// = reader.ReadInt();
			writer.WriteInt(ae->GetBasisX());// = reader.ReadInt();
			writer.WriteInt(ae->GetBasisY());// = reader.ReadInt();
			writer.WriteInt(ae->GetPosX());// = reader.ReadInt();
			writer.WriteInt(ae->GetPosY());// = reader.ReadInt();
			writer.WriteInt(ae->GetWidth());// = reader.ReadInt();
			writer.WriteInt(ae->GetHeight());// = reader.ReadInt();
		}

		return true;
	}

	bool ElemGroup::loadAdornmentGroup( cocos2d::iStream& stream )
	{
		int pos = stream.GetPosition();
		cocos2d::BinaryReaderNet reader;
		reader.SetStream(&stream, false);
		if (!reader.Open())
		{
			return false;
		}

		int LayerType = reader.ReadChar();
		int mLayerID = reader.ReadShort();

		char buf[1024] = {0};
		reader.ReadString(buf, 1024);
		std::string Name = buf;

		int adornNum = reader.ReadUInt();

		if (adornNum <= 0)
		{
			return false;
		}
		stream.Seek(pos, cocos2d::iStream::Begin);
		return true;
	}

	void ElemGroup::Render()
	{
		if (this->viewAreaDirty || this->elemDirty)
		{
			this->CheckPossibleListRender();
		}
		this->viewAreaDirty = false;
		this->elemDirty = false;
	}

	void ElemGroup::SetIsVisible( bool val )
	{
		if(GetIsVisible() == val)
			return;

		Layer::SetIsVisible(val);
		SetDirty(true);
	}

	void ElemGroup::OnSetViewBegin( int beginx, int beginy )
	{
		CC_ASSERT(spriteshow!=NULL);
		spriteshow->SetViewbegin(beginx, beginy);
	}

	void ElemGroup::OnElemRender( ElemBase* eb )
	{
		AdornmentElem* ae = (AdornmentElem*)eb;
		this->ClearAdornmentRenderInfo(ae);
		this->BuildAdornmentRenderInfo(ae);
	}

	void ElemGroup::ClearAdornmentRenderInfo( AdornmentElem* ae )
	{
		if (spriteshow && ae->getSpriteShowCell() != 0)
		{
			spriteshow->Release(ae->getSpriteShowCell());
			ae->setSpriteShowCell(NULL);
		}
	}

	void ElemGroup::BuildAdornmentRenderInfo( AdornmentElem* ae )
	{
		iSpriteShowCell* cell = spriteshow->CreateCell();
		ae->setSpriteShowCell(cell);
		cell->SetPos(ae->GetPosX(), ae->GetPosY());
		cell->CreateId(0, ae->GetDrawType(), ae->GetFlag(), ae->GetImageId(), ae->GetBasisX(), ae->GetBasisY());
	}
	//////////////////////////////////////////////////////////////////////////
	AreaElemBase::AreaElemBase()
		:dirty(true)
	{
		area.left = 0;
		area.top = 0;
		area.right = 0;
		area.bottom = 0;
	}

	AreaElemBase::~AreaElemBase()
	{

	}

	bool AreaElemBase::Intersect(const IntRect& r)
	{
		return this->area.IsIntersect(r);
	}

	bool AreaElemBase::Intersect(int x, int y)
	{
		return this->area.IsIntersect(x, y);
	}

	PosElemBase::PosElemBase()
		:posx(0),posy(0)
		,width(0),height(0)
	{

	}
	PosElemBase::~PosElemBase()
	{

	}
	void PosElemBase::BuildArea()
	{
		int hw = this->width / 2;
		int hh = this->height / 2;
		this->area.left = this->posx - hw;
		this->area.top = this->posy - hh;
		this->area.right = this->area.left + hw;
		this->area.bottom = this->area.top + hh;
		this->dirty = true;
	}

	BasisPosWHElemBase::BasisPosWHElemBase()
		:basisx(0),basisy(0)
	{
	}

	BasisPosWHElemBase::~BasisPosWHElemBase()
	{

	}

	AdornmentElem::AdornmentElem()
		:rendershowcell(0)
		,imageid(0)
		,drawflag(0)
		,drawtype(0xff)
	{
	}

	AdornmentElem::~AdornmentElem()
	{

	}

	void AdornmentElem::BuildArea()
	{
		this->area.left = this->posx - this->basisx;
		this->area.top = this->posy - this->basisy;
		this->area.right = this->area.left + this->width * this->GetScaleFloat();
		this->area.bottom = this->area.top + this->height * this->GetScaleFloat();
		this->dirty = true;
	}
	float AdornmentElem::GetScaleFloat()
	{
		return iImage::GetScaleFromFlag(this->drawflag);
	}
}
