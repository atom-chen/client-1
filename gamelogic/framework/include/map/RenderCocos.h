#ifndef _MAP_COCOS2D_X_RENDER_H_
#define _MAP_COCOS2D_X_RENDER_H_
#include "map/RenderCommon.h"
#include <vector>
#include <map>

namespace cocos2d
{
	class CCTexture2D;
	class CCShaderCache;
}

namespace cmap
{
	struct SRenderImage;

	class CCMapRender : public MapRender
	{
	public:
		CCMapRender();
		virtual ~CCMapRender();

		static cocos2d::CCShaderCache* GetShaderCache();
		static cocos2d::CCShaderCache* ccShaderCache;
		int id;
	public:
		void RenderColorImageImp(cocos2d::CCTexture2D* image,  int basisx, int basisy, int tox, int toy, int color) ;

		void RenderLineImp(int x1, int y1, int x2, int y2, int color);
		void RenderRectImp(int x1, int y1, int x2, int y2, int color, bool solid);

		static void RenderMapImage(cocos2d::CCTexture2D* img,int drawtype, int flag, int tox, int toy);


	protected:
		static void CalVertice(float (&vertices)[8], int imgW, int imgH, int x, int y, int* coord = NULL, bool turnx = false, bool turny = false, float scale = 1.0f);
		void CalColor(float (&colors)[16], int color);
		void CalColor(float &red, float& green, float& blue, float &alpha, int color);
	};

	class CCImageSetInfo: public ImageSetInfo
	{
	public:
		CCImageSetInfo();
		virtual ~CCImageSetInfo();
	protected:
	};

	class CCMapFactory : public iMapFactory
	{
	public:
		CCMapFactory();
		virtual ~CCMapFactory();
		virtual iMapRender* GetRender(int id);
		virtual iImageSetInfo* GetImageSetInfo();
	private:
		CCImageSetInfo* mimagesetinfo;
		std::vector<CCMapRender*> mmaprenderlist;
	};
}

#endif
