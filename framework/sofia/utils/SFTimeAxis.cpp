#include "cocos2d.h"
#include "include/utils/SFTimeAxis.h"
#include "include/utils/SFStringUtil.h"
USING_NS_CC;

SFTimeAxis::SFTimeAxis(): m_delayTime(0)
{
	//m_lastUpdate.tv_sec = m_lastUpdate.tv_usec = 0;
	m_lastTime =0;
	
	m_backgroundStartTime = 0;
	m_backgroundEndTime = 0;

	m_nCrtServerTime = 0;
	m_receSyncClientTime = 0;
	m_requSyncClientTIme = 0;
	m_lastDelayTime = 6000;
}

SFTimeAxis::~SFTimeAxis()
{

}

long long SFTimeAxis::getClientTime()
{
	return CCTime::getCurTime();
}

//按定窗口，得到的延迟时间会有错
int SFTimeAxis::getDelayTime()
{
	return m_delayTime;
}


void SFTimeAxis::advance( int delay )
{
	m_delayTime = delay;
}

void SFTimeAxis::setTimer( CCObject *pTarget, SEL_SCHEDULE pfnSelector, long millSceconds,unsigned int repeat )
{
	//cocos是先执行1次，再重复repeat次。
	//这里改成先延迟millSceconds执行1次，重复repeat-1次。这样就一共执行repeat次
	if (repeat == 0)
		repeat = kCCRepeatForever;
	else
		repeat -= 1;

	float fInterval = millSceconds / 1000.0;
	CCDirector::sharedDirector()->getScheduler()->scheduleSelector(pfnSelector, pTarget, fInterval, repeat, fInterval, false);
}

void SFTimeAxis::killTimer( CCObject *pTarget, SEL_SCHEDULE pfnSelector )
{
	CCDirector::sharedDirector()->getScheduler()->unscheduleSelector(pfnSelector, pTarget);
}

long long SFTimeAxis::getCrtServerTime()
{
	long long finishTime = getClientTime();
	long long resultTime = m_nCrtServerTime+(finishTime-m_receSyncClientTime);
	struct cc_timeval now;
	now.tv_sec = resultTime/1000;
	now.tv_usec = resultTime%1000;

	time_t lt = now.tv_sec;
	struct tm *ptr;
	ptr=gmtime(&lt);
	return resultTime;
}

void SFTimeAxis::setCrtServerTime( long long serverTime )
{
	m_receSyncClientTime = getClientTime();

	long long thisDelayTime = m_receSyncClientTime - m_requSyncClientTIme;
	if(thisDelayTime <= m_lastDelayTime){
		m_nCrtServerTime = serverTime + thisDelayTime/2;
		m_lastDelayTime =  thisDelayTime;
	}
	else{
		m_nCrtServerTime = serverTime;
	}
}

void SFTimeAxis::setRequSyneClientTime()
{
	m_requSyncClientTIme = getClientTime();
}

void SFTimeAxis::enterBackgroundTime()
{
	m_backgroundStartTime = getClientTime();
}

void SFTimeAxis::enterForegroundTime()
{
	m_backgroundEndTime = getClientTime();
}

long long SFTimeAxis::getBackgroundPauseTime()
{
	return m_backgroundEndTime - m_backgroundStartTime;
}

std::string SFTimeAxis::time2String( int time )
{
	int m = time/60;
	int s = time%60;
	int h = m/60;
	m = m-h*60;
	if(h>0)
		return SFStringUtil::formatString("%02d:%02d:%02d", h, m, s);
	else
		return SFStringUtil::formatString("%02d:%02d", m, s);
}

