#ifndef _SF_LOAD_RESOURCE_MODULE_H_
#define _SF_LOAD_RESOURCE_MODULE_H_
#include "cocos2d.h"
#include "map/RenderInterface.h"
class ISFLoadingCompleteEvent
{
public:	 
	ISFLoadingCompleteEvent() {}
	virtual ~ISFLoadingCompleteEvent() {}
	virtual void onLoadCompleted() = 0;
};


class ISFLoadResourceModule : public cocos2d::CCObject
{
public:
	ISFLoadResourceModule():m_bDel(false),m_doneCallback(NULL){}
	virtual ~ISFLoadResourceModule(){}
	// ���ض���������
	virtual int loadingObjectCount() = 0;
	// ʣ��δ���ض�������
	virtual int loadingRemainderObject() = 0;
	// ���ؽӿ� ����ʣ�������
	virtual int loadObject() = 0;
	// ���ü�����ɺ��Զ�ɾ��
	void setAutoDel(bool del){m_bDel = del;}
	bool getAutoDel(){return m_bDel;}
	// ���ü������֪ͨ
	void setLoadingEventCallback(ISFLoadingCompleteEvent* callback){m_doneCallback = callback;}

private:
	bool m_bDel;
protected:
	ISFLoadingCompleteEvent* m_doneCallback;
};

class SFLoadTextureModule : public ISFLoadResourceModule
{
public:
	SFLoadTextureModule();
	virtual ~SFLoadTextureModule();
public:
	// ���ض���������
	virtual int loadingObjectCount();
	// ʣ��δ���ض�������
	virtual int loadingRemainderObject();
	// ���ؽӿ� ����ʣ�������
	virtual int loadObject();
public:
	void addLoadObject(int texId, cocos2d::CCSprite* obj);
	void removeObject(cocos2d::CCSprite* obj);
	void clearObject();
protected:
	std::list<int> m_removveImageId;
	typedef std::map<int, cocos2d::CCTexture2D*> IMAGESET;
	typedef std::map<int, std::list<cocos2d::CCSprite*> > LOADINGSET;
	IMAGESET	m_imageSet;
	LOADINGSET	m_loadingSet;
};

//ֻ֧�ֵ��������ж�ء��������ݲ�֧��
//todo cache 40 model
class SFLoadSpriteModule : public ISFLoadResourceModule
{
public:
	// ���ض���������
	virtual int loadingObjectCount();
	// ʣ��δ���ض�������
	virtual int loadingRemainderObject();
	// ���ؽӿ� ����ʣ�������
	virtual int loadObject();
public:
	int addLoadObject(int modelId, const char* plist);
	void removeLoadObject(int modelId);
	void clearUnused();
protected:
	struct UsedModel
	{
		short					useCount;
		std::string				plist;
	};
	typedef	std::map<int, UsedModel*>	UsedModelMap;
	UsedModelMap		m_usedModel;
	UsedModelMap		m_cacheModel;		//cache
	//total used model if over 40(about 28m)
};

class SFLoadConfigModule : public ISFLoadResourceModule
{
public:
	// ���ض���������
	virtual int loadingObjectCount();
	// ʣ��δ���ض�������
	virtual int loadingRemainderObject();
	// ���ؽӿ� ����ʣ�������
	virtual int loadObject();
public:
	SFLoadConfigModule();
	virtual ~SFLoadConfigModule();
public:
	void	addConfig(const char* filename, cocos2d::CCObject *target, cocos2d::SEL_CallFuncND callFunc);
private:
	struct ConfigData
	{
		std::string		filemane;
		cocos2d::CCObject*		target;
		cocos2d::SEL_CallFuncND	callFunc;
	};
	std::list<ConfigData> m_loadConfig;
};

class SFRenderSpriteModule : public ISFLoadResourceModule
{
public:
	// ���ض���������
	virtual int loadingObjectCount();
	// ʣ��δ���ض�������
	virtual int loadingRemainderObject();
	// ���ؽӿ� ����ʣ�������
	virtual int loadObject();
public:
	SFRenderSpriteModule();
	virtual ~SFRenderSpriteModule();

	void addLoadObject(cocos2d::CCNode* renderSpr, int luaHandler);
	bool removeLoadObject(cocos2d::CCNode* renderSpr);
	void clearAllObject();
private:
	std::map<cocos2d::CCNode*, int>		m_loadRenderSprite;
};

#endif