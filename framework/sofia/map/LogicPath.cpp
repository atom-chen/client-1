#include "map/StructCommon.h"
#include "map/LogicBlock.h"
#include <memory>
#include "map/LogicPath.h"
#include "map/ExternStack.h"
#include "map/LogicBlock.h"
#include "map/LogicFinder.h"


#include "platform/CCPlatformConfig.h"
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <stdlib.h>
#endif

#include "cocos2d.h"
USING_NS_CC;
namespace cmap
{

#define XRealToGrid(x) ((x)/MapCellSize)
#define YRealToGrid(y) ((y)/MapCellSize)
#define XGridToReal(x) (x * MapCellSize + MapCellSize / 2)
#define YGridToReal(y) (y * MapCellSize + MapCellSize / 2)

	//find最大步数
#define FIND_MAX_STEP	0x7FFFFFFF

	void LogicPath::Clear()
	{ 
		m_iCurLine = 0;
	}

	//////////////////////////////////////////////////////////////////////
	// Construction/Destruction
	//////////////////////////////////////////////////////////////////////

	bool LogicPath::m_bLock = false;

	LogicPath::LogicPath()
	{
		m_pLine = NULL;
		m_iSpeed			= 12;
		m_lastTime			= 0;
		m_iCurLine = 0;
	}

	void LogicPath::SetSpeed(unsigned int speed)
	{
		if (speed <= 0)
		{
			return;
		}
		this->m_iSpeed = speed;
	}

	unsigned int LogicPath::GetSpeed() const
	{
		return this->m_iSpeed;
	}

	LogicPath::~LogicPath()
	{
		CC_SAFE_RELEASE_NULL(m_pLine);
	}
	//	功能：建立一条路径
	//	版本：v1.00
	//	算法：使用IPathFinder
	//	输入：起始点，结束点，起始方向，行走速度，丢弃几个点的路段，最大行走格数
	//	输出：返回是否建立成功
	//	备注：起始点，结束点的单位像素
	int LogicPath::Create( const IntPoint& from, const IntPoint& to, int iStartDir, int iMaxStep, bool ignoreBlock, unsigned long currentTime)
	{		
		IntPoint ptStart = from;
		IntPoint ptEnd = to;

		IntPoint ptTrueStart(XRealToGrid(ptStart.x), YRealToGrid(ptStart.y));
		IntPoint ptTrueEnd(XRealToGrid(ptEnd.x), YRealToGrid(ptEnd.y));

		//查找路径
		if( !m_pBlock->IsValid( ptTrueStart ) )
			return CP_FAIL;
		if( !m_pBlock->IsValid( ptTrueEnd ) )
			return CP_FAIL;

		if (ignoreBlock)
		{
			//无视阻挡
		}else
		{
			if( m_pBlock->IsBlock( ptTrueStart ) )
			{
				IntPoint lastNotBlock;
				if (m_pBlock->FirstBlock( ptTrueStart, ptTrueEnd, lastNotBlock))
				{
					ptTrueStart = lastNotBlock;
					ptStart.x = XGridToReal(ptTrueStart.x);
					ptStart.y = XGridToReal(ptTrueStart.y);
				}
			}
			if( m_pBlock->IsBlock( ptTrueEnd ) )
			{
				//找到最后一个不是阻挡的格子
				IntPoint lastNotBlock;
				if (m_pBlock->LastNotBlock( ptTrueStart, ptTrueEnd, lastNotBlock))
				{
					ptTrueEnd = lastNotBlock;
					ptEnd.x = XGridToReal(ptTrueEnd.x);
					ptEnd.y = XGridToReal(ptTrueEnd.y);
				}
			}
			if( m_pBlock->IsBlock( ptTrueEnd ) )
				return CP_FAIL;
		}		

		if( ptTrueStart.x == ptTrueEnd.x && ptTrueStart.y == ptTrueEnd.y )
			return false;

		//存在独享锁，直接留到下一帧进行寻路
		if (this->GetLock())
		{
			return CP_FINDNEXT;
		}

		if(m_pPathFinder->findPath(ptTrueStart, ptTrueEnd) == false)
			return false;

		CC_SAFE_RELEASE_NULL(m_pLine);
		cocos2d::CCArray* pathPoints = m_pPathFinder->getPathPoints();
		//处理一遍之后再给到这里来
		m_pLine = new CCArray();
		m_pLine->initWithCapacity(pathPoints->count() > 0 ? pathPoints->count() : 1);

		CCObject* pObj = NULL;
		pathPoint* pTmpObj = NULL;
		CCARRAY_FOREACH(pathPoints, pObj)
		{
			pathPoint* temp = (pathPoint*)pObj;
			pTmpObj = (pathPoint*)temp->copy();
			m_pLine->addObject(pTmpObj);
		}

		this->CreatePathLine(ptStart,ptEnd,iStartDir, currentTime);
		m_pPathFinder->getPathPoints()->removeAllObjects();
		m_iCurLine = 0;
		return CP_FINE;
	}

