#include "cocos2d.h"
//#include "EngineMacros.h"
#include "stream/iStream.h"
#include <memory.h>
#include "stream/BinaryReader.h"

namespace cocos2d {

	//using namespace Util;
	//using namespace System;

	//------------------------------------------------------------------------------
	/**
	*/
	BinaryReader::BinaryReader() :
		isOpen(false),
		stream(0),
		deleteStream(true),
		streamWasOpen(false),
		enableMapping(false),
		isMapped(false),
		mapCursor(0),
		mapEnd(0)
	{
		// empty
	}

	//------------------------------------------------------------------------------
	/**
	*/
	BinaryReader::~BinaryReader()
	{
		if (this->IsOpen())
		{
			this->Close();
		}
		if(deleteStream)
			CC_SAFE_DELETE(this->stream);
	}

	//------------------------------------------------------------------------------
	/**
	*/
	bool
	BinaryReader::Open()
	{
		CC_ASSERT(!this->isOpen);
		CC_ASSERT((this->stream != 0));
		CC_ASSERT(this->stream->CanRead());
		if (this->stream->IsOpen())
		{
			CC_ASSERT((this->stream->GetAccessMode() == iStream::ReadAccess) || (this->stream->GetAccessMode() == iStream::ReadWriteAccess));
			this->streamWasOpen = true;
			this->isOpen = true;
		}
		else
		{
			this->streamWasOpen = false;
			this->stream->SetAccessMode(iStream::ReadAccess);
			this->isOpen = this->stream->Open();
		}
		if (this->isOpen)
		{
			if (this->enableMapping && this->stream->CanBeMapped())
			{
				this->isMapped = true;
				this->mapCursor = (unsigned char*) this->stream->Map();
				this->mapEnd = this->mapCursor + this->stream->GetSize();
			}
			else
			{
				this->isMapped = false;
				this->mapCursor = 0;
				this->mapEnd = 0;
			}
			return true;
		}
		return false;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	void
	BinaryReader::Close()
	{
		CC_ASSERT(this->isOpen);
		if ((!this->streamWasOpen) && stream->IsOpen())
		{
			this->stream->Close();
		}
		this->isOpen = false;
		this->isMapped = false;
		this->mapCursor = 0;
		this->mapEnd = 0;
	}
	//------------------------------------------------------------------------------
	/**
		Attaches the reader to a stream. This will imcrement the refcount
		of the stream.
	*/
	void
	BinaryReader::SetStream(iStream* s, bool delStream)
	{
		if (this->stream && this->deleteStream)
		{
			delete this->stream;
		}
		this->stream = s;
		this->deleteStream = delStream;
	}

	//------------------------------------------------------------------------------
	/**
		Get pointer to the attached stream. If there is no stream attached,
		an assertion will be thrown. Use HasStream() to determine if a stream
		is attached.
	*/
	iStream* BinaryReader::GetStream()
	{
		return this->stream;
	}

	//------------------------------------------------------------------------------
	/**
		Returns true if a stream is attached to the reader.
	*/
	bool
	BinaryReader::HasStream() const
	{
		return (this->stream != 0);
	}

	//------------------------------------------------------------------------------
	/**
	*/
	bool
	BinaryReader::Eof() const
	{
		CC_ASSERT(this->IsOpen());
		return this->stream->Eof();
	}

	//------------------------------------------------------------------------------
	/**
	*/
	signed char
	BinaryReader::ReadChar()
	{
		if (this->isMapped)
		{
			CC_ASSERT(this->mapCursor < this->mapEnd);
			return *this->mapCursor++;
		}
		else
		{
			signed char c;
			this->stream->Read(&c, sizeof(c));
			return c;
		}
	}

	//------------------------------------------------------------------------------
	/**
	*/
	unsigned char
	BinaryReader::ReadUChar()
	{
		if (this->isMapped)
		{
			CC_ASSERT(this->mapCursor < this->mapEnd);
			return *this->mapCursor++;
		}
		else
		{
			unsigned char c;
			this->stream->Read(&c, sizeof(c));
			return c;
		}
	}

	//------------------------------------------------------------------------------
	/**
	*/
	signed short
	BinaryReader::ReadShort()
	{
		short val;
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(short)) <= this->mapEnd);        
			//Memory::Copy(this->mapCursor, &val, sizeof(val));
			memcpy(&val, this->mapCursor, sizeof(val));
			this->mapCursor += sizeof(val);
		}
		else
		{
			this->stream->Read(&val, sizeof(val));
		}
		//this->byteOrder.Convert<short>(val);
		return val;
	}

	//------------------------------------------------------------------------------
	/**
	*/ 
	unsigned short
	BinaryReader::ReadUShort()
	{
		unsigned short val;
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(unsigned short)) <= this->mapEnd);
			//Memory::Copy(this->mapCursor, &val, sizeof(val));
			memcpy(&val, this->mapCursor, sizeof(val));
			this->mapCursor += sizeof(val);
		}
		else
		{
			this->stream->Read(&val, sizeof(val));
		}
		//this->byteOrder.Convert<unsigned short>(val);
		return val;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	signed int
	BinaryReader::ReadInt()
	{
		int val;
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(int)) <= this->mapEnd);
			//Memory::Copy(this->mapCursor, &val, sizeof(val));
			memcpy(&val, this->mapCursor, sizeof(val));
			this->mapCursor += sizeof(val);
		}
		else
		{
			this->stream->Read(&val, sizeof(val));
		}
		//this->byteOrder.Convert<int>(val);
		return val;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	unsigned int
	BinaryReader::ReadUInt()
	{
		unsigned int val;
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(unsigned int)) <= this->mapEnd);
			//Memory::Copy(this->mapCursor, &val, sizeof(val));
			memcpy(&val, this->mapCursor, sizeof(val));
			this->mapCursor += sizeof(val);
		}
		else
		{
			this->stream->Read(&val, sizeof(val));
		}
		//this->byteOrder.Convert<unsigned int>(val);
		return val;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	float
	BinaryReader::ReadFloat()
	{
		float val;
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(float)) <= this->mapEnd);
			//Memory::Copy(this->mapCursor, &val, sizeof(val));
			memcpy(&val, this->mapCursor, sizeof(val));
			this->mapCursor += sizeof(val);
		}
		else
		{
			this->stream->Read(&val, sizeof(val));
		}
		//this->byteOrder.Convert<float>(val);
		return val;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	double
	BinaryReader::ReadDouble()
	{
		double val;
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(double)) <= this->mapEnd);
			//Memory::Copy(this->mapCursor, &val, sizeof(val));
			memcpy(&val, this->mapCursor, sizeof(val));
			this->mapCursor += sizeof(val);
		}
		else
		{
			this->stream->Read(&val, sizeof(val));
		}
		//this->byteOrder.Convert<double>(val);
		return val;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	bool
	BinaryReader::ReadBool()
	{
		bool val;
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(bool)) <= this->mapEnd);
			//Memory::Copy(this->mapCursor, &val, sizeof(val));
			memcpy(&val, this->mapCursor, sizeof(val));
			this->mapCursor += sizeof(val);
		}
		else
		{
			this->stream->Read(&val, sizeof(val));        
		}
		return val;
	}

	char* BinaryReader::ReadString(char* tempBuf, unsigned long len)
	{
		unsigned short length = this->ReadUShort();
		if (length == 0)
		{
			return 0;
		}

		if (length >= len )
		{
			length = len - 1;
		}
		if (this->isMapped)
		{
			CC_ASSERT((this->mapCursor + length) <= this->mapEnd);
			//char* str = GetAString1024();
			//Util::String str;
			if (length > 0)
			{
				//str.Reserve(length + 1);
				//Memory::Copy(this->mapCursor, buf, length);
				memcpy(tempBuf, this->mapCursor, length);
				this->mapCursor += length;
				tempBuf[length] = 0;
			}
			return tempBuf;    
		}
		else
		{
			//char* str = GetAString1024();
			//Util::String str;
			if (length > 0)
			{
				//str.Reserve(length + 1);
				//char* buf = (char*) str.AsCharPtr();
				this->stream->Read((void*)tempBuf, length);
				tempBuf[length] = 0;
			}
			return tempBuf;
		}
	}

	//char* BinaryReader::ReadString64k()
	//{
	//	unsigned short length = this->ReadUShort();
	//	if (length == 0)
	//	{
	//		return 0;
	//	}

	//	//64k
	//	if (length > 65535)
	//	{
	//		length = 65535;
	//	}
	//	if (this->isMapped)
	//	{
	//		CC_ASSERT((this->mapCursor + length) <= this->mapEnd);
	//		char* str = GetAString64k();
	//		//Util::String str;
	//		if (length > 0)
	//		{
	//			//str.Reserve(length + 1);
	//			//Memory::Copy(this->mapCursor, buf, length);
	//			memcpy(str, this->mapCursor, length);
	//			this->mapCursor += length;
	//			str[length] = 0;
	//		}
	//		return str;    
	//	}
	//	else
	//	{
	//		char* str = GetAString64k();
	//		//Util::String str;
	//		if (length > 0)
	//		{
	//			//str.Reserve(length + 1);
	//			//char* buf = (char*) str.AsCharPtr();
	//			this->stream->Read((void*)str, length);
	//			str[length] = 0;
	//		}
	//		return str;
	//	}
	//}

	char* BinaryReader::ReadStringNoLen(char* tempBuf, unsigned long len)
	{		
		char* outBuf = tempBuf;
		char* outBufEnd = tempBuf + len - 1;
		if (this->isMapped)
		{
			while (*(this->mapCursor) != 0 && this->mapCursor <= this->mapEnd && outBufEnd <= outBuf)
			{
				*outBuf = *(this->mapCursor);
				++ outBuf;
				++ (this->mapCursor);
			}
			*(outBuf) = 0;
			return tempBuf;    
		}
		else
		{
			char c = 0;
			this->stream->Read(&c, 1);
			while (c != 0 && this->stream->Eof() == false && outBufEnd <= outBuf)
			{
				*outBuf = c;
				++ outBuf;
				this->stream->Read(&c, 1);
			}
			*(outBuf) = 0;
			return tempBuf; 
		}
	}

	////------------------------------------------------------------------------------
	///**
	//*/
	//Util::String
	//BinaryReader::ReadString()
	//{
	//	if (this->isMapped)
	//	{
	//		unsigned short length = this->ReadUShort();
	//		CC_ASSERT((this->mapCursor + length) <= this->mapEnd);
	//		Util::String str;
	//		if (length > 0)
	//		{
	//			str.Reserve(length + 1);
	//			char* buf = (char*) str.AsCharPtr();
	//			//Memory::Copy(this->mapCursor, buf, length);
	//			memcpy(buf, this->mapCursor, length);
	//			this->mapCursor += length;
	//			buf[length] = 0;
	//		}
	//		return str;    
	//	}
	//	else
	//	{
	//		unsigned short length = this->ReadUShort();
	//		Util::String str;
	//		if (length > 0)
	//		{
	//			str.Reserve(length + 1);
	//			char* buf = (char*) str.AsCharPtr();
	//			this->stream->Read((void*)buf, length);
	//			buf[length] = 0;
	//		}
	//		return str;
	//	}
	//}

	////------------------------------------------------------------------------------
	///**
	//*/
	//Util::Blob
	//BinaryReader::ReadBlob()
	//{
	//	SizeT numBytes = this->ReadUInt();
	//	Util::Blob blob(numBytes);
	//	void* ptr = const_cast<void*>(blob.GetPtr());
	//	if (this->isMapped)
	//	{
	//		CC_ASSERT((this->mapCursor + numBytes) <= this->mapEnd);
	//		Memory::Copy(this->mapCursor, ptr, numBytes);
	//		this->mapCursor += numBytes;
	//	}
	//	else
	//	{
	//		this->stream->Read(ptr, numBytes);
	//	}
	//	return blob;
	//}

	////------------------------------------------------------------------------------
	///**
	//*/
	//Util::Guid
	//BinaryReader::ReadGuid()
	//{
	//	Util::Blob blob = this->ReadBlob();
	//	return Util::Guid((const unsigned char*) blob.GetPtr(), blob.Size());
	//}

	////------------------------------------------------------------------------------
	///**
	//*/ 
	//Math::float4
	//BinaryReader::ReadFloat4()
	//{
	//	Math::float4 val;
	//	if (this->isMapped)
	//	{
	//		// note: the memory copy is necessary to circumvent alignment problem on some CPUs
	//		CC_ASSERT((this->mapCursor + sizeof(Math::float4)) <= this->mapEnd);
	//		Memory::Copy(this->mapCursor, &val, sizeof(val));     
	//		this->mapCursor += sizeof(val);
	//	}
	//	else
	//	{
	//		this->stream->Read(&val, sizeof(val));
	//	}
	//	this->byteOrder.Convert<Math::float4>(val);
	//	return val;
	//}

	////------------------------------------------------------------------------------
	///**
	//*/ 
	//Math::matrix44
	//BinaryReader::ReadMatrix44()
	//{
	//	Math::matrix44 val;
	//	if (this->isMapped)
	//	{
	//		// note: the memory copy is necessary to circumvent alignment problem on some CPUs
	//		CC_ASSERT((this->mapCursor + sizeof(Math::matrix44)) <= this->mapEnd);
	//		Memory::Copy(this->mapCursor, &val, sizeof(val));        
	//		this->mapCursor += sizeof(val);
	//	}
	//	else
	//	{
	//		this->stream->Read(&val, sizeof(val));
	//	}
	//	this->byteOrder.Convert<Math::matrix44>(val);
	//	return val;
	//}

	//------------------------------------------------------------------------------
	/**
	*/ 
	void
	BinaryReader::ReadRawData(void* ptr, unsigned long numBytes)
	{
		CC_ASSERT((ptr != 0) && (numBytes > 0));
		if (this->isMapped)
		{
			CC_ASSERT((this->mapCursor + numBytes) <= this->mapEnd);
			//Memory::Copy(this->mapCursor, ptr, numBytes);
			memcpy(ptr, this->mapCursor, numBytes);
			this->mapCursor += numBytes;
		}
		else
		{
			this->stream->Read(ptr, numBytes);
		}
	}

	signed long long BinaryReader::ReadLLong()
	{
		long long val;
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(unsigned int)) <= this->mapEnd);
			//Memory::Copy(this->mapCursor, &val, sizeof(val));
			memcpy(&val, this->mapCursor, sizeof(val));
			this->mapCursor += sizeof(val);
		}
		else
		{
			this->stream->Read(&val, sizeof(val));
		}
		//this->byteOrder.Convert<unsigned int>(val);
		return val;
	}

	unsigned long long BinaryReader::ReadULLong()
	{
		unsigned long long val;
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(unsigned int)) <= this->mapEnd);
			//Memory::Copy(this->mapCursor, &val, sizeof(val));
			memcpy(&val, this->mapCursor, sizeof(val));
			this->mapCursor += sizeof(val);
		}
		else
		{
			this->stream->Read(&val, sizeof(val));
		}
		//this->byteOrder.Convert<unsigned int>(val);
		return val;
	}

}
