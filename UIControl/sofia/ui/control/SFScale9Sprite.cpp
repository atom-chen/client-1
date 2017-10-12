#include "ui/control/SFScale9Sprite.h"
#include "ui/utils/VisibleRect.h"

SFScale9Sprite::SFScale9Sprite():m_scale9Sprite(NULL)
{
	 ignoreAnchorPointForPosition(false);
}

// SFScale9Sprite* SFScale9Sprite::createWithKey( int id,  CCRect capInsets)
// {
// 	SFScale9Sprite *pRet = new SFScale9Sprite();
// 	if (pRet != NULL && pRet->initWithKey(id, capInsets)){
// 		pRet->autorelease();
// 		return pRet;
// 	}
// 	CC_SAFE_DELETE(pRet);
// 	return NULL;
// }

SFScale9Sprite* SFScale9Sprite::createWithKey( const char* key, CCRect capInsets )
{
	SFScale9Sprite *pRet = new SFScale9Sprite();
	if (pRet != NULL){
		pRet->autorelease();
		pRet->m_scale9Sprite = CCScale9Sprite::createWithSpriteFrameName(key, capInsets);
		pRet->m_scale9Sprite->retain();
		pRet->addChild(pRet->m_scale9Sprite);
		pRet->m_scale9Sprite->setAnchorPoint(CCPointZero);
		pRet->setContentSize(pRet->m_scale9Sprite->getContentSize());
		return pRet;
	}
	CC_SAFE_DELETE(pRet);
	return NULL;	
}

// SFScale9Sprite* SFScale9Sprite::createWithTexture( TextureInfo *texture, CCRect capInsets )
// {
// 	SFScale9Sprite *pRet = new SFScale9Sprite();
// 	if (pRet != NULL && pRet->initWithTexture(texture, capInsets)){
// 		pRet->autorelease();
// 		return pRet;
// 	}
// 	CC_SAFE_DELETE(pRet);
// 	return NULL;
// }
// 
// bool SFScale9Sprite::initWithKey( int id, CCRect capInsets )
// {
// 	TextureInfo *textureInfo = GAME_RESOURCE_TEX(id);
// 	return initWithTexture(textureInfo, capInsets);
// }

// bool SFScale9Sprite::initWithTexture( TextureInfo *texture, CCRect capInsets )
// {
// 	bool bRet = false;
// 	do 
// 	{
// 		cocos2d::CCRect rect;
// 		rect.origin.x = texture->x;
// 		rect.origin.y = texture->y;
// 		rect.size.width = texture->w;
// 		rect.size.height = texture->h;
// 		CCSpriteFrame *sFrame = CCSpriteFrame::createWithTexture((CCTexture2D *)texture->tex, rect);
// 
// 		m_scale9Sprite = CCScale9Sprite::createWithSpriteFrame(sFrame, capInsets);
// 		m_scale9Sprite->setAnchorPoint(CCPointZero);
// 		m_scale9Sprite->retain();
// 		addChild(m_scale9Sprite);
// 
// 		bRet = true;
// 	
// 	} while (0);
// 
// 	return bRet;
// }

void SFScale9Sprite::setScaleSize( CCSize size )
{
	if (m_scale9Sprite)
	{
		setContentSize(size);
		m_scale9Sprite->setContentSize(size);
		VisibleRect::relativePosition(m_scale9Sprite, this);
	}
}
