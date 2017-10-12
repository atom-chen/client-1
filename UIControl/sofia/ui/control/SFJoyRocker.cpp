/********************************************************************
文件名:SFJoyRocker.cpp
创建者:James Ou
创建时间:2013-1-8 11:15
功能描述:
*********************************************************************/
#include "ui/control/SFJoyRocker.h"
#include <math.h>
#include "script_support/CCScriptSupport.h"
void SFJoyRocker::updatePos(float dt){
	//jsSprite->setPosition(ccpAdd(jsSprite->getPosition(),ccpMult(ccpSub(currentPoint, jsSprite->getPosition()),0.5)));
	if (ccpDistance(movePoint,centerPoint) > inActiveRaidus)
	{
		if (pDelegate){
			pDelegate->rockerDirection(this, getDirection());
		}else if (m_delegateHandler)
		{
			CCScriptEngineProtocol *engine  = CCScriptEngineManager::sharedManager()->getScriptEngine();
			engine->executeJoyRockerDelegate(m_delegateHandler,kRockerDirection,this,getDirection());
		}
	}
}

//摇杆方位
RockerDirection SFJoyRocker::getDirection()
{
	//return ccpNormalize(ccpSub(centerPoint, currentPoint));
	CCPoint dirPos = ccpSub(currentPoint, centerPoint);
	float parameter = 0;
	if(dirPos.x > 0 && dirPos.y != 0){
		parameter = dirPos.y/dirPos.x;
		if((dirPos.y>0&&parameter < sqrtf(3)/3) || (dirPos.y<0&&parameter > -sqrtf(3)/3)){
			return eDir_Right;
		}
		else if(parameter >= sqrtf(3)/3 && parameter < sqrtf(3)){
			return eDir_RightUp;
		}
		else if(parameter <= -sqrtf(3)/3 && parameter > -sqrtf(3)){
			return eDir_RightDown;
		}
		else if(dirPos.y>0&&parameter >= sqrtf(3)){
			return eDir_Up;
		}
		else if(dirPos.y<0&&parameter <= -sqrtf(3)){
			return eDir_Down;
		}
	}
	else if(dirPos.x < 0 && dirPos.y != 0){
		parameter = dirPos.y/dirPos.x;
		if((dirPos.y>0&&parameter > -sqrtf(3)/3) || (dirPos.y<0&&parameter < sqrtf(3)/3)){
			return eDir_Left;
		}
		else if(parameter <= -sqrtf(3)/3 && parameter > -sqrtf(3)){
			return eDir_LeftUp;
		}
		else if(parameter >= sqrtf(3)/3 && parameter < sqrtf(3)){
			return eDir_LeftDown;
		}
		else if(dirPos.y>0&&parameter <= -sqrtf(3)){
			return eDir_Up;
		}
		else if(dirPos.y<0&&parameter >= sqrtf(3)){
			return eDir_Down;
		}
	}
	else if(dirPos.x < 0 && dirPos.y == 0){
		return eDir_Left;
	}
	else if(dirPos.x > 0 && dirPos.y == 0){
		return eDir_Right;
	}
	else if(dirPos.x == 0 && dirPos.y > 0){
		return eDir_Up;
	}
	else if(dirPos.x == 0 && dirPos.y < 0){
		return eDir_Down;
	}
	return eDir_UnKnow;
}
//摇杆力度
float SFJoyRocker::getVelocity()
{
	return ccpDistance(centerPoint, currentPoint);
}

