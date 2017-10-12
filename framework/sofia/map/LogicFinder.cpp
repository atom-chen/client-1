#include "map/StructCommon.h"
#include "map/LogicFinder.h"
#include "map/LogicBlock.h"
#include <memory>
#include "cocos2d.h"
#include "platform/CCPlatformConfig.h"
#include "map/SpriteMove.h"
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <stdlib.h>
#include <limits.h> 
#endif
USING_NS_CC;
namespace cmap
{
	//////////////////////////////////////////////////////////////////////
	// Construction/Destruction
	//////////////////////////////////////////////////////////////////////

	LogicFinder::LogicFinder()
	{
		this->blockBuffer	= 0;
		width = 0;
		height = 0;
		this->m_map = 0;
		this->m_map_mem = 0;

		m_pathPoint = cocos2d::CCArray::create();
		m_pathPoint->retain();
	}

	LogicFinder::~LogicFinder()
	{
		m_open_list.Clear();
		CC_SAFE_FREE(this->m_map);
		CC_SAFE_FREE(this->m_map_mem);
	}

	// 如果切换了地图，重新装入地图障碍
	bool LogicFinder::ReLoad( const LogicBlock& block)
	{
		CC_SAFE_FREE(this->m_map);
		CC_SAFE_FREE(this->m_map_mem);
		m_open_list.Clear();
		this->width = block.GetSizeW();
		this->height = block.GetSizeH();

		int iLen = this->width * this->height;
		this->m_map = (PointInfo**)malloc(sizeof(PointInfo*) * this->width);
		m_map_mem = (PointInfo*)malloc(sizeof(PointInfo) * iLen);
		for (int i = 0; i < this->width; ++i)
		{
			m_map[i] = m_map_mem + this->height * i;
		}
		this->blockBuffer = block.GetBlockData();
		if (this->blockBuffer == 0)
		{
			return false;
		}
		return true;
	}

	bool LogicFinder::GetPoint(IntPoint* out)
	{
		PointInfo *cur_p = &m_map[this->endX][this->endY];
		int cur_dir = -1;
		while(cur_p != 0)
		{
			if (cur_p->dir != cur_dir)
			{
				cur_dir = cur_p->dir;
			}
			cur_p = cur_p->parant;
		}
		return true;
	}

	void LogicFinder::calcWeight( int next_x, int next_y, IntPoint& cur_point, bool is_slash, int next_dir )
	{
		PointInfo *next_p = &m_map[next_x][next_y];
		PointInfo *cur_p = &m_map[cur_point.x][cur_point.y];

		int g = cur_p->g + (is_slash ? 14142 : 10000);

		// 方向改变的时候加权，可以让寻出来的路径尽量走直线
		if (cur_p->dir != next_dir)
		{
			g += 15000;	// 该权值越大，则在贴墙走的情况下拐点会越少
		}

		if (is_slash)
		{
			// 处理拐角(墙角)不能直接穿过的问题
			int offset = next_x + (cur_point.y) * this->width;
			int offset1= cur_point.x + (next_y) * this->width;
			if (blockBuffer[offset] || blockBuffer[offset1])
			{
				return; // 直接return的话就是无论如何不走拐角
				//g += 99999; // 如果加上一个大的数，则是不优先走拐角，但在其他地方没有路径的时候还是会走拐角
				// 这个数字的大小可以控制是否绕路的距离
			}
		}
		if (next_p->g == 0 || next_p->g > g)
		{
			next_p->g = g;
			next_p->parant = cur_p;
			//cur_p->child = next_p;
			next_p->dir = next_dir;			// 记录当前与parant的dir
			
			if (next_p->h == 0)
			{
				int x_dis = next_x - endX;
				int y_dis = next_y - endY;

				// 如果用这个的话搜索结果为最短路径，但拐点可能会比较多，并且耗时较长
				//return sqrt(float(x_dis * x_dis + y_dis * y_dis)); 

				// 用这个的话拐点比较少，并且速度快
				x_dis < 0 ? (x_dis = -x_dis) : 0;
				y_dis < 0 ? (y_dis = -y_dis) : 0;
				//x_dis + y_dis;

				next_p->h = 10000 * (x_dis + y_dis);
			}

			int f = next_p->h + next_p->g;
			m_open_list.Push(OpenItem(next_x, next_y, f));
			//CCLOG("LogicFinder::calcWeight x=%d, y=%d, value=%d",next_x, next_y, f);
		}
	}

