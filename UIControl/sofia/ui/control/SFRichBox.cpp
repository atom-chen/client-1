#include "ui/control/SFRichBox.h"
#include "ui/utils/VisibleRect.h"
//#include "platform/TextUtils.h"
#include "sprite_nodes/CCSpriteFrame.h"
#include "sprite_nodes/CCSpriteFrameCache.h"
//#include "utils/SFTouchDispatcher.h"

enum eTagFormat
{
	eTagFormatNone = 0,
	eTagFormatStart,
	eTagFormatEnd,
	eTagFormatSeparate
};


#define kKeyText		"text"
#define kKeyFont		"font"
#define kKeyFontSize	"size"
#define kKeyFontColor	"color"
#define kKeyData		"data"
#define kKeyImage		"image"
#define kkeyScale		"autoscale"

#define kQuadSize sizeof(m_sQuad.bl)

SFRichBox::SFRichBox():m_dimensions(CCSizeZero),m_prevEventId(0), m_callbackHandler(NULL), m_callback(NULL)
{
	m_sBlendFunc.src = CC_BLEND_SRC;
	m_sBlendFunc.dst = CC_BLEND_DST;
	setOpacityModifyRGB(true);
	m_batchNodes = CCArray::create();
	CC_SAFE_RETAIN(m_batchNodes);
	m_lastIndex = CCSprite::create();
	CC_SAFE_RETAIN(m_lastIndex);
}

SFRichBox::~SFRichBox()
{

}


void SFRichBox::setDimensions(CCSize var)
{
	m_dimensions = var;
}

CCSize SFRichBox::getDimensions()
{
	return m_dimensions;
}

void SFRichBox::clear()
{
	std::list<stTextInfo*>::iterator iter = m_drawList.begin();
	for (; iter != m_drawList.end(); ++iter)
	{
		CC_SAFE_DELETE((*iter)->data);
		CC_SAFE_DELETE((*iter));
	}
	m_drawList.clear();

	iter = m_eventList.begin();
	for (; iter != m_eventList.end(); ++iter)
	{
		CC_SAFE_DELETE((*iter)->data);
		CC_SAFE_DELETE((*iter));
	}
	m_eventList.clear();

	m_rectLast = CCRectZero;
	m_formatList.clear();
	m_batchNodes = CCArray::create();
	CC_SAFE_RETAIN(m_batchNodes);
	m_lastIndex = CCSprite::create();
	CC_SAFE_RETAIN(m_lastIndex);
	removeAllChildrenWithCleanup(true);

	setTouchEnabled(false);
}

void SFRichBox::clearAll()
{
	clear();
	setContentSize(CCSizeZero);
}


void SFRichBox::setClickHandle( CCObject* object, SFRichBoxCallback callback )
{
	m_callback = callback;
	m_callbackHandler = object;
}

bool SFRichBox::ccTouchBegan( CCTouch *pTouch, CCEvent *pEvent )
{
	if (isTouchInside(pTouch) && onTouch(pTouch))
	{
		return true;
	}

	return false;
}

bool SFRichBox::onTouch( CCTouch* pTouch )
{
	bool bRet = false;
	if (pTouch)
	{
		CCPoint pos = convertTouchToNodeSpace(pTouch);
	}
	return bRet;
}



bool SFRichBox::init()
{
	bool bRet =SFBaseControl::init();
	setTouchEnabled(true);
	setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor));
	return bRet;
}

void SFRichBox::appendFormatText( const char* pText )
{
	if (!pText)
		return;

	parseText(pText);
}

void SFRichBox::parseText( const char* pText )
{
	if (!pText)
		return;

	const char* p = pText;

	std::list<SFSharedFontManager::uFormatData> formatList;

	SFSharedFontManager::uFormatData data;
	data.imageFormat = NULL;
	data.textFormat = NULL;
	eTagFormat eTag = eTagFormatNone;
	std::string key;
	std::string value;
	while (*p != '\0')
	{
		if (*p == '@' && eTag == eTagFormatNone)
		{
			if (data.textFormat != NULL || data.imageFormat != NULL)
			{// ERROR
				break;
			}
			eTag = eTagFormatStart;
			key = "";
			value = "";
		}
		else if (*p == '@' && (eTag == eTagFormatStart || eTag == eTagFormatSeparate))
		{
			if (key.length() > 0 && value.length() > 0)
			{
				saveValue(&data, key.c_str(), value.c_str());
			}

			key = "";
			value = "";

			if (data.textFormat || data.imageFormat)
			{
				formatList.push_back(data);
				data.imageFormat = NULL;
				data.textFormat = NULL;
			}

			eTag = eTagFormatNone;
		}
		else if (*p == ';' && (eTag == eTagFormatStart || eTag == eTagFormatSeparate))
		{
			if (key.length() > 0 && value.length() > 0)
			{
				saveValue(&data, key.c_str(), value.c_str());
			}

			key = "";
			value = "";
			eTag = eTagFormatStart;
		}
		else if (*p == '=' && eTag == eTagFormatStart)
		{
			eTag = eTagFormatSeparate;
		}
		else if (eTag == eTagFormatSeparate || eTag == eTagFormatStart)
		{
			if (eTag == eTagFormatSeparate)
				value += *p;
			else
				key += *p;
		}

		p++;
	}
	m_formatList = formatList;
	CCSize change = SFSharedFontManager::sharedSFSharedFontManager()->updateRichTextBatchNodeSprite(formatList,m_batchNodes,m_dimensions,m_lastIndex);
	setContentSize(change);
	for (int i=0;i<m_batchNodes->count();i++)
	{
		CCSpriteBatchNode* batch = (CCSpriteBatchNode*)m_batchNodes->objectAtIndex(i);
		//检测是否这个batch已经添加到label，如果没有就添加
		CCNode* parent = batch->getParent();
		if (parent != this)
		{
			addChild(batch);
		}
	}

}

