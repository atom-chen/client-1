LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE    := framework_static

LOCAL_MODULE_FILENAME := libframework

LOCAL_SRC_FILES := ../sofia/base/SFApp.cpp  \
../sofia/core/RenderScene.cpp  \
../sofia/core/RenderSceneLayer.cpp  \
../sofia/core/RenderSprite.cpp  \
../sofia/core/RpgSprite.cpp  \
../sofia/core/SFRenderSprite.cpp  \
../sofia/download/BackgroundDownloadTask.cpp  \
../sofia/download/SFDownload.cpp  \
../sofia/eventset/Event.cpp  \
../sofia/eventset/EventArgs.cpp  \
../sofia/eventset/EventSet.cpp  \
../sofia/eventset/SubscriberSlot.cpp  \
../sofia/map/Background.cpp  \
../sofia/map/ccShaders.cpp  \
../sofia/map/CellGroup.cpp  \
../sofia/map/ElemGroup.cpp  \
../sofia/map/ExternStack.cpp  \
../sofia/map/Layer.cpp  \
../sofia/map/LogicBlock.cpp  \
../sofia/map/LogicFinder.cpp  \
../sofia/map/LogicPath.cpp  \
../sofia/map/Map.cpp  \
../sofia/map/MapResouceManager.cpp  \
../sofia/map/Mask.cpp  \
../sofia/map/MetaLayer.cpp  \
../sofia/map/MiddleRenderLayer.cpp  \
../sofia/map/RenderCocos.cpp  \
../sofia/map/RenderCommon.cpp  \
../sofia/map/RenderInterface.cpp  \
../sofia/map/SFMap.cpp  \
../sofia/map/SFMapService.cpp  \
../sofia/map/SpriteMove.cpp  \
../sofia/map/StructCommon.cpp  \
../sofia/net/NetSystem.cpp  \
../sofia/net/Network.cpp  \
../sofia/net/SFSocketCommService.cpp  \
../sofia/package/SFPackageManager.cpp  \
../sofia/package/SFPackageUpdateMgr.cpp  \
../sofia/resouce/SFLoadResourceModule.cpp  \
../sofia/resouce/SFModelResConfig.cpp  \
../sofia/resouce/SFResourceLoad.cpp  \
../sofia/SFSimulator.cpp  \
../sofia/resouce/GameResource.cpp  \
../sofia/scene/SFGamePresenter.cpp  \
../sofia/scene/SFGameScene.cpp  \
../sofia/scene/SFGameSceneMgr.cpp  \
../sofia/stream/BinaryReader.cpp  \
../sofia/stream/BinaryReaderNet.cpp  \
../sofia/stream/BinaryWriter.cpp  \
../sofia/stream/BinaryWriterNet.cpp  \
../sofia/stream/MemoryStream.cpp  \
../sofia/utils/CCStrConv.cpp  \
../sofia/utils/CCStrUtil.cpp  \
../sofia/utils/CommonUtility.cpp  \
../sofia/utils/CsvFile.cpp  \
../sofia/utils/HTTPHandler/Base64Code.cpp  \
../sofia/utils/HttpTools.cpp  \
../sofia/utils/md5.cpp  \
../sofia/utils/MessageFactory.cpp  \
../sofia/utils/SFExecutionThreadService.cpp  \
../sofia/utils/SFLabelTTF.cpp  \
../sofia/utils/SFMiniHtml.cpp  \
../sofia/utils/SFStringUtil.cpp  \
../sofia/utils/SFTimeAxis.cpp  \
../sofia/utils/SFGeometry.cpp  \
../sofia/utils/SFPriorityNotificationCenter.cpp  \
../sofia/utils/SFTouchDispatcher.cpp  \
../sofia/utils/sqlite3.c  \
../sofia/utils/StateBlock.cpp  \
../sofia/utils/StreamDataAdapter.cpp  \
../sofia/utils/ThreadScheduler.cpp \
../sofia/utils/SFEasyMail.cpp

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static cocos_extension_static libiconv libpack_static

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../ \
                           $(LOCAL_PATH)/../include \
                           $(LOCAL_PATH)/../sofia \
                           $(LOCAL_PATH)/../../UIControl \
                           $(LOCAL_PATH)/../../UIControl/include \
                           $(LOCAL_PATH)/../../cocos2dx/platform/third_party/win32/iconv \
                           $(LOCAL_PATH)/../../cocos2dx/platform/third_party/android/prebuilt/libpng/include \
                           $(LOCAL_PATH)/../../cocos2dx/platform/third_party/android/prebuilt/libjpeg/include \
                           $(LOCAL_PATH)/../../cocos2dx/platform/third_party/android/prebuilt/libtiff/include \
                           $(LOCAL_PATH)/../../gamelogic/include/platform
                           
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)\
														$(LOCAL_PATH)/include
														
LOCAL_CFLAGS += -DCOCOS2D_DEBUG   
                    
include $(BUILD_STATIC_LIBRARY)

$(call import-module,cocos2dx) \
$(call import-module,extensions) \
$(call import-module,zpack) \
$(call import-module,third_party/libiconv)