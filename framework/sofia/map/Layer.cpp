#include "map/Layer.h"
#include "stream/BinaryWriterNet.h"
#include "stream/BinaryReaderNet.h"

cmap::Layer::Layer(int layerType) 
	: mIsVisible(true)
	, mRender(NULL)
	, mLayerOrder(0)
	, mLayerType(layerType)
	, mLayerID(0)
{
	
}

cmap::Layer::~Layer()
{

}

bool cmap::Layer::Load(cocos2d::iStream& stream)
{
	cocos2d::BinaryReaderNet reader;
	reader.SetStream(&stream, false);
	if (!reader.Open())
	{
		return false;
	}

	mLayerType = reader.ReadChar();
	mLayerID = reader.ReadShort();

	char buf[1024] = {0};
	reader.ReadString(buf, 1024);
	mName = buf;
	return true;
}

bool cmap::Layer::Save(cocos2d::iStream& stream)
{
	cocos2d::BinaryWriterNet writer;
	writer.SetStream(&stream, false);
	if (!writer.Open())
	{
		return false;
	}

	writer.WriteChar(mLayerType);
	writer.WriteShort(mLayerID);
	writer.WriteString(mName.c_str());
	return true;
}

void cmap::Layer::setResourceLoadHandle( SFLoadTextureModule* resourceLoad )
{
	m_map_bg_loader = resourceLoad;
}


unsigned int cmap::Layer::memory_used_size = 0;
