LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE    := cocos_extension_static

LOCAL_MODULE_FILENAME := libextension

LOCAL_SRC_FILES := CCBReader/CCData.cpp \
GUI/CCControlExtension/CCControl.cpp \
GUI/CCControlExtension/CCControlButton.cpp \
GUI/CCControlExtension/CCControlColourPicker.cpp \
GUI/CCControlExtension/CCControlHuePicker.cpp \
GUI/CCControlExtension/CCControlSaturationBrightnessPicker.cpp \
GUI/CCControlExtension/CCControlSlider.cpp \
GUI/CCControlExtension/CCControlSwitch.cpp \
GUI/CCControlExtension/CCControlUtils.cpp \
GUI/CCControlExtension/CCInvocation.cpp \
GUI/CCControlExtension/CCScale9Sprite.cpp \
GUI/CCControlExtension/CCControlPotentiometer.cpp \
GUI/CCControlExtension/CCControlStepper.cpp \
GUI/CCScrollView/CCScrollView.cpp \
GUI/CCScrollView/CCTableView.cpp \
GUI/CCScrollView/CCTableViewCell.cpp \
GUI/CCScrollView/CCSorting.cpp \
GUI/CCEditBox/CCEditBox.cpp \
GUI/CCEditBox/CCEditBoxImplAndroid.cpp \
network/HttpClient.cpp \
network/WebSocket.cpp \
LocalStorage/LocalStorageAndroid.cpp \
spine/Animation.cpp \
spine/AnimationState.cpp \
spine/AnimationStateData.cpp \
spine/Atlas.cpp \
spine/AtlasAttachmentLoader.cpp \
spine/Attachment.cpp \
spine/AttachmentLoader.cpp \
spine/Bone.cpp \
spine/BoneData.cpp \
spine/Json.cpp \
spine/RegionAttachment.cpp \
spine/Skeleton.cpp \
spine/SkeletonData.cpp \
spine/SkeletonJson.cpp \
spine/Skin.cpp \
spine/Slot.cpp \
spine/SlotData.cpp \
spine/extension.cpp \
spine/spine-cocos2dx.cpp \
CocoStudio/Action/CCActionFrame.cpp \
CocoStudio/Action/CCActionFrameEasing.cpp  \
CocoStudio/Action/CCActionManager.cpp  \
CocoStudio/Action/CCActionNode.cpp  \
CocoStudio/Action/CCActionObject.cpp  \
CocoStudio/Action/CCActionEaseEx.cpp \
CocoStudio/Armature/CCArmature.cpp \
CocoStudio/Armature/CCBone.cpp \
CocoStudio/Armature/animation/CCArmatureAnimation.cpp \
CocoStudio/Armature/animation/CCProcessBase.cpp \
CocoStudio/Armature/animation/CCTween.cpp \
CocoStudio/Armature/datas/CCDatas.cpp \
CocoStudio/Armature/display/CCBatchNode.cpp \
CocoStudio/Armature/display/CCDecorativeDisplay.cpp \
CocoStudio/Armature/display/CCDisplayFactory.cpp \
CocoStudio/Armature/display/CCDisplayManager.cpp \
CocoStudio/Armature/display/CCSkin.cpp \
CocoStudio/Armature/physics/CCColliderDetector.cpp \
CocoStudio/Armature/utils/CCArmatureDataManager.cpp \
CocoStudio/Armature/utils/CCArmatureDefine.cpp \
CocoStudio/Armature/utils/CCDataReaderHelper.cpp \
CocoStudio/Armature/utils/CCSpriteFrameCacheHelper.cpp \
CocoStudio/Armature/utils/CCTransformHelp.cpp \
CocoStudio/Armature/utils/CCTweenFunction.cpp \
CocoStudio/Armature/utils/CCUtilMath.cpp \
CocoStudio/Components/CCComAttribute.cpp \
CocoStudio/Components/CCComAudio.cpp \
CocoStudio/Components/CCComController.cpp \
CocoStudio/Components/CCInputDelegate.cpp \
CocoStudio/Json/CSContentJsonDictionary.cpp \
CocoStudio/Json/DictionaryHelper.cpp \
CocoStudio/Json/lib_json/json_reader.cpp \
CocoStudio/Json/lib_json/json_value.cpp \
CocoStudio/Json/lib_json/json_writer.cpp \
CocoStudio/Trigger/ObjectFactory.cpp \
CocoStudio/Trigger/TriggerBase.cpp \
CocoStudio/Trigger/TriggerMng.cpp \
CocoStudio/Trigger/TriggerObj.cpp


LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocosdenshion_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_curl_static
LOCAL_WHOLE_STATIC_LIBRARIES += box2d_static
LOCAL_WHOLE_STATIC_LIBRARIES += chipmunk_static
LOCAL_WHOLE_STATIC_LIBRARIES += libwebsockets_static

LOCAL_CFLAGS += -DCC_ENABLE_CHIPMUNK_INTEGRATION=1
LOCAL_EXPORT_CFLAGS += -DCC_ENABLE_CHIPMUNK_INTEGRATION=1

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH) \
                           $(LOCAL_PATH)/CCBReader \
                           $(LOCAL_PATH)/GUI/CCControlExtension \
                           $(LOCAL_PATH)/GUI/CCScrollView \
                           $(LOCAL_PATH)/network \
                           $(LOCAL_PATH)/LocalStorage \
                           $(LOCAL_PATH)/CocoStudio/Action \
                           $(LOCAL_PATH)/CocoStudio/Armature \
                           $(LOCAL_PATH)/CocoStudio/Armature/animation \
                           $(LOCAL_PATH)/CocoStudio/Armature/datas \
                           $(LOCAL_PATH)/CocoStudio/Armature/display \
                           $(LOCAL_PATH)/CocoStudio/Action/Armature/external_tool \
                           $(LOCAL_PATH)/CocoStudio/Armature/physics \
                           $(LOCAL_PATH)/CocoStudio/Armature/utils \
                           $(LOCAL_PATH)/CocoStudio/Components \
                           $(LOCAL_PATH)/CocoStudio/GUI/BaseClasses \
                           $(LOCAL_PATH)/CocoStudio/GUI/Layouts \
                           $(LOCAL_PATH)/CocoStudio/GUI/System \
                           $(LOCAL_PATH)/CocoStudio/GUI/UIWidgets \
                           $(LOCAL_PATH)/CocoStudio/GUI/UIWidgets/Compatible \
                           $(LOCAL_PATH)/CocoStudio/GUI/UIWidgets/ScrollWidget \
                           $(LOCAL_PATH)/CocoStudio/Json \
                           $(LOCAL_PATH)/CocoStudio/Json/lib_json \
                           $(LOCAL_PATH)/CocoStudio/Reader 
                           
LOCAL_C_INCLUDES := $(LOCAL_PATH) \
										$(LOCAL_PATH)/CocoStudio/GUI/UIWidgets/ScrollWidget \
										$(LOCAL_PATH)/../external/libwebsockets/android/include
                    
include $(BUILD_STATIC_LIBRARY)

$(call import-module,cocos2dx)
$(call import-module,CocosDenshion/android)
$(call import-module,cocos2dx/platform/third_party/android/prebuilt/libcurl)
$(call import-module,external/Box2D)
$(call import-module,external/chipmunk)
$(call import-module,external/libwebsockets/android)
