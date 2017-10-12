#ifndef _SF_LABEL_TTF_H_
#define _SF_LABEL_TTF_H_

#include "sprite_nodes/CCSpriteBatchNode.h"
#include "cocos2d.h"
using namespace cocos2d;

typedef struct tagFontGlyph
{
	unsigned int	key;
	unsigned int	charID;
	CCRect			rect;
	short			xOffset;
	short			yOffset;
	short			xAdvance;
	UT_hash_handle    hh;
}TFONTGLYPH;

class SFLabelTTF : public CCSpriteBatchNode, public CCLabelProtocol, public CCRGBAProtocol
{
	/** conforms to CCRGBAProtocol protocol */
	CC_PROPERTY(GLubyte, m_cOpacity, Opacity)
	/** conforms to CCRGBAProtocol protocol */
	CC_PROPERTY_PASS_BY_REF(ccColor3B, m_tColor, Color)
	/** conforms to CCRGBAProtocol protocol */
	bool m_bIsOpacityModifyRGB;
	bool isOpacityModifyRGB();
	void setOpacityModifyRGB(bool isOpacityModifyRGB);
public:
	SFLabelTTF(void);
	~SFLabelTTF();

	const char* description();

	bool		init(const char* fontName, float fontSize, bool bBold = false, bool bItalic = false, bool bAntialias = true);
	virtual void	setString(const char* string);
	virtual void	setString(const char *label, bool fromUpdate);
	virtual void setCString(const char *label);
	virtual const char* getString();
	virtual void updateString(bool fromUpdate);

	virtual void setAnchorPoint(const CCPoint& var);
	virtual void updateLabel();
	virtual void setAlignment(CCTextAlignment alignment);
	virtual void setWidth(float width);
	virtual void setLineBreakWithoutSpace(bool breakWithoutSpace);
	virtual void setScale(float scale);
	virtual void setScaleX(float scaleX);
	virtual void setScaleY(float scaleY);

	float		getFontSize();
	void		setFontSize(float fontSize);
	const char* getFontName();
	void		setFontName(const char* fontName);


	/** updates the font chars based on the string to render */
	void createFontChars();
public:
	struct tagFontGlyph* m_pFontDefDictionary;
	//static const unsigned int font_count = 0xFFFF;
protected:
	/** Font name used in the label */
	std::string * m_pFontName;
	// initial string without line breaks
	std::string m_sInitialString;
	// max width until a line break is added
	float m_fWidth;
	// alignment of all lines
	CCTextAlignment m_pAlignment;
	// string to render
	unsigned short* m_sString;
	bool m_bLineBreakWithoutSpaces;

	int			m_nCommonHeight;
	//! Padding
	ccBMFontPadding    m_tPadding;
	// offset of the texture atlas
	CCPoint    m_tImageOffset;
private:
	int kerningAmountForFirst(unsigned short first, unsigned short second);
};

#endif