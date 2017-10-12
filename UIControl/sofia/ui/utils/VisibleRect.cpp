
#include "ui/utils/VisibleRect.h"

using namespace cocos2d;


#define kScreenSize CCSizeMake(960, 640)

const CCRect&  VisibleRect::rect()
{
	static CCRect s_rcVisible;
	if (0 == s_rcVisible.size.width)
	{
		CCSize visibleSize = CCDirector::sharedDirector()->getVisibleSize();
		CCPoint origin = CCDirector::sharedDirector()->getVisibleOrigin();
		s_rcVisible.origin = origin;
		s_rcVisible.size = visibleSize;
	}

	return s_rcVisible;
}

const CCPoint& VisibleRect::center()
{
	static CCPoint s_ptCenter;
	if (0 == s_ptCenter.x)
	{
		CCRect rc = VisibleRect::rect();
		s_ptCenter.x = rc.origin.x + rc.size.width / 2;
		s_ptCenter.y = rc.origin.y + rc.size.height / 2;
	}
	return s_ptCenter;
}

const CCPoint& VisibleRect::top()
{
	static CCPoint s_ptTop;
	if (0 == s_ptTop.x)
	{
		CCRect rc = VisibleRect::rect();
		s_ptTop.x = rc.origin.x + rc.size.width / 2;
		s_ptTop.y = rc.origin.y + rc.size.height;
	}
	return s_ptTop;
}

const CCPoint& VisibleRect::topRight()
{
	static CCPoint s_ptTopRight;
	if (0 == s_ptTopRight.x)
	{
		CCRect rc = VisibleRect::rect();
		s_ptTopRight.x = rc.origin.x + rc.size.width;
		s_ptTopRight.y = rc.origin.y + rc.size.height;
	}
	return s_ptTopRight;
}

const CCPoint& VisibleRect::right()
{
	static CCPoint s_ptRight;
	if (0 == s_ptRight.x)
	{
		CCRect rc = VisibleRect::rect();
		s_ptRight.x = rc.origin.x + rc.size.width;
		s_ptRight.y = rc.origin.y + rc.size.height / 2;
	}
	return s_ptRight;
}

const CCPoint& VisibleRect::bottomRight()
{
	static CCPoint s_ptBottomRight;
	if (0 == s_ptBottomRight.x)
	{
		CCRect rc = VisibleRect::rect();
		s_ptBottomRight.x = rc.origin.x + rc.size.width;
		s_ptBottomRight.y = rc.origin.y;
	}
	return s_ptBottomRight;
}

const CCPoint& VisibleRect::bottom()
{
	static CCPoint s_ptBottom;
	if (0 == s_ptBottom.x)
	{
		CCRect rc = VisibleRect::rect();
		s_ptBottom.x = rc.origin.x + rc.size.width / 2;
		s_ptBottom.y = rc.origin.y;
	}
	return s_ptBottom;
}

const CCPoint& VisibleRect::bottomLeft()
{
	return VisibleRect::rect().origin;
}

const CCPoint& VisibleRect::left()
{
	static CCPoint s_ptLeft;
	if (0 == s_ptLeft.x)
	{
		CCRect rc = VisibleRect::rect();
		s_ptLeft.x = rc.origin.x;
		s_ptLeft.y = rc.origin.y + rc.size.height / 2;
	}
	return s_ptLeft;
}

const CCPoint& VisibleRect::topLeft()
{
	static CCPoint s_ptTopLeft;
	if (0 == s_ptTopLeft.x)
	{
		CCRect rc = VisibleRect::rect();
		s_ptTopLeft.x = rc.origin.x;
		s_ptTopLeft.y = rc.origin.y + rc.size.height;
	}
	return s_ptTopLeft;
}

const CCPoint& VisibleRect::getScaleXY( CCSize winSize )
{
	static CCPoint s_scaleXY;
	if (0 == s_scaleXY.x){
		 CCRect rc = VisibleRect::rect();
		 s_scaleXY.x = winSize.width/kScreenSize.width;
		 s_scaleXY.y = winSize.height/kScreenSize.height;
	}
	return s_scaleXY;
}

