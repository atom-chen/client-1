#include "map/RenderCommon.h"
#include <algorithm>
#include "map/RenderCocos.h"
#include "utils/SFStringUtil.h"

namespace cmap
{
	SpriteShowCell::InfoListType SpriteShowCell::s_m_cacheElemList;
	SpriteShowCell::TexInfoMap SpriteShowCell::m_sTexMap;
	int SpriteShowCell::seed = 1;
	SpriteShowCell::SpriteShowCell()
		:mx(0), my(0), mInfoSize(sizeof(SpriteShowCell::Info))
	{
	}

	SpriteShowCell::~SpriteShowCell()
	{
		this->reset();
		//CCTextureCache::sharedTextureCache()->removeUnusedTextures();
		//CCTextureCache::sharedTextureCache()->dumpCachedTextureInfo();
	}

	void SpriteShowCell::clearCache()
	{
		SpriteShowCell::InfoListType::iterator iter = s_m_cacheElemList.begin();
		for ( ; iter!=s_m_cacheElemList.end(); iter++ )
		{
			CC_SAFE_FREE(*iter);
		}
		s_m_cacheElemList.clear();
		m_sTexMap.clear();
	}

	void SpriteShowCell::reset()
	{
		for (InfoMapType::iterator itr = this->m_infoMap.begin(); itr != this->m_infoMap.end(); ++itr)
		{
			CC_SAFE_RELEASE_NULL(itr->second->tex);
			s_m_cacheElemList.push_back(itr->second);
		}
		this->m_infoMap.clear();
		this->owner = NULL;
	}

	bool SpriteShowCell::SetPos(int posx, int posy)
	{
		this->mx = posx;
		this->my = posy;
		this->owner->SpriteShowCellOrederChanged(this);
		return true;
	}

	void SpriteShowCell::CreateId(int order, int drawtype, int flag,int backgroudId, int basisx, int basisy)
	{
		SpriteShowCell::Info* info = NULL;
		if ( s_m_cacheElemList.empty() )
		{
			++ SpriteShowCell::seed;
			if (SpriteShowCell::seed == 0)
			{
				SpriteShowCell::seed = 1;
			}
			info = (SpriteShowCell::Info*)malloc(this->mInfoSize);
			::memset(info,  0, sizeof(SpriteShowCell::Info));
			info->elemid = SpriteShowCell::seed;
		}
		else
		{
			info = s_m_cacheElemList.back();
			s_m_cacheElemList.pop_back();
			int elemid = info->elemid;
			CC_SAFE_RELEASE_NULL(info->tex);
			::memset(info,  0, sizeof(SpriteShowCell::Info));
			info->elemid = elemid;
		}
		info->order = order;
		info->drawtype = drawtype;
		info->flag = flag;
		info->imageid = backgroudId;//
		TexInfoMap::iterator iter = m_sTexMap.find(backgroudId);
		if (iter != m_sTexMap.end())
		{
			info->tex = iter->second;
		}
		else
		{
			std::string path = cmap::iMapFactory::inst->GetImageSetInfo()->GetStaticImagePath(backgroudId);
			if ( path.length() )
			{
				info->tex = (cocos2d::CCTexture2D*)cocos2d::CCTextureCache::sharedTextureCache()->addImage(path.c_str());
				if(info->tex)
					m_sTexMap.insert(std::pair<int, CCTexture2D*>(backgroudId, info->tex));
				else
				{
					CCLOG("SpriteShowCell::CreateId cant't load textureId:%d",backgroudId);
					return;
				}
			}
		}
		CC_ASSERT(info->tex);
		info->tex->retain();

		info->basisx = basisx;
		info->basisy = basisy;
		info->imagetype = SpriteShowCell::StaticImageType;
		this->m_infoMap.insert(std::pair<int, SpriteShowCell::Info*>(info->elemid, info));
	}

