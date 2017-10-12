LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := framework_static
LOCAL_MODULE_FILENAME := libframework
LOCAL_SRC_FILES := $(LOCAL_PATH)/proj.android/libframework.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include  \
$(LOCAL_PATH)/
include $(PREBUILT_STATIC_LIBRARY)

$(call import-module,cocos2dx)
