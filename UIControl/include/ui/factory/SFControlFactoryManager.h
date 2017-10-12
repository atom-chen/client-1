/********************************************************************
	created:	2013/09/24
	created:	24:9:2013   10:51
	filename: 	E:\Sophia\client\trunk\framework\sofia\ui\SFControlFactoryManager.h
	file path:	E:\Sophia\client\trunk\framework\sofia\ui
	file base:	SFControlFactoryManager
	file ext:	h
	author:		Liu Rui
	
	purpose:	ControlFactory的管理类
*********************************************************************/

#ifndef SFControlFactoryManager_h__
#define SFControlFactoryManager_h__

#include "cocoa/CCObject.h"
#include <string>
#include <map>

USING_NS_CC;

class SFControlFactory;

class SFControlFactoryManager : public CCObject
{
public:
	SFControlFactoryManager();
	~SFControlFactoryManager();

	void LoadAllFacotry();

	void AddFactory(const char* controlType, SFControlFactory* factory);
	void RemoveFactory(const char* controlType);

	SFControlFactory* getFactory(const char* controlType);

	static SFControlFactoryManager* shareCCControlFactoryMgr();

protected:
	typedef std::map<std::string, SFControlFactory*> FactoryMap;
	FactoryMap m_factoryMap;

};

#define getControlFactory(controlType) SFControlFactoryManager::shareCCControlFactoryMgr()->getFactory(controlType)

#endif // SFControlFactoryManager_h__
