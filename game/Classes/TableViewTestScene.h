#ifndef __TABLEVIEWTESTSCENE_H__
#define __TABLEVIEWTESTSCENE_H__

#include "cocos2d.h"
#include "cocos-ext.h"
#include "ui/control/SFControlDef.h"

CCLayer* createTableViewTest();

class TableViewTestLayer : public cocos2d::CCLayer, public SFTableViewDataSource, public SFTableViewDelegate
{
public:
    virtual bool init();  
   
	void toExtensionsMainLayer(cocos2d::CCObject *sender);

    CREATE_FUNC(TableViewTestLayer);
    
    virtual void scrollViewDidScroll(CCScrollView* view) {};
    virtual void scrollViewDidZoom(CCScrollView* view) {}
    virtual void tableCellTouched(SFTableView* table, SFTableViewCell* cell);
    virtual cocos2d::CCSize tableCellSizeForIndex(SFTableView *table, unsigned int idx);
    virtual SFTableViewCell* tableCellAtIndex(SFTableView *table, unsigned int idx);
    virtual unsigned int numberOfCellsInTableView(SFTableView *table);
};

#endif // __TABLEVIEWTESTSCENE_H__
