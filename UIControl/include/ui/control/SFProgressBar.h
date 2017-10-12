/********************************************************************
	created:	2013/01/24
	created:	24:1:2013   15:37
	filename: 	E:\jiuxian\client_sulation\trunk\mf.game\Classes\game\Common\MFUIComponent\SFProgressBar.h
	file path:	E:\jiuxian\client_sulation\trunk\mf.game\Classes\game\Common\MFUIComponent
	file base:	SFProgressBar
	file ext:	h
	author:		Liu Rui
	
	purpose:	简单进度条，可以显示背景和当初的数字
*********************************************************************/

#ifndef __SFProgressBar_h__
#define __SFProgressBar_h__

#include "./SFBaseControl.h"
#include <string>
#include "../utils/VisibleRect.h"
//class SFScale9Sprite;


class SFProgressBar : public SFBaseControl
{
public:
	static SFProgressBar* create(CCScale9Sprite* pBarImage, CCSize sizeBar);
	explicit SFProgressBar(CCScale9Sprite* pBarImage, CCSize sizeBar);
	virtual ~SFProgressBar();

	virtual bool init();

	void setBackground(CCScale9Sprite* pBarBg);

	void setNumberVisible(bool bVisible);
	void setTextParam(const char* pFontName, int fontSize, cocos2d::ccColor3B fontColor, 
		cocos2d::ccColor3B strokeColor=ccBLACK, int stroleSize = -1);

	void setMaxNumber(int number);
	inline int getMaxNumber(){return m_max;}

	void setCurrentNumber(int number);
	inline int getCurrentNumber(){return m_current;}

	void setPercentage(int number);
	inline int getPercentage(){return 100*m_current/m_max;}

private:
	void updateNumberText();
	void updateProgressBar(int percentage);

private:
	CCScale9Sprite* m_barBg;
	CCLabelTTF* m_number;
	CCScale9Sprite* m_bar;

	int m_max;
	int m_current;
	int m_bgFrameSize;
	CCSize m_sizeBar;
};

#endif