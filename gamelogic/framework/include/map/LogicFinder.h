#ifndef _MAP_LOGIC_FINDER_H_
#define _MAP_LOGIC_FINDER_H_
#include "utils/heap.h"
#include "cocos2d.h"
USING_NS_CC;
namespace cmap
{
	class LogicBlock;
	class IntPoint;
	enum ASTART_DIR
	{
		DIR_S = 0,
		Dir_U,
		Dir_RU,
		Dir_R,
		Dir_RD,
		Dir_D,
		Dir_LD,
		Dir_L,
		Dir_LU,
		Dir_RESERVED,
		Dir_Count
	};
	class pathPoint : public CCObject
	{
	public:
		pathPoint();
		virtual ~pathPoint();
		static pathPoint* create(int x, int y);
		virtual CCObject* copy();
		int getX(){return x;};
		int getY(){return y;};
	//protected:
		int				dx;				// 100秒移动的垂直方向上的距离
		int				dy;				// 100秒移动的水平方向上的距离
		unsigned long	uTimeStart;		// 人物进入这段路线的时刻
		int				x;
		int				y;
		bool			block;
		int				g;				// 当前点与起始点的实际距离
		int				h;				// 当前点与终点的估算距离，由CalH计算

		pathPoint*		parant;
		int				dir;			// 当前点与parant的方向
	private:
	};

	class LogicFinder
	{
	public:
		LogicFinder();
		virtual ~LogicFinder();

		virtual bool ReLoad( const LogicBlock& block);

		bool findPath(const IntPoint& begin, const IntPoint& end);

		virtual bool GetPoint(IntPoint* out);

		cocos2d::CCArray* getPathPoints();
	private:

		struct PointInfo
		{
			int x;
			int y;
			bool block;			// 当前点已经找过了，关闭列表标示
			int g;				// 当前点与起始点的实际距离
			int h;				// 当前点与终点的估算距离，由CalH计算

			PointInfo*	parant;
			int dir;			// 当前点与parant的方向
		};
		// 开放列表项
		struct OpenItem
		{
			OpenItem():x(0), y(0), f(0){}
			OpenItem(int _x, int _y, int _f):x(_x), y(_y), f(_f){}
			int x;
			int y;
			int f;	// 当前点的g + h
			bool operator<(const OpenItem &v)const
			{
				return f < v.f;
			}
		};
		PointInfo**		m_map;
		PointInfo*		m_map_mem;
		Heap<OpenItem>	m_open_list;

		cocos2d::CCArray* m_pathPoint;
	private:
		void	calcWeight(int next_x, int next_y, IntPoint& cur_point, bool is_slash, int next_dir);
	private:
		unsigned int width;
		unsigned int height;
		int endX;
		int endY;		// 结束点

		const unsigned char* blockBuffer;				// 地图
	};
}

#endif
