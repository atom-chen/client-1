/********************************************************************
文件名:SFTouchDispatcher.h
创建者:James Ou
创建时间:2013-5-14 10:02
功能描述:
*********************************************************************/

#ifndef __SFTOUCH_DISPATCHER_H__
#define __SFTOUCH_DISPATCHER_H__

#include "utils/Singleton.h"
#include "cocos2d.h"
USING_NS_CC;

#include "utils/FHCocosMacros.h"

class SFTouchDispatcher : public cocos2d::Singleton<SFTouchDispatcher>{
public:
	void addTouchEvent(CCTouchDelegate *pTouchDelegate, int nPriority, bool bSwallowsTouchs);
	void removeTouchEvent(CCTouchDelegate *pTouchDelegate);
};

#define GetTouchDispatcher SFTouchDispatcher::getInstancePtr()


class SFTouchDelegate
{
public:
	SFTouchDelegate( CCNode* pOwner ); 
	virtual ~SFTouchDelegate();
	 
protected:
	// default implements are used to call script callback if exist
	virtual bool byTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void byTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void byTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	virtual void byTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);

	//return value:
	//true: pParent is touched by user
	//false: pParent isn't touched by user.
	bool passMessage( CCNode* pParent, CCTouch *pTouch, CCEvent *pEvent );
private:
	CCNode* m_pOwner;
	bool m_bDraging;
	//items claim touch message
	CCArray* m_pItemsClaimTouch;
	CCArray* m_pMenusClaimTouch;
};

//Root Touch RT
class RTLayer : public CCLayer, public SFTouchDelegate
{
	//static
public:
	CREATE_FUNC( RTLayer );

	//functions
public:
	RTLayer();
	bool virtual init();
	SF_MESSAGE_BRIDGE();

protected:
	//SF_TOUCH_REGISTER_TWO_MODE( -500 );
	//SF_TOUCH_REGISTER_DEFAULT(-500);
};

#endif	//__SFTOUCH_DISPATCHER_H__