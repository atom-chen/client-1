﻿#ifndef SINGLETON_H
#define SINGLETON_H

#include <assert.h>

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#include<stdlib.h>
#endif

/** 单实例模板.

 示例：
 @code
 struct CFooSingleton : public SingletonEx<CFooSingleton>
 {
	Void foo()
	{
		Trace("foo!\n");
	}
 };	

 int main(int,int*)
 {
	new CFooSingleton();
	
	// 调用 foo 函数的方法：
	CFooSingleton::getInstance().foo();

	delete CFooSingleton::getInstancePtr();
 }
 @endcode
 */

namespace cocos2d {
	template<class T, bool mustDelete = true>
	class Singleton
	{
		static T*	_instance;		/// 实例静态指针
	public:
		static T& getInstance()
		{
			if (!_instance)
			{
				_instance = new T;
				_instance->init();
				if (mustDelete) atexit(releaseInstance);
			}

			return *_instance;
		}

		static T* getInstancePtr()
		{
			return &getInstance();
		}
		static void releaseInstance()
		{
			if (_instance && mustDelete)
			{
				delete _instance;
				_instance = 0;
			}
		}
		virtual void init(){};
	protected:
		/// 使用保护构造是为了用户不能在栈上声明一个实例
		Singleton() { }
	};

	/// 静态实例指针初始化
	template <class T, bool mustDelete> T* Singleton<T, mustDelete>::_instance = 0;



	/// 扩展的单实体模板，不关心对象的创建和销毁
	/// 采用外部new和delete，这种单实体的好处是外部能控制构造和析构的顺序
	template <typename T>
	class SingletonEx
	{
	protected:
		static T*	_instance;

	public:
		SingletonEx()
		{
			assert(!_instance);
			_instance = static_cast<T*>(this);
		}

		~SingletonEx()
		{
			assert(_instance);
			_instance = 0;
		}

		static T& getInstance()		{ assert(_instance); return (*_instance); }
		static T* getInstancePtr()	{ return _instance; }
	};

	template <typename T> T* SingletonEx<T>::_instance = 0;

}
#endif