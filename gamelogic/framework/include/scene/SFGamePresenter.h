#ifndef __GAMEPRESENTER_H__
#define __GAMEPRESENTER_H__

//#include "cocos2d.h"
#include "sofia.h"
#include "SFGameScene.h"
#include "SFGameSceneMgr.h"

using namespace cocos2d;

typedef enum
{
	GameSimulatorSlaveTag = 1,
	Current_GameSceneTag
}SceneChildTag;

class SFGamePresenter : public CCObject
{
public:
	SFGamePresenter(void);
	virtual ~SFGamePresenter(void);
	
public:
	virtual bool init();
	static SFGamePresenter* gamePresenter();

	CCScene* scene();
	void replaceScene(CCScene* scene);
	
	SFGameScene* getCrtScene();
	SFGameScene* addAndGetScene(string sceneName);
	void switchTo(SFGameScene *theScene);
	SFGameScene* switchTo(string sceneContext);

private:
	SFGameScene *crtScene_;
	SFGameSceneMgr *gameSceneMgr_;
	CCScene *presenterDelegate; 
};

#endif
