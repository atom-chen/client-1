/********************************************************************
	created:	2014/03/25
	created:	25:3:2014   17:10
	filename: 	E:\client\branch\v0.3.4.0\scripting\lua\luajit\include\loader_zpk.h
	file path:	E:\client\branch\v0.3.4.0\scripting\lua\luajit\include
	file base:	loader_zpk
	file ext:	h
	author:		Liu Rui
	
	purpose:	从zpk读取lua文件的中间组件
*********************************************************************/
#include "lua.h"

lua_CFunction zpkLoaderFunc = NULL;

void setZpkLoaderFunc(lua_CFunction func)
{
	zpkLoaderFunc = func;
}

int load_zpk(lua_State *L)
{
	if (zpkLoaderFunc)
	{
		(*zpkLoaderFunc)(L);
		return 1;
	}
	return 0;
}