//#include "TypeDefine.h"
#include "eventset/EventArgs.h"
#include "eventset/SubscriberSlot.h"
#include "eventset/Event.h"

namespace cocos2d {

	Event::Event(/* const char* name */)
		//:mName(name)
	{

	}

	Event::~Event()
	{
		for (SlotListType::iterator i = this->mSlotList.begin(); i != this->mSlotList.end(); ++i)
		{
			SubscriberSlot* ss = *i;
			delete ss;
		}
		this->mSlotList.clear();
	}

	void Event::SetName(const char* name)
	{
		this->mName = name;
	}

	const char* Event::GetName() const
	{
		return this->mName.c_str();
	}

	bool Event::IsMatch(const char* name) const
	{
		return this->mName == name;
	}

	void Event::Subcribe( SubscriberSlot* slot )
	{
		this->mSlotList.push_back(slot);
	}

	void Event::Unsubcribe( SubscriberSlot* slot )
	{
		SubscriberSlot* removeSlot = NULL;
		for (SlotListType::iterator i = this->mSlotList.begin(); i != this->mSlotList.end(); ++i)
		{
			SubscriberSlot* ss = *i;
			//if (ss->type == slot->type && ss->d_functor_impl  == slot->d_functor_impl)
			if (*ss == *slot)
			{
				this->mSlotList.erase(i);
				removeSlot = ss;
				break;
			}
		}
		if (removeSlot)
		{
				delete removeSlot;
		}

	}

	void Event::Fire( EventArgs& args )
	{
		if (this->mSlotList.empty())
			return ;

		SlotListType::iterator it = this->mSlotList.end(), itNext;
		it--;

		do 
		{
			itNext = it;
			if (itNext == this->mSlotList.begin())
				itNext = this->mSlotList.end();
			else
				itNext--;

			(*it)->fire(args);

			if (this->mSlotList.empty() || itNext == this->mSlotList.end())
				break;

			it = itNext;
		} while (true);
	}

	bool Event::FireMutual( EventArgs& args)
	{
		bool bRet = true;
		if (this->mSlotList.empty())//没人否决
			return bRet;

		SlotListType::iterator it = this->mSlotList.end(), itNext;
		it--;

		do 
		{
			itNext = it;
			if (itNext == this->mSlotList.begin())
				itNext = this->mSlotList.end();
			else
				itNext--;

			bRet = (*it)->fire(args);//有人否决，则返回false
			if (!bRet)
				break;

			if (itNext == this->mSlotList.end())
				break;

			it = itNext;
		} while (true);

		return bRet;
	}


}
