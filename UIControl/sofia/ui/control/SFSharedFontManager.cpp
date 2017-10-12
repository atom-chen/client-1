#include "ui/control/SFSharedFontManager.h"
#define kNextLine 10
#define  kTab 9
#define  kReturn 13
#define  kOffset 2
//¥¶¿Ì◊÷∑˚±‡¬Î∑Ω∑®∫Õ∫�?
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


int getOffset(int size)
{
	return size/4;
}

SFSharedFontManager::fontData SFSharedFontManager::FontMapRender::addTextureToMainTexture( const char* string,unsigned int code,int page)
{
	fontData data;
	//»Áπ˚”–ø’”‡Œª÷√æÕÃÌº�?
	if (hasFreeSpace())
	{
		//…˙≥…Œ∆¿Ì
		CCTexture2D* texture = new CCTexture2D();
		texture->autorelease();
		bool rect = false;
		CCImage* pImage = new CCImage();
		do 
		{
			CC_BREAK_IF(NULL == pImage);
			// #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
			//	rect = pImage->initWithStringShadowStroke(string,  0,0, CCImage::kAlignTop, "Arial",m_size,1,1,1,false,0,0,0,0,true,1,1,1,1);
			//#else
			//	rect = pImage->initWithString(string,  0,0, CCImage::kAlignTop, "Arial",m_size);
			//#endif
			rect = pImage->initWithString(string,  0,0, CCImage::kAlignTop, "Arial",m_size);
			CC_BREAK_IF(!rect);
			rect = texture->initWithImage(pImage);
		} while (0);
		CC_SAFE_RELEASE(pImage);

		CCSize tSize = texture->getContentSize();
		data.showW = tSize.width;
		data.showH = tSize.height;
		int offset =  4;
		float tempWidth = m_size+offset;
		float tempHeight = tSize.height+4;
		if (m_size >= 22)
		{
			tempWidth = m_size+m_size/2;
		}
		CCSize tempSize = CCSizeMake(tempWidth,tempHeight);
		if(!m_renderTexture)
		{
			m_renderTexture = CCRenderTexture::create(kTextureWidth,kTextureHeight,kCCTexture2DPixelFormat_RGBA8888);
			m_renderTexture->getSprite()->getTexture()->setAntiAliasTexParameters();
			CC_SAFE_RETAIN(m_renderTexture);
		}
		int maxRow = kTextureHeight/tempSize.height;
		int maxCol = kTextureWidth/tempSize.width;
		//≥ı ºªØ“ª¥Œ◊Ó¥Û◊¯±Í”√”⁄≈–∂œ «∑Ò”–ø’”‡ø’º�?
		if (m_full == -1)
		{
			m_full = maxRow*maxCol;
		}
		int currentCol = m_index%maxCol;
		int currentRow = m_index/maxCol;
		// ”√rendertexture ∞—–°Õºª≠…œ»�?
		m_renderTexture->begin();
		if (rect)
		{
			int width = currentCol*tempSize.width;

			int height = currentRow*tempSize.height;
			texture->drawAtPoint(ccp(width,height));
		}
		m_renderTexture->end();
		//m_renderTexture->getSprite()->getTexture()->setAliasTexParameters();
		data.tex = m_renderTexture->getSprite()->getTexture();
		int index =  m_index;
		data.index =index;
		data.w = tempSize.width;
		data.h = tempSize.height;
		data.page= page;
		m_index++;
		m_fontIndexMap[code] = data;
	}
	return data;
}

bool SFSharedFontManager::FontMapRender::hasFreeSpace()
{
	if (m_full == -1)
	{
		return true;
	}
	return m_index < m_full;
}

SFSharedFontManager::FontMapRender::FontMapRender( int size ):m_size(size)
{
	m_renderTexture = NULL;
	m_index = 0;
	m_full = -1;
}

SFSharedFontManager::FontMapRender::~FontMapRender()
{
	CC_SAFE_RELEASE_NULL(m_renderTexture);
}