void VisibleRect::autoScaleNode( CCNode *nd , CCPoint anchorPoint )
{
	static float scale = 0;
	if (0 == scale){
		CCSize visibleSize = CCDirector::sharedDirector()->getVisibleSize();
		CCPoint scaleXY = VisibleRect::getScaleXY(visibleSize);
		scale = (scaleXY.x>scaleXY.y)?scaleXY.y:scaleXY.x;
	}
	nd->setAnchorPoint(anchorPoint);
	nd->setScale(scale);

// 	CCPoint pos
// 	CCDirector* pDirector = CCDirector::sharedDirector();
// 	toleft = nd->getPosition().x / pDirector->getContentScaleFactor() - 1.0f;
// 	totop = nd->getPosition().y / pDirector->getContentScaleFactor() - 1.0f ;
// 	drawW = drawW / pDirector->getContentScaleFactor() +1.0f;
// 	drawH = drawH / pDirector->getContentScaleFactor() +1.0f;
}

const CCPoint& VisibleRect::getNodeScale(CCNode *nd, CCSize size){
	static CCPoint scaleXY;
	CCSize nodeSize = nd->boundingBox().size;
	scaleXY.x = size.width/nodeSize.width;
	scaleXY.y = size.height/nodeSize.height;
	return scaleXY;
}



//////////////////////////////////////////////////////////////////////////


void VisibleRect::autoSizeNode(cocos2d::CCNode *node, ScaleType type /*= eScaleMin*/)
{
	if (type == eScaleXY){
		node->setScaleX(SFGetScaleX());
		node->setScaleY(SFGetScaleY());
	}
	else if(type == eScaleMin){
		node->setScale(SFGetScale());
	}
	else {
		node->setScale((SFGetScaleX()>SFGetScaleY())?SFGetScaleX():SFGetScaleY());
	}
}

void VisibleRect::autoSizeNodeForSmall(cocos2d::CCNode *node)
{
	CCSize screenSize = CCDirector::sharedDirector()->getVisibleSize();

	if (screenSize.width >= kScreenSize.width && screenSize.height >= kScreenSize.height)
	{
		return;
	}
	autoSizeNode(node);
}

//void VisibleRect::autoPosNode(cocos2d::CCNode *node)
//{
//	CCSize screenSize = CCDirector::sharedDirector()->getWinSizeInPixels();
//
//	CCPoint pos;
//	float x = (screenSize.width*node->getPositionX())/(kScreenSize.width);
//	float y = (screenSize.height*node->getPositionY())/(kScreenSize.height);
//	pos = ccp(x, y);
//
//	node->setPosition(pos);
//}

int VisibleRect::autoFontSize(int fontSize/*cocos2d::CCNode *node*/)
{
	/*CCLabelTTF *font = (CCLabelTTF *)node;

	int fontSize = (designResolutionSize.height*font->getFontSize())/(smallResource.size.height*2);
	font->setFontSize(fontSize);*/

	return SFGetScale() * fontSize;
}

cocos2d::CCSize VisibleRect::nodeSize(cocos2d::CCNode *node)
{
	CCArray *nodeArray = NULL;
	nodeArray = node->getChildren();
	CCSize finalSize = node->getContentSize();

	if (nodeArray)
	{
		CCSize maxSize = CCSizeZero;
		CCSize minSize = CCSizeZero;
		CCPoint pos = CCPointZero;
		CCPoint anchorPos = CCPointZero;

		CCObject *obj;
		CCARRAY_FOREACH(nodeArray, obj)
		{
			CCNode *tmpNode = (CCNode*)obj;
			CCSize tmpSize = nodeSize(tmpNode);
			CCPoint tmpPos = tmpNode->getPosition();
			CCPoint tmpAnchorPos = tmpNode->getAnchorPoint();

			if ((maxSize.width * (1-anchorPos.x) + pos.x) < 
				(tmpSize.width * (1-tmpAnchorPos.x) + tmpPos.x))
			{
				maxSize.width = tmpSize.width * (1-tmpAnchorPos.x) + tmpPos.x;
			}

			if ((maxSize.height * (1-anchorPos.y) + pos.y) < 
				(tmpSize.height * (1-tmpAnchorPos.y) + tmpPos.y))
			{
				maxSize.height = tmpSize.height * (1-tmpAnchorPos.y) + tmpPos.y;
			}

			if ((minSize.width * anchorPos.x + pos.x) > 
				(tmpSize.width * tmpAnchorPos.x + tmpPos.x))
			{
				minSize.width = tmpSize.width * tmpAnchorPos.x + tmpPos.x;
			}

			if ((minSize.height * anchorPos.y + pos.y) > 
				(tmpSize.height * tmpAnchorPos.y + tmpPos.y))
			{
				minSize.height = tmpSize.height * tmpAnchorPos.y + tmpPos.y;
			}
		}

		finalSize.width = maxSize.width - minSize.width;
		finalSize.height = maxSize.height - minSize.height;
	}

	return finalSize;
}

