#ifndef _SF_BATCH_COMMAND_H_
#define _SF_BATCH_COMMAND_H_
#include "cocos2d.h"
NS_CC_BEGIN
	// �����е���ȾԪ�ؼ��뵽��Ⱦ�б�
	// ��command���д�����Ҫ��Ⱦ��batchnode
	// �����node�����κ���Ⱦ��Ϊ��ȫ��ί�и�����
	class CCSpriteBatchNode;
class SFBatchCommand : public CCLayer
{
public:
	SFBatchCommand();
	virtual ~SFBatchCommand();
public:
	//��Բ�������ؼ��Ż��������Ż������ڵĿؼ���Ĭ�Ϸ�ʽ��Ⱦ
	virtual void addChild(CCNode * child);
	virtual void addChild(CCNode * child, int zOrder);
	virtual void addChild(CCNode* child, int zOrder, int tag);
protected:
	//CCSpriteBatchNode*		m_
	typedef std::map<CCTexture2D*, int>		TextureInfo;
	TextureInfo					m_textureInfo;
private:
};
NS_CC_END
#endif