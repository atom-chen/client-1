#ifndef _ENGINE_IO_BINARYWRITERNET_H
#define _ENGINE_IO_BINARYWRITERNET_H
//------------------------------------------------------------------------------
#include "stream/BinaryWriter.h"
namespace cocos2d {
	class BinaryWriterNet : public  BinaryWriter
	{
	public:
		BinaryWriterNet() ;
		virtual ~BinaryWriterNet();

		/// write an 16-bit short to the stream
		virtual void WriteShort(short s);
		/// write an 16-bit unsigned short to the stream
		virtual void WriteUShort(unsigned short s);
		/// write an 32-bit int to the stream
		virtual void WriteInt(int i);
		/// write an 32-bit unsigned int to the stream
		virtual void WriteUInt(unsigned int i);
		/// write a float value to the stream
		virtual void WriteFloat(float f);
		/// write a double value to the stream
		virtual void WriteDouble(double d);

		virtual void WriteLLong(long long ll) ;
		virtual void WriteULLong(unsigned long long ull) ;
	};
}

#endif