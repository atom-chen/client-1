/********************************************************************
created:	2012/12/28
created:	28:12:2012   11:39
filename: 	E:\jiuxian\client_sulation\trunk\mf.game\Classes\MFUIComponent\SFScrollView.h
file path:	E:\jiuxian\client_sulation\trunk\mf.game\Classes\MFUIComponent
file base:	SFScrollView
file ext:	h
author:		Liu Rui

purpose:	基本和CCScrollView的功能一致，新增一下功能：
1. delegate多了点击事件的触摸点的传递
2. 设置是否启用自动滚动
*********************************************************************/


#ifndef __SFScrollView_H__
#define __SFScrollView_H__

#include "SFBaseControl.h"
#include "ExtensionMacros.h"


USING_NS_CC_EXT;

/**
* @addtogroup GUI
* @{
*/

typedef enum {
	kSFScrollViewDirectionNone = -1,
	kSFScrollViewDirectionHorizontal = 1,
	kSFScrollViewDirectionVertical = 2,
	kSFScrollViewDirectionBoth = 4
} SFScrollViewDirection;

typedef enum {
	kSFScrollViewFillTopDown,
	kSFScrollViewFillBottomUp
} SFScrollViewVerticalFillOrder;

class SFScrollView;

class SFScrollViewDelegate
{
public:
	virtual ~SFScrollViewDelegate() {}
	virtual void scrollViewDidScroll(SFScrollView* view){}
	virtual void scrollViewDidZoom(SFScrollView* view){}
	virtual void scrollViewTouchBegin(SFScrollView* view, CCPoint pt){}
	virtual void scrollViewTouchMove(SFScrollView* view, CCPoint pt){}
	virtual void scrollViewTouchEnd(SFScrollView* view, CCPoint pt){}
	virtual void scrollViewDidAnimateScrollEnd(SFScrollView* view){}
};

enum{
	kScrollViewDidScroll,
	kScrollViewDidZoom,
	kScrollViewTouchBegin,
	kScrollViewTouchMove,
	kScrollViewTouchEnd,
	kScrollViewDidAnimateScrollEnd,
};
/**
* ScrollView support for cocos2d for iphone.
* It provides scroll view functionalities to cocos2d projects natively.
*/
class SFScrollView : public SFBaseControl
{
public:
	SFScrollView();
	virtual ~SFScrollView();

	virtual bool init();
	/**
	* Returns an autoreleased scroll view object.
	* @deprecated: This interface will be deprecated sooner or later.
	* @param size view size
	* @param container parent object
	* @return autoreleased scroll view object
	*/
	CC_DEPRECATED_ATTRIBUTE static SFScrollView* viewWithViewSize(CCSize size, CCNode* container = NULL);

	/**
	* Returns an autoreleased scroll view object.
	*
	* @param size view size
	* @param container parent object
	* @return autoreleased scroll view object
	*/
	static SFScrollView* create(CCSize size, CCNode* container = NULL);

	/**
	* Returns an autoreleased scroll view object.
	* @deprecated: This interface will be deprecated sooner or later.
	* @param size view size
	* @param container parent object
	* @return autoreleased scroll view object
	*/
	CC_DEPRECATED_ATTRIBUTE static SFScrollView* node();

	/**
	* Returns an autoreleased scroll view object.
	*
	* @param size view size
	* @param container parent object
	* @return autoreleased scroll view object
	*/
	static SFScrollView* create();

	/**
	* Returns a scroll view object
	*
	* @param size view size
	* @param container parent object
	* @return scroll view object
	*/
	bool initWithViewSize(CCSize size, CCNode* container = NULL);


	/**
	* Sets a new content offset. It ignores max/min offset. It just sets what's given. (just like UIKit's UIScrollView)
	*
	* @param offset new offset
	* @param If YES, the view scrolls to the new offset
	*/
	void setContentOffset(CCPoint offset, bool animated = false);
	CCPoint getContentOffset();
	/**
	* Sets a new content offset. It ignores max/min offset. It just sets what's given. (just like UIKit's UIScrollView)
	* You can override the animation duration with this method.
	*
	* @param offset new offset
	* @param animation duration
	*/
	void setContentOffsetInDuration(CCPoint offset, float dt); 

	void setZoomScale(float s);
	/**
	* Sets a new scale and does that for a predefined duration.
	*
	* @param s a new scale vale
	* @param animated if YES, scaling is animated
	*/
	void setZoomScale(float s, bool animated);

	float getZoomScale();

	/**
	* Sets a new scale for container in a given duration.
	*
	* @param s a new scale value
	* @param animation duration
	*/
	void setZoomScaleInDuration(float s, float dt);
	/**
	* Returns the current container's minimum offset. You may want this while you animate scrolling by yourself
	*/
	CCPoint minContainerOffset();
	/**
	* Returns the current container's maximum offset. You may want this while you animate scrolling by yourself
	*/
	CCPoint maxContainerOffset(); 
	/**
	* Determines if a given node's bounding box is in visible bounds
	*
	* @return YES if it is in visible bounds
	*/
	bool isNodeVisible(CCNode * node);
	/**
	* Provided to make scroll view compatible with SWLayer's pause method
	*/
	void pause(CCObject* sender);
	/**
	* Provided to make scroll view compatible with SWLayer's resume method
	*/
	void resume(CCObject* sender);


	bool isDragging() {return m_bDragging;}
	bool isTouchMoved() { return m_bTouchMoved; }
	bool isBounceable() { return m_bBounceable; }
	void setBounceable(bool bBounceable) { m_bBounceable = bBounceable; }

