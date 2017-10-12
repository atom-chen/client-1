#include "core/RenderScene.h"
#include "core/RenderSceneLayer.h"
#include "core/RenderSprite.h"
//#include "map/sap/SAP.h"
namespace core
{

	RenderSceneLayerBase::RenderSceneLayerBase():m_bLayerDirty(false)
	{

	}

	RenderSceneLayerBase::~RenderSceneLayerBase()
	{

	}

	void RenderSceneLayerBase::setLayerDirty(bool dirty)
	{
		m_bLayerDirty = dirty;
	}

	void RenderSceneLayerBase::visit()
	{
		//this->sort();

		kmGLPushMatrix();

		this->transform();

		//this->draw();
		if(m_pChildren && m_pChildren->count() > 0)
		{
			//sortAllChildren();
			arrayMakeObjectsPerformSelector(m_pChildren, visit, CCNode*);
		}

		kmGLPopMatrix();
	}

	void RenderSceneLayerBase::addChild( cocos2d::CCNode * child, int zOrder, int tag )
	{
		if (CCSprite *spr = dynamic_cast<CCSprite *>(child))
		{
			CCTexture2D* texture = spr->getTexture();
			spr->setTag(tag);
			CCAssert(texture != NULL, "RenderSceneLayerBase::addChild ccprite tex is null");
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
			{
				batchNode->addChild(child);
				batchNode->setZOrder(zOrder);
				batchNode->setTag(tag);
			}
		}
		else
		{
			CCNode::addChild(child, zOrder, tag);
		}
	}

	void RenderSceneLayerBase::removeChild( CCNode* child )
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
				}
			}else{
				CCNode::removeChild(child, true);
			}
		}
		else
			CCNode::removeChild(child, true);
	}

	void RenderSceneLayerBase::removeAllChildren()
	{
		//没有retain，所以不需要释放
		m_batchNode.clear();
		CCNode::removeAllChildren();
	}

	RenderSceneLayer::RenderSceneLayer()
	{

	}

	RenderSceneLayer::~RenderSceneLayer()
	{

	}

	void RenderSceneLayer::addChild( cocos2d::CCNode * child, int zOrder, int tag )
	{
		//CCAssert(child != NULL, "child should not be null");

		//RenderSprite* renderNode = dynamic_cast<RenderSprite*>(child) ;
		//CCAssert(renderNode != NULL, "RenderSceneLayer::addChild only supports RenderSprite as children");
		//renderNode->setRenderSceneLayer(this);
		CCNode::addChild(child, zOrder, tag);
	}

	void RenderSceneLayer::visit()
	{
		//孩子不排序，子类的tick里排序
		if (!m_bVisible)
		{
			return;
		}

		this->sort();

		kmGLPushMatrix();

		this->transform();

		//this->draw();
		arrayMakeObjectsPerformSelector(m_pChildren, visit, CCNode*);

		kmGLPopMatrix();
	}

	void RenderSceneLayer::update(float dt/*, Camera* pCamera */)
	{
	}

	void RenderSceneLayer::sort()
	{
		if ( m_pChildren )
		{
			int i,j,length = m_pChildren->data->num;
			CCNode ** x = (CCNode**)m_pChildren->data->arr;
			CCNode *tempItem;

			for(i=1; i<length; i++)
			{
				tempItem = x[i];
				j = i-1;

				while(j>=0 && ( tempItem->getPositionY() < x[j]->getPositionY()  ) )
				{
					x[j+1] = x[j];
					j = j-1;
				}
				x[j+1] = tempItem;
			}

			setLayerDirty(false);
		}
	}

}

