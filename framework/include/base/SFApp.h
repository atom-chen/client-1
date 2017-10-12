//Beneath this mask there is more than flesh
//Beneath this mask there is an idea, Mr.Creedy, and ideas are bulletproof.
#ifndef _SFAPP_H
#define _SFAPP_H

#include "sofia.h"

//框架app
class SFApp : public cocos2d::CCScene//RTLayer
{

public:
	SFApp();
	virtual ~SFApp();

public:
	int getScreenResolutionX();
	int getScreenResolutionY();

protected:
	bool init();

	virtual void onInit() = 0;
	virtual void onDestory() = 0;
	virtual void onTick(int microSecs);
	virtual void onDraw();
	
private:
	virtual void update(float dt);
	virtual void draw(void);
	virtual void onExit();

	void startRun();
	int m_width;
	int m_height;
};


#endif