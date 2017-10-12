#ifndef _INTERFACE_EVENT_SET_H_
#define _INTERFACE_EVENT_SET_H_
#include <vector>

namespace cocos2d {

	class Event;
	class SubscriberSlot;
	class EventArgs;

	class EventSet
	{
	public:
		EventSet();
		virtual ~EventSet();

	public:
		virtual void ClearEvent();
		virtual bool SubscribeEvent(const char* name, SubscriberSlot* subscriber);
		virtual bool UnSubscribeEvent(const char* name, SubscriberSlot* subscriber);

		virtual bool FireEvent(const char* name, EventArgs& args);
		//互斥事件，有处理返回flase则直接跳出;默认返回true
		virtual bool FireMutualEvent(const char* name, EventArgs& args);
		
		//static bool SubscribePublicEvent(const char* name, SubscriberSlot* subscriber);
		//virtual bool SubscribeScriptedEvent(const char* name, const char* scriptedName);
		//virtual bool SubscribeScriptedPublicEvent(const char* name, const char* scriptedName);

	protected:
		Event* GetEvent(const char* name, bool autoAdd);
		//static Event* GetSEvent(const char* name, bool autoAdd);
	private:
		typedef std::vector<Event*> EventListType;
		EventListType mEventList;
		static EventListType s_EventList;
	};
}

#endif
