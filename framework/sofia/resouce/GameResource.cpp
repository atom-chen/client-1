#include "resource/gameResource.h"
#include "include/utils/SFStringUtil.h"

#include "platform/CCFileUtils.h"
#if CC_PLATFORM_ANDROID == CC_TARGET_PLATFORM
#include <sys/stat.h> 
#include <sys/types.h> 

void copyDir(const char* filePath)
{
	char buf[1000] = {0};
	for(const char* tag=filePath;*tag;tag++)
	{
		if (*tag=='\\' || *tag == '/')
		{
			memset(buf, 0, sizeof(buf));
			strcpy(buf,filePath);
			buf[strlen(filePath)-strlen(tag)+1]='\0';

			if (access(buf,6)==-1)
			{
				mkdir(buf, S_IRWXU);
			}
		}
	}
}

void copyData(const char* pFileName, const char* dstPath)
{
	unsigned long len = 0;
	unsigned char *data = NULL;

	copyDir(dstPath);
	data = CCFileUtils::sharedFileUtils()->getFileData(pFileName,"r",&len);

	FILE *fp = fopen(dstPath,"w+");
	size_t write = fwrite(data,sizeof(char),len,fp);
	fclose(fp);
	delete []data;
	
	data = NULL;
}
#endif

GameResource::GameResource()
{

}

GameResource::~GameResource()
{
}

bool GameResource::loadCsv( const char* csvFile, ICsvStreamCallBack* pCallback )
{
	std::string csvPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(csvFile);
	unsigned long size = 0;
	unsigned char* buffer = CCFileUtils::sharedFileUtils()->getFileData(csvPath.c_str(), "rb", &size);
	
	CsvFile file;
	bool ret = file.ReadCsvMemory((char*)buffer, size, csvFile, pCallback);
	delete[] buffer;
	return ret;
}

bool GameResource::loadCSV( const char* csvFile, CCObject *target /*= NULL*/, SEL_CallFuncND callFunc /*= NULL*/ )
{
	std::string csvPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(csvFile);
	unsigned long size = 0;
	unsigned char* buffer = CCFileUtils::sharedFileUtils()->getFileData(csvPath.c_str(), "rb", &size);
	CsvFile file;
	bool ret = file.ReadCsvMemory((char*)buffer, size, csvFile, target, callFunc);
	CC_SAFE_DELETE_ARRAY(buffer);
	return ret;
}


std::string GameResource::readblePathFromRelativePath( const char* path )
{
	std::string ret = CCFileUtils::sharedFileUtils()->fullPathForFilename(path);

#if CC_PLATFORM_ANDROID == CC_TARGET_PLATFORM
	ret = CCFileUtils::sharedFileUtils()->getWritablePath();
	ret += path;
	copyData(path, ret.c_str());
#endif
	// 用UTF8编码可以避免路径中有中文或者特殊字符导致的错误
	ret = SFStringUtil::formatStringUtf8(ret.c_str());

	return ret;
}

void GameResource::setMapPath(const char* filePath)
{
	//std::string path = CCFileUtils::sharedFileUtils()->fullPathForFilename(filePath);
	if (filePath)
	{
		m_mapPath = filePath;
		m_mapPath += "/";
	}
}

bool GameResource::loadMapFile(int mapId, IReadBinaryFileCallBack* pCallBack)
{
	std::string binaryFile;
	char mapFileName[20];

	sprintf(mapFileName, "%d", mapId);
	//itoa(mapId, mapFileName, 10);
	binaryFile = m_mapPath + mapFileName + ".cm";
	unsigned long size;
	unsigned char* pBuff = CCFileUtils::sharedFileUtils()->getFileData(binaryFile.c_str(), "rb", &size);
	if(!pBuff)
		return false;
	MemoryStream buffStream;
	buffStream.SetAccessMode(iStream::ReadWriteAccess);
	buffStream.Open();
	buffStream.Seek(0, iStream::Begin);
	cocos2d::BinaryWriter write;
	write.SetStream(&buffStream, false);
	write.Open();
	write.WriteRawData(pBuff, size);
	write.Close();
	buffStream.Seek(0, iStream::Begin);
	if (buffStream.GetSize() > 0)
	{
		pCallBack->onBinaryFileLoad(buffStream);
		return true;
	}
	
	return false;
}

GameResource* GameResource::instance()
{
	return GameResource::getInstancePtr();
}
