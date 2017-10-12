#ifndef _SFACTOREVENT_H_
#define _SFACTOREVENT_H_
//#include "base/map/ActorElem.h"
#include "SFMapDef.h"

//class SFActorSprite;

// 引擎精灵事件
// class SFSpriteEvent
// {
// public:
// 	SFSpriteEvent(){}
// 	~SFSpriteEvent(){}
// };
//////////////////////////////////////////////////////////////////////////
//动作帧事件
class SFSpriteAnimNotifyEvent //: public SFSpriteEvent
{
public:
	SFSpriteAnimNotifyEvent():mActionId(0),mNotify(0)
	{
	};
	int getCurAction(){return mActionId;}
	const char* getNotify(){return mNotify;}

public:
	int mActionId;
	const char* mNotify;
};


//////////////////////////////////////////////////////////////////////////
//点击事件
class SFTouchEvent //: public SFSpriteEvent
{
public:
	SFTouchEvent():screenX(0), screenY(0), mapX(0), mapY(0){	}

	inline int getMapX(){	return mapX;}
	inline int getMapY(){return mapY;}
	inline int getMapCellX()	{	return Map2Cell(mapX);	}
	inline int getMapCellY()	{	return Map2Cell(mapY);	}
	inline int getScreenX(){return screenX;}
	inline int getScreenY(){return screenY;}
	
public:
	int screenX;
	int screenY;
	int mapX;
	int mapY;
};


//////////////////////////////////////////////////////////////////////////
//移动移动事件
class SFSpriteMovementEvent //: public SFSpriteEvent
{
public:
	SFSpriteMovementEvent(){};
	SFSpriteMovementEvent(int x, int y):mapX(x), mapY(y),beginGo(false),beginStop(false)
	{
	}
	inline int getMapX(){return mapX;}
	inline int getMapY(){return mapY;}

	bool isBeginGo(){return beginGo;	}
	bool isBeginStop(){return beginStop;}

	int mapX;
	int mapY;
	bool beginGo;
	bool beginStop;
};


struct ISpriteTouchCallback
{
	virtual bool onTouchBegin(SFTouchEvent *e) = 0;
	virtual bool onTouchEnd(SFTouchEvent *e) = 0;
};


struct ISpriteAnimCallback
{
	virtual void onAnimNotify(SFSpriteAnimNotifyEvent* e) = 0;
};

#endif