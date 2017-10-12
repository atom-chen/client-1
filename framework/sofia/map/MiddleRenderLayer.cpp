#include <algorithm>
#include "cocos2d.h"
#include "map/MetaLayer.h"
#include "map/RenderInterface.h"
#include "map/StructCommon.h"
#include "map/RenderInterface.h"
#include "map/MiddleRenderLayer.h"
//#include "map/RenderImage.h"
#include "misc_nodes/CCRenderTexture.h"
#include "kazmath/GL/matrix.h"
//#include "utils/Profiler.h"

namespace cmap
{

	MiddleRenderLayer::MiddleRenderLayer()
		:last_tick(0)
		,mbackshow(0)
		,minitlayer(0)
		,mloading_end(false)
	{
		this->sizeofcell = sizeof(CellInfo);
		this->CreateRender();
	}

	MiddleRenderLayer::~MiddleRenderLayer()
	{
		for (RendreTargetListType::iterator itr = this->mcachetargetlist.begin(); itr != mcachetargetlist.end(); ++itr)
		{
			CC_SAFE_RELEASE_NULL( (*itr) );
		}
		this->mcachetargetlist.clear();
		this->Destory();
	}

	void MiddleRenderLayer::AddLayer(Layer* layer)
	{
		layer->DestroyShow();
		layer->SetRender(0);

		this->mLayerList.push_back(layer);
	}


	void MiddleRenderLayer::RemoveAllLayer()
	{
		for ( std::size_t i=0; i<mLayerList.size(); i++ )
		{
			CC_SAFE_DELETE(mLayerList[i]);
		}
		this->mLayerList.clear();
		minitlayer = false;
		allCellList.clear();
		showingCellList.clear();
	}

	int MiddleRenderLayer::CreateShow(int layerNum)
	{
		DestroyShow();
		this->mbackshow = mRender->GetShowManager()->CreateBackground(layerNum);

		SetLayerOrder(layerNum);
		SetDirty(true);

		return 2;
	}

	void MiddleRenderLayer::DestroyShow()
	{
		mRender->GetShowManager()->DestroyBackground(this->mbackshow);
		this->mbackshow = NULL;
	}

	void MiddleRenderLayer::CreateRender()
	{
		mlayerlistrender = cmap::iMapFactory::inst->GetRender(cmap::iMapFactory::eRender_Middle_Map);
	}

	void MiddleRenderLayer::Render()
	{
		if ( this->viewSizeW == 0 || this->viewSizeH == 0 )
		{
			return;
		}
		bool dirty = mloading_end || this->viewOrSizeChanged;
		if ( dirty && this->cellNumH != 0 && this->cellNumW != 0 && this->cellSizeW != 0 && this->cellSizeH != 0)
		{
			this->InternalRender();
		}

		this->mloading_end = false;
	}

#define CHECK_TIME 1

	void MiddleRenderLayer::Tick()
	{
		// remove not used render texture
		static struct cocos2d::cc_timeval tv;
		cocos2d::CCTime::gettimeofdayCocos2d(&tv, NULL);
		if ( (tv.tv_sec - last_tick)> CHECK_TIME )
		{
			last_tick = tv.tv_sec;
			
			if ( allCellList.size() == showingCellList.size() )
			{
				if (!this->mcachetargetlist.empty())
				{
					cocos2d::CCRenderTexture* rt = this->mcachetargetlist.back();
					CC_SAFE_RELEASE_NULL(rt);
					this->mcachetargetlist.pop_back();
				}
				return;
			}

			CellInfoListType::iterator iter = allCellList.begin();
			while ( iter!=allCellList.end() )
			{
				CellInfo *cell = (*iter);
				if ( std::find(showingCellList.begin(), showingCellList.end(), cell)!=showingCellList.end() )
				{
					iter++;
					continue;
				}
				if ( tv.tv_sec > cell->releaseTime )
				{
					InternalClearCell((char*)cell);
					iter = allCellList.erase(iter);
				}
				else
				{
					iter++;
				}
			}
		}
	}

	void MiddleRenderLayer::InternalBuildBuf(int xbeingindex, int xviewnum, int ybeingindex, int yviewnum)
	{
		this->showingCellList.clear();
		if (this->mbackshow && this->GetIsVisible())
		{
			this->mbackshow->Clear();
			this->BuildCellBuf();
		}
	}

	void MiddleRenderLayer::InternalBuildCellBuf(int beginx, int beginy, void* cellinfo)
	{
		CellInfo* info = (CellInfo*)cellinfo;
		if ( info->target == 0 || this->mloading_end)
		{
			this->InitCellImage(beginx, beginy, info);
		}
		else
		{
			showingCellList.push_back(info);
		}
		if (info->target == 0)
		{
			return ;
		}
		if (info->dynamicId == 0)
		{
			cmap::iImageSetInfo* isi = cmap::iMapFactory::inst->GetImageSetInfo();
			info->dynamicId = isi->AddDynamicImage(info->target->getSprite());
		}
		
		int right_center_x = beginx + this->cellSizeW + this->viewSizeWHalf;
		if ( right_center_x < this->viewCenterX )
		{
			return;
		}
		if ( beginx > this->viewCenterX+this->viewSizeWHalf)
		{
			return;
		}
		if ( beginy+this->cellSizeH < this->viewCenterY-this->viewSizeHHalf )
		{
			return;
		}
		if ( beginy > this->viewCenterY+this->viewSizeHHalf)
		{
			return;
		}

		info->elemId = this->mbackshow->CreateDynamic(0, info->dynamicId, beginx, beginy);//this->cellSizeW, this->cellSizeH)
	}