void VisibleRect::relativePosition(cocos2d::CCNode *node, cocos2d::CCNode *target, RelativeLayout layout /* = LAYOUT_CENTER */, CCPoint offset /* = CCPointZero */, bool bAutoAdaptation/* = true*/)
{
	if (!node || !target){
		return;
	}

	CCPoint nodePos = CCPointZero;
	CCPoint nodeAnchorPoint = CCPointZero;

	if (!node->isIgnoreAnchorPointForPosition())
		nodeAnchorPoint = node->getAnchorPoint();

	nodePos.x = node->getPositionX() - node->boundingBox().size.width/*node->getContentSize().width*/ * nodeAnchorPoint.x;
	nodePos.y = node->getPositionY() - node->boundingBox().size.height/*node->getContentSize().height*/ * nodeAnchorPoint.y;
	CCSize nodeSize = node->getContentSize();
	nodeSize.width = node->boundingBox().size.width;//nodeSize.width * node->getScaleX();
	nodeSize.height = node->boundingBox().size.height;//nodeSize.height * node->getScaleY();
	//CCSize nodeSize = VisibleRect::nodeSize(node);
	CCPoint nodeCenter = ccp(nodePos.x + nodeSize.width/2, nodePos.y + nodeSize.height/2);

	CCPoint targetPos = CCPointZero;
	CCPoint targetAnchorPoint = CCPointZero;

	if (!target->isIgnoreAnchorPointForPosition())
		targetAnchorPoint = target->getAnchorPoint();

	targetPos.x = target->getPositionX() - target->boundingBox().size.width/*target->getContentSize().width*/ * targetAnchorPoint.x;
	targetPos.y = target->getPositionY() - target->boundingBox().size.height/*target->getContentSize().height*/ * targetAnchorPoint.y;
	CCSize targetSize = target->getContentSize();
	targetSize.width = target->boundingBox().size.width;//targetSize.width * target->getScaleX();
	targetSize.height = target->boundingBox().size.height;//targetSize.height * target->getScaleY();
	//CCSize targetSize = VisibleRect::nodeSize(target);
	CCPoint targetCenter = ccp(targetPos.x + targetSize.width/2, targetPos.y + targetSize.height/2);

	CCPoint resolutionPos = node->getPosition();
	if (layout & LAYOUT_CENTER)
	{
		resolutionPos.x = targetCenter.x + nodeSize.width*(nodeAnchorPoint.x-0.5);
		resolutionPos.y = targetCenter.y + nodeSize.height*(nodeAnchorPoint.y-0.5);
	}

	if (layout & LAYOUT_TOP_INSIDE)
	{
		resolutionPos.y = (targetPos.y + targetSize.height) + nodeSize.height*(nodeAnchorPoint.y-1);
	}
	else if (layout & LAYOUT_TOP_OUTSIDE)
	{
		resolutionPos.y = (targetPos.y + targetSize.height) + nodeSize.height*(nodeAnchorPoint.y-0);
	}
	else if (layout & LAYOUT_BOTTOM_INSIDE)
	{
		resolutionPos.y = (targetPos.y) + nodeSize.height*(nodeAnchorPoint.y-0);
	}
	else if (layout & LAYOUT_BOTTOM_OUTSIDE)
	{
		resolutionPos.y = (targetPos.y) + nodeSize.height*(nodeAnchorPoint.y-1);
	}
	else if (layout & LAYOUT_CENTER_Y)
	{
		resolutionPos.y = targetCenter.y + nodeSize.height*(nodeAnchorPoint.y-0.5);
	}

	if (layout & LAYOUT_LEFT_INSIDE)
	{
		resolutionPos.x = targetPos.x + nodeSize.width*(nodeAnchorPoint.x-0);
	}
	else if (layout & LAYOUT_LEFT_OUTSIDE)
	{
		resolutionPos.x = targetPos.x + nodeSize.width*(nodeAnchorPoint.x-1);
	}
	else if (layout & LAYOUT_RIGHT_INSIDE)
	{
		resolutionPos.x = (targetPos.x + targetSize.width) + nodeSize.width*(nodeAnchorPoint.x-1);
	}
	else if (layout & LAYOUT_RIGHT_OUTSIDE)
	{
		resolutionPos.x = (targetPos.x + targetSize.width) + nodeSize.width*(nodeAnchorPoint.x-0);
	}
	else if (layout & LAYOUT_CENTER_X)
	{
		resolutionPos.x = targetCenter.x + nodeSize.width*(nodeAnchorPoint.x-0.5);
	}

	if (node->getParent()  == target)
	{
		// 设置在parent的位置要去掉scale的影响
		if (layout & LAYOUT_CENTER_X || layout & LAYOUT_CENTER || layout & LAYOUT_LEFT_INSIDE || layout & LAYOUT_LEFT_OUTSIDE ||
			layout & LAYOUT_RIGHT_INSIDE || layout & LAYOUT_RIGHT_OUTSIDE)
		{
			resolutionPos.x -= targetPos.x; //target->getPositionX();
			resolutionPos.x /= target->getScaleX();
		}
		
		if (layout & LAYOUT_CENTER_Y || layout & LAYOUT_CENTER || layout & LAYOUT_TOP_INSIDE || layout & LAYOUT_TOP_OUTSIDE ||
			layout & LAYOUT_BOTTOM_INSIDE || layout & LAYOUT_BOTTOM_OUTSIDE)
		{
			resolutionPos.y -= targetPos.y; //target->getPositionY();
			resolutionPos.y /= target->getScaleY();
		}
	}

	if (bAutoAdaptation)
	{
		resolutionPos.x += (offset.x * VisibleRect::SFGetScale()/*node->getScaleX()*/);
		resolutionPos.y += (offset.y * VisibleRect::SFGetScale()/*node->getScaleY()*/);
	}
	else
	{
		resolutionPos.x += offset.x;
		resolutionPos.y += offset.y;
	}

	node->setPosition(resolutionPos);
}

