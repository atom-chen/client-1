#include "ui/control/SFLabelTex.h"
#include "ui/control/SFSharedFontManager.h"



bool SFLabelTex::updateShowNode()
{

	CCRect box;
	box.size = getShowingDimension();
	box.origin = CCPointZero;
	//更新batch node 应该显示的精灵

	CCSize change =SFSharedFontManager::sharedSFSharedFontManager()->updateBatchNodeSprite(m_batchNodes,m_pFontName,m_fFontSize,m_string,box.size,getColor());
	for (int i=0;i<m_batchNodes->count();i++)
	{
		CCSpriteBatchNode* batch = (CCSpriteBatchNode*)m_batchNodes->objectAtIndex(i);
		//检测是否这个batch已经添加到label，如果没有就添加
		CCNode* parent = batch->getParent();
		if (parent != this)
		{
			this->addChild(batch);
		}
	}
	this->setContentSize(change);
	return true;
}

CCSize SFLabelTex::getShowingDimension()
{
	return m_tDimensions;
}

bool SFLabelTex::hasDimension()
{
	if (m_tDimensions.width !=0 && m_tDimensions.height != 0)
	{
		return true;
	}
	return false;
}

void SFLabelTex::setColor(const ccColor3B& color3)
{
	CCNodeRGBA::setColor(color3);
	updateShowNode();
}
// init with non parameter        default init 
bool SFLabelTex::init()
{
	return this->initWithString("", "Helvetica", 12);
}
//initialize with string , font name and size
bool SFLabelTex::initWithString(const char* string,const char* fontName,float size)
{
	return this->initWithString(string, fontName, size, 
		CCSizeZero, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop);
}

bool SFLabelTex::initWithString(const char *string, const char *fontName, float fontSize,
							   const CCSize& dimensions, CCTextAlignment hAlignment)
{
	return this->initWithString(string, fontName, fontSize, dimensions, hAlignment, kCCVerticalTextAlignmentTop);
}

//init with CCSprite::init() and setup
bool SFLabelTex::initWithString(const char *string, const char *fontName, float fontSize,
							   const CCSize& dimensions, CCTextAlignment hAlignment,CCVerticalTextAlignment vAlignment)
{
	//CCTexture2D* texture = new CCTexture2D();
	//texture->autorelease();
	if (CCNodeRGBA::init())
	{
        this->setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor));
		m_tDimensions = CCSizeMake(dimensions.width, dimensions.height);
		m_hAlignment  = hAlignment;
		m_vAlignment  = vAlignment;
		m_pFontName   = fontName;
		m_fFontSize   = fontSize;
		setAnchorPoint(ccp(0.5f, 0.5f));
		m_batchNodes = CCArray::create();
		CC_SAFE_RETAIN(m_batchNodes);
		this->setString(string);
		return true;
	}
	return false;
}

SFLabelTex * SFLabelTex::create(const char *string, const char *fontName, float fontSize)
{
	SFLabelTex* label = new SFLabelTex();
	if (label&& label->initWithString(string,fontName,fontSize))
	{
		label->autorelease();
		return label;
	}
	CC_SAFE_DELETE(label);
	return NULL;
}
SFLabelTex* SFLabelTex::create( const char* string, const char* fontName, float fontSize,CCSize dimensions )
{
	SFLabelTex* label = new SFLabelTex();
	if (label&& label->initWithString(string,fontName,fontSize,dimensions,kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop))
	{
		label->autorelease();
		return label;
	}
	CC_SAFE_DELETE(label);
	return NULL;
}

SFLabelTex * SFLabelTex::create(const char *string, const char *fontName, float fontSize,
							  const CCSize& dimensions, CCTextAlignment hAlignment)
{
	SFLabelTex* label = new SFLabelTex();
	if (label&& label->initWithString(string,fontName,fontSize,dimensions,hAlignment))
	{
		label->autorelease();
		return label;
	}
	CC_SAFE_DELETE(label);
	return NULL;
}

SFLabelTex * SFLabelTex::create(const char *string, const char *fontName, float fontSize,
							  const CCSize& dimensions, CCTextAlignment hAlignment, 
							  CCVerticalTextAlignment vAlignment)
{
	SFLabelTex* label = new SFLabelTex();
	if (label&& label->initWithString(string,fontName,fontSize,dimensions,hAlignment,vAlignment))
	{
		label->autorelease();
		return label;
	}
	CC_SAFE_DELETE(label);
	return NULL;
}

SFLabelTex* SFLabelTex::create()
{
	SFLabelTex* label = new SFLabelTex();
	if (label&& label->initWithString("","Arial",12))
	{
		label->autorelease();
		return label;
	}
	CC_SAFE_DELETE(label);
	return NULL;
}

void SFLabelTex::setFontFillColor(const ccColor3B &tintColor, bool mustUpdateTexture)
{
	m_textFillColor = tintColor;
	if (mustUpdateTexture)
	{
		updateShowNode();
	}
}
ccColor3B SFLabelTex::getFontFillColor()
{
	return m_textFillColor;
}

void SFLabelTex::setString(const char *label)
{
	CCAssert(label != NULL, "Invalid string");

	//std::string temp(label);
	if (m_string.compare(label))
	{
		m_string = label;
		this->updateShowNode();
	}
}

const char* SFLabelTex::getString(void)
{
	return m_string.c_str();
}

CCTextAlignment SFLabelTex::getHorizontalAlignment()
{
	return m_hAlignment;
}

void SFLabelTex::setHorizontalAlignment(CCTextAlignment alignment)
{
	m_hAlignment = alignment;
	updateShowNode();
}

CCVerticalTextAlignment SFLabelTex::getVerticalAlignment()
{
	return m_vAlignment;
}

void SFLabelTex::setVerticalAlignment(CCVerticalTextAlignment verticalAlignment)
{
	m_vAlignment = verticalAlignment;
}

CCSize SFLabelTex::getDimensions()
{
	return m_tDimensions;
}

void SFLabelTex::setDimensions(const CCSize &dim)
{
	if (dim.width != m_tDimensions.width || dim.height != m_tDimensions.height)
	{
		m_tDimensions = dim;
		// Force update
		if (m_string.size() > 0)
		{
			updateShowNode();
			m_tDimensions = getContentSize();
		}
	}
}

float SFLabelTex::getFontSize()
{
	return m_fFontSize;
}

void SFLabelTex::setFontSize(float fontSize)
{
	m_fFontSize = fontSize;
	updateShowNode();
}

const char* SFLabelTex::getFontName()
{
	return m_pFontName.c_str();
}

void SFLabelTex::setFontName(const char *fontName)
{
	if (m_pFontName.compare(fontName))
	{

		m_pFontName = fontName;
		// Force update
		if (m_string.size() > 0)
		{
			this->updateShowNode();
		}
	}
}

SFLabelTex::SFLabelTex()
	:m_hAlignment(kCCTextAlignmentCenter)
	, m_vAlignment(kCCVerticalTextAlignmentTop)
	, m_pFontName("")
	, m_fFontSize(0.0)
	, m_string("")
	, m_textFillColor(ccWHITE)
{
}

SFLabelTex::~SFLabelTex()
{
	CC_SAFE_RELEASE_NULL(m_batchNodes);
}