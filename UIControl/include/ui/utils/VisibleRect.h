#ifndef __VISIBLE_RECT_H__
#define __VISIBLE_RECT_H__

#include "cocos2d.h"
USING_NS_CC;

enum
{
	LAYOUT_CENTER			= 1 << 0,
	LAYOUT_TOP_INSIDE		= 1 << 1,
	LAYOUT_BOTTOM_INSIDE	= 1 << 2,
	LAYOUT_LEFT_INSIDE		= 1 << 3,
	LAYOUT_RIGHT_INSIDE		= 1 << 4,
	LAYOUT_TOP_OUTSIDE		= 1 << 5,
	LAYOUT_BOTTOM_OUTSIDE	= 1 << 6,
	LAYOUT_LEFT_OUTSIDE		= 1 << 7,
	LAYOUT_RIGHT_OUTSIDE	= 1 << 8,
	LAYOUT_CENTER_X			= 1 << 9,
	LAYOUT_CENTER_Y			= 1 << 10
};
typedef unsigned int RelativeLayout;

class VisibleRect
{
public:
    static const cocos2d::CCRect&  rect();
    static const cocos2d::CCPoint& center();
    static const cocos2d::CCPoint& top();
    static const cocos2d::CCPoint& topRight();
    static const cocos2d::CCPoint& right();
    static const cocos2d::CCPoint& bottomRight();
    static const cocos2d::CCPoint& bottom();
    static const cocos2d::CCPoint& bottomLeft();
    static const cocos2d::CCPoint& left();
    static const cocos2d::CCPoint& topLeft();
	static const cocos2d::CCPoint& getScaleXY(cocos2d::CCSize winSize);
	static const cocos2d::CCPoint& getNodeScale(cocos2d::CCNode *nd, cocos2d::CCSize size);
	static void autoScaleNode(cocos2d::CCNode *nd , cocos2d::CCPoint anchorPoint);

	static float SFGetScaleX();
	static float SFGetScaleY();
	static float SFGetScale();
	static float SFGetScaleOverOne();

	enum ScaleType{
		eScaleXY,
		eScaleMin,
		eScaleMax
	};
	// 主要对主窗体用
	static cocos2d::CCSize sizeToFix(cocos2d::CCSize size, int width, int height);
	// 自动缩放
	static void autoSizeNode(cocos2d::CCNode *node, ScaleType type = eScaleMin);
	
	// 小于正常尺寸下自动缩小
	static void autoSizeNodeForSmall(cocos2d::CCNode *node);

	// 字体大小
	static int autoFontSize(int fontSize/*cocos2d::CCNode *node*/);

	//static void autoPosNode(cocos2d::CCNode *node);

	//相对位置
	//node:要移动的对象
	//target:相对的目标
	static void relativePosition(cocos2d::CCNode *node, cocos2d::CCNode *target, RelativeLayout layout = LAYOUT_CENTER, cocos2d::CCPoint offset = cocos2d::CCPoint(0, 0), bool bAutoAdaptation = true);

	//计算node的size
	//慎用
	static cocos2d::CCSize nodeSize(cocos2d::CCNode *node);

	// 计算缩放后的CCSize
	static cocos2d::CCSize getScaleSize(cocos2d::CCSize size);

	// 计算缩放后的CCPoint
	static cocos2d::CCPoint getScalePoint(cocos2d::CCPoint pt);

	// 计算缩放后的长度
	static float getScaleLength(float length);
};

static inline bool ccc3BEqual(ccColor3B a, ccColor3B b)
{
   return a.r == b.r && a.g == b.g && a.b == b.b;
} 

#endif	// __VISIBLE_RECT_H__