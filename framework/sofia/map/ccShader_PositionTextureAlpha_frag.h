"                                                                        \n\
#ifdef GL_ES                                                   \n\
precision lowp float;                                                    \n\
#endif                                                                    \n\
                                                                        \n\
//varying float v_alpha													\n\
varying vec2 v_texCoord;                                                \n\
uniform sampler2D CC_Texture0;                                            \n\
uniform float u_alpha_value;													\n\
uniform vec4 u_color_value;                \n\
                                                                        \n\
void main()                                                                \n\
{                                                                        \n\
    gl_FragColor =  texture2D(CC_Texture0, v_texCoord) * u_color_value;                    \n\
	gl_FragColor.a =  gl_FragColor.a * u_alpha_value;	\n\
}                                                                        \n\
";
