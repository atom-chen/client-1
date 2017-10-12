#ifndef SFSHAREDFONTMANAGER_H
#define SFSHAREDFONTMANAGER_H
/********************************************************************
文件名:SFSharedFontManager.h
创建者:Zhan XianBo
创建时间:2013-9-17
功能描述:字体大纹理图管理
*********************************************************************/


#include "cocos2d.h"
USING_NS_CC;

#define kTextureWidth				256 //生成大纹理的宽度
#define kTextureHeight				256//大纹理高度

class SFSharedFontManager
{
public:

	struct stTextFormat
	{
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


	struct fontData
	{
		int page; //第几页大图
		int index;//大图里面小图的坐标(用高和宽去求)
		int w;//切图的宽度
		int h;//切图的高度
		int showW;//小图的显示宽度如英文字母等显示宽度比切图宽度小
		int showH;
		CCTexture2D* tex;//大图
	};
	typedef std::pair<unsigned int,std::string> CodePair; 
	typedef std::map<unsigned int, fontData> FontIndexMap;

	fontData getFontInfo(std::string font,  int size,unsigned int code,const char* string);
	//config
	fontData getFontInfo(int font,  int size,unsigned int code,const char* string);
	//更新 
	CCSize updateBatchNodeSprite(CCArray* batches,std::string font, int size,std::string input,CCSize dimension,ccColor3B color);
	CCSize updateRichTextBatchNodeSprite(std::list<uFormatData> formatList,CCArray* batches,CCSize dimension,CCSprite* last);
	//拿到指定fontsize有几张纹理
	unsigned int getFontMapRenderManagerSize(int fontSize);
	//单例实例
	static SFSharedFontManager* sharedSFSharedFontManager();
	static void  destroySFSharedFontManager();
	CCSprite* getSpriteFromMainTexture(std::string font,  int size,unsigned int code,const char* string);
	CCArray* getSpriteList(std::string font, int size,const char* str);
private:
	//装有所有纹理管理器的字典，用字体大小去查找
	CCDictionary* m_renderDic;
	//通过字体索引数据拿到大图中的字体小图并返回一个精灵
	CCSprite * getSpriteFromMainTextureWithFontData(fontData data);
	//重新调整数组里精灵的坐标
	void repositionWithArrayOfSprite(CCArray* sprites,CCPoint offset,bool flag = false,float curentY = -1);
	//根据texture查找batchnode
	CCSpriteBatchNode* findTheBatchNodeWithTexture(CCTexture2D* tex,CCArray* batches,unsigned int lenght);
	SFSharedFontManager();
	virtual ~SFSharedFontManager();
	//纹理渲染器
	class FontMapRender: public CCObject
	{
		CCRenderTexture* m_renderTexture;//->texture
		int m_index;//当前空闲坐标
		int m_full;//当前渲染器最大坐标
		int m_size;//当前渲染器字体大小
		FontIndexMap m_fontIndexMap;//当前渲染器字体索引数据
	public:
		FontMapRender(int size);
		virtual ~FontMapRender();
		//把一个小图
		fontData addTextureToMainTexture(const char* string,unsigned int code,int page);
		bool hasFreeSpace();
		fontData getFontInfoWithCodePair(unsigned int code);
	};
	//纹理渲染管理器 每种大小一个管理器
	class FontMapRenderManager: public CCObject
	{
	private:
		CCArray* m_renders;
		int m_currentIndex;
		int m_size;
		// 检测当前字体渲染器是否有空余位置
		bool hasFreeSpaceInCurrentIndex();
		//添加一个新的字体渲染器到数组
		void addNewFontMapRender();
		//返回当前在使用的渲染器
		FontMapRender* getCurrentRender();
	public:
		FontMapRenderManager(int size);
		virtual ~FontMapRenderManager();
		// 添加一个新的字符到大图
		fontData addTextureToMainTexture(const char* string,unsigned int code);
		// 获取一个字符的数据
		fontData getFontInfoWithCodePair(unsigned int code);
		//返回当前有几个纹理
		unsigned int arraySize();
	};
};


#endif