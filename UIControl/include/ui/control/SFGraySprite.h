//
//  SFGraySprite.h
//  goddess
//
//  Created by rekoo on 13-7-23.
//
//
#ifndef __goddess__SFGraySprite__
#define __goddess__SFGraySprite__
#include "cocos2d.h"
#include "cocos-ext.h"
USING_NS_CC;
USING_NS_CC_EXT;
class SFGraySprite : public CCSprite
{
public:
	SFGraySprite();
	~SFGraySprite();

	bool initWithTexture(CCTexture2D* texture, const CCRect&  rect);
	void draw();
	void initProgram();
	void listenBackToForeground(CCObject *obj);

	static SFGraySprite* create(const char *pszFileName);

};
#endif /* defined(__goddess__SFGraySprite__) */