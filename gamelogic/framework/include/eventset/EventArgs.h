#ifndef _INTERFACE_EVENT_ARGS_H_
#define _INTERFACE_EVENT_ARGS_H_

namespace cocos2d {

	/*!
	\brief
	Enumeration of mouse buttons
	*/
// 	enum MouseButton
// 	{
// 		//! The left mouse button.
// 		LeftButton,
// 		//! The right mouse button.
// 		RightButton,
// 		//! The middle mouse button.
// 		MiddleButton,
// 		//! The first 'extra' mouse button.
// 		X1Button,
// 		//! The second 'extra' mouse button.
// 		X2Button,
// 		//! Value that equals the number of mouse buttons supported by CEGUI.
// 		MouseButtonCount,
// 		//! Value set for no mouse button.  NB: This is not 0, do not assume!
// 		NoButton
// 	};

// 	enum DirectionStyle
// 	{
// 		HORIZONTAL = 1,
// 		VERTICAL = 2,
// 	};

// 	struct Flag
// 	{
// 		enum
// 		{
// 			LEFT				= 0x00,//DT_LEFT,
// 			H_CENTER			= 0x01,//DT_CENTER,
// 			RIGHT				= 0x02,//DT_RIGHT,
// 			TOP					= 0x00,//DT_TOP,
// 			V_CENTER			= 0x04,//DT_VCENTER,
// 			BOTTOM				= 0x08,//DT_BOTTOM,
// 			LEFT_TOP			= LEFT | TOP,//0, DT_LEFT	| DT_TOP,
// 			LEFT_CENTER			= LEFT | V_CENTER,//4,//DT_LEFT	| DT_VCENTER,
// 			LEFT_BOTTOM			= LEFT | BOTTOM,//8,//DT_LEFT	| DT_BOTTOM,
// 			CENTER_TOP			= H_CENTER | TOP,//1,//DT_CENTER | DT_TOP,
// 			CENTER_CENTER		= H_CENTER | V_CENTER,//5,//DT_CENTER | DT_VCENTER,
// 			CENTER_BOTTOM		= H_CENTER | BOTTOM,//9,//DT_CENTER | DT_BOTTOM,
// 			RIGHT_TOP			= RIGHT | TOP,//2,//DT_RIGHT	| DT_TOP,
// 			RIGHT_CENTER		= RIGHT | V_CENTER,//6,//DT_RIGHT	| DT_VCENTER,
// 			RIGHT_BOTTOM		= RIGHT | BOTTOM,//10,//DT_RIGHT	| DT_BOTTOM,
// 			V_REVERSE			= 0x010,//垂直方向上倒转
// 			H_REVERSE			= 0x020,//水平方向上倒转
// 			//BOLD			= 0x0100,//加粗
// 			//THIN			= 0x0200,//细体
// 			//ITALIC			= 0x0400,//斜体
// 			//UNDER_LINE		= 0x0800,//下划线
// 			//ENGLISH			= 0x1000,//是英文
// 			//FONT_THREE		= 0x1f00,//前三种相加
// 			//SHADOW			= 0x2000,//阴影
// 			//STROKE			= 0x4000,//描边
// 		};
// 		static int GetFlagFromName(const char* name);
// 	};


// 	enum TitleFlag
// 	{
// 		FLAG_LEFT_TOP		= 0,//DT_LEFT	| DT_TOP,
// 		FLAG_LEFT_CENTER	= 4,//DT_LEFT	| DT_VCENTER,
// 		FLAG_LEFT_BOTTOM	= 8,//DT_LEFT	| DT_BOTTOM,
// 		FLAG_CENTER_TOP		= 1,//DT_CENTER | DT_TOP,
// 		FLAG_CENTER_CENTER	= 5,//DT_CENTER | DT_VCENTER,
// 		FLAG_CENTER_BOTTOM	= 9,//DT_CENTER | DT_BOTTOM,
// 		FLAG_RIGHT_TOP		= 2,//DT_RIGHT	| DT_TOP,
// 		FLAG_RIGHT_CENTER	= 6,//DT_RIGHT	| DT_VCENTER,
// 		FLAG_RIGHT_BOTTOM	= 10,//DT_RIGHT	| DT_BOTTOM,
// 	};

	class EventArgs
	{
	public:
		EventArgs() :handle(0) {};
		virtual ~EventArgs(){};

		unsigned int handle;
	};

// 	class   inputSizedEvent : public EventArgs
// 	{
// 	public:
// 		inputSizedEvent(){}
// 
// 		unsigned int width;
// 		unsigned int height;
// 	};
}

#endif