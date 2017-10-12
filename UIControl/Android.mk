LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libuicontrol_static
#LOCAL_MODULE_FILENAME := libUIControl

LOCAL_SRC_FILES := \
sofia/ui/control/SFBaseControl.cpp \
sofia/ui/control/SFCheckBox.cpp \
sofia/ui/control/SFGraySprite.cpp \
sofia/ui/control/SFGridBox.cpp \
sofia/ui/control/SFJoyRocker.cpp \
sofia/ui/control/SFLabel.cpp \
sofia/ui/control/SFLabelTex.cpp \
sofia/ui/control/SFProgressBar.cpp \
sofia/ui/control/SFRichBox.cpp \
sofia/ui/control/SFRichLabel.cpp \
sofia/ui/control/SFScale9Sprite.cpp \
sofia/ui/control/SFScrollView.cpp \
sofia/ui/control/SFSharedFontManager.cpp \
sofia/ui/control/SFTableView.cpp \
sofia/ui/control/SFTabView.cpp \
sofia/ui/control/SFTabViewControl.cpp \
sofia/ui/control/SFTouchLayer.cpp \
sofia/ui/control/SFControlSlider.cpp \
sofia/ui/factory/SFControlFactory.cpp  \
sofia/ui/factory/SFControlFactoryExtension.cpp  \
sofia/ui/factory/SFControlFactoryManager.cpp  \
sofia/ui/utils/ThirdTool.cpp  \
sofia/ui/utils/VisibleRect.cpp  

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include \
												$(LOCAL_PATH)/include/ui \
                    $(LOCAL_PATH)/include/ui/control \
                   $(LOCAL_PATH)/include/ui/factory \
                   $(LOCAL_PATH)/include/ui/utils 

LOCAL_C_INCLUDES := $(LOCAL_PATH)/include \
										$(LOCAL_PATH)/../cocos2dx \
                    $(LOCAL_PATH)/../cocos2dx/include \
                    $(LOCAL_PATH)/../cocos2dx/platform \
                    $(LOCAL_PATH)/../cocos2dx/platform/android \
                    $(LOCAL_PATH)/../cocos2dx/kazmath/include \
                    $(LOCAL_PATH)/../CocosDenshion/include \
                    $(LOCAL_PATH)/../framework \
										$(LOCAL_PATH)/../framework/include \
           					$(LOCAL_PATH)/../third_party/libiconv/include

LOCAL_WHOLE_STATIC_LIBRARIES := libiconv cocos_extension_static cocos2dx_static framework_static

include $(BUILD_STATIC_LIBRARY)

$(call import-module,extensions)\
$(call import-module,framework) \
$(call import-module,third_party/libiconv) \
$(call import-module,cocos2dx)
