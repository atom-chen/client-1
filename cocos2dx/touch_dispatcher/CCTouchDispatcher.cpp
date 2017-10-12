/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009      Valentin Milea

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

#include "CCTouchDispatcher.h"
#include "CCTouchHandler.h"
#include "cocoa/CCArray.h"
#include "cocoa/CCSet.h"
#include "CCTouch.h"
#include "textures/CCTexture2D.h"
#include "support/data_support/ccCArray.h"
#include "ccMacros.h"
#include "CCDirector.h"
#include "cocoa/CCDictionary.h"
#include <algorithm>

NS_CC_BEGIN

//Juchao@2014013: 
#define DISPATCHER_TOUCH_BY_Z

#ifdef DISPATCHER_TOUCH_BY_Z
static CCDictionary s_targetTouchHandlerBak;
static bool nodeIsVisible(CCNode* node)
{
	if (NULL == node || (!node->isVisible()) || (!node->isRunning()))
		return false;
	CCNode* pParent = node->getParent();
	for( CCNode *c = pParent; c != NULL; c = c->getParent() )
	{
		if( !c->isVisible() )
		{
			return false;
		}
	}
	return true;
}
#endif

/**
 * Used for sort
 */
static int less(const CCObject* p1, const CCObject* p2)
{
    return ((CCTouchHandler*)p1)->getPriority() < ((CCTouchHandler*)p2)->getPriority();
}

bool CCTouchDispatcher::isDispatchEvents(void)
{
    return m_bDispatchEvents;
}

void CCTouchDispatcher::setDispatchEvents(bool bDispatchEvents)
{
    m_bDispatchEvents = bDispatchEvents;
}

/*
+(id) allocWithZone:(CCZone *)zone
{
    @synchronized(self) {
        CCAssert(sharedDispatcher == nil, @"Attempted to allocate a second instance of a singleton.");
        return [super allocWithZone:zone];
    }
    return nil; // on subsequent allocation attempts return nil
}
*/

bool CCTouchDispatcher::init(void)
{
    m_bDispatchEvents = true;
    m_pTargetedHandlers = CCArray::createWithCapacity(8);
    m_pTargetedHandlers->retain();
     m_pStandardHandlers = CCArray::createWithCapacity(4);
    m_pStandardHandlers->retain();
    m_pHandlersToAdd = CCArray::createWithCapacity(8);
    m_pHandlersToAdd->retain();
    m_pHandlersToRemove = ccCArrayNew(8);

	m_bIsTouchHandlersDirty = false;
	m_lockedCount = 0;
    m_bToRemove = false;
    m_bToAdd = false;
    m_bToQuit = false;

    m_sHandlerHelperData[CCTOUCHBEGAN].m_type = CCTOUCHBEGAN;
    m_sHandlerHelperData[CCTOUCHMOVED].m_type = CCTOUCHMOVED;
    m_sHandlerHelperData[CCTOUCHENDED].m_type = CCTOUCHENDED;
    m_sHandlerHelperData[CCTOUCHCANCELLED].m_type = CCTOUCHCANCELLED;

    return true;
}

CCTouchDispatcher::~CCTouchDispatcher(void)
{
    CC_SAFE_RELEASE(m_pTargetedHandlers);
    CC_SAFE_RELEASE(m_pStandardHandlers);
    CC_SAFE_RELEASE(m_pHandlersToAdd);
 
    ccCArrayFree(m_pHandlersToRemove);
	m_pHandlersToRemove = NULL;    
}

//
// handlers management
//
void CCTouchDispatcher::forceAddHandler(CCTouchHandler *pHandler, CCArray *pArray)
{
#ifdef DISPATCHER_TOUCH_BY_Z  
    CCLog("CCTouchDispatcher::forceAddHandler doesn't work since DISPATCHER_TOUCH_BY_Z is defined");
#else 
    unsigned int u = 0;

    CCObject* pObj = NULL;
    CCARRAY_FOREACH(pArray, pObj)
     {
         CCTouchHandler *h = (CCTouchHandler *)pObj;
         if (h)
         {
             if (h->getPriority() < pHandler->getPriority())
             {
                 ++u;
             }
 
             if (h->getDelegate() == pHandler->getDelegate())
             {
                 CCAssert(0, "");
                 return;
             }
         }
     }

    pArray->insertObject(pHandler, u);
#endif
}

