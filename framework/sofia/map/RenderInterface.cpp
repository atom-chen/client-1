#include "map/RenderInterface.h"
#ifdef WIN32
	#include "OGLES/GL/glew.h"
#else
#include "platform/CCPlatformConfig.h"
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#else
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#endif

#endif

namespace cmap
{
	iMapFactory* iMapFactory::inst = 0;
	float iImage::GetScaleFromFlag(int flag)
	{
		float scale = 1.0f;
		
		//char默认有无符号是平台和编译器相关的，要自定义申明signed或者unsigned
		signed char scaleint = ((flag & 0x0ff00) >> 8);
		if (scaleint != 0)
		{
			if (scaleint < 0)
			{
				scale = 1 / (1.0f - scaleint * 0.0625f);//-1 + (0, -7.9375) = (-1, -8.9375) 
			}
			else
			{
				scale = 1 + scaleint * 0.0625f;//1 + (0, 7.9375) = (1, 8.9375) 
			}
		}
		return scale;
	}

	void iImage::SetScaleToFlag(int& flag, float scale)
	{
		if (scale > 0.99 && scale < 1.01)
		{
			flag = flag & 0xffff00ff;
			return;
		}

		char scaleint = 0;
		if (scale > 1.0)
		{
			if (scale > 8.9f)
			{
				scale = 8.9f;
			}
			scaleint = (scale - 1) * 16;
		}
		if (scale < 1.0f)
		{
			if (scale < 0.113f)
			{
				scale = 0.113f;
			}
			//scaleint = (1 - 1/scale) * 16;
			scaleint = 16 - 16 / scale;
		}
		flag = flag & 0xffff00ff;
		flag = flag | ((unsigned char)scaleint << 8);
	}

	char iImage::ScaleToChar(float scale)
	{
		if (scale > 0.99f && scale < 1.01f)
		{
			return 0;
		}

		char scaleint = 0;
		if (scale > 1.0f)
		{
			if (scale > 8.9f)
			{
				scale = 8.9f;
			}
			scaleint = (scale - 1) * 16;
		}
		if (scale < 1.0f)
		{
			if (scale < 0.113f)
			{
				scale = 0.113f;
			}
			//scaleint = (1 - 1/scale) * 16;
			scaleint = 16 - 16 / scale;
		}
		return scaleint;
	}

	float iImage::ScaleToFloat(char scaleint)
	{
		float scale = 1.0;
		if (scaleint != 0)
		{
			if (scaleint < 0)
			{
				scale = 1 / (1.0 - scaleint * 0.0625);//-1 + (0, -7.9375) = (-1, -8.9375) 
				//scale = -1.0 * 1/scale;//-1/(-1, -8.9375) = (1, 1/8.9375)
			}
			else
			{
				scale = 1 + scaleint * 0.0625;//1 + (0, 7.9375) = (1, 8.9375) 
			}
		}
		return scale;
	}

	float iImage::GetAlphaFromDrawType(int drawtype)
	{
		unsigned char alpha = drawtype & 0x0ff;
		if (alpha == 0xff)
		{
			return 1.0;
		}
		float alphafloat = alpha * 0.00392157;//0.003921568627450980392156862745098 = 1/255
		return alphafloat;
	}

	void iImage::SetAlphaToDrawType(int& drawtype, float alpha)
	{
		if (alpha <= 0)
		{
			alpha = 0.0001f;
		}
		if (alpha > 0.99999f)
		{
			alpha = 0.99999f;
		}
		unsigned char alphauchar = alpha * 255;
		drawtype = drawtype & 0xffffff00;
		drawtype = drawtype | alphauchar;
	}

	unsigned char iImage::AlphaToUChar(float alpha)
	{
		if (alpha <= 0)
		{
			alpha = 0.0001f;
		}
		if (alpha > 0.99999f)
		{
			alpha = 0.99999f;
		}
		unsigned char alphauchar = alpha * 255;
		return alphauchar;
	}

	float iImage::AlphaToFloat(unsigned char alpha)
	{
		if (alpha == 0xff)
		{
			return 1.0;
		}
		float alphafloat = alpha * 0.00392157;//0.003921568627450980392156862745098 = 1/255
		return alphafloat;
	}
	void iImage::SetXYTurn(int& flag, bool x, bool y) 
	{ 
		if (x) 
		{
			flag = flag | 0x01; 
		}
		else
		{
			flag = flag & 0xfffffffe;
		}
		if (y) 
		{
			flag = flag | 0x02;
		}
		else
		{
			flag = flag & 0xfffffffd;
		}
	}

	static int sEquationExtValue[] = {GL_FUNC_ADD, GL_MIN_EXT, GL_MAX_EXT, GL_FUNC_SUBTRACT, GL_FUNC_REVERSE_SUBTRACT};
	static const char* sEquationExtName[] = {"GL_FUNC_ADD", "GL_MIN_EXT", "GL_MAX_EXT", "GL_FUNC_SUBTRACT", "GL_FUNC_REVERSE_SUBTRACT"};
	static int sEquationExtNum = 5;
	int iImage::GetEquationExtTypeNum()
	{
		return sEquationExtNum;
	}
	
	const char* iImage::GetEquationExtTypeName(int index)
	{
		if (index < sEquationExtNum)
		{
			return sEquationExtName[index];
		}
		return 0;
	}

