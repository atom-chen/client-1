#ifndef __THIRD_TOOL_H__
#define __THIRD_TOOL_H__

#include "cocos2d.h"


class ThirdTool
{
public:

	static bool IConvConvert(const char *from_charset, const char *to_charset, const char *inbuf, int inlen, char *outbuf, int outlen);
	static std::string IConvConvert_GBKToUTF8(const std::string& str);
	static std::string IConvConvert_UTF8ToGBK(const char* str);
};

#endif