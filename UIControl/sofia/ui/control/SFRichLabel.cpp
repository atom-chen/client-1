#include "ui/control/SFRichLabel.h"
#include "ui/utils/VisibleRect.h"
#include "sprite_nodes/CCSpriteFrame.h"
#include "sprite_nodes/CCSpriteFrameCache.h"
#include "utils/SFTouchDispatcher.h"
#include "include/utils/SFMiniHtml.h"
#include "include/utils/CCStrConv.h"
#include "include/utils/CCStrUtil.h"
#include "script_support/CCScriptSupport.h"
//处理字符编码方法和宏
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

enum eTagFormat
{
	eTagFormatNone = 0,
	eTagFormatStart,
	eTagFormatEnd,
	eTagFormatSeparate
};

#define kNextLine 10
#define  kReturn 13

#define kQuadSize sizeof(m_sQuad.bl)

bool GetAtomListValue(const std::vector<SFMiniHtmlParser::Attr>& attrList, const char* key, std::string& ret, const std::string& default_str = "")
{
	for (std::vector<SFMiniHtmlParser::Attr>::size_type attr_index = 0 ;attr_index < attrList.size();attr_index++)
	{
		const SFMiniHtmlParser::Attr& attr = attrList[attr_index];
		if(attr.key == key)
		{
			ret = attr.value.c_str();
			return true;
		}
	}

	ret = default_str;
	return false;
}

SFRichLabel::SFRichLabel():m_dimensions(CCSizeZero),m_defFontHeight(-1),m_prevEventId(0),m_heightSum(0),m_WidthSum(0),m_currentWidth(0),m_currentMaxHeight(0),m_handler(0)
{
	m_sBlendFunc.src = CC_BLEND_SRC;
	m_sBlendFunc.dst = CC_BLEND_DST;
	setOpacityModifyRGB(true);
	m_batchNodes = CCArray::create();
	CC_SAFE_RETAIN(m_batchNodes);
	m_lastIndex = CCSprite::create();
	CC_SAFE_RETAIN(m_lastIndex);
	m_defaultFontName = "Arial";
	m_defaultFontSize = 16;
	m_handler = 0;
	m_gaps = 0;
}

SFRichLabel::~SFRichLabel()
{
	CC_SAFE_RELEASE_NULL(m_batchNodes);
	CC_SAFE_RELEASE_NULL(m_lastIndex);
}


void SFRichLabel::setDimensions(CCSize var)
{
	m_dimensions = var;
}

CCSize SFRichLabel::getDimensions()
{
	return m_dimensions;
}

void SFRichLabel::clear()
{
	m_linkList.clear();
	m_batchNodes->removeAllObjects();
	if (m_spritesNode)
	{
		m_spritesNode->removeAllChildrenWithCleanup(true);
		m_spritesNode = NULL;
	}
	removeAllChildrenWithCleanup(true);
	m_lastIndex->setPosition(CCPointZero);
	m_lastIndex->setContentSize(CCSizeZero);
	 m_currentMaxHeight = 0;
	m_heightSum  = 0;
	m_currentWidth = 0;
	m_WidthSum = 0;
	setTouchEnabled(false);
}

void SFRichLabel::clearAll()
{
	clear();
	setContentSize(CCSizeZero);
}


bool SFRichLabel::ccTouchBegan( CCTouch *pTouch, CCEvent *pEvent )
{
	//Juchao@20140504: RichLabel的contentsize有问题。暂时不需要判断是否点击到自己
	if (/*isTouchIn(pTouch)&&*/onTouch(pTouch))
	{
		return true;
	}
	return false;
}

bool SFRichLabel::onTouch( CCTouch* pTouch )
{
	bool bRet = false;
	if (pTouch)
	{
		CCPoint pos = convertTouchToNodeSpace(pTouch);
		linkIt find;
		for (find = m_linkList.begin();find != m_linkList.end();find++)
		{
			eventType event = find->second;
			CCSprite* sprite = event.first;
			CCRect rect = sprite->boundingBox();
			if (rect.containsPoint(pos))
			{
				if (m_handler)
				{
					CCScriptEngineProtocol * engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
					engine->executeRichBoxTouchEvent(m_handler,find->first.c_str(), pTouch);
				}
			}
		}
		bRet = true;
	}
	return bRet;
}



bool SFRichLabel::init()
{
	bool bRet =SFBaseControl::init();
	setTouchEnabled(true);
	setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor));
	m_spritesNode = CCNode::create();
	addChild(m_spritesNode);
	return bRet;
}

void SFRichLabel::appendFormatText( const char* pText )
{
	if (!pText)
		return;

	parseText(pText);
}

