#include "ui/control/SFCheckBox.h"
#include "ui/SFUIFactory.h"
#include "ui/control/SFLabel.h"
#include "ui/utils/VisibleRect.h"
#include "utils/SFTouchDispatcher.h"

SFCheckBox::SFCheckBox():m_label(NULL), m_storkeSize(0)
{
	m_btn = NULL;
	m_icon = NULL;

	m_bSelect = false;
	m_bEnable = true;

	m_target = NULL;
	m_action = NULL;
}

SFCheckBox::~SFCheckBox()
{

}

SFCheckBox* SFCheckBox::create( const char* normal, const char* select, CCObject* target, SEL_CallFuncO action )
{
	SFCheckBox* pRet = SFCheckBox::create();
	pRet->initControl(normal, select, target, action);
	return pRet;
}

void SFCheckBox::initControl( const char* normal, const char* select, CCObject* target, SEL_CallFuncO action )
{
	m_target = target;
	m_action = action;

	m_btn = CCSprite::createWithSpriteFrameName(normal);
	m_icon = CCSprite::createWithSpriteFrameName(select);

	//m_btn = SFUIFactory::sharedUIFactory()->createSprite(normal);
	//m_icon = SFUIFactory::sharedUIFactory()->createSprite(select);

	setContentSize(m_btn->getContentSize());

	addChild(m_btn);
	addChild(m_icon);

	VisibleRect::relativePosition(m_btn, this);
	VisibleRect::relativePosition(m_icon, m_btn);

	m_icon->setVisible(m_bSelect);
	setTouchEnabled(true);
}

void SFCheckBox::initControl( const char* normal, const char* select,int nHandler )
{

	m_handler = nHandler;
	m_btn = CCSprite::createWithSpriteFrameName(normal);
	m_icon = CCSprite::createWithSpriteFrameName(select);

	//m_btn = SFUIFactory::sharedUIFactory()->createSprite(normal);
	//m_icon = SFUIFactory::sharedUIFactory()->createSprite(select);

	setContentSize(m_btn->getContentSize());

	addChild(m_btn);
	addChild(m_icon);

	VisibleRect::relativePosition(m_btn, this);
	VisibleRect::relativePosition(m_icon, m_btn);

	m_icon->setVisible(m_bSelect);
	setTouchEnabled(true);
}



void SFCheckBox::setSelect( bool bSelect )
{
	m_bSelect = bSelect;
	m_icon->setVisible(m_bSelect);
}

bool SFCheckBox::getSelect()
{
	return m_bSelect;
}

void SFCheckBox::setEnable( bool bEnable )
{
	m_bEnable = bEnable;
}

bool SFCheckBox::getEnable()
{
	return m_bEnable;
}

void SFCheckBox::setCallback( CCObject* target, SEL_CallFuncO action )
{
	m_target = target;
	m_action = action;
}

//void SFCheckBox::onPressedButton( CCObject* sender, SFButtonEvent controlEvent )
//{

//}

void SFCheckBox::resize()
{
	if (m_label)
	{
		int height = MAX(m_btn->boundingBox().size.height, m_label->boundingBox().size.height);
		int width = m_label->boundingBox().origin.x + m_label->boundingBox().size.width;
		setContentSize(CCSizeMake(width, height));
	}
	else
	{
		setContentSize(m_btn->boundingBox().size);
	}
}

bool SFCheckBox::ccTouchBegan( CCTouch *pTouch, CCEvent *pEvent )
{
	if (isTouchInside(pTouch) && m_bEnable)
	{
		setSelect(!getSelect());

		if (m_target && m_action)
		{
			(m_target->*m_action)(this);
		}else if (m_handler)
		{
			CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
			engine->executeFunctionWithObject(m_handler,(void*)this,0 );
		}
		return true;
	}

	return false;
}

void SFCheckBox::ccTouchMoved( CCTouch *pTouch, CCEvent *pEvent )
{

}

void SFCheckBox::ccTouchEnded( CCTouch *pTouch, CCEvent *pEvent )
{

}

void SFCheckBox::ccTouchCancelled( CCTouch *pTouch, CCEvent *pEvent )
{

}
