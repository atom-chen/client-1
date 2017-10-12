/********************************************************************
文件名:RpgSprite.h
创建者:yangguiming
创建时间:2013-5-6 18:42
功能描述:	 RPG精灵，可以寻路, 地图遮掩
*********************************************************************/
#ifndef RpgSprite_h__
#define RpgSprite_h__

#include "RenderSprite.h"

namespace core
{

	class RpgSprite : public RenderSprite
	{
	public:
		RpgSprite();
		virtual ~RpgSprite();

		// Liu Rui，for lua
		static RpgSprite* create();
	};
}


#endif // RpgSprite_h__