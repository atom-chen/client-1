#ifndef __SFNETMESSAGE_H__
#define __SFNETMESSAGE_H__
#include <string>
namespace cocos2d {
#define NET_PACKET_DATA_SIZE 40960
#define NET_PACKET_SIZE (sizeof(NetPacketHeader) + NET_PACKET_DATA_SIZE)

struct NetPacketHeader
{
	unsigned short wDataSize;
	char	wZipFlag;
	short wOpcode; // -10 ~ 10
};

struct NetZipPacketHeader
{
	unsigned short wDataSize;
	char	wZipFlag;
	//char wempty; // -10 ~ 10
	short wOpcode; // -10 ~ 10
	short zipDataSizeBefore;
	short zipDataSizeAfter;
};


struct NetPacket
{
	NetPacketHeader		Header;
	unsigned char		Data[NET_PACKET_DATA_SIZE];
};

#define NET_TEST_POD       1
struct NetPacket_Test_POD
{
	int		nIndex;
	char	arrMessage[512];
};

#define NET_TEST_SERIALIZE 2
struct NetPacket_Test_Serialize
{
	int			nIndex;
	std::string	strMessage;
};
}
#endif