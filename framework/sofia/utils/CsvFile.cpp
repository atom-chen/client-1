#include "utils/CsvFile.h"
#include <fstream>
#include "include/utils/SFStringUtil.h"
#include "sofia/utils/SFLog.h"
USING_NS_CC;
CsvFile::CsvFile()
{

}


CsvFile::~CsvFile()
{

}


bool CsvFile::ReadCsvFile( const char* fileName, const char* fileTag, ICsvStreamCallBack* callback)
{
	if (callback == NULL)
		return false;

	std::ifstream in(fileName);
	if (in.fail())
	{
		SFLog("CsvFile::ReadCsvFile:fileName%s ", fileName );
		callback->onCsvLoadError(fileTag);
		return false;
	}

	//m_stringKeyMap.clear();

	ReadCsvStream(in, fileTag, callback);
	in.close();
	return true;
}

void CsvFile::ReadCsvLine( std::vector<std::string> &record, const std::string& line, char delimiter )
{
	int linepos=0;
	int inquotes=false;
	char c = 0;
	int linemax=line.length();
	std::string curstring;
	record.clear();

	while(line[linepos]!=0 && linepos < linemax)
	{
		c = line[linepos];

		if (!inquotes && curstring.length()==0 && c=='"')
		{
			//beginquotechar
			inquotes=true;
		}
		else if (inquotes && c=='"')
		{
			//quotechar
			if ( (linepos+1 <linemax) && (line[linepos+1]=='"') ) 
			{
				//encountered 2 double quotes in a row (resolves to 1 double quote)
				curstring.push_back(c);
				linepos++;
			}
			else
			{
				//endquotechar
				inquotes=false; 
			}
		}
		else if (/*linepos==0 &&*/ !inquotes && c==delimiter)
		{
			//end of field
			record.push_back( curstring );
			curstring="";
		}
		else if (!inquotes && (c=='\r' || c=='\n') )
		{
			record.push_back( curstring );
			return;
		}
		else if (!inquotes && c=='#')
		{
			return;
		}
		else if (linepos==0 && c=='@')
		{
			std::string str = line;
			std::vector<std::string> row;
			str = str.erase(0,1);
			ReadCsvLine(row, str, ',');
			if (row.empty() == false)
				m_itemKey = row;
			return;
		}
		else
		{
			curstring.push_back(c);
		}
		linepos++;
	}
	if (curstring.size() > 0)
	{
		record.push_back( curstring );
	}
	else if(c == delimiter)
	{
		record.push_back( curstring );
	}
}

bool CsvFile::WriteCsvFile( const char* fileName, const char* fileTag, ICsvStreamCallBack*callback )
{
	std::ofstream out(fileName);
	if (out.fail())
	{
		SFLog("CsvFile::WriteCsvFile failed:fileName%s ", fileName );
		return false;
	}

	CsvWriter writer;
	if ( callback->onCsvWriteComment(&writer, fileTag) )
	{
		out << writer.GetRowStr() << '\n';
		writer.Clear();
	}

	writeTitle(writer);
	out << writer.GetRowStr() << '\n';
	writer.Clear();
	while ( callback->onCsvWriteLine(&writer, fileTag) )
	{
		out << writer.GetRowStr() << '\n';
		writer.Clear();
	}

	out.close();

	return true;
}

void CsvFile::writeTitle( CsvWriter &writer )
{
	std::string title = "@";
	title += m_itemKey[0];
	writer << title;
	for ( int i=1; i< m_itemKey.size(); i++)
	{
		writer << m_itemKey[i];
	}
}

bool CsvFile::ReadCsvMemory( char* buffer, long size, const char* fileTag, ICsvStreamCallBack* callback )
{
	if (callback == NULL)
		return false;

	std::stringstream ss;
	ss.write(buffer, size);

	ReadCsvStream(ss, fileTag, callback);
	return true;
}

