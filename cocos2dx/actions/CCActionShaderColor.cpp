#include "CCActionShaderColor.h"
#include "shaders/CCShaderCache.h"

NS_CC_BEGIN

CCShaderColorFadeIn::CCShaderColorFadeIn():m_glProgram(NULL), m_percent(0)
{

}

CCShaderColorFadeIn::~CCShaderColorFadeIn()
{
	CC_SAFE_RELEASE_NULL(m_glProgram);
}

CCShaderColorFadeIn* CCShaderColorFadeIn::create( float time, const ccColor3B& color )
{
	CCShaderColorFadeIn* ret = new CCShaderColorFadeIn();
	ret->initWithDuration(time, color);
	ret->autorelease();
	return ret;
}

bool CCShaderColorFadeIn::initWithDuration( float time, const ccColor3B& color )
{
	if (CCActionInterval::initWithDuration(time))
	{
		m_color = color;
		return true;
	}
	else
	{
		return false;
	}
}

void CCShaderColorFadeIn::startWithTarget( CCNode *pTarget )
{
	CCActionInterval::startWithTarget(pTarget);

	if (pTarget)
	{
		m_glProgram = CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureMixColor);
		m_glProgram->retain();
		m_pTarget->setShaderProgram(m_glProgram);

		m_glProgram->use();
		GLint locationColor = m_glProgram->getUniformLocationForName("u_mixColor");
		m_locationPercent = m_glProgram->getUniformLocationForName("u_percent");

		m_glProgram->setUniformLocationWith1f(m_locationPercent, m_percent);
		m_glProgram->setUniformLocationWith3f(locationColor, m_color.r*1.0f/255, m_color.g*1.0f/255, m_color.b*1.0f/255);
	}
}

void CCShaderColorFadeIn::stop( void )
{
	if (m_pTarget)
	{
		CC_SAFE_RELEASE_NULL(m_glProgram);
		m_glProgram = CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor);
		m_pTarget->setShaderProgram(m_glProgram);
		m_glProgram = NULL;
	}

	CCActionInterval::stop();
}

void CCShaderColorFadeIn::update( float dt )
{
	if (m_glProgram)
	{
		m_glProgram->use();
		m_glProgram->setUniformLocationWith1f(m_locationPercent, dt);

		GLint locationColor = m_glProgram->getUniformLocationForName("u_mixColor");
		m_glProgram->setUniformLocationWith3f(locationColor, m_color.r*1.0f/255, m_color.g*1.0f/255, m_color.b*1.0f/255);
	}
}


CCShaderColorFadeOut::CCShaderColorFadeOut():m_glProgram(NULL), m_percent(1)
{

}

CCShaderColorFadeOut::~CCShaderColorFadeOut()
{
	CC_SAFE_RELEASE_NULL(m_glProgram);
}

CCShaderColorFadeOut* CCShaderColorFadeOut::create( float time, const ccColor3B& color )
{
	CCShaderColorFadeOut* ret = new CCShaderColorFadeOut();
	ret->initWithDuration(time, color);
	ret->autorelease();
	return ret;
}

bool CCShaderColorFadeOut::initWithDuration( float time, const ccColor3B& color )
{
	if (CCActionInterval::initWithDuration(time))
	{
		m_color = color;
		return true;
	}
	else
	{
		return false;
	}
}

void CCShaderColorFadeOut::startWithTarget( CCNode *pTarget )
{
	CCActionInterval::startWithTarget(pTarget);

	if (pTarget)
	{
		m_glProgram = CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureMixColor);
		m_glProgram->retain();
		
		GLint locationColor = m_glProgram->getUniformLocationForName("u_mixColor");
		m_locationPercent = m_glProgram->getUniformLocationForName("u_percent");

		m_glProgram->setUniformLocationWith1f(m_locationPercent, m_percent);
		m_glProgram->setUniformLocationWith3f(locationColor, m_color.r*1.0f/255, m_color.g*1.0f/255, m_color.b*1.0f/255);

		m_pTarget->setShaderProgram(m_glProgram);
	}
}

void CCShaderColorFadeOut::stop( void )
{
	if (m_pTarget)
	{
		CC_SAFE_RELEASE_NULL(m_glProgram);
		m_glProgram = CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor);
		m_pTarget->setShaderProgram(m_glProgram);
		m_glProgram = NULL;
	}

	CCActionInterval::stop();
}

void CCShaderColorFadeOut::update( float dt )
{
	if (m_glProgram)
	{
		m_glProgram->use();
		m_glProgram->setUniformLocationWith1f(m_locationPercent, 1-dt);

		GLint locationColor = m_glProgram->getUniformLocationForName("u_mixColor");
		m_glProgram->setUniformLocationWith3f(locationColor, m_color.r*1.0f/255, m_color.g*1.0f/255, m_color.b*1.0f/255);
	}
}

NS_CC_END