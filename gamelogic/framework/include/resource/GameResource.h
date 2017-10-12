#ifndef _GAME_RESOURCE_H_
#define _GAME_RESOURCE_H_
#include "utils/Singleton.h"
#include "cocos2d.h"
using namespace cocos2d;
#define GAME_RESOURCE	GameResource::getInstancePtr()
#define GAME_PURGE_RES				GameResource::getInstancePtr()->releaseInstance()

//#include "utils/SFSqlReader.h"
#include "utils/CsvFile.h"
//#include "utils/SFJsonMgr.h"
#include "stream/iStream.h"
#include "stream/MemoryStream.h"
#include "stream/BinaryWriter.h"

// struct ISqlReadStreamCallBack
// {
// 	virtual void onSqTablelLoad(SFSqlReader* pReader, const char* tableName) = 0;
// };


struct IXmlStreamCallback
{
	virtual void onXmlLoad(tinyxml2::XMLElement* rootNode, const char* filename) = 0;
	virtual void onXmlLoadError(const char* errorstr, const char* filename){}
};

struct IReadBinaryFileCallBack
{
	virtual void onBinaryFileLoad(MemoryStream& msback) = 0;
};


class GameResource : public cocos2d::Singleton<GameResource>
{
public:
	GameResource();
	~GameResource();
	//bool initDb(const char* dbFilename);

	// for lua instance
	static GameResource* instance();

public:
	//content
	void				setContentLanguage(int nType);
	std::string			getContentForKey(std::string uiId, std::string keyWord);
public:
	//sound

public:

	//sqlite
	//加载表全部数据
	//bool loadSqlTable(const char* tableName, ISqlReadStreamCallBack* pCallBack);

	//csv
	bool loadCsv(const char* csvFile, ICsvStreamCallBack* pCallback);
	bool loadCSV(const char* csvFile, CCObject *target = NULL, SEL_CallFuncND callFunc = NULL);
	//Json
	//bool loadZJson(SFSqlBlob &blob, int jsonTag, IJsonParseCallBack* pCallback);

	// map cm file
	bool loadMapFile(int mapId, IReadBinaryFileCallBack* pCallBack);
	void setMapPath(const char* filePath);
private:
	//void executeSelect(const std::string& sql, ISqlReadStreamCallBack* pCallBack, const char* tableName);
	std::string readblePathFromRelativePath(const char* path);
	std::string m_mapPath;
};

#endif