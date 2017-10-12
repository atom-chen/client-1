#ifndef __MFTIMEAXIS_H__
#define __MFTIMEAXIS_H__
#include "utils/Singleton.h"
#include "cocos2d.h"
//毫秒单位的时间轴

class SFTimeAxis : public cocos2d::Singleton<SFTimeAxis>
{
public:
	SFTimeAxis();
	~SFTimeAxis();
	static SFTimeAxis*  Instance(){return SFTimeAxis::getInstancePtr();};
public:
	int getDelayTime();
	//客户端启动累计时间
	long long getClientTime();
		
	void advance(int delay);

	//设置定时器，多久执行一次，如果repeat为0，则一直运行
	//例子：SFTimeAxis::getInstancePtr()->setTimer(this, schedule_selector(MFGameApp::updateTimer), 1000, 3);
	void setTimer(cocos2d::CCObject *pTarget, cocos2d::SEL_SCHEDULE pfnSelector,  long millSceconds, unsigned int repeat);

	//删除定时器
	//例子：SFTimeAxis::getInstancePtr()->killTimer(this, schedule_selector(MFGameApp::updateTimer));
	void killTimer(cocos2d::CCObject *pTarget, cocos2d::SEL_SCHEDULE pfnSelector);

	/************************************************************************/
	/* 服务器时间                                                                     */
	/************************************************************************/
	void			setRequSyneClientTime();
	long long		getCrtServerTime();
	void			setCrtServerTime(long long serverTime);

	/************************************************************************/
	/* 后台暂停时间                                                                     */
	/************************************************************************/
	void enterBackgroundTime();
	void enterForegroundTime();
	long long getBackgroundPauseTime();

	std::string time2String(int time);

private:
	long m_delayTime;
	long m_lastTime;

	long long m_backgroundStartTime;
	long long m_backgroundEndTime;

	long long m_nCrtServerTime;
	long long m_receSyncClientTime;
	long long m_requSyncClientTIme;
	long long m_lastDelayTime;
};

#endif