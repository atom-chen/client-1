LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := game

LOCAL_MODULE_FILENAME := libgame

LOCAL_SRC_FILES := src/main.cpp \
									../../game/Classes/AppDelegate.cpp \
									../../game/Classes/SFGameApp.cpp 
									
LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static cocos_extension_static cocos_lua_static libpack_static framework_static libuicontrol_static gamelogic_static
                           
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../game/Classes \
										$(LOCAL_PATH)/src \
													$(LOCAL_PATH)/../../framework \
													$(LOCAL_PATH)/../../framework/include \
														
LOCAL_CFLAGS += -DCOCOS2D_DEBUG
                    
include $(BUILD_SHARED_LIBRARY)

$(call import-module,cocos2dx) \
$(call import-module,extensions) \
$(call import-module,framework) \
$(call import-module,zpack) \
$(call import-module,scripting/lua/proj.android) \
$(call import-module,UIControl) \
$(call import-module,gamelogic)