	/**
	* size to clip. CCNode boundingBox uses contentSize directly.
	* It's semantically different what it actually means to common scroll views.
	* Hence, this scroll view will use a separate size property.
	*/
	CCSize getViewSize() { return m_tViewSize; } 
	void setViewSize(CCSize size);

	CCNode * getContainer();
	void setContainer(CCNode * pContainer);

	/**
	* direction allowed to scroll. SFScrollViewDirectionBoth by default.
	*/
	SFScrollViewDirection getDirection() { return m_eDirection; }
	virtual void setDirection(SFScrollViewDirection eDirection) { m_eDirection = eDirection; }

	SFScrollViewDelegate* getDelegate() { return m_pDelegate; }
	void setDelegate(SFScrollViewDelegate* pDelegate) { m_pDelegate = pDelegate; }

	/** override functions */
	// optional
	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);

	virtual void setContentSize(const CCSize & size);
	virtual const CCSize & getContentSize();

	void updateInset();
	/**
	* Determines whether it clips its children or not.
	*/
	bool isClippingToBounds() { return m_bClippingToBounds; }
	void setClippingToBounds(bool bClippingToBounds) { m_bClippingToBounds = bClippingToBounds; }

	virtual void visit();
	virtual void addChild(CCNode * child, int zOrder, int tag);
	virtual void addChild(CCNode * child, int zOrder);
	virtual void addChild(CCNode * child);
	void setTouchEnabled(bool e);

	// 设置按页的滚动
	void setPageEnable(bool bEnable);
	//后添加的方法
	int getPage();
	//后添加的方法
	void setPageSize(CCSize pageSize);
	CCSize getPageSize();

	void setCurrentPage(int page);
	void setHandler(int nHandler){m_handler = nHandler;};
private:
	//lua handler
	int m_handler;

	/**
	* Init this object with a given size to clip its content.
	*
	* @param size view size
	* @return initialized scroll view object
	*/
	bool initWithViewSize(CCSize size);
	/**
	* Relocates the container at the proper offset, in bounds of max/min offsets.
	*
	* @param animated If YES, relocation is animated
	*/
	void relocateContainer(bool animated);
	/**
	* implements auto-scrolling behavior. change SCROLL_DEACCEL_RATE as needed to choose
	* deacceleration speed. it must be less than 1.0f.
	*
	* @param dt delta
	*/
	void deaccelerateScrolling(float dt);
	/**
	* This method makes sure auto scrolling causes delegate to invoke its method
	*/
	void performedAnimatedScroll(float dt);
	/**
	* Expire animated scroll delegate calls
	*/
	void stoppedAnimatedScroll(CCNode* node);
	/**
	* clip this view so that outside of the visible bounds can be hidden.
	*/
	void beforeDraw();
	/**
	* retract what's done in beforeDraw so that there's no side effect to
	* other nodes.
	*/
	void afterDraw();
	/**
	* Zoom handling
	*/
	void handleZoom();

	/**
	* scroll offset with page enable
	*/
	CCPoint getPageOffset(CCPoint pt);

	// 设置是否自动滚动
protected: bool m_bAutoScroll;
public: virtual bool getAutoScroll(void) const { return m_bAutoScroll; }
public: virtual void setAutoScroll(bool var){ m_bAutoScroll = var; }

protected:
	/**
	* current zoom scale
	*/
	float m_fZoomScale;
	/**
	* min zoom scale
	*/
	float m_fMinZoomScale;
	/**
	* max zoom scale
	*/
	float m_fMaxZoomScale;
	/**
	* scroll view delegate
	*/
	SFScrollViewDelegate* m_pDelegate;

	SFScrollViewDirection m_eDirection;

	SFScrollViewVerticalFillOrder m_eFillOrder;
	/**
	* If YES, the view is being dragged.
	*/
	bool m_bDragging;

	/**
	* Content offset. Note that left-bottom point is the origin
	*/
	CCPoint m_tContentOffset;

	/**
	* Container holds scroll view contents, Sets the scrollable container object of the scroll view
	*/
	CCNode* m_pContainer;
	/**
	* Determiens whether user touch is moved after begin phase.
	*/
	bool m_bTouchMoved;
	/**
	* max inset point to limit scrolling by touch
	*/
	CCPoint m_fMaxInset;
	/**
	* min inset point to limit scrolling by touch
	*/
	CCPoint m_fMinInset;
	/**
	* Determines whether the scroll view is allowed to bounce or not.
	*/
	bool m_bBounceable;

	bool m_bClippingToBounds;

	/**
	* scroll speed
	*/
	CCPoint m_tScrollDistance;
	/**
	* Touch point
	*/
	CCPoint m_tTouchPoint;
	/**
	* length between two fingers
	*/
	float m_fTouchLength;
	/**
	* UITouch objects to detect multitouch
	*/
	CCArray* m_pTouches;
	/**
	* size to clip. CCNode boundingBox uses contentSize directly.
	* It's semantically different what it actually means to common scroll views.
	* Hence, this scroll view will use a separate size property.
	*/
	CCSize m_tViewSize;
	/**
	* max and min scale
	*/
	float m_fMinScale, m_fMaxScale;

	/**
	* 是否按页滚动
	*/
	bool m_bPageEnable;

	/**
	* 是否按页滚动
	*/
	CCPoint m_ptPrevContainerOffset;
	//后加的
	int m_page;
	//后加的
	CCSize m_pageSize;
};

// end of GUI group
/// @}

#endif /* __SFScrollView_H__ */
