#ifndef _MAP_LOGIC_PATH_H_
#define _MAP_LOGIC_PATH_H_
#include <list>
// add Luofuwen 精灵行走地图上画线用的，测试的时候
//#include "map/RenderInterface.h"
#include "map/MetaLayer.h"
//#include "map/RenderInterface.h"

namespace cmap
{
	class LogicBlock;
	class LogicFinder;
	class IntPoint;

	class LogicPath
	{
	public:
		LogicPath();
		virtual ~LogicPath();

		virtual int Create(const IntPoint& from, const IntPoint& to, int dir, int iMaxStep, bool ignoreBlock, unsigned long currentTime);
		cocos2d::CCArray* getMovePoints();
		virtual int Update(int& x, int& y, int& dir, unsigned int currentTime);
		virtual void Clear();
		virtual bool IsBlock(const IntPoint& grid);
		virtual void SetSpeed(unsigned int speed);
		virtual unsigned int GetSpeed() const;

		virtual void SetLock(bool lock){LogicPath::m_bLock = lock;}
		virtual bool GetLock(){return LogicPath::m_bLock;}

	public:
		enum ECreatePath	//创建路径的返回结果
		{
			CP_NOTNEED = -1,//不需要创建
			CP_FAIL = 0,	//创建失败
			CP_FINE = 1,	//创建成功
			CP_FINDNEXT = 2,//需要多段查找
			CP_LOCKFIND = 3,//需要加锁独享
		};

		struct TWalkLine	// 一条路的一段路线
		{
			int iDir;		// 人物在这条路上的方向
			int dy;			// 100秒移动的垂直方向上的距离
			int dx;			// 100秒移动的水平方向上的距离
			IntPoint ptStart;	// 这段路的起始点
			unsigned long uTimeStart;// 人物进入这段路线的时刻
			unsigned long uTimeEnd;	// 人物离开这段路线的时刻
		};
		void Init(LogicBlock* block,LogicFinder* finder);

		int GetEndX() const {return m_ptEnd.x;}
		int GetEndY() const {return m_ptEnd.y;}
		
	private:
		// 初始化一条路线，其中pWalkLine->iType、uTimeStart、iStartDir、ptStart是输入的参数
		//void SetLine( const IntPoint& ptEnd, unsigned int iSpeed, TWalkLine* pWalkLine );

		//根据传入的折点列表计算出路线
		void CreatePathLine(IntPoint& ptStart,IntPoint& ptEnd,int iStartDir, unsigned int currentTime);
		// 取得这条路径的当前状态，返回是否结束
		bool _GetStateIsEnd(int& x, int& y, int& dir, unsigned int currentTime);
	
		LogicBlock* m_pBlock;
		LogicFinder* m_pPathFinder;
		IntPoint m_ptEnd;

		int				m_iCurLine;			// 当前在第几段路段中
		//int				m_iMaxLine;			// 共有多少条路段
		//TWalkLine*		m_pLine;			// 各段路线
		cocos2d::CCArray*	m_pLine;
		unsigned int 	m_iSpeed;

		unsigned int	m_lastTime;
		//bool firstUpdateTime;
		//unsigned int timeOffset;
		std::list<IntPoint*> m_ListPoint;	//路线折点链表		
		static bool m_bLock;				//使用静态全局变量,唯一
	};


}

#endif
