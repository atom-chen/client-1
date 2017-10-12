#include "stream/iStream.h"

#include "stream/BinaryWriterNet.h"
#include "sofia/utils/CommonUtility.h"

namespace cocos2d {

	BinaryWriterNet::BinaryWriterNet():BinaryWriter()
	{

	}

	BinaryWriterNet::~BinaryWriterNet()
	{

	}

	void BinaryWriterNet::WriteShort( short s )
	{
		BinaryWriter::WriteShort( HOST2NET_16(s) );
	}

	void BinaryWriterNet::WriteUShort( unsigned short s )
	{
		BinaryWriter::WriteUShort( HOST2NET_16(s) );
	}


	void BinaryWriterNet::WriteInt( int i )
	{
		BinaryWriter::WriteInt( HOST2NET_32(i) );
	}

	void BinaryWriterNet::WriteUInt( unsigned int i )
	{
		BinaryWriter::WriteUInt( HOST2NET_32(i) );
	}

	void BinaryWriterNet::WriteFloat( float f )
	{
		unsigned int temp = HOST2NET_32( *( (unsigned int*)&f ) );
		BinaryWriter::WriteFloat(*((float*)&temp));
	}

	void BinaryWriterNet::WriteDouble( double d )
	{
		unsigned long long temp = HOST2NET_64( *( (unsigned long long*)&d ) );
		BinaryWriter::WriteDouble(*((double*)&temp));
	}

	void BinaryWriterNet::WriteLLong( long long ll )
	{
		BinaryWriter::WriteLLong(HOST2NET_64(ll));
	}

	void BinaryWriterNet::WriteULLong( unsigned long long ull )
	{
		BinaryWriter::WriteULLong(HOST2NET_64(ull));
	}

}