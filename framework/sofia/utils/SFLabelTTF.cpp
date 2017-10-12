#include "SFLabelTTF.h"
//static int cc_wcslen(const unsigned short* str)
//{
//    int i=0;
//    while(*str++) i++;
//    return i;
//}

/* Code from GLIB gutf8.c starts here. */

#define UTF8_COMPUTE(Char, Mask, Len)        \
  if (Char < 128)                \
    {                        \
      Len = 1;                    \
      Mask = 0x7f;                \
    }                        \
  else if ((Char & 0xe0) == 0xc0)        \
    {                        \
      Len = 2;                    \
      Mask = 0x1f;                \
    }                        \
  else if ((Char & 0xf0) == 0xe0)        \
    {                        \
      Len = 3;                    \
      Mask = 0x0f;                \
    }                        \
  else if ((Char & 0xf8) == 0xf0)        \
    {                        \
      Len = 4;                    \
      Mask = 0x07;                \
    }                        \
  else if ((Char & 0xfc) == 0xf8)        \
    {                        \
      Len = 5;                    \
      Mask = 0x03;                \
    }                        \
  else if ((Char & 0xfe) == 0xfc)        \
    {                        \
      Len = 6;                    \
      Mask = 0x01;                \
    }                        \
  else                        \
    Len = -1;

#define UTF8_LENGTH(Char)            \
  ((Char) < 0x80 ? 1 :                \
   ((Char) < 0x800 ? 2 :            \
    ((Char) < 0x10000 ? 3 :            \
     ((Char) < 0x200000 ? 4 :            \
      ((Char) < 0x4000000 ? 5 : 6)))))


#define UTF8_GET(Result, Chars, Count, Mask, Len)    \
  (Result) = (Chars)[0] & (Mask);            \
  for ((Count) = 1; (Count) < (Len); ++(Count))        \
    {                            \
      if (((Chars)[(Count)] & 0xc0) != 0x80)        \
    {                        \
      (Result) = -1;                \
      break;                    \
    }                        \
      (Result) <<= 6;                    \
      (Result) |= ((Chars)[(Count)] & 0x3f);        \
    }

#define UNICODE_VALID(Char)            \
  ((Char) < 0x110000 &&                \
   (((Char) & 0xFFFFF800) != 0xD800) &&        \
   ((Char) < 0xFDD0 || (Char) > 0xFDEF) &&    \
   ((Char) & 0xFFFE) != 0xFFFE)


static const char utf8_skip_data[256] = {
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 2,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5,
  5, 5, 5, 6, 6, 1, 1
};

static const char *const g_utf8_skip = utf8_skip_data;

#define cc_utf8_next_char(p) (char *)((p) + g_utf8_skip[*(unsigned char *)(p)])

/*
 * @str:    the string to search through.
 * @c:        the character to find.
 * 
 * Returns the index of the first occurrence of the character, if found.  Otherwise -1 is returned.
 * 
 * Return value: the index of the first occurrence of the character if found or -1 otherwise.
 * */
static unsigned int cc_utf8_find_char(std::vector<unsigned short> str, unsigned short c)
{
    unsigned int len = str.size();

    for (unsigned int i = 0; i < len; ++i)
        if (str[i] == c) return i;

    return -1;
}

/*
 * @str:    the string to search through.
 * @c:        the character to not look for.
 * 
 * Return value: the index of the last character that is not c.
 * */
static unsigned int cc_utf8_find_last_not_char(std::vector<unsigned short> str, unsigned short c)
{
    int len = str.size();

    int i = len - 1;
    for (; i >= 0; --i)
        if (str[i] != c) return i;

    return i;
}

/*
 * @str:    the string to trim
 * @index:    the index to start trimming from.
 * 
 * Trims str st str=[0, index) after the operation.
 * 
 * Return value: the trimmed string.
 * */
