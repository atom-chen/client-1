#include "cocos2d.h"
#include "EngineMacros.h"
#include "stream/iStream.h"
#include <memory.h>
#include "stream/MemoryStream.h"

namespace cocos2d {

	//using namespace Math;

	//------------------------------------------------------------------------------
	/**
	*/
	MemoryStream::MemoryStream() :
		accessMode(iStream::ReadAccess),
		accessPattern(iStream::Sequential),
		isOpen(false),
		isMapped(false),
		capacity(0),
		size(0),
		position(0),
		buffer(0)
	{
		// empty
	}

	//------------------------------------------------------------------------------
	/**
	*/
	MemoryStream::~MemoryStream()
	{
		// close the stream if still open
		if (this->IsOpen())
		{
			this->Close();
		}

		// release memory buffer if allocated
		//if (0 != this->buffer)
		{
			//Memory::Free(Memory::StreamDataHeap, this->buffer);
			CC_SAFE_DELETE(this->buffer);
			//this->buffer = 0;
		}
	}

	//------------------------------------------------------------------------------
	/**
	*/
	bool
	MemoryStream::CanRead() const
	{
		return true;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	bool
	MemoryStream::CanWrite() const
	{
		return true;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	bool
	MemoryStream::CanSeek() const
	{
		return true;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	bool
	MemoryStream::CanBeMapped() const
	{
		return true;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	void
	MemoryStream::SetSize(Size s)
	{
		CC_ASSERT(!this->IsOpen());
		if (s > this->capacity)
		{
			this->Realloc(s);
		}
		this->size = s;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	int
	MemoryStream::GetSize() const
	{
		return this->size;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	int
	MemoryStream::GetPosition() const
	{
		return this->position;
	}

	void MemoryStream::SetAccessMode(iStream::AccessMode m)
	{
		CC_ASSERT(!this->IsOpen());
		this->accessMode = m;
	}

	//------------------------------------------------------------------------------
	/**
		Get the access mode of the stream.
	*/
	iStream::AccessMode MemoryStream::GetAccessMode() const
	{
		return this->accessMode;
	}

	//------------------------------------------------------------------------------
	/**
		Set the prefered access pattern of the stream. This can be Random or
		Sequential. This is an optional flag to improve performance with
		some stream implementations. The default is sequential. The pattern
		cannot be changed while the stream is open.
	*/
	void MemoryStream::SetAccessPattern(iStream::AccessPattern p)
	{
		CC_ASSERT(!this->IsOpen());
		this->accessPattern = p;
	}

	//------------------------------------------------------------------------------
	/**
		Get the currently set prefered access pattern of the stream.
	*/
	iStream::AccessPattern MemoryStream::GetAccessPattern() const
	{
		return this->accessPattern;
	}
	//------------------------------------------------------------------------------
	/**
		Open the stream for reading or writing. The stream may already contain
		data if it has been opened/closed before. 
	*/
	bool
	MemoryStream::Open()
	{
		CC_ASSERT(!this->IsOpen());
	    
		// nothing to do here, allocation happens in the first Write() call
		// if necessary, all we do is reset the read/write position to the
		// beginning of the stream
		this->isOpen = true;
		{
			this->position = 0;
			return true;
		}
		return false;
	}

	//------------------------------------------------------------------------------
	/**
		Close the stream. The contents of the stream will remain intact until
		destruction of the object, so that the same data may be accessed 
		or modified during a later session. 
	*/
	void
	MemoryStream::Close()
	{
		CC_ASSERT(this->IsOpen());
		if (this->IsMapped())
		{
			this->Unmap();
		}
		this->isOpen = false;
	}

	bool MemoryStream::IsOpen() const
	{
		return this->isOpen;
	}
	//------------------------------------------------------------------------------
	/**
	*/
	void MemoryStream::Write(const void* ptr, Size numBytes)
	{
		CC_ASSERT(this->IsOpen());
		CC_ASSERT(!this->IsMapped()); 
		CC_ASSERT(((WriteAccess == this->accessMode) || (AppendAccess == this->accessMode) || (ReadWriteAccess == this->accessMode)));
		CC_ASSERT(this->position >= 0);
		CC_ASSERT(this->position <= this->size);

		// if not enough room, allocate more memory
		if (!this->HasRoom(numBytes))
		{
			this->MakeRoom(numBytes);
		}

		// write data to stream
		CC_ASSERT((this->position + numBytes) <= this->capacity);
		//Memory::Copy(ptr, this->buffer + this->position, numBytes);
		::memcpy(this->buffer + this->position, ptr, numBytes);
		this->position += numBytes;
		if (this->position > this->size)
		{
			this->size = this->position;
		}
	}

	//------------------------------------------------------------------------------
	/**
	*/
	int
	MemoryStream::Read(void* ptr, Size numBytes)
	{
		CC_ASSERT(this->IsOpen());
		CC_ASSERT(!this->IsMapped()); 
		CC_ASSERT((ReadAccess == this->accessMode) || (ReadWriteAccess == this->accessMode));
		CC_ASSERT((this->position >= 0));
		CC_ASSERT(this->position <= this->size);

		// check if end-of-stream is near
		//Size readBytes = n_min(numBytes, this->size - this->position);
		Size readBytes = __MIN(numBytes, this->size - this->position);
		CC_ASSERT((this->position + readBytes) <= this->size);
		if (readBytes > 0)
		{
			//Memory::Copy(this->buffer + this->position, ptr, readBytes);
			::memcpy(ptr, this->buffer + this->position, readBytes);
			this->position += readBytes;
		}
		return readBytes;
	}

	void MemoryStream::Dump()
	{
		//unsigned char* temp_buf = this->buffer + position;
		//unsigned int num = this->size - this->position;
		//LogOut("<%d>: ", num);
		//for (unsigned int i = 0; i < num; ++i)
		//{
		//	LogOut("%02x ", *(temp_buf));
		//	++temp_buf;
		//}
		//LogOut("\r\n");
	}

	//------------------------------------------------------------------------------
	/**
	*/
	void
	MemoryStream::Seek(int offset, SeekOrigin origin)
	{
		CC_ASSERT(this->IsOpen());
		CC_ASSERT(!this->IsMapped()); 
		CC_ASSERT((this->position >= 0) && (this->position <= this->size));
		switch (origin)
		{
			case Begin:
				this->position = offset;
				break;
			case Current:
				this->position += offset;
				break;
			case End:
				this->position = this->size + offset;
				break;
		}

		// make sure read/write position doesn't become invalid
		//this->position = Math::n_iclamp(this->position, 0, this->size);
		__CLAMP(this->position, 0, this->size);
	}

	//------------------------------------------------------------------------------
	/**
	*/
	bool
	MemoryStream::Eof() const
	{
		CC_ASSERT(this->IsOpen());
		CC_ASSERT(!this->IsMapped());
		CC_ASSERT((this->position >= 0) && (this->position <= this->size));
		return (this->position == this->size);
	}

	//------------------------------------------------------------------------------
	/**
	*/
	bool
	MemoryStream::HasRoom(Size numBytes) const
	{
		return ((this->position + numBytes) <= this->capacity);
	}

	//------------------------------------------------------------------------------
	/**
		This (re-)allocates the memory buffer to a new size. If the new size
		is smaller then the existing size, the buffer contents will be clipped.
	*/
	void
	MemoryStream::Realloc(Size newCapacity)
	{
		//unsigned char* newBuffer = (unsigned char*) Memory::Alloc(Memory::StreamDataHeap, newCapacity);
		unsigned char* newBuffer = (unsigned char*) malloc(newCapacity);//, "MemoryStream");
		CC_ASSERT(0 != newBuffer);
		//int newSize = n_min(newCapacity, this->size);
		int newSize = __MIN(newCapacity, this->size);
		if (0 != this->buffer)
		{
			//Memory::Copy(this->buffer, newBuffer, newSize);
			::memcpy(newBuffer, this->buffer, newSize);
			//Memory::Free(Memory::StreamDataHeap, this->buffer);
			CC_SAFE_DELETE(this->buffer);
		}
		this->buffer = newBuffer;
		this->size = newSize;
		this->capacity = newCapacity;
		if (this->position > this->size)
		{
			this->position = this->size;
		}
	}

	//------------------------------------------------------------------------------
	/**
		This method makes room for at least N more bytes. The actually allocated
		memory buffer will be greater then that. This operation involves a copy
		of existing data.
	*/
	void
	MemoryStream::MakeRoom(Size numBytes)
	{
		CC_ASSERT(numBytes > 0);
		CC_ASSERT((this->size + numBytes) > this->capacity);

		// compute new capacity
		//Size newCapacity = n_max(16, n_max(2 * this->capacity, this->size + numBytes));
		Size newCapacity = __MAX(16, __MAX(2 * this->capacity, this->size + numBytes));
		CC_ASSERT(newCapacity > this->capacity);

		// (re-)allocate memory buffer
		this->Realloc(newCapacity);
	}

	//------------------------------------------------------------------------------
	/**
		Map the stream for direct memory access. This is much faster then 
		reading/writing, but less flexible. A mapped stream cannot grow, instead
		the allowed memory range is determined by GetSize(). The read/writer must 
		take special care to not read or write past the memory buffer boundaries!
	*/
	void*
	MemoryStream::Map()
	{
		CC_ASSERT(this->IsOpen());
		CC_ASSERT(this->CanBeMapped());
		CC_ASSERT(!this->isMapped);
		this->isMapped = true;
		//Stream::Map();
		CC_ASSERT(this->GetSize() > 0);
		return this->buffer;
	}

	//------------------------------------------------------------------------------
	/**
		Unmap a memory-mapped stream.
	*/
	void
	MemoryStream::Unmap()
	{
		CC_ASSERT(this->IsOpen());
		CC_ASSERT(this->CanBeMapped());
		CC_ASSERT(this->isMapped);
		this->isMapped = false;
	}

	bool MemoryStream::IsMapped() const
	{
		return this->isMapped;
	}

	void MemoryStream::Flush()
	{
		CC_ASSERT(this->IsOpen());
		CC_ASSERT(!this->isMapped);
	}
	//------------------------------------------------------------------------------
	/**
		Get a direct pointer to the raw data. This is a convenience method
		and only works for memory streams.
		NOTE: writing new data to the stream may/will result in an invalid
		pointer, don't keep the returned pointer around between writes!
	*/
	void*
	MemoryStream::GetRawPointer() const
	{
		CC_ASSERT(0 != this->buffer);
		return this->buffer;
	}

	void MemoryStream::InitRawPointer(unsigned char* buffer_, Size size_)
	{
		//if (this->buffer)
		{
			CC_SAFE_DELETE(this->buffer);
		}
		this->buffer = buffer_;
		this->size = size_;
		this->position = 0;
		this->capacity = this->size;
		if (!this->IsOpen())
		{
			this->Open();
		}
	}
}
