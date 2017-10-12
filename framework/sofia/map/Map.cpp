#include "map/RenderInterface.h"
#include "map/MetaLayer.h"
#include "map/Background.h"
//#include "map/Adornment.h"
#include "map/Map.h"
#include "map/MapLoadingInterface.h"
//#include "utils/Profiler.h"
#include "map/MapDefine.h"
#include "stream/BinaryWriterNet.h"
#include "stream/BinaryReaderNet.h"
#include "map/MiddleRenderLayer.h"
#include "map/Mask.h"
//#include "map/SFRender.h"
#include "resource/SFResourceLoad.h"
#include "map/ElemGroup.h"
namespace cmap
{
	Map::Map()
		: mCurLayer(NULL)
		, id(0)
		, mLayerNum(0)
		,render(NULL)
		,m_renderMode(RM_Normal)
		,m_map_loadingEvent(NULL)
		,m_backgroundLoading(false)
	{

		this->mapW = 0;
		this->mapH = 0;

		this->mTileWidth = 0;
		this->mTileHeight = 0;

		this->viewCenterX = 0;
		this->viewCenterY = 0;

		this->viewSizeW = 0;
		this->viewSizeH = 0;

		m_LoadModule = new SFLoadTextureModule();
		SFResourceLoad::sharedResourceLoadCache()->addLoadingModule(m_LoadModule);

		this->mMiddleRenderLayer = 0;
		if (m_renderMode == RM_Buffer)
		{
			this->mMiddleRenderLayer = new MiddleRenderLayer();
		}
		m_pMask = new Mask;

	}

	Map::~Map()
	{
		DelAllLayers();
		CC_SAFE_DELETE( m_pMask );
		SFResourceLoad::sharedResourceLoadCache()->removeLoadingModule(m_LoadModule);
		CC_SAFE_DELETE(mMiddleRenderLayer);
	}

	void Map::Init( iMapRender* render_, bool _inEditor)
	{
		this->render = render_;
		mLayerNum = 0;
	}

	void Map::SetViewCenter( unsigned int x, unsigned int y )
	{
		if (this->viewCenterX == x && this->viewCenterY == y)
		{
			return;
		}

		x = MAX(MIN(x, this->mapW-viewSizeW/2), viewSizeW/2);
		y = MAX(MIN(y, this->mapH-viewSizeH/2), viewSizeH/2);

		this->viewCenterX = x;
		this->viewCenterY = y;
		this->SetRenderRect(this->viewCenterX, this->viewCenterY, this->viewSizeW, this->viewSizeH);
	}

	int Map::GetViewCenterX() const
	{
		return this->viewCenterX;
	}

	int Map::GetViewCenterY() const
	{
		return this->viewCenterY;
	}

	void Map::SetViewBegin( unsigned int x, unsigned int y )
	{
		this->SetViewCenter(x + this->viewSizeW/2, y + this->viewSizeH/2);
	}

	unsigned int Map::GetViewBeginX() const
	{
		return this->viewCenterX - this->viewSizeW/2;
	}

	unsigned int Map::GetViewBeginY() const
	{
		return this->viewCenterY - this->viewSizeH/2;
	}

	void Map::SetViewSize( unsigned int w, unsigned int h )
	{
		if (this->viewSizeW == w && this->viewSizeH == h)
		{
			return;
		}

		this->viewSizeH = h;
		this->viewSizeW = w;
		//this->SetRenderRect(this->viewCenterX, this->viewCenterY, this->viewSizeW, this->viewSizeH);
	}

	unsigned int Map::GetViewSizeW() const
	{
		return this->viewSizeW;
	}

	unsigned int Map::GetViewSizeH() const
	{
		return this->viewSizeH;
	}

	void Map::SetMapSize( unsigned int tileColNum, unsigned int tileRowNum, unsigned int tileWidth, unsigned int tileHeight )
	{
		mTileWidth = tileWidth;
		mTileHeight = tileHeight;

		this->mapW = tileColNum * tileWidth;
		this->mapH = tileRowNum * tileHeight;

		if(m_renderMode == RM_Buffer)
		{
			mMiddleRenderLayer->SetRender(this->render);
			static int MiddleCellSize = 512;
			int rowNum1 = this->mapH / MiddleCellSize;
			if(this->mapH % MiddleCellSize != 0)
			{
				rowNum1++;
			}
			int colNum2 = this->mapW / MiddleCellSize;
			if(this->mapW % MiddleCellSize != 0)
			{
				colNum2++;
			}
			mMiddleRenderLayer->SetCellWHAndMapSize(colNum2, rowNum1, MiddleCellSize, MiddleCellSize);
			int createLayerNum = mMiddleRenderLayer->CreateShow(++mLayerNum);
			mLayerNum += createLayerNum;
		}
	}

