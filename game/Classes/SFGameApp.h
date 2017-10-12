#include "base/SFApp.h"
#include "cocos2d.h"
USING_NS_CC;

class SFGameApp :public SFApp
{
public:
	SFGameApp(){ };
	~SFGameApp(){ };
	static SFGameApp* createGameApp();
	virtual void onInit(){};
	virtual void onDestory() {};
private:

};
