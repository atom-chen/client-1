#include "resource/SFResourceLoad.h"
#define LOADING_LESS_FRAME				24.0f
#define LOADING_WAIT_FRAME				50.0f
#define LOADING_BACKGROUND_FRAME		18.0f
#define LOADING_WAIT			(1 / LOADING_WAIT_FRAME)
#define LOADING_BACKGROUND		(1 / LOADING_BACKGROUND_FRAME)
USING_NS_CC;
SFResourceLoad::SFResourceLoad()
	: m_eventCallback(NULL)
	, m_deltaTime(LOADING_WAIT)
	, m_curDeltaTime(LOADING_WAIT)
	, m_frame(LOADING_WAIT_FRAME)
	, m_nScriptHandler(0)
	, m_allLoadingCount(0)
{
	m_pLastUpdate = new struct cc_timeval();
	CCDirector::sharedDirector()->getScheduler()->scheduleSelector( schedule_selector(SFResourceLoad::tick), this, 0.0f, false);
}

SFResourceLoad::~SFResourceLoad()
{
	CC_SAFE_DELETE(m_pLastUpdate);
	CCDirector::sharedDirector()->getScheduler()->unscheduleSelector( schedule_selector(SFResourceLoad::tick), this );
}
static SFResourceLoad *g_sharedResourceLoadCache = NULL;
SFResourceLoad* SFResourceLoad::sharedResourceLoadCache()
{
	if (!g_sharedResourceLoadCache)
	{
		g_sharedResourceLoadCache = new SFResourceLoad();
	}
	return g_sharedResourceLoadCache;
}

void SFResourceLoad::purgeSharedResourceLoadCache()
{
	CC_SAFE_RELEASE_NULL(g_sharedResourceLoadCache);
}

void SFResourceLoad::addLoadingModule( ISFLoadResourceModule* module )
{
	m_loadModule.push_back(module);
	m_allLoadingCount += module->loadingObjectCount();
}

bool SFResourceLoad::removeLoadingModule( ISFLoadResourceModule* module )
{
	for (ResModuleVecter::iterator iter = m_loadModule.begin(); iter != m_loadModule.end(); ++iter)
	{
		if(*iter == module)
		{
			(*iter)->release();
			m_loadModule.erase(iter);
			return true;
		}
	}
	return false;
}

void SFResourceLoad::clearLoadingModule()
{
	for (ResModuleVecter::iterator iter = m_loadModule.begin(); iter != m_loadModule.end(); ++iter)
	{
		(*iter)->release();
	}
	m_loadModule.clear();
	setCompleteEventOnce(NULL);
	m_nScriptHandler = 0;
	m_allLoadingCount = 0;
}

void SFResourceLoad::tick( float dt )
{
	if (!m_loadModule.empty())
	{
		static CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		static float frame = LOADING_WAIT_FRAME;
		static int count = 0;
		static float oldDt = LOADING_WAIT;
		//处理平滑的加载
		if(m_nScriptHandler == 0 || m_eventCallback == NULL)
		{
			//如果dt大于现在运行效率，则降低现在一帧去渲染。
			if( m_deltaTime <= dt)
			{
				// 如果在最低帧数以上
				// 重置
				frame = m_frame;
				m_curDeltaTime = 1 / frame;
			}
			else
			{
				// 如果当前在最低帧数以下，降低帧数要求
				// 需要确保，帧数不少于24帧。以24帧作为最低要求
				// 如果当前帧的效率比上一帧效率要高，则不需要继续降帧（保持现有的效率或者提升帧数）
				if(frame > LOADING_LESS_FRAME && oldDt > dt)
				{
					frame -= 6.0f;
				}
				else
				{
					if((frame - (1 / (dt - oldDt))) > 2.0f)
						frame += 2.0f;
				}
				m_curDeltaTime = 1 / frame;
				oldDt = dt;
			}
		}
		for (ResModuleVecter::iterator iter = m_loadModule.begin(); iter != m_loadModule.end();)
		{
			ISFLoadResourceModule* module = *iter;
			
			while (module->loadObject())
			{
				++count;
// 				if (m_nScriptHandler && m_allLoadingCount)
// 				{
// 					pEngine->executeLoadingBackground(m_nScriptHandler, count/m_allLoadingCount, "");
// 				}
				struct cc_timeval now;
				if (CCTime::gettimeofdayCocos2d(&now, NULL) != 0)
				{
					return;
				}
				dt += (now.tv_sec - m_pLastUpdate->tv_sec) + (now.tv_usec - m_pLastUpdate->tv_usec) / 1000000.0f;
				*m_pLastUpdate = now;
				if( m_curDeltaTime < dt )
				{
					return;
				}
			}

			if(module->getAutoDel())
			{
				CC_SAFE_RELEASE_NULL(module);
				iter = m_loadModule.erase(iter);
			}
			else
				++iter;
		}
		if (m_eventCallback)
		{
			m_eventCallback->onLoadCompleted();
			m_eventCallback = NULL;
		}
		if (m_nScriptHandler)
		{
			CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
			pEngine->executeLoadingBackground(m_nScriptHandler, 1.0f, "Loading Completed!");
			m_nScriptHandler = 0;
		}
		m_deltaTime = LOADING_WAIT;
		m_curDeltaTime = LOADING_WAIT;
		m_frame = LOADING_WAIT_FRAME;
		frame = LOADING_WAIT_FRAME;
		oldDt = LOADING_WAIT;
		count=0;
		m_allLoadingCount = 0;
	}
}

void SFResourceLoad::setCompleteEventOnce( ISFLoadingCompleteEvent* event )
{
	if(event)
	{
		m_deltaTime = LOADING_BACKGROUND;
		m_frame = LOADING_BACKGROUND_FRAME;
	}
	m_eventCallback = event;
}

void SFResourceLoad::setCompleteEventOnceHandler( int handler )
{
	m_curDeltaTime = m_deltaTime = LOADING_BACKGROUND;
	m_frame = LOADING_BACKGROUND_FRAME;
	if(!m_nScriptHandler)
		m_nScriptHandler = handler;
}

int SFResourceLoad::getCompleteEventOnceHandler()
{
	return m_nScriptHandler;
}
