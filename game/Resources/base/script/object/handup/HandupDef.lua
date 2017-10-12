--挂机定义。配置挂机中的各种行为

require ("object.entity.EntityObject")
require ("object.mainHeroState.HeroStateDef")
require ("object.target.FightTargetDef")

--定义挂机在打不同目标时使用的PK模式
HandupPKModeMap =  
{
	[E_AutoSelectTargetMode.Normal] 	= E_HeroPKState.statePeace,		--和平
	[E_AutoSelectTargetMode.CastleWar] 	= E_HeroPKState.stateFaction, 	--公会
	[E_AutoSelectTargetMode.Collect] 	= nil,							--采集模式下不需要主动攻击目标
}

--定义挂机在反击时使用的PK模式
const_fightBackPKMode = E_HeroPKState.stateGoodOrEvil

--定义拾取的标准延时（在打完怪之后，需要一定时间后服务器才能将掉落物推送过来）
const_handupDelayPickupTime = 0.2

--定义挂机半径
const_handupRadius 				= 100	
--以攻击目标为原点，const_multipleAttackCheckRadius为半径的范围内有多少个怪物，则使用群攻
const_multipleAttackCheckRadius = 10	
--以攻击目标为原点，该值为半径的范围内有const_multipleAttackCheckCount个怪物，则使用群攻
const_multipleAttackCheckCount 	= 3		

--从攻击者里选择目标的策略：随机或者最近
--const_selectTargetFromAttackersType = "random"	
const_selectTargetFromAttackersType = "closest"	

--挂机消息的枚举
E_HandupMsgType = 
{
	BeAttacked 		= 1,	--被攻击
	StopWithPickup 	= 2,	--拾取完东西后再结束
--	ReselectTarget	= 3,	--重新选择目标
}

--挂机状态机状态的类型枚举
E_HandupStateType = 
{
	Pickup 		= "Pickup", 			--拾取指定，拾取全部，拾取全部
	Fight 		= "Fight", 				--打怪，打玩家{不同职业：（距离、属性相克）} {放技能逻辑}
	FightBack 	= "FightBack", 			--反击
	Search 		= "Search", 			--寻怪物，寻NPC
	Collect 	= "Collect", 			--采集
	Global 		= "Global", 			--全局状态，处理一些全局消息等
}	

--挂机时寻找目标的模式
E_SearchTargetMode = 
{
	Random = "Random", 	--随机找目标
	RefId  = "RefId",	--根据refId找目标
}

function G_getHandupFSM()
	return G_getHandupMgr():getFSM()
end

function G_getHandupMgr()
	return G_getHero():getHandupMgr()
end

function G_getHandupConfigMgr()
	return G_getHandupMgr():getConfigMgr()
end