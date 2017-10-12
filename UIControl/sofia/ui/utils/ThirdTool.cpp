#include "ui/utils/ThirdTool.h"

#if(CC_TARGET_PLATFORM != CC_PLATFORM_IOS)
#include "iconv.h"
#endif

static char textOut[2048];

bool ThirdTool::IConvConvert(const char *from_charset, const char *to_charset, const char *inbuf, int inlen, char *outbuf, int outlen) 

{
    
#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    return false;
#else
	iconv_t cd = iconv_open(to_charset, from_charset);

	if (cd == 0) return false;

	const char **pin = &inbuf;

	char **pout = &outbuf;

	memset(outbuf,0,outlen);

	size_t ret = iconv(cd,pin,(size_t *)&inlen,pout,(size_t *)&outlen);

	iconv_close(cd);

	return ret == (size_t)(-1) ? false : true;
#endif
}

std::string ThirdTool::IConvConvert_GBKToUTF8(const std::string& str)
{
    
#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    return "";
#else
	const char* textIn = str.c_str();
	bool ret = IConvConvert("gb2312", "utf-8", textIn, strlen(textIn),textOut, 256);
	return ret ? std::string(textOut) : std::string();
#endif
}

std::string ThirdTool::IConvConvert_UTF8ToGBK(const char* str)
{
    
#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    return "";
#else
	std::string ans;
	int len = strlen(str)*2+1;
	char *dst = (char *)malloc(len);
	if(dst == NULL)
	{
		return ans;
	}
	memset(dst, 0, len);
	const char *in = str;
	char *out = dst;
	size_t len_in = strlen(str);
	size_t len_out = len;
	iconv_t cd = iconv_open("GBK", "UTF-8");
	if ((iconv_t)-1 == cd)
	{
		free(dst);
		return ans;
	}
	int n = iconv(cd, &in, &len_in, &out, &len_out);
	if(n<0)
	{
	}
	else
	{
		ans = dst;
	}
	free(dst);
	iconv_close(cd);
	return ans;
#endif
}