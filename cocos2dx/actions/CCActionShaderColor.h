/********************************************************************
	created:	2014/01/03
	created:	3:1:2014   17:46
	filename: 	E:\client\trunk\cocos2dx\actions\CCActionShaderColor.h
	file path:	E:\client\trunk\cocos2dx\actions
	file base:	CCActionShaderColor
	file ext:	h
	author:		Liu Rui
	
	purpose:	用shader改变图片的颜色值
*********************************************************************/

#ifndef CCActionShaderColor_h__
#define CCActionShaderColor_h__

#include "CCActionInterval.h"
#include "ccTypes.h"

NS_CC_BEGIN

class CC_DLL CCShaderColorFadeIn : public CCActionInterval
{
public:
	CCShaderColorFadeIn();
	virtual ~CCShaderColorFadeIn();

	static CCShaderColorFadeIn* create(float time, const ccColor3B& color);

	bool initWithDuration(float time, const ccColor3B& color);
	virtual void startWithTarget(CCNode *pTarget);

	virtual void stop(void);
	virtual void update(float time);

private:
	ccColor3B m_color;
	CCGLProgram* m_glProgram;
	GLint m_locationPercent;
	float m_percent;
};

class CC_DLL CCShaderColorFadeOut : public CCActionInterval
{
public:
	CCShaderColorFadeOut();
	virtual ~CCShaderColorFadeOut();

	static CCShaderColorFadeOut* create(float time, const ccColor3B& color);

	bool initWithDuration(float time, const ccColor3B& color);
	virtual void startWithTarget(CCNode *pTarget);

	virtual void stop(void);
	virtual void update(float time);

private:
	ccColor3B m_color;
	CCGLProgram* m_glProgram;
	GLint m_locationPercent;
	float m_percent;
};

NS_CC_END

#endif // CCActionShaderColor_h__
