/********************************************************************
文件名:Base64Code.h
创建者:yangtianxiang
创建时间:2013-6-25 17:46
功能描述:base64加密解密
*********************************************************************/

#ifndef __BASE64CODE_H__
#define __BASE64CODE_H__

#include <string>

class Base64Code
{
public:
	static std::string decode(std::string const& encodeString);
	static std::string encode(unsigned char const* bytes_to_encode, unsigned int in_len);
private:
	static inline bool is_base64(unsigned char c) { return (isalnum(c) || (c == '+') || (c == '/'));} 
};

#endif //__BASE64CODE_H__