void CCTouchDispatcher::addStandardDelegate(CCTouchDelegate *pDelegate, int nPriority)
{ 
#ifdef DISPATCHER_TOUCH_BY_Z
	CCNode *node = dynamic_cast<CCNode*>(pDelegate);
	if (NULL == node) 
	{
		CCAssert(false, "CCTouchDispatcher::addStandardDelegate pDelegate must be CCNode too");
		return;
	}
	node->setTouchType(kStandardTouch);
    m_bIsTouchHandlersDirty = true;
#else
    CCTouchHandler *pHandler = CCStandardTouchHandler::handlerWithDelegate(pDelegate, nPriority);
    if (! isLocked())
    {
        forceAddHandler(pHandler, m_pStandardHandlers);
    }
    else
    {
        /* If pHandler is contained in m_pHandlersToRemove, if so remove it from m_pHandlersToRemove and return.
         * Refer issue #752(cocos2d-x)
         */
        if (ccCArrayContainsValue(m_pHandlersToRemove, pDelegate))
        {
            ccCArrayRemoveValue(m_pHandlersToRemove, pDelegate);
            return;
        }

        m_pHandlersToAdd->addObject(pHandler);
        m_bToAdd = true;
    }
#endif
}

void CCTouchDispatcher::addTargetedDelegate(CCTouchDelegate *pDelegate, int nPriority, bool bSwallowsTouches)
{   
#ifdef DISPATCHER_TOUCH_BY_Z
	if (pDelegate == NULL)
		return;
	CCNode *node = dynamic_cast<CCNode*>(pDelegate);
	if (NULL == node) 
	{
		CCAssert(false, "CCTouchDispatcher::addStandardDelegate pDelegate must be CCNode too");
		return;
	}
	node->setTouchType(kTargetedTouch);
	node->setIsSwallowsTouches(bSwallowsTouches);
    m_bIsTouchHandlersDirty = true;
#else

    CCTouchHandler *pHandler = CCTargetedTouchHandler::handlerWithDelegate(pDelegate, nPriority, bSwallowsTouches);
    if (! isLocked())
    {
        forceAddHandler(pHandler, m_pTargetedHandlers);
    }
    else
    {
        /* If pHandler is contained in m_pHandlersToRemove, if so remove it from m_pHandlersToRemove and return.
         * Refer issue #752(cocos2d-x)
         */
        if (ccCArrayContainsValue(m_pHandlersToRemove, pDelegate))
        {
            ccCArrayRemoveValue(m_pHandlersToRemove, pDelegate);
            return;
        }
        
        m_pHandlersToAdd->addObject(pHandler);
        m_bToAdd = true;
    }
#endif
}

void CCTouchDispatcher::forceRemoveDelegate(CCTouchDelegate *pDelegate)
{
    CCTouchHandler *pHandler;

    // XXX: remove it from both handlers ???
    
    // remove handler from m_pStandardHandlers
    CCObject* pObj = NULL;
    CCARRAY_FOREACH(m_pStandardHandlers, pObj)
    {
        pHandler = (CCTouchHandler*)pObj;
        if (pHandler && pHandler->getDelegate() == pDelegate)
        {
            m_pStandardHandlers->removeObject(pHandler);
            break;
        }
    }

    // remove handler from m_pTargetedHandlers
    CCARRAY_FOREACH(m_pTargetedHandlers, pObj)
    {
        pHandler = (CCTouchHandler*)pObj;
        if (pHandler && pHandler->getDelegate() == pDelegate)
        {
            
#ifdef DISPATCHER_TOUCH_BY_Z
			//只有有继承关系的类之间才能使用强制转换，即使用括号转换(CCNode*)，否则转换后会造成运行结果不对
			if (dynamic_cast<CCObject*>(pDelegate)) 
				s_targetTouchHandlerBak.removeObjectForKey((dynamic_cast<CCObject*>(pDelegate))->m_uID);
#endif
			m_pTargetedHandlers->removeObject(pHandler);
            break;
        }
    }
}

void CCTouchDispatcher::removeDelegate(CCTouchDelegate *pDelegate)
{
    if (pDelegate == NULL)
    {
        return;
	}

#ifdef DISPATCHER_TOUCH_BY_Z
	CCNode *node = dynamic_cast<CCNode*>(pDelegate);
	if (node == NULL)
		return;
    
	node->setTouchType(kNoTouch);
	m_bIsTouchHandlersDirty = true;
#endif
    if (! isLocked())
    {
        forceRemoveDelegate(pDelegate);
    }
    else
    {
        /* If pHandler is contained in m_pHandlersToAdd, if so remove it from m_pHandlersToAdd and return.
         * Refer issue #752(cocos2d-x)
         */
        CCTouchHandler *pHandler = findHandler(m_pHandlersToAdd, pDelegate);
        if (pHandler)
        {
            m_pHandlersToAdd->removeObject(pHandler);
            return;
        }

        ccCArrayAppendValue(m_pHandlersToRemove, pDelegate);
        m_bToRemove = true;
    }
}

