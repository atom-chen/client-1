#include "ui/control/SFProgressBar.h"
#include "ui/control/SFScale9Sprite.h"


SFProgressBar::SFProgressBar( CCScale9Sprite* pBarImage, CCSize sizeBar)
	:m_bar(pBarImage), m_barBg(NULL), m_number(NULL), m_max(100), m_current(50), m_bgFrameSize(0), m_sizeBar(sizeBar)
{	
	
}

SFProgressBar::~SFProgressBar()
{

}

void SFProgressBar::setNumberVisible( bool bVisible )
{
	m_number->setVisible(bVisible);
}

void SFProgressBar::setCurrentNumber( int number )
{
	if (number < 0)
		number = 0;

	if (number > m_max)
		number = m_max;

	m_current = number;

	int progress = 0;
	if (0==m_max)
	{
		progress = 0;
	}
	else if(m_max>0)
	{
		progress = (m_current*1.0f/m_max)*100;
	}
	updateProgressBar(progress);
	updateNumberText();
}

void SFProgressBar::setMaxNumber( int number )
{
	if (number <= 0)
		number = 0;

	m_max = number;
	int progress = 0;
	if (0 == m_max)
	{
		progress = 0;
	}
	else if(m_max>0)
	{
		progress = (m_current*1.0f/m_max)*100;
	}
	updateProgressBar(progress);
	updateNumberText();
}

void SFProgressBar::updateNumberText()
{
	char strNumber[128] = {0};
	sprintf(strNumber, "%d/%d", m_current, m_max);

	m_number->setString(strNumber);
	VisibleRect::relativePosition(m_number, this, LAYOUT_CENTER);
}

void SFProgressBar::setPercentage( int number )
{
	m_current = m_max*number/100;

	updateProgressBar(number);
	updateNumberText();
}

SFProgressBar* SFProgressBar::create( CCScale9Sprite* pBarImage, CCSize sizeBar )
{
	SFProgressBar* pRet = new SFProgressBar(pBarImage, sizeBar);
	if (pRet && pRet->init())
	{
		pRet->autorelease();
	}
	else
	{
		delete pRet;
		pRet = NULL;
	}

	return pRet;
}

bool SFProgressBar::init()
{
	bool bRet = false;
	do 
	{
		ignoreAnchorPointForPosition(false);
		CC_BREAK_IF(! SFBaseControl::init());
		setContentSize(m_sizeBar);
		setAnchorPoint(CCPointZero);
		m_bar->setAnchorPoint(ccp(0,0.5f));
		m_bar->setPosition((getContentSize().width-m_bar->getContentSize().width)*0.5f, getContentSize().height*0.5f);
		addChild(m_bar, 1);

		char strNumber[128] = {0};
		sprintf(strNumber, "%d/%d", m_current, m_max);
		m_number =CCLabelTTF::create("","",m_sizeBar.height);
		addChild(m_number, 1);
		VisibleRect::relativePosition(m_number, this, LAYOUT_CENTER);
		bRet = true;
	} while (!bRet);

	return bRet;
}

void SFProgressBar::setBackground( CCScale9Sprite* pBarBg )
{
	if (m_barBg)
	{
		m_barBg->removeAllChildrenWithCleanup(true);
		m_barBg = NULL;
	}

	if (pBarBg)
	{
		m_barBg = pBarBg;
		// 这里不要改写m_sizeBar的值，否则会影响m_bar的高
		CCSize newSize;
		newSize.width = MAX(m_barBg->getContentSize().width, m_bar->getContentSize().width);
		newSize.height = MAX(m_barBg->getContentSize().height, m_bar->getContentSize().height);
		setContentSize(newSize);
		addChild(m_barBg);
		m_barBg->setAnchorPoint(ccp(0,0.5f));
		m_barBg->setPosition(ccp((getContentSize().width-m_barBg->getContentSize().width)*0.5, getContentSize().height*0.5));

		if (m_bar)
			//VisibleRect::relativePosition(m_bar, m_barBg, LAYOUT_CENTER);
			m_bar->setPosition(ccp((getContentSize().width-m_bar->getContentSize().width)*0.5, getContentSize().height*0.5));

		if (m_bar && m_number)
			//VisibleRect::relativePosition(m_number, this, LAYOUT_CENTER);
			m_number->setPosition(ccp(getContentSize().width*0.5f, getContentSize().height*0.5f));
	}
}

void SFProgressBar::setTextParam( const char* pFontName, int fontSize, cocos2d::ccColor3B fontColor, cocos2d::ccColor3B strokeColor /*= NULL*/, int stroleSize /*= -1*/ )
{
	if (m_number)
	{
		if (pFontName)
			m_number->setFontName(pFontName);

		if (fontSize > 0)
			m_number->setFontSize(fontSize);

		m_number->setColor(fontColor);


		if (stroleSize >= 0)
		

		VisibleRect::relativePosition(m_number, this, LAYOUT_CENTER);
	}
}

void SFProgressBar::updateProgressBar( int percentage )
{
	if (m_bar)
	{
		int newWidth = percentage*m_sizeBar.width/100.0;
		if (0 == newWidth)
			newWidth = 1;

		if (newWidth <= m_bar->getOriginalSize().width)
		{
			// 如果比图片本来的尺寸还要小，用setScaleSize会出错
			//m_bar->setScaleSize(m_bar->getContentSize());
			m_bar->setContentSize(m_bar->getOriginalSize());
			m_bar->setScaleX(newWidth/m_bar->getOriginalSize().width);
		}
		else
		{
			m_bar->setScaleX(1);
			//m_bar->setScaleSize(CCSizeMake(newWidth, m_sizeBar.height));
			m_bar->setContentSize(CCSizeMake(newWidth, m_sizeBar.height));
		}
	}
}