	void Map::SetMapSizeNew( unsigned int width, unsigned int height, unsigned int tileWidth, unsigned int tileHeight )
	{
		this->mapW = width;
		this->mapH = height;
		mTileWidth = tileWidth;
		mTileHeight = tileHeight;
		if(m_renderMode == RM_Buffer)
		{
			mMiddleRenderLayer->SetRender(this->render);
			static int MiddleCellSize = 512;
			int rowNum1 = this->mapH / MiddleCellSize;
			if(this->mapH % MiddleCellSize != 0)
			{
				rowNum1++;
			}
			int colNum2 = this->mapW / MiddleCellSize;
			if(this->mapW % MiddleCellSize != 0)
			{
				colNum2++;
			}
			mMiddleRenderLayer->SetCellWHAndMapSize(colNum2, rowNum1, MiddleCellSize, MiddleCellSize);
			int createLayerNum = mMiddleRenderLayer->CreateShow(++mLayerNum);
			mLayerNum += createLayerNum;
		}
	}

	unsigned int Map::GetMapWidth() const
	{
		return this->mapW;
	}

	unsigned int Map::GetMapHeight() const
	{
		return this->mapH;
	}

	unsigned int Map::GetTileColNum() const
	{
		return this->mapW / mTileWidth;
	}

	unsigned int Map::GetTileRowNum() const
	{
		return this->mapH / mTileHeight;
	}

	unsigned int Map::GetTileWidth() const
	{
		return this->mTileWidth;
	}

	unsigned int Map::GetTileHeight() const
	{
		return this->mTileHeight;
	}

	void Map::Render()
	{
// 		if(m_backgroundLoading)
// 			return;
		if(m_renderMode == RM_Buffer)
		{
			mMiddleRenderLayer->Render();
		}
		else
		{
			for (LayerVector::iterator iter = mLayers.begin(); iter!=mLayers.end();++iter)
			{
				(*iter)->Render();
			}
		}
		//计算出需要渲染的rect区域
		render->GetShowManager()->Render();
	}

	void Map::SetMapLoadingEvent( IMapLoadingCompleteEvent *callbackEvent )
	{
		m_map_loadingEvent = callbackEvent;
	}
	void Map::onLoadCompleted()
	{
		if(m_renderMode == RM_Buffer)
		{
			mMiddleRenderLayer->onMapImagesLoaded();
		}
		if(m_map_loadingEvent)
			m_map_loadingEvent->onMapLoadCompleted();
		m_backgroundLoading = false;
	}

	void Map::OnMapDataLoaded()
	{
		if(m_renderMode == RM_Buffer)
		{
			mMiddleRenderLayer->gatherChunkImages( this->id, this->mapW, this->mapH, this->m_LoadModule );
		}
		else
		{
			std::set<int> images_set;
			LayerVector::iterator iter = mLayers.begin();
			for ( ;iter!=mLayers.end(); iter++ )
			{
				(*iter)->gatherImageIds(0, 0, 0 , 0, images_set);
			}
		}
		m_backgroundLoading = true;
		SFResourceLoad::sharedResourceLoadCache()->setCompleteEventOnce(this);
	}

	void Map::Tick()
	{
		if(m_backgroundLoading)
			return;
		if(m_renderMode == RM_Buffer)
			mMiddleRenderLayer->Tick();
	}

	void Map::SetRenderRect( unsigned int vx, unsigned int vy, unsigned int w, unsigned int h )
	{
		if(m_renderMode == RM_Buffer)
		{
			mMiddleRenderLayer->SetViewSize(w, h);
			mMiddleRenderLayer->SetViewCenter(vx, vy);
		}
		else
		{
			for (LayerVector::iterator iter = mLayers.begin(); iter!=mLayers.end();++iter)
			{
				(*iter)->SetViewSize(w, h);
				(*iter)->SetViewCenter(vx, vy);
			}
		}

	}