	bool MiddleRenderLayer::InitCellImage(int logicX, int logicY, CellInfo* info)
	{
		int viewCX = logicX + this->cellSizeW / 2;
		int viewCY = logicY + this->cellSizeH / 2;
		int i = 0;
		if (minitlayer == false)
		{
			for (LayerListType::iterator itr = mLayerList.begin(); itr != mLayerList.end(); ++itr)
			{
				Layer* l = *itr;
				l->SetViewSize(this->cellSizeW, this->cellSizeH);
				l->DestroyShow();
				l->SetRender(this->mlayerlistrender);
				l->CreateShow(i);
				i += 100;
			}
			minitlayer = true;
		}
		
		for (LayerListType::iterator itr = mLayerList.begin(); itr != mLayerList.end(); ++itr)
		{
			Layer* l = *itr;
			l->SetViewCenter(viewCX, viewCY);
			l->Render();
			i += 100;
		}

		if (info->target == 0)
		{
			if ( mcachetargetlist.empty() )
			{
				cocos2d::CCRenderTexture* renderTarget = cocos2d::CCRenderTexture::create(this->cellSizeW, this->cellSizeH, cocos2d::kCCTexture2DPixelFormat_RGB565);
				renderTarget->retain();
				info->target = renderTarget;
			}
			else
			{
				info->target = mcachetargetlist.back();
				mcachetargetlist.pop_back();
			}
			
		}
		if (info->target == 0)
		{
			return false;
		}

		struct cocos2d::cc_timeval tv;
		cocos2d::CCTime::gettimeofdayCocos2d(&tv, NULL);
		info->releaseTime = tv.tv_sec;

#if 0 // debug
		static float tempr[12] = {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 0};
		static float tempg[12] = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 0, 0};
		static float tempb[12] = {0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 0, 0, 0.1};
		static int ii = 0;
		++ii;
		if (ii >= 11)
		{
			ii = 0;
		}
		info->target->beginWithClear(tempr[ii], tempg[ii], tempb[ii], 1.0, 0,0);
#else
		info->target->beginWithClear(0.f, 0.f, 0.f, 1.0, 0,0);
#endif


		kmGLTranslatef(-logicX, -logicY, 0);
		this->mlayerlistrender->GetShowManager()->Render();
		info->target->end();

		info->target->getSprite()->setPosition(ccp(viewCX, viewCY));

		allCellList.push_back(info);
		showingCellList.push_back(info);

		return true;
	}

	void MiddleRenderLayer::InternalClearCell(char* cell)
	{
		CellInfo* info = (CellInfo*)cell;
		if (info->elemId)
		{
			mbackshow->Remove(info->elemId);
		}

		if ( info->target )
		{
			mcachetargetlist.push_back(info->target);
		}

		memset(info, 0, sizeof(CellInfo));
	}

	void MiddleRenderLayer::PreClearAllCell()
	{
		this->RemoveAllLayer();
	}

	void MiddleRenderLayer::onMapImagesLoaded()
	{
		this->viewOrSizeChanged = true;
		this->mloading_end = true;
	}

	void MiddleRenderLayer::gatherChunkImages(int mapId, int mapWidth, int mapHeight, SFLoadTextureModule* mapBgloader)
	{
		if ( m_mapChunkImageIdsMap.find(mapId)!= m_mapChunkImageIdsMap.end() )
		{
			std::vector<int> &imageIds = m_mapChunkImageIdsMap[mapId].chunkMap[0];
			for ( std::vector<int>::iterator it=imageIds.begin(); it!=imageIds.end(); it++)
			{
				//mapBgloader->addLoadObject( *it );
			}
			return;
		}

		MapChunkImageIds map_chunk_imageIds;

		std::set<int> images_set;
		LayerListType::iterator iter = mLayerList.begin();
// 		for ( ;iter!=mLayerList.end(); iter++ )
// 		{
// 			(*iter)->gatherImageIds(0, 0, 0 , 0, images_set);
// 		}

		std::vector<int> imageIds;
		for ( std::set<int>::iterator it=images_set.begin(); it!=images_set.end(); it++)
		{
			imageIds.push_back(*it);
			//mapBgloader->addLoadObject( *it );
		}

		map_chunk_imageIds.chunkMap[0] = imageIds;
		
		m_mapChunkImageIdsMap[mapId] = map_chunk_imageIds;
	}

	void MiddleRenderLayer::backgroudLoadCell( int beginx, int beginy, void* cellinfo )
	{

	}

}