SFSharedFontManager::fontData SFSharedFontManager::FontMapRender::getFontInfoWithCodePair( unsigned int code )
{
	fontData data;
	FontIndexMap::iterator find;
	find =m_fontIndexMap.find(code);
	if (find != m_fontIndexMap.end())
	{
		data = find->second;
	}else{
		data.index = -1;
	}
	return data;
}

SFSharedFontManager::fontData SFSharedFontManager::getFontInfo(std::string font,  int size,unsigned int code,const char* string)
{
	fontData data = {};
	//std::string newFont("Helvetica");
	//font = newFont;


	int keySize = size;
	CCString* key = CCString::createWithFormat("%d",keySize);
	FontMapRenderManager* object = (FontMapRenderManager* )m_renderDic->objectForKey(key->getCString());
	//»Áπ˚◊÷µ‰÷–’“≤ªµΩ æÕ–¬Ω®“ª∏ˆ
	if (object == NULL)
	{
		object = new FontMapRenderManager(size);
		object->autorelease();
		m_renderDic->setObject(object,key->getCString());
	}
	data = object->getFontInfoWithCodePair(code);
	//»Áπ˚ «–¬Œ∆¿ÌæÕÃÌº”µΩ¥ÛÕ�?
	if (data.index == -1)
	{	
		data = object->addTextureToMainTexture(string,code);
	}
	return data;
}

static SFSharedFontManager*g_sharedFontManager = NULL;

SFSharedFontManager* SFSharedFontManager::sharedSFSharedFontManager()
{
	if (!g_sharedFontManager)
	{
		g_sharedFontManager =  new SFSharedFontManager();
	}
	return g_sharedFontManager;
}

void SFSharedFontManager::destroySFSharedFontManager()
{
	if (g_sharedFontManager)
	{
		delete g_sharedFontManager;
		g_sharedFontManager = NULL;
	}
}

SFSharedFontManager::SFSharedFontManager()
{
	m_renderDic = CCDictionary::create();
	CC_SAFE_RETAIN(m_renderDic);
}

SFSharedFontManager::~SFSharedFontManager()
{
	CC_SAFE_RELEASE_NULL(m_renderDic);
}

//get the character texture with index
CCSprite * SFSharedFontManager::getSpriteFromMainTextureWithFontData(fontData data)
{
	//∏˘æ›font data …Ë÷√ΩÿÕºrect
	int maxCol = kTextureWidth/data.w;
	int currentCol = data.index%maxCol;
	int currentRow = data.index/maxCol;
	CCRect box;
	box.origin.x = currentCol*data.w;
	box.origin.y = currentRow*data.h;
	box.size.width = data.showW;
	box.size.height = data.showH;
	CCSprite *sprite =CCSprite::createWithTexture(data.tex,box);

	sprite->setFlipY(true);
	return sprite;
}

