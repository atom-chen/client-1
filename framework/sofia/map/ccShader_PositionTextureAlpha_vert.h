"                                                        \n\
attribute vec4 a_position;                                \n\
attribute vec2 a_texCoord;                                \n\
//attribute float a_alpha;                                \n\
uniform    mat4 u_MVPMatrix;                                \n\
                                                        \n\
#ifdef GL_ES                                            \n\
varying mediump vec2 v_texCoord;                        \n\
#else                                                    \n\
varying vec2 v_texCoord;                                \n\
#endif                                                    \n\
//#ifdef GL_ES                                            \n\
//varying mediump float v_alpha;                        \n\
//#else                                                    \n\
//varying float v_alpha;                                \n\
//#endif                                                    \n\
                                                        \n\
void main()                                                \n\
{                                                        \n\
    gl_Position = CC_MVPMatrix * a_position;                \n\
    v_texCoord = a_texCoord;                            \n\
	//v_alpha = a_alpha;                            \n\
}                                                        \n\
";
