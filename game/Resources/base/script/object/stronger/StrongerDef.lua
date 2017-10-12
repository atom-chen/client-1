
StrongerDetailType = 
{
	NeedStronger = 1, 	--我要变强
	NeedMaterial = 2,	--我要材料
}		

StrongerOptionType = 
{
	NeedStroger = 1, 
	NeedExp = 2,
	NeedEquip = 3,
	NeedZuoqidan = 4,
	NeedYumao = 5,
	NeedFabaosuipian = 6,
	NeedJinjieshi = 7,
	NeedJinbi = 8,
	NeedHeitiekuang = 9,
	NeedGongxun = 10
}

StrongerChannel = 
{
	ZhengMoTa = 1, --镇魔塔
	DailyQuest = 2, --日常任务
	HandUpPoint = 3, --黄金挂机点
	Instance = 4, --副本
	Boss = 5, --打BOSS
	Arena = 6,--竞技场
	Mining = 7,--挖矿活动
	monstInvasion = 8,--怪物入侵活动
	eliteMonster = 9, -- 精英怪
}

--配置。以后会改成读表的形式。
--content 表示该类选项里面有哪些内容
--[[const_optionConfig =  
{
	[StrongerOptionType.NeedStroger] = {name = "我要变强", contentList = {1, 2, 3, 4, 5, 6}},
	[StrongerOptionType.NeedExp] = {name = "我要经验", contentList = {6, 5, 4, 3, 2, 1}},
	[StrongerOptionType.NeedEquip] = {name = "我要装备", contentList = {1, 2, 3, 4, 5, 6}},
	[StrongerOptionType.NeedZuoqidan] = {name = "我要坐骑丹", contentList = {6, 5, 4, 3, 2, 1}},
	[StrongerOptionType.NeedYumao] = {name = "我要羽毛", contentList = {1, 2, 3, 4, 5, 6}},
	[StrongerOptionType.NeedFabaosuipian] = {name = "我要法宝碎片", contentList = {6, 5, 4, 3, 2, 1}},
	[StrongerOptionType.NeedJinjieshi] = {name = "我要进阶石", contentList = {1, 2, 3, 4, 5, 6}},
	[StrongerOptionType.NeedJinbi] = {name = "我要金币", contentList = {6, 5, 4, 3, 2, 1}},
	[StrongerOptionType.NeedHeitiekuang] = {name = "我要黑铁矿", contentList = {1, 2, 3, 4, 5, 6}},
	[StrongerOptionType.NeedGongxun] = {name = "我要功勋", contentList = {6, 5, 4, 3, 2, 1}}
}--]]