void CCTouchDispatcher::forceRemoveAllDelegates(void)
{
     m_pStandardHandlers->removeAllObjects();
     m_pTargetedHandlers->removeAllObjects();
#ifdef DISPATCHER_TOUCH_BY_Z 
	 s_targetTouchHandlerBak.removeAllObjects();
	 m_bIsTouchHandlersDirty = true;
#endif
}

void CCTouchDispatcher::removeAllDelegates(void)
{
    if (! isLocked())
    {
        forceRemoveAllDelegates();
    }
    else
    {
        m_bToQuit = true;
    }
}

CCTouchHandler* CCTouchDispatcher::findHandler(CCTouchDelegate *pDelegate)
{
#ifdef DISPATCHER_TOUCH_BY_Z   
	return NULL;
#else
	CCObject* pObj = NULL;
    CCARRAY_FOREACH(m_pTargetedHandlers, pObj)
    {
        CCTouchHandler* pHandler = (CCTouchHandler*)pObj;
        if (pHandler->getDelegate() == pDelegate)
        {
            return pHandler;
        }
    }

    CCARRAY_FOREACH(m_pStandardHandlers, pObj)
    {
        CCTouchHandler* pHandler = (CCTouchHandler*)pObj;
        if (pHandler->getDelegate() == pDelegate)
        {
            return pHandler;
        }
    } 

    return NULL;
#endif
}

CCTouchHandler* CCTouchDispatcher::findHandler(CCArray* pArray, CCTouchDelegate *pDelegate)
{
    CCAssert(pArray != NULL && pDelegate != NULL, "");

    CCObject* pObj = NULL;
    CCARRAY_FOREACH(pArray, pObj)
    {
        CCTouchHandler* pHandle = (CCTouchHandler*)pObj;
        if (pHandle->getDelegate() == pDelegate)
        {
            return pHandle;
        }
    }

    return NULL;
}

void CCTouchDispatcher::rearrangeHandlers(CCArray *pArray)
{
#ifdef DISPATCHER_TOUCH_BY_Z 
    CCLog("CCTouchDispatcher::rearrangeHandlers doesn't work since DISPATCHER_TOUCH_BY_Z is defined");
#else
    std::sort(pArray->data->arr, pArray->data->arr + pArray->data->num, less);
#endif
}

void CCTouchDispatcher::setPriority(int nPriority, CCTouchDelegate *pDelegate)
{
#ifdef DISPATCHER_TOUCH_BY_Z
    CCLog("CCTouchDispatcher::setPriority doesn't work since DISPATCHER_TOUCH_BY_Z is defined");
#else
    CCAssert(pDelegate != NULL, "");

    CCTouchHandler *handler = NULL;

    handler = this->findHandler(pDelegate);

    CCAssert(handler != NULL, "");
	
    if (handler->getPriority() != nPriority)
    {
        handler->setPriority(nPriority);
        this->rearrangeHandlers(m_pTargetedHandlers);
        this->rearrangeHandlers(m_pStandardHandlers);
    }
#endif
}

bool CCTouchDispatcher::isLocked()
{
	return m_lockedCount > 0;
}

