#ifndef __SFLABEL_H__
#define __SFLABEL_H__

#include "SFBaseControl.h"
#include "../utils/VisibleRect.h"
#include "SFLabelTex.h"

USING_NS_CC;

typedef enum
{
	kSFVerticalTextAlignmentTop,
	kSFVerticalTextAlignmentCenter,
	kSFVerticalTextAlignmentBottom,
} SFVerticalTextAlignment;

class SFLabel : public SFBaseControl
{
public:
	SFLabel();
	virtual ~SFLabel();

	static SFLabel* create(const char* str, 
		const char* font, 
		int fontSize = VisibleRect::autoFontSize(24), 
		ccColor3B color = ccBLACK, 
		CCSize size = CCSizeZero);

	bool init(const char* str, const char* font, int fontSize = VisibleRect::autoFontSize(24), ccColor3B color = ccBLACK, CCSize size = CCSizeZero);
	void setDimensions(CCSize size);
	void setString(const char* str);
	void setFontName(const char* font);
	void setFontSize(int fontSize);
	//void setColor(ccColor3B color);
	void setVerticalTextAlignment(SFVerticalTextAlignment alignment);

	CCSize getDimensions();
	const char* getString();
	const char* getFontName();
	int getFontSize();
	//ccColor3B getColor();
	SFVerticalTextAlignment getVerticalTextAlignment();

	virtual const CCSize& getContentSize();

private:
	SFLabelTex* m_pLabel;
};

#endif