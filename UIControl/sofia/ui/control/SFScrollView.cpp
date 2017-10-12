/****************************************************************************
 Copyright (c) 2012 cocos2d-x.org
 Copyright (c) 2010 Sangwoo Im
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include "ui/control/SFScrollView.h"
#include "actions/CCActionInterval.h"
#include "actions/CCActionTween.h"
#include "actions/CCActionInstant.h"
#include "support/CCPointExtension.h"
#include "touch_dispatcher/CCTouchDispatcher.h"
#include "effects/CCGrid.h"
#include "CCDirector.h"
#include "kazmath/GL/matrix.h"
#include "touch_dispatcher/CCTouch.h"
#include "CCEGLView.h"
#include "utils/SFTouchDispatcher.h"
#include "script_support/CCScriptSupport.h"
#define SCROLL_DEACCEL_RATE  0.95f
#define SCROLL_DEACCEL_DIST  1.0f
#define BOUNCE_DURATION      0.15f
#define INSET_RATIO          0.2f


SFScrollView::SFScrollView()
: m_fZoomScale(0.0f)
, m_fMinZoomScale(0.0f)
, m_fMaxZoomScale(0.0f)
, m_pDelegate(NULL)
, m_bDragging(false)
, m_bBounceable(false)
, m_eDirection(kSFScrollViewDirectionBoth)
, m_eFillOrder(kSFScrollViewFillBottomUp)
, m_bClippingToBounds(false)
, m_pContainer(NULL)
, m_bTouchMoved(false)
, m_fTouchLength(0.0f)
, m_pTouches(NULL)
, m_fMinScale(0.0f)
, m_fMaxScale(0.0f)
, m_bPageEnable(false)
, m_ptPrevContainerOffset(CCPointZero)
, m_bAutoScroll(true)
,m_page(0)
,m_pageSize(CCSizeZero)
,m_handler(0)
{

}

SFScrollView::~SFScrollView()
{
    m_pTouches->release();
}

SFScrollView* SFScrollView::viewWithViewSize(CCSize size, CCNode* container/* = NULL*/)
{
    return SFScrollView::create(size, container);
}

SFScrollView* SFScrollView::create(CCSize size, CCNode* container/* = NULL*/)
{
    SFScrollView* pRet = new SFScrollView();
    if (pRet && pRet->initWithViewSize(size, container))
    {
        pRet->autorelease();
    }
    else
    {
        CC_SAFE_DELETE(pRet);
    }
    return pRet;
}

SFScrollView* SFScrollView::node()
{
    return SFScrollView::create();
}

SFScrollView* SFScrollView::create()
{
    SFScrollView* pRet = new SFScrollView();
    if (pRet && pRet->init())
    {
        pRet->autorelease();
    }
    else
    {
        CC_SAFE_DELETE(pRet);
    }
    return pRet;
}


bool SFScrollView::initWithViewSize(CCSize size, CCNode *container/* = NULL*/)
{
    if (SFBaseControl::init())
    {
		setAnchorPoint(CCPointZero);
        m_pContainer = container;
        
        if (!this->m_pContainer)
        {
            m_pContainer = CCNode::create();
            this->m_pContainer->ignoreAnchorPointForPosition(false);
            this->m_pContainer->setAnchorPoint(ccp(0.0f, 0.0f));
        }

        this->setViewSize(size);

        setTouchEnabled(true);
		CC_SAFE_DELETE(m_pTouches);
        m_pTouches = new CCArray();
        m_pDelegate = NULL;
        m_bBounceable = true;
        m_bClippingToBounds = true;
        //m_pContainer->setContentSize(CCSizeZero);
        m_eDirection  = kSFScrollViewDirectionBoth;
        m_pContainer->setPosition(ccp(0.0f, 0.0f));
        m_fTouchLength = 0.0f;
        
        this->addChild(m_pContainer);
        m_fMinScale = m_fMaxScale = 1.0f;
        return true;
    }
    return false;
}

