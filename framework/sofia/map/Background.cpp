#include "map/Background.h"
#include "map/RenderInterface.h"
#include "map/StructCommon.h"
#include "stream/BinaryReaderNet.h"
#include "stream/BinaryWriterNet.h"
#include "map/RenderInterface.h"
#include "cocos2d.h"
#include "map/SFMapService.h"
namespace cmap
{
	Background::Background(): 
		mbackshow(NULL)
	{
		this->sizeofcell = sizeof(Background::CellInfo);
	}

	Background::~Background()
	{
		DestroyShow();
		CellInfoListType::iterator iter = showingCellList.begin();
		while (iter != showingCellList.end())
		{
			m_map_bg_loader->removeObject(iter->second->elemInfoList[0]);
			++iter;
		}
		Destory();
	}

	void Background::setResourceLoadHandle( SFLoadTextureModule* resourceLoad )
	{
		m_map_bg_loader = resourceLoad;
		m_map_bg_loader->addBackgroundShow(mbackshow);
	}

	void Background::DestroyShow()
	{
		if (mRender)
		{
			mRender->GetShowManager()->DestroyBackground(this->mbackshow);
			this->mbackshow = NULL;
		}
	}

	void Background::Destory()
	{
		this->PreClearAllCell();
		this->ReleaseBuf();
		m_sceneObject.clear();
	}

	int Background::CreateShow(int layerNum)
	{
		DestroyShow();
		if (mRender)
		{
			this->mbackshow = mRender->GetShowManager()->CreateBackground(layerNum);
			//addBackgroundShow
			SetLayerOrder(layerNum);
		}
		SetDirty(true);

		return 2;
	}

	void Background::CreateBuf()
	{
		if ( this->cellNumW>0 && this->cellNumH>0 )
		{
			CellInfo* infolist = new CellInfo[this->cellNumW * this->cellNumH];
			this->mcellbuflist = (char*)infolist;
		}
	}

	void Background::ReleaseBuf()
	{
		if ( this->mcellbuflist )
		{
			CellInfo* infolist = (CellInfo*)this->mcellbuflist;
			delete [] infolist;
			this->mcellbuflist = 0;
		}
	}
	bool Background::Load(cocos2d::iStream& stream)
	{
		Layer::Load(stream);

		cocos2d::BinaryReaderNet reader;
		reader.SetStream(&stream, false);
		if (!reader.Open() || reader.Eof())
		{
			return false;
		}

		int cell_w = reader.ReadUInt();
		int cell_h = reader.ReadUInt();
		int cell_w_num = reader.ReadUInt();
		int cell_h_num = reader.ReadUInt();

		m_sceneObject.resize(cell_w_num*cell_h_num);

		this->SetCellWHAndNum(cell_w, cell_h, cell_w_num, cell_h_num);

		for (int y = 0; y < cell_h_num; ++y)
		{
			for (int x = 0; x < cell_w_num; ++x)
			{
				if (reader.Eof())
				{
					return false;
				}
				int imageNum = reader.ReadShort();
				for(int i = 0; i < imageNum; i++)
				{
					int imageId = reader.ReadInt();
					this->SetCellImage(imageId, 0, x, y);
				}

				int flag = reader.ReadInt();
				this->SetCellFlag(flag, x, y);
			}
		}

		this->SetDirty(true);
		return true;
	}

	bool Background::Save(cocos2d::iStream& stream)
	{
		Layer::Save(stream);

		cocos2d::BinaryWriterNet writer;
		writer.SetStream(&stream, false);
		if (!writer.Open())
		{
			return false;
		}

		writer.WriteUInt(this->cellSizeW);
		writer.WriteUInt(this->cellSizeH);
		writer.WriteUInt(this->cellNumW);
		writer.WriteUInt(this->cellNumH);

		Background::CellInfo* cell_info = (Background::CellInfo*)this->mcellbuflist;//this->imageList;
		for (int i = 0; i < this->cellNumH; ++i)
		{
			for (int j = 0; j < this->cellNumW; ++j)
			{
				writer.WriteShort(cell_info->elemInfoList.size());
				ElemInfoVector::iterator iter = cell_info->elemInfoList.begin();
				while(iter != cell_info->elemInfoList.end())
				{
					writer.WriteInt(*iter);
					iter++;
				}

				writer.WriteInt(cell_info->flag);
				++ cell_info;
			}
		}

		return true;
	}

	void Background::SetCellImage( int imageid, int flag, int cell_x, int cell_y )
	{
		char* temp = this->GetCellInfo(cell_x, cell_y);
		if (temp == 0)
		{
			return;
		}
		Background::CellInfo* info = (Background::CellInfo*)temp;
		info->gid = cell_x + cell_y * this->cellNumW;
		info->flag = flag;
		if(info->elemInfoList.size() > 0 )
			CCLOG("Background::backgroudLoadCell is null, beginX:%d, beginY:%d",cell_x/128, cell_y/128);
		if(imageid != 0)
		{
			ElemInfoVector::iterator i = info->elemInfoList.begin();
			while(i != info->elemInfoList.end())
			{
				if(*i == imageid)
					return;
				i++;
			}

			if(i == info->elemInfoList.end())
			{
				info->elemInfoList.push_back(imageid);
			}
		}
		
		this->SetDirty(true);
	}

