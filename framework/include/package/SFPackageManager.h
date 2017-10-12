/********************************************************************
	created:	2013/10/22
	created:	22:10:2013   16:36
	filename: 	E:\Sophia\client\trunk\framework\include\package\SFPackageManager.h
	file path:	E:\Sophia\client\trunk\framework\include\package
	file base:	SFPackageManager
	file ext:	h
	author:		Liu Rui
	
	purpose:	��Դ������������ȡ
*********************************************************************/

#ifndef SFPackageManager_h__
#define SFPackageManager_h__
#include "../../zpack/zpack.h"
#include "platform/CCFileLoader.h"
#include <vector>
#include <string>
#include <list>
#include "cocos2d.h"
// namespace cocos2d{
// class SFPackage;
// }

class SFPackgePatchDelegate :public cocos2d::CCObject
{
public:
	virtual void onPatchProgress(int current, int total){};
	virtual void onPatchError(int errorCode){};
	virtual void onSuccess(){};
	virtual void stop(){};
	//virtual void on
};

enum PatchEvent
{
	eOnPatchProgress,
	eOnError,
	eOnSuccess,
};

class SFPackgePatchLuaDelegate: public SFPackgePatchDelegate
{
public:
	SFPackgePatchLuaDelegate();
	virtual ~SFPackgePatchLuaDelegate();
	virtual void onPatchProgress(int current, int total);
	virtual void onPatchError(int errorCode);
	virtual void onSuccess();
	virtual void setLuaHandler(int nHandler){m_handler = nHandler;}
	virtual void sendPatchDelegate(float dt);
	virtual void stop();
private:
	int m_handler;
	int m_current;
	int m_total;
	int m_error;
};

struct SFPackageVersion
{
	int mainVersion;
	int subVersion;
	char format;	// ��Դ��ʽ
};
// todo support multi zpks read/write
class SFPackageManager : public cocos2d::CCFileLoader
{
public:
	virtual ~SFPackageManager();
	static SFPackageManager* Instance();

	// ������Դ����ȡ�ļ��С�ֻ��Ҫ�������·��
	void setResourcePath(const char* path);
	// ���ؼ��صİ����ڰ汾��Ϣ
	SFPackageVersion addPackageName(const char* name);
	// �ͷ��Ѿ����ص�IO���
	void releaseLoadPackage();

	// �ϰ�api
	// �ϰ��ص� for lua
	//void setPackageCallback(int handle);
	void setPackageDelegateProtocl(SFPackgePatchDelegate* delegate);
	// �ϰ�����
	void mergePackage(const char* patchPackage);
	// ��ʼ�ϰ�
	void startMerge();
	// �ϰ���ɡ�֪ͨ���Զ�д�ļ�
	void completePackage();
	//��ȡһ���ַ���Ϊ���ݵ��ļ�
	std::string getFileStringContent(const char* filePath);
public:
	virtual bool canLoad(){return true;};
	// �ļ��Ƿ����, filePath�������·��
	virtual bool isFileExist(const std::string& strFilePath);
	// ��ȡ�ļ�����, filePath�������·��
	virtual long getFileLength(const char* filePath);
	//��ȡ�ļ�����
	virtual unsigned char* getFileData(const char* filePath, long* length);
private:
	SFPackageManager();
private:
	std::string m_resourcePath;
	std::list<std::string> m_packageNameList;
	typedef std::list<zp::IPackage*> PackageList;
	PackageList m_packageList;
	bool		m_mergeing;
};

#endif // SFPackageManager_h__