bool SFScrollView::init()
{
    return this->initWithViewSize(CCSizeMake(200, 200), NULL);
}

bool SFScrollView::isNodeVisible(CCNode* node)
{
    const CCPoint offset = this->getContentOffset();
    const CCSize  size   = this->getViewSize();
    const float   scale  = this->getZoomScale();
    
    CCRect viewRect;
    
    viewRect = CCRectMake(-offset.x/scale, -offset.y/scale, size.width/scale, size.height/scale); 
    
    return viewRect.intersectsRect(node->boundingBox());
}

void SFScrollView::pause(CCObject* sender)
{
    m_pContainer->pauseSchedulerAndActions();

    CCObject* pObj = NULL;
    CCArray* pChildren = m_pContainer->getChildren();

    CCARRAY_FOREACH(pChildren, pObj)
    {
        CCNode* pChild = (CCNode*)pObj;
        pChild->pauseSchedulerAndActions();
    }
}

void SFScrollView::resume(CCObject* sender)
{
    CCObject* pObj = NULL;
    CCArray* pChildren = m_pContainer->getChildren();

    CCARRAY_FOREACH(pChildren, pObj)
    {
        CCNode* pChild = (CCNode*)pObj;
        pChild->resumeSchedulerAndActions();
    }

    m_pContainer->resumeSchedulerAndActions();
}

void SFScrollView::setTouchEnabled(bool e)
{
    CCLayer::setTouchEnabled(e);
    if (!e)
    {
        m_bDragging = false;
        m_bTouchMoved = false;
        m_pTouches->removeAllObjects();
    }
}

void SFScrollView::setContentOffset(CCPoint offset, bool animated/* = false*/)
{
    if (animated)
    { //animate scrolling
        this->setContentOffsetInDuration(offset, BOUNCE_DURATION);
    } 
    else
    { //set the container position directly
        if (!m_bBounceable)
        {
            const CCPoint minOffset = this->minContainerOffset();
            const CCPoint maxOffset = this->maxContainerOffset();
            
            offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
            offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
        }

        m_pContainer->setPosition(offset);
		getPage();
        if (m_pDelegate != NULL)
        {
            m_pDelegate->scrollViewDidScroll(this);   
        }
    }
}

void SFScrollView::setContentOffsetInDuration(CCPoint offset, float dt)
{
    CCFiniteTimeAction *scroll, *expire;
    
    scroll = CCMoveTo::create(dt, offset);
    expire = CCCallFuncN::create(this, callfuncN_selector(SFScrollView::stoppedAnimatedScroll));
    m_pContainer->runAction(CCSequence::create(scroll, expire, NULL));
    this->schedule(schedule_selector(SFScrollView::performedAnimatedScroll));
}

CCPoint SFScrollView::getContentOffset()
{
    return m_pContainer->getPosition();
}

void SFScrollView::setZoomScale(float s)
{
    if (m_pContainer->getScale() != s)
    {
        CCPoint oldCenter, newCenter;
        CCPoint center;
        
        if (m_fTouchLength == 0.0f) 
        {
            center = ccp(m_tViewSize.width*0.5f, m_tViewSize.height*0.5f);
            center = this->convertToWorldSpace(center);
        }
        else
        {
            center = m_tTouchPoint;
        }
        
        oldCenter = m_pContainer->convertToNodeSpace(center);
        m_pContainer->setScale(MAX(m_fMinScale, MIN(m_fMaxScale, s)));
        newCenter = m_pContainer->convertToWorldSpace(oldCenter);
        
        const CCPoint offset = ccpSub(center, newCenter);
        if (m_pDelegate != NULL)
        {
            m_pDelegate->scrollViewDidZoom(this);
        }
        this->setContentOffset(ccpAdd(m_pContainer->getPosition(),offset));
    }
}

float SFScrollView::getZoomScale()
{
    return m_pContainer->getScale();
}

