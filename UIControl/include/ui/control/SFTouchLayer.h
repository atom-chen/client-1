#ifndef __SFTOUCHCONTROL_H__
#define __SFTOUCHCONTROL_H__

#include "SFBaseControl.h"

/************************************************************************/
/* 增加的Touch事件                                                                     */
/************************************************************************/	

class SFTouchProtocol{
public:
	virtual void singleTouch(CCPoint touchPosition){};
	virtual void doubleTouch(CCPoint touchPosition){};
	virtual void longTouch(CCPoint touchPosition){};
};

class SFTouchLayer: public SFBaseControl, public SFTouchProtocol{
public:

	SFTouchLayer();
	virtual ~SFTouchLayer();

	static SFTouchLayer* create() 
	{ 
		SFTouchLayer *pRet = new SFTouchLayer(); 
		if (pRet && pRet->init()) 
		{ 
			pRet->autorelease(); 
			return pRet; 
		} 
		else 
		{ 
			delete pRet; 
			pRet = NULL; 
			return NULL; 
		} 
	};
	virtual bool init();
	virtual void onExit();
	/************************************************************************/
	/* 是否吞并所有点击                                                                     */
	/************************************************************************/
	virtual void setSwallow(bool swallow);
	/************************************************************************/
	/*                                                                      */
	/************************************************************************/
	virtual void catchScreen(bool isCatch);

	/************************************************************************/
	/* 开启关闭扩展的点击事件，响应单击、双击和长按事件, 
	必须把THIS指针传入 ，关闭扩展事件，传入NULL                          */
	/************************************************************************/
	void setExpandAction(bool bExpand);
	/*	void setExpandAction(SFTouchProtocol *touchProtocol);*/

	/************************************************************************/
	/* 把Touch事件，再次传送给指定的对象， distance是点击点和移动点的距离，
	达到指定距离就开始传送出去.把touchHandle设为NULL可以取消传送                                    */
	/************************************************************************/
	virtual void passHandle(CCTouchDelegate *touchHandle, int distance=10);

protected:
	/************************************************************************/
	/* 如果要重写以下方法的，要在重写的方法里调用父类的相应方法                                           */
	/************************************************************************/
	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);	

private:
	void countTouch();
	void timingTouch(float dt);
	void touchFinish();

private:
	bool			m_isSwallow;
	bool			m_isCatch;
	bool			m_expAction;

private:
	SFTouchProtocol	*m_touchProtocol;
	CCTouchDelegate	*m_touchHandle;
	bool			m_bExpand;

protected:
	int				m_distance;
	bool			m_isPass;
	CCPoint			m_sPoint;
	CCTouch			*m_passTouch;
private:
	short			m_touchCount;
	bool			m_touchUp;
private:
	CCArray		*handles;
};


#endif	//__SFTOUCHCONTROL_H__

