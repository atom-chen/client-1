LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE    := cocos_lua_static

LOCAL_MODULE_FILENAME := liblua

LOCAL_SRC_FILES :=../lua/cjson/fpconv.c \
          ../lua/cjson/lua_cjson.c \
          ../lua/cjson/lua_extensions.c \
          ../lua/cjson/strbuf.c \
          ../tolua/tolua_event.c \
          ../tolua/tolua_is.c \
          ../tolua/tolua_map.c \
          ../tolua/tolua_push.c \
          ../tolua/tolua_to.c \
          ../cocos2dx_support/CCLuaBridge.cpp \
          ../cocos2dx_support/CCLuaEngine.cpp \
          ../cocos2dx_support/CCLuaStack.cpp \
          ../cocos2dx_support/CCLuaValue.cpp \
          ../cocos2dx_support/Cocos2dxLuaLoader.cpp \
          ../cocos2dx_support/LuaCocos2d.cpp \
          ../cocos2dx_support/LuaFramework.cpp \
          ../cocos2dx_support/SFScriptManager.cpp \
          ../cocos2dx_support/tolua_fix.c \
          ../cocos2dx_support/Lua_web_socket.cpp
          
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../lua \
                           $(LOCAL_PATH)/../tolua \
                           $(LOCAL_PATH)/../cocos2dx_support 
          
          
LOCAL_C_INCLUDES := $(LOCAL_PATH)/ \
										$(LOCAL_PATH)/.. \
                    $(LOCAL_PATH)/../lua \
                    $(LOCAL_PATH)/../tolua \
                    $(LOCAL_PATH)/../../../cocos2dx \
                    $(LOCAL_PATH)/../../../cocos2dx/include \
                    $(LOCAL_PATH)/../../../cocos2dx/platform \
                    $(LOCAL_PATH)/../../../cocos2dx/platform/android \
                    $(LOCAL_PATH)/../../../cocos2dx/kazmath/include \
                    $(LOCAL_PATH)/../../../CocosDenshion/include \
                    $(LOCAL_PATH)/../../../framework \
										$(LOCAL_PATH)/../../../framework/include \
										$(LOCAL_PATH)/../../../gamelogic \
										$(LOCAL_PATH)/../../../external/libwebsockets/android/include
                    
LOCAL_CFLAGS += -Wno-psabi
LOCAL_EXPORT_CFLAGS += -Wno-psabi

LOCAL_WHOLE_STATIC_LIBRARIES := cocos_extension_static framework_static luajit_static libwebsockets_static

include $(BUILD_STATIC_LIBRARY)

$(call import-module,extensions)
$(call import-module,framework)
$(call import-module,scripting/lua/luajit)
$(call import-module,external/libwebsockets/android)