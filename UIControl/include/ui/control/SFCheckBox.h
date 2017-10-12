#ifndef __SFCHECKBOX_H__
#define __SFCHECKBOX_H__

#include "cocos2d.h"
#include "cocos-ext.h"
USING_NS_CC;
USING_NS_CC_EXT;

#include "SFBaseControl.h"

class SFCheckBox : public SFBaseControl
{
public:
	SFCheckBox();
	virtual ~SFCheckBox();
	static SFCheckBox* create() 
	{ 
		SFCheckBox *pRet = new SFCheckBox(); 
		if (pRet && pRet->init()) 
		{ 
			pRet->autorelease(); 
			return pRet; 
		} 
		else 
		{ 
			delete pRet; 
			pRet = NULL; 
			return NULL; 
		} 
	};
	static SFCheckBox* create(const char* normal, const char* select, CCObject* target = NULL, SEL_CallFuncO action = NULL);

	void initControl(const char* normal, const char* select, CCObject* target, SEL_CallFuncO action);
	void initControl(const char* normal, const char* select,int nHandler);
	void setSelect(bool bSelect);
	bool getSelect();

	void setEnable(bool bEnable);
	bool getEnable();

	void setCallback(CCObject* target, SEL_CallFuncO action);

	// 不描边的文字
	void setString(const char* pszText, const char* font, int size, ccColor3B color, int strokeSize, ccColor3B strokeColor);

	// 描边的文字
	void setString(const char* pszText, const char* font, int size, ccColor3B color);

protected:
	void resize();

	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);
private:
	CCObject* m_target;
	SEL_CallFuncO m_action;

	CCSprite* m_btn;
	CCSprite* m_icon;

	bool m_bSelect;
	bool m_bEnable;
	int m_handler;
	CCNode* m_label;
	int m_storkeSize;
};

#endif //__SFCHECKBOX_H__