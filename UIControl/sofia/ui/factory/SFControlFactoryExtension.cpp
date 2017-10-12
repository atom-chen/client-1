#include "ui/factory/SFControlFactoryExtension.h"
#include "sprite_nodes/CCSprite.h"
#include "GUI/CCControlExtension/CCScale9Sprite.h"
#include "ui/control/SFTableView.h"
#include "ui/control/SFCheckBox.h"
#include "ui/control/SFTabView.h"
#include "ui/control/SFScrollView.h"
#include "ui/control/SFLabel.h"
#include "ui/control/SFRichBox.h"
#include "GUI/CCEditBox/CCEditBox.h"

USING_NS_CC;
USING_NS_CC_EXT;

CCNode* SFSpriteFactory::CreateControl()
{
	return CCSprite::create();
}

CCNode* SFScale9SpriteFactory::CreateControl()
{
	return CCScale9Sprite::create();
}

CCNode* SFTableViewFactory::CreateControl()
{
	SFTableView* table = new SFTableView();
	table->autorelease();
	table->retain();
	return table;
}

CCNode* SFTabViewFactory::CreateControl()
{
	return SFTabView::create(NULL, 0);
}

CCNode* SFCheckButtonFactory::CreateControl()
{
	return SFCheckBox::create();
}

CCNode* SFLabelFactory::CreateControl()
{
	return SFLabel::create("","Arial");
}

CCNode* SFRichLabelFactory::CreateControl()
{
	return SFRichBox::create();
}

CCNode* SFEditBoxFactory::CreateControl()
{
	CCEditBox* editBox = new CCEditBox();
	editBox->autorelease();
	return editBox;
}

CCNode* SFScrollViewFactory::CreateControl()
{
	return SFScrollView::create();
}


