/********************************************************************
	created:	2013/09/25
	created:	25:9:2013   17:31
	filename: 	E:\Sophia\client\trunk\framework\sofia\utils\StreamDataAdapter.h
	file path:	E:\Sophia\client\trunk\framework\sofia\utils
	file base:	StreamDataAdapter
	file ext:	h
	author:		Liu Rui
	
	purpose:	c++和lua直接传递复杂数据的适配器
*********************************************************************/

#ifndef StreamDataAdapter_h__
#define StreamDataAdapter_h__

#include <string>

namespace cocos2d{
	class iBinaryReader;
	class iBinaryWriter;
};

using namespace cocos2d;

class StreamDataAdapter
{
public:
	//write method
	static void WriteChar(iBinaryWriter* writer, signed char value);
	static void WriteUChar(iBinaryWriter* writer, unsigned char value);
	static void WriteShort(iBinaryWriter* writer, signed short value);
	static void WriteUShort(iBinaryWriter* writer, unsigned short value);
	static void WriteInt(iBinaryWriter* writer, signed int value);
	static void WriteUInt(iBinaryWriter* writer, unsigned int value);
	static void WriteFloat(iBinaryWriter* writer, float value);
	static void WriteLLong(iBinaryWriter* writer, signed long long value);
	static void WriteULLong(iBinaryWriter* writer, unsigned long long value);
	static void WriteStr(iBinaryWriter* writer, const char* value);

	// read method
	static signed char			ReadChar(iBinaryReader* reader);
	static unsigned char		ReadUChar(iBinaryReader* reader);
	static signed short			ReadShort(iBinaryReader* reader);
	static unsigned short		ReadUShort(iBinaryReader* reader);
	static signed int			ReadInt(iBinaryReader* reader);
	static unsigned int			ReadUInt(iBinaryReader* reader);
	static float				ReadFloat(iBinaryReader* reader);
	static char*				ReadStr(iBinaryReader* reader);
	static signed long long		ReadLLong(iBinaryReader* reader);
	static unsigned long long	ReadULLong(iBinaryReader* reader);
};

#endif // StreamDataAdapter_h__