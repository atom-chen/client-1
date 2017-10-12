#include "SFGameApp.h"

SFGameApp* SFGameApp::createGameApp()
{
	SFGameApp* app = new SFGameApp();
	if (app && app->init())
	{
		app->retain();
		return app;
	}
	CC_SAFE_DELETE(app);
	return NULL;
}