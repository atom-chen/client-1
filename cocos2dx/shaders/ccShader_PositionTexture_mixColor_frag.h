/*
 * 相当于PS的叠加模式
 */

"										\n\
#ifdef GL_ES							\n\
precision lowp float;					\n\
#endif									\n\
										\n\
										\n\
varying vec2 v_texCoord;				\n\
uniform		vec3 u_mixColor;			\n\
										\n\
uniform sampler2D u_texture;			\n\
uniform		float u_originalAlpha;		\n\
void main()								\n\
{										\n\
	vec4 alpha = texture2D(u_texture, v_texCoord).aaaa; \n \
	vec3 mixColor; \n\
	if (texture2D(u_texture, v_texCoord).r > 0.5) \n\
	{ \n\
	mixColor.r = 1.0 - (1.0-texture2D(u_texture, v_texCoord).r)*(1.0-u_mixColor.r)/0.5;	\n\
	} \n\
	else \n\
	{ \n\
	mixColor.r =  texture2D(u_texture, v_texCoord).r*u_mixColor.r/0.5; \n\
	} \n\
	if (texture2D(u_texture, v_texCoord).g > 0.5) \n\
	{ \n\
	mixColor.g = 1.0 - (1.0-texture2D(u_texture, v_texCoord).g)*(1.0-u_mixColor.g)/0.5;	\n\
	} \n\
	else \n\
	{ \n\
	mixColor.g =  texture2D(u_texture, v_texCoord).g*u_mixColor.g/0.5; \n\
	} \n\
	if (texture2D(u_texture, v_texCoord).b > 0.5) \n\
	{ \n\
	mixColor.b = 1.0 - (1.0-texture2D(u_texture, v_texCoord).b)*(1.0-u_mixColor.b)/0.5;	\n\
	} \n\
	else \n\
	{ \n\
	mixColor.b =  texture2D(u_texture, v_texCoord).b*u_mixColor.b/0.5; \n\
	} \n\
	gl_FragColor =  u_originalAlpha*alpha*vec4(mixColor.rgb, 1.0); \n\
}										\n\
";
