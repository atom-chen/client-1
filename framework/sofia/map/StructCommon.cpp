#include "map/StructCommon.h"
namespace cmap
{

	void GetViewInfo(int cellsize, int viewbegin, int viewsize, int& viewbeginindex, int& viewnum)
	{
		if (viewbegin < 0)
		{
			viewsize += viewbegin;
			viewbegin = 0;
		}
		if (viewsize <= 0)
		{
			return;
		}
		viewbeginindex = viewbegin / cellsize;//第一个可以看到的格子　
// 		if(viewbeginindex>0)
// 			--viewbeginindex;
		int viewsize_front_blank = viewbegin - viewbeginindex * cellsize + viewsize;//第一格突出的部分　+　viewsize;
		viewnum = viewsize_front_blank / cellsize;//可以看到多少个，最后一个不完全看到的除外。
		if (viewsize_front_blank % cellsize != 0)//如果最后一个可以看到，则可看以的个数再加一
		{
			++viewnum;
		}
	}
}