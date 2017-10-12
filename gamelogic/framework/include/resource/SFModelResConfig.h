#ifndef _SF_MODEL_RES_CONFIG_H_
#define _SF_MODEL_RES_CONFIG_H_
// @brief: 
// @author: typ77
// @data: [11/13/2013 typ77]
//Even though I walk  through the valley of the shadow of death,  I will fear no evil,  for you are with me;  your rod and your staff,  they comfort me. 
#include "cocos2d.h"
#include "cocos-ext.h"
struct ModelRes
{
	ModelRes():modelIndex(0){};
	char			modelIndex;
};
struct ModelTypeConfig
{
	std::string		modelName;
	std::string		modelPath;
};

class SFModelResConfig : public cocos2d::CCObject
{
public:
	SFModelResConfig();
	virtual ~SFModelResConfig();
public:
	static SFModelResConfig* sharedSFModelResConfig();
	static void purgeSharedSFModelResConfig();
public:
	signed char getActionConfig(unsigned int modelId);
	void	removeActionConfig(unsigned int modelId);
	void	setActionConfig(unsigned int modelId, char modelIndex);
	//����ģ�ͣ����Ҽ�����Ӧ��ģ�ͣ��첽��
	void	setModelType(char type, const char* path, const char* name);
	ModelTypeConfig getModelType(char type);
	void	removeModelType(char type);

	void	setModelOffset(signed char actionId, short offsetX, short offsetY);
	const cocos2d::CCPoint& getModelOffset(signed char actionId, signed char index);

	void	setModelId(int id);
	bool	checkModelId(int id);

	// ��ʱ�����ﴦ��
	// sfRenderSprite��Json��¼�����������崦��
	void	addSFRecord(std::string& jsonFile);
	// �Ƴ��������Ǽ�ʱ�Ƴ����첽�Ƴ������Ҹ���ʹ��Ƶ�������塣����ǻ������ʱ���Ƴ�
	void	removeSFRecord(std::string& jsonFile);
	// ���ü�¼�����Ҷ����м�¼�Ƴ�
	void	resetSFRecord();
	// �Ծ����plist�����⴦��
	int		addSFRenderSprite(int modelId, const char* plist);
	void	removeSFRenderSprite(int modelId);
	void	clearAllSFRenderSprite();
private:
	void tick(float dt);
	typedef std::map<int, char> ActionConfig;
	typedef std::map<char, ModelTypeConfig> ModelType;
	typedef std::map<int, char> ModelId;
	typedef std::vector<cocos2d::CCPoint> ActionOffset;
	typedef std::map<signed char, ActionOffset*> ModelOffset;
	ModelId			m_modelId;
	ActionConfig	m_actionMap;
	ModelType		m_modelType;
	ModelOffset		m_modelOffset;



	struct SFRecord
	{
		unsigned int	usedCount;			//ʹ�ù���
		short			reference;			//������
		bool			beCache;			//�Ƿ񱻻���
		cocos2d::extension::CCArmature*		point;				//��������
	};

	bool		removeSFObj(std::string& str);

	typedef std::map<std::string, SFRecord*> SFRSRecord;
	typedef std::list<std::string>			SFRSRemove;

	SFRSRemove		m_sfrRemoveObj;
	SFRSRecord		m_sfrUsedObj;
	SFRSRecord		m_sfrTempObj;
	int				m_lessUsed; //��Ӧ��json
	//std::string		m_lessName;
};
//NS_CC_END
#endif