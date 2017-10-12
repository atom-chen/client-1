#include "core/SFRenderSprite.h"
#include "resource/SFModelResConfig.h"
#include "include/utils/SFStringUtil.h"
#include "resource/EntityData.h"
USING_NS_CC_EXT;



cocos2d::extension::SFRenderSprite::SFRenderSprite()
	: m_callback(NULL)
	, m_currentIndex(-1)
	, m_modelId(0)
	, m_currentArmature(NULL)
	, m_bdirty(false)
	, m_gender(true)
	, m_nScriptHandler(0)
	, m_actionId(kCCNodeTagInvalid)
	, m_opacity(255)
{
	m_currentRenderNode = CCNode::create();
	m_currentRenderNode->retain();
	this->addChild(m_currentRenderNode, 1);
}

cocos2d::extension::SFRenderSprite::~SFRenderSprite()
{
	this->removeAllChildren();
	CC_SAFE_RELEASE_NULL(m_currentRenderNode);

	m_partRenderMap.clear();
	for (ActRenderArmature::iterator iter = m_actRenderMap.begin(); iter != m_actRenderMap.end(); ++iter)
	{
		//CC_SAFE_RELEASE_NULL(iter->second->arature);
		int idd = m_modelId*100 + iter->first;
		SFModelResConfig::sharedSFModelResConfig()->removeSFRenderSprite(idd);
		CC_SAFE_RELEASE_NULL(iter->second);
	}
	m_actRenderMap.clear();
 	if(m_jsonFile.length())
 	{
 		SFModelResConfig::sharedSFModelResConfig()->removeSFRecord(m_jsonFile);
	}
}
//part id : 坐骑，武器等等。这个直接和层次关联
void cocos2d::extension::SFRenderSprite::changeModel( unsigned int modelId, bool gender, unsigned int defaultId)
{
	int mid = 0;
	if (SFModelResConfig::sharedSFModelResConfig()->checkModelId(modelId))
	{
		if(m_modelId != modelId)
			mid = modelId;
	}
	else if(defaultId != 0 && SFModelResConfig::sharedSFModelResConfig()->checkModelId(defaultId))
	{
		if(m_modelId != defaultId)
			mid = defaultId;
	}
	if(mid != 0 && m_modelId != mid)
	{
		//对model下的所有action更新。卸载替换
		for (ActRenderArmature::iterator iter = m_actRenderMap.begin(); iter != m_actRenderMap.end(); ++iter)
		{
			signed char id = SFModelResConfig::sharedSFModelResConfig()->getActionConfig(iter->first);
			if(id == -1)
				return;
			ModelTypeConfig config = SFModelResConfig::sharedSFModelResConfig()->getModelType(id);
			int idd = m_modelId*100 + iter->first;
			SFModelResConfig::sharedSFModelResConfig()->removeSFRenderSprite(idd);
			std::string plistPath = SFStringUtil::formatString("%s%d_%d.plist", config.modelPath.c_str(), mid, iter->first);
			idd = mid*100 + iter->first;
			SFModelResConfig::sharedSFModelResConfig()->addSFRenderSprite(idd, plistPath.c_str());
		}
		m_modelId = mid;
		m_gender = gender;
		m_bdirty = true;
	}
}

bool cocos2d::extension::SFRenderSprite::playByDir( int dir, CCObject *target /*= NULL*/, SEL_MovementEventCallFunc callFunc /*= NULL*/)
{
	if (!m_currentArmature)
		return false;
	if (dir == m_currentIndex && m_bdirty == false)
	{
		return false;
	}
	int i = dir;
	if(i > 4)
	{
		i = 8 - i; 
	}

	float scale = 1.0f;
	if(dir > 4)
		scale = -1.0f;
		
	m_currentIndex = dir;
	for (PartRenderArmature::iterator iter = m_partRenderMap.begin(); iter != m_partRenderMap.end(); ++iter)
	{
		SFRenderSprite* pNode = (SFRenderSprite*) iter->second;
		pNode->playByIndex(i, NULL, NULL);

		switch (iter->first)
		{
		case eEntityPart_Wing:
			if ((dir > 2 && dir < 6))
				pNode->setZOrder(eEntityPart_Mount);
			else
				pNode->setZOrder(eEntityPart_Wing);
			break;
		case eEntityPart_Weapon:
			if (dir == 4)
				pNode->setZOrder(eEntityPart_Mount);
			else
				pNode->setZOrder(eEntityPart_Weapon);
			break;
		case eEntityPart_Mount:
			if (dir == 4)
				pNode->setZOrder(eEntityPart_Weapon);
			else
				pNode->setZOrder(eEntityPart_Mount);
			break;
		default:
			break;
		}
	}
	this->setScaleX(scale);
	return this->playByIndex(i, target, callFunc);
}

