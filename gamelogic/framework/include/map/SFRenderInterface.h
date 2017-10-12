#ifndef _SF_RENDER_INTERFACE_H_
#define _SF_RENDER_INTERFACE_H_
#include "sofia/SofiaMacro.h"
//USING_NS_CC;
NS_SF_BEGIN

class SFRenderInterface : public cocos2d::CCObject
{
public:
	SFRenderInterface(){};
	virtual ~SFRenderInterface(){};
	virtual void setRenderData(cocos2d::CCObject* data) = 0;
	virtual void draw() = 0;
protected:
private:
};

NS_SF_END
#endif