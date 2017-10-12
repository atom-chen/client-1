#include "utils/StreamDataAdapter.h"
#include "script_support/CCScriptSupport.h"
#include "stream/iStream.h"

void StreamDataAdapter::WriteChar( iBinaryWriter* writer, signed char value )
{
	if (writer)
		writer->WriteChar(value);
}

void StreamDataAdapter::WriteUChar( iBinaryWriter* writer, unsigned char value )
{
	if (writer)
		writer->WriteUChar(value);
}

void StreamDataAdapter::WriteShort( iBinaryWriter* writer, signed short value )
{
	if (writer)
		writer->WriteShort(value);
}

void StreamDataAdapter::WriteUShort( iBinaryWriter* writer, unsigned short value )
{
	if (writer)
		writer->WriteUShort(value);
}

void StreamDataAdapter::WriteInt( iBinaryWriter* writer, signed int value )
{
	if (writer)
		writer->WriteInt(value);
}

void StreamDataAdapter::WriteUInt( iBinaryWriter* writer, unsigned int value )
{
	if (writer)
		writer->WriteUInt(value);
}

void StreamDataAdapter::WriteFloat( iBinaryWriter* writer, float value )
{
	if (writer)
		writer->WriteFloat(value);
}

void StreamDataAdapter::WriteLLong( iBinaryWriter* writer, signed long long value )
{
	if (writer)
		writer->WriteLLong(value);
}

void StreamDataAdapter::WriteULLong( iBinaryWriter* writer, unsigned long long value )
{
	if (writer)
		writer->WriteULLong(value);
}

void StreamDataAdapter::WriteStr( iBinaryWriter* writer, const char* value )
{
	if (writer && value)
		writer->WriteString(value);
}

signed char StreamDataAdapter::ReadChar( iBinaryReader* reader )
{
	if (reader)
		return reader->ReadChar();
	else
		return 0;
}

unsigned char StreamDataAdapter::ReadUChar( iBinaryReader* reader )
{
	if (reader)
		return reader->ReadUChar();
	else
		return 0;
}

signed short StreamDataAdapter::ReadShort( iBinaryReader* reader )
{
	if (reader)
		return reader->ReadShort();
	else
		return 0;
}

unsigned short StreamDataAdapter::ReadUShort( iBinaryReader* reader )
{
	if (reader)
		return reader->ReadUShort();
	else
		return 0;
}

signed int StreamDataAdapter::ReadInt( iBinaryReader* reader )
{
	if (reader)
		return reader->ReadInt();
	else
		return 0;
}

unsigned int StreamDataAdapter::ReadUInt( iBinaryReader* reader )
{
	if (reader)
		return reader->ReadUInt();
	else
		return 0;
}

float StreamDataAdapter::ReadFloat( iBinaryReader* reader )
{
	if (reader)
		return reader->ReadFloat();
	else
		return 0;
}

char* StreamDataAdapter::ReadStr( iBinaryReader* reader )
{
	if (reader)
	{
		static std::string ret;
		char tmpBuffer[1024] = {0};
		reader->ReadString(tmpBuffer, 1024);
		ret = tmpBuffer;
		return (char*)ret.c_str();
	}
	else
		return "";
}

signed long long StreamDataAdapter::ReadLLong( iBinaryReader* reader )
{
	if (reader)
		return reader->ReadLLong();
	else
		return 0;
}

unsigned long long StreamDataAdapter::ReadULLong( iBinaryReader* reader )
{
	if (reader)
		return reader->ReadULLong();
	else
		return 0;
}
