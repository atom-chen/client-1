#include "Utils/HttpTools.h"
#include "script_support/CCScriptSupport.h"
static HttpTools* instance = NULL;

HttpTools* HttpTools::getInstance()
{
	if (!instance)
	{
		instance = new HttpTools();
	}
	return instance;
}

void HttpTools::send(const char* url,int  type, const char* tag,const char* userData,int len )
{
	CCHttpRequest* request = new CCHttpRequest();
	request->setTag(tag);
	request->setUrl(url);
	if (len >0 && userData != NULL)
	{
		request->setRequestData(userData,len);
	}
	switch (type)
	{
	case kTypePost:
		request->setRequestType(CCHttpRequest::kHttpGet);
		
		break;
	case kTypeGet:
		request->setRequestType(CCHttpRequest::kHttpGet);
		break;
	}
	request->setResponseCallback(this,callfuncND_selector(HttpTools::requestCallBack));
	CCHttpClient::getInstance()->send(request);
}

void HttpTools::requestCallBack( CCObject *sender, void *data  )
{
	CCHttpResponse* response = (CCHttpResponse*)data;
	if (response && m_handler)
	{
			std::string ret;
			std::vector<char> *buffer = response->getResponseData();
			int size = buffer->size();
			//char* pBuffer = new char[size+1];
			//memset(pBuffer, 0, size+1);
			//strcpy(pBuffer, &(*buffer)[0]);
			for (int i = 0; i < size; ++i)
			{
				ret.push_back((*buffer)[i]);
			}
			int state = response->getResponseCode();
			const char* tag = response->getHttpRequest()->getTag();
			//const char* responeData = ret.c_str();
			CCLog("http state:%d", state);
			CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
			engine->executeHttpEvent(m_handler,state,tag, ret.c_str(), size);
			//delete[] pBuffer;
	}
	if (response)
	{
		response->getHttpRequest()->release();
	}
}

void HttpTools::registLuaCallBack( int nhandler )
{
	m_handler = nhandler;
}

HttpTools::HttpTools()
{
	m_handler = 0;
}

HttpTools::~HttpTools()
{

}