	int Map::GetLayerIndexByName(const char* name)
	{
		int i = 0;
		while(i != mLayers.size())
		{
			if(mLayers[i]->GetName() == name)
			{
				return i;
			}
			i++;
		}

		return -1;
	}

	Layer* Map::GetLayerByName(const char* name)
	{
		for (LayerVector::iterator iter = mLayers.begin(); iter!=mLayers.end();++iter)
		{
			if((*iter)->GetName() == name)
			{
				return (*iter);
			}
		}

		return NULL;
	}

	Layer* Map::AddTileLayer(int index, int tileWidth, int tileHeight)
	{
		if(index < 0 || index > mLayers.size())
		{
			index = mLayers.size();
		}

		std::string preName = "tile_layer_";

		std::string name;
		for(int i = 1; true; i++)
		{
			char temp[12] = {0};
			sprintf(temp, "%d", i);
			name = preName + temp;
			if(!GetLayerByName(name.c_str()))
			{
				break;
			}
		}

		Background* back = new Background();
		back->SetName(name);
		back->SetLayerID(GetLayerNewID());
		if(m_renderMode == RM_Buffer)
		{
			mMiddleRenderLayer->AddLayer(back);
			mMiddleRenderLayer->SetRender(render);
		}
		else
		{
			back->SetRender(render);
			int createLayerNum = back->CreateShow(mLayerNum);
			mLayerNum += createLayerNum;
			AddLayer(back, index);
		}

		int rowNum = mapH / tileHeight;
		if(mapH % tileHeight != 0)
		{
			rowNum++;
		}

		int colNum = mapW / tileWidth;
		if(mapW % tileWidth != 0)
		{
			colNum++;
		}
		//back->SetCellWHAndMapSize(colNum, rowNum, tileWidth, tileHeight);
		back->SetViewSize(viewSizeW, viewSizeH);
		back->SetViewCenter(viewCenterX, viewCenterY);
		//back->setResourceLoadHandle(m_map_bg_loader);
		m_LoadModule->clearObject();
		back->setResourceLoadHandle(m_LoadModule);
		mCurLayer = back;
		return back;
	}

	Layer* Map::AddAdornmentLayer(int index)
	{
		if(index < 0 || index > mLayers.size())
		{
			index = mLayers.size();
		}

		std::string preName = "adornment_layer_";

		std::string name;
		for(int i = 1; true; i++)
		{
			char temp[12] = {0};
			sprintf(temp, "%d", i);
			//::itoa(i, temp, 10);
			name = preName + temp;
			if(!GetLayerByName(name.c_str()))
			{
				break;
			}
		}

		ElemGroup* back = new ElemGroup();
		back->SetName(name);
		back->SetLayerID(GetLayerNewID());
		if(m_renderMode == RM_Buffer)
		{
			mMiddleRenderLayer->AddLayer(back);
		}
		else
		{
			back->SetRender(render);
			int createLayerNum = back->CreateShow(mLayerNum);
			mLayerNum += createLayerNum;
			back->SetViewSize(viewSizeW, viewSizeH);
			back->SetViewCenter(viewCenterX, viewCenterY);

			AddLayer(back, index);
		}
		return back;
	}

	Layer* Map::AddMetaLayer(int index, int tileWidth, int tileHeight)
	{
		if(index < 0 || index > mLayers.size())
		{
			index = mLayers.size();
		}

		MetaLayer* back = new MetaLayer();

		back->SetRender(render);
		back->SetLayerID(GetLayerNewID());

#if DRAW_META_LAYER
		int createLayerNum = back->CreateShow(mLayerNum);
		mLayerNum += createLayerNum;
#endif

		back->SetViewSize(viewSizeW, viewSizeH);
		back->SetViewCenter(viewCenterX, viewCenterY);
		//AddLayer(back, index);
		return back;
	}

	void Map::DelLayerByName(const char* name)
	{
		int index = GetLayerIndexByName(name);
		if(index == -1)
		{
			return;
		}

		Layer* layer = mLayers[index];
		// 如果是Tile层 不给删除
		if (layer->GetLayerType() == Layer::TileLayerType)
		{
			return;
		}

		layer->DestroyShow();

		int layerIndex = layer->GetLayerOrder();
		mLayerNum = layerIndex;

		LayerVector::iterator ret = mLayers.begin() + index;
		mLayers.erase(ret);

		for(int i = 0; i < mLayers.size(); i++)
		{
			int layerNum = mLayers[i]->CreateShow(mLayerNum);
			mLayerNum += layerNum;
		}
	}

