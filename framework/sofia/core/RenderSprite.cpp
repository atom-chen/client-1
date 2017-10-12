//#include "core/utils.h"
#include "resource/EntityData.h"
#include "core/RenderSceneLayer.h"
#include "core/RenderSprite.h"
#include "script_support/CCScriptSupport.h"
#include "map/SFMapService.h"
#include "core/RenderScene.h"
#include "map/Map.h"
#include "resource/SFModelResConfig.h"
enum ModelNodeType
{
	kNodeHead = 1,
};
#define MASKALPHA  153
namespace core
{
	USING_NS_CC_EXT;
	RenderSprite::RenderSprite()
		:m_nAngle(0), 
		m_fSpriteAlpha(255)
		,m_targetAlpha(255)
		,m_notifyScriptHandler(0)
		,m_sprtieModel(NULL)
		,m_bEnableOpacity(false)
	{
		this->addChild(cocos2d::CCNode::create(), 0, kNodeHead);
	}

	RenderSprite::~RenderSprite()
	{
		if (m_pParent)
		{
			m_pParent->removeChild(this, false);
			m_pParent = NULL;
		}
		CC_SAFE_RELEASE_NULL(m_sprtieModel);
	}

	void RenderSprite::visit()
	{
		if (!m_bVisible)
			return;
		if(m_sprtieModel /*&& m_bInverseDirty*/)
		{
			int x = Map2Cell( this->getPositionX() );
			int y = Map2Cell( this->getPositionY() );
			float alpha = 1;
			if(SFMapService::instance()->getShareMap()->getRenderScene()->getMap()->IsMaskPoint(x,y))
			{
				alpha = 0.6;
			}else{
				alpha = 1;
			}
			unsigned char changeOpacity =  alpha*m_targetAlpha;
			if (m_fSpriteAlpha != changeOpacity)
			{
				m_fSpriteAlpha = changeOpacity;
				m_sprtieModel->setOpacity(m_fSpriteAlpha);
			}
			//m_bInverseDirty =  false;
		}
		CCNode::visit();
	}
	bool RenderSprite::load( unsigned int modelId, unsigned int defaultId)
	{
		if(!m_sprtieModel)
		{
			m_sprtieModel = cocos2d::extension::SFRenderSprite::createRenderSprite(modelId, defaultId);
			if(!m_sprtieModel) return false;
			m_sprtieModel->retain();
			m_sprtieModel->setScaleY(-1.0f);
			//m_sprtieModel->playByDir(0);
		}
		else if(!m_sprtieModel->init(modelId))
		{
			m_sprtieModel->removeFromParent();
			m_sprtieModel->setParent(NULL);
			CC_SAFE_RELEASE_NULL(m_sprtieModel);
			return false;
		}
		if(!m_sprtieModel->getParent())
			this->addChild(m_sprtieModel);
		return true;
	}

	void RenderSprite::onLeaveMap()
	{

	}

	bool RenderSprite::changeActionCallback(int actionId, float speed, bool loop, int nScriptHandler)
	{
		if(m_sprtieModel && (m_sprtieModel->getActionId() != actionId || loop == false))
		{
			signed char id = SFModelResConfig::sharedSFModelResConfig()->getActionConfig(actionId);
			m_sprtieModel->changeModelAction(id,actionId, speed, m_fSpriteAlpha);
			m_sprtieModel->setScriptHandler(nScriptHandler);
			m_sprtieModel->playByDir(m_nAngle);
			return true;
		}
		//CCLOG("RenderSprite::changeActionCallback action : %d , modelid: %d", actionId, m_sprtieModel->getModelId());
		return false;
	}

	bool RenderSprite::changeAction( int actionId, float speed, bool loop )
	{
		return this->changeActionCallback(actionId, speed, loop, 0);
	}

	void RenderSprite::setAnimSpeed( float speed )
	{
		if(m_sprtieModel)
			m_sprtieModel->setAnimationSpeed(speed);
	}

	void RenderSprite::changePartWithDefault( int partType, int showId, bool gender,unsigned int defaultId /*= 0*/, short offsetX, short offsetY )
	{
		if (m_sprtieModel)
		{
			//m_sprtieModel->changeModelPart(partType,showId,gender,true,defaultId);
			m_sprtieModel->changeModelPart(partType,showId,cocos2d::CCPointMake(offsetX,offsetY), true, gender,defaultId);
			m_sprtieModel->playByDir(m_nAngle);
		}
	}

	void RenderSprite::setVisiblePart( int partType, bool visible )
	{
		if (m_sprtieModel)
		{
			if(visible == false)
				m_sprtieModel->changeModelPart(partType,0,true ,visible);
		}
	}

	void RenderSprite::clear()
	{
		if (m_sprtieModel)
		{
			m_sprtieModel->reset();
		}
	}

	void RenderSprite::setAngle( int dir )
	{
		m_nAngle = dir;
		if(m_sprtieModel)
			m_sprtieModel->playByDir(dir);
	}


