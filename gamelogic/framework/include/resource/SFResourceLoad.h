#ifndef _SF_RESOURCE_LOAD_H_
#define _SF_RESOURCE_LOAD_H_

#include "cocos2d.h"
#include "resource/SFLoadResourceModule.h"
//to do
//1.����һ�����ȼ���ʹ���ؿ����������ȼ�����
class SFResourceLoad : public cocos2d::CCObject
{
public:
	SFResourceLoad();
	~SFResourceLoad();

	static SFResourceLoad* sharedResourceLoadCache();
	static void purgeSharedResourceLoadCache();

	void addLoadingModule(ISFLoadResourceModule* module);
	//fix me .maybe del
	bool removeLoadingModule(ISFLoadResourceModule* module);
	void clearLoadingModule();

	//���ûص������������к�̨���ݺ�֪ͨ
	void setCompleteEventOnce(ISFLoadingCompleteEvent* event);
	void setCompleteEventOnceHandler(int handler);
	int  getCompleteEventOnceHandler();
private:
	void tick(float dt);
private:
	typedef std::vector<ISFLoadResourceModule*> ResModuleVecter;
	ResModuleVecter	m_loadModule;
	ISFLoadingCompleteEvent* m_eventCallback;
	float					m_deltaTime;
	float					m_curDeltaTime;
	float					m_frame;
	int						m_nScriptHandler;
	int						m_allLoadingCount;
	struct cocos2d::cc_timeval		*m_pLastUpdate;
};

#endif