	void Background::ClearCell(int cellX, int cellY)
	{
		CellInfo* infolist = (CellInfo*)this->mcellbuflist;
		//infolist;
		char* temp = this->GetCellInfo(cellX, cellY);
		if (temp == 0)
		{
			return ;
		}

		Background::CellInfo* info = (Background::CellInfo*)temp;
		ElemInfoVector::iterator i = info->elemInfoList.begin();
		while(i != info->elemInfoList.end())
		{
			this->mbackshow->Remove(infolist->gid);
			i++;
		}

		info->elemInfoList.clear();

		this->SetDirty(true);

	}

	void Background::SetCellFlag(int flag, int cell_x, int cell_y )
	{
		char* temp = this->GetCellInfo(cell_x, cell_y);
		if (temp == 0)
		{
			return ;
		}
		Background::CellInfo* info = (Background::CellInfo*)temp;

		
		info->flag = flag;
		
		this->SetDirty(true);
	}

	void Background::SetIsVisible(bool draw)
	{
		if(GetIsVisible() == draw)
		{
			return;
		}

		Layer::SetIsVisible(draw);
		this->SetDirty(true);
		if ( !draw && this->mbackshow )
		{
			this->mbackshow->Clear();
		}
	}

	void Background::InternalBuildBuf(int xbeingindex, int xviewnum, int ybeingindex, int yviewnum)
	{
		if (this->mbackshow && this->GetIsVisible())
		{
			this->mixedOperation(xbeingindex, ybeingindex, xviewnum, yviewnum);
		}
	}

	void Background::removeObject( int gid, int texId )
	{
		m_map_bg_loader->removeObject(texId);
		mbackshow->Remove(gid);
		//remove spr
		if(gid >= m_sceneObject.size() && gid < 0)
			return;
		gidObjectList obList = m_sceneObject[gid];
		for (gidObjectList::iterator itr = obList.begin(); itr != obList.end(); ++itr)
		{
			SFMapService::getInstancePtr()->getShareMap()->LeaveMap((*itr));
		}
		//////////////////////////////////////////////////////////////////////////
	}

	void Background::mixedOperation(int xbeginIndex, int ybeginIndex, int xSize, int ySize)
	{
		if (mcellbuflist == NULL)
			return;
		CellInfoListType newShowCell;
		//先有显示的队列
		CellInfoListType::iterator iter = showingCellList.begin();
		int offsetX = 1;
		int offsetY = 0;
		int cellX = xbeginIndex;
		int cellY = ybeginIndex;

		while (iter != showingCellList.end())
		{
			cellY = ybeginIndex + offsetY;
			Background::CellInfo* info = (Background::CellInfo*)this->GetCellInfo(cellX, cellY);
			if(!info)
			{
				this->removeObject( iter->second->gid, iter->second->elemInfoList[0] );
				++iter;
				continue;
			}
			//已经渲染id小于将要内容ID
			if (iter->second->gid < info->gid)
			{
				if(iter->second->gid >= 0)
					this->removeObject( iter->second->gid, iter->second->elemInfoList[0] );
				++iter;
			}
			else if (iter->second->gid  > info->gid)
			{
				if(offsetY < ySize)
				{
					if(info->gid >= 0)
					{
						this->InternalBuildCellBuf(cellX*this->cellSizeW, cellY*this->cellSizeH, info);
						newShowCell.insert(CellInfoListType::value_type(info->gid, info));
					}
					if (offsetX < xSize)
					{
						++cellX;
						++offsetX;
					}
					else
					{
						cellX = xbeginIndex;
						offsetX = 1;
						++offsetY;
					}
				}
				else
				{
					//清除掉多出来的部分
					this->removeObject( iter->second->gid, iter->second->elemInfoList[0] );
					++iter;
				}
			}
			else
			{
				//在交集内的数据，直接不在参与二次渲染的内容
				//重复的渲染的加入到新渲染里面（这个是已经在渲染队列里面，不需要二次添加到show）
				if(iter->first >= 0)
					newShowCell.insert(CellInfoListType::value_type(iter->first, iter->second));
				++iter;
				if(offsetY < ySize)
				{
					if (offsetX < xSize)
					{
						++cellX;
						++offsetX;
					}
					else
					{
						cellX = xbeginIndex;
						offsetX = 1;
						++offsetY;
					}
				}
			}
			//需要把
		}
		//这里是全部新加入的渲染内容。不包括重叠部分的内容
		int offX = offsetX - 1;
		for (int y = offsetY; y < ySize; ++y)
		{
			for (int x = offX; x < xSize; ++x)
			{
				cellY = ybeginIndex + y;
				cellX = xbeginIndex + x;
				Background::CellInfo* info = (Background::CellInfo*)this->GetCellInfo(xbeginIndex + x, ybeginIndex + y);
				if(!info || info->gid < 0) continue;
				this->InternalBuildCellBuf(cellX*this->cellSizeW, cellY*this->cellSizeH, info);
				newShowCell.insert(CellInfoListType::value_type(info->gid, info));
			}
			offX = 0;
		}
		showingCellList.swap(newShowCell);
	}

