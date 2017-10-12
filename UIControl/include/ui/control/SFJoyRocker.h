/********************************************************************
文件名:SFJoyRocker.h
创建者:James Ou
创建时间:2013-1-8 11:01
功能描述:
*********************************************************************/

#ifndef __SFJOYROCKER_H_
#define __SFJOYROCKER_H_

#include "cocos2d.h"
#include "SFTouchLayer.h"

enum RockerDirection{
	eDir_Up,
	eDir_LeftUp,
	eDir_Left,
	eDir_LeftDown,
	eDir_Down,
	eDir_RightDown,
	eDir_Right,
	eDir_RightUp,
	eDir_UnKnow
};

enum 
{
	kRockerDirection,
	kRockerFinish,
};
using namespace cocos2d;

class SFJoyRocker;

class SFJoyRockerDelegate{
public:
	virtual void rockerDirection(SFJoyRocker *rocker, RockerDirection direction){};
	virtual void rockerFinish(SFJoyRocker *rocker){};
};

class SFJoyRocker :public SFTouchLayer {

public :
	virtual ~SFJoyRocker();
	//初始化 aRadius是摇杆半径 aJsSprite是摇杆控制点 aJsBg是摇杆背景
	static SFJoyRocker*  JoyRockerWithCenter(float aRadius ,CCSprite* aJsSprite,CCSprite* aJsBg,bool _isFollowRole);

	bool initWithCenter(float aRadius ,CCSprite* aJsSprite,CCSprite* aJsBg,bool _isFollowRole);
	//启动摇杆
	void setActive(bool isActive);
	bool isActive();

	void hideRocker(bool hidden);

	void setDelegate(SFJoyRockerDelegate *delegate);
	void setDelegateHandler(int nHandler) {m_delegateHandler= nHandler;};
	void removeDelegate();
	void setInActiveRadius(float r){inActiveRaidus = r;};
private:
	SFJoyRockerDelegate	*pDelegate;
	int m_delegateHandler;
	CCPoint centerPoint;//摇杆中心
	CCPoint currentPoint;//摇杆当前位置

	bool active;//是否激活摇杆
	float radius;//摇杆半径
	float inActiveRaidus;//不敏感半径
	CCPoint movePoint;
	CCSprite *jsSprite;
	CCSprite *jsBg;

	bool isFollowRole;//是否跟随用户点击

	RockerDirection getDirection();
	float getVelocity();
	void  updatePos(float dt);

	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	//LAYER_NODE_FUNC(SFJoyRocker);
};
#endif	//__SFJOYROCKER_H_