	void Map::DelAllLayers()
	{
		if(m_renderMode == RM_Buffer && this->mMiddleRenderLayer)
		{
			this->mMiddleRenderLayer->Destory();
		}
		for(int i = 0; i < mLayers.size(); i++)
		{
			mLayers[i]->DestroyShow();
			//mLayers[i]->Destory();
			delete mLayers[i];
		}
		mLayers.clear();
		mLayerNum = 0;
	}

	void Map::AddLayer( cmap::Layer* layer, int index)
	{
		LayerVector::iterator iter = mLayers.begin() + index;
		mLayers.insert(iter, layer);

		//ResetLayersShow();
	}

	int Map::GetLayerNewID()
	{
		for(int i = 1; true; i++)
		{
			if(GetLayerByID(i) == NULL)
			{
				return i;
			}
		}
	}

	Layer* Map::GetLayerByID( int id )
	{
		for (LayerVector::iterator iter = mLayers.begin(); iter!=mLayers.end();++iter)
		{
			if((*iter)->GetLayerID() == id)
			{
				return (*iter);
			}
		}

		return NULL;
	}

	void Map::ResetLayersShow()
	{
		mLayerNum = 0;
		for(int i = 0; i < mLayers.size(); i++)
		{
			int num = mLayers[i]->CreateShow(mLayerNum);
			mLayerNum += num;
		}
	}

	Mask* Map::GetMask()
	{
		return m_pMask;
	}

	bool Map::IsMaskPoint( int cellx, int celly )
	{
		return m_pMask->IsMask(cellx, celly);
	}

	void Map::setRenderMode( RenderMode rm )
	{
		if (rm == RM_Normal)
		{
		}
		else
		{
			if(!this->mMiddleRenderLayer)
				this->mMiddleRenderLayer = new MiddleRenderLayer();
		}
		m_renderMode = rm;
	}
	bool Map::LoadHeader( cocos2d::iStream& stream )
	{
		cocos2d::BinaryReaderNet reader;
		reader.SetStream(&stream, false);
		if (!reader.Open())
		{
			return false;
		}
		MapFileHeader fileHeader;
		MapInfoHeader infoHeader;
		memset(&fileHeader, 0, sizeof(fileHeader));
		memset(&infoHeader, 0, sizeof(infoHeader));
		reader.ReadRawData(&fileHeader, sizeof(fileHeader));
			
		if ( 0 != strcmp(fileHeader.fileExt, "SMCF") )
		{
			return false;
		}
		m_version = fileHeader.version;
		reader.ReadRawData(&infoHeader, sizeof(infoHeader));

		this->id = infoHeader.mapId;
		this->name = infoHeader.mapName;
		this->SetId(infoHeader.mapId);
		this->SetName(infoHeader.mapName);
		this->SetMapSize(infoHeader.colNum, infoHeader.rowNum, infoHeader.cellWidth, infoHeader.cellHeight);
		return true;
	}

	bool Map::SaveHeader( cocos2d::iStream& stream )
	{
		cocos2d::BinaryWriterNet writer;
		writer.SetStream(&stream, false);
		if (!writer.Open())
		{
			return false;
		}
		MapFileHeader fileHeader;
		MapInfoHeader infoHeader;
		memset(&fileHeader, 0, sizeof(fileHeader));
		memset(&infoHeader, 0, sizeof(infoHeader));
		strcpy(fileHeader.fileExt , "SMCF");
		fileHeader.version = 2013100118;

		infoHeader.mapId = this->id;
		strcpy(infoHeader.mapName, this->name.c_str());
		infoHeader.colNum = this->GetTileColNum();
		infoHeader.rowNum =  this->GetTileRowNum();
		infoHeader.cellWidth = this->GetTileWidth();
		infoHeader.cellHeight =  this->GetTileHeight();

		writer.WriteRawData(&fileHeader, sizeof(fileHeader));
		writer.WriteRawData(&infoHeader, sizeof(infoHeader));
		return true;
	}

	bool Map::addSprite( cocos2d::CCNode* renderSpr, int layer )
	{
		renderSpr->setTag(layer);
		return mCurLayer ? mCurLayer->addSprite(renderSpr, layer) : false ;
	}

	void Map::removeSprite( cocos2d::CCNode* render )
	{

	}

}