	void SpriteShowCell::Render()
	{
		InfoMapType::iterator itr = this->m_infoMap.begin();
		for (; itr != this->m_infoMap.end(); ++itr)
		{
			SpriteShowCell::Info* info = itr->second;
			if (info->tex == 0)
			{
				continue;
			}
			CCMapRender::RenderMapImage(info->tex, info->drawtype, info->flag, this->mx - info->basisx, this->my - info->basisy);
		}
	}

	bool SpriteShowCell::Remove(int elemid_)
	{
		InfoMapType::iterator iter = this->m_infoMap.find(elemid_);
		if (iter != m_infoMap.end())
		{
			CC_SAFE_RELEASE_NULL(iter->second->tex);
			free(iter->second);
			m_infoMap.erase(iter);
			return true;
		}
		return false;
	}

	SpriteShow::CellListType SpriteShow::s_cacheCellList;
	SpriteShow::SpriteShow()
		:mx(0), my(0)
	{

	}

	SpriteShow::~SpriteShow()
	{
		this->Clear();
		for (CellListType::iterator itr = s_cacheCellList.begin(); itr != s_cacheCellList.end(); ++itr)
		{
			CC_SAFE_DELETE( *itr );
		}
		s_cacheCellList.clear();
		SpriteShowCell::clearCache();
	}

	void SpriteShow::Clear()
	{
		for (CellListType::iterator itr = cellList.begin(); itr != cellList.end(); ++itr)
		{
			CC_SAFE_DELETE(*itr);
		}
		this->cellList.clear();
	}

	void SpriteShow::Release(iSpriteShowCell* cell)
	{
		CellListType::iterator itr = std::find(this->cellList.begin(), this->cellList.end(), cell);
		if (itr != this->cellList.end())
		{
			cmap::SpriteShowCell* showcell = *itr;
			this->cellList.erase(itr);
			//清除原有数据
			showcell->reset();
			//加入到回收队列中
			s_cacheCellList.push_back(showcell);
		}
	}

	void SpriteShow::SetViewbegin(int x, int y)
	{
		this->mx = x;
		this->my = y;
	}

	iSpriteShowCell* SpriteShow::CreateCell()
	{
		SpriteShowCell* cell = NULL;
		if ( s_cacheCellList.empty() )
		{
			cell = new SpriteShowCell;
		}
		else
		{
			cell = s_cacheCellList.back();
			s_cacheCellList.pop_back();
		}
		cell->owner = this;
		this->cellList.push_back(cell);
		return cell;
	}

	void SpriteShow::Render()
	{
		if (mshouldsort)
		{
			cellList.sort(SpriteShow::SortCell);
			mshouldsort = false;
		}
		for (CellListType::iterator itr = cellList.begin(); itr != cellList.end(); ++itr)
		{
			(*itr)->Render();
		}
	}

	void SpriteShow::SpriteShowCellOrederChanged(SpriteShowCell* cell)
	{
		mshouldsort = true;
	}

	bool SpriteShow::SortCell(SpriteShowCell* c1, SpriteShowCell* c2)
	{
		return c1->my < c2->my;
	}

	BackgroundShow::BackgroundShow()
	{
		mInfoSize = sizeof(BackgroundShow::Info);
	}

	BackgroundShow::~BackgroundShow()
	{
		this->Clear();
	}

	BackgroundShow::Info::~Info()
	{
	}

	void BackgroundShow::Clear()
	{
		for (InfoListType::iterator itr = this->mlist.begin(); itr != this->mlist.end(); ++itr)
		{
			CC_SAFE_DELETE(itr->second);
		}
		this->mlist.clear();
	}
	
	int BackgroundShow::seed = 1;

	bool BackgroundShow::create( int flag, int textureId, int gid , int posx, int posy)
	{
		InfoListType::iterator iter = mlist.find(gid);
		if (iter == mlist.end())
		{
			BackgroundShow::Info* info = new BackgroundShow::Info;
			info->dynamicid = 0;
			info->imageid = textureId;
			info->posx = posx;
			info->posy = posy;

			info->flag = flag;
			mlist.insert(std::pair<int, Info*>(gid, info));
			return true;
		}
		return false;
	}

