-- 存放一些可全局使用的方法

require ("ui.utils.UIControl")
require ("config.words")
require("config.MainMenuConfig")
--定义aoi格子大小（单位为const_mapCellSize）。所有涉及到AOI格子大小的地方都应该使用该变量
const_aoiCellSize	= 4	

--定义地图格子大小（单位为像素）。所有涉及到地图格子大小的地方都应该使用该变量
const_mapCellSize	= 16

const_switchSkill_banyue = "skill_zs_4"
const_switchSkill_cisha = "skill_zs_3"
const_skill_gongsha = "skill_zs_2"
const_skill_pugong = "skill_0"

const_skill_liehuojianfa = "skill_zs_6" 
const_skill_zhaohuanshenshou = "skill_ds_11"
const_skill_zhaohuankulou = "skill_ds_5"
const_skill_shidushu = "skill_ds_3"
const_skill_mofadun = "skill_fs_11"

kTableCellSizeForIndex 		= 0
kCellSizeForTable 			= 1
kTableCellAtIndex 			= 2
kNumberOfCellsInTableView 	= 3
kTableViewTouchBegan	= 4
kTableViewTouchMoved	= 5
kTableViewTouchEnded	= 6
kTableViewTouchCanceled	= 7
kTableViewDidAnimateScrollEnd = 8

cont_UIMoveSpeed = 0.3

GameAnalyzeID = 
{
	HeroLevelChange = 1, -- 玩家升级等级 
	CreateRole = 2,  -- 创建角色
	LoginServer = 3, --- 进入服务器 
}

E_BagOption = 
{
	All = 4,
	Equip = 3,
	Drug = 2,
	Other = 1,
}


E_EquipSource = 
{
	inBag = 1,
	inBody = 2
}	




E_CompareRet =
{
Greater = 1,
Smaller = 2,
Equal = 3,
Error 	= -1
}

E_UpdataEvent =
{
Add = 1,
Delete = 2,
Modify = 3
}

E_ItemDetailBtnType =
{
eSell 	= 1,
eShow 	= 2,
ePutOn 	= 3,
eUse  	= 4,
eUnload = 5,
eBuy    = 6,
eCancelSell = 7,
eAuctionSell = 8,
eAuctionCancelSell = 9, 
eAuctionBuy = 10,
eGetOut = 11,
eDetail = 12,
}

E_ItemDetailViewType =
{
eNormal = 1,
eEquip  = 2,
eGift	= 3,
}




E_TipsType = {
	emphasize = 1,
	common = 2,
}
E_MarqueeType = {
	system = 1,
	vipLuck = 2
}

E_EquipShowPriceType = {
	noPrice = 0,
	buyPrice = 1,
	sellPrice = 2,
	auctionPrice = 3,
}


-- 根据职业ID返回职业名称
function G_getProfessionNameById(id)
	if (id == 1) then
		return Config.LoginWords[10128]
	elseif (id == 2) then
		return  Config.LoginWords[10129]
	elseif (id == 3) then
		return Config.LoginWords[10130]
	else
		return "-"
	end
end