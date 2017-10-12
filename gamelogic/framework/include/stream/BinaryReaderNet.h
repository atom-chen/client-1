#ifndef _ENGINE_IO_BINARYREADERNET_H
#define _ENGINE_IO_BINARYREADERNET_H
//------------------------------------------------------------------------------
#include "stream/BinaryReader.h"

namespace cocos2d {
	class BinaryReaderNet : public BinaryReader
	{
	public:
		BinaryReaderNet() ;
		virtual ~BinaryReaderNet();

		virtual short ReadShort();
		/// read a 16-bit unsigned short from the stream
		virtual unsigned short ReadUShort();
		/// read a 32-bit int from the stream
		virtual int ReadInt();
		/// read a 32-bit unsigned int from the stream
		virtual unsigned int ReadUInt();

		/// read a float value from the stream
		virtual float ReadFloat();
		/// read a double value from the stream
		virtual double ReadDouble();


		virtual long long ReadLLong() ;
		virtual unsigned long long ReadULLong() ;
	};
}

#endif