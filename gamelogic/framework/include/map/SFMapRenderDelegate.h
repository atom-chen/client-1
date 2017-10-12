#ifndef _SF_MAP_RENDER_DELEGATE_H_
#define _SF_MAP_RENDER_DELEGATE_H_

#include "cocos2d.h"
//临时的渲染托管类。后续需要去掉这样的渲染优化托管 todo fixme at 3.0
//简化处理cocos2d-x 的2.x版本的渲染优化，在3.0的时候需要去掉这里做法
NS_CC_BEGIN
//这里没有对代码做很好处理。不考虑扩展性的问题。因为我迟早要删的。
//如果相同资源的话，使用batch提交
class SFMapBackgroud : public CCNode
{
public:
	virtual void addChild(CCNode * child);
	virtual void addChild(CCNode * child, int zOrder);
	virtual void addChild(CCNode* child, int zOrder, int tag);
	virtual void removeChild(CCNode* child);
	virtual void removeAllChildrenWithCleanup(bool cleanup);

	void addChild(CCNode* child, bool batchEnable, int zOrder, int tag);
protected:
	std::map<unsigned int, CCSpriteBatchNode* >	m_batchNode;
private:
};

// 使用buff渲染。如果不是用buff渲染。请直接使用ccnode。这里不做包装
class SFMapBuff : public CCNode
{
public:
	virtual void addChild(CCNode * child);
	virtual void addChild(CCNode * child, int zOrder);
	virtual void addChild(CCNode* child, int zOrder, int tag);
	virtual void removeChild(CCNode* child);
	virtual void removeAllChildrenWithCleanup(bool cleanup);
protected:
private:
};
NS_CC_END
#endif