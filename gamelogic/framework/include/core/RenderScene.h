/********************************************************************
文件名:RenderScene.h
创建者:yangguiming
创建时间:2013-5-3 11:45
功能描述:	 RenderScene只接受RenderSceneLayer
*********************************************************************/
#ifndef RenderScene_h__
#define RenderScene_h__


#include "RenderSceneLayer.h"


namespace cocos2d 
{
		class MemoryStream;
}

namespace cmap
{
	class Map;
}

namespace core
{
	class RenderScene : public cocos2d::CCNode
	{
	private:
		cmap::Map* m_pMap;

	public:
		RenderScene();
		~RenderScene();

	public:
		virtual void visit();
		virtual void scheduleUpdate();

		virtual void addChild(cocos2d::CCNode * child, int zOrder, int tag);//重载addchild，只能添加RenderSceneLayer
		
		virtual void update(float dt);
	public:
		void load(cocos2d::MemoryStream &msback);

		//virtual Camera* getCamera();
		virtual cmap::Map* getMap();
		void setViewCenter(int x, int y);
	private:
	};
}

#endif // RenderScene_h__