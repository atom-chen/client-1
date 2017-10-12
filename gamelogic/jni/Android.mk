LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := gamelogic_static

LOCAL_MODULE_FILENAME := libgamelogic

LOCAL_SRC_FILES := \
../sofia/platform/android/SFLoginManager.cpp \
../sofia/platform/android/SFGameHelper.cpp   \
../sofia/platform/android/SFGameAnalyzer.cpp \
../sofia/platform/android/com_morningglory_shell_GardeniaLogin.cpp 


LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include/platform \
											

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../ \
										$(LOCAL_PATH)/../include \
										$(LOCAL_PATH)/../include/platform \
										$(LOCAL_PATH)/../include/platform/android \
										$(LOCAL_PATH)/../../cocos2dx \
                    $(LOCAL_PATH)/../../cocos2dx/include \
                    $(LOCAL_PATH)/../../cocos2dx/platform \
                    $(LOCAL_PATH)/../../cocos2dx/platform/android \
                    $(LOCAL_PATH)/../../cocos2dx/kazmath/include \
                    $(LOCAL_PATH)/../../CocosDenshion/include \
                    $(LOCAL_PATH)/../../framework \
										$(LOCAL_PATH)/../../framework/include \
										$(LOCAL_PATH)/../../extensions
						

LOCAL_WHOLE_STATIC_LIBRARIES := cocos_extension_static cocos2dx_static framework_static

include $(BUILD_STATIC_LIBRARY)

$(call import-module,extensions)\
$(call import-module,framework\jni) \
$(call import-module,cocos2dx)
