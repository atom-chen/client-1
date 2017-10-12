// 通用全局函数
#ifndef COMMONUTILITY_H
#define COMMONUTILITY_H

#include "ccMacros.h"

unsigned long long swap64Bit(unsigned long long val);


#define HOST2NET_16(val)  ((CC_HOST_IS_BIG_ENDIAN == true)? (val) : CC_SWAP16(val) )
#define NET2HOST_16(val)  ((CC_HOST_IS_BIG_ENDIAN == true)? (val) : CC_SWAP16(val) )
#define HOST2NET_32(val)  ((CC_HOST_IS_BIG_ENDIAN == true)? (val) : CC_SWAP32(val) ) //hton_32(val)
#define NET2HOST_32(val)  ((CC_HOST_IS_BIG_ENDIAN == true)? (val) : CC_SWAP32(val) ) //ntoh_32(val)
#define HOST2NET_64(val)  ((CC_HOST_IS_BIG_ENDIAN == true)? (val) : swap64Bit(val) ) //hton_64(val)
#define NET2HOST_64(val)  ((CC_HOST_IS_BIG_ENDIAN == true)? (val) : swap64Bit(val) ) //ntoh_64(val)

#endif