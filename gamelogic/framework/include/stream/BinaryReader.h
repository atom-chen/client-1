#ifndef _ENGINE_IO_BINARYREADER_H
#define _ENGINE_IO_BINARYREADER_H

//------------------------------------------------------------------------------
namespace cocos2d {
	class  BinaryReader : public iBinaryReader
	{
	public:
		/// constructor
		BinaryReader();
		/// destructor
		virtual ~BinaryReader();

		virtual void SetStream(iStream* s, bool delStream);
		virtual iStream* GetStream();
		virtual bool HasStream() const;
		virtual bool Eof() const;
		virtual bool Open();
		virtual void Close();
		virtual bool IsOpen() const;

		/// call before Open() to enable memory mapping (if stream supports mapping)
		virtual void SetMemoryMappingEnabled(bool b);
		/// return true if memory mapping is enabled
		virtual bool IsMemoryMappingEnabled() const;
		/// set the stream byte order (default is host byte order)
		//void SetStreamByteOrder(System::ByteOrder::Type byteOrder);
		/// get the stream byte order
		//System::ByteOrder::Type GetStreamByteOrder() const;
		/// begin reading from the stream
		/// read an 8-bit char from the stream
		virtual signed char ReadChar();
		/// read an 8-bit unsigned character from the stream
		virtual unsigned char ReadUChar();
		/// read a 16-bit short from the stream
		virtual signed short ReadShort();
		/// read a 16-bit unsigned short from the stream
		virtual unsigned short ReadUShort();
		/// read a 32-bit int from the stream
		virtual signed int ReadInt();
		/// read a 32-bit unsigned int from the stream
		virtual unsigned int ReadUInt();
		/// read a float value from the stream
		virtual float ReadFloat();
		/// read a double value from the stream
		virtual double ReadDouble();
		/// read a bool value from the stream
		virtual bool ReadBool();

		virtual char* ReadString(char* tempBuf, unsigned long len);
		//char* ReadString64k();
		virtual char* ReadStringNoLen(char* tempBuf, unsigned long len);
		/// read a string from the stream
		//Util::String ReadString();
		/// read a float4 from the stream
		//Math::float4 ReadFloat4();
		///// read a matrix44 from the stream
		//Math::matrix44 ReadMatrix44();
		///// read a blob of data
		//Util::Blob ReadBlob();
		///// read a guid
		//Util::Guid ReadGuid();
		/// read raw data
		virtual void ReadRawData(void* ptr, unsigned long numBytes);

		virtual signed long long ReadLLong() ;
		virtual unsigned long long ReadULLong() ;

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
	inline void
	BinaryReader::SetMemoryMappingEnabled(bool b)
	{
		this->enableMapping = b;
	}

	//------------------------------------------------------------------------------
	/**
	*/
	inline bool BinaryReader::IsMemoryMappingEnabled() const
	{
		return this->enableMapping;
	}

	inline bool BinaryReader::IsOpen() const
	{
		return this->isOpen;
	}
	//------------------------------------------------------------------------------
	/**
	*/
	//inline void
	//BinaryReader::SetStreamByteOrder(System::ByteOrder::Type order)
	//{
	//	this->byteOrder.SetFromByteOrder(order);
	//}

	////------------------------------------------------------------------------------
	///**
	//*/
	//inline System::ByteOrder::Type
	//BinaryReader::GetStreamByteOrder() const
	//{
	//	return this->byteOrder.GetFromByteOrder();
	//}

}
//------------------------------------------------------------------------------
#endif