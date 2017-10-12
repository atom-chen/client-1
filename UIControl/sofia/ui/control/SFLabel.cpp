#include "ui/control/SFLabel.h"
#include "label_nodes/CCLabelTTF.h"
#include "ui/utils/VisibleRect.h"
#include "utils/SFStringUtil.h"

SFLabel::SFLabel():m_pLabel(NULL)
{

}

SFLabel::~SFLabel()
{
	if (m_pLabel)
	{
		m_pLabel->release();
		m_pLabel = NULL;
	}
}

SFLabel* SFLabel::create( const char* str, const char* font, int fontSize /*= TITLE_FONT_SIZE*/, ccColor3B color /*= ccBLACK*/, CCSize size )
{
	SFLabel* pLabel = new SFLabel();
	if (pLabel && pLabel->init(str, font, fontSize, color))
	{
		pLabel->autorelease();
		return pLabel;
	}
	else
	{
		delete pLabel;
		return NULL;
	}
}

void SFLabel::setString( const char* str )
{
	if ((!str) || (!m_pLabel))
		return;

	if (SFStringUtil::isEqual(m_pLabel->getString(), str))
		return;

	m_pLabel->setString(str);
	VisibleRect::relativePosition(m_pLabel, this, LAYOUT_LEFT_INSIDE | LAYOUT_BOTTOM_INSIDE);

	if (m_pLabel->getDimensions().equals(CCSizeZero))
	{
		setContentSize(m_pLabel->getContentSize());
	}
	else
	{
		setContentSize(m_pLabel->getDimensions());
	}

}

void SFLabel::setFontName( const char* font )
{
	if (m_pLabel)
		m_pLabel->setFontName(font);

	if (m_pLabel->getDimensions().equals(CCSizeZero))
	{
		setContentSize(m_pLabel->getContentSize());
	}
	else
	{
		setContentSize(m_pLabel->getDimensions());
	}
}

void SFLabel::setFontSize( int fontSize )
{
	if (m_pLabel)
		m_pLabel->setFontSize(fontSize);

	if (m_pLabel->getDimensions().equals(CCSizeZero))
	{
		setContentSize(m_pLabel->getContentSize());
	}
	else
	{
		setContentSize(m_pLabel->getDimensions());
	}
}

//void SFLabel::setColor( ccColor3B color )
//{
//	if (m_pLabel)
//		m_pLabel->setColor(color);
//}

const char* SFLabel::getString()
{
	if (m_pLabel)
		return m_pLabel->getString();
	else
		return NULL;
}

const char* SFLabel::getFontName()
{
	if (m_pLabel)
		return m_pLabel->getFontName();
	else
		return NULL;
}

int SFLabel::getFontSize()
{
	if (m_pLabel)
		return m_pLabel->getFontSize();
	else
		return NULL;
}

//cocos2d::ccColor3B SFLabel::getColor()
//{
//	if (m_pLabel)
//		return m_pLabel->getColor();
//	else
//		return ccBLACK;
//}

bool SFLabel::init( const char* str, const char* font, int fontSize /*= TITLE_FONT_SIZE*/, ccColor3B color /*= ccBLACK*/, CCSize size )
{
	bool bRet = false;
	do 
	{
		CC_BREAK_IF(! SFBaseControl::init());
		if (!m_pLabel)
		{
			m_pLabel = SFLabelTex::create(str, font, fontSize);	//1
			m_pLabel->retain();
			addChild(m_pLabel);
		}
		
		m_pLabel->setColor(color);
		
		VisibleRect::relativePosition(m_pLabel, this, LAYOUT_LEFT_INSIDE | LAYOUT_BOTTOM_INSIDE);
		//m_pLabel->setAnchorPoint(CCPointZero);
		//m_pLabel->setPosition(CCPointZero);

		setContentSize(m_pLabel->getContentSize());
		bRet = true;
	} while (!bRet);

	return bRet;
}

void SFLabel::setDimensions( CCSize size )
{
	if (m_pLabel)
	{
		m_pLabel->setDimensions(size);

		if (size.height == 0)
		{
			setContentSize(m_pLabel->getContentSize());
			m_pLabel->setPosition(ccp(m_pLabel->getContentSize().width/2, m_pLabel->getContentSize().height/2));
		}
		else
		{
			setContentSize(size);
			m_pLabel->setPosition(ccp(m_pLabel->getDimensions().width/2, m_pLabel->getDimensions().height/2));
		}
		setColor(m_pLabel->getColor());
	}
}

cocos2d::CCSize SFLabel::getDimensions()
{
	if (m_pLabel)
	{
		return m_pLabel->getDimensions();
	}
	else
	{
		return CCSizeZero;
	}
}

void SFLabel::setVerticalTextAlignment( SFVerticalTextAlignment alignment )
{
	if (m_pLabel)
	{
		m_pLabel->setVerticalAlignment((CCVerticalTextAlignment)alignment);

	}
}

SFVerticalTextAlignment SFLabel::getVerticalTextAlignment()
{
	if (m_pLabel)
	{
		return (SFVerticalTextAlignment)m_pLabel->getVerticalAlignment();
	}
	else
	{
		return kSFVerticalTextAlignmentTop;
	}
}

const CCSize& SFLabel::getContentSize()
{
	if (m_pLabel)
	{
		return SFBaseControl::getContentSize();
	}
	else
	{
		return CCSizeZero;
	}
}
