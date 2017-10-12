#include "ui/renderer/SFBatchCommand.h"
#include "ui/control/SFControlDef.h"
USING_NS_CC;
void cocos2d::SFBatchCommand::addChild( CCNode * child )
{
//	if (NULL != dynamic_cast<SFButton*>(child)) {
//
//	}
//	else
//	{
		this->addChild(child, child->getZOrder(), child->getTag());
//	}
}

void cocos2d::SFBatchCommand::addChild( CCNode * child, int zOrder )
{
//	if (NULL != dynamic_cast<SFButton*>(child)) {
//	}
//	else
//	{
		this->addChild(child, zOrder, child->getTag());
//	}
}

void cocos2d::SFBatchCommand::addChild( CCNode* child, int zOrder, int tag )
{
//	if (NULL != dynamic_cast<SFButton*>(child)) {
//	}
//	else
//	{
		this->addChild(child, zOrder, tag);
//	}
}

