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
#include "../../UIControl/include/ui/control/SFRichBox.h"
#include "../../UIControl/include/ui/control/SFLabel.h"
#include "scene/SFGamePresenter.h"
#include "scene/SFGameScene.h"
#include "scene/SFGameSceneMgr.h"
#include "../../UIControl/include/ui/factory/SFControlFactory.h"
#include "../../UIControl/include/ui/factory/SFControlFactoryManager.h"
#include "SFSimulator.h"
#include "utils/StreamDataAdapter.h"
#include "stream/iStream.h"
#include "../../UIControl/include/ui/utils/VisibleRect.h"
#include "GUI/CCControlExtension/CCInvocation.h"
#include "GUI/CCControlExtension/CCScale9Sprite.h"
#include "../../UIControl/include/ui/control/SFCheckBox.h"
#include "../../UIControl/include/ui/control/SFScrollView.h"
#include "../../UIControl/include/ui/control/SFTabView.h"
#include "utils/SFPriorityNotificationCenter.h"
#include "map/SFMap.h"
#include "core/RpgSprite.h"
#include "map/RenderInterface.h"
#include "map/SFMapService.h"
#include "../../UIControl/include/ui/control/SFTableCell.h"
#include "../../UIControl/include/ui/control/SFTableView.h"
#include "../../UIControl/include/ui/control/SFGridBox.h"
#include "core/RpgSprite.h"
#include "map/SpriteMove.h"
#include "include/utils/SFTimeAxis.h"
#include "../../UIControl/include/ui/control/SFJoyRocker.h"
#include "../../UIControl/include/ui/control/SFProgressBar.h"
#include "../../UIControl/include/ui/control/SFLabelTex.h"
#include "../../UIControl/include/ui/control/SFRichLabel.h"
#include "../../UIControl/include/ui/control/SFGraySprite.h"
#include "core/SFRenderSprite.h"
#include "actions/CCActionShaderColor.h"
#include "include/platform/SFGameHelper.h"
#include "include/platform/SFGameAnalyzer.h"
#include "include/map/LogicFinder.h"
#include "include/core/RenderScene.h"
#include "include/platform/SFLoginManager.h"
#include "include/package/SFPackageManager.h"
#include "include/utils/HttpTools.h"
#include "include/utils/SFEasyMail.h"
#include "include/platform/SFGameAnalyzer.h"
#include "SFScriptManager.h"
#include "include/download/SFDownload.h"
#include "../../UIControl/include/ui/control/SFControlSlider.h"
#include "include/map/SFSpriteEvent.h"
#include "../framework/include/utils/HTTPHandler/Base64Code.h"

using namespace cocos2d;
using namespace CocosDenshion;
using namespace core;
using namespace cmap;


TOLUA_API int tolua_LuaFramework_open(lua_State* tolua_S);

#endif // __LUACOCOS2D_H_