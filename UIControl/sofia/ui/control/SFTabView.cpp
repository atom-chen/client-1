#include "ui/control/SFTabView.h"

#define kDefautIndex 99

SFTabView* SFTabView::create(CCArray *controls, int margin, TabViewMode mode)
{
	SFTabView *pRet = new SFTabView();
	if (pRet != NULL && pRet->init(controls, margin, mode)){
		pRet->autorelease();
	}
	else{
		delete pRet;
		pRet = NULL;
	}
	return pRet;
}



bool SFTabView::init(CCArray *controls, int margin, TabViewMode mode)
{
	bool bRet = false;
	do 
	{
		bRet = SFBaseControl::init();
		m_controls = CCArray::create();
		m_controls->retain();
		CCObject *obj = NULL;
		CCARRAY_FOREACH(controls, obj){
			CCControlButton *btn = (CCControlButton *)obj;
			//btn->setAnchorPoint(ccp(0.5f,0));
			m_controls->addObject(btn);
		}
		m_margin = margin;
		m_tabMode = mode;
		m_selIndex = kDefautIndex;		
		m_delegate = NULL;
		m_defaultSel = true;
		initControlTaget();
		m_isfirst = true;
	} while (0);

	return bRet;
}

void SFTabView::initControlTaget()
{
//	SFButton *ctlButton = (SFButton*)m_controls->objectAtIndex(0);
//	CCSize csize = CCSizeMake((ctlButton->getContentSize().width+m_margin)*m_controls->count()-m_margin, ctlButton->getContentSize().height);
	setContentSize(getSize());
	//setContentSize(getSize());

	CCPoint pos = CCPointZero;
	int i = 0;
	CCObject *obj = NULL;
	CCARRAY_FOREACH(m_controls, obj){
		
		CCControlButton *btn = (CCControlButton *)obj;
		btn->addTargetWithActionForControlEvents(this, cccontrol_selector(SFTabView::controlOnClick), CCControlEventTouchUpInside);
		pos.x = int(btn->boundingBox().size.width*0.5f);
		pos.y = int(btn->boundingBox().size.height*0.5f);
		if (m_tabMode == tab_horizontal){
			pos.x = int((btn->boundingBox().size.width+m_margin)*i+pos.x);
		}
		else{
			pos.y = int((btn->boundingBox().size.height+m_margin)*i+pos.y);
		}
		
		btn->setPosition(pos);
		addChild(btn,-i);
		i++;
	}
}

bool SFTabView::insertControl( CCControlButton *ctlButton )
{
	if (m_controls->containsObject(ctlButton))
		return false;

	ctlButton->addTargetWithActionForControlEvents(this, cccontrol_selector(SFTabView::controlOnClick), CCControlEventTouchUpInside);
	CCControlButton *btn = (CCControlButton *)m_controls->lastObject();
	CCPoint pos = btn->getPosition();
	//pos.x = int(pos.x + btn->boundingBox().size.width/2);
	//pos.y = int(pos.y + btn->boundingBox().size.height/2);
	if (m_tabMode == tab_horizontal){
		pos.x = int(btn->boundingBox().size.width+m_margin + pos.x);
	}
	else{
		pos.y = int(btn->boundingBox().size.height+m_margin + pos.y);
	}
	
	//ctlButton->setAnchorPoint(ccp(0.5f,0));
	ctlButton->setPosition(pos);
	int index = m_controls->count();

	m_controls->addObject(ctlButton);

//	CCSize csize = CCSizeMake((ctlButton->getContentSize().width+m_margin)*m_controls->count()-m_margin, ctlButton->getContentSize().height);
	setContentSize(getSize());
	//setContentSize(getSize());

	addChild(ctlButton, -index);
	
	return true;
}

bool SFTabView::removeControl( CCControlButton *ctlButton )
{
	if (!ctlButton)
		return false;

	int index = m_controls->indexOfObject(ctlButton);
	m_controls->removeObject(ctlButton);
	removeChild(ctlButton, true);
	if ((-1 < index) && (index <= m_selIndex)){
		setSelIndex(0);
	}
	CCSize csize = CCSizeMake((ctlButton->getContentSize().width+m_margin)*m_controls->count()-m_margin, ctlButton->getContentSize().height);
	setContentSize(csize);
	return true;
}

CCControlButton* SFTabView::getSelControl()
{
	if((-1 < m_selIndex) && (m_selIndex < int(m_controls->count()))){
		return (CCControlButton *)m_controls->objectAtIndex(m_selIndex);
	}
	return NULL;
}

