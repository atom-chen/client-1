#include "scene/SFGameScene.h"
#include "ui/utils/VisibleRect.h"
#include "script_support/CCScriptSupport.h"

SFGameScene::SFGameScene(void) :
gameNode_(CCNode::create()),
uiNode_(CCNode::create()),
dialogNode_(CCNode::create()),
m_sceneEnterHandler(0),
m_sceneExitHandler(0),
m_bTouchCatch(false)
{
	CCPoint center = VisibleRect::center();
	gameNode_->setAnchorPoint(ccp(0.5f, 0.5f));
	uiNode_->setAnchorPoint(ccp(0.5f, 0.5f));
	dialogNode_->setAnchorPoint(ccp(0.5f, 0.5f));

}


SFGameScene::~SFGameScene(void)
{
    
}


bool SFGameScene::initWithContext(std::string context)
{
	RTLayer::init();
    context_ = context;

	addChild(gameNode_, 0, TagGameLayer);
	addChild(uiNode_, 1, TagUILayer);
	addChild(dialogNode_, 2, TagDialogLayer);

    return true;
}

SFGameScene* SFGameScene::gameSceneWithContext(std::string context)
{
    SFGameScene *gameScene = new SFGameScene();
    if (gameScene != NULL && gameScene->initWithContext(context))
    {
        gameScene->autorelease();
        return gameScene;
    }
    else
    {
        delete gameScene;
        gameScene = NULL;
        return NULL;
    }
}

std::string SFGameScene::getContext()
{
    return context_;
}

void SFGameScene::addGameLayer( CCNode *gameLayer )
{
	gameNode_->addChild(gameLayer);
}

void SFGameScene::removeGameLayer( int tagOfGameLayer, bool clearUp )
{
	gameNode_->removeChildByTag(tagOfGameLayer, clearUp);
}

void SFGameScene::removeGameLayer( CCNode *gameLayer, bool clearUp )
{
	gameNode_->removeChild(gameLayer, clearUp);
}

void SFGameScene::addUILayer( CCNode *uiLayer )
{
	uiNode_->addChild(uiLayer);
}

void SFGameScene::removeUILayer( int tagOfUILayer, bool clearUp )
{
	uiNode_->removeChildByTag(tagOfUILayer, clearUp);
}

void SFGameScene::removeUILayer( CCNode *uiLayer, bool clearUp )
{
	uiNode_->removeChild(uiLayer, clearUp);
}

void SFGameScene::addDialogLayer( CCNode *dialogLayer )
{
	dialogNode_->addChild(dialogLayer);
}

void SFGameScene::removeDialogLayer( int tagOfDialogLayer, bool clearUp )
{
	dialogNode_->removeChildByTag(tagOfDialogLayer, clearUp);
}

void SFGameScene::removeDialogLayer( CCNode *dialogLyer, bool clearUp )
{
	dialogNode_->removeChild(dialogLyer, clearUp);
}

CCNode* SFGameScene::getGameLayerByTag( int tagOfGameLayer )
{
	return gameNode_->getChildByTag(tagOfGameLayer);
}

CCNode* SFGameScene::getUILayerByTag( int tagOfUILayer )
{
	return uiNode_->getChildByTag(tagOfUILayer);
}

CCNode* SFGameScene::getDialogLayerByTag( int tagOfDialogLayer )
{
	return dialogNode_->getChildByTag(tagOfDialogLayer);
}

void SFGameScene::onEnter()
{
	RTLayer::onEnter();

	if (0 != m_sceneEnterHandler)
	{
		CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeSceneEvent(m_sceneEnterHandler, this, SceneEventEnter, getContext().c_str());
	}
}

void SFGameScene::onExit()
{
	RTLayer::onExit();

	if (0 != m_sceneExitHandler)
	{
		CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeSceneEvent(m_sceneExitHandler, this, SceneEventExit, getContext().c_str());
	}
}

void SFGameScene::addSceneEventHandler( int event, int nHandler )
{
	if (SceneEventEnter == event)
		m_sceneEnterHandler = nHandler;
	else if (SceneEventExit == event)
		m_sceneExitHandler = nHandler;
}

bool SFGameScene::byTouchBegan( CCTouch *pTouch, CCEvent *pEvent )
{
	m_bTouchCatch = RTLayer::byTouchBegan(pTouch,pEvent);
	bool bRet = m_bTouchCatch;
	if (!m_bTouchCatch && kScriptTypeNone != m_eScriptType)
	{
		CCScriptEngineProtocol* engine =  CCScriptEngineManager::sharedManager()->getScriptEngine();
		bRet = engine->executeLayerTouchEvent(this,CCTOUCHBEGAN, pTouch)  == 0 ? false : true;
	}
	
	return bRet;
}

void SFGameScene::byTouchMoved( CCTouch *pTouch, CCEvent *pEvent )
{
	if (m_bTouchCatch)
	{
		RTLayer::byTouchMoved(pTouch,pEvent);
	}
	else if (kScriptTypeNone != m_eScriptType)
	{
		CCScriptEngineProtocol* engine =  CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeLayerTouchEvent(this,CCTOUCHMOVED, pTouch) ;
	}
}

void SFGameScene::byTouchEnded( CCTouch *pTouch, CCEvent *pEvent )
{
	if (m_bTouchCatch)
	{
		RTLayer::byTouchEnded(pTouch,pEvent);
	}
	else if (kScriptTypeNone != m_eScriptType)
	{
		CCScriptEngineProtocol* engine =  CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeLayerTouchEvent(this,CCTOUCHENDED, pTouch) ;
	}

	m_bTouchCatch = false;
}

void SFGameScene::byTouchCancelled( CCTouch *pTouch, CCEvent *pEvent )
{
	if (m_bTouchCatch)
	{
		RTLayer::byTouchCancelled(pTouch,pEvent);
	}
	else if (kScriptTypeNone != m_eScriptType)
	{
		CCScriptEngineProtocol* engine =  CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeLayerTouchEvent(this,CCTOUCHCANCELLED, pTouch) ;
	}

	m_bTouchCatch = false;
}
