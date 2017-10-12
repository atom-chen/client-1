#ifndef SFSHAREDFONTMANAGER_H
#define SFSHAREDFONTMANAGER_H
/********************************************************************
�ļ���:SFSharedFontManager.h
������:Zhan XianBo
����ʱ��:2013-9-17
��������:���������ͼ����
*********************************************************************/


#include "cocos2d.h"
USING_NS_CC;

#define kTextureWidth				256 //���ɴ�����Ŀ��
#define kTextureHeight				256//������߶�

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
		int page; //�ڼ�ҳ��ͼ
		int index;//��ͼ����Сͼ������(�øߺͿ�ȥ��)
		int w;//��ͼ�Ŀ��
		int h;//��ͼ�ĸ߶�
		int showW;//Сͼ����ʾ�����Ӣ����ĸ����ʾ��ȱ���ͼ���С
		int showH;
		CCTexture2D* tex;//��ͼ
	};
	typedef std::pair<unsigned int,std::string> CodePair; 
	typedef std::map<unsigned int, fontData> FontIndexMap;

	fontData getFontInfo(std::string font,  int size,unsigned int code,const char* string);
	//config
	fontData getFontInfo(int font,  int size,unsigned int code,const char* string);
	//���� 
	CCSize updateBatchNodeSprite(CCArray* batches,std::string font, int size,std::string input,CCSize dimension,ccColor3B color);
	CCSize updateRichTextBatchNodeSprite(std::list<uFormatData> formatList,CCArray* batches,CCSize dimension,CCSprite* last);
	//�õ�ָ��fontsize�м�������
	unsigned int getFontMapRenderManagerSize(int fontSize);
	//����ʵ��
	static SFSharedFontManager* sharedSFSharedFontManager();
	static void  destroySFSharedFontManager();
	CCSprite* getSpriteFromMainTexture(std::string font,  int size,unsigned int code,const char* string);
	CCArray* getSpriteList(std::string font, int size,const char* str);
private:
	//װ������������������ֵ䣬�������Сȥ����
	CCDictionary* m_renderDic;
	//ͨ���������������õ���ͼ�е�����Сͼ������һ������
	CCSprite * getSpriteFromMainTextureWithFontData(fontData data);
	//���µ��������ﾫ�������
	void repositionWithArrayOfSprite(CCArray* sprites,CCPoint offset,bool flag = false,float curentY = -1);
	//����texture����batchnode
	CCSpriteBatchNode* findTheBatchNodeWithTexture(CCTexture2D* tex,CCArray* batches,unsigned int lenght);
	SFSharedFontManager();
	virtual ~SFSharedFontManager();
	//������Ⱦ��
	class FontMapRender: public CCObject
	{
		CCRenderTexture* m_renderTexture;//->texture
		int m_index;//��ǰ��������
		int m_full;//��ǰ��Ⱦ���������
		int m_size;//��ǰ��Ⱦ�������С
		FontIndexMap m_fontIndexMap;//��ǰ��Ⱦ��������������
	public:
		FontMapRender(int size);
		virtual ~FontMapRender();
		//��һ��Сͼ
		fontData addTextureToMainTexture(const char* string,unsigned int code,int page);
		bool hasFreeSpace();
		fontData getFontInfoWithCodePair(unsigned int code);
	};
	//������Ⱦ������ ÿ�ִ�Сһ��������
	class FontMapRenderManager: public CCObject
	{
	private:
		CCArray* m_renders;
		int m_currentIndex;
		int m_size;
		// ��⵱ǰ������Ⱦ���Ƿ��п���λ��
		bool hasFreeSpaceInCurrentIndex();
		//���һ���µ�������Ⱦ��������
		void addNewFontMapRender();
		//���ص�ǰ��ʹ�õ���Ⱦ��
		FontMapRender* getCurrentRender();
	public:
		FontMapRenderManager(int size);
		virtual ~FontMapRenderManager();
		// ���һ���µ��ַ�����ͼ
		fontData addTextureToMainTexture(const char* string,unsigned int code);
		// ��ȡһ���ַ�������
		fontData getFontInfoWithCodePair(unsigned int code);
		//���ص�ǰ�м�������
		unsigned int arraySize();
	};
};


#endif