	void BackgroundShow::create( int flag, cocos2d::CCTexture2D* tex, int gid, int posx, int posy )
	{
		InfoListType::iterator iter = this->mlist.find(gid);
		if (iter == mlist.end())
		{
			BackgroundShow::Info* info = new BackgroundShow::Info;
			info->dynamicid = 0;
			info->tex = tex;
			info->posx = posx;
			info->posy = posy;

			info->flag = flag;
			//CCLOG("***********gid:%d", gid);
			mlist.insert(std::pair<int, Info*>(gid, info));
		}
	}

	int BackgroundShow::CreateDynamic(int flag, int dynamicid, int posx, int posy)
	{
		++ BackgroundShow::seed;
		if (BackgroundShow::seed == 0)
		{
			BackgroundShow::seed = 1;
		}
		BackgroundShow::Info* info = (BackgroundShow::Info*)malloc(mInfoSize);
		info->dynamicid = dynamicid;
		info->imageid = 0;
		info->posx = posx;
		info->posy = posy;

		info->flag = flag;
		info->elemid = BackgroundShow::seed;
		mlist.insert(std::pair<int, Info*>(info->elemid, info));
		return BackgroundShow::seed;
	}
	void BackgroundShow::Remove(int showid)
	{
		InfoListType::iterator iter = this->mlist.find(showid);
		//for (InfoListType::iterator itr = this->mlist.begin(); itr != this->mlist.end(); ++itr)
		if(iter != this->mlist.end())
		{
			BackgroundShow::Info* info = iter->second;
			CC_SAFE_DELETE(info);
			this->mlist.erase(iter);
		}
	}
	//fixme 最后这里需要成为一个渲染器。根据需求而是用渲染方式。
	void BackgroundShow::Render()
	{
		for (InfoListType::iterator itr = this->mlist.begin(); itr != this->mlist.end(); ++itr)
		{
			BackgroundShow::Info* info = itr->second;
			//cocos2d::CCTexture2D* img = 0;
			if(info->dynamicid != 0)
			{
				//cocos2d::CCSprite* spr = imageset->GetDynamicImage(info->dynamicid);
				cocos2d::CCSprite* spr = cmap::iMapFactory::inst->GetImageSetInfo()->GetDynamicImage(info->dynamicid);
				if (spr)
				{
					spr->visit();
				}
			}
			else// if (info->imageid != 0)
			{
// 				if(info->imageid != 0 && !info->tex)
// 				{
// 					std::string path = cmap::iMapFactory::inst->GetImageSetInfo()->GetStaticImagePath(info->imageid);
// 					if ( path.length() )
// 					{
// 						info->tex = (cocos2d::CCTexture2D*)cocos2d::CCTextureCache::sharedTextureCache()->addImage(path.c_str());
// 						//info->imageid = 0;
// 						info->tex->retain();
// 					}
// 				}
				if(info->tex)
				{
					CCMapRender::RenderMapImage(info->tex, 0x0ff, info->flag, info->posx, info->posy);
				}
			}
		}
	}

	void BackgroundShow::updateTexture( int gid, cocos2d::CCTexture2D* tex )
	{
		InfoListType::iterator iter = this->mlist.find(gid);
		if (iter != mlist.end())
		{
// 			CC_SAFE_RELEASE(iter->second->tex);
// 			CC_SAFE_RETAIN(tex);
			iter->second->tex = tex;
		}
	}

	MapRender::MapRender()
	{
		this->mShowManager = 0;
	}

	MapRender::~MapRender()
	{
		SpriteShowCell::clearCache();
		if (this->mShowManager)
		{
			this->mShowManager->Clear();
			delete this->mShowManager;
		}
	}

	ShowManager::ShowManager()
	{
		this->mMapRender = 0;
	}

	ShowManager::~ShowManager()
	{
		this->Clear();
	}

	void ShowManager::Clear()
	{
		for (InfoListType::iterator itr = this->mlist.begin(); itr != this->mlist.end(); ++itr)
		{
			Info* info = *itr;
			info->show->Clear();
			delete (info->show);
			free(info);
		}
		this->mlist.clear();
	}

