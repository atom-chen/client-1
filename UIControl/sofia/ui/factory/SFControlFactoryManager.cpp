#include "ui/factory/SFControlFactoryManager.h"
#include "ui/factory/SFControlFactoryExtension.h"
#include "ui/ControlDef.h"

static SFControlFactoryManager* s_SharedFactoryMgr = NULL;

SFControlFactoryManager::SFControlFactoryManager()
{

}

SFControlFactoryManager::~SFControlFactoryManager()
{
	FactoryMap::iterator itr = m_factoryMap.begin();
	while (itr != m_factoryMap.end())
	{
		delete itr->second;
		itr->second = NULL;
		itr++;
	}

	m_factoryMap.clear();

	s_SharedFactoryMgr = NULL;
}

void SFControlFactoryManager::LoadAllFacotry()
{
	AddFactory(Control_Label, new SFLabelFactory(Control_Label));
	AddFactory(Control_Sprite, new SFSpriteFactory(Control_Sprite));
	AddFactory(Control_TabView, new SFTabViewFactory(Control_TabView));
	AddFactory(Control_TableView, new SFTableViewFactory(Control_TabView));
	AddFactory(Control_ScrollView, new SFScrollViewFactory(Control_ScrollView));
	AddFactory(Control_Scale9Sprite, new SFScale9SpriteFactory(Control_Scale9Sprite));
	AddFactory(Control_RichLabel, new SFRichLabelFactory(Control_RichLabel));
	AddFactory(Control_EditBox, new SFEditBoxFactory(Control_EditBox));
	AddFactory(Control_CheckButton, new SFCheckButtonFactory(Control_CheckButton));
}

void SFControlFactoryManager::AddFactory( const char* controlType, SFControlFactory* factory )
{
	FactoryMap::iterator itr = m_factoryMap.find(controlType);
	if (itr != m_factoryMap.end())
	{
		return;
	}

	m_factoryMap.insert(std::pair<std::string, SFControlFactory*>(controlType, factory));
}

void SFControlFactoryManager::RemoveFactory( const char* controlType )
{
	FactoryMap::iterator itr = m_factoryMap.find(controlType);
	if (itr == m_factoryMap.end())
	{
		return;
	}

	delete itr->second;
	itr->second = NULL;
	m_factoryMap.erase(itr);
}

SFControlFactory* SFControlFactoryManager::getFactory( const char* controlType )
{
	FactoryMap::iterator itr = m_factoryMap.find(controlType);
	if (itr == m_factoryMap.end())
	{
		return NULL;
	}

	return itr->second;
}

SFControlFactoryManager* SFControlFactoryManager::shareCCControlFactoryMgr()
{
	if (s_SharedFactoryMgr == NULL)
	{
		s_SharedFactoryMgr = new SFControlFactoryManager();
		s_SharedFactoryMgr->LoadAllFacotry();
	}

	return s_SharedFactoryMgr;
}
