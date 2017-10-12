#ifndef _MAP_COMMAND_RENDER_H_
#define _MAP_COMMAND_RENDER_H_

#include "cocos2d.h"
USING_NS_CC;
namespace cmap
{
	class ImageSetInfo
	{
	public:
		ImageSetInfo();
		virtual ~ImageSetInfo();
		//设置资源路径
		virtual bool SetStaticImage(int id_, const char* imagepath, const char* type);
		//返回资源路径(传入的是完整的id)
		virtual std::string& GetStaticImagePath(int id_, std::string& str);
		virtual bool checkStaticImagePath(int id);
		virtual bool checkAsyncFlag(int id);
	protected:
		
		struct singleImage 
		{
			std::string	 path;
			std::string	 type;
			bool		 async;
		};

		typedef std::map<int, singleImage>  singleImageInfoListType;
		singleImageInfoListType m_singleImageList;				// 静态图片
	public:
		static ImageSetInfo * sharedImageSetInfo();
	};
}

#endif