	void ShowManager::InsertShow(iShow* show, int order, int type)
	{
		ShowManager::Info* info = (ShowManager::Info*)malloc(sizeof(ShowManager::Info));
		info->order = order;
		info->show = show;
		info->type = type;
		this->mlist.push_back(info);
		std::sort(this->mlist.begin(), this->mlist.end(), ShowManager::ShowSort);
	}

	void ShowManager::RemoveShow(iShow* show)
	{
		for (InfoListType::iterator itr = this->mlist.begin(); itr != this->mlist.end(); ++itr)
		{
			ShowManager::Info* info = *itr;
			if(info->show == show)
			{
				this->mlist.erase(itr);
				free(info);
				return;
			}
		}
	}

	iShow* ShowManager::GetShow(int order, int type)
	{
		for (InfoListType::iterator itr = this->mlist.begin(); itr != this->mlist.end(); ++itr)
		{
			ShowManager::Info* info = *itr;
			if (info->order == order && info->type == type)
			{
				return info->show;
			}
		}
		return 0;
	}

	iBackgroundShow* ShowManager::GetBackground(int order)
	{
		iShow* show = this->GetShow(order, ShowManager::Back);
		if (show == 0)
		{
			return 0;
		}
		return static_cast<iBackgroundShow*>(show);
	}

	iSpriteShow* ShowManager::GetSprite(int order)
	{
		iShow* show = this->GetShow(order, ShowManager::Sprite);
		if (show == 0)
		{
			return 0;
		}
		return static_cast<iSpriteShow*>(show);
	}

	iBackgroundShow* ShowManager::CreateBackgroundImp()
	{
		BackgroundShow* show = new BackgroundShow();
		return show;
	}

	iBackgroundShow* ShowManager::CreateBackground(int order)
	{
		iBackgroundShow* show = this->CreateBackgroundImp();
		if (show == 0)
		{
			return 0;
		}

		this->InsertShow(show, order, ShowManager::Back);
		return show;
	}

	void ShowManager::DestroyBackground(iBackgroundShow* show)
	{
		if (show == 0)
		{
			return;
		}

		this->RemoveShow(show);
		delete show;
	}

	iSpriteShow* ShowManager::CreateSprite(int order)
	{
		iSpriteShow* show = new SpriteShow();
		if (show == 0)
		{
			return 0;
		}

		this->InsertShow(show, order, ShowManager::Sprite);
		return show;
	}

	void ShowManager::DestroySprite(iSpriteShow* show)
	{
		if (show == 0)
		{
			return;
		}

		this->RemoveShow(show);
		delete show;
	}

	bool ShowManager::ShowSort(ShowManager::Info* c1, ShowManager::Info* c2)
	{
		return c1->order < c2->order;
	}

	void ShowManager::Render()
	{
		
		for (InfoListType::iterator itr = this->mlist.begin(); itr != this->mlist.end(); ++itr)
		{
			ShowManager::Info* info = *itr;
			info->show->Render();
		}
	}

	ImageSetInfo::ImageSetInfo()
	{
		this->seed = 100;
	}

	ImageSetInfo::~ImageSetInfo()
	{
		this->clearStaticImage();
		this->ClearDynamicImage();
	}
	
	int ImageSetInfo::AddDynamicImage(cocos2d::CCSprite* texture)
	{
		int id = this->seed;
		this->mmemoryimagelist[id] = texture;
		++ this->seed;
		return id;
	}

	cocos2d::CCSprite* ImageSetInfo::GetDynamicImage(int id_)
	{
		MemoryImageListType::iterator itr = this->mmemoryimagelist.find(id_);
		if (itr == this->mmemoryimagelist.end())
		{
			return 0;
		}
		return itr->second;
	}

