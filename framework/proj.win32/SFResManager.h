/********************************************************************
	created:	2013/10/21
	created:	21:10:2013   20:43
	filename: 	E:\Sophia\client\trunk\framework\proj.win32\SFResManager.h
	file path:	E:\Sophia\client\trunk\framework\proj.win32
	file base:	SFResManager
	file ext:	h
	author:		Liu Rui
	
	purpose:	��Դ������
*********************************************************************/

#ifndef SFResManager_h__
#define SFResManager_h__

#include <vector>
#include <string>

#define StringVector std::vector<std::string>

class SFResManager
{
public:
	static SFResManager* Instance();
	~SFResManager();

	// �Ƿ��ҵ�����Դ
	bool IsFindResource();

	// ������Դ�汾�ţ���������ڷ���0
	int getVersion();

	// ����ָ���ļ��İ汾��
	int getVersion(const char* fileName);

	// ��Դ���Ƿ����ĳ���ļ�
	bool FindResFile(const char* fileName);

	// ����������
	bool addPath(StringVector& resFileVector);

private:
	SFResManager();
};


#endif // SFResManager_h__
