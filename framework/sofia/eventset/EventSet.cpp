#include "eventset/EventArgs.h"
#include "eventset/SubscriberSlot.h"
#include "eventset/Event.h"
#include "eventset/EventSet.h"

namespace cocos2d {

	EventSet::EventListType EventSet::s_EventList;

	EventSet::EventSet()
	{

	}

	EventSet::~EventSet()
	{
		this->ClearEvent();
	}

	void EventSet::ClearEvent()
	{
		for (EventListType::iterator itr = this->mEventList.begin(); itr != this->mEventList.end(); ++itr)
		{
			Event* e = *itr;
			delete e;
		}
		this->mEventList.clear();
	}

	bool EventSet::SubscribeEvent( const char* name,  SubscriberSlot* subscriber )
	{
		 Event* e = this->GetEvent(name, true);
		if (e == 0)
		{
			return false;
		}

		e->Subcribe(subscriber);
		return true;
	}


	bool EventSet::UnSubscribeEvent( const char* name, SubscriberSlot* subscriber )
	{
		Event* e = this->GetEvent(name, true);
		if (e == 0)
		{
			return false;
		}

		e->Unsubcribe(subscriber);
		return true;
	}

	bool EventSet::FireEvent( const char* name, EventArgs& args )
	{
		 Event* e = this->GetEvent(name, false);
		if (e == 0)
		{
			return false;
		}

		int handle = args.handle;
		e->Fire(args);
		if (handle != args.handle)
		{
			return true;
		}

		return false;
	}

	//互斥事件
	bool EventSet::FireMutualEvent( const char* name, EventArgs& args)
	{
		Event* e = this->GetEvent(name, false);
		if (e == 0)
			return true;
		return e->FireMutual(args);
	}

	 Event* EventSet::GetEvent( const char* name, bool autoAdd )
	{
		for (EventListType::iterator itr = this->mEventList.begin(); itr != this->mEventList.end(); ++itr)
		{
			 Event* e = *itr;
			if (e->IsMatch(name))
			{
				return e;
			}
		}

		if (autoAdd)
		{
			 Event* e = new  Event(/*name*/);
			e->SetName(name);
			this->mEventList.push_back(e);
			return e;
		}

		return 0;
	}
}
