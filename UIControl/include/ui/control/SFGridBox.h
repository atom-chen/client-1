#ifndef __SFGRIDBOX_H__
#define __SFGRIDBOX_H__

#include "SFBaseControl.h"
#include <list>

enum 
{
	kDidTouchBegin,
	kDidClickItem,
	kDidDoubleClickItem,
	kDidLongPressItem,
	kDidMoveItem,
	kDidTouchEndItem,
};

class SFGridBox;

class SFGridBoxDataSource{
public:
	virtual CCNode* cellFromGrid(SFGridBox *gridBox, int index, CCSize &gridSize)=0;
};

class SFGridBoxDelegate{
public:
	virtual void didClickItem(SFGridBox *gridBox, int index){};
	virtual void didDoubleClickItem(SFGridBox *gridBox, int index){};
	virtual void didLongPressItem(SFGridBox *gridBox, int index){};
	virtual void didMoveItem(SFGridBox *gridBox, int index, CCTouch *pTouch, CCEvent *pEvent){};
	virtual void didTouchEndItem(SFGridBox *gridBox, int index, CCTouch *pTouch, CCEvent *pEvent){};
};



class SFGridBox: public SFBaseControl{
public:
	virtual~SFGridBox(){
		m_delegate = NULL;
		m_dataSource = NULL;
	}
	CCSize getSize();
public:
	static SFGridBox* create(int columns, CCSize gridSize);
	bool init(int columns, CCSize boxSize);

public:

	virtual void addGrid(int count=1);
	virtual bool removeGrid(int count=1);

	virtual int getSelIndex();
	virtual void setSelIndex(unsigned int index);

	virtual void setAllMargin(int margin);
	virtual void setHeightMargin(int margin);
	virtual void setWidthMargin(int margin);

	virtual CCSize getGridSize();
	virtual unsigned getGridCount();
	virtual void reloadGridBox();
	virtual void reloadCellWithIndex(int index);

public:
	virtual void onEnter();
	virtual void onExit();

public:
	virtual void setDelegate(SFGridBoxDelegate *delegate);
	virtual void setDelegateHandler(int nHandler){m_delegateHandler = nHandler;};
	virtual void setDataSource(SFGridBoxDataSource *dataSource);
	virtual void setDataSourceHandler(int nHandler){m_dataSourceHandler = nHandler;};
private:
	void actionBegin();
	void actionEnd();
	void actionTiming(float dt);

	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);

	bool isTouchInside(CCTouch *pTouch);
	virtual void registerWithTouchDispatcher();
protected:	
	unsigned int m_columns;
	CCSize m_gridSize;

	unsigned int m_grids;
	int m_selIndex;

	unsigned int m_heightMargin;
	unsigned int m_widthMargin;

	SFGridBoxDelegate	*m_delegate;
	SFGridBoxDataSource	*m_dataSource;

	int m_dataSourceHandler;
	int m_delegateHandler;

	bool isCanTouch;
	bool isLoad;
	bool isTouchUp;
	unsigned int m_touchCount;
	unsigned int m_touchTime;
};


#endif	//__SFGRIDBOX_H__

