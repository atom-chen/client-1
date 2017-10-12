#ifndef __LOGIN_H_
#define __LOGIN_H_

extern "C" {
#include "tolua++.h"
#include "tolua_fix.h"
}

#include <map>
#include <string>
#include "tolua_fix.h"
#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "ui/control/SFRichBox.h"
#include "ui/control/SFLabel.h"
#include "ui/control/SFButton.h"
#include "scene/SFGamePresenter.h"
#include "scene/SFGameScene.h"
#include "scene/SFGameSceneMgr.h"

using namespace cocos2d;
using namespace CocosDenshion;

TOLUA_API int tolua_LoginFrame_open(lua_State* tolua_S);

#endif // __LUACOCOS2D_H_