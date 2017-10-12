#include "TableViewTestScene.h"
#include "CustomTableViewCell.h"

USING_NS_CC;
USING_NS_CC_EXT;

CCLayer* createTableViewTest()
{
	TableViewTestLayer *pLayer = TableViewTestLayer::create();
	return pLayer;
}

// on "init" you need to initialize your instance
bool TableViewTestLayer::init()
{
    if ( !CCLayer::init() )
    {
        return false;
    }

	CCSize winSize = CCDirector::sharedDirector()->getWinSize();

    SFTableView* tableView = SFTableView::create(this, CCSizeMake(250, 60));
    tableView->setDirection(kCCScrollViewDirectionHorizontal);
    tableView->setPosition(ccp(20,winSize.height/2-30));
    tableView->setDelegate(this);
    this->addChild(tableView);
    tableView->reloadData();

	tableView = SFTableView::create(this, CCSizeMake(60, 250));
	tableView->setDirection(kCCScrollViewDirectionVertical);
	tableView->setPosition(ccp(winSize.width-150,winSize.height/2-120));
	tableView->setDelegate(this);
	tableView->setVerticalFillOrder(kSFTableViewFillTopDown);
	this->addChild(tableView);
	tableView->reloadData();

    return true;
}

void TableViewTestLayer::toExtensionsMainLayer(cocos2d::CCObject *sender)
{
}

void TableViewTestLayer::tableCellTouched(SFTableView* table, SFTableViewCell* cell)
{
    CCLOG("cell touched at index: %i", cell->getIdx());
}

CCSize TableViewTestLayer::tableCellSizeForIndex(SFTableView *table, unsigned int idx)
{
    if (idx == 2) {
        return CCSizeMake(100, 100);
    }
    return CCSizeMake(60, 60);
}

SFTableViewCell* TableViewTestLayer::tableCellAtIndex(SFTableView *table, unsigned int idx)
{
    CCString *string = CCString::createWithFormat("%d", idx);
    SFTableViewCell *cell = table->dequeueCell();
    if (!cell) {
        cell = new CustomTableViewCell();
        cell->autorelease();
        CCSprite *sprite = CCSprite::createWithSpriteFrame(CCSpriteFrameCache::sharedSpriteFrameCache()->spriteFrameByName("common_bg3.png"));
        sprite->setAnchorPoint(CCPointZero);
        sprite->setPosition(ccp(0, 0));
        cell->addChild(sprite);

        CCLabelTTF *label = CCLabelTTF::create(string->getCString(), "Helvetica", 20.0);
        label->setPosition(CCPointZero);
		label->setAnchorPoint(CCPointZero);
        label->setTag(123);
        cell->addChild(label);
    }
    else
    {
        CCLabelTTF *label = (CCLabelTTF*)cell->getChildByTag(123);
        label->setString(string->getCString());
    }


    return cell;
}

unsigned int TableViewTestLayer::numberOfCellsInTableView(SFTableView *table)
{
    return 20;
}