	// 取得这条路径的当前状态，返回是否结束
	bool LogicPath::_GetStateIsEnd(int& x, int& y, int& dir, unsigned int currentTime)
	{
		cocos2d::CCArray* pathPoints = m_pLine;
		if(m_iCurLine >= pathPoints->count())
			return false;
		pathPoint* pp = (pathPoint*)pathPoints->objectAtIndex(m_iCurLine);
		while(m_iCurLine < pathPoints->count() && (pp->uTimeStart <= m_lastTime))
		{
			++m_iCurLine;
			if (m_iCurLine >= pathPoints->count())
			{
				return true;
			}
			pp = (pathPoint*)pathPoints->objectAtIndex(m_iCurLine);	
		}

		//消耗时间
		//当前时间 - 当前路的开始时间
		pp = (pathPoint*)pathPoints->objectAtIndex(m_iCurLine-1);
		int iUseTime = (int)(m_lastTime - pp->uTimeStart);
		if( iUseTime < 0 )
		{
			return true;
		}
		x = pp->x;
		y = pp->y;

		dir = ((pathPoint*)pathPoints->objectAtIndex(m_iCurLine))->dir;
		x = x + ((pathPoint*)pathPoints->objectAtIndex(m_iCurLine))->dx * iUseTime / 100000.0f;
		y = y + ((pathPoint*)pathPoints->objectAtIndex(m_iCurLine))->dy * iUseTime / 100000.0f;
		m_lastTime = currentTime;
		return false;
	}

	int LogicPath::Update(int& x, int& y, int& dir, unsigned int currentTime)
	{
		if( _GetStateIsEnd(x, y, dir, currentTime) )
		{
			cocos2d::CCArray* pathPoints = m_pLine;
			pathPoint* pp = (pathPoint*)pathPoints->lastObject();
			if(pp->dir == -1)
				dir = 0;
			else
				dir = pp->dir;
			x = pp->x;
			y = pp->y;
			m_pLine->removeAllObjects();
			return true;
		}
		return false;
	}

	void LogicPath::CreatePathLine(IntPoint& ptStart,IntPoint& ptEnd,int iStartDir, unsigned int currentTime)
	{
		if (m_iSpeed == 0)
			return;
		cocos2d::CCArray* pathPoints = m_pLine;
		CCObject* child;
		int i = 0;
		CCARRAY_FOREACH(pathPoints,child)
		{
			pathPoint* pChild = (pathPoint*) child;

			pChild->x = XGridToReal(pChild->x);
			pChild->y = YGridToReal(pChild->y);
			if(i == 0)
			{
				pChild->uTimeStart = currentTime;
				m_lastTime = currentTime;
				++i;
				continue;
			}
			int dx = pChild->x - ((pathPoint*)pathPoints->objectAtIndex(i-1))->x;
			int dy = pChild->y - ((pathPoint*)pathPoints->objectAtIndex(i-1))->y;
			//todo
			double dAngle = atan2( dy * 1.4142135623731, dx ); //角度
			int iDistance = 1600 * m_iSpeed;
			pChild->dx = int(cos( dAngle ) * iDistance);
			pChild->dy = int(sin( dAngle ) * iDistance * 0.70710678118654);
			if (pChild->dx != 0 && pChild->dy != 0)
			{
				if (pChild->dx < 0)
				{
					pChild->dx  = -iDistance /1.5;
				}else{
					pChild->dx  = iDistance /1.5;
				}
				if (pChild->dy < 0)
				{
					pChild->dy  = -iDistance /1.5;
				}else{
					pChild->dy  = iDistance /1.5;
				}
			}
			if (pChild->dx == 0)
			{
				if (pChild->dy < 0)
				{
					pChild->dy = -iDistance;
				}else{
					pChild->dy = iDistance;
				}
			}
			unsigned long uUseTime; // 单位毫秒
			if( dx != 0 )
				uUseTime = dx * 100000 / pChild->dx;
			else if( dy != 0 )
				uUseTime = dy * 100000 / pChild->dy;
			else
				uUseTime = 1;
			pChild->uTimeStart = ((pathPoint*)pathPoints->objectAtIndex(i-1))->uTimeStart + uUseTime;
			++i;
		}
	}

	void LogicPath::Init(LogicBlock* block, LogicFinder* finder)
	{
		this->m_pBlock = block;
		this->m_pPathFinder = finder;
	}

	bool LogicPath::IsBlock(const IntPoint& grid)
	{
		if (this->m_pBlock == 0)
		{
			return true;
		}
		return this->m_pBlock->IsBlock(grid);
	}

	cocos2d::CCArray* LogicPath::getMovePoints()
	{
		return m_pLine;
	}
}