void SFScrollView::setZoomScale(float s, bool animated)
{
    if (animated)
    {
        this->setZoomScaleInDuration(s, BOUNCE_DURATION);
    }
    else
    {
        this->setZoomScale(s);
    }
}

void SFScrollView::setZoomScaleInDuration(float s, float dt)
{
    if (dt > 0)
    {
        if (m_pContainer->getScale() != s)
        {
            CCActionTween *scaleAction;
            scaleAction = CCActionTween::create(dt, "zoomScale", m_pContainer->getScale(), s);
            this->runAction(scaleAction);
        }
    }
    else
    {
        this->setZoomScale(s);
    }
}

void SFScrollView::setViewSize(CCSize size)
{
    m_tViewSize = size;
    CCLayer::setContentSize(size);
}

CCNode * SFScrollView::getContainer()
{
    return this->m_pContainer;
}

void SFScrollView::setContainer(CCNode * pContainer)
{
    this->removeAllChildrenWithCleanup(true);

    if (!pContainer) return;

    this->m_pContainer = pContainer;

    this->m_pContainer->ignoreAnchorPointForPosition(false);
    this->m_pContainer->setAnchorPoint(ccp(0.0f, 0.0f));
	//CCAssert(m_pContainer->getContentSize().equals(CCSizeZero),"The contentSize can not be zero");
    this->addChild(this->m_pContainer);

    this->setViewSize(this->m_tViewSize);
	this->updateInset();
}

void SFScrollView::relocateContainer(bool animated)
{
    CCPoint oldPoint, min, max;
    float newX, newY;
    
    min = this->minContainerOffset();
    max = this->maxContainerOffset();
    
    oldPoint = m_pContainer->getPosition();

    newX     = oldPoint.x;
    newY     = oldPoint.y;
    if (m_eDirection == kSFScrollViewDirectionBoth || m_eDirection == kSFScrollViewDirectionHorizontal)
    {
        newX     = MIN(newX, max.x);
        newX     = MAX(newX, min.x);
    }

    if (m_eDirection == kSFScrollViewDirectionBoth || m_eDirection == kSFScrollViewDirectionVertical)
    {
        newY     = MIN(newY, max.y);
        newY     = MAX(newY, min.y);
    }

    if (newY != oldPoint.y || newX != oldPoint.x)
    {
        this->setContentOffset(ccp(newX, newY), animated);
    }
}

CCPoint SFScrollView::maxContainerOffset()
{
    return ccp(0.0f, 0.0f);
}

CCPoint SFScrollView::minContainerOffset()
{
    return ccp(m_tViewSize.width - m_pContainer->getContentSize().width*m_pContainer->getScaleX(), 
               m_tViewSize.height - m_pContainer->getContentSize().height*m_pContainer->getScaleY());
}

void SFScrollView::deaccelerateScrolling(float dt)
{
    if (m_bDragging)
    {
        this->unschedule(schedule_selector(SFScrollView::deaccelerateScrolling));
        return;
    }
    
    float newX, newY;
    CCPoint maxInset, minInset;
    
    m_pContainer->setPosition(ccpAdd(m_pContainer->getPosition(), m_tScrollDistance));
    
    if (m_bBounceable)
    {
        maxInset = m_fMaxInset;
        minInset = m_fMinInset;
    }
    else
    {
        maxInset = this->maxContainerOffset();
        minInset = this->minContainerOffset();
    }
    
    //check to see if offset lies within the inset bounds
    newX     = MIN(m_pContainer->getPosition().x, maxInset.x);
    newX     = MAX(newX, minInset.x);
    newY     = MIN(m_pContainer->getPosition().y, maxInset.y);
    newY     = MAX(newY, minInset.y);
    
    m_tScrollDistance     = ccpSub(m_tScrollDistance, ccp(newX - m_pContainer->getPosition().x, newY - m_pContainer->getPosition().y));
    m_tScrollDistance     = ccpMult(m_tScrollDistance, SCROLL_DEACCEL_RATE);

	this->setContentOffset(ccp(newX,newY));
    
    if ((fabsf(m_tScrollDistance.x) <= SCROLL_DEACCEL_DIST &&
         fabsf(m_tScrollDistance.y) <= SCROLL_DEACCEL_DIST) ||
        newX == maxInset.x || newX == minInset.x ||
        newY == maxInset.y || newY == minInset.y)
    {
        this->unschedule(schedule_selector(SFScrollView::deaccelerateScrolling));
        this->relocateContainer(true);
    }
}

