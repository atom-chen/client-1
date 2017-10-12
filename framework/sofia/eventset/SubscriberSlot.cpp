#include "eventset/SubscriberSlot.h"

namespace cocos2d {

	SubscriberSlot::SubscriberSlot()
		:d_functor_impl(0),type(0)
	{
	}


	SubscriberSlot::~SubscriberSlot()
	{
		cleanup();
	}

	void SubscriberSlot::cleanup()
	{
		if (d_functor_impl)
		{
			delete d_functor_impl;
			d_functor_impl = 0;
		}
	}

}
