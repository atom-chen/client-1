#ifndef __SFUIFACTORY_H__
#define __SFUIFACTORY_H__


#include "ui/control/SFBaseControl.h"
#include "ui/control/SFTabView.h"
#include "ui/utils/VisibleRect.h"
class SFScale9Sprite;
class SFGridBox;
class SFTableView;
class SFTableViewDataSource;
class SFLabel;
class SFScrollView;
class SFJoyRocker;
class SFLabelStroke;

class SFRichBox;
class SFCheckBox;
class SFPageControl;

class SFUIFactory{

public:

	SFUIFactory(){};
	~SFUIFactory(){}

	static SFUIFactory* sharedUIFactory();
	virtual bool init();
	CCMenuItem* createMenuItem(const char* key);

	SFScale9Sprite* createScale9Sprite(const char* key, CCSize size, CCRect capInsets=CCRectZero);
	SFGridBox* createGridBox(unsigned column, CCSize gridSize, int count, int margin=1);
	SFTableView* createTableView(SFTableViewDataSource* dataSource, CCSize size);


	SFLabel* createLabel(const char* str, const char* fontName, int fontSize = VisibleRect::autoFontSize(24), ccColor3B color = ccBLACK);

	CCRenderTexture *createTexture(CCSize size, CCNode *node, ...);
	CCRenderTexture *createTexture(CCSize size, CCArray *nodes);

	CCProgressTimer *createProgress(const char* key, CCSize size, CCProgressTimerType type);

	SFScrollView* createScrollView();
	//joy是摇杆控制点 joyBg是摇杆背景 radius是摇杆半径 
	SFJoyRocker* createJoyRocker(CCSprite *joy, CCSprite *joyBg, float radius=0, bool isFollow=false);
	SFLabelStroke* createLabelStroke(const char* string, const char* fontName="Arial", float fontSize=24, ccColor3B fontColor=ccc3(255,255,255), ccColor3B strokeColor=ccc3(0,0,0), int strokeSize=2);

	SFRichBox* createRichBox(CCSize dimensions=CCSizeZero);

	SFCheckBox* createCheckBox(const char* normal, const char* select);

	SFPageControl* createPageControl(const char* pBackgroundFrameName, const char* pSelectFrameName);
};

#endif	//__SFUIFACTORY_H__