static void cc_utf8_trim_from(std::vector<unsigned short>* str, int index)
{
    int size = str->size();
    if (index >= size || index < 0)
        return;

    str->erase(str->begin() + index, str->begin() + size);
}

/*
 * @ch is the unicode character whitespace?
 * 
 * Reference: http://en.wikipedia.org/wiki/Whitespace_character#Unicode
 * 
 * Return value: weather the character is a whitespace character.
 * */
//static bool isspace_unicode(unsigned short ch)
//{
//    return  (ch >= 0x0009 && ch <= 0x000D) || ch == 0x0020 || ch == 0x0085 || ch == 0x00A0 || ch == 0x1680
//        || (ch >= 0x2000 && ch <= 0x200A) || ch == 0x2028 || ch == 0x2029 || ch == 0x202F
//        ||  ch == 0x205F || ch == 0x3000;
//}

static void cc_utf8_trim_ws(std::vector<unsigned short>* str)
{
    int len = str->size();

    if ( len <= 0 )
        return;

    int last_index = len - 1;

    // Only start trimming if the last character is whitespace..
    if (isspace_unicode((*str)[last_index]))
    {
        for (int i = last_index - 1; i >= 0; --i)
        {
            if (isspace_unicode((*str)[i]))
                last_index = i;
            else
                break;
        }

        cc_utf8_trim_from(str, last_index);
    }
}
/*
 * g_utf8_strlen:
 * @p: pointer to the start of a UTF-8 encoded string.
 * @max: the maximum number of bytes to examine. If @max
 *       is less than 0, then the string is assumed to be
 *       null-terminated. If @max is 0, @p will not be examined and
 *       may be %NULL.
 *
 * Returns the length of the string in characters.
 *
 * Return value: the length of the string in characters
 **/
//long
//cc_utf8_strlen (const char * p, int max)
//{
//  long len = 0;
//  const char *start = p;
//
//  if (!(p != NULL || max == 0))
//  {
//      return 0;
//  }
//
//  if (max < 0)
//    {
//      while (*p)
//    {
//      p = cc_utf8_next_char (p);
//      ++len;
//    }
//    }
//  else
//    {
//      if (max == 0 || !*p)
//    return 0;
//
//      p = cc_utf8_next_char (p);
//
//      while (p - start < max && *p)
//    {
//      ++len;
//      p = cc_utf8_next_char (p);
//    }
//
//      /* only do the last len increment if we got a complete
//       * char (don't count partial chars)
//       */
//      if (p - start == max)
//    ++len;
//    }
//
//  return len;
//}

/*
 * g_utf8_get_char:
 * @p: a pointer to Unicode character encoded as UTF-8
 *
 * Converts a sequence of bytes encoded as UTF-8 to a Unicode character.
 * If @p does not point to a valid UTF-8 encoded character, results are
 * undefined. If you are not sure that the bytes are complete
 * valid Unicode characters, you should use g_utf8_get_char_validated()
 * instead.
 *
 * Return value: the resulting character
 **/
static unsigned int
cc_utf8_get_char (const char * p)
{
  int i, mask = 0, len;
  unsigned int result;
  unsigned char c = (unsigned char) *p;

  UTF8_COMPUTE (c, mask, len);
  if (len == -1)
    return (unsigned int) - 1;
  UTF8_GET (result, p, i, mask, len);

  return result;
}

/*
 * cc_utf16_from_utf8:
 * @str_old: pointer to the start of a C string.
 * 
 * Creates a utf8 string from a cstring.
 * 
 * Return value: the newly created utf8 string.
 * */
static unsigned short* cc_utf16_from_utf8(const char* str_old)
{
    int len = cc_utf8_strlen(str_old, -1);

    unsigned short* str_new = new unsigned short[len + 1];
    str_new[len] = 0;

    for (int i = 0; i < len; ++i)
    {
        str_new[i] = cc_utf8_get_char(str_old);
        str_old = cc_utf8_next_char(str_old);
    }

    return str_new;
}

