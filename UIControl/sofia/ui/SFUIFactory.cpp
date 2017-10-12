#include "ui/SFUIFactory.h"
#include "ui/control/SFControlDef.h"

static SFUIFactory* s_UIFactory = NULL;
SFUIFactory* SFUIFactory::sharedUIFactory()
{
	if (s_UIFactory == NULL){
		s_UIFactory = new SFUIFactory();
		s_UIFactory->init();
	}
	return s_UIFactory;
}

bool SFUIFactory::init()
{
	return true;
}

cocos2d::CCMenuItem* SFUIFactory::createMenuItem( const char* key )
{

	CCSprite *spr1 = CCSprite::createWithSpriteFrameName(key);
	CCSprite *spr2 = CCSprite::createWithSpriteFrameName(key);

	return (CCMenuItem *)CCMenuItemSprite::create(spr1, spr2);

}

SFScale9Sprite* SFUIFactory::createScale9Sprite( const char* key, CCSize size, CCRect capInsets )
{
	if (!capInsets.equals(CCRectZero))
	{
		CCSpriteFrame *frame = CCSpriteFrameCache::sharedSpriteFrameCache()->spriteFrameByName(key);
		if (frame)
		{
			capInsets.origin.x = frame->getRect().origin.x+capInsets.origin.x;
			capInsets.origin.y = frame->getRect().origin.y+capInsets.origin.y;
		}
	}

	SFScale9Sprite* sprite = SFScale9Sprite::createWithKey(key, capInsets);
	sprite->setScaleSize(size);
	return sprite;
}

SFGridBox* SFUIFactory::createGridBox( unsigned column, CCSize gridSize, int count, int margin/*=1*/ )
{
	SFGridBox *box = SFGridBox::create(column, gridSize);
	box->addGrid(count);
	box->setAllMargin(margin);
	box->setContentSize(box->getSize());
	return box;
}

SFTableView* SFUIFactory::createTableView( SFTableViewDataSource* dataSource, CCSize size )
{
	return SFTableView::create(dataSource, size);
}


SFLabel* SFUIFactory::createLabel( const char* str, const char* fontName, int fontSize /*= TITLE_FONT_SIZE*/, ccColor3B color /*= ccBLACK*/ )
{
	return SFLabel::create(str, fontName, fontSize, color);
}

CCRenderTexture * SFUIFactory::createTexture( CCSize size, CCNode *node, ... )
{
	CCRenderTexture *rt = CCRenderTexture::create((int)size.width, (int)size.height);
	rt->begin();

	va_list args;
	va_start(args,node);
	node->visit();
	CCNode *i = va_arg(args, CCNode*);
	while(i){
		i->visit();
		i = va_arg(args, CCNode*);
	}
	va_end(args);

	rt->end();
	return rt;
}

CCRenderTexture * SFUIFactory::createTexture( CCSize size, CCArray *nodes )
{
	CCRenderTexture *rt = CCRenderTexture::create((int)size.width, (int)size.height);
	rt->begin();

	CCObject *obj = NULL;
	CCARRAY_FOREACH(nodes, obj){
		CCNode *nd = (CCNode *)obj;
		nd->visit();
	}

	rt->end();
	return rt;
}

CCProgressTimer * SFUIFactory::createProgress( const char* key, CCSize size, CCProgressTimerType type )
{
	CCSprite *sprite = CCSprite::createWithSpriteFrameName(key);	
	CCProgressTimer *progress = CCProgressTimer::create(sprite);
	if(size.width>1){
		progress->setScaleX(size.width/progress->getContentSize().width);
		progress->setScaleY(size.height/progress->getContentSize().height);
	}
	
	progress->setType(type);
	progress->setMidpoint(ccp(0, progress->getContentSize().height));
	progress->setBarChangeRate(ccp(1,0));
	progress->setPercentage(100.0f);
	return progress;
}

SFScrollView* SFUIFactory::createScrollView()
{
	return SFScrollView::create();
}

SFJoyRocker* SFUIFactory::createJoyRocker( CCSprite *joy, CCSprite *joyBg, float radius/*=50*/, bool isFollow/*=false*/ )
{
	if(radius == 0)
		radius = 50*VisibleRect::SFGetScale();
	SFJoyRocker *joyRocker = SFJoyRocker::JoyRockerWithCenter(radius, joy, joyBg, isFollow);
	return joyRocker;
}

SFRichBox* SFUIFactory::createRichBox( CCSize dimensions )
{
	SFRichBox* ctl = SFRichBox::create();
	ctl->setDimensions(dimensions);
	return ctl;
}

SFCheckBox* SFUIFactory::createCheckBox( const char* normal, const char* select )
{
	SFCheckBox* m_checkBox = SFCheckBox::create(normal, select);
	return m_checkBox;
}