bool cocos2d::extension::SFRenderSprite::playByDirLua( int dir )
{
	return playByDir(dir);
}

bool cocos2d::extension::SFRenderSprite::playByIndex( int index ,CCObject *target, SEL_MovementEventCallFunc callFunc)
{
	if(!m_currentArmature)
		return false;
	CCArmatureAnimation * animation = m_currentArmature->getAnimation();
	animation->playByIndex(index);
	if(m_nScriptHandler)
	{
		animation->setMovementEventCallFunc(this, movementEvent_selector(SFRenderSprite::onAnimationEvent));
	}
	else
		animation->setMovementEventCallFunc(target, callFunc);
	return true;
}

//有一个初始化模型。加载的时候用这个初始化模型
SFRenderSprite* cocos2d::extension::SFRenderSprite::createRenderSprite( unsigned int modelId, unsigned int defaultId )
{
	SFRenderSprite* pRet = new SFRenderSprite();
	if (pRet && pRet->init(modelId, defaultId))
	{
		pRet->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(pRet);
	}
	return pRet;
}

SFRenderSprite* cocos2d::extension::SFRenderSprite::createRenderSprite( unsigned int modelId, int actionId, const char* path )
{
	SFRenderSprite* pRet = new SFRenderSprite();
	if (pRet && pRet->init(modelId, actionId, path))
	{
		pRet->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(pRet);
	}
	return pRet;
}
// id 动作模板ID
void cocos2d::extension::SFRenderSprite::changeModelAction(signed char index,  int actionId, float speed, float alpha )
{
	if(m_modelId == 0) return;
// 	signed char id = SFModelResConfig::sharedSFModelResConfig()->getActionConfig(actionId);
	if(index == -1)
		return;
	ModelTypeConfig config = SFModelResConfig::sharedSFModelResConfig()->getModelType(index);
	if(eEntityPart_Wing == this->getTag())
	{
		if(actionId == eEntityAction_RideIdle || actionId == eEntityAction_RideRun)
		{
			this->setPosition(m_wingOffset);
		}
		else
		{
			this->setPosition(ccp(0,0));
		}
	}
	//actArmatureData* data = NULL;
	if(actionId != m_actionId || m_currentArmature == NULL)
	{
		//查找动作是否有缓冲
		ActRenderArmature::iterator iter = m_actRenderMap.find(actionId);
		if(m_currentArmature)
		{
			m_currentArmature->removeFromParentAndCleanup(true);
			m_currentArmature->setParent(NULL);
		}
		
		//如果有的话，用旧的 
		if (iter != m_actRenderMap.end())
		{
			//data = iter->second;
			m_currentArmature = iter->second;
			CCInteger* integer = (CCInteger*)m_currentArmature->getUserObject();
			//如果modelid不一样，需要重新加载
			m_bdirty = integer->getValue() != m_modelId ? true : false;
			integer->m_nValue = m_modelId;
		}
		else
		{
			//如果没有的话创建
			m_currentArmature = CCArmature::create(config.modelName.c_str());
			CCInteger* integer = CCInteger::create(m_modelId);
			m_currentArmature->setUserObject(integer);
			m_currentArmature->retain();
			//data = new actArmatureData;
			//data->plist = SFStringUtil::formatString("%s%d_%d.plist",config.modelPath.c_str(), m_modelId, actionId);
			m_actRenderMap.insert(std::pair<int, CCArmature*>(actionId, m_currentArmature));

			int idd = m_modelId*100 + actionId;

			if(eEntityPart_Wing == this->getTag())
			{
				if(actionId == eEntityAction_RideIdle)
				{
					actionId = eEntityAction_Idle;
				}
				else if(actionId == eEntityAction_RideRun)
				{
					actionId = eEntityAction_Run;
				}
			}
			std::string plist = SFStringUtil::formatString("%s%d_%d.plist",config.modelPath.c_str(), m_modelId, actionId);
			//data->arature = m_currentArmature;

			SFModelResConfig::sharedSFModelResConfig()->addSFRenderSprite(idd, plist.c_str());
			m_bdirty = true;
		}
		m_currentRenderNode->addChild(m_currentArmature, 0, actionId);
	}
	m_currentArmature->getAnimation()->setSpeedScale(speed);
	m_currentArmature->setOpacity(alpha);
	//是否需要重新加载。新创建的和改变模型的都要重新加载一次

	if (m_bdirty)
	{
		m_bdirty = false;
		//std::string plistPath = SFStringUtil::formatString("%s%d_%d.plist",config.modelPath.c_str(), m_modelId, actionId);
		//CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile(plistPath.c_str());
		//骨骼精灵加载
		CCBone* bonePart = m_currentArmature->getBone("body");
		unsigned int count = bonePart->getBoneData()->displayDataList.count();
		for (int i = 0; i < count; i++)
		{
			std::string rec;
			{
				rec = SFStringUtil::formatString("%d_%d_%.5d.png",m_modelId,actionId,i);
			}

			CCSkin *skin = CCSkin::createWithSpriteFrameName(rec.c_str());
			if(skin)
			{
				bonePart->addDisplay(skin, i);
				if (!m_gender)
				{
					CCPoint osPt = SFModelResConfig::sharedSFModelResConfig()->getModelOffset(actionId,i);
					skin->setPosition(osPt);
				}
			}
			else
			{
				return;
			}
		}
	}
	for (PartRenderArmature::iterator iter = m_partRenderMap.begin(); iter != m_partRenderMap.end(); ++iter)
	{
		SFRenderSprite* pNode = (SFRenderSprite*) iter->second;
		pNode->changeModelAction(index, actionId,speed,alpha);
	}
	m_actionId = actionId;
	m_currentIndex = -1;
	if (m_pShaderProgram)
	{
		m_currentArmature->setShaderProgram(m_pShaderProgram);
	}
}

