#include "ui/control/SFBaseControl.h"
//#include "utils/SFTouchDispatcher.h"

SFBaseControl::SFBaseControl()
:m_pDispatchTable(NULL)
,m_deltaLeft(0.0f)
,m_deltaRight(0.0f)
,m_deltaTop(0.0f)
,m_deltaButtom(0.0f)
,m_touchAreaScale(1.0)
{

}

SFBaseControl::~SFBaseControl()
{
	CC_SAFE_RELEASE(m_pDispatchTable);
}

//CRGBA protocol
void SFBaseControl::setColor(const ccColor3B& color)
{
	m_tColor=color;
	CCObject* child;
	CCArray* children=getChildren();
	CCARRAY_FOREACH(children, child)
	{
		CCRGBAProtocol* pNode = dynamic_cast<CCRGBAProtocol*>(child);        
		if (pNode)
		{
			pNode->setColor(m_tColor);
		}
	}
}

const ccColor3B& SFBaseControl::getColor(void)
{
	return m_tColor;
}


void SFBaseControl::setOpacity(GLubyte opacity)
{
	m_cOpacity = opacity;

	CCObject* child;
	CCArray* children=getChildren();
	CCARRAY_FOREACH(children, child)
	{
		CCRGBAProtocol* pNode = dynamic_cast<CCRGBAProtocol*>(child);        
		if (pNode)
		{
			pNode->setOpacity(opacity);
		}
	}

}

GLubyte SFBaseControl::getOpacity()
{
	return m_cOpacity;
}


void SFBaseControl::setOpacityModifyRGB(bool bOpacityModifyRGB)
{
	m_bIsOpacityModifyRGB=bOpacityModifyRGB;
	CCObject* child;
	CCArray* children=getChildren();
	CCARRAY_FOREACH(children, child)
	{
		CCRGBAProtocol* pNode = dynamic_cast<CCRGBAProtocol*>(child);        
		if (pNode)
		{
			pNode->setOpacityModifyRGB(bOpacityModifyRGB);
		}
	}
}

bool SFBaseControl::isOpacityModifyRGB()
{
	return m_bIsOpacityModifyRGB;
}


bool SFBaseControl::init()
{
	bool bRet = false;
	do 
	{
		CC_BREAK_IF(! cocos2d::CCLayer::init());
		ignoreAnchorPointForPosition(false);
		setTouchMode(kCCTouchesOneByOne);
		setTouchPriority(kCCMenuHandlerPriority);
		m_pDispatchTable = new CCDictionary();
		bRet = true;
	} while (0);

	return bRet;
}

void SFBaseControl::setControlName( const char* name )
{
	m_controlName = name;
}

const char* SFBaseControl::getControlName()
{
	return m_controlName;
}

void SFBaseControl::setImageKey( const char* imageKey )
{
	m_imageKey = imageKey;
}

const char* SFBaseControl::getImageKey()
{
	return m_imageKey;
}

void SFBaseControl::setTitleKey( const char* titleKey )
{
	m_titleKey = titleKey;
}

const char* SFBaseControl::getTitleKey()
{
	return m_titleKey;
}

bool SFBaseControl::isTouchInside( CCTouch *pTouch )
{
	if(!getParent() || !isVisible())
		return false;
	CCNode *superParent = NULL;
	CCNode *parent = getParent();
	while(parent != NULL){
		superParent = parent->getParent();
		if(superParent){
			if(parent->getContentSize().width > 0 && !parent->boundingBox().containsPoint(superParent->convertTouchToNodeSpace(pTouch)))
				return false;
		}
		parent = superParent;
	}
	CCPoint pos = getParent()->convertTouchToNodeSpace(pTouch);	
	CCRect bBox = boundingBox();
	CCRect deltaBox = CCRect(bBox.getMidX() - (m_deltaLeft + bBox.size.width / 2 ) * m_touchAreaScale,
							bBox.getMidY() - (m_deltaButtom + bBox.size.height / 2) * m_touchAreaScale,
							(bBox.size.width + m_deltaRight + m_deltaLeft ) * m_touchAreaScale,
							(bBox.size.height + m_deltaButtom + m_deltaTop) * m_touchAreaScale);
	if (deltaBox.containsPoint(pos)){
		return true;
	}
	return false;
}

void SFBaseControl::addTargetWithActionForControlEvents( CCObject* target, SEL_CCControlHandler action, SFControlEvent controlEvents )
{
	CCInvocation *invocation = CCInvocation::create(target, action, controlEvents);

	CCArray* eventInvocationList = this->dispatchListforControlEvent(controlEvents);
	eventInvocationList->addObject(invocation);    
}

void SFBaseControl::addTargetWithActionForControlEvents( int nHandler, SFControlEvent controlEvents )
{
	CCInvocation *invocation = CCInvocation::create(nHandler, controlEvents);

	CCArray* eventInvocationList = this->dispatchListforControlEvent(controlEvents);
	eventInvocationList->addObject(invocation); 
}

void SFBaseControl::sendActionsForControlEvents( SFControlEvent controlEvents )
{
	for (int i = 0; i < kSFControlEventTotalNumber; i++)
	{
		if ((controlEvents & (1 << i)))
		{
			CCArray* invocationList = this->dispatchListforControlEvent(1<<i);
			CCObject* pObj = NULL;
			CCARRAY_FOREACH(invocationList, pObj)
			{
				CCInvocation* invocation = (CCInvocation*)pObj;
				invocation->invoke(this);
			}
		}
	}
}

CCArray* SFBaseControl::dispatchListforControlEvent( SFControlEvent controlEvent )
{
	CCArray* invocationList = (CCArray*)m_pDispatchTable->objectForKey(controlEvent);

	if (invocationList == NULL)
	{
		invocationList = CCArray::createWithCapacity(1);
		m_pDispatchTable->setObject(invocationList, controlEvent);
	}    
	return invocationList;
}

void SFBaseControl::onEnter()
{
	CCLayer::onEnter();
}

void SFBaseControl::onExit()
{
	CCLayer::onExit();
}

void SFBaseControl::setTouchAreaDelta( float deltaLeft, float deltaRight, float deltaTop, float deltaButtom )
{
	m_deltaLeft = deltaLeft;
	m_deltaRight = deltaRight;
	m_deltaTop = deltaTop;
	m_deltaButtom = deltaButtom;
}

void SFBaseControl::setTouchAreaScale( float scale )
{
	m_touchAreaScale = scale;
}

// cocos2d::CCPoint SFBaseControl::getPosition()
// {
// 	return m_pos;
// }
// 
// cocos2d::CCSize SFBaseControl::getSize()
// {
// 	return m_contentSize;
// }
// 
// cocos2d::CCRect SFBaseControl::getRect()
// {
// 	return NULL;
// }