	bool LogicFinder::findPath( const IntPoint& begin, const IntPoint& end )
	{
		//检查是否范围内的点。有效性
		if( begin.x < 0 || begin.x >= this->width || begin.y < 0 || begin.y >= this->height
			|| end.x < 0 || end.x >= this->width || end.y < 0 || end.y >= this->height) 
		{
			return false;
		}
		m_pathPoint->removeAllObjects();
		int iStartX = begin.x;
		int iStartY = begin.y;
		this->endX	= end.x;
		this->endY	= end.y;
		//如果起始点是阻挡点，不走
		int offset = iStartX + (iStartY) * this->width;
		if (this->blockBuffer[offset])
		{
			this->endX	= iStartX;
			this->endY	= iStartY;
			return false;
		}
		//如果起始点和终点一致，直接返回
		if (begin.x == end.x && begin.y == end.y)
		{
			return false;
		}
		// reset map m_map
		bool get_to_end = false;
		memset(m_map_mem, 0, sizeof(PointInfo) * this->width * this->height);
		m_open_list.Clear();
		
		IntPoint cur_point = begin;
		for (;;)
		{
			m_map[cur_point.x][cur_point.y].block = true;
			m_map[cur_point.x][cur_point.y].x = cur_point.x;
			m_map[cur_point.x][cur_point.y].y = cur_point.y;

			int x_begin = cur_point.x - 1;
			x_begin < 0 ? (x_begin = 0) : 0;
			int x_end = cur_point.x + 2;
			x_end > this->width ? (x_end = this->width) : 0;
			int y_begin = cur_point.y - 1;
			y_begin < 0 ? (y_begin = 0) : 0;
			int y_end = cur_point.y + 2;
			y_end > this->height ? (y_end = this->height) : 0;
			for (int i = x_begin; i < x_end; ++i)
			{
				for (int j = y_begin; j < y_end; ++j)
				{
					offset = i + (j) * this->width;
					// 计算与当前点相邻的有效点，
					if (!m_map[i][j].block && !(blockBuffer[offset]))
					{
						static int POINT_DIR[3][3] = {	Dir_LU, Dir_L,Dir_LD,
							Dir_U,  DIR_S, Dir_D,
							Dir_RU, Dir_R, Dir_RD };
						int x_d = i - cur_point.x;
						int y_d = j - cur_point.y;
						int next_dir = POINT_DIR[x_d + 1][y_d + 1];
						// 达到目的地
						if (i == this->endX && j == this->endY)
						{
							m_map[i][j].parant = &m_map[cur_point.x][cur_point.y];
							m_map[i][j].x = i;
							m_map[i][j].y = j;
							m_map[i][j].dir = next_dir;
							get_to_end = true;
							//CCLOG("LogicFinder::Find:end x=%d, y=%d",i, j);
 							PointInfo* cur_p = &m_map[i][j];
							pathPoint* pp = NULL;
							int dir = -1;
							while (cur_p)
							{
								if (cur_p->dir != dir)
								{
// 									if(m_pathPoint->count() > 1)
// 									{
// 										//处理一下是否需要拉直
// 										//pathPoint* points0 = (pathPoint*)m_pathPoint->objectAtIndex(0);
// 										pathPoint* points1 = (pathPoint*)m_pathPoint->objectAtIndex(1);
// 										//int x = cur_p->x;
// 										//int index = 0;
// 										bool isBlock = cmap::SpriteMove::IsHaveBlock(points1->x, points1->y, cur_p->x, cur_p->y);
// 										if(isBlock == false)
// 										{
// 											m_pathPoint->removeObjectAtIndex(0);
// 										}
// 										//CCLOG("++++++++++++++++++++ %d",isBlock);
// 										//如果拉直，把前一个点删除
// 									}
									pathPoint* points = pathPoint::create(cur_p->x, cur_p->y);
									points->dir = cur_p->dir - 1;
									if(pp)
 										pp->parant = points;
									pp = points;
									m_pathPoint->insertObject(points,0);
									dir = cur_p->dir;
								}
								cur_p = cur_p->parant;
							}
							break;
						}


						x_d < 0 ? (x_d = -x_d) : 0;
						y_d < 0 ? (y_d = -y_d) : 0;

						bool is_slash = ((x_d + y_d) == 2);

						// 计算该点的权值并将有效的压到最小堆中
						calcWeight(i, j, cur_point, is_slash, next_dir);
					}
				}
			}
			if (get_to_end) break;

			bool cant_find = true;
			OpenItem next_open;
			while (m_open_list.Front(&next_open))
			{
				m_open_list.PopFront();
				// 找到下一个F值最小的点
				if (!m_map[next_open.x][next_open.y].block)
				{
					cur_point.x = next_open.x;
					cur_point.y = next_open.y;
					cant_find = false;
					break;
				}
			}
			// 说明开放列表为空，那么就没有找到路径
			if (cant_find)
			{
				this->endX	= end.x;
				this->endY	= end.y;
				return false;
			}
		}
		//CCLOG("--------------------");
		return true;
	}

	cocos2d::CCArray* LogicFinder::getPathPoints()
	{
		return m_pathPoint;
	}

	pathPoint::pathPoint():
		dx(0), dy(0), uTimeStart(0), x(0), y(0), block(false), g(0), h(0)
		, parant(NULL), dir(DIR_S)
	{
	}

	pathPoint* pathPoint::create(int x, int y)
	{
		pathPoint* ret = new pathPoint();
		ret->x = x;
		ret->y = y;
		ret->autorelease();
		return ret;
	}

	pathPoint::~pathPoint()
	{

	}

	CCObject* pathPoint::copy()
	{
		pathPoint* ret = new pathPoint();
		ret->x = x;
		ret->y = y;

		ret->dx = dy;
		ret->dy = dy;
		ret->uTimeStart = uTimeStart;
		ret->dir = dir;
		ret->autorelease();
		return ret;
	}

}
