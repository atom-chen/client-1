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

#ifndef _SFRichEditZ_h__h__
#define _SFRichEditZ_h__h__

#include "SFBaseControl.h"
#include <list>
#include "SFSharedFontManager.h"

typedef void (CCObject::*SFRichBoxCallback)(CCObject*, const char* pData);

class SFRichBox : public SFBaseControl
{
public:
	SFRichBox();
	virtual ~SFRichBox();

	static SFRichBox* create() 
	{ 
		SFRichBox *pRet = new SFRichBox(); 
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
	*  exp : @text=this is a test\r\n asdasdsa;font=aaa;size=20;color=FF66FF;data=item_103_403@
	*  exp:  @image=UI$createBg;autoscale=1@
	*/
	void appendFormatText(const char* pText);

	/*
	* 清理所有的内容
	*/
	void clearAll();

	void setClickHandle(CCObject* object, SFRichBoxCallback callback);

protected: CCSize m_dimensions;
public: virtual CCSize getDimensions(void);
public: virtual void setDimensions(CCSize var);

private:
	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	bool onTouch(CCTouch* pTouch);
	virtual bool init();

private:

	void StringReplace(std::string &strBase, std::string strSrc, std::string strDes);


	void clear();

	void parseText(const char* pText);
	bool saveValue(SFSharedFontManager::uFormatData* format, const char* key, const char* value);

	bool isTextFormatKey(const char* key);
	bool isImageFormatKey(const char* key);

	int convertFromHex(std::string& hex);
	ccColor3B stringToColor(std::string& str);


	// 把drawList的超链接的信息保存到eventList
	void divertDrawList();

	struct stTextInfo;
	struct stDrawInfo;

	virtual void onEnter();
	virtual void onExit();

private:
	// 事件的数据，都用字符串保存在data里面
	struct stEventData
	{
		int eventId;
		std::string data;
	};
	int m_prevEventId;

	// 每一块文字的纹理和信息
	struct stTextInfo
	{
		ccColor3B		color;
		// rect的height是当前行的height
		// texture的现实区域
		float			scale;
		stEventData*	data;
	};
	CCArray* m_batchNodes;
	// 保存参与绘制的stTextInfo
	std::list<stTextInfo*> m_drawList;

	// 保存记录超链接信息的stTextInfo，但不包括texture
	std::list<stTextInfo*> m_eventList;


	std::list<stDrawInfo*> m_drawTextureList;
	std::list<SFSharedFontManager::uFormatData> m_formatList;
	CCRect m_rectLast;

	SFRichBoxCallback m_callback;	// 回调函数
	CCObject* m_callbackHandler;	// 回调的Object

	ccBlendFunc        m_sBlendFunc;

	// vertex coords, texture coords and color info
	ccV3F_C4B_T2F_Quad m_sQuad;

	// opacity and RGB protocol
	ccColor3B m_sColorUnmodified;
	CCSprite* m_lastIndex;
};

#endif // _SFRichEditZ_h__h__