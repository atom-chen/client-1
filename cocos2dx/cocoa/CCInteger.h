#ifndef __CCINTEGER_H__
#define __CCINTEGER_H__

#include "CCObject.h"

NS_CC_BEGIN

/**
 * @addtogroup data_structures
 * @{
 */

class CC_DLL CCInteger : public CCObject
{
public:
	CCInteger(int v)
		: m_nValue(v) {}
	int getValue() const {return m_nValue;}

	static CCInteger* create(int v)
	{
		CCInteger* pRet = new CCInteger(v);
		pRet->autorelease();
		return pRet;
	}
	int m_nValue;
private:
	
};

// end of data_structure group
/// @}

NS_CC_END

#endif /* __CCINTEGER_H__ */
