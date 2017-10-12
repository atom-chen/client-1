#include "TestWidget.h"

typedef enum 
{
	eTestLabel = 500,
	eTestSprite,
	eTestScale9Sprite,
	eTestGridBox,
	eTestTabelView,
	eTestTabView,
	eTestButton,
	eTestRichText,
	eTestScrollView,
	eTestEditBox,
} TestType;

TestWidget::TestWidget()
{
	CCSpriteFrameCache *frameCache = CCSpriteFrameCache::sharedSpriteFrameCache();
	frameCache->addSpriteFramesWithFile("ui/ui_common_bg.plist");
	frameCache->addSpriteFramesWithFile("ui/ui_common_form.plist");
	initTimer();
	//setTouchEnabled(true);
	m_operateType = Operate_Add_Z;
}

TestWidget* TestWidget::create()
{
	TestWidget *node = new TestWidget();

	if (node && node->init())
	{
		node->initUI();
		node->autorelease();
		return node;
	}
	CC_SAFE_DELETE(node);
	return NULL;
}

TestWidget::~TestWidget()
{
	SFSharedFontManager::destroySFSharedFontManager();				//test
	m_dialogArray->release();
}

//每次跑到这个函数，CCObject的数量都会+1。但退出程序后，vld没有检测出内存泄漏问题
//原因可能是每次create一个label，SFSharedFontManager都会增加一个CCObject类型的对象。
void TestWidget::testLabel()
{
	removeChildByTag(eTestLabel, true);

	SFLabel *label = SFLabel::create("Test Label Memory", "Arial", 30, ccc3(200, 200, 30));
	label->setTag(eTestLabel);
	addChild(label);
	VisibleRect::relativePosition(label, this, LAYOUT_CENTER);
	printObjCount();
}

void  TestWidget::initUI()
{
	m_dialogArray = CCArray::createWithCapacity(16);
	m_dialogArray->retain();

	CCScale9Sprite *normal1 = CCScale9Sprite::createWithSpriteFrameName("common_bg3.png");
	normal1->setPreferredSize(CCSizeMake(250, 80));
	CCControlButton *changeOperateTypeBtn  = CCControlButton::create(normal1);
	changeOperateTypeBtn->setPreferredSize(CCSizeMake(250, 80));
	changeOperateTypeBtn->setScaleDef(VisibleRect::SFGetScale());

	m_operateLabel = SFLabel::create("切换操作(当前= z+1)", "Arial", 23, ccc3(200, 200, 30));
	changeOperateTypeBtn->addChild(m_operateLabel);
	VisibleRect::relativePosition(m_operateLabel, changeOperateTypeBtn, LAYOUT_CENTER);

	CCControlButton *resetBtn = createBtn(CCSizeMake(250, 80), "重置");

	changeOperateTypeBtn->addTargetWithActionForControlEvents(this, cccontrol_selector(TestWidget::onChangedOperateType), CCControlEventTouchUpInside);
	resetBtn->addTargetWithActionForControlEvents(this, cccontrol_selector(TestWidget::onReset), CCControlEventTouchUpInside);

	addChild(changeOperateTypeBtn, 10000000);
	addChild(resetBtn, 10000000);

	VisibleRect::relativePosition(changeOperateTypeBtn, this, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(200, -50));
	VisibleRect::relativePosition(resetBtn, changeOperateTypeBtn,   LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(50, 0));

	CCSize size = CCSizeMake(CCDirector::sharedDirector()->getVisibleSize().width / 2 - 50, CCDirector::sharedDirector()->getVisibleSize().height / 2 - 50);
	char buf[10];
	for (int i = 0; g_layouts[i] != 0; ++i)
	{
		sprintf(buf, "%d", i);
		CCControlButton *btn;
		if (i < 4)
			btn = createBtn(size, buf);
		else if (i < 8)
			btn = createBtn(size, buf, "common_formBg1.png");
		else
			btn = createBtn(size, buf);
		m_dialogArray->addObject(btn);
		btn->setTag(i);
		btn->addTargetWithActionForControlEvents(this, cccontrol_selector(TestWidget::onOperateDialog), CCControlEventTouchUpInside);
	}

	onReset(NULL, 0);
}