void SFScrollView::stoppedAnimatedScroll(CCNode * node)
{
    this->unschedule(schedule_selector(SFScrollView::performedAnimatedScroll));

	if (m_pDelegate != NULL)
	{
		m_pDelegate->scrollViewDidAnimateScrollEnd(this);
	}
	if (m_handler != 0)
	{
		CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeSFScrollView(m_handler,this,kScrollViewDidAnimateScrollEnd,0,0);
		getPage();
	}
	
}

void SFScrollView::performedAnimatedScroll(float dt)
{
    if (m_bDragging)
    {
        this->unschedule(schedule_selector(SFScrollView::performedAnimatedScroll));
        return;
    }

    if (m_pDelegate != NULL)
    {
        m_pDelegate->scrollViewDidScroll(this);
    }
}


const CCSize & SFScrollView::getContentSize()
{
	return m_pContainer->getContentSize();
}

void SFScrollView::setContentSize(const CCSize & size)
{
    if (this->getContainer() != NULL)
    {
        this->getContainer()->setContentSize(size);
		this->updateInset();
    }
}

void SFScrollView::updateInset()
{
	if (this->getContainer() != NULL)
	{
		m_fMaxInset = this->maxContainerOffset();
		m_fMaxInset = ccp(m_fMaxInset.x + m_tViewSize.width * INSET_RATIO,
			m_fMaxInset.y + m_tViewSize.height * INSET_RATIO);
		m_fMinInset = this->minContainerOffset();
		m_fMinInset = ccp(m_fMinInset.x - m_tViewSize.width * INSET_RATIO,
			m_fMinInset.y - m_tViewSize.height * INSET_RATIO);
	}
}

/**
 * make sure all children go to the container
 */
void SFScrollView::addChild(CCNode * child, int zOrder, int tag)
{
    //child->ignoreAnchorPointForPosition(false);
    //child->setAnchorPoint(ccp(0.0f, 0.0f));
    if (m_pContainer != child) {
        m_pContainer->addChild(child, zOrder, tag);
    } else {
        CCLayer::addChild(child, zOrder, tag);
    }
}

void SFScrollView::addChild(CCNode * child, int zOrder)
{
    this->addChild(child, zOrder, child->getTag());
}

void SFScrollView::addChild(CCNode * child)
{
    this->addChild(child, child->getZOrder(), child->getTag());
}

/**
 * clip this view so that outside of the visible bounds can be hidden.
 */
void SFScrollView::beforeDraw()
{
    if (m_bClippingToBounds && this->getParent())
    {
		// TODO: This scrollview should respect parents' positions
		CCPoint screenPos = this->getParent()->convertToWorldSpace(this->getPosition());

        glEnable(GL_SCISSOR_TEST);
        float s = this->getScale();

//        CCDirector *director = CCDirector::sharedDirector();
//        s *= director->getContentScaleFactor();
        CCEGLView::sharedOpenGLView()->setScissorInPoints(screenPos.x*s, screenPos.y*s, m_tViewSize.width*s, m_tViewSize.height*s);
        //glScissor((GLint)screenPos.x, (GLint)screenPos.y, (GLsizei)(m_tViewSize.width*s), (GLsizei)(m_tViewSize.height*s));
		
    }
}

/**
 * retract what's done in beforeDraw so that there's no side effect to
 * other nodes.
 */
