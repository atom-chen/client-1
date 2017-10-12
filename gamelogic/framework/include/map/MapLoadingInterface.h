#ifndef _MapLoadingInterface_h__
#define _MapLoadingInterface_h__

class IMapLoadingCompleteEvent
{
public:	 
	IMapLoadingCompleteEvent() {}
	virtual ~IMapLoadingCompleteEvent() {}
	virtual void onMapLoadCompleted() = 0;
};

#endif // _MapLoadingInterface_h__