	// 现在渲染，需要现在就加载到的。或者已经预加载好的。直接渲染
	void Background::InternalBuildCellBuf(int beginx, int beginy, void* cellinfo)
	{
		Background::CellInfo* info = (Background::CellInfo*)cellinfo;

		ElemInfoVector::iterator i = info->elemInfoList.begin();
		if(info->elemInfoList.size() > 1)
			CCLOG("Background::backgroudLoadCell is null, beginX:%d, beginY:%d",beginx/128, beginy/128);
		//只有一层，暂时
		while(i != info->elemInfoList.end())
		{
			if(this->mbackshow->create(info->flag, *i, info->gid, beginx, beginy))
			{
				m_map_bg_loader->addLoadObject(*i, info->gid);
			}

			gidObjectList obList = m_sceneObject[info->gid];
			for (gidObjectList::iterator itr = obList.begin(); itr != obList.end(); ++itr)
			{
				if((*itr)->getParent())
				{
					break;
				}
				SFMapService::getInstancePtr()->getShareMap()->EnterMap(*itr,(eRenderLayerTag)(*itr)->getTag());
			}
			//只有一层
			return;
			i++;
		}
	}
	//预加载列表
	void Background::backgroudLoadCell( int beginx, int beginy, void* cellinfo )
	{
	}

	void Background::InternalBuildCellRectBuff(int x, int y, int x2, int y2)
	{
	}

	void Background::InternalClearCell(char* cell)
	{
		if (!this->mbackshow)
			return;

		Background::CellInfo* ci = (Background::CellInfo*)cell;
		ElemInfoVector::iterator i = ci->elemInfoList.begin();
		while(i != ci->elemInfoList.end())
		{
			this->mbackshow->Remove(ci->gid);
			i++;
		}
	}

	void Background::PreClearAllCell()
	{
		this->showingCellList.clear();
	}

	void Background::Render()
	{
		//这里应该计算矩阵差
		if (this->viewOrSizeChanged && this->cellNumH != 0 && this->cellNumW != 0 && this->cellSizeW != 0 && this->cellSizeH != 0)
		{
			//计算出view区域
			int viewbeginx, xbeginindex, xviewnum;
			this->GetVisibleInfoX(viewbeginx, xbeginindex, xviewnum);
			int viewbeginy, ybeginindex, yviewnum;
			this->GetVisibleInfoY(viewbeginy, ybeginindex, yviewnum);

			int viewBeginIndexX, viewNumX;
			GetViewInfo(this->cellSizeW, viewbeginx-this->cellSizeW, this->viewSizeW + (this->cellSizeW*3), viewBeginIndexX, viewNumX);

			int viewBeginIndexY, viewNumY;
			GetViewInfo(this->cellSizeH, viewbeginy-this->cellSizeH, this->viewSizeH + (this->cellSizeH*2), viewBeginIndexY, viewNumY);
			if(viewBeginIndexX + viewNumX > cellNumW)
			{
				viewNumX = cellNumW - viewBeginIndexX;
			}
			if(viewBeginIndexY + viewNumY > cellNumH)
			{
				viewNumY = cellNumH - viewBeginIndexY;
			}
			cocos2d::CCRect rectLoad = cocos2d::CCRectMake(viewBeginIndexX,viewBeginIndexY,viewNumX,viewNumY);
			// 对比是否有变化，有变化需要重构render的内容
			if( !m_loadRect.equals(rectLoad) )
			{
				m_loadRect = rectLoad;
				this->InternalBuildBuf(viewBeginIndexX, viewNumX, viewBeginIndexY, viewNumY);
			}

			this->viewOrSizeChanged = false;
		}
	}

	void Background::gatherImageIds( int left, int top, int right, int bottom, std::set<int>& images )
	{
		this->Render();
	}

	bool Background::addSprite( cocos2d::CCNode* renderSpr, int layer )
	{
		//计算出GID
		int x = renderSpr->getPositionX();
		int y = renderSpr->getPositionY();

		int gid = (x / cellSizeW) + (y / cellSizeH) * cellNumW;

		if (gid >= m_sceneObject.size())
			return false;
		m_sceneObject[gid].push_back(renderSpr);
		return true;
	}
}
