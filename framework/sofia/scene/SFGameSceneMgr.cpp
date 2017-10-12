//
//  SFGameSceneMgr.cpp
//  mangosanguo
//
//  Created by alan huang on 12-5-21.
//  Copyright (c) 2012锟斤拷 private. All rights reserved.
//

#include "scene/SFGameSceneMgr.h"

SFGameSceneMgr::SFGameSceneMgr()
{
    
}

SFGameSceneMgr::~SFGameSceneMgr()
{
    CC_SAFE_RELEASE_NULL(gameSceneDictionary_);
}

bool SFGameSceneMgr::init()
{
    gameSceneDictionary_ = new SFDictionary<string, SFGameScene*>();
    gameSceneDictionary_->autorelease();
    gameSceneDictionary_->retain();
    return true;
}

SFGameSceneMgr* SFGameSceneMgr::gameSceneMgr()
{
    SFGameSceneMgr *gameSceneMgr = new SFGameSceneMgr();
    if (gameSceneMgr != NULL && gameSceneMgr->init())
    {
        gameSceneMgr->autorelease();
        return gameSceneMgr;
    }
    else 
    {
		CC_SAFE_DELETE(gameSceneMgr);
        return NULL;
    }
}

void SFGameSceneMgr::addGameScene(SFGameScene *gameScene)
{
    gameSceneDictionary_->setObject(gameScene, gameScene->getContext());
}

void SFGameSceneMgr::removeGameSceneWithContext(string gameSceneContext)
{
    gameSceneDictionary_->removeObjectForKey(gameSceneContext);
}

SFGameScene* SFGameSceneMgr::getGameScene(string context)
{
    return gameSceneDictionary_->objectForKey(context);
}




