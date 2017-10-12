#include "CommonUtility.h"

unsigned long long swap64Bit(unsigned long long val)
{
	return (val & 0xFF) << 56 | 
		(val >> 8 & 0xFF) << 48 |
		(val >> 16 & 0xFF) << 40 |
		(val >> 24 & 0xFF) << 32 |
		(val >> 32 & 0xFF) << 24 |
		(val >> 40 & 0xFF) << 16 |
		(val >> 48 & 0xFF) << 8 |
		(val >> 56 & 0xFF) ;
}
