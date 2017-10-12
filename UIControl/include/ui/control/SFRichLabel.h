/********************************************************************
created:	2013/04/18
created:	18:4:2013   20:36
filename: 	E:\jiuxian\client_sulation\trunk\framework\sofia\ui\SFRichEdit.h
file path:	E:\jiuxian\client_sulation\trunk\framework\sofia\ui
file base:	SFRichEdit
file ext:	h
author:		Liu Rui
Editor:			Zhan XianBo
purpose:	富文本控件
*********************************************************************/

#ifndef _SFRichLabel_h__h__
#define _SFRichLabel_h__h__

#include "SFBaseControl.h"
#include <list>
#include "SFSharedFontManager.h"

typedef void (CCObject::*SFRichLabelCallback)(CCObject*, const char* pData);
typedef std::pair<CCSprite*,bool> eventType;
typedef std::multimap<std::string,eventType>::iterator  linkIt;
class SFRichLabel : public SFBaseControl
{
public:
	SFRichLabel();
	virtual ~SFRichLabel();

	static SFRichLabel* create() 
	{ 
		SFRichLabel *pRet = new SFRichLabel(); 
		if (pRet && pRet->init()) 
		{ 
			pRet->autorelease(); 
			return pRet; 
		} 
		else 
		{ 
			delete pRet; 
			pRet = NULL; 
			return NULL; 
		} 
	}

	/*
	*  添加指定格式的文本
	*  
	*/
	void appendFormatText(const char* pText);
	 virtual void draw(void);
	/*
	* 清理所有的内容
	*/
	void clearAll();
	void setEventHandler(int nHandler){m_handler = nHandler;};
	void setClickHandle(CCObject* object, SFRichLabelCallback callback);
	void setFont(const char* font){m_defaultFontName = font;};
	void setFontSize(int size){m_defaultFontSize = size; m_defFontHeight=-1;};
	void setGaps(float gaps){m_gaps = gaps;};
	float getGaps(){return m_gaps;};
protected: CCSize m_dimensions;
public: virtual CCSize getDimensions(void);
public: virtual void setDimensions(CCSize var);
		virtual void registerWithTouchDispatcher(void);
private:
	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);
	bool onTouch(CCTouch* pTouch);
	virtual bool init();
	
private:
	struct stImageFormat;
	struct stTextFormat;
	struct uFormatData;
	void StringReplace(std::string &strBase, std::string strSrc, std::string strDes);
	bool isTouchIn(CCTouch* pTouch);
	void clear();

	void parseText(const char* pText);
	bool saveValue(uFormatData* format, const char* key, const char* value);
	void appendText(const char* text,int size,const char* color,bool hasEvent = false,bool isUnderLine = false,const char* eventStr = "" );
	void appendImage(std::string& setName,std::string& imageName, std::string& eventStr, float widht,float height);
	void appendAlignmentText(const char* text,std::string type);
	void addLinkToList(CCSprite* sprite,const char* data,bool isUnderLine);
	int convertFromHex(std::string& hex);
	ccColor3B stringToColor(std::string& str);

	CCSpriteBatchNode* findTheBatchNodeWithTexture(CCTexture2D* tex);
	void reposition(CCPoint offset,bool flag = false,float curentY= -1);
	void repositionAllChildren(CCNode* node,CCPoint offset,bool flag,float curentY);
	void adjustPosition(CCSprite* sprite,CCNode* parent,bool hasbreakLine);
	bool breakLine();
	virtual void onEnter();
	virtual void onExit();

private:
	// 事件的数据，都用字符串保存在data里面
	struct stEventData
	{
		int eventId;
		std::string data;
	};

	struct stTextFormat
	{
		stTextFormat():
			text(""),font("Arial"),fontSize(16),color(ccWHITE){};
		std::string text;
		std::string font;
		int fontSize;
		ccColor3B color;
		std::string data;
	};

	struct stImageFormat
	{
		std::string setName;
		std::string imageFrameName;
		float width;
		float height;
	};

	struct uFormatData
	{
		stTextFormat* textFormat;
		stImageFormat* imageFormat;
	};
	int m_prevEventId;

	CCArray* m_batchNodes;
	CCSpriteBatchNode* m_imageBatch;

	const char* m_defaultFontName;
	int m_defaultFontSize;
	ccBlendFunc        m_sBlendFunc;
	
	std::multimap<std::string,eventType> m_linkList;
	CCNode* m_spritesNode;
	CCSprite* m_lastIndex;
	float m_currentMaxHeight;
	float m_heightSum;
	float m_currentWidth;
	float m_WidthSum;
	int m_handler;
	float m_gaps;
	int m_defFontHeight;
};


#endif // _SFRichEditZ_h__h__