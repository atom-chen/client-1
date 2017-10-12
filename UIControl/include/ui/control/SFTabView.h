#ifndef __SFTABVIEW_H__
#define __SFTABVIEW_H__



#include "SFBaseControl.h"
#include <list>

enum TabViewMode{
	tab_horizontal,
	tab_vertical
};

class SFTabView;

class SFTabViewDelegate{
public:
	virtual void didSelControl(SFTabView *tabView, int index)=0;
};


class SFTabView: public SFBaseControl{
public:
	virtual ~SFTabView(){
		CCObject *obj = NULL;
		CCARRAY_FOREACH(m_controls, obj){
			CCNode *btn = (CCNode*)obj;
			btn->stopAllActions();
		}
		m_controls->removeAllObjects();
		CC_SAFE_RELEASE_NULL(m_controls);
		m_delegate = NULL;
	}

public:
	static SFTabView* create(CCArray *controls, int margin, TabViewMode mode = tab_horizontal);
	bool init(CCArray* controls, int margin, TabViewMode mode = tab_horizontal);

	void initControlTaget();	
	const CCSize & getSize();
public:

	virtual bool insertControl(CCControlButton *ctlButton);
	virtual bool removeControl(CCControlButton *ctlButton);

	virtual CCControlButton* getSelControl();
	virtual bool setSelControl(CCControlButton *ctlButton);

	virtual int getSelIndex();
	virtual bool setSelIndex(unsigned int index);
	virtual void setAllUnSel();
	virtual void setDefaultSel(bool defaultSel);

public:
	
	virtual void setTabMode(TabViewMode tabMode);
	virtual void setDelegate(SFTabViewDelegate *delegate);
private:
	virtual void onEnter();
private:	
	void _selectTag(CCControlButton* btn, int index);
	void controlOnClick(CCObject *sender, SFControlEvent event);
	void allUnSel();

	int m_selIndex;	
	CCArray		*m_controls;


	SFTabViewDelegate	*m_delegate;
	TabViewMode			m_tabMode;
	int					m_margin;
	bool				m_isfirst;
	bool				m_defaultSel;
	CCSize m_tabSize;
};


#endif	//__SFTABVIEW_H__

