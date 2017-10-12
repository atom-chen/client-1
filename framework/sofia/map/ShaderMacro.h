#ifndef ShaderMacro_h__
#define ShaderMacro_h__

//shaders
#define engShader_PositionTextureAlpha                "ShaderPositionTextureAlpha"



//shader属性索引
enum
{
	engShaderAtribute_Begin = 100,
	engVertexAttrib_Position,		//位置
	engVertexAttrib_Color,			//颜色
	engVertexAttrib_TexCoords,//纹理坐标
};

#define  engUniformAlpha						"u_alpha_value"
#define  engUniformColor							 "u_color_value"

#endif // shaderMacro_h__