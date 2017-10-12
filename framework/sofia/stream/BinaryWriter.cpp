#include "cocos2d.h"
//#include "EngineMacros.h"
#include "stream/iStream.h"
#include "stream/BinaryWriter.h"
//#include <string.h>
#include <memory.h>

namespace cocos2d {

	//------------------------------------------------------------------------------
	/**
	*/
	BinaryWriter::BinaryWriter() :
		isOpen(false),
		deleteStream(true),
		stream(0),
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
	BinaryWriter::~BinaryWriter()
	{
		if (this->IsOpen())
		{
			this->Close();
		}
		if (deleteStream && this->stream)
		{
			delete this->stream;
		}
	}
	
	//------------------------------------------------------------------------------
	/**
		Attaches the writer to a stream. This will imcrement the refcount
		of the stream.
	*/
	void BinaryWriter::SetStream(iStream* s, bool delStream)
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
	iStream*	BinaryWriter::GetStream()
	{
		return this->stream;
	}

	//------------------------------------------------------------------------------
	/**
		Returns true if a stream is attached to the writer.
	*/
	bool
	BinaryWriter::HasStream() const
	{
		return (this->stream != 0);
	}

	//------------------------------------------------------------------------------
	/**
	*/
	bool
	BinaryWriter::Open()
	{
		CC_ASSERT(!this->isOpen);
		CC_ASSERT((this->stream != 0));
		CC_ASSERT(this->stream->CanWrite());
		if (this->stream->IsOpen())
		{
			CC_ASSERT((this->stream->GetAccessMode() == iStream::WriteAccess) || (this->stream->GetAccessMode() == iStream::ReadWriteAccess));
			this->streamWasOpen = true;
			this->isOpen = true;
		}
		else
		{
			this->streamWasOpen = false;
			this->stream->SetAccessMode(iStream::WriteAccess);
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
	BinaryWriter::Close()
	{
		CC_ASSERT(this->isOpen);
		if ((!this->streamWasOpen) && stream->IsOpen())
		{
			stream->Close();
		}
		this->isOpen = false;
		this->isMapped = false;
		this->mapCursor = 0;
		this->mapEnd = 0;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	void
	BinaryWriter::WriteChar(signed char c)
	{
		if (this->isMapped)
		{
			CC_ASSERT(this->mapCursor < this->mapEnd);
			*this->mapCursor++ = c;
		}
		else
		{
			this->stream->Write(&c, sizeof(c));
		}
	}

	//------------------------------------------------------------------------------
	/**
	*/
	void
	BinaryWriter::WriteUChar(unsigned char c)
	{
		if (this->isMapped)
		{
			CC_ASSERT(this->mapCursor < this->mapEnd);
			*this->mapCursor++ = c;
		}
		else
		{
			this->stream->Write(&c, sizeof(c));
		}
	}

	//------------------------------------------------------------------------------
	/**
	*/
	void
	BinaryWriter::WriteShort(signed short s)
	{
		//this->byteOrder.Convert<short>(s);
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(s)) <= this->mapEnd);
			//Memory::Copy(&s, this->mapCursor, sizeof(s));
			memcpy(this->mapCursor, &s, sizeof(s));
			this->mapCursor += sizeof(s);
		}
		else
		{
			this->stream->Write(&s, sizeof(s));
		}
	}

