#include "scene/SFGamePresenter.h"

SFGamePresenter::SFGamePresenter(void):presenterDelegate(NULL)
{
}


SFGamePresenter::~SFGamePresenter(void)
{
	CC_SAFE_RELEASE(gameSceneMgr_);
}

bool SFGamePresenter::init()
{
	bool bRet = false;
	do 
	{
		gameSceneMgr_ = SFGameSceneMgr::gameSceneMgr();
		gameSceneMgr_->retain();
		bRet = true;

		crtScene_ = NULL;
	} while (0);

	return bRet;
}

SFGamePresenter* SFGamePresenter::gamePresenter()
{
	SFGamePresenter *presenter = new SFGamePresenter();
	if (presenter != NULL && presenter->init())
	{
		presenter->autorelease();
		return presenter;
	}
	else 
	{
		delete presenter;
		presenter = NULL;
		return  NULL;
	}
}

CCScene* SFGamePresenter::scene()
{
	return presenterDelegate;
}

SFGameScene* SFGamePresenter::getCrtScene()
{
	return crtScene_;
}

SFGameScene* SFGamePresenter::addAndGetScene(string sceneName)
{
	SFGameScene* gameScene = SFGameScene::gameSceneWithContext(sceneName);
	gameSceneMgr_->addGameScene(gameScene);
	return gameScene;
}

void SFGamePresenter::switchTo(SFGameScene *theScene)
{
	if (!theScene)
		return;

	if (crtScene_ != NULL)
	{
		//if (theScene->getContext().compare(crtScene_->getContext()) == 0) return;
		//crtScene_->removeAllChildrenWithCleanup(true);
		//crtScene_->onExit();
		presenterDelegate->removeChild(crtScene_, true);
	}
	crtScene_ = theScene;
	presenterDelegate->addChild(theScene, Current_GameSceneTag);
	//crtScene_->onEnter();
}

SFGameScene* SFGamePresenter::switchTo(string sceneContext)
{
	SFGameScene* gameScene = gameSceneMgr_->getGameScene(sceneContext);
	switchTo(gameScene);
	return gameScene;
}

void SFGamePresenter::replaceScene( CCScene* scene )
{
	presenterDelegate = scene;
}