void SFScrollView::afterDraw()
{
    if (m_bClippingToBounds)
    {
        glDisable(GL_SCISSOR_TEST);
    }
}

void SFScrollView::visit()
{
	// quick return if not visible
	if (!isVisible())
    {
		return;
    }

	kmGLPushMatrix();
	
    if (m_pGrid && m_pGrid->isActive())
    {
        m_pGrid->beforeDraw();
        this->transformAncestors();
    }

	this->transform();
    this->beforeDraw();

	if(m_pChildren)
    {
		ccArray *arrayData = m_pChildren->data;
		unsigned int i=0;
		
		// draw children zOrder < 0
		for( ; i < arrayData->num; i++ )
        {
			CCNode *child =  (CCNode*)arrayData->arr[i];
			if ( child->getZOrder() < 0 )
            {
				child->visit();
			}
            else
            {
				break;
            }
		}
		
		// this draw
		this->draw();
		
		// draw children zOrder >= 0
		for( ; i < arrayData->num; i++ )
        {
			CCNode* child = (CCNode*)arrayData->arr[i];
			child->visit();

			CCLayer *childLayer = dynamic_cast<CCLayer*>(child);
			if(childLayer && childLayer->isVisible()){
				if(!boundingBox().containsPoint(childLayer->boundingBox().origin) && 
					!boundingBox().containsPoint(ccp(childLayer->boundingBox().origin.x, childLayer->boundingBox().origin.y-childLayer->boundingBox().size.height))){
					childLayer->setTouchEnabled(false);
				}
				else{
					childLayer->setTouchEnabled(true);
				}
			}
		}        
	}
    else
    {
		this->draw();
    }

    this->afterDraw();
	if ( m_pGrid && m_pGrid->isActive())
    {
		m_pGrid->afterDraw(this);
    }

	kmGLPopMatrix();
}

bool SFScrollView::ccTouchBegan(CCTouch* touch, CCEvent* event)
{
    if (!this->isVisible())
    {
        return false;
    }

	if (!this->getParent())
	{
		CCLog("SFScrollView ccTouchBegan with none parent!!");
		return false;
	}

    CCRect frame;
    CCPoint frameOriginal = this->getParent()->convertToWorldSpace(this->getPosition());
    frame = CCRectMake(frameOriginal.x, frameOriginal.y, m_tViewSize.width, m_tViewSize.height);
    
    //dispatcher does not know about clipping. reject touches outside visible bounds.
    if (m_pTouches->count() > 2 ||
        m_bTouchMoved          ||
        !frame.containsPoint(m_pContainer->convertToWorldSpace(m_pContainer->convertTouchToNodeSpace(touch))))
    {
        return false;
    }

    if (!m_pTouches->containsObject(touch))
    {
        m_pTouches->addObject(touch);
    }

    if (m_pTouches->count() == 1)
    { // scrolling
        m_tTouchPoint     = this->convertTouchToNodeSpace(touch);
        m_bTouchMoved     = false;
        m_bDragging     = true; //dragging started
        m_tScrollDistance = ccp(0.0f, 0.0f);
        m_fTouchLength    = 0.0f;
		m_ptPrevContainerOffset = m_pContainer->getPosition();
    }
    else if (m_pTouches->count() == 2)
    {
        m_tTouchPoint  = ccpMidpoint(this->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(0)),
                                   this->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(1)));
        m_fTouchLength = ccpDistance(m_pContainer->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(0)),
                                   m_pContainer->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(1)));
        m_bDragging  = false;
    } 

	if (m_pDelegate)
		m_pDelegate->scrollViewTouchBegin(this, m_tTouchPoint);
	if (m_handler != 0)
	{
		CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeSFScrollView(m_handler, this, kScrollViewTouchBegin, m_tTouchPoint.x, m_tTouchPoint.y);
	}
	
    return true;
}

