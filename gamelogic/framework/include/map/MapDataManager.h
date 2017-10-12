/********************************************************************
	created:	2013/09/23
	created:	23:9:2013   16:23
	filename: 	..\engine\include\map\MapDataManager.h
	file path:	..\engine\include\map
	file base:	MapDataManager
	file ext:	h
	author:		Luofuwen
	
	purpose:	所有已经加载的地图，没有加载的取不到的哟
*********************************************************************/
#ifndef MapDataManager_h__
#define MapDataManager_h__
#include <map>
#include <list>
#include "platform/CCPlatformMacros.h"
#include "map/MapDefine.h"
#include "stream/iStream.h"

namespace cmap
{
	class MapData;
	class MapMetaLayerData;
	class MapTileLayerData;
	class MapAdornLayerData;

	class MapDataManager
	{
	public:
		static MapDataManager getInstance();

		MapDataManager();
		~MapDataManager();
		void clearAll();
		bool delMap(int mapId);
		void addMap(char* dataPtr, int dataSize);
		MapData* getMapData(int mapId);
	protected:
		static MapDataManager* m_selfInstance;
	private:
		// id, mapData
		std::map<int, MapData*> m_mapDatas; 
	};
	//////////////////////////////////////////////////////////////////////////
	class MapData
	{
	public:
		MapData();
		~MapData();
		bool load(char* dataPtr, int dataSize);
		bool save(cocos2d::iStream& stream);
		// Get Set
		char* getDataPtr() { return m_dataPtr; }
		CC_SYNTHESIZE(int, m_dataSize, DataSize);
		CC_SYNTHESIZE(int, m_mapId, MapId);
		CC_SYNTHESIZE(MapFileHeader*, m_fileHeader, FileHeader);
		CC_SYNTHESIZE(MapInfoHeader*, m_infoHeader, InfoHeader);
		CC_SYNTHESIZE(MapMetaLayerData*, m_metaLayerData, MetaLayerData);
		CC_SYNTHESIZE(MapTileLayerData*, m_tileLayerData, TileLayerData);
		CC_SYNTHESIZE(MapAdornLayerData*, m_adornLayerData, AdornLayerData);
	private:
		// 正常情况下，地图应该是有3个类型的图层
		char getLayerCount();
		char* m_dataPtr;
	};
	//////////////////////////////////////////////////////////////////////////
	class MapMetaLayerData
	{
	public:
		MapMetaLayerData();
		~MapMetaLayerData();
		bool load(cocos2d::iStream& stream);
		bool save(cocos2d::iStream& stream);

		// Get Set
		CC_SYNTHESIZE(LayerHeader*, m_layerHeader, LayerHeader);
		CC_SYNTHESIZE(MetaLayerInfoHeader*, m_infoHeader, InfoHeader);
		CC_SYNTHESIZE(MetaLayerClassInfoHeader*, m_classInfoHeader, ClassInfoHeader);
		std::list<MetaLayerClassInfo*> getClassInfoList() const { return m_classInfoList; }
		MetaLayerClassInfo* getClassInfo(int type);
		bool addClassInfo(MetaLayerClassInfo* classInfo, bool replace = true);
		bool delClassInfo(int type);
		void clearClassInfos();
		// readMode_grid
		CC_SYNTHESIZE(MetaLayerTileInfoGridHeader*, m_tileInfoGridHeader, TileInfoGridHeader);
		std::list<MetaLayerTileInfoCell*> getTileInfoCellList() const { return m_tileInfoCellList; }
		MetaLayerTileInfoCell* getTileInfoCell(int gridId);
		
		// readMode_byte
		CC_SYNTHESIZE(MetaLayerTileInfoByteHeader*, m_tileInfoByteHeader, TileInfoByteHeader);
		CC_SYNTHESIZE(char*, m_tileInfoByteDataPtr, TileInfoByteDataPtr);
		int getTileInfoByteDataSize();
	private:
		bool readModeGrid(cocos2d::iStream& stream);
		bool saveModeGrid(cocos2d::iStream& stream);
		bool readModeByte(cocos2d::iStream& stream);
		bool saveModeByte(cocos2d::iStream& stream);
		// type, MetaLayerClassInfo*
		std::list<MetaLayerClassInfo*> m_classInfoList;
		// gird
		std::list<MetaLayerTileInfoCell*> m_tileInfoCellList;
	};
	//////////////////////////////////////////////////////////////////////////
	class MapTileLayerData
	{
	public:
		MapTileLayerData();
		~MapTileLayerData();
		bool load(cocos2d::iStream& stream);
		bool save(cocos2d::iStream& stream);
		// Get Set
		CC_SYNTHESIZE(LayerHeader*, m_layerHeader, LayerHeader);
		CC_SYNTHESIZE(TileLayerInfoHeader*, m_infoHeader, InfoHeader);
		CC_SYNTHESIZE(TileLayerClassInfo*, m_classInfo, ClassInfo);
		CC_SYNTHESIZE(TileImageInfoHreader*, m_tileInfoHeader, TileInfoHeader);
		// 下面是属性字典
		std::map<short, TileImageInfoProperty*> const getImageInfoPropertyList() { return m_imageInfoPropertyList; }
		TileImageInfoProperty* getTileImageInfoProperty(short gridId);
	private:
		// gridId,prop
		std::map<short, TileImageInfoProperty*> m_imageInfoPropertyList;

	};
	//////////////////////////////////////////////////////////////////////////
	// showindex, property
	typedef std::map<int, AdornImageInfoProperty*> AdornImageInfoPropertyObject;
	// image, showindex, property
	typedef std::map<int, AdornImageInfoPropertyObject> AdornImageInfoPropertyClass;
	class MapAdornLayerData
	{
	public:
		MapAdornLayerData();
		~MapAdornLayerData();
		bool load(cocos2d::iStream& stream);
		bool save(cocos2d::iStream& stream);
		// Get Set
		CC_SYNTHESIZE(LayerHeader*, m_layerHeader, LayerHeader);
		CC_SYNTHESIZE(AdornLayerInfoHeader*, m_infoHeader, InfoHeader);
		CC_SYNTHESIZE(AdornLayerClassInfoHeader*, m_classInfoHeader, ClassInfoHeader);
		std::list<AdornLayerClassInfo*> getClassInfoList() const { return m_classInfoList; }
		AdornLayerClassInfo* getCLassInfo(int elemId);

		CC_SYNTHESIZE(AdornImageInfoHeader*, m_elemInfoHeader, ElemInfoHeader);
		// 下面是属性字典
		AdornImageInfoPropertyClass getImageInfoMap() { return m_imageInfoPropertyMap; }
		AdornImageInfoProperty* getImageInfoProperty(int imageId, int showIndex);
	private:
		std::list<AdornLayerClassInfo*> m_classInfoList;
		AdornImageInfoPropertyClass m_imageInfoPropertyMap;
	};

}



#endif