	int RenderSprite::getAngle()
	{
		return m_nAngle;
	}

	cocos2d::CCRect RenderSprite::getBoundRect()
	{
		//默认取底边中心为偏移
		float x, y;
		this->getPosition(&x, &y);
		if(m_sprtieModel)
		{
			cocos2d::CCSize size = m_sprtieModel->getContentSize();
			float width = size.width / 2;
			float height = size.width / 4;
			return cocos2d::CCRect(x - width, y - size.height, 
				size.width, size.height);
		}

		return cocos2d::CCRect(x - m_obContentSize.width / 2, 
								y - m_obContentSize.height, 
								m_obContentSize.width, m_obContentSize.height);
	}

	void RenderSprite::setAlpha( unsigned char alpha )
	{
		if(m_sprtieModel && m_fSpriteAlpha != alpha && m_bEnableOpacity)
		{
			m_targetAlpha = alpha;
			m_fSpriteAlpha = alpha;
			m_sprtieModel->setOpacity(m_fSpriteAlpha);
			CCNodeRGBA::setOpacity(m_fSpriteAlpha);
		}
		
	}

	int RenderSprite::getModelId()
	{
		return m_sprtieModel ? m_sprtieModel->getModelId() : 0;
	}

	cocos2d::CCNode* RenderSprite::getHeadNode()
	{
		return this->getChildByTag(kNodeHead);
	}

	void RenderSprite::reset()
	{
		m_nAngle = 0;
		m_fSpriteAlpha=255;
	}

	float RenderSprite::getCenterPositionY()
	{
		float y = MAX( (this->m_obPosition.y - 55.f), 0.f);
		return y;
	}

	void RenderSprite::setAnimNotifyScriptHandler( int nScriptHandler )
	{
		m_notifyScriptHandler = nScriptHandler;
	}

	int RenderSprite::getZOrder()
	{
		return (this->m_nZOrder!=0) ? this->m_nZOrder : int(this->m_obPosition.y);
	}

	const CCSize& RenderSprite::getContentSize()
	{
		if(!m_sprtieModel) return CCSizeMake(0, 0);
		return m_sprtieModel->getContentSize();
	}

	void RenderSprite::changeModel( int modelId )
	{
		if(m_sprtieModel)
		{
			signed char id = SFModelResConfig::sharedSFModelResConfig()->getActionConfig(m_sprtieModel->getActionId());
			m_sprtieModel->changeModel(modelId);
			m_sprtieModel->changeModelAction(id, m_sprtieModel->getActionId(), m_sprtieModel->getAnimationSpeed(), m_fSpriteAlpha);
		}
	}

	void RenderSprite::changeModelWithDefault(int modelId, int defaultId,bool gender)
	{
		if(m_sprtieModel)
		{
			signed char id = SFModelResConfig::sharedSFModelResConfig()->getActionConfig(m_sprtieModel->getActionId());
			m_sprtieModel->changeModel(modelId,gender,defaultId);
			m_sprtieModel->changeModelAction(id, m_sprtieModel->getActionId(), m_sprtieModel->getAnimationSpeed(), m_fSpriteAlpha);
		}
	}

	void RenderSprite::setEnableOpacity( bool enable )
	{
		m_bEnableOpacity = enable;
	}

	void RenderSprite::setRenderSpriteVisible( bool visible )
	{
		if(m_sprtieModel)
		{
			m_sprtieModel->setVisible(visible);
		}
	}

	bool RenderSprite::getRenderSpriteVisible()
	{
		return (m_sprtieModel == NULL)?false:m_sprtieModel->isVisible();
	}

	void RenderSprite::setShaderProgram( CCGLProgram *pShaderProgram )
	{
		if(m_sprtieModel)
		{
			CC_SAFE_RELEASE(m_pShaderProgram);
			m_pShaderProgram = pShaderProgram;
			CC_SAFE_RETAIN(m_pShaderProgram);
			m_sprtieModel->setShaderProgram(pShaderProgram);
		}
		else
		{
			CCLOG("RenderSprite::setShaderProgram");
		}
	}
	int RenderSprite::getActionId()
	{
		return m_sprtieModel == NULL ?  kCCNodeTagInvalid :  m_sprtieModel->getActionId();
	}

	unsigned char RenderSprite::getAlpha()
	{
		return m_fSpriteAlpha;
	}

	void RenderSprite::setOpacity( GLubyte opacity )
	{
		if (m_sprtieModel)
		{
			//m_fSpriteAlpha = opacity;
			m_targetAlpha = opacity;
			m_sprtieModel->setOpacity(opacity);
		}
		CCNodeRGBA::setOpacity(opacity);
	}

	void RenderSprite::setRenderOffset(CCPoint offset )
	{
		if (m_sprtieModel)
		{
			m_sprtieModel->setPosition(offset);
		}
	}

	void RenderSprite::setPartScale( int partType, float scale )
	{
	}

	float RenderSprite::getPartScale( int partType )
	{
		return 1.0f;
	}

}