SFLabelTTF::SFLabelTTF()
: m_pFontName(NULL)
, m_nCommonHeight(0)
{

}

SFLabelTTF::~SFLabelTTF()
{
	CC_SAFE_DELETE(m_pFontName);
}

const char* SFLabelTTF::description()
{
	return "";
}

bool SFLabelTTF::init(const char* fontName, float fontSize, bool bBold /* = false */, bool bItalic /* = false */, bool bAntialias /* = true */)
{
	return true;
}

// LabelBMFont - Atlas generation
int SFLabelTTF::kerningAmountForFirst(unsigned short first, unsigned short second)
{
	int ret = 0;
	//unsigned int key = (first<<16) | (second & 0xffff);

	//if( m_pConfiguration->m_pKerningDictionary ) {
	//	tKerningHashElement *element = NULL;
	//	HASH_FIND_INT(m_pConfiguration->m_pKerningDictionary, &key, element);        
	//	if(element)
	//		ret = element->amount;
	//}
	return ret;
}

void SFLabelTTF::createFontChars()
{
	int nextFontPositionX = 0;
	int nextFontPositionY = 0;
	////unsigned short prev = -1;
	int kerningAmount = 0;

	CCSize tmpSize = CCSizeZero;

	int longestLine = 0;
	unsigned int totalHeight = 0;

	unsigned int quantityOfLines = 1;

	unsigned int stringLen = cc_wcslen(m_sString);
	if (stringLen == 0)
	{
		return;
	}

	for (unsigned int i = 0; i < stringLen - 1; ++i)
	{
		unsigned short c = m_sString[i];
		if (c == '\n')
		{
			quantityOfLines++;
		}
	}

	totalHeight = m_nCommonHeight * quantityOfLines;
	nextFontPositionY = 0-(m_nCommonHeight - m_nCommonHeight * quantityOfLines);

	for (unsigned int i= 0; i < stringLen; i++)
	{
		unsigned short c = m_sString[i];

		if (c == '\n')
		{
			nextFontPositionX = 0;
			nextFontPositionY -= m_nCommonHeight;
			continue;
		}

		tagFontGlyph *element = NULL;

		// unichar is a short, and an int is needed on HASH_FIND_INT
		unsigned int key = c;
		HASH_FIND_INT(m_pFontDefDictionary, &key, element);
		CCAssert(element, "FontDefinition could not be found!");

	//	ccBMFontDef fontDef = element->fontDef;

		CCRect rect = element->rect;
		rect = CC_RECT_PIXELS_TO_POINTS(rect);

		rect.origin.x += m_tImageOffset.x;
		rect.origin.y += m_tImageOffset.y;

		CCSprite *fontChar;

		fontChar = (CCSprite*)(this->getChildByTag(i));
		if( ! fontChar )
		{
			fontChar = new CCSprite();
	//		fontChar->initWithTexture(m_pobTextureAtlas->getTexture(), rect);
			this->addChild(fontChar, 0, i);
	//		fontChar->release();
		}
		else
		{
			// reusing fonts
	//		fontChar->setTextureRect(rect, false, rect.size);

			// restore to default in case they were modified
	//		fontChar->setVisible(true);
	//		fontChar->setOpacity(255);
		}

	//	// See issue 1343. cast( signed short + unsigned integer ) == unsigned integer (sign is lost!)
	//	int yOffset = m_pConfiguration->m_nCommonHeight - fontDef.yOffset;
	//	CCPoint fontPos = ccp( (float)nextFontPositionX + fontDef.xOffset + fontDef.rect.size.width*0.5f + kerningAmount,
	//		(float)nextFontPositionY + yOffset - rect.size.height*0.5f * CC_CONTENT_SCALE_FACTOR() );
	//	fontChar->setPosition(CC_POINT_PIXELS_TO_POINTS(fontPos));

	//	// update kerning
	//	nextFontPositionX += fontDef.xAdvance + kerningAmount;
	//	//prev = c;

	//	// Apply label properties
	//	fontChar->setOpacityModifyRGB(m_bIsOpacityModifyRGB);
	//	// Color MUST be set before opacity, since opacity might change color if OpacityModifyRGB is on
	//	fontChar->setColor(m_tColor);

		// only apply opacity if it is different than 255 )
		// to prevent modifying the color too (issue #610)
		if( m_cOpacity != 255 )
		{
			//fontChar->setOpacity(m_cOpacity);
		}

	//	if (longestLine < nextFontPositionX)
	//	{
	//		longestLine = nextFontPositionX;
	//	}
	}

	tmpSize.width  = (float) longestLine;
	tmpSize.height = (float) totalHeight;

	this->setContentSize(CC_SIZE_PIXELS_TO_POINTS(tmpSize));

}

