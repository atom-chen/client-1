/****************************************************************************
 Copyright (c) 2013 cocos2d-x.org
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include "CCTextureETC.h"
#include "CCConfiguration.h"
#include "platform/CCCommon.h"
#include "platform/CCPlatformMacros.h"
#include "platform/CCFileUtils.h"
#include "etc/etc1.h"


NS_CC_BEGIN

CCTextureETC::CCTextureETC()
: _name(0)
, _width(0)
, _height(0)
{}

CCTextureETC::~CCTextureETC()
{
}

bool CCTextureETC::initWithFile(const char *file)
{
    // Only Android supports ETC file format
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    bool ret = loadTexture(CCFileUtils::sharedFileUtils()->fullPathForFilename(file).c_str());
    return ret;
#else
    return false;
#endif
}

unsigned int CCTextureETC::getName() const
{
    return _name;
}

unsigned int CCTextureETC::getWidth() const
{
    return _width;
}

unsigned int CCTextureETC::getHeight() const
{
    return _height;
}

bool CCTextureETC::loadTexture(const char* file)
{
	unsigned long etcFileSize = 0;
	etc1_byte* etcFileData = NULL;
	etcFileData = CCFileUtils::sharedFileUtils()->getFileData(file, "rb", &etcFileSize);

	if(0 == etcFileSize)
	{
		return false;
	}

	if(!etc1_pkm_is_valid(etcFileData))
	{
		delete[] etcFileData;
		etcFileData = NULL;
		return  false;
	}

	_width = etc1_pkm_get_width(etcFileData);
	_height = etc1_pkm_get_height(etcFileData);
	CCLOG("load etc texture %s %d %d", file, _width, _height);
	if( 0 == _width || 0 == _height )
	{
		delete[] etcFileData;
		etcFileData = NULL;
		return false;
	}

	if(CCConfiguration::sharedConfiguration()->supportsETC())
	{
#ifdef GL_ETC1_RGB8_OES
			glGenTextures(1, &_name);
			glBindTexture(GL_TEXTURE_2D, _name);

			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_ETC1_RGB8_OES, _width, _height, 0, etcFileSize - ETC_PKM_HEADER_SIZE,
				etcFileData + ETC_PKM_HEADER_SIZE);

			glBindTexture(GL_TEXTURE_2D, 0);

			delete[] etcFileData;
			etcFileData = NULL;
			return true;
#endif
	}

	return false;
}

NS_CC_END
