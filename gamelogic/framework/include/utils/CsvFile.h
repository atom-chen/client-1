#ifndef CsvFile_h__
#define CsvFile_h__
#include <string>
#include <vector>
#include <map>
#include "cocos2d.h"
typedef std::vector<std::string> CsvVector;
typedef std::map<std::string, std::string> CsvKeyToValue;

class CsvReader
{
public:
	CsvReader(CsvKeyToValue* rowValue);
	~CsvReader();
	int			readAsInt(const char* key, int defaultValue=0);
	bool		readAsBool(const char* key, bool defaultValue=false);
	float		readAsFloat(const char* key, float defalutValue=0.0f);
	const char* readAsString(const char* key, const char* defaultValue="");
private:

	const char* getVal(const char* key);

	CsvKeyToValue*	m_rowValue;
};

class CsvWriter
{
public:
	CsvWriter();
	~CsvWriter();

	void WriteInt(int val);
	void WriteStr(const char*val);
	void WriteFloat(float val);
	void Clear() { m_rowValue.clear(); }

	const char* GetRowStr();

	inline CsvWriter & operator<<( float val )
	{
		this->WriteFloat( val );
		return (*this);
	}
	inline CsvWriter & operator<<( bool val )
	{
		this->WriteInt( int(val) );
		return (*this);
	}
	inline CsvWriter & operator<<( int val )
	{
		this->WriteInt( val );
		return (*this);
	}
	inline CsvWriter & operator<<( const char* val )
	{
		this->WriteStr( val );
		return (*this);
	}
	inline CsvWriter & operator<<( const std::string& val )
	{
		this->WriteStr( val.c_str() );
		return (*this);
	}
private:
	std::string m_rowValue;
};

struct ICsvStreamCallBack
{
	virtual bool onCsvLoad(CsvReader* pReader, const char* fileName) = 0;
	virtual void onCsvLoadError(const char* fileName) {};

	// write end when return false
	virtual bool onCsvWriteLine(CsvWriter *pWrite, const char* fileName) { return false; };
	virtual bool onCsvWriteComment(CsvWriter *pWrite, const char* fileName) { return false; };
};


class CsvFile
{
public:
	CsvFile();
	virtual ~CsvFile();

	bool ReadCsvFile(const char* fileName, const char* fileTag, ICsvStreamCallBack* callback);
	bool ReadCsvMemory(char* buffer, long size, const char* fileTag, ICsvStreamCallBack* callback);
	bool ReadCsvMemory(char* buffer, long size, const char* fileTag, cocos2d::CCObject *target = NULL, cocos2d::SEL_CallFuncND callFunc = NULL);
	bool WriteCsvFile( const char* fileName, const char* fileTag, ICsvStreamCallBack*callback );

private:
	void writeTitle( CsvWriter &writer );

	void ReadCsvStream(std::istream& is, const char* fileTag, ICsvStreamCallBack* callback);
	void ReadCsvStream(std::istream& is, const char* fileTag, cocos2d::CCObject *target = NULL, cocos2d::SEL_CallFuncND callFunc = NULL);
	void ReadCsvLine(std::vector<std::string> &record, const std::string& line, char delimiter);


private:

	CsvVector				m_itemKey;
};
//NS_CC_END
#endif // CsvFileReader_h__