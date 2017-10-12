/********************************************************************
	created:	2013/09/24
	created:	24:9:2013   11:04
	filename: 	E:\Sophia\client\trunk\framework\sofia\ui\SFControlFactoryExtension.h
	file path:	E:\Sophia\client\trunk\framework\sofia\ui
	file base:	SFControlFactoryExtension
	file ext:	h
	author:		Liu Rui
	
	purpose:	¾ßÌåµÄcontrol factory
*********************************************************************/

#ifndef SFControlFactoryExtension_h__
#define SFControlFactoryExtension_h__

#include "SFControlFactory.h"

class SFSpriteFactory : public SFControlFactory
{
public:
	SFSpriteFactory(const char* controlType):SFControlFactory(controlType){}
	virtual CCNode* CreateControl();
};

class SFScale9SpriteFactory : public SFControlFactory
{
public:
	SFScale9SpriteFactory(const char* controlType):SFControlFactory(controlType){}
	virtual CCNode* CreateControl();
};

class SFTableViewFactory : public SFControlFactory
{
public:
	SFTableViewFactory(const char* controlType):SFControlFactory(controlType){}
	virtual CCNode* CreateControl();
};

class SFTabViewFactory : public SFControlFactory
{
public:
	SFTabViewFactory(const char* controlType):SFControlFactory(controlType){}
	virtual CCNode* CreateControl();
};

class SFCheckButtonFactory : public SFControlFactory
{
public:
	SFCheckButtonFactory(const char* controlType):SFControlFactory(controlType){}
	virtual CCNode* CreateControl();
};

class SFLabelFactory : public SFControlFactory
{
public:
	SFLabelFactory(const char* controlType):SFControlFactory(controlType){}
	virtual CCNode* CreateControl();
};

class SFRichLabelFactory : public SFControlFactory
{
public:
	SFRichLabelFactory(const char* controlType):SFControlFactory(controlType){}
	virtual CCNode* CreateControl();
};

class SFEditBoxFactory : public SFControlFactory
{
public:
	SFEditBoxFactory(const char* controlType):SFControlFactory(controlType){}
	virtual CCNode* CreateControl();
};

class SFScrollViewFactory : public SFControlFactory
{
public:
	SFScrollViewFactory(const char* controlType):SFControlFactory(controlType){}
	virtual CCNode* CreateControl();
};


#endif // SFControlFactoryExtension_h__
