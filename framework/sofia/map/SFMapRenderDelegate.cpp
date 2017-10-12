#include "map/SFMapRenderDelegate.h"
USING_NS_CC;

void SFMapBackgroud::addChild(CCNode * child)
{
	CCAssert(false, "not allow to used this api,please use addChild(CCNode* child, bool batchEnable)");
}

void SFMapBackgroud::addChild(CCNode * child, int zOrder)
{
	CCAssert(false, "not allow to used this api,please use addChild(CCNode* child, bool batchEnable)");
}

void SFMapBackgroud::addChild(CCNode* child, int zOrder, int tag)
{
	CCAssert(false, "not allow to used this api,please use addChild(CCNode* child, bool batchEnable)");
}

void cocos2d::SFMapBackgroud::addChild( CCNode* child, bool batchEnable, int zOrder, int tag )
{
	if (batchEnable)
	{
		if (CCSprite *spr = dynamic_cast<CCSprite *>(child))
		{
			CCTexture2D* texture = spr->getTexture();
			if(texture)
			{
				spr->setTag(tag);
				//spr->setZOrder(zOrder);
				unsigned int nameId = texture->getName();
				std::map<unsigned int, CCSpriteBatchNode* >::iterator iter = m_batchNode.find(nameId);
				CCSpriteBatchNode* batchNode = NULL;
				if (iter == m_batchNode.end())
				{
					batchNode = CCSpriteBatchNode::createWithTexture(texture);
					m_batchNode.insert(std::pair<unsigned int, CCSpriteBatchNode*>(nameId, batchNode));
					CCNode::addChild(batchNode, zOrder, tag);
				}
				else
				{
					batchNode = iter->second;
				}
				batchNode->addChild(child);
				//batchNode->setZOrder(zOrder);
				batchNode->setTag(tag);
			}
		}
		else
			CCNode::addChild(child, zOrder, tag);
	}
	else
		CCNode::addChild(child, zOrder, tag);
}

void SFMapBackgroud::removeChild(CCNode* child)
{
	if (CCSprite *spr = dynamic_cast<CCSprite *>(child))
	{
		CCTexture2D* texture = spr->getTexture();
		if (texture)
		{
			unsigned int nameId = texture->getName();
			std::map<unsigned int, CCSpriteBatchNode* >::iterator iter = m_batchNode.find(nameId);
			if (iter != m_batchNode.end())
			{
				CCSpriteBatchNode* batchNode = iter->second;
				batchNode->removeChild(child, true);
				if(batchNode->getChildrenCount() == 0)
				{
					m_batchNode.erase(iter);
					CCNode::removeChild(batchNode, true);
				}
				return;
			}
		}
	}
// 	child->removeFromParent();
	CCNode::removeChild(child, true);
}

void SFMapBackgroud::removeAllChildrenWithCleanup(bool cleanup)
{
	m_batchNode.clear();
	CCNode::removeAllChildrenWithCleanup(cleanup);
}

void cocos2d::SFMapBuff::addChild( CCNode * child )
{
	this->addChild(child, 0, 0);
}

void cocos2d::SFMapBuff::addChild( CCNode * child, int zOrder )
{
	this->addChild(child, zOrder, 0);
}

void cocos2d::SFMapBuff::addChild( CCNode* child, int zOrder, int tag )
{

}

void cocos2d::SFMapBuff::removeChild( CCNode* child )
{

}

void cocos2d::SFMapBuff::removeAllChildrenWithCleanup( bool cleanup )
{

}
