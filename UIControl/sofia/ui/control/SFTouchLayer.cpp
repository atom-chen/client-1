#include "ui/control/SFTouchLayer.h"
#include "include/utils/SFTimeAxis.h"
#include "utils/SFTouchDispatcher.h"

SFTouchLayer::SFTouchLayer()
{
	m_isCatch = false;
	m_isSwallow = true;

	m_touchProtocol = NULL;
	m_touchHandle = NULL;
	m_distance = 10;
	m_isPass = false;

	m_expAction = false;
	m_touchCount = 0;
	m_touchUp = false;
	m_bExpand = true;
	m_passTouch = NULL;
	
}

SFTouchLayer::~SFTouchLayer()
{

}

bool SFTouchLayer::init()
{
	bool pRet = SFBaseControl::init();
	if(pRet)
		setTouchEnabled(true);
	m_touchProtocol = this;
	return pRet;
}

void SFTouchLayer::setSwallow( bool swallow )
{
	m_isSwallow = swallow;
}

void SFTouchLayer::catchScreen( bool isCatch )
{
	m_isCatch = isCatch;
}


bool SFTouchLayer::ccTouchBegan( CCTouch *pTouch, CCEvent *pEvent )
{	
	bool bRet = false;
	if (m_isCatch && isVisible())
		bRet = true;
	if(!bRet && isTouchInside(pTouch)){
		m_sPoint = this->getParent()->convertTouchToNodeSpace(pTouch);	
		
		countTouch();
		bRet = true;
	}

	if(bRet && m_touchHandle){
		
		m_touchHandle->ccTouchBegan(pTouch,pEvent);
		
		m_passTouch = pTouch;
	}
	return bRet;
}

void SFTouchLayer::ccTouchMoved( CCTouch *pTouch, CCEvent *pEvent )
{
	CCPoint pos = this->getParent()->convertTouchToNodeSpace(pTouch);
	if((abs(pos.y - m_sPoint.y)>m_distance || abs(pos.x - m_sPoint.x)>m_distance)){
		
		if(m_touchHandle){

			m_touchHandle->ccTouchMoved(pTouch, pEvent);
//			m_passTouch = pTouch;
			m_isPass = true;
		}
	}
}

void SFTouchLayer::ccTouchEnded( CCTouch *pTouch, CCEvent *pEvent )
{
	
	if(!m_isPass){
		touchFinish();
	}
	
	if(m_touchHandle){	
		m_touchHandle->ccTouchEnded(pTouch, pEvent);
		m_isPass = false;
	}	
}

void SFTouchLayer::ccTouchCancelled( CCTouch *pTouch, CCEvent *pEvent )
{
	
	if(!m_isPass){
		touchFinish();
	}
	
	if(m_touchHandle){	
		m_touchHandle->ccTouchCancelled(pTouch, pEvent);
		m_isPass = false;
	}
}



void SFTouchLayer::passHandle( CCTouchDelegate *touchHandle, int distance )
{
	m_touchHandle = touchHandle;
	m_distance = distance;
}

void SFTouchLayer::countTouch()
{
	m_touchUp = false;
	if(m_bExpand){
		if (m_touchCount<=0){
			SFTimeAxis::getInstancePtr()->setTimer(this, schedule_selector(SFTouchLayer::timingTouch), 450, 2);
		}
		m_touchCount++;
	}	
}

void SFTouchLayer::timingTouch( float dt )
{
	if(!m_isPass){
		if(!m_touchUp && m_touchCount>0 && m_touchProtocol){
			m_touchProtocol->longTouch(m_sPoint);
		}
		else if(m_touchUp && m_touchCount == 1 && m_touchProtocol){
			m_touchProtocol->singleTouch(m_sPoint);
		}
	}	
	m_touchUp = true;
	m_touchCount = 0;
}

void SFTouchLayer::touchFinish()
{
	m_touchUp = true;
	if(m_bExpand){
		if(m_touchCount >= 2){
			SFTimeAxis::getInstancePtr()->killTimer(this, schedule_selector(SFTouchLayer::timingTouch));
			m_touchCount = 0;
			if(m_touchProtocol)
				m_touchProtocol->doubleTouch(m_sPoint);
		}
	}	
	else{
		if(m_touchProtocol)		
			m_touchProtocol->singleTouch(m_sPoint);
		m_touchCount = 0;
	}
}

void SFTouchLayer::setExpandAction( bool bExpand )
{
	m_bExpand = bExpand;
}

void SFTouchLayer::onExit()
{
	if(m_isPass){
		ccTouchCancelled(m_passTouch, NULL);
	}
	SFBaseControl::onExit();
}






