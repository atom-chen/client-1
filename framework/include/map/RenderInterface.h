#ifndef _MAP_I_RENDER_H_
#define _MAP_I_RENDER_H_
#include <string>
namespace cocos2d
{
	class CCTexture2D;
	class CCSprite;
}
namespace cmap
{
	class iShow
	{
	public:
		virtual ~iShow() {}
		virtual void Render() = 0;
		virtual void Clear() = 0;
	};

	class iSpriteShowCell
	{
	public:
		virtual ~iSpriteShowCell() {}
		virtual void CreateId(int order, int drawtype, int flag,int backgroudId, int basisx, int basisy)=0;
		virtual bool Remove(int elemId) = 0;
		//virtual void Clear() = 0;

		virtual bool SetPos(int posx, int posy) = 0;
	};

	class iSpriteShow : public iShow
	{
	public:
		virtual ~iSpriteShow(){}
		virtual void SetViewbegin(int x, int y) = 0;
		virtual iSpriteShowCell* CreateCell() = 0;
		virtual void Release(iSpriteShowCell* cell) = 0;
	};

	class iBackgroundShow : public iShow
	{
	public:
		virtual ~iBackgroundShow(){}
		virtual bool create(int flag, int texture, int gid, int posx, int posy) = 0;
		virtual void create(int flag, cocos2d::CCTexture2D* tex, int gid, int posx, int posy) = 0;
		virtual int CreateDynamic(int falg, int imageId, int posx, int posy) = 0;
		virtual void Remove(int showid) = 0;
		virtual void Clear() = 0;
		virtual void updateTexture(int gid, cocos2d::CCTexture2D* tex) = 0;
	};

	class iImage
	{
	public:
		virtual ~iImage() {}
		static float GetScaleFromFlag(int flag);
		static void SetScaleToFlag(int& flag, float scale);
		static char ScaleToChar(float scale);
		static float ScaleToFloat(char scale);
		static bool GetXTurn(int flag) { return (flag & 0x01) != 0;}
		static bool GetYTurn(int flag) { return (flag & 0x02) != 0;}
		
		static float GetAlphaFromDrawType(int drawtype);
		static void SetAlphaToDrawType(int& drawtype, float alpha);
		static unsigned char AlphaToUChar(float alpha);
		static float AlphaToFloat(unsigned char alpha);

		static int GetEquationExtTypeNum();
		static const char* GetEquationExtTypeName(int index);
		static int GetEquationExt(int drawtype);
		static int GetEquationExtToOpenGL(int drawtype);

		static void SetXYTurn(int& flag, bool x, bool y);
		static void SetEquationExt(int& drawtype, int index);

		static int GetBlendFuncTypeNum();
		static const char* GetSourBlendFuncTypeName(int index);
		static const char* GetDestBlendFuncTypeName(int index);
		static void GetBlendFunc(int drawtype, int& sourceBlend, int& destBlend);
		static void GetBlendFuncToOpenGL(int drawtype, int& sourceBlend, int& destBlend);
		static void SetBlendFunc(int& drawtype, int sourceBlend, int destBlend);

		virtual int GetW() const = 0;
		virtual int GetH() const = 0;
	};

	class iShowManager
	{
	public:
		virtual ~iShowManager() {}
		virtual void SetViewSize(int w, int h) = 0;
		virtual iBackgroundShow* CreateBackground(int order) = 0;
		virtual void DestroyBackground(iBackgroundShow* show) = 0;

		virtual iSpriteShow* CreateSprite(int order) = 0;
		virtual void DestroySprite(iSpriteShow* show) = 0;

		virtual iBackgroundShow* GetBackground(int order) = 0;
		virtual iSpriteShow* GetSprite(int order) = 0;
		virtual void Render() = 0;
		virtual void Clear() = 0;
	};

	class iMapRender
	{
	public:
		virtual ~iMapRender() {}
		virtual void SetShowManager(iShowManager* showManager) = 0;
		virtual iShowManager* GetShowManager() = 0;
	};

	class iImageSetInfo
	{
	public:
		virtual ~iImageSetInfo() {}

		virtual bool SetStaticImage(int id_, const char* imagepath, const char* type) = 0;
		virtual std::string GetStaticImagePath(int id_) = 0;
		virtual bool checkStaticImagePath(int id) = 0;
		virtual void setStaticImage(int id, cocos2d::CCTexture2D* tex) = 0;
		virtual cocos2d::CCTexture2D* getStaticImage(int id) = 0;
		virtual void clearStaticImage(int id) = 0;
		virtual void clearStaticImage() = 0;

		virtual int AddDynamicImage(cocos2d::CCSprite* texture) = 0;
		virtual cocos2d::CCSprite* GetDynamicImage(int id_) = 0;
		virtual bool RemoveDynamicImage(int id_) = 0;
		virtual void ClearDynamicImage() = 0;

	};

	class iMapFactory
	{
	public:
		virtual ~iMapFactory() {}
		virtual iMapRender* GetRender(int id) = 0;
		virtual iImageSetInfo* GetImageSetInfo() = 0;
		static iMapFactory* inst;

		enum
		{
			eRender_Map = 0xFFFFFFFF,
			eRender_Middle_Map = 0x0101,
		};
	};
}

#endif
