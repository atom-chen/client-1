#ifndef _CURL_EASY_UTILS_H_
#define _CURL_EASY_UTILS_H_

namespace curlutils
{
#ifdef  WIN32
	wchar_t *ansiToWideChar(const char* str);
#endif
	void ensureDirectoryExists( const char* pszDir );
};

#endif