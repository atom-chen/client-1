#include "sofia.h"
#include "include/utils/SFStringUtil.h"
#include <algorithm>
#include <time.h>
#include <stdio.h>
#include "ui/utils/ThirdTool.h"

//-----------------------------------------------------------------------
	const String SFStringUtil::BLANK;


	//-----------------------------------------------------------------------
    void SFStringUtil::trim(String& str, bool left, bool right)
    {
        /*
        size_t lspaces, rspaces, len = length(), i;

        lspaces = rspaces = 0;

        if( left )
        {
            // Find spaces / tabs on the left
            for( i = 0;
                i < len && ( at(i) == ' ' || at(i) == '\t' || at(i) == '\r');
                ++lspaces, ++i );
        }
        
        if( right && lspaces < len )
        {
            // Find spaces / tabs on the right
            for( i = len - 1;
                i >= 0 && ( at(i) == ' ' || at(i) == '\t' || at(i) == '\r');
                rspaces++, i-- );
        }

        *this = substr(lspaces, len-lspaces-rspaces);
        */
        static const String delims = " \t\r";
        if(right)
            str.erase(str.find_last_not_of(delims)+1); // trim right
        if(left)
            str.erase(0, str.find_first_not_of(delims)); // trim left
    }

    //-----------------------------------------------------------------------
    std::vector<String> SFStringUtil::split( const String& str, const String& delims, unsigned int maxSplits)
    {
        std::vector<String> ret;
        // Pre-allocate some space for performance
        ret.reserve(maxSplits ? maxSplits+1 : 10);    // 10 is guessed capacity for most case

        unsigned int numSplits = 0;

        // Use STL methods 
        size_t start, pos;
        start = 0;
        do 
        {
            pos = str.find_first_of(delims, start);
            if (pos == start)
            {
                // Do nothing
                start = pos + 1;
            }
            else if (pos == String::npos || (maxSplits && numSplits == maxSplits))
            {
                // Copy the rest of the string
                ret.push_back( str.substr(start) );
                break;
            }
            else
            {
                // Copy up to delimiter
                ret.push_back( str.substr(start, pos - start) );
                start = pos + 1;
            }
            // parse up to next real data
            start = str.find_first_not_of(delims, start);
            ++numSplits;

        } while (pos != String::npos);



        return ret;
    }

	void SFStringUtil::split( const String& str, std::vector< int > &vec, const String& delims /*= ","*/, unsigned int maxSplits /*= 0*/ )
	{
		// Pre-allocate some space for performance
		vec.reserve(maxSplits ? maxSplits+1 : 10);    // 10 is guessed capacity for most case

		unsigned int numSplits = 0;

		// Use STL methods 
		size_t start, pos;
		start = 0;
		int v = 0;
		do 
		{
			pos = str.find_first_of(delims, start);
			if (pos == start)
			{
				// Do nothing
				start = pos + 1;
			}
			else if (pos == String::npos || (maxSplits && numSplits == maxSplits))
			{
				// the rest of the string
				if ( sscanf( str.substr(start).c_str(), "%d", &v ) == 1 )
				{
					vec.push_back( v );
				}
				
				break;
			}
			else
			{
				// Copy up to delimiter
				if ( sscanf( str.substr(start, pos - start).c_str(), "%d", &v ) == 1 )
				{
					vec.push_back( v );
				}
				start = pos + 1;
			}
			// parse up to next real data
			start = str.find_first_not_of(delims, start);
			++numSplits;

		} while (pos != String::npos);

	}

    //-----------------------------------------------------------------------
    void SFStringUtil::toLowerCase(String& str)
    {
        std::transform(
            str.begin(),
            str.end(),
            str.begin(),
			tolower);
    }

    //-----------------------------------------------------------------------
    void SFStringUtil::toUpperCase(String& str) 
    {
        std::transform(
            str.begin(),
            str.end(),
            str.begin(),
			toupper);
    }
    //-----------------------------------------------------------------------
    bool SFStringUtil::startsWith(const String& str, const String& pattern, bool lowerCase)
    {
        size_t thisLen = str.length();
        size_t patternLen = pattern.length();
        if (thisLen < patternLen || patternLen == 0)
            return false;

        String startOfThis = str.substr(0, patternLen);
        if (lowerCase)
            SFStringUtil::toLowerCase(startOfThis);

        return (startOfThis == pattern);
    }
    //-----------------------------------------------------------------------
    bool SFStringUtil::endsWith(const String& str, const String& pattern, bool lowerCase)
    {
        size_t thisLen = str.length();
        size_t patternLen = pattern.length();
        if (thisLen < patternLen || patternLen == 0)
            return false;

        String endOfThis = str.substr(thisLen - patternLen, patternLen);
        if (lowerCase)
            SFStringUtil::toLowerCase(endOfThis);

        return (endOfThis == pattern);
    }
    //-----------------------------------------------------------------------
    String SFStringUtil::standardisePath(const String& init)
    {
        String path = init;

        std::replace( path.begin(), path.end(), '\\', '/' );
        if( path[path.length() - 1] != '/' )
            path += '/';

        return path;
    }
    //-----------------------------------------------------------------------
    void SFStringUtil::splitFilename(const String& qualifiedName, 
        String& outBasename, String& outPath)
    {
        String path = qualifiedName;
        // Replace \ with / first
        std::replace( path.begin(), path.end(), '\\', '/' );
        // split based on final /
        size_t i = path.find_last_of('/');

        if (i == String::npos)
        {
            outPath.clear();
			outBasename = qualifiedName;
        }
        else
        {
            outBasename = path.substr(i+1, path.size() - i - 1);
            outPath = path.substr(0, i+1);
        }

    }
    //-----------------------------------------------------------------------
    bool SFStringUtil::match(const String& str, const String& pattern, bool caseSensitive)
    {
        String tmpStr = str;
		String tmpPattern = pattern;
        if (!caseSensitive)
        {
            SFStringUtil::toLowerCase(tmpStr);
            SFStringUtil::toLowerCase(tmpPattern);
        }

        String::const_iterator strIt = tmpStr.begin();
        String::const_iterator patIt = tmpPattern.begin();
		String::const_iterator lastWildCardIt = tmpPattern.end();
        while (strIt != tmpStr.end() && patIt != tmpPattern.end())
        {
            if (*patIt == '*')
            {
				lastWildCardIt = patIt;
                // Skip over looking for next character
                ++patIt;
                if (patIt == tmpPattern.end())
				{
					// Skip right to the end since * matches the entire rest of the string
					strIt = tmpStr.end();
				}
				else
                {
					// scan until we find next pattern character
                    while(strIt != tmpStr.end() && *strIt != *patIt)
                        ++strIt;
                }
            }
            else
            {
                if (*patIt != *strIt)
                {
					if (lastWildCardIt != tmpPattern.end())
					{
						// The last wildcard can match this incorrect sequence
						// rewind pattern to wildcard and keep searching
						patIt = lastWildCardIt;
						lastWildCardIt = tmpPattern.end();
					}
					else
					{
						// no wildwards left
						return false;
					}
                }
                else
                {
                    ++patIt;
                    ++strIt;
                }
            }

        }
		// If we reached the end of both the pattern and the string, we succeeded
		if (patIt == tmpPattern.end() && strIt == tmpStr.end())
		{
        	return true;
		}
		else
		{
			return false;
		}

	}

	bool SFStringUtil::isEqual( const char* str1, const char* str2 )
	{
		if (str1 == NULL || str2 == NULL)
			return false;
		return strcmp(str1, str2) == 0;
	}


	static char szBuf[1024];
	String SFStringUtil::formatString( const char* fmt , ... )
	{
	
		va_list ap;
		va_start(ap, fmt);
		vsprintf(szBuf,  fmt, ap);
		va_end(ap);
		return String(szBuf);
	}

	String SFStringUtil::formatStringUtf8( const char* fmt , ... )
	{
		va_list ap;
		va_start(ap, fmt);
		vsprintf(szBuf,  fmt, ap);
		va_end(ap);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 ||  CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
            return ThirdTool::IConvConvert_GBKToUTF8(szBuf);
#else
        return String(szBuf);
#endif

	}

	String SFStringUtil::formatStringDate( long long time )
	{
		time_t m_time = time;
		struct tm* local;
		local = localtime(&m_time);

		char buf[255];
		strftime(buf, 255, "%Y-%m-%d %H:%M:%S", local);


		return String(buf);
	}

	String SFStringUtil::itoa( int value )
	{
		return SFStringUtil::formatString("%d", value);
	}

	bool SFStringUtil::toInt( const char* str, int* value )
	{
		if ( sscanf( str, "%d", value ) == 1 ) {
			return true;
		}
		return false;
	}

	bool SFStringUtil::toUnsigned( const char* str, unsigned *value )
	{
		if ( sscanf( str, "%u", value ) == 1 ) {
			return true;
		}
		return false;
	}

	bool SFStringUtil::toBool( const char* str, bool* value )
	{
		int ival = 0;
		if ( toInt( str, &ival )) {
			*value = (ival==0) ? false : true;
			return true;
		}

		std::string testStr = str;
		toLowerCase(testStr);
		if ( isEqual( testStr.c_str(), "true" ) ) {
			*value = true;
			return true;
		}
		else if ( isEqual( testStr.c_str(), "false" ) ) {
			*value = false;
			return true;
		}
		return false;
	}

	bool SFStringUtil::toFloat( const char* str, float* value )
	{
		if ( sscanf( str, "%f", value ) == 1 ) {
			return true;
		}
		return false;
	}

	bool SFStringUtil::toDouble( const char* str, double* value )
	{
		if ( sscanf( str, "%lf", value ) == 1 ) {
			return true;
		}
		return false;
	}

	bool SFStringUtil::toInt16( const char* str, int* value )
	{
		if ( sscanf( str, "%x", value ) == 1 ) {
			return true;
		}
		return false;
	}

	bool SFStringUtil::toLongLong( const char* str, long long* value )
	{
		if (sscanf( str, "%lld", value) == 1){
			return true;
		}

		return false;
	}

	StringList SFStringUtil::compare( const char* str, const char* compareSymbol )
	{
		StringList stringList;
		std::string pOri = str;
		int index = pOri.find(compareSymbol);
		int subIndex = 0;
		while(index != std::string::npos){
			std::string result = pOri.substr(0, index);
			stringList.push_back(result);
			
			pOri = pOri.substr(index+1);
			index = pOri.find(compareSymbol);
		}
		return stringList;
	}

	int SFStringUtil::getUTF8CharacterLength( const char* p, int len )
	{
		int ret = 0;

		if (len >= 6 && (*p & 0xfe) == 0xfc 
			&& (*(p+1) & 0xc0) == 0x80
			&& (*(p+2) & 0xc0) == 0x80
			&& (*(p+3) & 0xc0) == 0x80
			&& (*(p+4) & 0xc0) == 0x80
			&& (*(p+5) & 0xc0) == 0x80) 
		{
			ret = 6;
		}
		else if (len >= 5 && (*p & 0xfc) == 0xf8 
			&& (*(p+1) & 0xc0) == 0x80
			&& (*(p+2) & 0xc0) == 0x80
			&& (*(p+3) & 0xc0) == 0x80
			&& (*(p+4) & 0xc0) == 0x80) 
		{
			ret = 5;
		}
		else if(len >= 4 && (*p & 0xf8) == 0xf0 
			&& (*(p+1) & 0xc0) == 0x80
			&& (*(p+2) & 0xc0) == 0x80
			&& (*(p+3) & 0xc0) == 0x80) 
		{
			ret = 4;
		}
		else if (len >= 3 && (*p & 0xf0) == 0xe0 
			&& (*(p+1) & 0xc0) == 0x80
			&& (*(p+2) & 0xc0) == 0x80)
		{
			ret = 3;
		}
		else if( len >= 2 && (*p & 0xe0) == 0xc0 
			&& (*(p+1) & 0xc0) == 0x80) {
			ret = 2;
		}
		else if (*p < 0x80)
		{
			// 英文或者数字
			ret = 1;
		}

		return ret;
	}

	std::vector<int> SFStringUtil::getUTF8StringSplitInfo( const char* pText )
	{
		std::vector<int> splitInfo;
		if (!pText)
			return splitInfo;

		splitInfo.clear();

		const char* pStr = pText;
		int len = strlen(pText);
		int strLen  = 0;
		while (*pStr != '\0')
		{
			strLen = getUTF8CharacterLength(pStr, len);
			if (strLen == 0)
				break;

			if (splitInfo.empty())
				splitInfo.push_back(strLen);
			else
				splitInfo.push_back(splitInfo.back()+strLen);

			len -= strLen;
			pStr+=strLen;
		}

		return splitInfo;
	}

	String SFStringUtil::lltoa( long long value )
	{
		return formatString("%lld", value);
	}

	String SFStringUtil::convertBreakLine( const char* pszText )
	{
		String ret;

		if (pszText)
		{
			ret = replaceAll(pszText, "\\n", "\n");
		}

		return ret;
	}

	String SFStringUtil::replaceAll( const char* pszText, const char* pszSrc, const char* pszDest )
	{
		String ret;

		if (pszText && pszSrc && pszDest)
		{
			ret = pszText;
			std::string::size_type pos = 0;
			std::string::size_type srcLen = strlen(pszSrc);
			std::string::size_type desLen = strlen(pszDest);
			pos = ret.find(pszSrc, pos); 
			while ((pos != std::string::npos))
			{
				ret = ret.replace(pos, srcLen, pszDest);
				pos = ret.find(pszSrc, (pos+desLen));
			}
		}

		return ret;
	}

	int SFStringUtil::stringCount( const char* pTex )
	{
		return getUTF8StringSplitInfo(pTex).size();
	}

	cocos2d::ccColor3B SFStringUtil::string2Color( const char* pColorText )
	{
		std::string strColor = pColorText;
		std::string strR = strColor.substr(0, 2);
		std::string strG = strColor.substr(2, 2);
		std::string strB = strColor.substr(4, 2);
		unsigned char intR = convertFromHex(strR);
		unsigned char intG = convertFromHex(strG);
		unsigned char intB = convertFromHex(strB);
		return ccc3(intR, intG, intB);		
	}

	unsigned char SFStringUtil::convertFromHex( std::string hex )
	{
		int value = 0;
		int a = 0;
		int b = hex.length() - 1;
		for (; b >= 0; a++, b--)
		{
			if (hex[b] >= '0' && hex[b] <= '9')
			{
				value += (hex[b] - '0') * (1 << (a * 4));
			}
			else
			{
				switch (hex[b])
				{
				case 'A':
				case 'a':
					value += 10 * (1 << (a * 4));
					break;

				case 'B':
				case 'b':
					value += 11 * (1 << (a * 4));
					break;

				case 'C':
				case 'c':
					value += 12 * (1 << (a * 4));
					break;

				case 'D':
				case 'd':
					value += 13 * (1 << (a * 4));
					break;

				case 'E':
				case 'e':
					value += 14 * (1 << (a * 4));
					break;

				case 'F':
				case 'f':
					value += 15 * (1 << (a * 4));
					break;

				default:
					break;
				}
			}
		}

		return value;
	}
