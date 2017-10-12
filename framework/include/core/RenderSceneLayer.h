/********************************************************************
文件名:RenderSceneLayer.h
创建者:yangguiming
创建时间:2013-4-23 20:21
功能描述:	 场景层次，由子类实现具体的绘制次序；只接受RenderSceneNode
*********************************************************************/
#ifndef RenderSceneLayer_h__
#define RenderSceneLayer_h__

//#include "Camera.h"
#include "cocos2d.h"
USING_NS_CC;
namespace core
{

	class RenderSceneLayerBase : public CCNode
	{
	public:
		RenderSceneLayerBase();
		virtual ~RenderSceneLayerBase();

		void setLayerDirty(bool dirty);

		virtual void update(float dt /*,Camera* pCamera*/) {}
		virtual void visit();

		virtual void addChild(cocos2d::CCNode * child, int zOrder, int tag);
		virtual void removeChild(CCNode* child);
		virtual void removeAllChildren();
	protected:
		bool		m_bLayerDirty;
		std::map<unsigned int, CCSpriteBatchNode* >	m_batchNode;

	};

	class RenderSceneLayer : public RenderSceneLayerBase
	{
	protected:

	public:
		RenderSceneLayer();
		~RenderSceneLayer();
	public:
		virtual void addChild(cocos2d::CCNode * child, int zOrder, int tag);
		virtual void visit();

	public:
		void update(float dt /*,Camera* pCamera*/) ;

	private:
		//子类实现（对m_childList操作）
		void sort();
	};
}


#endif // RenderSceneLayer_h__