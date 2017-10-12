#ifndef _SFMAPDEF_H_
#define _SFMAPDEF_H_

// 地图渲染层次定义
enum eRenderLayerTag
{
	eRenderLayer_Sprite,
	eRenderLayer_SpriteBackground, // render sprite background
	eRenderLayer_Effect,			// 特效层
	eRenderLayer_Total,
};

#endif