#ifndef _PROPERTY_SYMBOL_QUARY_H_
#define _PROPERTY_SYMBOL_QUARY_H_
#include "utils/SQLiteQuary.h"
#include "core/property/PropertySymbol.h"

class PropertySymbolQuary : public SQLiteBaseQuary<PropertySymbol>
{
protected:
	virtual std::string GetTableName() {return "d_symbol";}
	virtual std::string GetNameListString() {return "id, key, symbol, name, description, type";}
	virtual std::string GetValueListString(PropertySymbol* t)
	{
		std::strstream str;
		str << t->getId() << ", ";
		str << t->getKey().c_str() << ", ";
		str << t->getSymbol().c_str() << ", ";
		str << t->getName().c_str() << ", ";
		str << t->getDescription().c_str()  << ", ";
		str << t->getType() <<  std::ends;
		const char* tt = str.str();
		return tt;
	}
	virtual std::string GetKeyNameString() { return "id";}
	virtual std::string GetKeyValueString(PropertySymbol* t)
	{
		std::strstream str;
		str << t->getId() << std::ends;
		return str.str();
	}
	virtual std::string GetUpdateKeyValueListString(PropertySymbol* t)
	{
		std::strstream str;
		str << "id = " << t->getId() << ", ";
		str << "key = " << t->getKey().c_str() << ", ";
		str << "symbol = " << t->getSymbol().c_str() << ", ";
		str << "name = " << t->getName().c_str() << ", ";
		str << "description = " << t->getDescription().c_str() << ", ";
		str << "type = " << t->getType() << std::ends;//orderlist
		return str.str();
	}

	virtual PropertySymbol* getFromRow(struct sqlite3_stmt* stmt)
	{
		PropertySymbol* ret = new PropertySymbol(sqlite3_column_int( stmt, 0 ),
												(const char*)sqlite3_column_text( stmt, 1 ),
												(const char*)sqlite3_column_text( stmt, 2 ),
												(const char*)sqlite3_column_text( stmt, 3 ),
												(const char*)sqlite3_column_text( stmt, 4 ),
												sqlite3_column_int( stmt, 5 )
												);
		return ret;
	}

	virtual void insertToRow(PropertySymbol* t, struct sqlite3_stmt* stmt)
	{

	}
};
#endif