bool SFRichBox::saveValue( SFSharedFontManager::uFormatData* format, const char* key, const char* value )
{
	bool bRet = false;

	if (format && key && value)
	{
		if (isTextFormatKey(key) && !format->imageFormat)
		{
			if (!format->textFormat)
			{
				format->textFormat = new SFSharedFontManager::stTextFormat;
				format->textFormat->fontSize =10;
				format->textFormat->color = ccBLACK;
			}

			std::string strValue = value;
			if (strcmp(key, kKeyFont) == 0)
				format->textFormat->font = value;
			else if (strcmp(key, kKeyFontColor) == 0)
				format->textFormat->color = stringToColor(strValue);
			else if (strcmp(key, kKeyFontSize) == 0)
				format->textFormat->fontSize = atoi(value);
			else if (strcmp(key, kKeyData) == 0)
				format->textFormat->data = value;
			else if (strcmp(key, kKeyText) == 0)
				format->textFormat->text = value;
			bRet = true;
		}
		else if (isImageFormatKey(key) && !format->textFormat)
		{
			if (!format->imageFormat)
			{
				format->imageFormat = new SFSharedFontManager::stImageFormat;
				
			}

			if (strcmp(key, kKeyImage) == 0)
				format->imageFormat->imageFrameName = value;
			else if (strcmp(key, kkeyScale) == 0)
				

			bRet = true;
		}
	}

	return bRet;
}

bool SFRichBox::isTextFormatKey( const char* key )
{
	bool bRet = false;

	if (strcmp(key, kKeyFont) == 0 || strcmp(key, kKeyFontColor) == 0 || strcmp(key, kKeyFontSize) == 0
		|| strcmp(key, kKeyData) == 0 || strcmp(key, kKeyText) == 0)
	{
		bRet = true;
	}

	return bRet;
}

bool SFRichBox::isImageFormatKey( const char* key )
{
	bool bRet = false;

	if (strcmp(key, kKeyImage) == 0 || strcmp(key, kkeyScale) == 0)
	{
		bRet = true;
	}

	return bRet;
}

int SFRichBox::convertFromHex( std::string& hex )
{
	int value = 0;
	int a = 0;
	int b = hex.length() - 1;
	for (; b >= 0; a++, b--)
	{
		if (hex[b] >= '0' && hex[b] <= '9')
		{
			value += (hex[b] - '0') * (1 << (a * 4));
		}
		else
		{
			switch (hex[b])
			{
			case 'A':
			case 'a':
				value += 10 * (1 << (a * 4));
				break;

			case 'B':
			case 'b':
				value += 11 * (1 << (a * 4));
				break;

			case 'C':
			case 'c':
				value += 12 * (1 << (a * 4));
				break;

			case 'D':
			case 'd':
				value += 13 * (1 << (a * 4));
				break;

			case 'E':
			case 'e':
				value += 14 * (1 << (a * 4));
				break;

			case 'F':
			case 'f':
				value += 15 * (1 << (a * 4));
				break;

			default:
				break;
			}
		}
	}

	return value;
}

cocos2d::ccColor3B SFRichBox::stringToColor( std::string& str )
{
	if (str.size() != 6)
	{
		return ccWHITE;
	}

	std::string strR = str.substr(0, 2);
	std::string strG = str.substr(2, 2);
	std::string strB = str.substr(4, 2);
	unsigned char intR = convertFromHex(strR);
	unsigned char intG = convertFromHex(strG);
	unsigned char intB = convertFromHex(strB);
	return ccc3(intR, intG, intB);// {intR,intG,intB};
}





void SFRichBox::divertDrawList()
{

}

void SFRichBox::StringReplace( std::string &strBase, std::string strSrc, std::string strDes )
{
	std::string::size_type pos = 0;
	std::string::size_type srcLen = strSrc.size();
	std::string::size_type desLen = strDes.size();
	pos=strBase.find(strSrc, pos); 
	while ((pos != std::string::npos))
	{
		strBase.replace(pos, srcLen, strDes);
		pos=strBase.find(strSrc, (pos+desLen));
	}
}

void SFRichBox::onEnter()
{
	SFBaseControl::onEnter();
}

void SFRichBox::onExit()
{
	SFBaseControl::onExit();
	clear();
	CC_SAFE_RELEASE_NULL(m_batchNodes);
	CC_SAFE_RELEASE_NULL(m_lastIndex);
}

