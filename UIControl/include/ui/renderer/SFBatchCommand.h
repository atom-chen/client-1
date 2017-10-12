#ifndef _SF_BATCH_COMMAND_H_
#define _SF_BATCH_COMMAND_H_
#include "cocos2d.h"
NS_CC_BEGIN
	// 把所有的渲染元素加入到渲染列表。
	// 有command自行创建需要渲染的batchnode
	// 本身的node不做任何渲染行为，全部委托给此类
	class CCSpriteBatchNode;
class SFBatchCommand : public CCLayer
{
public:
	SFBatchCommand();
	virtual ~SFBatchCommand();
public:
	//针对部分特殊控件优化，不在优化方案内的控件用默认方式渲染
	virtual void addChild(CCNode * child);
	virtual void addChild(CCNode * child, int zOrder);
	virtual void addChild(CCNode* child, int zOrder, int tag);
protected:
	//CCSpriteBatchNode*		m_
	typedef std::map<CCTexture2D*, int>		TextureInfo;
	TextureInfo					m_textureInfo;
private:
};
NS_CC_END
#endif