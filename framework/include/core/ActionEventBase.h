#ifndef __ACTIONEVENTBASE_H__
#define __ACTIONEVENTBASE_H__

#include "cocos2d.h"
#include "stream/iStream.h"
using namespace cocos2d;
//接收包，解析
class ActionEventBase : public cocos2d::CCObject
{
public:
	ActionEventBase(){};
	virtual ~ActionEventBase(){};

	virtual void unpackFromBuffer(iBinaryReader *reader) 
	{
	}

	virtual void packToBuffer(iBinaryWriter*writer) 
	{

	}
	
public:
	int actionEventId;
	int handle;
};

//网络链接事件
class MFNetConnectEvent : public ActionEventBase
{
public:
	bool success;
	int errorCode;
};

//网络关闭链接
class MFNetCloseEvent : public ActionEventBase
{
public:
	int errorCode;
};

//////////////////////////////////////////////////////////////////////////
//游戏自定义参数事件
class UserMsgEvent : public ActionEventBase
{
public:
	int				msgId;
	unsigned int	wParam;
	unsigned long lParam;
};

#endif