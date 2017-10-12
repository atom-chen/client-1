#ifndef DreamStringConverter_h__
#define DreamStringConverter_h__

////#include "DreamPredependencies.h"
////#include "boost\lexical_cast.hpp"

#include "include/utils/CCStrUtil.h"


	class  StrConv
	{
	public:
		StrConv(){}
		~StrConv(){}
	
		public:

        /** Converts a Real to a String. */
        static std::string toString(float val);

        /** Converts an int to a String. */
        static std::string toString(int val);

        /** Converts a size_t to a String. */
        static std::string toString(size_t val);

        /** Converts a long to a String. */
        static std::string toString(long val);

        /** Converts a boolean to a String. 
        @param yesNo If set to true, result is 'yes' or 'no' instead of 'true' or 'false'
        */
        static std::string toString(bool val, bool yesNo = false);
        /////** Converts a ColourValue to a String. 
        ////@remarks
        ////    Format is "r g b a" (i.e. 4x Real values, space delimited). 
        ////*/
        ////static std::string toString(const ColourValue& val);
        ///** Converts a StringVector to a string.
        //@remarks
        //    Strings must not contain spaces since space is used as a delimiter in
        //    the output.
        //*/
        //static std::string toString(const StrVec& val);

		/*
		Converts char* to a String. 
		*/
		static std::string toString(const char* val);

        /** Converts a String to a Real. 
        @returns
            0.0 if the value could not be parsed, otherwise the Real version of the String.
        */
        static float parseReal(const std::string& val, float defaultValue = 0);
        /** Converts a String to a whole number. 
        @returns
            0.0 if the value could not be parsed, otherwise the numeric version of the String.
        */
        static int parseInt(const std::string& val, int defaultValue = 0);
        /** Converts a String to a whole number. 
        @returns
            0.0 if the value could not be parsed, otherwise the numeric version of the String.
        */
        static unsigned int parseUnsignedInt(const std::string& val, unsigned int defaultValue = 0);
        /** Converts a String to a whole number. 
        @returns
            0.0 if the value could not be parsed, otherwise the numeric version of the String.
        */
        static long parseLong(const std::string& val, long defaultValue = 0);
        /** Converts a String to a whole number. 
        @returns
            0.0 if the value could not be parsed, otherwise the numeric version of the String.
        */
        static unsigned long parseUnsignedLong(const std::string& val, unsigned long defaultValue = 0);
        /** Converts a String to a boolean. 
        @remarks
            Returns true if case-insensitive match of the start of the string
			matches "true", "yes" or "1", false otherwise.
        */
        static bool parseBool(const std::string& val, bool defaultValue = 0);
        /////** Parses a ColourValue out of a String. 
        ////@remarks
        ////    Format is "r g b a" (i.e. 4x Real values, space delimited), or "r g b" which implies
        ////    an alpha value of 1.0 (opaque). Failure to parse returns ColourValue::Black.
        ////*/
        ////static ColourValue parseColourValue(const std::string& val, const ColourValue& defaultValue = ColourValue::Black);

        ///** Pareses a StringVector from a string.
        //@remarks
        //    Strings must not contain spaces since space is used as a delimiter in
        //    the output.
        //*/
        //static StrVec parseStringVector(const std::string& val);
        /** Checks the String is a valid number value. */
        static bool isNumber(const std::string& val);
	};


#endif // DreamStringConverter_h__