//更改模型局部的模型ID
void cocos2d::extension::SFRenderSprite::changeModelPart( int partId, unsigned int modelId, bool gender, bool visible /*= true*/, unsigned int defaultId)
{
	//不显示
	this->changeModelPart(partId, modelId, cocos2d::CCPointMake(0,0),visible, gender, defaultId);
}

void cocos2d::extension::SFRenderSprite::changeModelPart( int partId, unsigned int modelId, const CCPoint &position, bool visible /*= true*/, bool gender /*= false*/, unsigned int defaultId )
{
	SFRenderSprite* partSprite = this->getPartRenderNode(partId);
	//不显示
	if (visible == false)
	{		
		if (partSprite)
			partSprite->setVisible(false);
	}
	else
	{
		if (!partSprite)
		{
			partSprite = cocos2d::extension::SFRenderSprite::createRenderSprite(modelId, defaultId);
			if(!partSprite)
			{
				CCLOG("SFRenderSprite::changeModelPart : the modelId is not in model csv:%d %d",modelId,defaultId);
				return;
			}
			partSprite->m_gender = gender;
			m_partRenderMap.insert(std::pair<int, SFRenderSprite*>(partId, partSprite));
			this->addChild(partSprite, partId, partId);
		}
		else
		{
 			partSprite->changeModel(modelId, gender, defaultId);
			partSprite->setVisible(true);
		}
		//int actionId = m_actionId;
		if(partId == eEntityPart_Wing)
		{
			partSprite->m_wingOffset = position;
		}

	 	signed char id = SFModelResConfig::sharedSFModelResConfig()->getActionConfig(m_actionId);
	 	if(id != -1)
			partSprite->changeModelAction(id, m_actionId, getAnimationSpeed(), m_opacity);
		if(partId == eEntityPart_Wing)
			m_bdirty = true;
	}
}

// to fix me
// fix the part+body is contentSize
const CCSize& cocos2d::extension::SFRenderSprite::getContentSize()
{
	if(!m_currentArmature) return CCSizeMake(0, 0);
	return m_currentArmature->getBone("body")->getDisplayManager()->getDecorativeDisplayByIndex(0)->getDisplay()->getContentSize();
}

SFRenderSprite* cocos2d::extension::SFRenderSprite::getPartRenderNode( int part )
{
	PartRenderArmature::iterator iter = m_partRenderMap.find(part);
	if (iter != m_partRenderMap.end())
	{
		return m_partRenderMap[part];
	}
	return NULL;
}

void cocos2d::extension::SFRenderSprite::setAnimationSpeed( float speed )
{
	if(m_currentArmature)
	{
		m_currentArmature->getAnimation()->setSpeedScale(speed);
		for (PartRenderArmature::iterator iter = m_partRenderMap.begin(); iter != m_partRenderMap.end(); ++iter)
		{
			SFRenderSprite* pNode = (SFRenderSprite*)iter->second;
			pNode->setAnimationSpeed(speed);
		}
	}
}

