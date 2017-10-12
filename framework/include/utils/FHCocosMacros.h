/********************************************************************
文件名:FHCocosMacros.h
创建者:James Ou
创建时间:2013-8-9 15:16
功能描述:
*********************************************************************/

#ifndef __FHCOCOS_MACROS_H__
#define __FHCOCOS_MACROS_H__

/************************************************************************/
/* 层次顺序                                                                     */
/************************************************************************/
typedef enum {
	eUI_ORDER_NORMAL = 0,
	eUI_ORDER_FORM = 100,
	eUI_ORDER_ALERT = 200,
	eUI_ORDER_TIPS = 300,
	eUI_ORDER_LOADING = 400,
	eUI_ORDER_FLOAT = 500
}UI_ORDER;

#define SF_MESSAGE_CONSTRUCTOR( ownerClassName ) \
	ownerClassName() : SFTouchDelegate( this ){}


#define SF_MESSAGE_BRIDGE()                                             \
	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)             \
{                                                                       \
	return byTouchBegan( pTouch, pEvent );                                  \
}                                                                       \
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent)             \
{                                                                       \
	byTouchMoved( pTouch, pEvent );                                         \
}                                                                       \
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)             \
{                                                                       \
	byTouchEnded( pTouch, pEvent );                                         \
}                                                                       \
	virtual void ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent)         \
{                                                                       \
	byTouchCancelled( pTouch, pEvent );                                     \
}

#endif	//__FHCOCOS_MACROS_H__