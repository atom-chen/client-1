#ifndef _INTERFACE_SUBSCRIBERSLOT_H_
#define _INTERFACE_SUBSCRIBERSLOT_H_
//#include "EventArgs.h"

namespace cocos2d {

	class EventArgs;

	class SlotFunctorBase
	{
	public:
		virtual ~SlotFunctorBase() {};
		virtual bool operator()(const EventArgs& args) = 0;
		virtual bool operator==(const SlotFunctorBase& other) = 0;
	};

	class FreeFunctionSlot : public SlotFunctorBase
	{
	public:
		//! Slot function type.
		typedef bool (SlotFunction)(const EventArgs&);

		FreeFunctionSlot(SlotFunction* func) :
		d_function(func)
		{}

		virtual bool operator()(const EventArgs& args)
		{
			return d_function(args);
		}

		bool operator == (const SlotFunctorBase& f)
		{
			const FreeFunctionSlot & other =  ( const FreeFunctionSlot&  )f;
			return (other.d_function == this->d_function);
		}

	private:
		SlotFunction* d_function;
	};

	template<typename T>
	class FunctorPointerSlot : public SlotFunctorBase
	{
	public:
		FunctorPointerSlot(T* functor) :
		  d_functor(functor)
		  {}

		  virtual bool operator()(const EventArgs& args)
		  {
			  return (*d_functor)(args);
		  }

		  bool operator == (const SlotFunctorBase& f)
		  {
			  const FunctorPointerSlot<T>& other =  ( const FunctorPointerSlot<T>&  )f;
			  return (other.d_functor == this->d_functor);
		  }

	private:
		T* d_functor;
	};

	template<typename T>
	class FunctorCopySlot : public SlotFunctorBase
	{
	public:
		FunctorCopySlot(const T& functor) :
		  d_functor(functor)
		  {}

		  virtual bool operator()(const EventArgs& args)
		  {
			  return d_functor(args);
		  }

// 		  bool operator == (const FunctorCopySlot<T>& f)
// 		  {
// 			  return (f.d_functor == this->d_functor)
// 		  }

		  bool operator == (const SlotFunctorBase& f)
		  {
			  const FunctorCopySlot<T> & other =  ( const FunctorCopySlot<T>&  )f;
			  return (other.d_functor == this->d_functor);
		  }

	private:
		T d_functor;
	};
	template<typename T>
	class FunctorReferenceSlot : public SlotFunctorBase
	{
	public:
		FunctorReferenceSlot(T& functor) :
		  d_functor(functor)
		  {}

		  virtual bool operator()(const EventArgs& args)
		  {
			  return d_functor(args);
		  }

		  bool operator == (const FunctorReferenceSlot<T>& f)
		  {
			  return (f.d_functor == this->d_functor);
		  }
	private:
		T& d_functor;
	};

	template<typename T>
	class MemberFunctionSlot : public SlotFunctorBase
	{
	public:
		//! Member function slot type.
		typedef bool(T::*MemberFunctionType)(const EventArgs&);

		MemberFunctionSlot(MemberFunctionType func, T* obj) :
		d_function(func),
			d_object(obj)
		{}

		virtual bool operator()(const EventArgs& args)
		{
			return (d_object->*d_function)(args);
		}

		bool operator == (const SlotFunctorBase& f)
		{
			const MemberFunctionSlot<T>& other =  ( const MemberFunctionSlot<T>&  )f;
			return (other.d_function == this->d_function && other.d_object == this->d_object);
		}

// 		bool operator== (const MemberFunctionSlot<T>& f)
// 		{
// 			return (f.d_function == this->d_function && f.d_object == this->d_object)
// 		}
	private:
		MemberFunctionType d_function;
		T* d_object;
	};

	template<typename T>
	struct FunctorReferenceBinder
	{
		FunctorReferenceBinder(T& functor) :
			d_functor(functor)
		{}

// 		bool operator == (const FunctorReferenceBinder<T>& f)
// 		{
// 			return (f.d_functor == this->d_functor)
// 		}
		bool operator == (const SlotFunctorBase& f)
		{
			const FunctorReferenceBinder<T>& other =  ( const FunctorReferenceBinder<T>&  )f;
			return (other.d_functor == this->d_functor );
		}
		T& d_functor;
	};

	class SubscriberSlot
	{
	public:
		enum
		{
			eMemberFunctionSlot,
			eFunctorReferenceSlot,
			eFunctorCopySlot,
			eFunctorPointerSlot,
		};

		/*!
		\brief
		Default constructor.  Creates a SubscriberSlot with no bound slot.
		*/
		SubscriberSlot();

		/*!
		\brief
		Creates a SubscriberSlot that is bound to a free function.
		*/
		//SubscriberSlot(FreeFunctionSlot::SlotFunction* func);

		/*!
		\brief
		Destructor.  Note this is non-virtual, which should be telling you not
		to sub-class!
		*/
		~SubscriberSlot();

		bool operator == (const SubscriberSlot& slot)
		{
			if (slot.type == this->type)
			{
				return *(this->d_functor_impl) == (*slot.d_functor_impl);
			}
			return false;
		}

		/*!
		\brief
		Invokes the slot functor that is bound to this Subscriber.  Returns
		whatever the slot returns, unless there is not slot bound when false is
		always returned.
		*/
		bool operator()(const EventArgs& args) const
		{
			return (*d_functor_impl)(args);
		}
		bool fire(const EventArgs& args) const
		{
			return (*d_functor_impl)(args);
		}
		/*!
		\brief
		Returns whether the SubscriberSlot is internally connected (bound).
		*/
		bool connected() const
		{
			return d_functor_impl != 0;
		}

		/*!
		\brief
		Disconnects the slot internally and performs any required cleanup
		operations.
		*/
		void cleanup();

		// templatised constructors
		/*!
		\brief
		Creates a SubscriberSlot that is bound to a member function.
		*/
		template<typename T>
			SubscriberSlot(bool (T::*function)(const EventArgs&), T* obj) :
		d_functor_impl(new MemberFunctionSlot<T>(function, obj)),type(eMemberFunctionSlot)
		{}

		/*!
		\brief
		Creates a SubscriberSlot that is bound to a functor object reference.
		*/
		template<typename T>
			SubscriberSlot(const FunctorReferenceBinder<T>& binder) :
		d_functor_impl(new FunctorReferenceSlot<T>(binder.d_functor)),type(eFunctorReferenceSlot)
		{}

		/*!
		\brief
		Creates a SubscriberSlot that is bound to a copy of a functor object.
		*/
		template<typename T>
			SubscriberSlot(const T& functor) :
		d_functor_impl(new FunctorCopySlot<T>(functor)),type(eFunctorCopySlot)
		{}

		/*!
		\brief
		Creates a SubscriberSlot that is bound to a functor pointer.
		*/
		template<typename T>
			SubscriberSlot(T* functor) :
		d_functor_impl(new FunctorPointerSlot<T>(functor)),type(eFunctorPointerSlot)
		{}

	public:
		int type;
		//! Points to the internal functor object to which we are bound
		SlotFunctorBase* d_functor_impl;
	};

}

#endif
