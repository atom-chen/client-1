#include "cocos2d.h"
#include "map/SpriteMove.h"
#include "map/LogicPath.h"
#include "map/LogicFinder.h"
#include "map/LogicBlock.h"
#include "map/MetaLayer.h"

#include "stream/iStream.h"
#include "stream/MemoryStream.h"
#include "stream/BinaryReader.h"
USING_NS_CC;
namespace cmap
{
	LogicFinder* SpriteMove::slogicfinder = 0;
	LogicBlock* SpriteMove::slogicblock = 0;
	unsigned int SpriteMove::scurrenttime = 0;
	void SpriteMove::Init()
	{
		SpriteMove::slogicfinder = new LogicFinder();
		SpriteMove::slogicblock = new LogicBlock();
	}

	void SpriteMove::BlockChanged( cocos2d::MemoryStream &stream )
	{
		cocos2d::BinaryReader reader;
		reader.SetStream(&stream, false);
		if (!reader.Open() || reader.Eof())
		{
			return;
		}

		int width = reader.ReadInt();
		int height = reader.ReadInt();

		int buf_size = reader.ReadInt();

		if (SpriteMove::slogicblock->buffer != 0 && SpriteMove::slogicblock->bufferSize < buf_size)
		{
			free(SpriteMove::slogicblock->buffer);
			SpriteMove::slogicblock->buffer = 0;
			SpriteMove::slogicblock->bufferSize = 0;
		}
		if (SpriteMove::slogicblock->buffer == 0)
		{
			SpriteMove::slogicblock->buffer = (unsigned char*)malloc(buf_size);
			SpriteMove::slogicblock->bufferSize = buf_size;
		}
		reader.ReadRawData(SpriteMove::slogicblock->buffer, buf_size);
		SpriteMove::slogicblock->width = width;
		SpriteMove::slogicblock->height = height;
		SpriteMove::slogicblock->InitAreaLimit();

		SpriteMove::slogicfinder->ReLoad(*(SpriteMove::slogicblock));
	}

	void SpriteMove::End()
	{
		CC_SAFE_DELETE(slogicfinder);
		CC_SAFE_DELETE(slogicblock);
	}

	SpriteMove::SpriteMove()
	{
		this->mpath = new LogicPath();
		this->mpath->Init(SpriteMove::slogicblock, SpriteMove::slogicfinder);
	}

	SpriteMove::~SpriteMove()
	{
		delete this->mpath;
	}

	bool SpriteMove::CreatePath(int fromx, int fromy, int fromdir, int tox, int toy)
	{
		return this->mpath->Create(IntPoint(fromx, fromy), IntPoint(tox, toy), fromdir, 300, false, SpriteMove::scurrenttime);
	}

	void SpriteMove::ClearPath()
	{
		this->mpath->Clear();
	}

	bool SpriteMove::Tick(int& curX, int& curY, int& dir)
	{
		bool state = this->mpath->Update(curX, curY, dir, SpriteMove::scurrenttime);
		m_dir = dir;
		m_x = curX;
		m_y = curY;
		return state;
	}

	void SpriteMove::SetSpeed( int speed )
	{
		mpath->SetSpeed(speed);
	}

	void SpriteMove::GetEndXY( int &endX, int &endY )
	{
		endX = this->mpath->GetEndX();
		endY = this->mpath->GetEndY();
		m_endX = endX;
		m_endY = endY;
	}

	int SpriteMove::GetSpeed()
	{
		return mpath->GetSpeed();
	}

	bool SpriteMove::IsBlock( int x, int y )
	{
		return	SpriteMove::slogicblock->IsBlock(IntPoint(x, y));
	}

	bool SpriteMove::IsHaveBlock( int startX, int startY, int endX, int endY )
	{
		IntPoint ptTrueStart(startX, startY);

		IntPoint ptTrueEnd(endX, endY);
		return SpriteMove::slogicblock->HaveBlock(ptTrueStart, ptTrueEnd);
	}

	cmap::IntPoint SpriteMove::finBlock( int startX, int startY, int endX, int endY )
	{
		IntPoint pStart(startX, startY);
		IntPoint pEnd(endX, endY);
		IntPoint pBlock;
		SpriteMove::slogicblock->FirstBlock(pStart, pEnd, pBlock);
		return pBlock;
	}

	std::list<cmap::IntPoint> SpriteMove::GetMovePoints( int fromx, int fromy, int tox, int toy )
	{
		std::list<cmap::IntPoint> res;
		return res;
	}

	SpriteMove* SpriteMove::create()
	{
		SpriteMove* spriteMove = new SpriteMove();
		spriteMove->autorelease();
		return spriteMove;
	}

	CCArray* SpriteMove::getMovePoints( int fromx,int fromy, int tox,int toy )
	{
		return this->mpath->getMovePoints();
// 		std::list<cmap::IntPoint> moveList = GetMovePoints( fromx,fromy,tox,toy );
// 		CCArray* array = CCArray::create();
// 		for (std::list<cmap::IntPoint>::iterator it = moveList.begin();it != moveList.end();it++)
// 		{
// 			cmap::IntPoint intPoint = (*it);
// 			PathPoint* point = PathPoint::create(intPoint.x,intPoint.y);
// 			array->addObject(point);
// 		}
// 		return array;
	}

}