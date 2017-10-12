#include "map/MetaLayer.h"
#include "map/RenderInterface.h"
#include "map/StructCommon.h"
#include "stream/BinaryReaderNet.h"
#include "stream/BinaryWriterNet.h"
#include "map/RenderInterface.h"

namespace cmap
{
	int MetaLayer::ver_0_flag = 0xffff4321;
	MetaLayer::MetaLayer()
		: mMetaType(0)
	{
		this->viewOrSizeChanged = true;
		this->sizeofcell = 1;

		//mIsShowGrid = false;
#if DRAW_META_LAYER
		mIsVisible = true;
#else
		mIsVisible = false;
#endif//DRAW_META

		mLayerType = cmap::Layer::MetaLayerType;
	}

	MetaLayer::~MetaLayer()
	{

	}

	int MetaLayer::CreateShow( int layerNum )
	{
		DestroyShow();

		SetLayerOrder(layerNum);

		SetDirty(true);

		return 2;
	}

	void MetaLayer::DestroyShow()
	{
	}

	bool MetaLayer::Load(cocos2d::iStream& stream)
	{
		Layer::Load(stream);

		cocos2d::BinaryReaderNet reader;
		reader.SetStream(&stream, false);
		if (!reader.Open() || reader.Eof())
		{
			return false;
		}

		int flag = reader.ReadUInt();
		if (flag != MetaLayer::ver_0_flag || reader.Eof())
		{
			return false;
		}
		int cellSizew_ = reader.ReadUInt();
		int cellSizeh_ = reader.ReadUInt();
		int numW_ = reader.ReadUInt();
		int numH_ = reader.ReadUInt();

		int compress = reader.ReadUShort();

		
		this->SetCellWHAndNum(cellSizew_, cellSizeh_, numW_, numH_);
		
		this->mMetaType = reader.ReadChar();


		int num = reader.ReadShort();
		for(int i = 0; i < num; i++)
		{
			int color = reader.ReadInt();
			int v = reader.ReadChar();
			this->AddColorInfo(color, v);
		}

		int buf_size = this->GetBufferSize();
		reader.ReadRawData(this->mcellbuflist, buf_size);
		this->viewOrSizeChanged = true;

		return true;
	}

	bool MetaLayer::Save(cocos2d::iStream& stream)
	{
		Layer::Save(stream);

		cocos2d::BinaryWriterNet writer;
		writer.SetStream(&stream, false);
		if (!writer.Open())
		{
			return false;
		}
		
		int buf_size = this->GetBufferSize();//w * h * sizeof(unsigned char);

		writer.WriteUInt(MetaLayer::ver_0_flag);

		writer.WriteUInt(this->cellSizeW);
		writer.WriteUInt(this->cellSizeH);
		writer.WriteUInt(this->cellNumW);
		writer.WriteUInt(this->cellNumH);
		writer.WriteUShort(0);//compress;

		writer.WriteChar(mMetaType);

		writer.WriteShort(mColorInfos.size());
		ColorInfoVector::iterator i = mColorInfos.begin();
		while(i != mColorInfos.end())
		{
			writer.WriteInt(i->first);
			writer.WriteChar(i->second);
			i++;
		}

		writer.WriteRawData(this->mcellbuflist, buf_size);
		return true;
	}

	bool MetaLayer::SaveBlockData(cocos2d::iStream& stream)
	{
		// 如果不是阻挡，处理
		if (MetaLayer::MetaBlockType != mMetaType)
		{
			return false;
		}
		return this->Save(stream);
	}

	void MetaLayer::SetIsVisible(bool drawBlock)
	{
		Layer::SetIsVisible(drawBlock);
		this->viewOrSizeChanged = true;
		if ( drawBlock )
		{
		}
		else
		{
			DestroyShow();
		}
	}
	
	void MetaLayer::SetShowInfo(bool drawInfo)
	{

	}

	bool MetaLayer::GetShowInfo() const
	{
		return this->drawInfo;
	}

