#ifndef __SFGAMESCENE_H__
#define __SFGAMESCENE_H__


//#include "cocos2d.h"
#include "sofia.h"
#include <string>
#include "utils/SFTouchDispatcher.h"

using namespace cocos2d;

enum
{
	TagGameLayer,
	TagUILayer,
	TagDialogLayer
};

enum 
{
	SceneEventEnter = 1,
	SceneEventExit
};

class SFGameScene : public RTLayer//public CCLayer /*public CCNode*/
{
public:
	SFGameScene(void);
	virtual ~SFGameScene(void);
    
public:
    bool initWithContext(std::string context);
    static SFGameScene* gameSceneWithContext(std::string context);

	virtual void onEnter();
	virtual void onExit();
    
public:
    std::string getContext();
    
public:
	CCNode* getGameLayerByTag(int tagOfGameLayer);
	void addGameLayer(CCNode *gameLayer);
	void removeGameLayer(int tagOfGameLayer, bool clearUp=true);
	void removeGameLayer(CCNode *gameLayer, bool clearUp=true);

	CCNode* getUILayerByTag(int tagOfUILayer);
	void addUILayer(CCNode *uiLayer);
	void removeUILayer(int tagOfUILayer, bool clearUp=true);
	void removeUILayer(CCNode *uiLayer, bool clearUp=true);

	CCNode* getDialogLayerByTag(int tagOfDialogLayer);
	void addDialogLayer(CCNode *dialogLayer);
	void removeDialogLayer(int tagOfDialogLayer, bool clearUp=true);
	void removeDialogLayer(CCNode *dialogLyer, bool clearUp=true);

	void addSceneEventHandler(int event, int nHandler);

	virtual bool byTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void byTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void byTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	virtual void byTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);

protected:
	CCNode *gameNode_;
	CCNode *uiNode_;
	CCNode *dialogNode_;

private:
    std::string context_;
	int m_sceneEnterHandler;
	int m_sceneExitHandler;
	bool m_bTouchCatch;
};

#endif