//
// dispatch events
//
void CCTouchDispatcher::touches(CCSet *pTouches, CCEvent *pEvent, unsigned int uIndex)
{
    CCAssert(uIndex >= 0 && uIndex < 4, "");
    
    if (isLocked())
		return;
    
#ifdef DISPATCHER_TOUCH_BY_Z
	updateTouchHandlers();
#endif
    CCSet *pMutableTouches;
    ++m_lockedCount;
    // optimization to prevent a mutable copy when it is not necessary
    unsigned int uTargetedHandlersCount = m_pTargetedHandlers->count();
    unsigned int uStandardHandlersCount = m_pStandardHandlers->count();
    bool bNeedsMutableSet = (uTargetedHandlersCount && uStandardHandlersCount);

    pMutableTouches = (bNeedsMutableSet ? pTouches->mutableCopy() : pTouches);

    struct ccTouchHandlerHelperData sHelper = m_sHandlerHelperData[uIndex];
    //
    // process the target handlers 1st
    //
    if (uTargetedHandlersCount > 0)
    {
        CCTouch *pTouch;
        CCSetIterator setIter;
        for (setIter = pTouches->begin(); setIter != pTouches->end(); ++setIter)
        {
            pTouch = (CCTouch *)(*setIter);

            CCTargetedTouchHandler *pHandler = NULL;
            CCObject* pObj = NULL;
#ifdef DISPATCHER_TOUCH_BY_Z
			ccArray *arrayData = m_pTargetedHandlers->data;
			unsigned int i = uTargetedHandlersCount - 1;	//Juchao@20140110: 浠庢渶鍚庡紑濮嬮亶鍘嗭紝鍥犱负鏈�鍚庣殑瀵硅薄鍦ㄦ渶椤朵笂锛屼紭鍏堢骇鏈�楂樸�傚彟澶栵紝i涓烘棤绗﹀彿鏁村舰锛?-1鍚庝細鍙樻渶澶с�傛案杩滀笉浼氬皬浜?
			do
			{
				pObj = arrayData->arr[i];
#else
            CCARRAY_FOREACH(m_pTargetedHandlers, pObj)
			{
#endif	
                pHandler = (CCTargetedTouchHandler *)(pObj);

                if (! pHandler)
                {
                    break;
                }
                bool bClaimed = false;
                if (uIndex == CCTOUCHBEGAN)
                {
                    bClaimed = pHandler->getDelegate()->ccTouchBegan(pTouch, pEvent);
                    
                    if (bClaimed)
                    {
                        pHandler->getClaimedTouches()->addObject(pTouch);
                    }
				} else
                if (pHandler->getClaimedTouches()->containsObject(pTouch))
				{
					// moved ended canceled
					bClaimed = true;

					switch (sHelper.m_type)
					{
					case CCTOUCHMOVED:
						pHandler->getDelegate()->ccTouchMoved(pTouch, pEvent);
						break;
					case CCTOUCHENDED:
						pHandler->getDelegate()->ccTouchEnded(pTouch, pEvent);
						pHandler->getClaimedTouches()->removeObject(pTouch);
						break;
					case CCTOUCHCANCELLED:
						pHandler->getDelegate()->ccTouchCancelled(pTouch, pEvent);
						pHandler->getClaimedTouches()->removeObject(pTouch);
						break;
					}
                }

                if (bClaimed && pHandler->isSwallowsTouches())
                {
                    if (bNeedsMutableSet)
                    {
                        pMutableTouches->removeObject(pTouch);
                    }

                    break;
                }
#ifdef  DISPATCHER_TOUCH_BY_Z
				if (i > 0)						
					--i;
				else
					break;
			} while (true);
#else
            }
#endif
        }
    }

    //
    // process standard handlers 2nd
    //
    if (uStandardHandlersCount > 0 && pMutableTouches->count() > 0)
    {
        CCStandardTouchHandler *pHandler = NULL;
        CCObject* pObj = NULL;
#ifdef DISPATCHER_TOUCH_BY_Z
		ccArray *arrayData = m_pStandardHandlers->data;
		unsigned int i = uStandardHandlersCount - 1;	//Juchao@20140110: 浠庢渶鍚庡紑濮嬮亶鍘嗭紝鍥犱负鏈�鍚庣殑瀵硅薄鍦ㄦ渶椤朵笂锛屼紭鍏堢骇鏈�楂樸�傚彟澶栵紝i涓烘棤绗﹀彿鏁村舰锛?-1鍚庝細鍙樻渶澶с�傛案杩滀笉浼氬皬浜?
		do
		{
			pObj = arrayData->arr[i];
#else
		CCARRAY_FOREACH(m_pStandardHandlers, pObj)
		{
#endif	
            pHandler = (CCStandardTouchHandler*)(pObj);

            if (! pHandler)
            {
                break;
            }

            switch (sHelper.m_type)
            {
            case CCTOUCHBEGAN:
                pHandler->getDelegate()->ccTouchesBegan(pMutableTouches, pEvent);
                break;
            case CCTOUCHMOVED:
                pHandler->getDelegate()->ccTouchesMoved(pMutableTouches, pEvent);
                break;
            case CCTOUCHENDED:
                pHandler->getDelegate()->ccTouchesEnded(pMutableTouches, pEvent);
                break;
            case CCTOUCHCANCELLED:
                pHandler->getDelegate()->ccTouchesCancelled(pMutableTouches, pEvent);
                break;
            }
#ifdef  DISPATCHER_TOUCH_BY_Z
			if (i > 0)				
				--i;
			else
				break;
		} while (true);
#else
		}
#endif
    }

    if (bNeedsMutableSet)
    {
        pMutableTouches->release();
    }

    //
    // Optimization. To prevent a [handlers copy] which is expensive
    // the add/removes/quit is done after the iterations
    //
    --m_lockedCount;
    if (m_bToRemove)
    {
        m_bToRemove = false;
        for (unsigned int i = 0; i < m_pHandlersToRemove->num; ++i)
        {
            forceRemoveDelegate((CCTouchDelegate*)m_pHandlersToRemove->arr[i]);
        }
        ccCArrayRemoveAllValues(m_pHandlersToRemove);
    }

#ifndef DISPATCHER_TOUCH_BY_Z
    if (m_bToAdd)
    {
        m_bToAdd = false;
        CCTouchHandler* pHandler = NULL;
        CCObject* pObj = NULL;
        CCARRAY_FOREACH(m_pHandlersToAdd, pObj)
         {
             pHandler = (CCTouchHandler*)pObj;
            if (! pHandler)
            {
                break;
            }

            if (dynamic_cast<CCTargetedTouchHandler*>(pHandler) != NULL)
            {                
                forceAddHandler(pHandler, m_pTargetedHandlers);
            }
            else
            {
                forceAddHandler(pHandler, m_pStandardHandlers);
            }
         }
 
         m_pHandlersToAdd->removeAllObjects();    
    }
#endif
    
    if (m_bToQuit)
    {
        m_bToQuit = false;
        forceRemoveAllDelegates();
    }
}