float VisibleRect::SFGetScaleX()
{
	static float s_scaleX = 0;
	if(s_scaleX==0){
		CCSize winSize = 
			CCDirector::sharedDirector()->getVisibleSize();
		return winSize.width  / kScreenSize.width;
	}
	return s_scaleX;
}

float VisibleRect::SFGetScaleY()
{
	static float s_scaleY = 0;
	if(s_scaleY==0){
		CCSize winSize = 
			CCDirector::sharedDirector()->getVisibleSize();
		return winSize.height  / kScreenSize.height;
	}
	return s_scaleY;
}

float VisibleRect::SFGetScale()
{
	static float s_scale = 0;
	if(s_scale==0){
		s_scale = (SFGetScaleX()>SFGetScaleY())?SFGetScaleY():SFGetScaleX();
	}
	return s_scale;
}

float VisibleRect::SFGetScaleOverOne()
{
	static float s_scaleOne = 0;
	if(s_scaleOne==0){
		s_scaleOne = (SFGetScale()>1)?SFGetScale():1;
	}
	return s_scaleOne;
}

cocos2d::CCSize VisibleRect::sizeToFix( cocos2d::CCSize size, int width, int height )
{
	if(SFGetScaleX()!=SFGetScaleY()){
		size.width = (size.width+width*2);
		size.height = (size.height+height*2);
	}
	size.width = size.width*SFGetScale();
	size.height = size.height*SFGetScale();
	return size;
}

cocos2d::CCSize VisibleRect::getScaleSize( cocos2d::CCSize size )
{
	return CCSizeMake(size.width*SFGetScale(), size.height*SFGetScale());
}

cocos2d::CCPoint VisibleRect::getScalePoint( cocos2d::CCPoint pt )
{
	return ccp(pt.x*SFGetScaleX(), pt.y*SFGetScaleY());
}

float VisibleRect::getScaleLength( float length )
{
	return length*SFGetScale();
}
