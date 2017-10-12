#include "map/StructCommon.h"
#include "map/LogicBlock.h"
#include <memory>

#include "platform/CCPlatformConfig.h"
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include <stdlib.h>
#endif
namespace cmap
{
	inline int MyAbs( int x )
	{
		int t = x >> 31;
		x ^= t;
		x -= t;
		return x;
	}

	inline int MySign( int x)
	{
		int t = x >> 31;
		int t2 = -x >> 31;
		return t | -t2;
	}

	//////////////////////////////////////////////////////////////////////
	// Construction/Destruction
	//////////////////////////////////////////////////////////////////////

	LogicBlock::LogicBlock()
	{
		this->buffer = 0;
		this->bufferSize = 0;
		this->height = 0;
		this->width = 0;
	}

	LogicBlock::~LogicBlock()
	{
		if (this->buffer)
		{
			free(this->buffer);
			this->buffer = 0;
		}
		this->bufferSize = 0;
		this->width = 0;
		this->height = 0;
	}

	void LogicBlock::InitAreaLimit()
	{
		if (this->buffer == 0)
		{
			return;
		}

		::memset(this->buffer, 1, this->width);
		::memset(this->buffer + this->width * this->height - this->width, 1, this->width);
		unsigned char* first_buf = this->buffer;
		unsigned char* last_buf = this->buffer + this->width - 1;
		for (int i = 0; i < this->height; ++i)
		{
			*first_buf = 1;
			*last_buf = 1;
			first_buf += this->width;
			last_buf += this->width;
		}
	}

	inline bool LogicBlock::IsValid(const IntPoint& point) const
	{
		if( point.x < 0 || point.x >= this->width || point.y < 0 || point.y >= this->height)
		{
			return false;
		}
		return true;
	}

	bool LogicBlock::IsBlock(int x, int y) const
	{
		if( this->buffer == 0 || !IsValid(x, y) )
		{
			return true;
		}
		return this->buffer[x + y * this->width] != 0;
	}

	inline bool LogicBlock::IsValid(int x, int y) const
	{
		if( x < 0 || x >= this->width || y < 0 || y >= this->height)
		{
			return false;
		}
		return true;
	}

	bool LogicBlock::IsBlock(const IntPoint& point) const
	{
		if( this->buffer == 0 || !IsValid(point) )
		{
			return true;
		}
		return this->buffer[point.x + point.y * this->width] != 0;
	}

	inline bool LogicBlock::_IsBlock(const IntPoint& point) const
	{
		return this->buffer[point.x + point.y * this->width] != 0;
	}

	bool LogicBlock::LastNotBlock(const IntPoint& from, const IntPoint& to, IntPoint& lastNotBlock) const
	{
		if (this->buffer == 0)
		{
			return false;
		}

		int dx = from.x - to.x;
		int dy = from.y - to.y;

		int sdx = MySign(dx);
		int sdy = MySign(dy);

		dx = MyAbs(dx) * 2;
		dy = MyAbs(dy) * 2;

		lastNotBlock.x = to.x;
		lastNotBlock.y = to.y;

		if( dx >= dy )
		{
			int e = -(dx>>1) + (dy>>1);
			lastNotBlock.x += sdx;
			for(; lastNotBlock.x != to.x; lastNotBlock.x += sdx )//X方向
			{
				if( e != 0 )
					if( !_IsBlock(lastNotBlock))
						return true;

				e += dy;
				if( e > 0 )
				{
					lastNotBlock.y += sdy;
					e -= dx;
					if( !_IsBlock(lastNotBlock))
						return true;
				}
			}//for
		}
		else
		{
			int e = -(dy>>1) + (dx>>1);
			lastNotBlock.y += sdy;
			for(; lastNotBlock.y != to.y; lastNotBlock.y += sdy )//Y方向
			{
				if( e != 0 )
					if( !_IsBlock(lastNotBlock))
						return true;

				e += dx;
				if( e > 0 )
				{
					lastNotBlock.x += sdx;
					e -= dy;
					if( !_IsBlock(lastNotBlock))
						return true;
				}
			}//for
		}
		return false;
	}

	bool LogicBlock::FirstBlock(const IntPoint& from, const IntPoint& to, IntPoint& firstBlock) const
	{
		if (this->buffer == 0 
			|| from.x < 0 || from.x >= this->width || from.y < 0 || from.y >= this->height
			|| to.x < 0 || to.x >= this->width || to.y < 0 || to.y >= this->height)
		{
			return false;
		}

		int dx = to.x - from.x;
		int dy = to.y - from.y;

		int sdx = MySign(dx);
		int sdy = MySign(dy);

		dx = MyAbs(dx) * 2;
		dy = MyAbs(dy) * 2;

		firstBlock.x = from.x;
		firstBlock.y = from.y;

		if( dx >= dy )
		{
			int e = -(dx>>1) + (dy>>1);
			firstBlock.x += sdx;
			for(; firstBlock.x != to.x; firstBlock.x += sdx )//X方向
			{
				if( e != 0 )
					if( _IsBlock(firstBlock))
						return true;

				e += dy;
				if( e > 0 )
				{
					firstBlock.y += sdy;
					e -= dx;
					if( _IsBlock(firstBlock))
						return true;
				}
			}//for
		}
		else
		{
			int e = -(dy>>1) + (dx>>1);
			firstBlock.y += sdy;
			for(; firstBlock.y != to.y; firstBlock.y += sdy )//Y方向
			{
				if( e != 0 )
					if( _IsBlock(firstBlock))
						return true;

				e += dx;
				if( e > 0 )
				{
					firstBlock.x += sdx;
					e -= dy;
					if( _IsBlock(firstBlock))
						return true;
				}
			}//for
		}
		return false;
	}

	bool LogicBlock::HaveBlock(const IntPoint& from, const IntPoint& to) const
	{
		IntPoint block;
		return FirstBlock(from, to, block);
	}

	unsigned int LogicBlock::GetSizeW() const
	{
		return this->width;
	}

	unsigned int LogicBlock::GetSizeH() const
	{
		return this->height;
	}

	const unsigned char* LogicBlock::GetBlockData() const
	{
		return this->buffer;
	}
}
