--[[
场景主菜单相关的配置
]]

local PosxX = 80
local PosxY = 25
local viewSize = CCDirector:sharedDirector():getVisibleSize()
local btnSpace = (viewSize.width-PosxX)/10
Config = Config or {}

-- icon: 		按钮图标
-- clickfunc:	点击事件
-- condition:	开启条件

MainMenu_Btn = 
{
	Btn_role = 1,
	Btn_skill = 2,
	Btn_faction = 3,	
	Btn_achieve = 4,
	Btn_mount = 5,
	Btn_wing = 6,
	Btn_talisman = 7,
	Btn_forge = 8,
	Btn_bag = 9,
	Btn_setting = 10,
	Btn_shop = 11,
	Btn_auction = 12,
}

Config.MainMenu = {
	[MainMenu_Btn.Btn_role] = {
		icon = "main_role.png",
		name = "word_window_role.png",
		relativePosition = ccp(PosxX+btnSpace*(MainMenu_Btn.Btn_role-1),PosxY),
		clickfunc = {},
		condition = {},	
		openlevel = 1,
		tips = "",	
	},	
	[MainMenu_Btn.Btn_bag] = {
		icon = "main_bag.png",
		name = "word_window_bag.png",
		relativePosition = ccp(PosxX+btnSpace*(MainMenu_Btn.Btn_bag-1),PosxY),
		clickfunc = {},
		condition = {},		
		openlevel = 1,
		tips = "",
	},	
	[MainMenu_Btn.Btn_skill] = {
		icon = "main_skill.png",
		name = "word_window_skill.png",
		relativePosition = ccp(PosxX+btnSpace*(MainMenu_Btn.Btn_skill-1),PosxY),
		clickfunc = {},
		condition = {},
		openlevel = 1,
		tips = "",				
	},	
	[MainMenu_Btn.Btn_faction] = {
		icon = "main_faction.png",
		name = "word_window_sociaty.png",
		relativePosition = ccp(PosxX+btnSpace*(MainMenu_Btn.Btn_faction-1),PosxY),
		clickfunc = {},
		condition = {},		
		openlevel = 1,
		tips = "",
	},	
	[MainMenu_Btn.Btn_talisman] = {
		icon = "main_artifact.png",
		name = "word_window_magic_weapon.png",
		relativePosition = ccp(PosxX+btnSpace*(MainMenu_Btn.Btn_talisman-1),PosxY),
		clickfunc = {},
		condition = {},		
		openlevel = 45,
		tips = Config.Words[25902],
	},	
	[MainMenu_Btn.Btn_mount] = {
		icon = "main_mounts.png",
		name = "word_window_ride.png",
		relativePosition = ccp(PosxX+btnSpace*(MainMenu_Btn.Btn_mount-1),PosxY),
		clickfunc = {},
		condition = {},		
		openlevel = 40,
		tips = Config.Words[25901],
	},	
	[MainMenu_Btn.Btn_wing] = {
		icon = "main_wing.png",
		name = "word_window_wing.png",
		relativePosition = ccp(PosxX+btnSpace*(MainMenu_Btn.Btn_wing-1),PosxY),
		clickfunc = {},
		condition = {},		
		openlevel = 50,
		tips = Config.Words[25903],
	},	
	[MainMenu_Btn.Btn_forge] = {
		icon = "main_forge.png",
		name = "word_window_forge.png",
		relativePosition = ccp(PosxX+btnSpace*(MainMenu_Btn.Btn_forge-1),PosxY),
		clickfunc = {},
		condition = {},		
		openlevel = 50,
		tips = Config.Words[25904],
	},	
	[MainMenu_Btn.Btn_achieve] = {
		icon = "main_achieve.png",
		name = "word_window_achievement.png",
		relativePosition = ccp(PosxX+btnSpace*(MainMenu_Btn.Btn_achieve-1),PosxY),
		clickfunc = {},
		condition = {},		
		openlevel = 1,
		tips = "",
	},	
	[MainMenu_Btn.Btn_shop] = {
		icon = "main_mall.png",
		name = "word_window_mall.png",
		relativePosition = ccp(PosxX+btnSpace*(MainMenu_Btn.Btn_shop-2), 90+PosxY),
		clickfunc = {},
		condition = {},		
		openlevel = 1,
		tips = "",
	},
	[MainMenu_Btn.Btn_setting] = {
		icon = "main_setting.png",
		name = "word_window_setting.png",			
		relativePosition = ccp(PosxX+btnSpace*(MainMenu_Btn.Btn_setting-1), PosxY),
		clickfunc = {},
		condition = {},		
		openlevel = 1,
		tips = "",
	},	
		
	[MainMenu_Btn.Btn_auction] = {
		icon = "main_auction.png",
		name = "word_auction.png",			
		relativePosition = ccp(PosxX + btnSpace * 8, 90+PosxY),
		clickfunc = {},
		condition = {},		
		openlevel = 1,
		tips = "",
	},	
}