/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009-2010 Ricardo Quesada
Copyright (C) 2009      Matt Oswald
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

#ifndef __SF_SPRITE_BATCH_NODE_H__
#define __SF_SPRITE_BATCH_NODE_H__

#include "base_nodes/CCNode.h"
#include "CCProtocols.h"
#include "textures/CCTextureAtlas.h"
#include "ccMacros.h"
#include "cocoa/CCArray.h"
#include "sprite_nodes/CCSpriteBatchNode.h"

NS_CC_BEGIN

/**
 * @addtogroup sprite_nodes
 * @{
 */

#define kDefaultSpriteBatchCapacity   29

class CCSprite;
/** SFSpriteBatchNode is like a batch node: if it contains children, it will draw them in 1 single OpenGL call
* (often known as "batch draw").
*
* A SFSpriteBatchNode can reference one and only one texture (one image file, one texture atlas).
* Only the CCSprites that are contained in that texture can be added to the SFSpriteBatchNode.
* All CCSprites added to a SFSpriteBatchNode are drawn in one OpenGL ES draw call.
* If the CCSprites are not added to a SFSpriteBatchNode then an OpenGL ES draw call will be needed for each one, which is less efficient.
*
*
* Limitations:
*  - The only object that is accepted as child (or grandchild, grand-grandchild, etc...) is CCSprite or any subclass of CCSprite. eg: particles, labels and layer can't be added to a SFSpriteBatchNode.
*  - Either all its children are Aliased or Antialiased. It can't be a mix. This is because "alias" is a property of the texture, and all the sprites share the same texture.
* 
* @since v0.7.1
*/
class CC_DLL SFSpriteBatchNode : public CCSpriteBatchNode
{
public:

    SFSpriteBatchNode();
    ~SFSpriteBatchNode();

    /** creates a SFSpriteBatchNode with a texture2d and capacity of children.
    The capacity will be increased in 33% in runtime if it run out of space.
    */
    static SFSpriteBatchNode* createWithTexture(CCTexture2D* tex, unsigned int capacity);
    static SFSpriteBatchNode* createWithTexture(CCTexture2D* tex) {
        return SFSpriteBatchNode::createWithTexture(tex, kDefaultSpriteBatchCapacity);
    }

    /** creates a SFSpriteBatchNode with a file image (.png, .jpeg, .pvr, etc) and capacity of children.
    The capacity will be increased in 33% in runtime if it run out of space.
    The file will be loaded using the TextureMgr.
    */
    static SFSpriteBatchNode* create(const char* fileImage, unsigned int capacity);
    static SFSpriteBatchNode* create(const char* fileImage) {
        return SFSpriteBatchNode::create(fileImage, kDefaultSpriteBatchCapacity);
    }

    void removeSpriteFromAtlas(CCSprite *sprite);
    virtual void visit(void);
    virtual void addChild(CCNode * child, int zOrder, int tag);
    virtual void removeChild(CCNode* child, bool cleanup);
    virtual void sortAllChildren();
    virtual void draw(void);
};

// end of sprite_nodes group
/// @}

NS_CC_END

#endif // __CC_SPRITE_BATCH_NODE_H__