void SFScrollView::ccTouchMoved(CCTouch* touch, CCEvent* event)
{
    if (!this->isVisible())
    {
        return;
    }

	if (!this->getParent())
	{
		CCLog("SFScrollView ccTouchBegan with none parent!!");
		return;
	}

    if (m_pTouches->containsObject(touch))
    {
        if (m_pTouches->count() == 1 && m_bDragging)
        { // scrolling
            CCPoint moveDistance, newPoint, maxInset, minInset;
            CCRect  frame;
            float newX, newY;
            
            CCPoint frameOriginal = this->getParent()->convertToWorldSpace(this->getPosition());
            frame = CCRectMake(frameOriginal.x, frameOriginal.y, m_tViewSize.width, m_tViewSize.height);

            newPoint     = this->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(0));
            moveDistance = ccpSub(newPoint, m_tTouchPoint);
			if (4 < ccpDistanceSQ(newPoint, m_tTouchPoint))
			{
				m_bTouchMoved  = true;
			}

            m_tTouchPoint  = newPoint;
            
            if (frame.containsPoint(this->convertToWorldSpace(newPoint)))
            {
                switch (m_eDirection)
                {
                    case kSFScrollViewDirectionVertical:
                        moveDistance = ccp(0.0f, moveDistance.y);
                        break;
                    case kSFScrollViewDirectionHorizontal:
                        moveDistance = ccp(moveDistance.x, 0.0f);
                        break;
                    default:
                        break;
                }

                m_pContainer->setPosition(ccpAdd(m_pContainer->getPosition(), moveDistance));
                
                maxInset = m_fMaxInset;
                minInset = m_fMinInset;
                
                
                //check to see if offset lies within the inset bounds
                newX     = MIN(m_pContainer->getPosition().x, maxInset.x);
                newX     = MAX(newX, minInset.x);
                newY     = MIN(m_pContainer->getPosition().y, maxInset.y);
                newY     = MAX(newY, minInset.y);
                
                m_tScrollDistance     = ccpSub(moveDistance, ccp(newX - m_pContainer->getPosition().x, newY - m_pContainer->getPosition().y));
                this->setContentOffset(ccp(newX, newY));
            }
        }
        else if (m_pTouches->count() == 2 && !m_bDragging)
        {
            const float len = ccpDistance(m_pContainer->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(0)),
                                            m_pContainer->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(1)));
            this->setZoomScale(this->getZoomScale()*len/m_fTouchLength);
        }

		if (m_pDelegate && m_bTouchMoved)
			m_pDelegate->scrollViewTouchMove(this, m_tTouchPoint);
		if (m_handler != 0)
		{
			CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
			engine->executeSFScrollView(m_handler,this,kScrollViewTouchMove,m_tTouchPoint.x,m_tTouchPoint.y);
		}
    }
}

void SFScrollView::ccTouchEnded(CCTouch* touch, CCEvent* event)
{
    if (!this->isVisible())
    {
        return;
    }
    if (m_pTouches->containsObject(touch))
    {
		CCPoint newPoint = this->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(0));

		bool bAutoScorll = false;

        if (m_pTouches->count() == 1 && m_bTouchMoved && !m_bPageEnable && m_bAutoScroll)
            bAutoScorll = true;

		if (bAutoScorll)
		{
			this->schedule(schedule_selector(SFScrollView::deaccelerateScrolling));
		}
		else
		{
			if (m_bPageEnable) 
				this->setContentOffset(getPageOffset(getContentOffset()), true);

			if (m_pDelegate)
				m_pDelegate->scrollViewTouchEnd(this, newPoint);
			if (m_handler != 0)
			{
				CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
				engine->executeSFScrollView(m_handler,this,kScrollViewTouchEnd,newPoint.x,newPoint.y);
			}
		}

        m_pTouches->removeObject(touch);
    } 

    if (m_pTouches->count() == 0)
    {
        m_bDragging = false;    
        m_bTouchMoved = false;
    }
	
}

