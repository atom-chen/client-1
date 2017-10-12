#ifndef _ENGINE_IO_BINARYWRITER_H
#define _ENGINE_IO_BINARYWRITER_H


//------------------------------------------------------------------------------
namespace cocos2d {
	class  BinaryWriter : public iBinaryWriter
	{
	public:
		/// constructor
		BinaryWriter();
		/// destructor
		virtual ~BinaryWriter();

		virtual void SetStream(iStream* s, bool delStream);
		virtual iStream* GetStream();
		virtual bool HasStream() const;
		virtual bool Open();
		virtual void Close();
		virtual bool IsOpen() const;

		/// call before Open() to enable memory mapping (if stream supports mapping)
		void SetMemoryMappingEnabled(bool b);
		/// return true if memory mapping is enabled
		bool IsMemoryMappingEnabled() const;

		/// write an 8-bit char to the stream
		void WriteChar(signed char c);
		/// write an 8-bit unsigned char to the stream
		void WriteUChar(unsigned char c);
		/// write an 16-bit short to the stream
		void WriteShort(signed short s);
		/// write an 16-bit unsigned short to the stream
		void WriteUShort(unsigned short s);
		/// write an 32-bit int to the stream
		void WriteInt(signed int i);
		/// write an 32-bit unsigned int to the stream
		void WriteUInt(unsigned int i);
		/// write a float value to the stream
		void WriteFloat(float f);
		/// write a double value to the stream
		void WriteDouble(double d);
		/// write a boolean value to the stream
		void WriteBool(bool b);
		/// write a string to the stream
		void WriteString(const char* txt);
		void WriteStringNoLen(const char* txt);

		//void WriteString64k(const char* txt);
		//void WriteString(const Util::String& s);
		/// write a float4 to the stream
		//void WriteFloat4(const Math::float4& v);
		///// write a matrix44 to the stream
		//void WriteMatrix44(const Math::matrix44& m);
		///// write a blob of data
		//void WriteBlob(const Util::Blob& blob);
		///// write a guid
		//void WriteGuid(const Util::Guid& guid);
		/// write raw data
		void WriteRawData(const void* ptr, unsigned long numBytes);

		virtual void WriteLLong(signed long long ll) ;
		virtual void WriteULLong(unsigned long long ull) ;

	public:
		iStream* stream;
		bool deleteStream;
		bool isOpen;
		bool streamWasOpen;
		bool enableMapping;
		bool isMapped;
		//System::ByteOrder byteOrder;
		unsigned char* mapCursor;
		unsigned char* mapEnd;
	};

	//------------------------------------------------------------------------------
	/**
	*/
	inline
	void
	BinaryWriter::SetMemoryMappingEnabled(bool b)
	{
		this->enableMapping = b;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	inline
	bool
	BinaryWriter::IsMemoryMappingEnabled() const
	{
		return this->enableMapping;
	}

	inline bool BinaryWriter::IsOpen() const
	{
		return this->isOpen;
	}
	//
	////------------------------------------------------------------------------------
	///**
	//*/
	//inline void
	//BinaryWriter::SetStreamByteOrder(System::ByteOrder::Type order)
	//{
	//    this->byteOrder.SetToByteOrder(order);
	//}
	//
	////------------------------------------------------------------------------------
	///**
	//*/
	//inline System::ByteOrder::Type
	//BinaryWriter::GetStreamByteOrder() const
	//{
	//    return this->byteOrder.GetToByteOrder();
	//}

}
//------------------------------------------------------------------------------
#endif
