#ifndef RenderSprite_h__
#define RenderSprite_h__

#include "cocos2d.h"
#include <list>
#include "core/SFRenderSprite.h"
namespace cmap
{
	struct BodyModelInfo;
}

namespace core
{
	class RenderSceneLayer;

	class RenderSprite : public cocos2d::CCNodeRGBA
	{
		public:		
			void	reset();
		protected:
			int								m_notifyScriptHandler;	//lua
			//控制逻辑
			int								m_nAngle;
			unsigned char					m_fSpriteAlpha;
			bool							m_bEnableOpacity;
			unsigned char					m_targetAlpha;
			cocos2d::extension::SFRenderSprite*					m_sprtieModel;
			bool							m_enable;
		public:
			RenderSprite();
			virtual ~RenderSprite();
			virtual void setPosition(const CCPoint &position);
			virtual void setPosition(float x, float y);
			//-------------------------------------------------------------------------------
			//逻辑调用
		public:
			bool load(unsigned int modelId, unsigned int defaultId = 0);
			void onLeaveMap();
			int	 getModelId();
			//add by zhan reset rendersprite
			void clear();
			//角度
			void setAngle(int dir);
			int getAngle();
			//alpha
			void setAlpha(unsigned char alpha);
			//set rendersprite visible
			void setRenderSpriteVisible(bool visible);
			bool getRenderSpriteVisible();
			//动作
			bool changeActionCallback(int actionId, float speed, bool loop, int nScriptHandler);
			bool changeAction(int actionId, float speed, bool loop);
			void changeModel(int modelId);
			void changeModelWithDefault(int modelId, int defaultId,bool gender);
			void setAnimSpeed(float speed);
			//float getAnimSpeed();
			int getActionId();
			void setEnableOpacity(bool enable);
			//改变模型节点
			//add by zhanxianbo change part with default model
			void changePartWithDefault(int partType, int showId, bool gender,unsigned int defaultId = 0, short offsetX = 0, short offsetY = 0);
			void setPartScale(int partType, float scale);
			float getPartScale(int partType);
			//void changePart(int partType, int showId, bool gender, cocos2d::CCPoint ptOffset=cocos2d::CCPoint(0, 0));
			//移除part
			void setVisiblePart(int partType, bool visible);
			//bool isPartVisible(int partType);
			// lua需要的回调
			void setAnimNotifyScriptHandler(int nScriptHandler);

			void setEnable(bool bEnable);
			bool getEnable();
			//碰撞盒
			cocos2d::CCRect getBoundRect();
			cocos2d::CCNode* getHeadNode();
			// model center position y
			float getCenterPositionY();
			unsigned char getAlpha();
			// add by liu rui, 用来支持shader
			virtual void setShaderProgram(cocos2d::CCGLProgram *pShaderProgram);
			//add by zhanxianbo using this for fadein action
			virtual void setOpacity(GLubyte opacity);

			void setRenderOffset(cocos2d::CCPoint offset);
		//-------------------------------------------------------------------------------
		//引擎调用
		public:
			virtual void visit();
		public:
			//void setRenderSceneLayer(RenderSceneLayer* layer);
			int getZOrder();
			virtual const cocos2d::CCSize& getContentSize();
	};
}
#endif // RenderSprite_h__