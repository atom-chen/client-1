#include "cocos2d.h"
#include "map/RenderCocos.h"
#include <algorithm>

#include "ccShaders.h"
#include "ShaderMacro.h"

#include "stream/iStream.h"
#include "stream/MemoryStream.h"
//#include "map/RenderImage.h"

using namespace cocos2d;

namespace cmap
{
/*
	p1   -> p2
		\
		\
	p0  ->  p3
*/
static const GLfloat s_def_coordinates[] = {    
	0.0f,   0.0f,
	1.0f,	0.0f,
	0.0f,   1.0f,
	1.0f,	1.0f };

#define SET_COORDINATES(coord_array, imgW, imgH, coord) {\
	float _l = coord!=NULL ? coord[0]/(float)imgW : 0.f;\
	float _t = coord!=NULL ? coord[1]/(float)imgH : 0.f;\
	float _r = coord!=NULL ? coord[2]/(float)imgW : 1.f;\
	float _b = coord!=NULL ? coord[3]/(float)imgH : 1.f;\
	coord_array[0] = _l;\
	coord_array[1] = _t;\
	coord_array[2] = _r;\
	coord_array[3] = _t;\
	coord_array[4] = _l;\
	coord_array[5] = _b;\
	coord_array[6] = _r;\
	coord_array[7] = _b;}

	CCMapRender::CCMapRender( )
	{
		ccShaderCache = 0;
	}

	CCMapRender::~CCMapRender()
	{
	}

	void CCMapRender::CalVertice( float (&vertices)[8], int imgW, int imgH, int x, int y, int* coord /*= NULL*/, bool turnx /*= false*/, bool turny /*= false*/, float scale /*= 1.0f*/ )
	{

		float drawW = coord!=NULL ? coord[2]-coord[0]: imgW;
		float drawH = coord!=NULL ? coord[3]-coord[1]: imgH;
		drawH = drawH * scale;
		drawW = drawW * scale;

		float toleft	= turnx ? (x + drawW): (x);
		float toright	= turnx ? (x) : (x + drawW);
		float totop		= turny ? (y + drawH) : (y);
		float tobottom	= turny ? (y) : (y + drawH);

		toleft = ceilf(toleft);
		toright = ceilf(toright);
		totop = ceilf(totop);
		tobottom = ceilf(tobottom);

		vertices[0] = toleft;
		vertices[1] = totop;

		vertices[2] = toright;
		vertices[3] = totop;

		vertices[4] = toleft;
		vertices[5] = tobottom;

		vertices[6] = toright;
		vertices[7] = tobottom;

	}

	void CCMapRender::CalColor( float (&colors)[16], int color )
	{
		float a,r,g,b;
		CalColor(r,g,b,a, color);

		colors[0] = colors[4] = colors[8] = colors[12] = r;
		colors[1] = colors[5] = colors[9] = colors[13] = g;
		colors[2] = colors[6] = colors[10] = colors[14] = b;
		colors[3] = colors[7] = colors[11] = colors[15] = a;
	}

	void CCMapRender::CalColor( float &red, float& green, float& blue, float &alpha, int color )
	{
		red = ((color & 0xff000000) >> 24) * 1.0f/ 255;
		green = ((color & 0x00ff0000) >> 16) * 1.0f/ 255;
		blue = ((color & 0x0000ff00) >> 8) * 1.0f/ 255;
		alpha = (color & 0x0ff) * 1.0f/ 255;
	}