	void MetaLayer::SetValueByColor(int x, int y, int color)
	{
		char* buf = this->GetCellInfo(x, y);
		if (buf == 0)
		{
			return;
		}

		IntIntPair* colorInfo = GetColorInfoByColor(color);
		if(colorInfo == NULL)
		{
			return;
		}

		*buf = colorInfo->second;
		this->viewOrSizeChanged = true;
	}

	void MetaLayer::SetValue( int x, int y, unsigned char value )
	{
		char* buf = this->GetCellInfo(x, y);
		if (buf == 0)
		{
			return;//error;
		}
		*buf = value;
		this->viewOrSizeChanged = true;
	}

	unsigned char MetaLayer::GetMetaValue( int x , int y ) const
	{
		const char* buf = this->GetCellInfo(x, y);
		if (buf == 0)
		{
			return 1;//error;
		}
		return (unsigned char)*buf;
	}

	void MetaLayer::ClearMetaValue()
	{
		this->ClearAllCell();
		this->viewOrSizeChanged = true;
	}

	bool MetaLayer::HasProblem() const
	{
		return false;
	}

	void MetaLayer::Render()
	{
		if(this->GetIsVisible())
			this->InternalRender();
	}
	
	void MetaLayer::InternalBuildBuf(int xbeingindex, int xviewnum, int ybeingindex, int yviewnum)
	{
	}

	void MetaLayer::InternalBuildCellBuf(int beginx, int beginy, void* cellinfo)
	{
	}

	void MetaLayer::InternalBuildCellRectBuff(int x, int y, int x2, int y2)
	{
	}

	void MetaLayer::InternalClearCell(char* cell)
	{

	}

	const unsigned char* MetaLayer::getMetaBuf()
	{
		return (const unsigned char*)mcellbuflist;
	}

	bool MetaLayer::AddColorInfo( int color, int v )
	{
		if(GetColorInfoByColor(color) != NULL)
		{
			return false;
		}

		if(GetColorInfoByValue(v) != NULL)
		{
			return false;
		}

		mColorInfos.push_back(IntIntPair(color, v));
		return true;
	}

	void MetaLayer::SetValues(int vfrom, int vto)
	{
		for(int i = 0; i < this->GetCellNumH(); i++)
		{
			for(int j = 0; j < this->GetCellNumW(); j++)
			{
				char* buf = GetCellInfo(j, i);
				if(*buf == vfrom)
				{
					*buf = vto;
				}
			}
		}

		SetDirty(true);
	}

	bool MetaLayer::DelColorInfoByColor( int color )
	{
		ColorInfoVector::iterator i = mColorInfos.begin();
		while(i != mColorInfos.end())
		{
			if(i->first == color)
			{
				SetValues(i->second, 0);

				mColorInfos.erase(i);
				return true;
			}
			i++;
		}

		return false;
	}

	bool MetaLayer::DelColorInfoByValue( int v )
	{
		ColorInfoVector::iterator i = mColorInfos.begin();
		while(i != mColorInfos.end())
		{
			if(i->second == v)
			{
				SetValues(i->second, 0);

				mColorInfos.erase(i);
				return true;
			}
			i++;
		}

		return false;
	}

	IntIntPair* MetaLayer::GetColorInfoByColor( int color )
	{
		ColorInfoVector::iterator i = mColorInfos.begin();
		while(i != mColorInfos.end())
		{
			if(i->first == color)
			{
				return &*i;
			}
			i++;
		}

		return NULL;
	}

	IntIntPair* MetaLayer::GetColorInfoByValue( int v )
	{
		ColorInfoVector::iterator i = mColorInfos.begin();
		while(i != mColorInfos.end())
		{
			if(i->second == v)
			{
				return &*i;
			}
			i++;
		}

		return NULL;
	}

	void MetaLayer::backgroudLoadCell( int beginx, int beginy, void* cellinfo )
	{

	}

}
