LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := gamelogic_static
LOCAL_MODULE_FILENAME := libgamelogic
LOCAL_SRC_FILES := $(LOCAL_PATH)/proj.android/libgamelogic.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include  
include $(PREBUILT_STATIC_LIBRARY)

$(call import-module,cocos2dx)
