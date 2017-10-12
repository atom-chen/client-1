#ifndef _MAP_LOGIC_BLOCK_H_
#define _MAP_LOGIC_BLOCK_H_

namespace cmap
{
	class IntPoint;
	class LogicBlock
	{
	public:
		LogicBlock();
		virtual ~LogicBlock();

		virtual unsigned int GetSizeW() const;
		virtual unsigned int GetSizeH() const;

		virtual const unsigned char* GetBlockData() const;

		virtual bool IsBlock(int x, int y) const;
		virtual bool IsValid(int x, int y) const;
		virtual bool IsBlock(const IntPoint& point) const;
		virtual bool IsValid(const IntPoint& point) const;
		virtual bool HaveBlock(const IntPoint& from, const IntPoint& to) const;		// 两点之间是否有障碍
		virtual bool FirstBlock(const IntPoint& from, const IntPoint& to, IntPoint& firstBlock) const; //碰到的第一个障碍
		virtual bool LastNotBlock(const IntPoint& from, const IntPoint& to, IntPoint& lastNotBlock) const; //碰到障碍前的最后一个非障碍。 from 必须是非障碍 

	public:
		void InitAreaLimit();//把最外面一圈设为阻挡

	private:
		inline bool _IsBlock(const IntPoint& point) const;

	private:
		friend class Block;
		friend class SpriteMove;
		unsigned char* buffer;
		unsigned int bufferSize;
		unsigned int width;
		unsigned int height;
	};
}

#endif
