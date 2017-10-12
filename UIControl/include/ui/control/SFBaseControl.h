#ifndef __SFBASECONTROL_H__
#define __SFBASECONTROL_H__

//#include "resource/GameResource.h"
#include "cocos2d.h"
#include "GUI/CCControlExtension/CCControlExtensions.h"

USING_NS_CC;
USING_NS_CC_EXT;

enum
{
	SFControlEventTouchEnd				= 1 << 0,
	SFControlEventDoubleClick		= 1 << 1,
	SFControlEventLongClick			= 1 << 2,
	SFControlEventScrollViewScroll	= 1 << 3,
	SFControlEventScrollViewZoom	= 1 << 4,
	SFControlEventTouchMove          =  1<< 5,
	SFControlEventTouchBegin          =  1 << 6,
};

typedef unsigned int SFControlEvent;

#define kSFControlEventTotalNumber	7
class SFBaseControl: public CCLayer//, public CCRGBAProtocol
{
public:
	SFBaseControl();
	virtual ~SFBaseControl();
	//CCRGBAProtocol

	virtual void onEnter();
	virtual void onExit();

	virtual unsigned char getOpacity(void);
	virtual void setOpacity(unsigned char var);

	virtual const ccColor3B& getColor(void);
	virtual void setColor(const ccColor3B& var);

	bool m_bIsOpacityModifyRGB;
	bool isOpacityModifyRGB();
	void setOpacityModifyRGB(bool bOpacityModifyRGB);

	virtual bool init();

	void setControlName(const char* name);
	const char* getControlName();

	void setImageKey(const char* imageKey);
	const char* getImageKey();

	void setTitleKey(const char* titleKey);
	const char* getTitleKey();

	void addTargetWithActionForControlEvents(CCObject* target, SEL_CCControlHandler action, SFControlEvent controlEvents);
	void addTargetWithActionForControlEvents(int nHandler, SFControlEvent controlEvents);

	virtual void sendActionsForControlEvents(SFControlEvent controlEvents);
	/**
	* 增大点击区域：左/右/上/下
	*/
	void setTouchAreaDelta(float deltaLeft = 0.0f, float deltaRight = 0.0f, float deltaTop = 0.0f, float deltaButtom = 0.0f);


	/**
	/* 整体缩放点击区域                                                                     
	*/
	void setTouchAreaScale(float scale = 1.0f);

protected:
	bool isTouchInside(CCTouch *pTouch);
	unsigned char m_cOpacity;
protected: ccColor3B m_tColor;
		   CCArray* dispatchListforControlEvent(SFControlEvent controlEvent);

private:
	const char* m_controlName;
	const char*	m_titleKey;
	const char*	m_imageKey;
	float m_deltaLeft;
	float m_deltaRight;
	float m_deltaTop;
	float m_deltaButtom;
	float m_touchAreaScale;

	CCPoint		m_pos;

	CCDictionary* m_pDispatchTable;
};


#endif	//__SFBASECONTROL_H__