void SFScrollView::ccTouchCancelled(CCTouch* touch, CCEvent* event)
{
    if (!this->isVisible())
    {
        return;
    }
    m_pTouches->removeObject(touch); 
    if (m_pTouches->count() == 0)
    {
        m_bDragging = false;    
        m_bTouchMoved = false;
    }
}

void SFScrollView::setPageEnable( bool bEnable )
{
	m_bPageEnable = bEnable;
	m_pContainer->setPosition(getPageOffset(m_pContainer->getPosition()));

	if (m_pageSize.equals(CCSizeZero))
	{
		// 如果pageSize为0, 给一个默认值
		m_pageSize = m_tViewSize;
	}
}

CCPoint SFScrollView::getPageOffset( CCPoint pt )
{
	int page = 0;
	CCSize size;
	if (m_pageSize.width==0 || m_pageSize.height==0)
	{
		size = m_tViewSize;
	} 
	else
	{
		size = m_pageSize;
	}

	if (m_eDirection & kSFScrollViewDirectionHorizontal )
	{
		page = ((int)m_ptPrevContainerOffset.x)/((int)size.width);
//        CCLog("old page =%d, size.width=%f", page, size.width);

		if (m_ptPrevContainerOffset.x - pt.x > size.width*0.3)	//向左移动
        {
			page -= 1;
//            CCLog("page -= 1");
        }
		else if (pt.x - m_ptPrevContainerOffset.x >  size.width*0.3) //向右移动
        {
            page += 1;
//			CCLog("page += 1");
        }
		pt.x = page*size.width;
		if (pt.x > 0) {
			pt.x = 0;
		} else if (pt.x < -(getContentSize().width - m_tViewSize.width)) {
			pt.x = -(getContentSize().width - m_tViewSize.width);
		}

//		CCLog("page=%d x=%f width=%f m_ptPrevContainerOffset=%f", page, pt.x, getContentSize().width, m_ptPrevContainerOffset.x);
	}

	if (m_eDirection & kSFScrollViewDirectionVertical)
	{
		page = m_ptPrevContainerOffset.y/size.height;
		if (m_ptPrevContainerOffset.y - pt.y > size.height*0.3)
			page -= 1;
		else if (pt.y - m_ptPrevContainerOffset.y >  size.height*0.3)
			page += 1;
		
		pt.y = page*size.height;
	}
	return pt;
}

int SFScrollView::getPage()
{
	CCSize viewSize;
	if (m_pageSize.width==0 || m_pageSize.height==0)
	{
		viewSize = m_tViewSize;
	} 
	else
	{
		viewSize = m_pageSize;
	}

	if (m_eDirection == kSFScrollViewDirectionHorizontal)
	{
		m_page = -((int)m_pContainer->getPositionX())/((int)viewSize.width);
	}else{
		m_page = -((int)m_pContainer->getPositionY())/((int)viewSize.height);
	}
//    CCLog("x=%f, y=%f, width=%f, height=%f, page=%d, m_eDirection=%d",
//          m_pContainer->getPositionX(),
//          m_pContainer->getPositionY(),
//          m_tViewSize.width,
//          m_tViewSize.height,
//          m_page,
//          m_eDirection);
	return m_page;
}

void SFScrollView::setCurrentPage( int page )
{
	if (page < 0 || page == m_page)
	{
		return;
	}
	CCPoint point =CCPointZero;
	CCSize viewSize;
	if (m_pageSize.width==0 || m_pageSize.height==0)
	{
		viewSize = m_tViewSize;
	} 
	else
	{
		viewSize = m_pageSize;
	}
	if (m_eDirection == kSFScrollViewDirectionHorizontal)
	{
		point.x = page*viewSize.width;
	}else
	{
		point.y = page*viewSize.height;
	}
	m_pContainer->setPosition(point);
}

void SFScrollView::setPageSize( CCSize pageSize )
{
	m_pageSize = pageSize;
}

cocos2d::CCSize SFScrollView::getPageSize()
{
	return m_pageSize;
}
