#include "ui/control/SFTabViewControl.h"


SFTabViewControl* SFTabViewControl::createWithControls( CCControlButton *ctlButton, ... )
{
	va_list args;
	va_start(args,ctlButton);
	SFTabViewControl *pRet = new SFTabViewControl();
	if (pRet && pRet->initWithControls(ctlButton, args))
	{
		pRet->autorelease();
		va_end(args);
		return pRet;
	}
	va_end(args);
	CC_SAFE_DELETE(pRet);
	return NULL;
	
}

SFTabViewControl* SFTabViewControl::createWithArray( CCArray *controls )
{
	SFTabViewControl *pRet = new SFTabViewControl();
	if (pRet != NULL && pRet->initWithArray(controls)){
		pRet->autorelease();
	}
	else{
		delete pRet;
		pRet = NULL;
	}
	return pRet;
}

bool SFTabViewControl::initWithControls( CCControlButton* ctlButton, va_list args )
{

	CCArray* pArray = NULL;
	if( ctlButton ) {		
		pArray = CCArray::create(ctlButton, NULL);
		CCControlButton *i = va_arg(args, CCControlButton*);
		while(i) 
		{
			pArray->addObject(i);
			i = va_arg(args, CCControlButton*);
		}
	}

	return initWithArray(pArray);
}

bool SFTabViewControl::initWithArray( CCArray* pArrayOfctl )
{
	if (!pArrayOfctl) return NULL;
	bool bRet = false;
	do 
	{
		m_controls = CCArray::create();
		m_controls->retain();
		CCObject *obj = NULL;
		CCARRAY_FOREACH(pArrayOfctl, obj){
			CCControlButton *btn = (CCControlButton *)obj;
			m_controls->addObject(btn);
		}
		
		m_selIndex = 0;
		m_delegate = NULL;
		initControlTaget();
		bRet = true;
	} while (0);

	return bRet;
}

void SFTabViewControl::initControlTaget()
{
	CCObject *obj = NULL;
	CCARRAY_FOREACH(m_controls, obj){
// 		if (typeid(obj) != typeid(SFButton)){
// 			continue;	
// 		}
			
		CCControlButton *btn = (CCControlButton *)obj;
		//btn->setTarget(this, menu_selector(SFTabViewControl::controlOnClick));
		//m_pMenu->addChild(btn);
		btn->addTargetWithActionForControlEvents(this, cccontrol_selector(SFTabViewControl::controlOnClick), SFControlEventTouchEnd);
	}
}

bool SFTabViewControl::insertControl( CCControlButton *ctlButton )
{
	ctlButton->addTargetWithActionForControlEvents(this, cccontrol_selector(SFTabViewControl::controlOnClick), SFControlEventTouchEnd);
	//ctlButton->setTarget(this, menu_selector(SFTabViewControl::controlOnClick));
	m_controls->addObject(ctlButton);
	//m_pMenu->addChild(ctlButton);
	return true;
}

bool SFTabViewControl::removeControl( CCControlButton *ctlButton )
{
	unsigned int index = m_controls->indexOfObject(ctlButton);
	m_controls->removeObject(ctlButton);

	if (-1 < index && index <= m_selIndex){
		setSelIndex(0);
	}
	
	return true;
}

CCControlButton* SFTabViewControl::getSelControl()
{
	if(-1 < m_selIndex && m_selIndex < m_controls->count()){
		return (CCControlButton *)m_controls->objectAtIndex(m_selIndex);
	}
	return NULL;
}

bool SFTabViewControl::setSelControl( CCControlButton *ctlButton )
{
	unsigned int index = m_controls->indexOfObject(ctlButton);
	if(-1 < index && (index < m_controls->count())){
		m_selIndex = index;
		allUnSel();

		CCControlButton *btn = (CCControlButton *) m_controls->objectAtIndex(m_selIndex);
		btn->setSelected(true);
		btn->sendActionsForControlEvents(SFControlEventTouchEnd); 
		//controlOnClick(btn);
		return true;
	}
	return false;
}

int SFTabViewControl::getSelIndex()
{
	return m_selIndex;
}

bool SFTabViewControl::setSelIndex(unsigned int index )
{
	
	if((-1 < (int)index) && (index < m_controls->count())){

		allUnSel();

		m_selIndex = index;
		CCControlButton *btn = (CCControlButton *) m_controls->objectAtIndex(m_selIndex);
 		btn->setSelected(true);
 		btn->sendActionsForControlEvents(SFControlEventTouchEnd); 
		//controlOnClick(btn);
		return true;
	}
	return false;
}


void SFTabViewControl::allUnSel()
{
	CCObject *obj = NULL;
	CCARRAY_FOREACH(m_controls, obj){
		CCControlButton *btn = (CCControlButton *)obj;
		//btn->unselected();
		btn->setSelected(false);
	}
}


void SFTabViewControl::setDelegate( SFTabViewControlDelegate *delegate )
{
	m_delegate = (SFTabViewControlDelegate *)delegate;
}

void SFTabViewControl::controlOnClick(CCObject *sender, SFControlEvent event)
{
	
	CCControlButton *btn = (CCControlButton *)sender;
	unsigned int index = m_controls->indexOfObject(btn);
	btn->setSelected(true);
	if (index == m_selIndex)
		return;
	CCControlButton *oldBtn = (CCControlButton *)m_controls->objectAtIndex(m_selIndex);
	oldBtn->setSelected(false);
	m_selIndex = index;
	//allUnSel();
	
	if (m_delegate){
		m_delegate->didSelControl(this, m_selIndex);
	}
	
}

void SFTabViewControl::hiddenTabItem(bool hide)
{
	CCObject *obj = NULL;
	CCARRAY_FOREACH(m_controls, obj){
		CCControlButton *btn = (CCControlButton *)obj;
		btn->setVisible(!hide);
	}
}






