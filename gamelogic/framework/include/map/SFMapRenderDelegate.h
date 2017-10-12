#ifndef _SF_MAP_RENDER_DELEGATE_H_
#define _SF_MAP_RENDER_DELEGATE_H_

#include "cocos2d.h"
//��ʱ����Ⱦ�й��ࡣ������Ҫȥ����������Ⱦ�Ż��й� todo fixme at 3.0
//�򻯴���cocos2d-x ��2.x�汾����Ⱦ�Ż�����3.0��ʱ����Ҫȥ����������
NS_CC_BEGIN
//����û�жԴ������ܺô�����������չ�Ե����⡣��Ϊ�ҳ���Ҫɾ�ġ�
//�����ͬ��Դ�Ļ���ʹ��batch�ύ
class SFMapBackgroud : public CCNode
{
public:
	virtual void addChild(CCNode * child);
	virtual void addChild(CCNode * child, int zOrder);
	virtual void addChild(CCNode* child, int zOrder, int tag);
	virtual void removeChild(CCNode* child);
	virtual void removeAllChildrenWithCleanup(bool cleanup);

	void addChild(CCNode* child, bool batchEnable, int zOrder, int tag);
protected:
	std::map<unsigned int, CCSpriteBatchNode* >	m_batchNode;
private:
};

// ʹ��buff��Ⱦ�����������buff��Ⱦ����ֱ��ʹ��ccnode�����ﲻ����װ
class SFMapBuff : public CCNode
{
public:
	virtual void addChild(CCNode * child);
	virtual void addChild(CCNode * child, int zOrder);
	virtual void addChild(CCNode* child, int zOrder, int tag);
	virtual void removeChild(CCNode* child);
	virtual void removeAllChildrenWithCleanup(bool cleanup);
protected:
private:
};
NS_CC_END
#endif