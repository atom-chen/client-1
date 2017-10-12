#include "cocos2d.h"
#include "ui/control/SFControlDef.h"
#include "ui/utils/VisibleRect.h"
#include "ui/control/SFRichLabel.h"
#include "TableViewTestScene.h"

USING_NS_CC;

typedef enum
{
	Operate_Add_Z = 1,
	Operate_Sub_Z = 2,
	Operate_Show_Hide = 3,
	Operate_Remove_Add = 4,
} OperateType;

static int g_layouts[10] = 
{
	(LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE),
	(LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE),
	(LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE),
	(LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE),
	(LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE),
	(LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE),
	(LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE),
	(LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE),
	(LAYOUT_CENTER),
	0
};

class TestWidget : public CCLayer
{
public:
	static TestWidget* create();
	TestWidget();
	~TestWidget();
	
	void testLabel();	//�ڴ�û����
	void testSprite();//�ڴ�û����
	void testScale9Sprite();//�ڴ�û����
	void testGridBox();//�ڴ�û����
	void testTabelView();
	void testTabView();	//�ڴ�û����
	void testButton();//�ڴ�û����
	void testRichText(); //�ڴ�û����
	void testScrollView();//�ڴ�û����
	void testEditBox();//�ڴ�û����
	

private:
	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);

	void addBtn(const CCSize &size, int group, int i, CCArray *array);
	void initTimer();
	void onTimeout(float time);
	void initUI();
	CCControlButton* createBtn(const CCSize &size, const char *name, const char* file = NULL);

	CCArray* m_dialogArray;
	OperateType m_operateType;
	SFLabel *m_operateLabel;
	
	void onOperateDialog(CCObject* pSender, CCControlEvent event); 
	void onChangedOperateType(CCObject* pSender, CCControlEvent event); 
	void onReset(CCObject* pSender, CCControlEvent event);
};
