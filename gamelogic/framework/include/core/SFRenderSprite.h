#ifndef _SF_RENDER_SPRITE_H_
#define _SF_RENDER_SPRITE_H_
// @brief: 
// @author: typ77
// @data: [11/12/2013 typ77]
//Even though I walk  through the valley of the shadow of death,  I will fear no evil,  for you are with me;  your rod and your staff,  they comfort me. 

#include "cocos-ext.h"
NS_CC_EXT_BEGIN

class SFRenderSprite : public CCNode
{
public:
	SFRenderSprite();
	virtual ~SFRenderSprite();
public:
	static SFRenderSprite*		createRenderSprite(unsigned int modelId, unsigned int defaultId = 0);
	//player��Ҷ���
	bool init(unsigned int modelId, unsigned int defaultId = 0);
public:
	//����ģ��
	void			reset();
	//����ģ�͵ı��
	void			changeModel(unsigned int modelId, bool gender = true, unsigned int defaultId = 0);
	//���ò����ı��
	//��ʱֻ�������ﾫ��
	void			changeModelPart(int partId, unsigned int modelId, bool gender, bool visible = true, unsigned int defaultId = 0);
	void			changeModelPart(int partId, unsigned int modelId, const CCPoint &position, bool visible = true, bool gender = false, unsigned int defaultId = 0);
	//���¶���(run��idle��attack��ect)
	//void			changeModelAction(int actionId);
	void			changeModelAction(signed char index, int actionId, float speed, float alpha);
	// �������ò��Ž����ص�
	bool			playByIndex(int index, CCObject *target = NULL, SEL_MovementEventCallFunc callFunc = NULL);
	bool			playByDir(int dir, CCObject *target = NULL, SEL_MovementEventCallFunc callFunc = NULL);
	//void			setMode(SpriteMode sm);
	// for lua--LiuRui
	bool			playByIndexLua(int index);
	bool			playByDirLua(int dir);
	//���ò�λƫ����
	//set lua callback
	void			setScriptHandler(int scriptHander);
	void			setAnimationSpeed(float speed);
	float			getAnimationSpeed();
	unsigned	int getModelId(){return m_modelId;}
	bool			getGender(){return m_gender;};
	// add by liu rui, ��RenderSprite֧��shader
	virtual void setShaderProgram(CCGLProgram *pShaderProgram);
	void			setPartScale(int partType, float scale);
public:
	virtual const CCSize& getContentSize();
	void setOpacity(unsigned char opacity);
	int getActionId();
	//for orginal api
public:
	static SFRenderSprite* createRenderSprite(unsigned int modelId, int actionId, const char* path);
	bool init(unsigned int modelId, int actionId, const char* path);
	
protected:
	SFRenderSprite*		getPartRenderNode(int part);
	void onAnimationEvent(cocos2d::extension::CCArmature *armature, cocos2d::extension::MovementEventType movementType, const char *movementID);
private:
	unsigned char				m_opacity;
	int							m_currentIndex;
	int							m_modelId;				// ģ��ID
	short						m_actionId;
	bool						m_bdirty;
	bool						m_gender;			// �Ƿ����Ա�����
	CCArmature*					m_currentArmature;
	CCNode*						m_currentRenderNode;
	std::string					m_jsonFile;
	int	m_nScriptHandler;		// LUA script handler
	// ģ�Ͳ�λ ��Ҫɾ��
	typedef std::map<int, SFRenderSprite*> PartRenderArmature;
	PartRenderArmature	m_partRenderMap;

	typedef std::map<int, CCArmature*> ActRenderArmature;
	ActRenderArmature	m_actRenderMap;

	CCPoint						m_wingOffset;//Ӳ���룬��ʱ����todo fixme
};
NS_CC_EXT_END
#endif