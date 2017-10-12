
#ifndef __ENGINEMARCROS_H__
#define __ENGINEMARCROS_H__

#define NS_CC_ENG_BEGIN                     namespace cocos2d { //namespace eng { 
#define NS_CC_ENG_END                       }//}
#define USING_NS_CC_ENG                     using namespace cocos2d//::eng

int GetVarArgs_A( char* dest, int count, const char*& fmt );
#define __CLAMP(value, min, max) \
	if (value < min) value = min; \
	else if (value > max) value = max

#define __MIN(a, b) (a < b ? a : b)
#define __MAX(a, b) (a > b ? a : b)
typedef signed char			int8;
typedef unsigned char		uint8;
typedef signed short		int16;
typedef unsigned short		uint16;
typedef signed int			int32;
typedef unsigned int		uint32;

#endif