bool SFTabView::setSelControl( CCControlButton *ctlButton )
{
	int index = m_controls->indexOfObject(ctlButton);
	if (m_selIndex == index)
		return false;
	if(-1 < index && (index < int(m_controls->count()))){		
		CCControlButton* btn = (CCControlButton *)m_controls->objectAtIndex(index);
		if (btn)
			_selectTag(btn, index);

		return true;
	}
	return false;
}

int SFTabView::getSelIndex()
{
	return m_selIndex;
}

bool SFTabView::setSelIndex(unsigned int index )
{
	if (/*!m_isfirst && */index == m_selIndex)
		return false;
// 
// 	if(m_isfirst){		
// 		m_isfirst = false;
// 	}
		
	if (index < m_controls->count())
	{
		CCControlButton* btn = (CCControlButton *)m_controls->objectAtIndex(index);
		if (btn)
			_selectTag(btn, index);
	}
	return true;
}

void SFTabView::setAllUnSel()
{
	allUnSel();
	m_selIndex = kDefautIndex;
}

void SFTabView::setDefaultSel(bool defaultSel)
{
	m_defaultSel = defaultSel;
}

void SFTabView::allUnSel()
{
	CCObject *obj = NULL;
	CCARRAY_FOREACH(m_controls, obj){
		CCControlButton *btn = (CCControlButton *)obj;
		//btn->unselected();
		btn->setSelected(false);
		btn->setScaleDef(1);
	}
}


void SFTabView::setDelegate( SFTabViewDelegate *delegate )
{
	m_delegate = (SFTabViewDelegate *)delegate;
}

void SFTabView::controlOnClick(CCObject *sender, SFControlEvent event)
{

	CCControlButton *btn = (CCControlButton *)sender;
	unsigned int index = m_controls->indexOfObject(btn);
	btn->setSelected(true);
	
	_selectTag(btn, index);
}


void SFTabView::setTabMode( TabViewMode tabMode )
{
	m_tabMode = tabMode;
}


void SFTabView::_selectTag( CCControlButton* btn, int index )
{
#define kZoomActionTag 888
	static float s_scale = btn->getScale();
	
	if (m_selIndex < int(m_controls->count()))
	{
		CCControlButton *oldBtn = (CCControlButton *)m_controls->objectAtIndex(m_selIndex);
		if (oldBtn){
			oldBtn->setSelected(false);
// 			oldBtn->removeFromParentAndCleanup(true);
// 			addChild(oldBtn,oldBtn->getTag());
			oldBtn->stopActionByTag(kZoomActionTag);
			CCScaleTo *scaleTo = CCScaleTo::create(0.1f,1.0*s_scale);
			scaleTo->setTag(kZoomActionTag);
			oldBtn->runAction(scaleTo);		
		}
	}
	
	m_selIndex = index;
	btn->setSelected(true);
	btn->setTag(btn->getTag()+1);
// 	btn->removeFromParentAndCleanup(true);
// 	addChild(btn, btn->getTag()+1);
	btn->stopActionByTag(kZoomActionTag);
	CCScaleTo *scaleTo = CCScaleTo::create(0.1f,1.1f*s_scale);
	scaleTo->setTag(kZoomActionTag);
	btn->runAction(scaleTo);
	
	if (m_delegate){
		m_delegate->didSelControl(this, m_selIndex);
	}
}

const CCSize & SFTabView::getSize()
{
	m_tabSize = CCSizeZero;
	
	CCObject *obj = NULL;
	CCARRAY_FOREACH(m_controls, obj){
		CCControlButton *btn = (CCControlButton*)obj;
		if(m_tabMode == tab_horizontal){
			m_tabSize.width = int(m_tabSize.width+btn->boundingBox().size.width+m_margin);
			m_tabSize.height = int(btn->boundingBox().size.height);
		}
		else{
			m_tabSize.height = int(m_tabSize.height+btn->boundingBox().size.height+m_margin);
			m_tabSize.width = int(btn->boundingBox().size.width);
		}
	}
	if(m_tabMode == tab_horizontal)
		m_tabSize.width = int(m_tabSize.width-m_margin);
	else{
		m_tabSize.height = int(m_tabSize.height-m_margin);
	}
	return m_tabSize;
}

void SFTabView::onEnter()
{
	SFBaseControl::onEnter();
	if (m_defaultSel == true){
		if(m_selIndex == kDefautIndex){
			setSelIndex(0);
		}
	}		
}
