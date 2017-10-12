#ifndef __SFTABVIEWCONTROL_H__
#define __SFTABVIEWCONTROL_H__

//用于创建不规则的Tab

#include "SFBaseControl.h"
#include <list>

class SFTabViewControl;

class SFTabViewControlDelegate{
public:
	virtual void didSelControl(SFTabViewControl *tabCtl, int index)=0;
};



class SFTabViewControl: public CCObject{
public:
	~SFTabViewControl(){
		CC_SAFE_RELEASE_NULL(m_controls);
		m_delegate = NULL;
	}

public:
	static SFTabViewControl* createWithControls(CCControlButton *ctlButton, ...);
	static SFTabViewControl* createWithArray(CCArray *controls);

	bool initWithControls(CCControlButton* ctlButton, va_list args);
	bool initWithArray(CCArray* pArrayOfctl);

	void initControlTaget();	

public:
	
	virtual bool insertControl(CCControlButton *ctlButton);
	virtual bool removeControl(CCControlButton *ctlButton);

	virtual CCControlButton* getSelControl();
	virtual bool setSelControl(CCControlButton *ctlButton);

	virtual int getSelIndex();
	virtual bool setSelIndex(unsigned int index);

	virtual void hiddenTabItem(bool hide);

public:
	virtual void setDelegate(SFTabViewControlDelegate *delegate);
	
private:	

	void controlOnClick(CCObject *sender, SFControlEvent event);
	void allUnSel();

	unsigned int m_selIndex;	
	CCArray		*m_controls;
	

	SFTabViewControlDelegate	*m_delegate;
};


#endif	//__SFTABVIEWCONTROL_H__

