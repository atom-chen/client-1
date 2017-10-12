#ifndef __SFSCALE9SPRITE_H__
#define __SFSCALE9SPRITE_H__

#include "SFBaseControl.h"


class SFScale9Sprite: public SFBaseControl{

public:
	SFScale9Sprite();
	virtual ~SFScale9Sprite(){
		CC_SAFE_RELEASE_NULL(m_scale9Sprite);
	}

	static SFScale9Sprite* createWithKey(const char* key,  CCRect capInsets=CCRectZero);
	CCSize getSize(){ return m_scale9Sprite->getContentSize();};
	void setScaleSize(CCSize size);

private:
	CCScale9Sprite *m_scale9Sprite;

};


#endif	//__SFSCALE9SPRITE_H__