bool SFJoyRocker::ccTouchBegan(CCTouch* touch, CCEvent* event)
{
	
	if (!active || !isVisible())
		return false;

	CCPoint pos = convertTouchToNodeSpace(touch);// convertToNodeSpace(touchLocation);
	currentPoint = pos;
	if(!isFollowRole){
		
		if (jsBg->boundingBox().containsPoint(pos)){
			schedule(schedule_selector(SFJoyRocker::updatePos));
			return true;
		}
	}
	else{
// 		CCPoint touchPoint = touch->getLocationInView();
// 		touchPoint = CCDirector:: sharedDirector()->convertToGL(touchPoint);
		hideRocker(false);
		centerPoint=currentPoint;
		jsSprite->setPosition(currentPoint);
		jsBg->setPosition(currentPoint);
		schedule(schedule_selector(SFJoyRocker::updatePos));
		return true;
	}

	return false;
}
void  SFJoyRocker::ccTouchMoved(CCTouch* touch, CCEvent* event)
{
	CCPoint touchPoint = convertTouchToNodeSpace(touch);
	movePoint = touchPoint;
	if (ccpDistance(touchPoint, centerPoint) > radius)
	{
		currentPoint =ccpAdd(centerPoint,ccpMult(ccpNormalize(ccpSub(touchPoint, centerPoint)), radius));
	}else {
		currentPoint = touchPoint;
	}
	jsSprite->setPosition(ccpAdd(jsSprite->getPosition(),ccpMult(ccpSub(currentPoint, jsSprite->getPosition()),0.5)));		
}

void  SFJoyRocker::ccTouchEnded(CCTouch* touch, CCEvent* event)
{
	unschedule(schedule_selector(SFJoyRocker::updatePos));
	currentPoint = centerPoint;
	jsSprite->setPosition(centerPoint);
	if(isFollowRole){
		hideRocker(true);
	}
	if(pDelegate){
		pDelegate->rockerFinish(this);
	}else if (m_delegateHandler)
	{
		CCScriptEngineProtocol *engine  = CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeJoyRockerDelegate(m_delegateHandler,kRockerFinish,this,getDirection());
	}
	
}

SFJoyRocker* SFJoyRocker:: JoyRockerWithCenter(float aRadius ,CCSprite* aJsSprite,CCSprite* aJsBg,bool _isFollowRole){
	SFJoyRocker *jstick = new SFJoyRocker();
	if (jstick  && jstick->initWithCenter(aRadius,aJsSprite,aJsBg,_isFollowRole))
	{
		jstick->autorelease();
		return jstick;
	}
	CC_SAFE_DELETE(jstick);
	return NULL;
}

bool SFJoyRocker::initWithCenter(float aRadius ,CCSprite* aJsSprite,CCSprite* aJsBg,bool _isFollowRole){

	bool pRet = false;
	do 
	{
		CC_BREAK_IF(!SFTouchLayer::init());

		isFollowRole =_isFollowRole;
		active = false;
		radius = aRadius;
		if(!_isFollowRole){
			centerPoint = ccp(aJsBg->boundingBox().size.width/2,aJsBg->boundingBox().size.height/2);
		}else{
			centerPoint =ccp(0,0);
		}
		inActiveRaidus = 0;
		currentPoint = centerPoint;
		jsSprite = aJsSprite;
		jsSprite->retain();
		jsSprite->setAnchorPoint(ccp(0.5,0.5));
		jsSprite->setPosition(centerPoint);

		jsBg = aJsBg;
		jsBg->retain();
		jsBg->setAnchorPoint(ccp(0.5,0.5));
		jsBg->setPosition(centerPoint);
		
		setContentSize(jsBg->boundingBox().size);
		
		this->addChild(jsBg);
		this->addChild(jsSprite);
		if(isFollowRole){
			this->hideRocker(true);
		}
		this->setActive(true);//激活摇杆

		pDelegate = NULL;
		m_delegateHandler = 0;
		pRet = true;
		setTouchEnabled(true);
	} while (0);
	
	return pRet;
}

void SFJoyRocker::setActive( bool isActive )
{
	active = isActive;
}

bool SFJoyRocker::isActive()
{
	return active;
}

void SFJoyRocker::hideRocker( bool hidden )
{
	jsSprite->setVisible(!hidden);
	jsBg->setVisible(!hidden);
}

void SFJoyRocker::setDelegate( SFJoyRockerDelegate *delegate )
{
	pDelegate = delegate;
}

void SFJoyRocker::removeDelegate()
{
	pDelegate = NULL;
}

SFJoyRocker::~SFJoyRocker()
{
	CC_SAFE_RELEASE_NULL(jsBg);
	CC_SAFE_RELEASE_NULL(jsSprite);
}
