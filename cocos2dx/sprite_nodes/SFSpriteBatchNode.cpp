/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009-2010 Ricardo Quesada
Copyright (c) 2009      Matt Oswald
Copyright (c) 2011      Zynga Inc.

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "SFSpriteBatchNode.h"
#include "ccConfig.h"
#include "CCSprite.h"
#include "effects/CCGrid.h"
#include "draw_nodes/CCDrawingPrimitives.h"
#include "textures/CCTextureCache.h"
#include "support/CCPointExtension.h"
#include "shaders/CCShaderCache.h"
#include "shaders/CCGLProgram.h"
#include "shaders/ccGLStateCache.h"
#include "CCDirector.h"
#include "support/TransformUtils.h"
#include "support/CCProfiling.h"
// external
#include "kazmath/GL/matrix.h"

NS_CC_BEGIN

	/*
	* creation with CCTexture2D
	*/

	SFSpriteBatchNode* SFSpriteBatchNode::createWithTexture(CCTexture2D* tex, unsigned int capacity/* = kDefaultSpriteBatchCapacity*/)
{
	SFSpriteBatchNode *batchNode = new SFSpriteBatchNode();
	batchNode->initWithTexture(tex, capacity);
	batchNode->autorelease();

	return batchNode;
}

/*
* creation with File Image
*/

SFSpriteBatchNode* SFSpriteBatchNode::create(const char *fileImage, unsigned int capacity/* = kDefaultSpriteBatchCapacity*/)
{
	SFSpriteBatchNode *batchNode = new SFSpriteBatchNode();
	batchNode->initWithFile(fileImage, capacity);
	batchNode->autorelease();

	return batchNode;
}

SFSpriteBatchNode::SFSpriteBatchNode()
{
}

SFSpriteBatchNode::~SFSpriteBatchNode()
{

}

// override visit
// don't call visit on it's children
void SFSpriteBatchNode::visit(void)
{
	CC_PROFILER_START_CATEGORY(kCCProfilerCategoryBatchSprite, "SFSpriteBatchNode - visit");

	// CAREFUL:
	// This visit is almost identical to CocosNode#visit
	// with the exception that it doesn't call visit on it's children
	//
	// The alternative is to have a void CCSprite#visit, but
	// although this is less maintainable, is faster
	//
	if (! m_bVisible)
	{
		return;
	}

	kmGLPushMatrix();

	if (m_pGrid && m_pGrid->isActive())
	{
		m_pGrid->beforeDraw();
		transformAncestors();
	}

	sortAllChildren();
	transform();

	draw();

	//Juchao@20140521: 对于非Sprite或者不参加批处理Sprite, 调用其visit函数进行单独绘制
	CCObject *pObj;
	CCSprite *pSprite;
	CCARRAY_FOREACH(m_pChildren, pObj)
	{
		pSprite = dynamic_cast<CCSprite*>(pObj);
		if ((!pSprite)) {
			((CCNode*)pObj)->visit();
		} else if (!pSprite->getBatchNode()) {
			pSprite->visit();
		}
	}

	if (m_pGrid && m_pGrid->isActive())
	{
		m_pGrid->afterDraw(this);
	}

	kmGLPopMatrix();
	setOrderOfArrival(0);

	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategoryBatchSprite, "SFSpriteBatchNode - visit");
}

void SFSpriteBatchNode::addChild(CCNode *child, int zOrder, int tag)
{
	CCAssert(child != NULL, "child should not be null");
	//CCAssert(dynamic_cast<CCSprite*>(child) != NULL, "SFSpriteBatchNode only supports CCSprites as children");
	CCSprite *pSprite = dynamic_cast<CCSprite*>(child);
	// check CCSprite is using the same texture id
	//CCAssert(pSprite->getTexture()->getName() == m_pobTextureAtlas->getTexture()->getName(), "CCSprite is not using the same texture id");

	CCNode::addChild(child, zOrder, tag);
	//Juchao@20140521: Sprite类型且纹理Id一样才加入批处理
	if (pSprite && pSprite->getTexture() && pSprite->getTexture()->getName() == m_pobTextureAtlas->getTexture()->getName())
		appendChild(pSprite);
}

