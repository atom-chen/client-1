#ifndef HTTP_TOOLS_H
#define  HTTP_TOOLS_H
#include "cocos2d.h"
#include "cocos-ext.h"
USING_NS_CC;
USING_NS_CC_EXT;
enum
{
	kTypePost,
	kTypeGet,
};

class HttpTools : public CCObject
{
public:
	static HttpTools* getInstance();

	void send(const char* url,int  type, const char* tag,const char* userData,int len);

	void requestCallBack(CCObject *sender, void *data );

	void registLuaCallBack(int nhandler);
	HttpTools();
	~HttpTools();

private:
	int m_handler;
};


#endif