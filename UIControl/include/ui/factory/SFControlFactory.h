/********************************************************************
	created:	2013/09/24
	created:	24:9:2013   10:49
	filename: 	E:\Sophia\client\trunk\framework\sofia\ui\SFControlFactory.h
	file path:	E:\Sophia\client\trunk\framework\sofia\ui
	file base:	SFControlFactory
	file ext:	h
	author:		Liu Rui
	
	purpose:	控件工厂的基类
*********************************************************************/

#ifndef SFControlFactory_h__
#define SFControlFactory_h__

#include "base_nodes/CCNode.h"
USING_NS_CC;

class SFControlFactory
{
public:
	SFControlFactory(const char *type):m_controlType(type)
	{

	}

	virtual CCNode* CreateControl() = 0;

	virtual void DestroyControl(CCNode *control)
	{
		CCNode *parentNode = control->getParent();
		parentNode->removeChild(control);
	}

	const char * GetTypeName() const
	{ 
		return m_controlType.c_str();
	}

protected:
	std::string  m_controlType;
};

#endif // SFControlFactory_h__