#define SET_RGBA_COLOR(c4, color) {\
	(c4[0]) = ((color & 0xff000000) >> 24) * 1.0f/ 255;\
	(c4[1]) = ((color & 0x00ff0000) >> 16) * 1.0f/ 255;\
	(c4[2]) = ((color & 0x0000ff00) >> 8) * 1.0f/ 255;\
	(c4[3]) = (color & 0x0ff) * 1.0f/ 255;}

	void CCMapRender::RenderColorImageImp( cocos2d::CCTexture2D* image, int basisx, int basisy, int tox, int toy, int color )
	{
		cocos2d::CCTexture2D* mt = image;
		if (mt == 0)
		{
			return;
		}
		int imgW = image->getPixelsWide();
		int imgH = image->getPixelsHigh();

		GLfloat vertices[8] = {0};
		CalVertice(vertices, imgW, imgH, tox-basisx, toy-basisy);

		GLfloat pSquareColors[16] = {0.f};
		CalColor(pSquareColors, color);

		//shader
		cocos2d::CCShaderCache* ccsc = this->GetShaderCache();
		cocos2d::CCGLProgram* pg = ccsc->programForKey(kCCShader_PositionTextureColor);
		pg->use();
		//pg->setUniformForModelViewProjectionMatrix();
		pg->setUniformsForBuiltins();
		//绑定纹理
		ccGLBindTexture2D( mt->getName() );
		int sblend = GL_SRC_ALPHA;
		int dblend = GL_ONE_MINUS_SRC_ALPHA;
		ccGLBlendFunc(sblend, dblend);

		//绑定格式
		ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );
		glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
		glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, s_def_coordinates);
		glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, 0, pSquareColors);

		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		ccGLBindTexture2D( 0 );
		ccGLBlendResetToCache();

		CC_INCREMENT_GL_DRAWS(1);
		CHECK_GL_ERROR_DEBUG();
	}


	void CCMapRender::RenderLineImp( int x1, int y1, int x2, int y2, int color )
	{
		float a,r,g,b;
		r = ((color & 0xff000000) >> 24) * 1.0f/ 255;
		g = ((color & 0x00ff0000) >> 16) * 1.0f/ 255;
		b = ((color & 0x0000ff00) >> 8) * 1.0f/ 255;
		a = (color & 0x0ff) * 1.0f/ 255;
		ccDrawColor4F(r, g, b, a);
		ccDrawLine(CCPoint(x1, y1), CCPoint(x2, y2));
	}

	void CCMapRender::RenderRectImp( int x1, int y1, int x2, int y2, int color, bool solid )
	{
		if (solid)
		{
			ccColor4F scolor;   
			scolor.r = ((color & 0xff000000) >> 24) * 1.0f/ 255;
			scolor.g = ((color & 0x00ff0000) >> 16) * 1.0f/ 255;
			scolor.b = ((color & 0x0000ff00) >> 8) * 1.0f/ 255; 
			scolor.a = (color & 0x0ff) * 1.0f/ 255;   
			ccDrawSolidRect(CCPoint(x1, y1), CCPoint(x2, y2), scolor);
		}
		else
		{
			this->RenderLineImp(x1, y1, x2, y1, color);
			this->RenderLineImp(x2, y1, x2, y2, color);
			this->RenderLineImp(x2, y2, x1, y2, color);
			this->RenderLineImp(x1, y2, x1, y1, color);
		}
	}

	void CCMapRender::RenderMapImage( cocos2d::CCTexture2D* img,int drawtype, int flag, int tox, int toy )
	{
		int imgW = img->getPixelsWide();
		int imgH = img->getPixelsHigh();

		GLfloat vertices[8] = {0};
		CalVertice(vertices, imgW, imgH, tox, toy, NULL,
			cmap::iImage::GetXTurn(flag), cmap::iImage::GetYTurn(flag), cmap::iImage::GetScaleFromFlag(flag));

		{
			ccGLBindTexture2D(img->getName());

			static cocos2d::CCGLProgram* pg = CCMapRender::GetShaderCache()->programForKey(engShader_PositionTextureAlpha);
			pg->use();
			pg->setUniformsForBuiltins();

			float configAlpha = cmap::iImage::GetAlphaFromDrawType(drawtype);
			GLint alphaHandle = glGetUniformLocation(pg->getProgram(), engUniformAlpha);
			pg->setUniformLocationWith1f( alphaHandle, configAlpha );

			GLint colorHandle = glGetUniformLocation(pg->getProgram(), engUniformColor);
			float fColor[4] = {1.f,1.f,1.f,1.f};
			//SET_RGBA_COLOR(fColor, color);
			pg->setUniformLocationWith4fv(colorHandle, fColor, 1);

			//混合源
			//-------------------------------------------------------------------------------------------------------------
			int sblend = GL_SRC_ALPHA;
			int dblend = GL_ONE_MINUS_SRC_ALPHA;
			cmap::iImage::GetBlendFuncToOpenGL(drawtype, sblend, dblend);
			ccGLBlendFunc(sblend, dblend);
			//混合方程
			int blendEquation = cmap::iImage::GetEquationExtToOpenGL(drawtype);
			glBlendEquation( blendEquation);
			//-------------------------------------------------------------------------------------------------------------
		}
		//GLubyte tmpColor[4] = { 255, 255, 255, 255 };
		ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords);
		glVertexAttribPointer(cocos2d::kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
		glVertexAttribPointer(cocos2d::kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, s_def_coordinates);
		//glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, tmpColor);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		ccGLBlendResetToCache();

		CC_INCREMENT_GL_DRAWS(1);
		CHECK_GL_ERROR_DEBUG();
	}

	cocos2d::CCShaderCache* CCMapRender::ccShaderCache = 0;

	cocos2d::CCShaderCache* CCMapRender::GetShaderCache()
	{
		if (CCMapRender::ccShaderCache == 0)
		{
			//TODO:新的shader先放在这里，待封装时候包起来

			//shader1
			cocos2d::CCShaderCache* cache = cocos2d::CCShaderCache::sharedShaderCache();
			cocos2d::CCGLProgram *p = new cocos2d::CCGLProgram();
			p->autorelease();
			p->initWithVertexShaderByteArray(ccPositionTextureAlpha_vert ,ccPositionTextureAlpha_frag);
			p->addAttribute(kCCAttributeNamePosition, cocos2d::kCCVertexAttrib_Position);
			p->addAttribute(kCCAttributeNameTexCoord, cocos2d::kCCVertexAttrib_TexCoords);
			p->link();
			p->updateUniforms();
			cache->addProgram(p, engShader_PositionTextureAlpha);

			ccShaderCache = cache;
		}

		return CCMapRender::ccShaderCache;
	}

	CCImageSetInfo::CCImageSetInfo()
	{

	}

	CCImageSetInfo::~CCImageSetInfo()
	{

	}

	CCMapFactory::CCMapFactory()
		: mimagesetinfo(0)
	{
	
	}

	CCMapFactory::~CCMapFactory()
	{
		for (std::vector<CCMapRender*>::iterator itr = this->mmaprenderlist.begin(); itr != this->mmaprenderlist.end(); ++itr)
		{
			delete (*itr);
		}
		mmaprenderlist.clear();
		delete mimagesetinfo;
	}

	iImageSetInfo* CCMapFactory::GetImageSetInfo()
	{
		if (mimagesetinfo == 0)
		{
			mimagesetinfo = new cmap::CCImageSetInfo();
		}
		return mimagesetinfo;
	}

	iMapRender* CCMapFactory::GetRender(int id)
	{
		for (std::vector<CCMapRender*>::iterator itr = this->mmaprenderlist.begin(); itr != this->mmaprenderlist.end(); ++itr)
		{
			CCMapRender* mr = *itr;
			if (mr->id == id)
			{
				return mr;
			}
		}

		ShowManager* sm = new ShowManager();
		CCMapRender* ret = new cmap::CCMapRender();

		ret->SetShowManager(sm);
		ret->id = id;
		this->mmaprenderlist.push_back(ret);
		return ret;
	}
}
