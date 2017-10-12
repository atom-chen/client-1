#include <memory>
#include "stream/iStream.h"
#include "stream/MemoryStream.h"
#include "stream/BinaryReader.h"
#include "map/Mask.h"


namespace cmap
{
	Mask::Mask():buffer(0), bufferSize(0), width(0),height(0)
	{

	}

	Mask::~Mask()
	{
		if (this->buffer)
		{
			delete buffer;
		}
	}

	void Mask::ReloadMask( cocos2d::MemoryStream& stream )
	{
		cocos2d::BinaryReader reader;
		reader.SetStream(&stream, false);
		if (!reader.Open() || reader.Eof())
		{
			return ;
		}

		if (this->buffer)
		{
			delete buffer;
			buffer = 0;
		}

		this->width = reader.ReadInt();
		this->height = reader.ReadInt();
		this->bufferSize = reader.ReadInt();

		if (this->width && this->height)
		{
			this->buffer = new unsigned char[this->bufferSize];
			reader.ReadRawData(this->buffer, this->bufferSize);
		}
	}

	bool Mask::IsMask( int x, int y )
	{
		if( this->buffer == 0 || !IsValid(x, y) )
		{
			return false;
		}
		return this->buffer[x + y * this->width] != 0;
	}

	bool Mask::IsValid( int x, int y )
	{
		if( x < 0 || x >= this->width || y < 0 || y >= this->height)
		{
			return false;
		}
		return true;
	}

}