bool CsvFile::ReadCsvMemory( char* buffer, long size, const char* fileTag, CCObject *target /*= NULL*/, SEL_CallFuncND callFunc /*= NULL*/ )
{
	std::stringstream ss;
	ss.write(buffer, size);

	ReadCsvStream(ss, fileTag, target, callFunc);
	return true;
}

void CsvFile::ReadCsvStream( std::istream& is, const char* fileTag, ICsvStreamCallBack* callback )
{
	std::vector<std::string> row;
	std::string line;

	int i = 0;
	int fileLine = 0;
	while(getline(is, line))
	{
		fileLine++;
		if (line.size() > 0)
		{
			ReadCsvLine(row, line, ',');
			if (row.empty() == false)
			{
				if (!m_itemKey.size())
				{
					break;
				}
				CsvKeyToValue keyToValue;
				for (CsvVector::size_type i=0;i<m_itemKey.size(); ++i)
				{
					keyToValue[m_itemKey[i]] = row[i];
				}

				CsvReader csvReader(&keyToValue);
				if ( callback->onCsvLoad(&csvReader, fileTag) == false)
				{
					SFLog("load Error:fileTag%s line:%d", fileTag, fileLine);
				}
			}
		}
	}
}

void CsvFile::ReadCsvStream( std::istream& is, const char* fileTag, CCObject *target /*= NULL*/, SEL_CallFuncND callFunc /*= NULL*/ )
{
	std::vector<std::string> row;
	std::string line;

	int i = 0;
	int fileLine = 0;
	while(getline(is, line))
	{
		fileLine++;
		if (line.size() > 0)
		{
			ReadCsvLine(row, line, ',');
			if (row.empty() == false)
			{
				if (!m_itemKey.size())
				{
					break;
				}
				CsvKeyToValue keyToValue;
				for (CsvVector::size_type i=0;i<m_itemKey.size(); ++i)
				{
					keyToValue[m_itemKey[i]] = row[i];
				}

				CsvReader csvReader(&keyToValue);
				(target->*callFunc)(NULL, (void*)&csvReader);
			}
		}
	}
}

CsvReader::CsvReader( CsvKeyToValue* rowValue)
{
	m_rowValue = rowValue;
}

CsvReader::~CsvReader()
{

}

int CsvReader::readAsInt( const char* key, int defaultValue )
{
	const char* str = getVal(key);
	int val;
	if (str && SFStringUtil::toInt(str, &val))
	{
		return val;
	}
	return defaultValue;
}

bool CsvReader::readAsBool( const char* key, bool defaultValue )
{
	const char* str = getVal(key);
	bool val;
	if (str && SFStringUtil::toBool(str, &val))
	{
		return val;
	}
	return defaultValue;
}

float CsvReader::readAsFloat( const char* key, float defalutValue )
{
	const char* str = getVal(key);
	float val;
	if (str && SFStringUtil::toFloat(str, &val))
	{
		return val;
	}
	return defalutValue;
}

const char* CsvReader::readAsString( const char* key, const char* defaultValue )
{
	const char* str = getVal(key);
	if (str)
	{
		return str;
	}
	return defaultValue;
}

const char* CsvReader::getVal( const char* key )
{
	CsvKeyToValue::iterator iter = m_rowValue->find(key);
	if (iter != m_rowValue->end() )
	{
		return (*iter).second.c_str();
	}
	return NULL;
}

void CsvWriter::WriteStr( const char*val )
{
	m_rowValue.append(val);
	m_rowValue.push_back(',');
}

void CsvWriter::WriteInt( int val )
{
	m_rowValue.append( SFStringUtil::formatString("%d,", val) );
}

void CsvWriter::WriteFloat( float val )
{
	m_rowValue.append( SFStringUtil::formatString("%.6f,", val) );
}

CsvWriter::CsvWriter()
{

}

CsvWriter::~CsvWriter()
{

}

const char* CsvWriter::GetRowStr()
{ 
	CC_ASSERT(!m_rowValue.empty());
	m_rowValue = m_rowValue.substr(0, m_rowValue.size()-1);
	return m_rowValue.c_str(); 
}