// override remove child
void SFSpriteBatchNode::removeChild(CCNode *child, bool cleanup)
{
	CCSprite *pSprite = dynamic_cast<CCSprite*>(child);

	// explicit null handling
	if (pSprite && pSprite->getBatchNode())
	{
		// cleanup before removing
		removeSpriteFromAtlas(pSprite);
	}

	//CCAssert(m_pChildren->containsObject(pSprite), "sprite batch node should contain the child");
	CCNode::removeChild(child, cleanup); //use child, not pSprite
}

//override sortAllChildren
void SFSpriteBatchNode::sortAllChildren()
{
	if (m_bReorderChildDirty)
	{
		int i = 0,j = 0,length = m_pChildren->data->num;
		CCNode ** x = (CCNode**)m_pChildren->data->arr;
		CCNode *tempItem = NULL;

		//insertion sort
		for(i=1; i<length; i++)
		{
			tempItem = x[i];
			j = i-1;

			//continue moving element downwards while zOrder is smaller or when zOrder is the same but orderOfArrival is smaller
			while(j>=0 && ( tempItem->getZOrder() < x[j]->getZOrder() || ( tempItem->getZOrder() == x[j]->getZOrder() && tempItem->getOrderOfArrival() < x[j]->getOrderOfArrival() ) ) )
			{
				x[j+1] = x[j];
				j--;
			}

			x[j+1] = tempItem;
		}

		//sorted now check all children
		if (m_pChildren->count() > 0)
		{
			//first sort all children recursively based on zOrder
			arrayMakeObjectsPerformSelector(m_pChildren, sortAllChildren, CCSprite*);

			int index=0;

			CCObject* pObj = NULL;
			//fast dispatch, give every child a new atlasIndex based on their relative zOrder (keep parent -> child relations intact)
			// and at the same time reorder descendants and the quads to the right index
			CCARRAY_FOREACH(m_pChildren, pObj)
			{
				//CCSprite* pChild = (CCSprite*)pObj;
				CCSprite* pChild = dynamic_cast<CCSprite*>(pObj);
				if (pChild && pChild->getBatchNode())
					updateAtlasIndex(pChild, &index);
			}
		}

		m_bReorderChildDirty=false;
	}
}

// draw
void SFSpriteBatchNode::draw(void)
{
	CC_PROFILER_START("SFSpriteBatchNode - draw");

	// Optimization: Fast Dispatch
	if( m_pobTextureAtlas->getTotalQuads() == 0 )
	{
		return;
	}

	CC_NODE_DRAW_SETUP();

	//arrayMakeObjectsPerformSelector(m_pChildren, updateTransform, CCSprite*);
	//Juchao@20140521: Sprite类型且有BatchNode的才调用updateTransform
	CCObject *pObj;
	CCARRAY_FOREACH(m_pChildren, pObj)
	{
		CCSprite *pSprite = dynamic_cast<CCSprite*>(pObj);
		if (pSprite && pSprite->getBatchNode()) {
			pSprite->updateTransform();
		}
	}

	ccGLBlendFunc( m_blendFunc.src, m_blendFunc.dst );

	m_pobTextureAtlas->drawQuads();

	CC_PROFILER_STOP("SFSpriteBatchNode - draw");
}

void SFSpriteBatchNode::removeSpriteFromAtlas(CCSprite *pobSprite)
{
	// remove from TextureAtlas
	m_pobTextureAtlas->removeQuadAtIndex(pobSprite->getAtlasIndex());

	// Cleanup sprite. It might be reused (issue #569)
	pobSprite->setBatchNode(NULL);

	unsigned int uIndex = m_pobDescendants->indexOfObject(pobSprite);
	if (uIndex != UINT_MAX)
	{
		m_pobDescendants->removeObjectAtIndex(uIndex);

		// update all sprites beyond this one
		unsigned int count = m_pobDescendants->count();

		for(; uIndex < count; ++uIndex)
		{
			CCSprite* s = (CCSprite*)(m_pobDescendants->objectAtIndex(uIndex));
			s->setAtlasIndex( s->getAtlasIndex() - 1 );
		}
	}

	// remove children recursively
	CCArray *pChildren = pobSprite->getChildren();
	if (pChildren && pChildren->count() > 0)
	{
		CCObject* pObject = NULL;
		CCARRAY_FOREACH(pChildren, pObject)
		{
			CCSprite* pChild = dynamic_cast<CCSprite*>(pObject);
			if (pChild && pChild->getBatchNode())
			{
				removeSpriteFromAtlas(pChild);
			}
		}
	}
}


NS_CC_END