void TestWidget::onOperateDialog(CCObject* pSender, CCControlEvent event)
{
	CCNode *node = (CCNode*)pSender;
	int tag = node->getTag();
	switch (m_operateType)
	{
	case Operate_Add_Z:
		node->setZOrder(node->getZOrder() + 1);
		break;
	case Operate_Sub_Z:
		node->setZOrder(node->getZOrder() - 1);
		break;
	case Operate_Show_Hide:
		if (node->isVisible())
			node->setVisible(false);
		else
			node->setVisible(true);
		break;
	case Operate_Remove_Add:
		removeChild(node);
		addChild(node);
		VisibleRect::relativePosition(node, this, g_layouts[tag]);
		break;
	default:
		break;
	}
}

void  TestWidget::onChangedOperateType(CCObject* pSender, CCControlEvent event)
{
	CCNode *node = (CCNode*)pSender;
	switch (m_operateType)
	{
	case Operate_Add_Z:
		m_operateType = Operate_Show_Hide;
		m_operateLabel->setString("切换操作(当前= 显示/隐藏)");
		break;
	case Operate_Show_Hide:
		m_operateType = Operate_Sub_Z;
		m_operateLabel->setString("切换操作(当前= z-1)");
		break;
	case Operate_Sub_Z:
		m_operateType = Operate_Remove_Add;
		m_operateLabel->setString("切换操作(当前= Reload)");
		break;
	case Operate_Remove_Add:
		m_operateType = Operate_Add_Z;
		m_operateLabel->setString("切换操作(当前= z+1)");
		break;
	default:
		m_operateType = Operate_Add_Z;
		m_operateLabel->setString("切换操作(当前= z+1)");
		break;
	}
}

void TestWidget::onReset(CCObject* pSender, CCControlEvent event)
{
	m_operateType = Operate_Add_Z;
	m_operateLabel->setString("切换操作(当前= z+1)");
	CCObject* pObj = NULL;

	int i = 0;
	CCARRAY_FOREACH(m_dialogArray, pObj)
	{
		CCNode *node = (CCNode*)pObj;
		if (NULL == node->getParent())
		{
			addChild(node);
			VisibleRect::relativePosition(node, this, g_layouts[i]);
		}
		node->setVisible(true);
		++i;
	}
}

CCControlButton* TestWidget::createBtn(const CCSize &size, const char *name, const char *file)
{
	if (NULL == file)
		file = "common_bg3.png";

	CCScale9Sprite *normal1 = CCScale9Sprite::createWithSpriteFrameName(file);
	normal1->setPreferredSize(size);
	CCControlButton* btn1 = CCControlButton::create(normal1);
	btn1->setPreferredSize(size);
	btn1->setScaleDef(VisibleRect::SFGetScale());

	SFLabel *label = SFLabel::create(name, "Arial", 23, ccc3(200, 200, 30));
	btn1->addChild(label);
	VisibleRect::relativePosition(label, btn1, LAYOUT_CENTER);
	return btn1;
}

void TestWidget::addBtn(const CCSize &size, int group, int i, CCArray *array)
{
	CCScale9Sprite *normal1 = CCScale9Sprite::createWithSpriteFrameName("common_bg3.png");
	normal1->setPreferredSize(size);
	CCControlButton* btn1 = CCControlButton::create(normal1);
	btn1->setPreferredSize(size);
	btn1->setScaleDef(VisibleRect::SFGetScale());

	char buf[10];
	sprintf(buf, "%d.%d", group, i);
	SFLabel *label = SFLabel::create(buf, "Arial", 14, ccc3(200, 200, 30));
	btn1->addChild(label);
	VisibleRect::relativePosition(label, btn1, LAYOUT_RIGHT_INSIDE + LAYOUT_CENTER_Y);

	array->addObject(btn1);
}

//("common_formBg1.png")

void TestWidget::testSprite()
{
	removeChildByTag(eTestSprite, true);

	CCSpriteFrame* frame = CCSpriteFrameCache::sharedSpriteFrameCache()->spriteFrameByName("common_bg3.png");

	CCSprite* sprite = CCSprite::create();
	sprite->setDisplayFrame(frame);
	sprite->setTag(eTestSprite);
	addChild(sprite);
	VisibleRect::relativePosition(sprite, this, LAYOUT_CENTER);
	printObjCount();
}

void TestWidget::testEditBox()
{
	removeChildByTag(eTestEditBox, true);

	CCScale9Sprite *normal1= CCScale9Sprite::createWithSpriteFrameName("common_bg3.png");
	CCEditBox *box = CCEditBox::create(CCSizeMake(300, 50), normal1);
	box->setTag(eTestEditBox);
	addChild(box);
	VisibleRect::relativePosition(box, this, LAYOUT_CENTER);
	printObjCount();
}

void TestWidget::testScale9Sprite()
{
}

void TestWidget::testGridBox()
{
}

