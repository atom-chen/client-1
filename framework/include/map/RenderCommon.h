#ifndef _MAP_COMMAND_RENDER_H_
#define _MAP_COMMAND_RENDER_H_
#include "map/RenderInterface.h"
#include <vector>
#include <map>
#include "cocos2d.h"
USING_NS_CC;
namespace cmap
{
	class SpriteShow;
	class SpriteShowCell : public iSpriteShowCell
	{
	public:
		SpriteShowCell();
		virtual ~SpriteShowCell();

		virtual void CreateId(int order, int drawtype, int flag,int backgroudId, int basisx, int basisy);
		virtual bool Remove(int elemId) ;
		//void Clear();
		void reset();

		virtual bool SetPos(int posx, int posy) ;
		virtual void Render();
		void SetOwner(SpriteShow* o) { this->owner = o;}

		struct Info
		{
			int elemid;
			int order;
			int drawtype;
			int flag;
			short imagetype;
			int imageid;			//图片ID
			int basisx;
			int basisy;
			cocos2d::CCTexture2D* tex;
			//int color;
		};

		static void clearCache();
	protected:
		void RenderFrameImage(iMapRender* render, Info* info, int viewx, int viewy);
		static int seed;
		int mx;
		int my;

		enum
		{
			NullType = 0,
			StaticImageType,
		};

		typedef std::vector<SpriteShowCell::Info*> InfoListType;
		typedef std::map<int, SpriteShowCell::Info*> InfoMapType;
		InfoMapType	m_infoMap;
		static InfoListType s_m_cacheElemList;
		typedef std::map<int, CCTexture2D*> TexInfoMap;
		static TexInfoMap m_sTexMap;
		int mInfoSize;
		friend class SpriteShow;
		SpriteShow* owner;
	};

	class SpriteShow : public iSpriteShow
	{
	public:
		SpriteShow();
		virtual ~SpriteShow();
		virtual void SetViewbegin(int x, int y);

		virtual iSpriteShowCell* CreateCell();
		virtual void Release(iSpriteShowCell* cell);
		virtual void Clear();
		virtual void Render();
		void SpriteShowCellOrederChanged(SpriteShowCell* cell);
		static bool SortCell(SpriteShowCell* c1, SpriteShowCell* c2);
	protected:
		typedef std::list<SpriteShowCell*> CellListType;
		//typedef std
		CellListType cellList;
		static CellListType s_cacheCellList;
		int mx;
		int my;
		bool mshouldsort;
	};

	class BackgroundShow : public iBackgroundShow
	{
	public:
		BackgroundShow();
		virtual ~BackgroundShow();

		bool create(int flag, int texture, int gid, int posx, int posy);
		void create(int flag, cocos2d::CCTexture2D* tex, int gid, int posx, int posy);
		int CreateDynamic(int flag, int imageid, int posx, int posy);
		virtual void Remove(int showid);
		virtual void Clear();
		virtual void Render();

		virtual void updateTexture(int gid, cocos2d::CCTexture2D* tex);
		struct Info
		{
			Info():elemid(0)
				,imageid(0),dynamicid(0),flag(0),posx(0),posy(0),tex(NULL)
			{}
			~Info();
			int elemid;
			int imageid;
			cocos2d::CCTexture2D*	tex;
			int dynamicid;
			int flag;
			int posx;
			int posy;
		};
	protected:
		static int seed;
		//iImageSet* mimageset;

		int mInfoSize;
		typedef std::map<int, Info*> InfoListType;
		InfoListType mlist;
	};

	class ImageSetInfo : public iImageSetInfo
	{
	public:
		ImageSetInfo();
		virtual ~ImageSetInfo();
		//设置资源路径
		virtual bool SetStaticImage(int id_, const char* imagepath, const char* type);
		//返回资源路径(传入的是完整的id)
		virtual std::string GetStaticImagePath(int id_);
		virtual bool checkStaticImagePath(int id);
		//设置纹理
		virtual void setStaticImage(int id, cocos2d::CCTexture2D* tex);
		//获取纹理，没有加载纹理返回null。不做自动加载
		virtual cocos2d::CCTexture2D* getStaticImage(int id);
		//卸载纹理
		virtual void clearStaticImage(int id);
		virtual void clearStaticImage();

		virtual int AddDynamicImage(cocos2d::CCSprite* texture);
		virtual cocos2d::CCSprite* GetDynamicImage(int id_);
		virtual bool RemoveDynamicImage(int id_);
		virtual void ClearDynamicImage();

	protected:
		
		struct singleImage 
		{
			std::string	 path;
			std::string	 type;
		};

		typedef std::map<int, cocos2d::CCSprite*>  MemoryImageListType;
		typedef std::map<int, singleImage>  singleImageInfoListType;
		MemoryImageListType mmemoryimagelist;					// 动态图片管理
		singleImageInfoListType m_singleImageList;				// 静态图片

		int seed;
	};
	class ShowManager :public iShowManager
	{
	public:
		ShowManager();
		virtual ~ShowManager();
		virtual void SetViewSize(int w, int h){}
		virtual iBackgroundShow* CreateBackground(int order);
		virtual void DestroyBackground(iBackgroundShow* show);

		virtual iSpriteShow* CreateSprite(int order);
		virtual void DestroySprite(iSpriteShow* show);

		virtual iBackgroundShow* GetBackground(int order);
		virtual iSpriteShow* GetSprite(int order);
		virtual void Render();
		virtual void Clear();

	protected:
		virtual iBackgroundShow* CreateBackgroundImp();

		friend class BackgroundShow;
		friend class SpriteShowCell;
		
		void InsertShow(iShow* show, int order, int type);
		void RemoveShow(iShow* show);
		iShow* GetShow(int order, int type);
		enum
		{
			Back,
			Sprite,
		};
		struct Info
		{
			int order;
			int type;
			iShow* show;
		};
		static bool ShowSort(Info* c1, Info* c2);
		typedef std::vector<Info*> InfoListType;
		InfoListType mlist;
		iMapRender* mMapRender;
	};

	class MapRender : public iMapRender
	{
	public:
		MapRender();
		virtual ~MapRender();

		virtual void SetShowManager(iShowManager* showManager){mShowManager = showManager;}
		virtual iShowManager* GetShowManager(){return this->mShowManager;}
	protected:

		iShowManager* mShowManager;
	};

}

#endif