void cocos2d::extension::SFRenderSprite::setScriptHandler( int scriptHander )
{
	m_nScriptHandler = scriptHander;
}

void cocos2d::extension::SFRenderSprite::onAnimationEvent( cocos2d::extension::CCArmature *armature, cocos2d::extension::MovementEventType movementType, const char *movementID )
{
	if (m_nScriptHandler!=0)
	{
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		
		pEngine->executeSpriteActionEvent(m_nScriptHandler, m_actionId, movementType);
	}
}

bool cocos2d::extension::SFRenderSprite::playByIndexLua( int index )
{
	return playByIndex(index);
}

void cocos2d::extension::SFRenderSprite::setOpacity( unsigned char opacity )
{
	//保证在换动作的时候也不会导致失效
	for (ActRenderArmature::iterator iter = m_actRenderMap.begin(); iter != m_actRenderMap.end(); ++iter)
	{
		iter->second->setOpacity(opacity);
	}
	for (PartRenderArmature::iterator iter = m_partRenderMap.begin(); iter != m_partRenderMap.end(); ++iter)
	{
		SFRenderSprite* pNode = (SFRenderSprite*) iter->second;
		pNode->setOpacity(opacity);
	}
	if (m_pShaderProgram)
	{
		GLint originalAlpha = m_pShaderProgram->getUniformLocationForName("u_originalAlpha");
		m_pShaderProgram->use();
		if (opacity == 0.6*255)
		{
			m_pShaderProgram->setUniformLocationWith1f(originalAlpha,opacity/255.0);
		}else{
			m_pShaderProgram->setUniformLocationWith1f(originalAlpha,1.0);
		}
	}
	m_opacity = opacity;
}

void cocos2d::extension::SFRenderSprite::setShaderProgram( CCGLProgram *pShaderProgram )
{
	CC_SAFE_RELEASE(m_pShaderProgram);
	m_pShaderProgram = pShaderProgram;
	CC_SAFE_RETAIN(m_pShaderProgram);

	for (PartRenderArmature::iterator iter = m_partRenderMap.begin(); iter != m_partRenderMap.end(); ++iter)
	{
		SFRenderSprite* pNode = (SFRenderSprite*) iter->second;
		pNode->setShaderProgram(pShaderProgram);
	}
	if(m_currentArmature)
		m_currentArmature->setShaderProgram(pShaderProgram);
}

int cocos2d::extension::SFRenderSprite::getActionId()
{
	return m_actionId;
}

float cocos2d::extension::SFRenderSprite::getAnimationSpeed()
{
	return m_currentArmature ? m_currentArmature->getAnimation()->getSpeedScale() : 0.0f;
}

void cocos2d::extension::SFRenderSprite::reset()
{
	m_modelId = 0;
	m_gender = true;
	m_bdirty = true;
	m_callback = NULL;
	m_currentIndex = kCCNodeTagInvalid;
	m_actionId = kCCNodeTagInvalid;
	m_opacity = 255;
}

bool cocos2d::extension::SFRenderSprite::init(unsigned int modelId, unsigned int defaultId)
{
	if (SFModelResConfig::sharedSFModelResConfig()->checkModelId(modelId))
	{
		m_modelId = modelId;
		m_bdirty = true;
		return true;
	}
	else if(defaultId != 0 && SFModelResConfig::sharedSFModelResConfig()->checkModelId(defaultId))
	{
		m_modelId = defaultId;
		m_bdirty = true;
		return true;
	}
	m_modelId = 0;
	return false;
}

bool cocos2d::extension::SFRenderSprite::init( unsigned int modelId, int actionId, const char* path )
{
	//模型ID
	m_modelId = modelId;
	//加载模型文件
	m_jsonFile = SFStringUtil::formatString("%s%d_%d.ExportJson",path, m_modelId, actionId);
	//CCLOG("SFRenderSprite::init %s",m_jsonFile.c_str());
	SFModelResConfig::sharedSFModelResConfig()->addSFRecord(m_jsonFile);
	CCArmatureDataManager::sharedArmatureDataManager()->addArmatureFileInfo(m_jsonFile.c_str());
	std::string namePath;
	namePath = SFStringUtil::formatString("%d_%d", m_modelId, actionId);
	//创建动画
	CCArmature* armature = CCArmature::create(namePath.c_str());
	//添加到渲染节点
	m_currentRenderNode->addChild(armature);
	armature->setTag(actionId);
	//当前的渲染模型
	m_currentArmature = armature;
	return true;
}