void SFLabelTTF::setString(const char* string)
{

}

void SFLabelTTF::setString(const char *label, bool fromUpdate)
{
	CC_SAFE_DELETE_ARRAY(m_sString);
	m_sString = cc_utf16_from_utf8(label);
	m_sInitialString = label;

	updateString(fromUpdate);
}

void SFLabelTTF::updateString(bool fromUpdate)
{
	if (m_pChildren && m_pChildren->count() != 0)
	{
		CCObject* child;
		CCARRAY_FOREACH(m_pChildren, child)
		{
			CCNode* pNode = (CCNode*) child;
			if (pNode)
			{
				pNode->setVisible(false);
			}
		}
	}
	this->createFontChars();

	if (!fromUpdate)
		updateLabel();
}

const char* SFLabelTTF::getString()
{
	return m_sInitialString.c_str();
}

void SFLabelTTF::setCString(const char *label)
{
	setString(label);
}

float SFLabelTTF::getFontSize()
{
	return 0.0f;
}

void SFLabelTTF::setFontSize(float fontSize)
{

}

const char* SFLabelTTF::getFontName()
{
	return "";
}

void SFLabelTTF::setFontName(const char* fontName)
{
	if (m_pFontName->compare(fontName))
	{
		delete m_pFontName;
		m_pFontName = new std::string(fontName);
	}
}

//LabelBMFont - CCRGBAProtocol protocol
void SFLabelTTF::setColor(const ccColor3B& var)
{
	m_tColor = var;
	if (m_pChildren && m_pChildren->count() != 0)
	{                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
		CCObject* child;
		CCARRAY_FOREACH(m_pChildren, child)
		{
			CCSprite* pNode = (CCSprite*) child;
			if (pNode)
			{
				pNode->setColor(m_tColor);
			}
		}
	}
}
const ccColor3B& SFLabelTTF::getColor()
{
	return m_tColor;
}
void SFLabelTTF::setOpacity(GLubyte var)
{
	m_cOpacity = var;

	if (m_pChildren && m_pChildren->count() != 0)
	{
		CCObject* child;
		CCARRAY_FOREACH(m_pChildren, child)
		{
			CCNode* pNode = (CCNode*) child;
			if (pNode)
			{
				CCRGBAProtocol *pRGBAProtocol = dynamic_cast<CCRGBAProtocol*>(pNode);
				if (pRGBAProtocol)
				{
					pRGBAProtocol->setOpacity(m_cOpacity);
				}
			}
		}
	}
}

GLubyte SFLabelTTF::getOpacity()
{
	return m_cOpacity;
}

void SFLabelTTF::setOpacityModifyRGB(bool var)
{
	m_bIsOpacityModifyRGB = var;
	if (m_pChildren && m_pChildren->count() != 0)
	{
		CCObject* child;
		CCARRAY_FOREACH(m_pChildren, child)
		{
			CCNode* pNode = (CCNode*) child;
			if (pNode)
			{
				CCRGBAProtocol *pRGBAProtocol = dynamic_cast<CCRGBAProtocol*>(pNode);
				if (pRGBAProtocol)
				{
					pRGBAProtocol->setOpacityModifyRGB(m_bIsOpacityModifyRGB);
				}
			}
		}
	}
}