void CCTouchDispatcher::addStandardHandler(CCNode *node)
{
#ifdef DISPATCHER_TOUCH_BY_Z
	if (!isLocked())
	{
		//m_pStandardHandlers->removeObject(node);
		CCTouchDelegate* pDelegate = dynamic_cast<CCTouchDelegate*>(node);
		if (NULL == pDelegate)
		{
			CCAssert(false, "CCTouchDispatcher::addStandardHandler node must be CCTouchDelegate too");
			return;
		}
		CCTouchHandler *pHandler = CCStandardTouchHandler::handlerWithDelegate(pDelegate, 10);
		m_pStandardHandlers->addObject(pHandler);
	}
#else
    CCLog("CCTouchDispatcher::addStandardHandler doesn't work since DISPATCHER_TOUCH_BY_Z is not defined");
#endif
}

void CCTouchDispatcher::addTargetedHandler(CCNode *node)
{
#ifdef DISPATCHER_TOUCH_BY_Z
	if (!isLocked())
	{
		//m_pTargetedHandlers->removeObject(node);
		CCTouchDelegate* pDelegate = dynamic_cast<CCTouchDelegate*>(node);
		if (NULL == pDelegate)
		{
			CCAssert(false, "CCTouchDispatcher::addTargetedHandler node must be CCTouchDelegate too");
			return;
		}
        
        CCTouchHandler *pHandler = (CCTouchHandler*)s_targetTouchHandlerBak.objectForKey(node->m_uID);
        if (NULL == pHandler) {
            pHandler = CCTargetedTouchHandler::handlerWithDelegate(pDelegate, 20, node->getIsSwallowsTouches());
            //Juchao@20140703:
            s_targetTouchHandlerBak.setObject(pHandler, node->m_uID);
		}
        m_pTargetedHandlers->addObject(pHandler);
    }
#else
    CCLog("CCTouchDispatcher::addTargetedHandler doesn't work since DISPATCHER_TOUCH_BY_Z is not defined");
#endif
}

//Juchao@20140703: to update all touch handlers by z order. It's called before dispatch touch event.
void CCTouchDispatcher::updateTouchHandlers()
{
#ifdef DISPATCHER_TOUCH_BY_Z
    if (!m_bIsTouchHandlersDirty)
        return;
    
    CCNode* runningScene = (CCNode*)(CCDirector::sharedDirector()->getRunningScene());
    if (NULL == runningScene)
        return;

	//clear touch handlers
	clearStandardHandler();
	clearTargetedHandler();
    
    //scan root node recursively to find node registered touch event, and add it to touch handler/s_targetTouchHandlerBak by touch type
    updateTouchHandlersRecursively(runningScene);
    
    //remove unused targeted handlers(the node that doesn't exist in) from s_targetTouchHandlerBak
    removeUnusedTargetedHandlerBak();
    
    //now touch handlers is clean
    m_bIsTouchHandlersDirty = false;
#else
    CCLog("CCTouchDispatcher::addTargetedHandler doesn't work since DISPATCHER_TOUCH_BY_Z is not defined");
#endif
}

