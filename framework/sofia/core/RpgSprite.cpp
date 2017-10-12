#include "core/RenderScene.h"
#include "core/RpgSprite.h"

using namespace cmap;


USING_NS_CC;
namespace core
{

	RpgSprite::RpgSprite()
	{
	}

	RpgSprite::~RpgSprite()
	{
	}

	RpgSprite* RpgSprite::create()
	{
		RpgSprite* spr = new RpgSprite();
		spr->autorelease();
		return spr;
	}

}