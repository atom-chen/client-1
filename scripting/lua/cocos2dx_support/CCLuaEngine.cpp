/****************************************************************************
 Copyright (c) 2011 cocos2d-x.org

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

#include "CCLuaEngine.h"
#include "cocos2d.h"
#include "cocoa/CCArray.h"
#include "CCScheduler.h"

NS_CC_BEGIN

CCLuaEngine* CCLuaEngine::m_defaultEngine = NULL;

CCLuaEngine* CCLuaEngine::defaultEngine(void)
{
    if (!m_defaultEngine)
    {
        m_defaultEngine = new CCLuaEngine();
        m_defaultEngine->init();
    }
    return m_defaultEngine;
}

CCLuaEngine::~CCLuaEngine(void)
{
    CC_SAFE_RELEASE(m_stack);
    m_defaultEngine = NULL;
}

bool CCLuaEngine::init(void)
{
    m_stack = CCLuaStack::create();
    m_stack->retain();
    return true;
}

void CCLuaEngine::addSearchPath(const char* path)
{
    m_stack->addSearchPath(path);
}

void CCLuaEngine::addLuaLoader(lua_CFunction func)
{
    m_stack->addLuaLoader(func);
}

void CCLuaEngine::removeScriptObjectByCCObject(CCObject* pObj)
{
    m_stack->removeScriptObjectByCCObject(pObj);
}

void CCLuaEngine::removeScriptHandler(int nHandler)
{
    m_stack->removeScriptHandler(nHandler);
}

int CCLuaEngine::executeString(const char *codes)
{
    int ret = m_stack->executeString(codes);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeScriptFile(const char* filename)
{
    int ret = m_stack->executeScriptFile(filename);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeGlobalFunction(const char* functionName)
{
    int ret = m_stack->executeGlobalFunction(functionName);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeNodeEvent(CCNode* pNode, int nAction)
{
    int nHandler = pNode->getScriptHandler();
    if (!nHandler) return 0;
    
    switch (nAction)
    {
        case kCCNodeOnEnter:
            m_stack->pushString("enter");
            break;
            
        case kCCNodeOnExit:
            m_stack->pushString("exit");
            break;
            
        case kCCNodeOnEnterTransitionDidFinish:
            m_stack->pushString("enterTransitionFinish");
            break;
            
        case kCCNodeOnExitTransitionDidStart:
            m_stack->pushString("exitTransitionStart");
            break;
            
        case kCCNodeOnCleanup:
            m_stack->pushString("cleanup");
            break;
            
        default:
            return 0;
    }
    int ret = m_stack->executeFunctionByHandler(nHandler, 1);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeMenuItemEvent(CCMenuItem* pMenuItem)
{
    int nHandler = pMenuItem->getScriptTapHandler();
    if (!nHandler) return 0;
    
    m_stack->pushInt(pMenuItem->getTag());
    m_stack->pushCCObject(pMenuItem, "CCMenuItem");
    int ret = m_stack->executeFunctionByHandler(nHandler, 2);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeNotificationEvent(CCNotificationCenter* pNotificationCenter, const char* pszName)
{
	CCLog("executeNotificationEvent");
    int nHandler = pNotificationCenter->getScriptHandler();
    if (!nHandler) return 0;
    
    m_stack->pushString(pszName);
    int ret = m_stack->executeFunctionByHandler(nHandler, 1);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeCallFuncActionEvent(CCCallFunc* pAction, CCObject* pTarget/* = NULL*/)
{
    int nHandler = pAction->getScriptHandler();
    if (!nHandler) return 0;
    
    if (pTarget)
    {
        m_stack->pushCCObject(pTarget, "CCNode");
    }
    int ret = m_stack->executeFunctionByHandler(nHandler, pTarget ? 1 : 0);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeSchedule(int nHandler, float dt, CCNode* pNode/* = NULL*/)
{
    if (!nHandler) return 0;
    m_stack->pushFloat(dt);
    int ret = m_stack->executeFunctionByHandler(nHandler, 1);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeLayerTouchEvent(CCLayer* pLayer, int eventType, CCTouch *pTouch)
{
    CCTouchScriptHandlerEntry* pScriptHandlerEntry = pLayer->getScriptTouchHandlerEntry();
    if (!pScriptHandlerEntry) return 0;
    int nHandler = pScriptHandlerEntry->getHandler();
    if (!nHandler) return 0;
    
    switch (eventType)
    {
        case CCTOUCHBEGAN:
            m_stack->pushString("began");
            break;
            
        case CCTOUCHMOVED:
            m_stack->pushString("moved");
            break;
            
        case CCTOUCHENDED:
            m_stack->pushString("ended");
            break;
            
        case CCTOUCHCANCELLED:
            m_stack->pushString("cancelled");
            break;
            
        default:
            return 0;
    }
    
    const CCPoint pt = CCDirector::sharedDirector()->convertToGL(pTouch->getLocationInView());
    m_stack->pushFloat(pt.x);
    m_stack->pushFloat(pt.y);
    int ret = m_stack->executeFunctionByHandler(nHandler, 3);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeLayerTouchesEvent(CCLayer* pLayer, int eventType, CCSet *pTouches)
{
    CCTouchScriptHandlerEntry* pScriptHandlerEntry = pLayer->getScriptTouchHandlerEntry();
    if (!pScriptHandlerEntry) return 0;
    int nHandler = pScriptHandlerEntry->getHandler();
    if (!nHandler) return 0;
    
    switch (eventType)
    {
        case CCTOUCHBEGAN:
            m_stack->pushString("began");
            break;
            
        case CCTOUCHMOVED:
            m_stack->pushString("moved");
            break;
            
        case CCTOUCHENDED:
            m_stack->pushString("ended");
            break;
            
        case CCTOUCHCANCELLED:
            m_stack->pushString("cancelled");
            break;
            
        default:
            return 0;
    }

    CCDirector* pDirector = CCDirector::sharedDirector();
    lua_State *L = m_stack->getLuaState();
    lua_newtable(L);
    int i = 1;
    for (CCSetIterator it = pTouches->begin(); it != pTouches->end(); ++it)
    {
        CCTouch* pTouch = (CCTouch*)*it;
        CCPoint pt = pDirector->convertToGL(pTouch->getLocationInView());
        lua_pushnumber(L, pt.x);
        lua_rawseti(L, -2, i++);
        lua_pushnumber(L, pt.y);
        lua_rawseti(L, -2, i++);
        lua_pushinteger(L, pTouch->getID());
        lua_rawseti(L, -2, i++);
    }
    int ret = m_stack->executeFunctionByHandler(nHandler, 2);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeLayerKeypadEvent(CCLayer* pLayer, int eventType)
{
    CCScriptHandlerEntry* pScriptHandlerEntry = pLayer->getScriptKeypadHandlerEntry();
    if (!pScriptHandlerEntry)
        return 0;
    int nHandler = pScriptHandlerEntry->getHandler();
    if (!nHandler) return 0;
    
    switch (eventType)
    {
        case kTypeBackClicked:
            m_stack->pushString("backClicked");
            break;
            
        case kTypeMenuClicked:
            m_stack->pushString("menuClicked");
            break;
            
        default:
            return 0;
    }
    int ret = m_stack->executeFunctionByHandler(nHandler, 1);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeAccelerometerEvent(CCLayer* pLayer, CCAcceleration* pAccelerationValue)
{
    CCScriptHandlerEntry* pScriptHandlerEntry = pLayer->getScriptAccelerateHandlerEntry();
    if (!pScriptHandlerEntry)
        return 0;
    int nHandler = pScriptHandlerEntry->getHandler();
    if (!nHandler) return 0;
    
    m_stack->pushFloat(pAccelerationValue->x);
    m_stack->pushFloat(pAccelerationValue->y);
    m_stack->pushFloat(pAccelerationValue->z);
    m_stack->pushFloat(pAccelerationValue->timestamp);
    int ret = m_stack->executeFunctionByHandler(nHandler, 4);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeEvent(int nHandler, const char* pEventName, CCObject* pEventSource /* = NULL*/, const char* pEventSourceClassName /* = NULL*/)
{
    m_stack->pushString(pEventName);
    if (pEventSource)
    {
        m_stack->pushCCObject(pEventSource, pEventSourceClassName ? pEventSourceClassName : "CCObject");
    }
    int ret = m_stack->executeFunctionByHandler(nHandler, pEventSource ? 2 : 1);
    m_stack->clean();
    return ret;
}

bool CCLuaEngine::handleAssert(const char *msg)
{
    bool ret = m_stack->handleAssert(msg);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::reallocateScriptHandler(int nHandler)
{    
    int nRet = m_stack->reallocateScriptHandler(nHandler);
    m_stack->clean();
    return nRet;
}

int CCLuaEngine::executeControlEvent( int nHandler, int nHandleEvent )
{
	if (0 == nHandler)
		return 0;

	m_stack->pushInt(nHandleEvent);
	int nRet = m_stack->executeFunctionByHandler(nHandler, 1);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeFunctionWithObject( int nHandler, void* eventReader,int eventType )
{
	if (0 == nHandler)
		return 0;

	m_stack->pushUserData(eventReader);
	m_stack->pushInt(eventType);
	int nRet = m_stack->executeFunctionByHandler(nHandler, 2);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeSceneEvent( int nHandler, SFGameScene* scene, int event, const char* oldSceneName )
{
	if (0 == nHandler)
		return 0;

	m_stack->pushUserData((void*)scene);
	m_stack->pushInt(event);
	m_stack->pushString(oldSceneName, strlen(oldSceneName));
	int nRet = m_stack->executeFunctionByHandler(nHandler, 3);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeTableViewDataSourceEvent( int nHandler,int eventType,SFTableView* table, unsigned int index,SFTableData* data )
{
	if (0 == nHandler)
		return 0;
	m_stack->pushInt(eventType);
	m_stack->pushUserData((void*)table);
	m_stack->pushInt(index);
	m_stack->pushUserData((void*)data);
	int nRet = m_stack->executeFunctionByHandler(nHandler, 4);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeTableViewTouchEvent( int nHandler, SFTableView* table, SFTableViewCell* cell,CCPoint point )
{
	if (0 == nHandler)
		return 0;
	m_stack->pushUserData((void*)table);
	m_stack->pushUserData((void*)cell);
	m_stack->pushFloat(point.x);
	m_stack->pushFloat(point.y);
	int nRet = m_stack->executeFunctionByHandler(nHandler, 4);
	m_stack->clean();
	return nRet;
}

int  CCLuaEngine::executeGridBoxDataSourceEvent( int nHandler,SFGridBox *gridBox, int index, float width,float height,CCNode* node)
{
	if (0 == nHandler)
		return 0;
	m_stack->pushUserData((void*)gridBox);
	m_stack->pushInt(index);
	m_stack->pushFloat(width);
	m_stack->pushFloat(height);
	m_stack->pushUserData((void*)node);
	int nRet = m_stack->executeFunctionByHandler(nHandler, 5);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeGirdBoxTouchEvent( int nHandler,int eventType,SFGridBox *gridBox, int index, CCTouch *pTouch )
{
	if (0 == nHandler)
		return 0;
	m_stack->pushInt(eventType);
	m_stack->pushUserData((void*)gridBox);
	m_stack->pushInt(index);
	m_stack->pushUserData((void*)pTouch);
	int nRet = m_stack->executeFunctionByHandler(nHandler,4);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeJoyRockerDelegate( int nhandler,int eventType,SFJoyRocker* rocker,int dir )
{
	if (0 == nhandler)
		return 0;
	m_stack->pushInt(eventType);
	m_stack->pushUserData((void*)rocker);
	m_stack->pushInt(dir);
	int nRet = m_stack->executeFunctionByHandler(nhandler,3);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeHttpEvent( int nhandler,int state,const char* tag,const char* responeData, int len )
{
	if (0 == nhandler)
		return 0;
	m_stack->pushInt(state);
	m_stack->pushString(tag);
	m_stack->pushString(responeData, len);
	int nRet = m_stack->executeFunctionByHandler(nhandler,3);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeBagBoxDataSourceEvent( int nHandler,SFBagGridBox* bagBox,int index,float width,float height, SFBagData* data )
{
	if (0 == nHandler)
		return 0;
	m_stack->pushUserData((void*)bagBox);
	m_stack->pushInt(index);
	m_stack->pushFloat(width);
	m_stack->pushFloat(height);
	m_stack->pushUserData((void*)data);
	int nRet = m_stack->executeFunctionByHandler(nHandler,5);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeSFScrollView( int nHandler,SFScrollView* scrollView,int eventType,float x,float y )
{
	if (0 == nHandler)
		return 0;
	m_stack->pushUserData((void*)scrollView);
	m_stack->pushInt(eventType);
	m_stack->pushFloat(x);
	m_stack->pushFloat(y);
	int nRet = m_stack->executeFunctionByHandler(nHandler,4);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeRichBoxTouchEvent( int nHander,const char* eventStr, CCTouch *pTouch )
{
	if (0 == nHander)
		return 0;
	m_stack->pushString(eventStr);
	m_stack->pushUserData((void*)pTouch);
	int nRet = m_stack->executeFunctionByHandler(nHander,2);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeSpriteActionEvent( int nHander, int nActionId, int movementType )
{
	if (0 == nHander)
		return 0;
	m_stack->pushInt(nActionId);
	m_stack->pushInt(movementType);
	int nRet = m_stack->executeFunctionByHandler(nHander,2);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeLoadingBackground( int nHander, float per, const char* currentFilename )
{
	if (0 == nHander)
		return 0;
	m_stack->pushFloat(per);
	m_stack->pushString(currentFilename);
	int nRet = m_stack->executeFunctionByHandler(nHander,2);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeRenderSprLoad( int nHandler, CCNode* node, int layerTag )
{
	if (0 == nHandler)
		return 0;
	m_stack->pushUserData((void*)node);
	m_stack->pushInt(layerTag);
	int nRet = m_stack->executeFunctionByHandler(nHandler,2);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeLoginCB(int nHandler, const char* data,  int len, int errCode)
{
	if (0 == nHandler)
		return 0;
	m_stack->pushString(data, len);
	m_stack->pushInt(errCode);
	int nRet = m_stack->executeFunctionByHandler(nHandler,2);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executePatchCallBack( int nHandler, int eventCode, int errorCode, int current, int total )
{
	if (0 == nHandler)
		return 0;
	m_stack->pushInt(eventCode);
	m_stack->pushInt(errorCode);
	m_stack->pushInt(current);
	m_stack->pushInt(total);
	int nRet = m_stack->executeFunctionByHandler(nHandler,4);
	m_stack->clean();
	return nRet;
}

int CCLuaEngine::executeDownloadCallBack( int nHandler,int eventCode, int intValue, const char* stringData,float doubleValue )
{
	if (0 == nHandler)
		return 0;
	m_stack->pushInt(eventCode);
	m_stack->pushInt(intValue);
	m_stack->pushString(stringData);
	m_stack->pushFloat(doubleValue);
	int nRet =  m_stack->executeFunctionByHandler(nHandler,4);
	m_stack->clean();
	return nRet;
}NS_CC_END