void SFRichLabel::parseText( const char* pText )
{
	if (!pText)
		return;

	const char* p = pText;

	std::list<uFormatData> formatList;

	uFormatData data;
	data.imageFormat = NULL;
	data.textFormat = NULL;
	eTagFormat eTag = eTagFormatNone;
	
	SFMiniHtmlParser parser;
	SFMiniHtmlParser::DataArray dataArray = parser.Parse(pText);

	for (SFMiniHtmlParser::DataArray::size_type index = 0; index < dataArray.size(); index++)
	{
		SFMiniHtmlParser::Data htmlData = dataArray[index];
		std::vector<SFMiniHtmlParser::Atom>& atomList =  htmlData.atom_list;

		// 文字属性设置
		std::string eventStr = "";
		bool isUnderLine = false;
		std::string underLineString  = "";
		std::string colorStr = "FFFFFF";
		float fontSize = m_defaultFontSize;
		bool hasAlignmentTag = false;
		for (std::vector<SFMiniHtmlParser::Atom>::size_type atom_index = 0;atom_index < atomList.size();atom_index++)
		{
			SFMiniHtmlParser::Atom& atom = atomList[atom_index];
			//CCLog("atom.atom_name=%s", atom.atom_name.c_str());
			if(atom.atom_name == "img")
			{
				std::string setName;
				std::string imageName;
				std::string widthStr;
				std::string heightStr;
				std::string eventStr;
				GetAtomListValue(atom.attr_list,"name",setName);
				GetAtomListValue(atom.attr_list,"image",imageName);
				GetAtomListValue(atom.attr_list,"width",widthStr);
				GetAtomListValue(atom.attr_list,"height",heightStr);
				GetAtomListValue(atom.attr_list,"data",eventStr);
				appendImage(setName, imageName, eventStr, StrConv::parseReal(widthStr), StrConv::parseReal(heightStr));
			}
			else if(atom.atom_name == "a")
			{
				GetAtomListValue(atom.attr_list, "data", eventStr);
				GetAtomListValue(atom.attr_list, "line", underLineString);
				if (underLineString == "true")
				{
					isUnderLine = true;
				}
				
			}
			else if(atom.atom_name == "font")
			{
				std::string colorTextStr;
				std::string fontSizeStr;
				std::string fontExtraAdvanceStr;

				if(GetAtomListValue(atom.attr_list, "color", colorTextStr))
				{
					colorStr = std::string( colorTextStr.c_str(), 1, colorTextStr.size());
				}

				if(GetAtomListValue(atom.attr_list, "size", fontSizeStr))
				{
					fontSize = StrConv::parseReal(fontSizeStr);
				}
			}else if (atom.atom_name == "alignment")
			{
				std::string type;
				GetAtomListValue(atom.attr_list, "type", type);
				appendAlignmentText(htmlData.data.c_str(),type);
				hasAlignmentTag = true;
			}
				
		}
		if (hasAlignmentTag)
		{
			continue;
		}
		if(eventStr != "")
		{
			appendText(htmlData.data.c_str(),fontSize, colorStr.c_str(),true,isUnderLine,eventStr.c_str());
		}
		else
		{
			appendText(htmlData.data.c_str(),fontSize, colorStr.c_str());
		}
	}
	CCSize change = m_dimensions;
	if (m_dimensions.width == 0)
	{
		change.width = m_WidthSum;
	}
	if (m_dimensions.height == 0)
	{
		change.height = m_heightSum+m_currentMaxHeight;
	}
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

int SFRichLabel::convertFromHex( std::string& hex )
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

cocos2d::ccColor3B SFRichLabel::stringToColor( std::string& str )
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


void SFRichLabel::StringReplace( std::string &strBase, std::string strSrc, std::string strDes )
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

void SFRichLabel::onEnter()
{
	setTouchEnabled(true);
	SFBaseControl::onEnter();
}

void SFRichLabel::onExit()
{
	CCLayer::onExit();
}

void SFRichLabel::appendText(const char* text,int size,const char* color,bool hasEvent,bool isUnderLine,const char* eventStr )
{

	bool hasBreakLine = false;
	std::string colorStr = color;
	ccColor3B colorC =stringToColor(colorStr);
	int fontSize = size;
	std::string fontName = m_defaultFontName;
	std::string inputArray = text;
	CCPoint  drawPoint;
	CCSprite* tempSprite = CCSprite::create();
	CCSpriteBatchNode* tempBatch = NULL;
	int lenght = cc_utf8_strlen(inputArray.c_str(),inputArray.length());
	for (int i = 0;i<lenght;i++)
	{
		const char* start = inputArray.c_str();
		const char* p;
		p =cc_utf8_next_char(start);
		int offset = p-start;
		std::string temp = inputArray.substr(0,offset);
		unsigned short* utf16 = cc_utf8_to_utf16(temp.c_str());
		unsigned int code = utf16[0];
		delete [] utf16;
		inputArray = inputArray.substr(offset);
		if (code  == kNextLine)
		{
			hasBreakLine = this->breakLine();
		}else if (code  ==kReturn)
		{

		}
		else{
			tempSprite = SFSharedFontManager::sharedSFSharedFontManager()->
				getSpriteFromMainTexture(fontName,fontSize,code,temp.c_str());
			if (m_defFontHeight == -1)
			{
				m_defFontHeight = tempSprite->getContentSize().height;
			}
			tempBatch = this->findTheBatchNodeWithTexture(tempSprite->getTexture());
			tempSprite->setColor(colorC);
			adjustPosition(tempSprite,tempBatch,hasBreakLine);
			if (hasEvent)
			{
				addLinkToList(tempSprite,eventStr,isUnderLine);
			}
		}
		
	}
	CCSize tempS = tempSprite->getContentSize();
	m_lastIndex->setPosition(tempSprite->getPosition());
	m_lastIndex->setContentSize(CCSizeMake(tempS.width,m_heightSum));
}

void SFRichLabel::appendImage(std::string& setName,std::string& imageName, std::string& eventStr, float widht,float height )
{
	CCSprite* sprite = CCSprite::createWithSpriteFrameName(imageName.c_str());
	if (!sprite)
	{
		CCLog("Error!SFRichLabel::appendImage with unexist image,%s", imageName.c_str());
		return;
	}
	if (m_spritesNode == NULL)
	{
		m_spritesNode = CCNode::create();
	}
	if (m_spritesNode->getParent() == NULL)
	{
		addChild(m_spritesNode);
	}
	adjustPosition(sprite,m_spritesNode,false);
	CCSize tempS = sprite->getContentSize();
	m_lastIndex->setPosition(sprite->getPosition());
	m_lastIndex->setContentSize(CCSizeMake(tempS.width,m_heightSum));

	if (!eventStr.empty())
	{
		addLinkToList(sprite, eventStr.c_str(), false);
	}
}


void SFRichLabel::repositionAllChildren(CCNode* node,CCPoint offset,bool flag,float curentY)
{
	CCSprite* tempSprite;
	if (node)
	{
		for (int i = 0;i<node->getChildrenCount();i++)
		{
			tempSprite = (CCSprite*)node->getChildren()->objectAtIndex(i);
			CCPoint oldPos = tempSprite->getPosition();
			if (flag)
			{
				if (oldPos.y != curentY)
				{
					tempSprite->setPosition(ccpAdd(oldPos,offset));
				}
			}else{
				tempSprite->setPosition(ccpAdd(oldPos,offset));
			}
		}
	}
}

void SFRichLabel::reposition(CCPoint offset,bool flag,float curentY)
{
	CCSprite* tempSprite;
	for (int i = 0;i<m_batchNodes->count();i++)
	{
		CCSpriteBatchNode* batch = (CCSpriteBatchNode*) m_batchNodes->objectAtIndex(i);
		repositionAllChildren(batch,offset,flag,curentY);
	}
	if (m_spritesNode)
	{
		repositionAllChildren(m_spritesNode,offset,flag,curentY);
	}
}

CCSpriteBatchNode* SFRichLabel::findTheBatchNodeWithTexture(CCTexture2D* tex)
{
	CCSpriteBatchNode* tempBatch = NULL;
	for (int i = 0;i<m_batchNodes->count();i++)
	{
		tempBatch = (CCSpriteBatchNode*)m_batchNodes->objectAtIndex(i);
		if (tempBatch->getTexture() != tex)
		{
			tempBatch = NULL;
		}else{
			break;
		}
	}
	if (tempBatch == NULL)
	{
		CCSpriteBatchNode* batch = new CCSpriteBatchNode();
		batch->autorelease();
		batch->init();
		batch->setTexture(tex);
		ccBlendFunc blendFunc = {GL_ONE,GL_ONE_MINUS_SRC_ALPHA};
		batch->setBlendFunc(blendFunc);
		m_batchNodes->addObject(batch);
		tempBatch = batch;
	}
	return tempBatch;
}

void SFRichLabel::adjustPosition( CCSprite* sprite,CCNode* parent,bool hasbreakLine)
{
	if (!sprite || !parent)
	{
		CCLog("Error!SFRichLabel adjustPosition with error params");
		return;
	}
		
	bool hasBreakLine = hasbreakLine;
	CCPoint drawPoint = CCPointZero;
	float width = m_dimensions.width;
	CCSize tempSize = sprite->getContentSize();
	tempSize.height = tempSize.height+m_gaps;
	if (m_currentMaxHeight < tempSize.height)
	{
		float offset = tempSize.height - m_currentMaxHeight;
		if (m_currentMaxHeight != 0)
		{
			reposition(ccp(0,offset),true,m_lastIndex->getPositionY());
		}
		m_currentMaxHeight = tempSize.height;
	}
	if (m_currentWidth+tempSize.width> width && width > tempSize.width)
	{
		hasBreakLine = this->breakLine();
	}
	float y = 0;
	drawPoint = ccp(m_currentWidth,y);
	sprite->setPosition(drawPoint);
	parent->addChild(sprite);
	sprite->setAnchorPoint(CCPointZero);
	m_currentWidth += tempSize.width;
	if (!hasBreakLine)
	{
		m_WidthSum += tempSize.width;
	}
}

void SFRichLabel::addLinkToList( CCSprite* sprite,const char* data ,bool isUnderLine)
{
	std::string eventStr  = data;
	eventType event = std::make_pair(sprite,isUnderLine);
	m_linkList.insert(std::make_pair(eventStr,event));
}

void SFRichLabel::draw(void)
{
	CCLayer::draw();
	linkIt find;
	for (find = m_linkList.begin();find != m_linkList.end();find++)
	{
		eventType event = find->second;
		bool isUnderLine = event.second;
		if (isUnderLine)
		{
			CCSprite* sprite = event.first;
			CCPoint start = sprite->getPosition();
			CCPoint endPoint = ccp(start.x+sprite->getContentSize().width,start.y);
			kmGLPushMatrix();
			ccColor3B color = sprite->getColor();
			ccDrawColor4F(color.r,color.g,color.b,255);
			ccDrawLine(start,endPoint);
			kmGLPopMatrix();
		}
	}
}

bool SFRichLabel::isTouchIn( CCTouch* pTouch )
{
	if (getParent() == NULL) 
		return false;
	CCPoint touchLocation = pTouch->getLocation(); // Get the touch position
	touchLocation = this->getParent()->convertToNodeSpace(touchLocation);
	CCRect bBox=boundingBox();
	return bBox.containsPoint(touchLocation);
}

void SFRichLabel::registerWithTouchDispatcher( void )
{
	CCTouchDispatcher* pDispatcher = CCDirector::sharedDirector()->getTouchDispatcher();
	pDispatcher->addTargetedDelegate(this,-128,false);
}

void SFRichLabel::ccTouchMoved( CCTouch *pTouch, CCEvent *pEvent )
{

}

void SFRichLabel::ccTouchEnded( CCTouch *pTouch, CCEvent *pEvent )
{

}

void SFRichLabel::ccTouchCancelled( CCTouch *pTouch, CCEvent *pEvent )
{

}

void SFRichLabel::appendAlignmentText( const char* text,std::string type )
{
	float startPosition = 0;
	bool isLeft = true;
	if (type == "right")
	{
		startPosition = m_dimensions.width;
		isLeft = false;
	}else if (type == "left"){

	}
	std::string inputArray = text;
	int lenght = cc_utf8_strlen(inputArray.c_str(),inputArray.length());
	std::list<std::pair<unsigned int,std::string> > codeList;
	for (int i = 0;i<lenght;i++)
	{
		const char* start = inputArray.c_str();
		const char* p;
		p =cc_utf8_next_char(start);
		int offset = p-start;
		std::string temp = inputArray.substr(0,offset);
		unsigned short* utf16 = cc_utf8_to_utf16(temp.c_str());
		unsigned int code = utf16[0];
		delete [] utf16;
		inputArray = inputArray.substr(offset);
		codeList.push_back(std::make_pair(code,temp));
	}
	std::string fontName = m_defaultFontName;
	int fontSize = m_defaultFontSize;
	for (int i = 0;i<lenght;i++)
	{
		std::pair<unsigned int,std::string> temp;
		CCSprite* tempSprite;
		CCSpriteBatchNode* tempBatch;
		float xPosition = 0;
		if (isLeft)
		{
			temp = codeList.front();
			codeList.pop_front();
		}else{
			temp = codeList.back();
			codeList.pop_back();
		}
		tempSprite = SFSharedFontManager::sharedSFSharedFontManager()->
			getSpriteFromMainTexture(fontName,fontSize,temp.first,temp.second.c_str());
		tempBatch = this->findTheBatchNodeWithTexture(tempSprite->getTexture());
		CCSize tempSize = tempSprite->getContentSize();
		if (isLeft)
		{
			if (i!= 0)
			{
				startPosition = startPosition+tempSize.width;
			}
		}else{
			startPosition = startPosition - tempSize.width;
		}
		tempSprite->setAnchorPoint(CCPointZero);
		tempSprite->setPosition(ccp(startPosition,m_lastIndex->getPositionY()));
		tempBatch->addChild(tempSprite);
		if (tempBatch->getParent() == NULL)
		{
			addChild(tempBatch);
		}
	}
}

bool SFRichLabel::breakLine()
{
	reposition(ccp(0,m_currentMaxHeight));
	m_heightSum += m_currentMaxHeight;
	m_currentWidth = 0;
	m_currentMaxHeight = m_defFontHeight;
	return true;
}