void SFSharedFontManager::repositionWithArrayOfSprite(CCArray* sprites,CCPoint offset,bool flag,float curentY)
{
	CCSprite* tempSprite;
	for (int i =0;i<sprites->count();i++)
	{
		tempSprite = (CCSprite*) sprites->objectAtIndex(i);
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

CCSpriteBatchNode* SFSharedFontManager::findTheBatchNodeWithTexture(CCTexture2D* tex,CCArray* batches,unsigned int lenght)
{
	CCSpriteBatchNode* tempBatch = NULL;
	for (int i = 0;i<batches->count();i++)
	{
		tempBatch = (CCSpriteBatchNode*)batches->objectAtIndex(i);
		if (tempBatch->getTexture() != tex)
		{
			tempBatch = NULL;
		}else{
			break;
		}
	}
	if (tempBatch == NULL)
	{
		CCSpriteBatchNode* batch;
		if (lenght > 20)
		{
			batch = CCSpriteBatchNode::createWithTexture(tex,lenght);
		}else{
			batch = CCSpriteBatchNode::createWithTexture(tex);
		}
		ccBlendFunc func = {GL_ONE,GL_ONE_MINUS_SRC_ALPHA};
		batch->setBlendFunc(func);
		batches->addObject(batch);
		tempBatch = batch;
	}
	return tempBatch;
}


CCSize SFSharedFontManager::updateRichTextBatchNodeSprite( std::list<uFormatData> formatList,CCArray* batches,CCSize dimension,CCSprite* last)
{
	CCSize returnSize = CCSizeZero;
	int size= formatList.size();
	if (size != 0)
	{
		float heightSum = last->getContentSize().height;
		float currentMaxHeight = 0;
		float showW = last->getPositionX()+last->getContentSize().width;
		float widthSum = last->getPositionX()+last->getContentSize().width;
		bool hasBreakLine = false;
		CCArray* addedSprite = CCArray::create();
		CCPoint  drawPoint;
		CCSprite* tempSprite = CCSprite::create();
		CCSpriteBatchNode* tempBatch = NULL;
		std::list<uFormatData>::iterator  find;
		for (int i =0;i<batches->count();i++)
		{
			tempBatch =(CCSpriteBatchNode*) batches->objectAtIndex(i);
			CCArray* children = tempBatch->getChildren();
			addedSprite->addObjectsFromArray(children);
		}
		for (find = formatList.begin();find != formatList.end();find++)
		{
			uFormatData formatData = (*find);

			if (formatData.textFormat)
			{
				if (formatData.textFormat->text != "")
				{
					if (!formatData.textFormat->font.empty() )
					{
						std::string font("Arial");
						formatData.textFormat->font = font;
					}
					if(formatData.textFormat->fontSize == 0)
						formatData.textFormat->fontSize = 12;
					ccColor3B color =formatData.textFormat->color;
					int fontSize = formatData.textFormat->fontSize;
					std::string fontName = formatData.textFormat->font;
					std::string inputArray =  formatData.textFormat->text;

					int lenght = cc_utf8_strlen(inputArray.c_str(),inputArray.length());
					for (int i = 0;i<lenght;i++)
					{
						const char* start = inputArray.c_str();
						const char* p;
						p = cc_utf8_next_char(start);
						int offset = p-start;
						std::string temp = inputArray.substr(0,offset);
						unsigned short* utf16 = cc_utf8_to_utf16(temp.c_str());
						unsigned int code = utf16[0];
						delete [] utf16;
						inputArray = inputArray.substr(offset);
						if (code  == kNextLine)
						{
							repositionWithArrayOfSprite(addedSprite,ccp(0,currentMaxHeight));
							heightSum += currentMaxHeight;
							showW = 0;
							hasBreakLine  = true; 
							currentMaxHeight = 0;
						}else if (code  ==kReturn || code == kTab)
						{

						}
						else{
							fontData data = getFontInfo(fontName,fontSize,code,temp.c_str());
							tempBatch = findTheBatchNodeWithTexture(data.tex,batches,lenght);

							tempSprite = getSpriteFromMainTextureWithFontData(data);
							tempSprite->setAnchorPoint(CCPointZero);
							tempSprite->setColor(color);
							addedSprite->addObject(tempSprite);
							float width = dimension.width;
							CCSize tempSize = tempSprite->getContentSize();
							if (currentMaxHeight < tempSize.height)
							{
								float offset = tempSize.height - currentMaxHeight;
								if (currentMaxHeight != 0)
								{
									repositionWithArrayOfSprite(addedSprite,ccp(0,offset),true,last->getPositionY());
								}
								currentMaxHeight = tempSize.height;
							}
							if (showW+tempSize.width> width && width > tempSize.width)
							{
								repositionWithArrayOfSprite(addedSprite,ccp(0,currentMaxHeight));
								heightSum += currentMaxHeight;
								showW = 0;
								hasBreakLine  = true; 
								currentMaxHeight = 0;
							}
							float y = 0;
							drawPoint = ccp(showW,y);
							tempSprite->setPosition(drawPoint);
							tempBatch->addChild(tempSprite);
							tempSprite->setAnchorPoint(CCPointZero);
							showW += tempSize.width;
							if (!hasBreakLine)
							{
								widthSum += tempSize.width;
							}
						}
					}
				}
			}else if (formatData.imageFormat)
			{
				CCRect rect = CCRectMake(0,0,formatData.imageFormat->width,formatData.imageFormat->height);
				CCSpriteFrame* imageFrame = CCSpriteFrameCache::sharedSpriteFrameCache()
					->spriteFrameByName(formatData.imageFormat->imageFrameName.c_str());
				CCSprite* imageSprite = CCSprite::createWithSpriteFrame(imageFrame);
				imageSprite->setAnchorPoint(CCPointZero);

			}
		}
		CCSize tempS = tempSprite->getContentSize();
		last->setPosition(tempSprite->getPosition());

		last->setContentSize(CCSizeMake(tempS.width,heightSum));
		if (dimension.width != 0 && dimension.width > tempS.width)
		{
			returnSize.width = dimension.width ;
		}else{
			returnSize.width = widthSum;
		}
		returnSize.height = hasBreakLine?(heightSum+currentMaxHeight):(heightSum == 0?currentMaxHeight:heightSum+currentMaxHeight);
	}
	return returnSize;
}

CCSize SFSharedFontManager::updateBatchNodeSprite( CCArray* batches,std::string font, int size,std::string input,CCSize dimension,ccColor3B color)
{

	if (!input.empty())
	{
		int row =0;
		float showW = 0;
		float widthSum = 0;
		CCPoint  drawPoint;
		CCSprite* tempSprite = CCSprite::create();
		CCSpriteBatchNode* tempBatch;
		CCSize returnSize;
		//«Âø’‘≠”–æ´¡È£®»Áπ˚”–∏ˆ∂‘±»æ…”– ˝æ›ø…ƒ‹∏¸∫√£©
		for (int i =0;i<batches->count();i++)
		{
			tempBatch =(CCSpriteBatchNode*) batches->objectAtIndex(i);
			tempBatch->removeAllChildren();
		}
		//∑÷∏Ó◊÷∑˚¥Æ
		std::string inputArray = input;
		int lenght = cc_utf8_strlen(inputArray.c_str(),inputArray.length());
		std::string check = inputArray.substr(0,3);
		unsigned short* checkCode = cc_utf8_to_utf16(check.c_str());
		int startIndex =0;
		if (checkCode[0] == 65279)
		{
			inputArray = inputArray.substr(3);
			startIndex = 1;
		}
		delete [] checkCode;
		for (int i = startIndex;i<lenght;i++)
		{
			const char* start = inputArray.c_str();
			const char* p;
			p = cc_utf8_next_char(start);
			int offset = p-start;
			std::string temp = inputArray.substr(0,offset);
			unsigned short* utf16 = cc_utf8_to_utf16(temp.c_str());
			unsigned int code = utf16[0];
			delete [] utf16;
			inputArray = inputArray.substr(offset);
			if (code  == kNextLine)
			{
				row++;
				showW = 0;
				continue;
			}else if (code  ==kReturn || code == kTab)
			{

			}else{
				fontData data = getFontInfo(font,size,code,temp.c_str());

				tempSprite = getSpriteFromMainTextureWithFontData(data);
				tempBatch =findTheBatchNodeWithTexture(tempSprite->getTexture(), batches,lenght);

				tempSprite = getSpriteFromMainTextureWithFontData(data);
				tempSprite->setAnchorPoint(CCPointZero);
				tempSprite->setColor(color);
				float width = dimension.width;
				CCSize tempSize = tempSprite->getContentSize();
				float height = dimension.height == 0?tempSize.height: dimension.height;
				if (showW+tempSize.width> width && width > tempSize.width)
				{
					row++;
					showW = 0;
				}
				float y = height- (row+1)*tempSize.height;
				drawPoint = ccp(showW,y);
				tempSprite->setPosition(drawPoint);
				tempBatch->addChild(tempSprite);
				tempSprite->setAnchorPoint(CCPointZero);
				showW += tempSize.width;
				if (row == 0)
				{
					widthSum += tempSize.width;
				}
			}
		}
		CCSize tempS = tempSprite->getContentSize();

		if (dimension.width != 0 && dimension.width > tempS.width)
		{
			returnSize.width = dimension.width ;

		}else{
			returnSize.width = widthSum;
		}
		returnSize.height = row == 0?tempS.height:tempS.height*(row+1);
		return returnSize;
	}
	return CCSizeZero;
}


unsigned int SFSharedFontManager::getFontMapRenderManagerSize( int fontSize )
{
	int keySize = fontSize;
	CCString* key = CCString::createWithFormat("%d",keySize);
	FontMapRenderManager* object = (FontMapRenderManager* )m_renderDic->objectForKey(key->getCString());
	if (object == NULL)
	{
		return 1;
	}
	return object->arraySize();
}

CCSprite* SFSharedFontManager::getSpriteFromMainTexture( std::string font, int size,unsigned int code,const char* string )
{
	fontData data = getFontInfo(font,size,code,string);
	CCSprite* tempSprite = getSpriteFromMainTextureWithFontData(data);

	return tempSprite;
}

CCArray* SFSharedFontManager::getSpriteList( std::string font, int size,const char* str )
{
	std::string inputArray = str;
	CCArray* data = CCArray::create();
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

		}else if (code  ==kReturn)
		{

		}
		else{
			CCSprite* tempSprite = SFSharedFontManager::sharedSFSharedFontManager()->
				getSpriteFromMainTexture(font,size,code,temp.c_str());
			data->addObject(tempSprite);
		}
	}
	return data;
}

