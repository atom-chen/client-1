#include "stream/iStream.h"

#include "stream/BinaryReaderNet.h"
#include "sofia/utils/CommonUtility.h"


namespace cocos2d {

	BinaryReaderNet::BinaryReaderNet():BinaryReader()
	{

	}

	BinaryReaderNet::~BinaryReaderNet()
	{

	}


	short BinaryReaderNet::ReadShort()
	{
		short val = BinaryReader::ReadShort();
		return NET2HOST_16(val);
	}

	unsigned short BinaryReaderNet::ReadUShort()
	{
		unsigned short val = BinaryReader::ReadUShort();
		return NET2HOST_16(val);
	}

	int BinaryReaderNet::ReadInt()
	{
		int val = BinaryReader::ReadInt();
		return NET2HOST_32(val);
	}

	unsigned int BinaryReaderNet::ReadUInt()
	{
		unsigned int val = BinaryReader::ReadUInt();
		return NET2HOST_32(val);
	}

	float BinaryReaderNet::ReadFloat()
	{
		float f = BinaryReader::ReadFloat();
		unsigned int temp = NET2HOST_32( *( (unsigned int*)&f ) );
		return *((float*)&temp);
	}

	double BinaryReaderNet::ReadDouble()
	{
		double f = BinaryReader::ReadDouble();
		unsigned long long temp = NET2HOST_64( *( (unsigned long long*)&f ) );
		return *((double*)&temp);
	}

	long long BinaryReaderNet::ReadLLong()
	{
		long long val = BinaryReader::ReadLLong();
		return NET2HOST_64(val);
	}

	unsigned long long BinaryReaderNet::ReadULLong()
	{
		unsigned long long val = BinaryReader::ReadULLong();
		return NET2HOST_64(val);
	}


}