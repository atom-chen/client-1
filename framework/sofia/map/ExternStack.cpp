
#include "map/ExternStack.h"
#include <memory>

#include "platform/CCPlatformConfig.h"
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include <stdlib.h>
#endif
namespace cmap
{
	CExternStackVar::CExternStackVar(unsigned int cbSize)
	{
		m_ptr = (void*)malloc(cbSize);
	}
	CExternStackVar::~CExternStackVar()
	{
		free(m_ptr);
	}

}