SFSharedFontManager::FontMapRenderManager::FontMapRenderManager(int size)
{
	m_currentIndex = 0;
	m_size = size;
	m_renders = CCArray::create();
	FontMapRender* render = new FontMapRender(size);
	render->autorelease();
	m_renders->addObject(render);
	CC_SAFE_RETAIN(m_renders);
}

unsigned int SFSharedFontManager::FontMapRenderManager::arraySize()
{
	return m_renders->count();
}

bool SFSharedFontManager::FontMapRenderManager::hasFreeSpaceInCurrentIndex()
{
	FontMapRender* render = getCurrentRender();
	return render->hasFreeSpace();
}

void SFSharedFontManager::FontMapRenderManager::addNewFontMapRender()
{
	FontMapRender* render = new FontMapRender(m_size);
	render->autorelease();
	m_renders->addObject(render);
	m_currentIndex++;
}

SFSharedFontManager::fontData SFSharedFontManager::FontMapRenderManager::addTextureToMainTexture( const char* string,unsigned int code )
{
	FontMapRender* render = getCurrentRender();
	//»Áπ˚µ±«∞◊÷ÃÂ‰÷»æ∆˜√ªø’”‡ø’º‰µƒª∞–¬Ω®“ª∏ˆ
	if (!render->hasFreeSpace())
	{
		addNewFontMapRender();
		render = getCurrentRender();
	}
	return render->addTextureToMainTexture(string,code,m_currentIndex);
}

SFSharedFontManager::FontMapRender* SFSharedFontManager::FontMapRenderManager::getCurrentRender()
{
	FontMapRender* render = (FontMapRender*)m_renders->objectAtIndex(m_currentIndex);
	return render;
}

SFSharedFontManager::FontMapRenderManager::~FontMapRenderManager()
{
	CC_SAFE_RELEASE_NULL(m_renders);
}

SFSharedFontManager::fontData SFSharedFontManager::FontMapRenderManager::getFontInfoWithCodePair( unsigned int code )
{
	FontMapRender* render;
	fontData data;
	data.index = -1;
	for (int i =0;i<arraySize();i++)
	{
		render = (FontMapRender*)m_renders->objectAtIndex(i);
		data = render->getFontInfoWithCodePair(code);
		if (data.index != -1)
		{
			i = arraySize();
		}
	}
	return data;
}