void TestWidget::testTabelView()
{
	removeChildByTag(eTestTabView);

	CCLayer* testView = createTableViewTest();
	testView->setTag(eTestTabView);
	addChild(testView);
	VisibleRect::relativePosition(testView, this, LAYOUT_CENTER);
	printObjCount();
}

void TestWidget::testTabView()
{
	removeChildByTag(eTestTabView);

	CCArray* btnArray = CCArray::create();

	CCScale9Sprite *normal1= CCScale9Sprite::createWithSpriteFrameName("common_bg3.png");
	CCScale9Sprite *selected1 = CCScale9Sprite::createWithSpriteFrameName("common_bg3.png");

	SFButton* btn1= SFButton::create(normal1, selected1);

	CCScale9Sprite *normal2 = CCScale9Sprite::createWithSpriteFrameName("common_bg3.png");
	CCScale9Sprite *selected2 = CCScale9Sprite::createWithSpriteFrameName("common_bg3.png");

	SFButton* btn2 = SFButton::create(normal2, selected2);

	btnArray->addObject(btn1);
	btnArray->addObject(btn2);

	SFTabView *tabView = SFTabView::create(btnArray, 10);
	tabView->setTag(eTestTabView);
	addChild(tabView);
	VisibleRect::relativePosition(tabView, this, LAYOUT_CENTER);
	printObjCount();
}

//没问题
void TestWidget::testButton()
{
	removeChildByTag(eTestButton);

	CCScale9Sprite *normal = CCScale9Sprite::createWithSpriteFrameName("common_bg3.png");
	normal->setPreferredSize(CCSizeMake(100, 50));
	CCScale9Sprite *selected = CCScale9Sprite::createWithSpriteFrameName("common_bg3.png");
	normal->setPreferredSize(CCSizeMake(100, 50));

	CCControlButton* btn = CCControlButton::create(normal);
	btn->setPreferredSize(CCSizeMake(100, 50));
	btn->setTag(eTestButton);
	btn->setScaleDef(VisibleRect::SFGetScale());
	addChild(btn);
	VisibleRect::relativePosition(btn, this, LAYOUT_CENTER);
	//printObjCount();
}

void TestWidget::testRichText()
{
	removeChildByTag(eTestRichText);

	SFRichLabel* rich = SFRichLabel::create();
	rich->appendFormatText("aaaaaa<font color='#ff00ff'><a data='zhan'>aaaaaa</a></font><img image='common_bg3.png'>dfff</img>aaaa");
	rich->appendFormatText("aaaaaa<font color='#ff00ff'><a data='zhan'>aaaaaa</a></font><img image='common_bg3.png'>dfff</img>aaaa");
	rich->appendFormatText("aaaaaa<font color='#ff00ff'><a data='zhan'>aaaaaa</a></font><img image='common_bg3.png'>dfff</img>aaaa");
	rich->clearAll();


	rich->appendFormatText("aaaaaa<font color='#ff00ff'><a data='zhan'>aaaaaa</a></font><img image='common_bg3.png'>dfff</img>aaaa");
	rich->appendFormatText("aaaaaa<font color='#ff00ff'><a data='zhan'>aaaaaa</a></font><img image='common_bg3.png'>dfff</img>aaaa");
	rich->appendFormatText("aaaaaa<font color='#ff00ff'><a data='zhan'>aaaaaa</a></font><img image='common_bg3.png'>dfff</img>aaaa");
	rich->setTag(eTestRichText);
	addChild(rich);
	VisibleRect::relativePosition(rich, this, LAYOUT_CENTER);
	printObjCount();
}

//没问题
void TestWidget::testScrollView()
{
	SFScrollView *scroll = SFScrollView::create();
	scroll->setViewSize(CCSizeMake(300, 300));
}

void TestWidget::initTimer()
{
	CCScheduler *sch = CCDirector::sharedDirector()->getScheduler();
	sch->scheduleSelector(schedule_selector(TestWidget::onTimeout), this, 1.0f, false);
}

void TestWidget::onTimeout(float time)
{
	//testButton();
	//printObjCount();
	//testScrollView();
	//testSprite();
	//testButton();
	//testTabView();
	//testEditBox();
	//testRichText();
	//testTabelView();
	//printObjCount();

	CCDirector::sharedDirector()->checkTouchHandlers();
}

bool  TestWidget::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
	CCLog("TestWidget::ccTouchBegan");
	return true;
}

void TestWidget::ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent)
{
	CCLog("TestWidget::ccTouchMoved");
}

void TestWidget::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
	CCLog("TestWidget::ccTouchEnded");
}