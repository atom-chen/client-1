#ifndef SFLABEL_TEX_H 
#define SFLABEL_TEX_H 

/********************************************************************
文件名:SFLabelTex.h
创建者:Zhan XianBo
创建时间:2013-9-17
功能描述:使用大图纹理管理字体渲染的Label
*********************************************************************/
#include "cocos2d.h"
USING_NS_CC;

class SFLabelTex : public CCNodeRGBA
{
private:
	CCArray* m_batchNodes;
	CCSize m_tDimensions;
	CCTextAlignment         m_hAlignment;
	CCVerticalTextAlignment m_vAlignment;
	std::string m_pFontName;
	float m_fFontSize;
	std::string m_string;
	ccColor3B   m_textFillColor;
	bool updateShowNode();
	CCSize getShowingDimension();
	bool hasDimension();
protected:
	bool init();
public:
	SFLabelTex();
	virtual ~SFLabelTex();

	bool initWithString(const char* string,const char* fontName,float size);
	bool initWithString(const char* string, const char* fontName, float fontSize,
		const CCSize& dimensions, CCTextAlignment hAlignment);
	bool initWithString(const char* string, const char* fontName, float fontSize,
		const CCSize& dimensions, CCTextAlignment hAlignment,CCVerticalTextAlignment vAlignment);
	static SFLabelTex* create();
	static SFLabelTex* create(const char* string, const char* fontName, float fontSize);
	static SFLabelTex* create(const char* string, const char* fontName, float fontSize,CCSize dimensions);
	static SFLabelTex* create(const char* string, const char* fontName, float fontSize,
		const CCSize& dimensions, CCTextAlignment hAlignment);
	static SFLabelTex* create(const char* string, const char* fontName, float fontSize,
		const CCSize& dimensions, CCTextAlignment hAlignment, 
		CCVerticalTextAlignment vAlignment);

	void setFontFillColor(const ccColor3B &tintColor, bool mustUpdateTexture = true);
	ccColor3B getFontFillColor();
	void setColor(const ccColor3B& color3);
	void setString(const char* label);
	const char* getString(void);

	CCTextAlignment getHorizontalAlignment();
	void setHorizontalAlignment(CCTextAlignment alignment);

	CCVerticalTextAlignment getVerticalAlignment();
	void setVerticalAlignment(CCVerticalTextAlignment verticalAlignment);

	CCSize getDimensions();
	void setDimensions(const CCSize &dim);

	float getFontSize();
	void setFontSize(float fontSize);

	const char* getFontName();
	void setFontName(const char* fontName);
};

#endif