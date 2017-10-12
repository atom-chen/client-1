#include "map/RenderInterface.h"
#include "map/Map.h"
#include "map/ElemGroup.h"
#include "map/MetaLayer.h"
#include "map/mask.h"
#include "map/SpriteMove.h"
#include "stream/iStream.h"
#include "stream/MemoryStream.h"
#include "stream/BinaryReader.h"
#include "stream/BinaryWriter.h"
#include "core/RenderScene.h"

USING_NS_CC;

namespace core
{
	RenderScene::RenderScene()
	{
		cmap::iMapRender* maprender = cmap::iMapFactory::inst->GetRender(cmap::iMapFactory::eRender_Map);
		m_pMap = new cmap::Map();
		m_pMap->Init(maprender, false);
	}

	RenderScene::~RenderScene()
	{
		// attributes
		CC_SAFE_DELETE(m_pMap);
	}

	void RenderScene::visit()
	{
		if (! this->isVisible())
		{
			return;
		}

		if (m_pMap->GetMapWidth() == 0 || m_pMap->GetMapHeight() == 0 )
		{
			return ;
		}
		//draw
		kmGLPushMatrix();

		ccDirectorProjection project = CCDirector::sharedDirector()->getProjection();
		if (project != kCCDirectorProjection3D)
		{
			CCDirector::sharedDirector()->setProjection(kCCDirectorProjection3D);
		}

		//这里用了摄像机，所以就把之前的矩阵单位化了;
		kmGLLoadIdentity();
		
		this->transform();

		float height = (float)(m_pMap->GetMapHeight());
		kmGLTranslatef(0, height, 0.f);
		kmGLScalef(1.f, -1.f, 1.f);

		//两个需要画（地图和精灵）
		//都应该是同一的剔除渲染
		m_pMap->Render();

		arrayMakeObjectsPerformSelector(m_pChildren, visit, RenderSceneLayer*);

		if (project != kCCDirectorProjection3D)
		{
			CCDirector::sharedDirector()->setProjection(project);
		}

		kmGLPopMatrix();
		
	}

	void RenderScene::update(float dt)
	{
		if ( !this->isRunning() )
		{
			return;
		}

		//CModelMap::instance().tick(dt);
		int time = dt* 1000;
		cmap::SpriteMove::scurrenttime += time;

		m_pMap->Tick();

	}

	void RenderScene::addChild( cocos2d::CCNode * child, int zOrder, int tag )
	{
		CCAssert(child != NULL, "child should not be null");

		RenderSceneLayerBase* layer = dynamic_cast<RenderSceneLayerBase*>(child);
		CCAssert(layer != NULL, "RenderScene::addChild only supports RenderSceneLayerBase as children");

		CCNode::addChild(child, zOrder, tag);
		sortAllChildren();
	}

	void RenderScene::load( cocos2d::MemoryStream &msback )
	{
		m_pMap->DelAllLayers();

		cocos2d::BinaryReader reader;
		reader.SetStream(&msback, false);
		if (!reader.Open() || reader.Eof())
		{
			return ;
		}

		if (!m_pMap->LoadHeader(msback))
		{
			CCLog("Error map file!");
		}

		//地图数据
		while(!reader.Eof())
		{
			int pos = msback.GetPosition();
			char layerType = reader.ReadChar();
			msback.Seek(pos, cocos2d::iStream::Begin);
			cmap::Layer* layer = NULL;
			switch(layerType)
			{
			case cmap::Layer::TileLayerType:
				{
					layer = m_pMap->AddTileLayer(-1, 64, 64);
					layer->Load(msback);
				}
				break;
			case cmap::Layer::AdornmentLayerType:
				{
					if(cmap::ElemGroup::loadAdornmentGroup(msback))
					{
						layer = m_pMap->AddAdornmentLayer(-1);
						layer->Load(msback);
					}
				}
				break;

			case cmap::Layer::MetaLayerType:
				{
					// liurui:这里传入的width和height没有被用到，不用管
					layer = m_pMap->AddMetaLayer(-1, 48, 48);
					layer->Load(msback);

					cmap::MetaLayer* metaLayer =  (cmap::MetaLayer*)layer;

					//编辑器约定
					bool isBlockMeta = metaLayer->GetMetaType() == cmap::MetaLayer::MetaBlockType;
					bool isMaskMeta =  metaLayer->GetMetaType() == cmap::MetaLayer::MetaMaskType;
					//内存超过1M大于堆栈缓冲，可能会出问题
					cocos2d::MemoryStream stream;
					//阻挡或者mask
					if(isBlockMeta || isMaskMeta)
					{
						stream.SetAccessMode(cocos2d::iStream::ReadWriteAccess);
						stream.Open();
						stream.Seek(0, cocos2d::iStream::Begin);

						cocos2d::BinaryWriter write;
						write.SetStream(&stream, false);
						write.Open();
						write.WriteInt(metaLayer->GetCellNumW());
						write.WriteInt(metaLayer->GetCellNumH());
						write.WriteInt(metaLayer->GetBufferSize());
						write.WriteRawData(metaLayer->getCellBufflist(), metaLayer->GetBufferSize());
						write.Close();
					}

					if (isMaskMeta)
					{
						cmap::Mask *mask = m_pMap->GetMask();
						stream.Seek(0, cocos2d::iStream::Begin);
						mask->ReloadMask(stream);
					}
					else if (isBlockMeta)
					{
						stream.Seek(0, cocos2d::iStream::Begin);
						cmap::SpriteMove::BlockChanged(stream);
					}
					metaLayer->DestroyShow();
					metaLayer->Destory();
					delete metaLayer;
				}
				break;
			default:
				break;
			}
		}

		//m_pMap->OnMapDataLoaded();
	}

	cmap::Map* RenderScene::getMap()
	{
		return m_pMap;
	}

	void RenderScene::scheduleUpdate()
	{
		getScheduler()->scheduleUpdateForTarget(this, kCCPrioritySystem, false);
	}

	void RenderScene::setViewCenter( int x, int y )
	{
		CCCamera* pCamera = getCamera();
		//pCamera->setViewCenter(x,y);
		m_pMap->SetViewCenter(x,y);
		
		
		float eyeX, eyeY, eyeZ;
		pCamera->getEyeXYZ(&eyeX, &eyeY, &eyeZ);

		//转成左下角坐标
		float _x = m_pMap->GetViewCenterX() ;
		float _y = m_pMap->GetMapHeight() - m_pMap->GetViewCenterY();
		if (eyeX != _x || eyeY != _y )
		{
			pCamera->setEyeXYZ(_x, _y, CCDirector::sharedDirector()->getZEye());
			pCamera->setCenterXYZ( _x, _y, 0.0f );
		}
	}

}