bool SFLabelTTF::isOpacityModifyRGB()
{
	return m_bIsOpacityModifyRGB;
}

// LabelBMFont - AnchorPoint
void SFLabelTTF::setAnchorPoint(const CCPoint& point)
{
	if( ! point.equals(m_obAnchorPoint))
	{
		CCSpriteBatchNode::setAnchorPoint(point);
		updateLabel();
	}
}

void SFLabelTTF::updateLabel()
{
	this->setString(m_sInitialString.c_str(),true);
	//if (m_fWidth > 0)
	//{
	//	// Step 1: Make multiline
	//	vector<unsigned short> str_whole = cc_utf16_vec_from_utf16_str(m_sString);
	//	unsigned int stringLength = str_whole.size();
	//	vector<unsigned short> multiline_string;
	//	multiline_string.reserve( stringLength );
	//	vector<unsigned short> last_word;
	//	last_word.reserve( stringLength );

	//	unsigned int line = 1, i = 0;
	//	bool start_line = false, start_word = false;
	//	float startOfLine = -1, startOfWord = -1;
	//	int skip = 0;

	//	CCArray* children = getChildren();
	//	for (unsigned int j = 0; j < children->count(); j++)
	//	{
	//		CCSprite* characterSprite;

	//		while (!(characterSprite = (CCSprite*)this->getChildByTag(j + skip)))
	//			skip++;

	//		if (!characterSprite->isVisible()) continue;

	//		if (i >= stringLength)
	//			break;

	//		unsigned short character = str_whole[i];

	//		if (!start_word)
	//		{
	//			startOfWord = getLetterPosXLeft( characterSprite );
	//			start_word = true;
	//		}
	//		if (!start_line)
	//		{
	//			startOfLine = startOfWord;
	//			start_line = true;
	//		}

	//		// Newline.
	//		if (character == '\n')
	//		{
	//			cc_utf8_trim_ws(&last_word);

	//			last_word.push_back('\n');
	//			multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());
	//			last_word.clear();
	//			start_word = false;
	//			start_line = false;
	//			startOfWord = -1;
	//			startOfLine = -1;
	//			i++;
	//			line++;

	//			if (i >= stringLength)
	//				break;

	//			character = str_whole[i];

	//			if (!startOfWord)
	//			{
	//				startOfWord = getLetterPosXLeft( characterSprite );
	//				start_word = true;
	//			}
	//			if (!startOfLine)
	//			{
	//				startOfLine  = startOfWord;
	//				start_line = true;
	//			}
	//		}

	//		// Whitespace.
	//		if (isspace_unicode(character))
	//		{
	//			last_word.push_back(character);
	//			multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());
	//			last_word.clear();
	//			start_word = false;
	//			startOfWord = -1;
	//			i++;
	//			continue;
	//		}

	//		// Out of bounds.
	//		if ( getLetterPosXRight( characterSprite ) - startOfLine > m_fWidth )
	//		{
	//			if (!m_bLineBreakWithoutSpaces)
	//			{
	//				last_word.push_back(character);

	//				int found = cc_utf8_find_last_not_char(multiline_string, ' ');
	//				if (found != -1)
	//					cc_utf8_trim_ws(&multiline_string);
	//				else
	//					multiline_string.clear();

	//				if (multiline_string.size() > 0)
	//					multiline_string.push_back('\n');

	//				line++;
	//				start_line = false;
	//				startOfLine = -1;
	//				i++;
	//			}
	//			else
	//			{
	//				cc_utf8_trim_ws(&last_word);

	//				last_word.push_back('\n');
	//				multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());
	//				last_word.clear();
	//				start_word = false;
	//				start_line = false;
	//				startOfWord = -1;
	//				startOfLine = -1;
	//				line++;

	//				if (i >= stringLength)
	//					break;

	//				if (!startOfWord)
	//				{
	//					startOfWord = getLetterPosXLeft( characterSprite );
	//					start_word = true;
	//				}
	//				if (!startOfLine)
	//				{
	//					startOfLine  = startOfWord;
	//					start_line = true;
	//				}

	//				j--;
	//			}

	//			continue;
	//		}
	//		else
	//		{
	//			// Character is normal.
	//			last_word.push_back(character);
	//			i++;
	//			continue;
	//		}
	//	}

	//	multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());

	//	int size = multiline_string.size();
	//	unsigned short* str_new = new unsigned short[size + 1];

	//	for (int i = 0; i < size; ++i)
	//	{
	//		str_new[i] = multiline_string[i];
	//	}

	//	str_new[size] = 0;

	//	CC_SAFE_DELETE_ARRAY(m_sString);
	//	m_sString = str_new;
	//	updateString(true);
	//}

	//// Step 2: Make alignment
	//if (m_pAlignment != kCCTextAlignmentLeft)
	//{
	//	int i = 0;

	//	int lineNumber = 0;
	//	int str_len = cc_wcslen(m_sString);
	//	vector<unsigned short> last_line;
	//	for (int ctr = 0; ctr <= str_len; ++ctr)
	//	{
	//		if (m_sString[ctr] == '\n' || m_sString[ctr] == 0)
	//		{
	//			float lineWidth = 0.0f;
	//			unsigned int line_length = last_line.size();
	//			// if last line is empty we must just increase lineNumber and work with next line
	//			if (line_length == 0)
	//			{
	//				lineNumber++;
	//				continue;
	//			}
	//			int index = i + line_length - 1 + lineNumber;
	//			if (index < 0) continue;

	//			CCSprite* lastChar = (CCSprite*)getChildByTag(index);
	//			if ( lastChar == NULL )
	//				continue;

	//			lineWidth = lastChar->getPosition().x + lastChar->getContentSize().width/2.0f;

	//			float shift = 0;
	//			switch (m_pAlignment)
	//			{
	//			case kCCTextAlignmentCenter:
	//				shift = getContentSize().width/2.0f - lineWidth/2.0f;
	//				break;
	//			case kCCTextAlignmentRight:
	//				shift = getContentSize().width - lineWidth;
	//				break;
	//			default:
	//				break;
	//			}

	//			if (shift != 0)
	//			{
	//				for (unsigned j = 0; j < line_length; j++)
	//				{
	//					index = i + j + lineNumber;
	//					if (index < 0) continue;

	//					CCSprite* characterSprite = (CCSprite*)getChildByTag(index);
	//					characterSprite->setPosition(ccpAdd(characterSprite->getPosition(), ccp(shift, 0.0f)));
	//				}
	//			}

	//			i += line_length;
	//			lineNumber++;

	//			last_line.clear();
	//			continue;
	//		}

	//		last_line.push_back(m_sString[ctr]);
	//	}
	//}
}

// LabelBMFont - Alignment
void SFLabelTTF::setAlignment(CCTextAlignment alignment)
{
	this->m_pAlignment = alignment;
	updateLabel();
}

void SFLabelTTF::setWidth(float width)
{
	this->m_fWidth = width;
	updateLabel();
}

void SFLabelTTF::setLineBreakWithoutSpace( bool breakWithoutSpace )
{
	m_bLineBreakWithoutSpaces = breakWithoutSpace;
	updateLabel();
}

void SFLabelTTF::setScale(float scale)
{
	CCSpriteBatchNode::setScale(scale);
	updateLabel();
}

void SFLabelTTF::setScaleX(float scaleX)
{
	CCSpriteBatchNode::setScaleX(scaleX);
	updateLabel();
}

void SFLabelTTF::setScaleY(float scaleY)
{
	CCSpriteBatchNode::setScaleY(scaleY);
	updateLabel();
}