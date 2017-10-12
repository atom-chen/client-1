/********************************************************************
	created:	2013/09/18
	created:	18:9:2013   11:39
	filename: 	..\engine\include\map\MapDefine.h
	file path:	..\engine\include\map
	file base:	MapDefine
	file ext:	h
	author:		luofuwen
	
	purpose:	For the defines of map
	abort:		grid_id[1...n]
*********************************************************************/
#ifndef MapDefine_h__
#define MapDefine_h__
#include <list>
#include <map>

namespace cmap
{
	//////////////////////////////////////////////////////////////////////////
	// 地图文件头
	struct MapFileHeader
	{
		char fileExt[64];	// SMCF
		int  version;		// 日期，比如 2013100118 （代表2013年10月01号18点的版本）
		// 遗留空间，用来扩展
		char reserve[256];
	};
	//地图文件信息头
	struct MapInfoHeader
	{
		int mapId;
		char mapName[256];
		short colNum;
		short rowNum;
		short cellHeight;
		short cellWidth;
		char renderMode;
		char compress;
		int  normalSize;
		int  compressSize;
		char reserve[256];
	};


	// ENUM BEGIN
	enum E_MetaLayerClassType
	{
		MetaType_Block = 1,
		MetaType_Mask  = 2
	};
	enum E_MetaLayerDataReadType
	{
		MetaReadType_Grid = 1,
		MetaReadType_Byte = 2
	};
	enum E_LayerDataLoadType
	{
		LayerLoadType_All  = 1,
		LayerLoadType_Asyn = 2
	};
	enum E_MapLayerType
	{
		NullLayerType = 0,
		TileLayerType,
		AdornmentLayerType,
		MetaLayerType,
	};
	// ENUM END
	// Layer统一标识头
	struct LayerHeader
	{
		char layerType;	
		int  dataSize; // layerInfoSize + layerDataSize , without LayerHeader's Size

		char reserve[256];
	};
	
	//////////////////////////////////////////////////////////////////////////
	// Layer Info
	// MetaLayer信息头
	struct MetaLayerInfoHeader
	{
		short gridWidth;
		short gridHeight;
		short gridRow;
		short gridCol;

		char reserve[256];
	};
	// MetaLayer Class
	struct MetaLayerClassInfoHeader
	{
		int classNum;
		char reserve[256];
	};
	// MetaLayerClassInfo连接上面的头，是循环数据
	struct MetaLayerClassInfo
	{
		int metaType;	// E_MetaLayerClassType
		char readMode;	// E_MetaLayerDataReadType
		char name[256];
		unsigned int color;
		char reserve[256];
	};
	struct MetaLayerTileInfoGridHeader
	{
		int metaType;	// E_MetaLayerClassType
		int gridNum;
		char reserve[256];
	};
	struct MetaLayerTileInfoCell // -- Grid数据
	{
		short gridId;	
		int imageId;
		char reserve[16];
	};
	struct MetaLayerTileInfoByteHeader // -- Byte数据存在BUFF里byteBuff[rows*columns]
	{
		int metaType;	// E_MetaLayerClassType
		char reserve[256];
	};
	// TileLayer信息头
	struct TileLayerInfoHeader
	{
		short gridWidth;
		short gridHeight;
		short gridRow;
		short gridCol;
		char  loadType;	// E_LayerDataLoadType

		char reserve[256];
	};

	// TileLayerClass
	struct TileLayerClassInfo
	{
		int usedMemory; // (kb)
		char name[256];
		char reserve[256];
	};
	struct  TileImageInfoHreader
	{
		int totleCount;
		char reserve[256];
	};
	struct TileImageInfoProperty
	{
		short gridId;
		int imageId;
		char rotateFlag;
	};
	// --------------------------------
	// AdornLayer信息头
	struct AdornLayerInfoHeader
	{
		char  loadType;	// E_LayerDataLoadType

		char reserve[256];
	}; 
	// AdornLayerClass
	struct AdornLayerClassInfoHeader
	{
		int usedMemory;		// (kb)
		char names[1024];	// 编辑器专用！装饰层可以分成很多层去编辑，这里存放每层的名字 name1;name2;name3...
		int elemNum;		// 用到的原件数量
		char reserve[256];
	};
	struct AdornLayerClassInfo
	{
		int imageId; 
		int imageUseNum;
		char reserve[256];
	};
	struct AdornImageInfoHeader
	{
		int renderObjectId; 
		int propDataSize;
		char reserve[256];
	};
	struct AdornImageInfoProperty
	{
		int renderObjectId;
		char drawIndex;
		char drawType;
		char rotateFlag;
		int base_x;
		int base_y;
		int pos_x;
		int pos_y;
		int width;
		int height;
	};
	// Single Class Info END

}
#endif

