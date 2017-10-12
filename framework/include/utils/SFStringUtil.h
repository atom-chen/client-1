#ifndef SFStringUtil_h__
#define SFStringUtil_h__

#include <string>
#include <vector>
#include <list>

#include "cocos2d.h"
USING_NS_CC;

typedef std::string	String;
typedef std::list<String> StringList;

 class SFStringUtil
    {
	public:
        typedef std::ostringstream StrStreamType;
		
        /** Removes any whitespace characters, be it standard space or
            TABs and so on.
            @remarks
                The user may specify wether they want to trim only the
                beginning or the end of the String ( the default action is
                to trim both).
        */
        static void trim( String& str, bool left = true, bool right = true );

        /** Returns a StringVector that contains all the substrings delimited
            by the characters in the passed <code>delims</code> argument.
            @param
                delims A list of delimiter characters to split by
            @param
                maxSplits The maximum number of splits to perform (0 for unlimited splits). If this
                parameters is > 0, the splitting process will stop after this many splits, left to right.
        */
		static std::vector< String > split( const String& str, const String& delims = "\t\n ", unsigned int maxSplits = 0);
		static void	split( const String& str, std::vector< int > &vec, const String& delims = ",", unsigned int maxSplits = 0);
        /** Upper-cases all the characters in the string.
        */
        static void toLowerCase( String& str );

        /** Lower-cases all the characters in the string.
        */
        static void toUpperCase( String& str );


        /** Returns whether the string begins with the pattern passed in.
        @param pattern The pattern to compare with.
        @param lowerCase If true, the end of the string will be lower cased before
            comparison, pattern should also be in lower case.
        */
        static bool startsWith(const String& str, const String& pattern, bool lowerCase = true);

        /** Returns whether the string ends with the pattern passed in.
        @param pattern The pattern to compare with.
        @param lowerCase If true, the end of the string will be lower cased before
            comparison, pattern should also be in lower case.
        */
        static bool endsWith(const String& str, const String& pattern, bool lowerCase = true);

        /** Method for standardising paths - use forward slashes only, end with slash.
        */
        static String standardisePath( const String &init);

        /** Method for splitting a fully qualified filename into the base name
            and path.
        @remarks
            Path is standardised as in standardisePath
        */
        static void splitFilename(const String& qualifiedName,
            String& outBasename, String& outPath);

        /** Simple pattern-matching routine allowing a wildcard pattern.
        @param str String to test
        @param pattern Pattern to match against; can include simple '*' wildcards
        @param caseSensitive Whether the match is case sensitive or not
        */
        static bool match(const String& str, const String& pattern, bool caseSensitive = true);


		static bool isEqual(const char* str1, const char* str2);


		static String	formatString(const char* fmt , ...);
		static String	formatStringUtf8(const char* fmt , ...);
		static String	formatStringDate(long long time);

		static String itoa(int value);
		static String lltoa(long long value);

		static bool toInt( const char* str, int* value );
		static bool toUnsigned( const char* str, unsigned *value );
		static bool toInt16( const char* str, int* value );
		static bool toBool( const char* str, bool* value );
		static bool toFloat( const char* str, float* value );
		static bool toDouble( const char* str, double* value );
		static bool toLongLong( const char* str, long long* value);

		static StringList compare(const char* str, const char* compareSymbol);

		// return the length of one utf8 character
		static int getUTF8CharacterLength(const char* p, int len);

		// 返回pText中每一个UTF8字符在字符串中的位置
		static std::vector<int> getUTF8StringSplitInfo(const char* pText);

		// 字符数
		static int stringCount(const char* pTex);

        /// Constant blank string, useful for returning by ref where local does not exist
        static const String BLANK;

		// 把字符串里面的/n转换为换行符
		static String convertBreakLine(const char* pszText);

		// 把pszText的所有的pszSrc替换为pszDest
		static String replaceAll(const char* pszText, const char* pszSrc, const char* pszDest);

		/************************************************************************/
		/* ffffff转成COLOR， 不成功时返回ccc3b(0,0,0)                                                                     */
		/************************************************************************/
		static ccColor3B string2Color(const char* pColorText);
		
	private:
		static unsigned char convertFromHex(std::string hex);
    };

#endif // SFStringUtil_h__