//
//  SFGameSceneMgr.h
//  mangosanguo
//
//  Created by alan huang on 12-5-21.
//  Copyright (c) 2012年 private. All rights reserved.
//

#ifndef mangosanguo_SFGameSceneMgr_h
#define mangosanguo_SFGameSceneMgr_h

//#include "cocos2d.h"
#include "sofia.h"
#include "utils/SFDictionary.h"
#include "SFGameScene.h"
#include <map>
#include <string>

using namespace cocos2d;

class SFGameSceneMgr : public CCObject
{
public:
    SFGameSceneMgr();
    virtual ~SFGameSceneMgr();
    
public:
    bool init();
    static SFGameSceneMgr* gameSceneMgr();
    
public:
    void addGameScene(SFGameScene *gameScene);
    void removeGameSceneWithContext(std::string gameSceneContext);
    SFGameScene* getGameScene(std::string context);
    
private:
    SFDictionary<std::string, SFGameScene*> *gameSceneDictionary_;
	//std::map<string, SFGameScene*> gameSceneDictionary_;
};

#endif
