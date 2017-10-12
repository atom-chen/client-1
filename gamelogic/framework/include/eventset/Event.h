#ifndef _INTERFACE_EVENT_H_
#define _INTERFACE_EVENT_H_
#include <vector>
#include <string>
#include <list>

namespace cocos2d {

	class EventArgs;
	class SubscriberSlot;

	class Event 
	{
	public:
		Event(/*const char* name*/);
		~Event();

	public:
		void SetName(const char* name);
		const char* GetName() const;
		bool IsMatch(const char* name) const;

		void Subcribe(SubscriberSlot* slot);
		void Unsubcribe(SubscriberSlot* slot);
		void Fire(EventArgs& args);
		bool FireMutual(EventArgs& args);

	private:
		typedef std::list<SubscriberSlot*> SlotListType;
		std::string mName;
		SlotListType mSlotList;
	};
}

#endif
