#ifndef _ENGINE_IO_MEMORYSTREAM_H
#define _ENGINE_IO_MEMORYSTREAM_H

namespace cocos2d {
	class  MemoryStream : public iMemoryStream
	{
	public:
		MemoryStream();
		virtual ~MemoryStream();
		virtual bool CanRead() const;
		virtual bool CanWrite() const;
		virtual bool CanSeek() const;
		virtual bool CanBeMapped() const;
		virtual void SetSize(Size s);
		virtual Size GetSize() const;
		virtual int GetPosition() const;
		virtual void SetAccessMode(iStream::AccessMode m);
		virtual iStream::AccessMode GetAccessMode() const;
		virtual void SetAccessPattern(iStream::AccessPattern p);
		virtual iStream::AccessPattern GetAccessPattern() const;
		virtual bool Open();
		virtual void Close();
		virtual bool IsOpen() const;
		virtual void Write(const void* ptr, Size numBytes);
		virtual Size Read(void* ptr, Size numBytes);
		virtual void Seek(int offset, SeekOrigin origin);
		virtual void Flush();
		virtual bool Eof() const;
		virtual void* Map();
		virtual void Unmap();
		virtual bool IsMapped() const;
		virtual void Dump();

		virtual void* GetRawPointer() const;
		virtual void InitRawPointer(unsigned char* buffer, Size size);

	private:
		/// re-allocate the memory buffer
		void Realloc(Size s);
		/// return true if there's enough space for n more bytes
		bool HasRoom(Size numBytes) const;
		/// make room for at least n more bytes
		void MakeRoom(Size numBytes);

		static const int InitialSize = 256;
		int capacity;
		int size;
		int position;
		unsigned char* buffer;
		iStream::AccessMode accessMode;
		iStream::AccessPattern accessPattern;
		bool isOpen;
		bool isMapped;
	};

}
//------------------------------------------------------------------------------
#endif