	bool ImageSetInfo::RemoveDynamicImage(int id_)
	{
		MemoryImageListType::iterator itr = this->mmemoryimagelist.find(id_);
		if (itr == this->mmemoryimagelist.end())
		{
			return false;
		}
		this->mmemoryimagelist.erase(itr);
		return true;
	}

	void ImageSetInfo::ClearDynamicImage()
	{
		MemoryImageListType minlist;
		this->mmemoryimagelist.swap(minlist);
	}

	cocos2d::CCTexture2D* ImageSetInfo::getStaticImage( int id )
	{
// 		singleImageInfoListType::iterator itr = this->m_singleImageList.find(id);
// 		if (itr != this->m_singleImageList.end())
// 		{
// 			return itr->second.tex;
// 		}
		return NULL;
	}
	// fixme retain is error
	void ImageSetInfo::setStaticImage( int id, cocos2d::CCTexture2D* tex )
	{
// 		singleImageInfoListType::iterator itr = this->m_singleImageList.find(id);
// 		if ( itr != this->m_singleImageList.end() && !itr->second.tex)
// 		{
// 			itr->second.tex = tex;
// 			tex->retain();
// 		}
	}

	void ImageSetInfo::clearStaticImage( int id )
	{
		std::string path = cmap::iMapFactory::inst->GetImageSetInfo()->GetStaticImagePath(id);
		if ( path.length())
		{
			cocos2d::CCTexture2D* texture2d = (cocos2d::CCTexture2D*)cocos2d::CCTextureCache::sharedTextureCache()->addImage(path.c_str());
			
			if (texture2d->isSingleReference())
			{
				cocos2d::CCTextureCache::sharedTextureCache()->removeTexture(texture2d);
			}
			else if (texture2d->retainCount() == 2)
			{
				texture2d->release();
				//CCLOG("----------- %d", id);
				cocos2d::CCTextureCache::sharedTextureCache()->removeTexture(texture2d);
			}
			else
				texture2d->release();
		}
// 		singleImageInfoListType::iterator itr = this->m_singleImageList.find(id);
// 		if (itr != m_singleImageList.end() && (*itr).second.tex)
// 		{
// 			cocos2d::CCTexture2D* tex = (*itr).second.tex;
// 			tex->release();
// 			if (tex->isSingleReference())
// 			{
// 				cocos2d::CCTextureCache::sharedTextureCache()->removeTexture(tex);
// 				(*itr).second.tex = NULL;
// 			}
// 		}
	}

	bool ImageSetInfo::SetStaticImage(int id_, const char* imagepath, const char* type)
	{
		if (imagepath == 0)
		{
			return false;
		}
		singleImage data;
		//data.tex = NULL;
		data.path= imagepath;
		data.type= type;
		this->m_singleImageList[id_] = data;
		return true;
	}

	void ImageSetInfo::clearStaticImage()
	{
// 		for (singleImageInfoListType::iterator itr = this->m_singleImageList.begin(); itr != this->m_singleImageList.end(); ++itr)
// 		{
// 			cocos2d::CCTexture2D* tex = (*itr).second.tex;
// 			if (tex != 0)
// 			{
// 				cocos2d::CCTextureCache::sharedTextureCache()->removeTexture(tex);
// 			}
// 		}
	}
	std::string ImageSetInfo::GetStaticImagePath(int id_)
	{
		//高5位作为索引id
		//低5位作为图片索引
		//加上type
		int height = id_/10000;
		int low= id_%10000;//%.5d
		std::string rec;
		singleImageInfoListType::iterator itr = this->m_singleImageList.find(height);
		if (itr == this->m_singleImageList.end())
		{
			return rec;
		}
		rec = SFStringUtil::formatString("%s%.5d.%s",itr->second.path.c_str(), low, itr->second.type.c_str());

		return rec;
	}

	bool ImageSetInfo::checkStaticImagePath( int id )
	{
		int height = id/10000;
		int low= id%10000;//%.5d
		std::string rec;
		singleImageInfoListType::iterator itr = this->m_singleImageList.find(height);
		if (itr == this->m_singleImageList.end())
		{
			return false;
		}
		return true;
	}

}