	int iImage::GetEquationExt(int drawtype)
	{
		return ((drawtype & 0x07000000) >> 24);
	}

	int iImage::GetEquationExtToOpenGL(int drawtype)
	{
		int index = ((drawtype & 0x07000000) >> 24);
		if (index >= sEquationExtNum)
		{
			index = 0;
		}
		return sEquationExtValue[index];
	}
	void iImage::SetEquationExt(int& drawtype, int index)
	{
		drawtype = drawtype & 0xf8ffffff;
		drawtype = drawtype | ((index << 24) & 0x07000000);
	}

	static int sBlendFunNum = 15;
	static int sSourBlendFunValue[] = {
		GL_ONE,
		GL_ZERO,
		GL_SRC_COLOR,
		GL_ONE_MINUS_SRC_COLOR,
		GL_SRC_ALPHA,
		GL_ONE_MINUS_SRC_ALPHA,
		GL_DST_ALPHA,
		GL_ONE_MINUS_DST_ALPHA,
		GL_DST_COLOR,
		GL_ONE_MINUS_DST_COLOR,
		GL_SRC_ALPHA_SATURATE,
		GL_CONSTANT_COLOR,
		GL_ONE_MINUS_CONSTANT_COLOR,
		GL_CONSTANT_ALPHA,
		GL_ONE_MINUS_CONSTANT_ALPHA
	};
	static const char* sSourBlendFunName[] = {
		"GL_ONE",
		"GL_ZERO",
		"GL_SRC_COLOR",
		"GL_ONE_MINUS_SRC_COLOR",
		"GL_SRC_ALPHA",
		"GL_ONE_MINUS_SRC_ALPHA",
		"GL_DST_ALPHA",
		"GL_ONE_MINUS_DST_ALPHA",
		"GL_DST_COLOR",
		"GL_ONE_MINUS_DST_COLOR",
		"GL_SRC_ALPHA_SATURATE",
		"GL_CONSTANT_COLOR",
		"GL_ONE_MINUS_CONSTANT_COLOR",
		"GL_CONSTANT_ALPHA",
		"GL_ONE_MINUS_CONSTANT_ALPHA"
	};
	static int sDestBlendFunValue[] = {
		GL_ONE_MINUS_SRC_ALPHA,
		GL_ZERO,
		GL_ONE,
		GL_SRC_COLOR,
		GL_ONE_MINUS_SRC_COLOR,
		GL_SRC_ALPHA,
		GL_DST_ALPHA,
		GL_ONE_MINUS_DST_ALPHA,
		GL_DST_COLOR,
		GL_ONE_MINUS_DST_COLOR,
		GL_SRC_ALPHA_SATURATE,
		GL_CONSTANT_COLOR,
		GL_ONE_MINUS_CONSTANT_COLOR,
		GL_CONSTANT_ALPHA,
		GL_ONE_MINUS_CONSTANT_ALPHA
	};
	static const char* sDestBlendFunName[] = {
		"GL_ONE_MINUS_SRC_ALPHA",
		"GL_ZERO",
		"GL_ONE",
		"GL_SRC_COLOR",
		"GL_ONE_MINUS_SRC_COLOR",
		"GL_SRC_ALPHA",
		"GL_DST_ALPHA",
		"GL_ONE_MINUS_DST_ALPHA",
		"GL_DST_COLOR",
		"GL_ONE_MINUS_DST_COLOR",
		"GL_SRC_ALPHA_SATURATE",
		"GL_CONSTANT_COLOR",
		"GL_ONE_MINUS_CONSTANT_COLOR",
		"GL_CONSTANT_ALPHA",
		"GL_ONE_MINUS_CONSTANT_ALPHA"
	};
	int iImage::GetBlendFuncTypeNum()
	{
		return sBlendFunNum;
	}

	const char* iImage::GetSourBlendFuncTypeName(int index)
	{
		if (index >= sBlendFunNum)
		{
			index = 0;
		}
		return sSourBlendFunName[index];
	}

	const char* iImage::GetDestBlendFuncTypeName(int index)
	{
		if (index >= sBlendFunNum)
		{
			index = 0;
		}
		return sDestBlendFunName[index];
	}

	void iImage::GetBlendFunc(int drawtype, int& sourceBlend, int& destBlend)
	{
		sourceBlend = (drawtype & 0x000f0000) >> 16;
		destBlend = (drawtype & 0x00f00000) >> 20;
	}

	void iImage::GetBlendFuncToOpenGL(int drawtype, int& sourceBlend, int& destBlend)
	{
		int sourceBlendIndex = (drawtype & 0x000f0000) >> 16;
		int destBlendIndex = (drawtype & 0x00f00000) >> 20;
		if (sourceBlendIndex >= sBlendFunNum)
		{
			sourceBlendIndex = 0;
		}
		if (destBlendIndex >= sBlendFunNum)
		{
			destBlendIndex = 0;
		}
		sourceBlend = sSourBlendFunValue[sourceBlendIndex];
		destBlend = sDestBlendFunValue[destBlendIndex];
	}
	void iImage::SetBlendFunc(int& drawtype, int sourceBlend, int destBlend)
	{
		drawtype = drawtype & 0xff00ffff;
		drawtype = drawtype | ((sourceBlend << 16) & 0x000f0000);
		drawtype = drawtype | ((destBlend << 20) & 0x00f00000);
	}
}