void CCTouchDispatcher::updateTouchHandlersRecursively(CCNode *node)
{
	if (!node->isVisible())
		return;
    
	CCArray* children = node->getChildren();
	unsigned int count = -1;
	if(children && children->count() > 0)
	{
		count = children->count();
		CCNode* pChildNode = NULL;
		unsigned int i = 0;
		ccArray *arrayData = children->data;
		for( ; i < arrayData->num; i++ )
		{
			pChildNode = (CCNode*) arrayData->arr[i];
			if (pChildNode->getZOrder() < 0)
				updateTouchHandlersRecursively(pChildNode);
			else
				break;
		}
        
		addTouchHandler(node);
        
		for( ; i < arrayData->num; i++ )
		{
			pChildNode = (CCNode*) arrayData->arr[i];
			updateTouchHandlersRecursively(pChildNode);
		}
	}
	else
	{
		addTouchHandler(node);
	}
}

void CCTouchDispatcher::addTouchHandler(CCNode* node)
{
	if (node->getTouchType() == kStandardTouch)
	{
		addStandardHandler(node);
	}
	else if (node->getTouchType() == kTargetedTouch)
	{
		addTargetedHandler(node);
	}
}


void CCTouchDispatcher::clearStandardHandler()
{
#ifdef DISPATCHER_TOUCH_BY_Z
	if (!isLocked())
        m_pStandardHandlers->removeAllObjects();
#else
    CCLog("CCTouchDispatcher::clearStandardHandler doesn't work since DISPATCHER_TOUCH_BY_Z is not defined");
#endif
}

void CCTouchDispatcher::clearTargetedHandler()
{
#ifdef DISPATCHER_TOUCH_BY_Z
    if (!isLocked())
        m_pTargetedHandlers->removeAllObjects();
#else
    CCLog("CCTouchDispatcher::clearTargetedHandler doesn't work since DISPATCHER_TOUCH_BY_Z is not defined");
#endif
}

void CCTouchDispatcher::removeUnusedTargetedHandlerBak()
{
#ifdef DISPATCHER_TOUCH_BY_Z
    UT_hash_handle hh;
    CCDictElement *pElement, *tmp;
    CCNode *node;
	CCTouchHandler *handler;
    HASH_ITER(hh, s_targetTouchHandlerBak.m_pElements, pElement, tmp)
    {
        handler = (CCTouchHandler*)pElement->getObject();
		node = dynamic_cast<CCNode*>(handler->getDelegate());
		
		if (node && (node->getTouchType() == kNoTouch || (!nodeIsVisible(node)))) {
			HASH_DEL(s_targetTouchHandlerBak.m_pElements, pElement);
			node->release();
			CC_SAFE_DELETE(pElement);
		}
    }
//	CCLog("s_targetTouchHandlerBak count===== %d", s_targetTouchHandlerBak.count());
//	CCLog("m_pTargetedHandlers count===== %d", m_pTargetedHandlers->count());
//	CCLog("m_pStandardHandlers count===== %d", m_pStandardHandlers->count());
#else
    CCLog("CCTouchDispatcher::clearTargetedHandler doesn't work since DISPATCHER_TOUCH_BY_Z is not defined");
#endif
}


void CCTouchDispatcher::touchesBegan(CCSet *touches, CCEvent *pEvent)
{
    if (m_bDispatchEvents)
    {
        this->touches(touches, pEvent, CCTOUCHBEGAN);
	}
}

void CCTouchDispatcher::touchesMoved(CCSet *touches, CCEvent *pEvent)
{
    if (m_bDispatchEvents)
    {
        this->touches(touches, pEvent, CCTOUCHMOVED);
	}
}

void CCTouchDispatcher::touchesEnded(CCSet *touches, CCEvent *pEvent)
{
    if (m_bDispatchEvents)
    {
        this->touches(touches, pEvent, CCTOUCHENDED);
	}
}

void CCTouchDispatcher::touchesCancelled(CCSet *touches, CCEvent *pEvent)
{
    if (m_bDispatchEvents)
    {
        this->touches(touches, pEvent, CCTOUCHCANCELLED);
    }
}

NS_CC_END
