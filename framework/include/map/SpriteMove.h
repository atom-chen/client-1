#ifndef _MAP_SPRITE_MOVE_H_
#define _MAP_SPRITE_MOVE_H_
#include "map/StructCommon.h"
#include <list>
#include "cocos2d.h"
namespace cocos2d
{
	class MemoryStream;
}

class PathPoint :public cocos2d::CCObject
{
public:
	static PathPoint* create(float x, float y){
		PathPoint* point = new PathPoint();
		point->autorelease();
		point->m_x = x;
		point->m_y = y;
		return point;
	};
	float getX(){return m_x;};
	float getY(){return m_y;};
private:
	float m_x;
	float m_y;
};
namespace cmap
{
	class LogicPath;
	class LogicFinder;
	class LogicBlock;
	class Block;
	class MetaLayer;

	
	
	class SpriteMove :public cocos2d::CCObject
	{
	public:
		SpriteMove();
		virtual ~SpriteMove();

		static SpriteMove* create();

		virtual bool CreatePath(int fromx, int fromy, int fromdir, int tox, int toy);
		virtual std::list<cmap::IntPoint> GetMovePoints(int fromx, int fromy, int tox, int toy);
		virtual cocos2d::CCArray* getMovePoints(int fromx,int fromy, int tox,int toy);
		virtual void ClearPath();
		virtual void SetSpeed(int speed);
		virtual int	 GetSpeed();

		virtual void GetEndXY(int &endX, int &endY);

		//return if should stop
		virtual bool Tick(int& curX, int& curY, int& dir);

		static unsigned int scurrenttime;
		static void Init();
		static void BlockChanged(cocos2d::MemoryStream &stream);
		static void End();
		//是否阻挡点
		static bool IsBlock(int x, int y);
		//是否直线阻挡
		static bool IsHaveBlock(int startX, int startY, int endX, int endY);
		static IntPoint finBlock(int startX, int startY, int endX, int endY);

		int getX(){return m_x;};
		int getY(){return m_y;};
		int getDir(){return m_dir;};//lua
		int getEndX(){return m_endX;};
		int getEndY(){return m_endY;};
	private:
		LogicPath* mpath;
		static LogicFinder* slogicfinder;
		static LogicBlock* slogicblock;
		int m_x;
		int m_y;
		int m_dir;
		int m_endX;
		int m_endY;
	};
}

#endif