	//------------------------------------------------------------------------------
	/**
	*/
	void
	BinaryWriter::WriteUShort(unsigned short s)
	{
		//this->byteOrder.Convert<unsigned short>(s);
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(s)) <= this->mapEnd);
			//Memory::Copy(&s, this->mapCursor, sizeof(s));
			memcpy(this->mapCursor, &s, sizeof(s));
			this->mapCursor += sizeof(s);
		}
		else
		{
			this->stream->Write(&s, sizeof(s));
		}
	}

	//------------------------------------------------------------------------------
	/**
	*/
	void
	BinaryWriter::WriteInt(signed int i)
	{
		//this->byteOrder.Convert<int>(i);
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(i)) <= this->mapEnd);
			//Memory::Copy(&i, this->mapCursor, sizeof(i));
			memcpy(this->mapCursor, &i, sizeof(i));
			this->mapCursor += sizeof(i);
		}
		else
		{
			this->stream->Write(&i, sizeof(i));
		}
	}

	//------------------------------------------------------------------------------
	/**
	*/
	void
	BinaryWriter::WriteUInt(unsigned int i)
	{
		//this->byteOrder.Convert<unsigned int>(i);
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(i)) <= this->mapEnd);
			//Memory::Copy(&i, this->mapCursor, sizeof(i));
			memcpy(this->mapCursor, &i, sizeof(i));
			this->mapCursor += sizeof(i);
		}
		else
		{
			this->stream->Write(&i, sizeof(i));
		}
	}

	//------------------------------------------------------------------------------
	/**
	*/
	void
	BinaryWriter::WriteFloat(float f)
	{
		//this->byteOrder.Convert<float>(f);
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(f)) <= this->mapEnd);
			//Memory::Copy(&f, this->mapCursor, sizeof(f));
			memcpy(this->mapCursor, &f, sizeof(f));
			this->mapCursor += sizeof(f);
		}
		else
		{
			this->stream->Write(&f, sizeof(f));
		}
	}

	//------------------------------------------------------------------------------
	/**
	*/
	void
	BinaryWriter::WriteDouble(double d)
	{
		//this->byteOrder.Convert<double>(d);
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(d)) <= this->mapEnd);
			//Memory::Copy(&d, this->mapCursor, sizeof(d));
			memcpy(this->mapCursor, &d, sizeof(d));
			this->mapCursor += sizeof(d);
		}
		else
		{
			this->stream->Write(&d, sizeof(d));
		}
	}

	//------------------------------------------------------------------------------
	/**
	*/
	void
	BinaryWriter::WriteBool(bool b)
	{
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(b)) <= this->mapEnd);
			//Memory::Copy(&b, this->mapCursor, sizeof(b));
			memcpy(this->mapCursor, &b, sizeof(b));
			this->mapCursor += sizeof(b);
		}
		else
		{
			this->stream->Write(&b, sizeof(b));
		}
	}

	void BinaryWriter::WriteString(const char* txt)
	{
		if (txt == 0 || txt[0] == 0)
		{
			this->WriteUShort(0);
			return;
		}
		unsigned int txt_len = strlen(txt);
		CC_ASSERT(txt_len < (1<<16));
		if (txt_len > 1023)
		{
			txt_len = 1023;
		}
		this->WriteUShort((unsigned short)(txt_len));
		if (txt_len > 0)
		{
			if (this->isMapped)
			{
				CC_ASSERT((this->mapCursor + txt_len) <= this->mapEnd);
				//Memory::Copy(s.AsCharPtr(), this->mapCursor, s.Length());
				memcpy(this->mapCursor, txt, txt_len);
				this->mapCursor += txt_len;
			}
			else
			{
				this->stream->Write((void*)txt, txt_len);
			}
		}
	}

	void BinaryWriter::WriteStringNoLen(const char* txt)
	{
		if (txt == 0 || txt[0] == 0)
		{
			this->WriteUShort(0);
			return;
		}
		unsigned int txt_len = strlen(txt);
		CC_ASSERT(txt_len < (1<<16));
		if (txt_len > 1023)
		{
			txt_len = 1023;
		}
		//this->WriteUShort(unsigned short(txt_len));
		if (txt_len > 0)
		{
			if (this->isMapped)
			{
				CC_ASSERT((this->mapCursor + txt_len) <= this->mapEnd);
				//Memory::Copy(s.AsCharPtr(), this->mapCursor, s.Length());
				memcpy(this->mapCursor, txt, txt_len);
				this->mapCursor += txt_len;
			}
			else
			{
				this->stream->Write((void*)txt, txt_len);
			}
		}
	}

	void
	BinaryWriter::WriteRawData(const void* ptr, unsigned long numBytes)
	{
		CC_ASSERT((ptr != 0) && (numBytes > 0));
		if (this->isMapped)
		{
			CC_ASSERT((this->mapCursor + numBytes) <= this->mapEnd);
			//Memory::Copy(ptr, this->mapCursor, numBytes);
			memcpy(this->mapCursor, ptr, numBytes);
			this->mapCursor += numBytes;
		}
		else
		{
			this->stream->Write(ptr, numBytes);
		}
	}

	void BinaryWriter::WriteLLong( signed long long ll )
	{
		//this->byteOrder.Convert<double>(d);
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(ll)) <= this->mapEnd);
			//Memory::Copy(&d, this->mapCursor, sizeof(d));
			memcpy(this->mapCursor, &ll, sizeof(ll));
			this->mapCursor += sizeof(ll);
		}
		else
		{
			this->stream->Write(&ll, sizeof(ll));
		}
	}

	void BinaryWriter::WriteULLong(unsigned long long ull)
	{
		//this->byteOrder.Convert<double>(d);
		if (this->isMapped)
		{
			// note: the memory copy is necessary to circumvent alignment problem on some CPUs
			CC_ASSERT((this->mapCursor + sizeof(ull)) <= this->mapEnd);
			//Memory::Copy(&d, this->mapCursor, sizeof(d));
			memcpy(this->mapCursor, &ull, sizeof(ull));
			this->mapCursor += sizeof(ull);
		}
		else
		{
			this->stream->Write(&ull, sizeof(ull));
		}
	}

}
