--自动选择目标模式
E_AutoSelectTargetMode = 
{
	Normal 				= "Normal", 	--只选择怪物
	CastleWar			= "CastleWar", 	--沙巴克攻城模式
	Collect				= "Collect", 	--
}

--重新选择目标的策略
E_SelectTargetType = 
{
	Closest = "Closest",
	Random 	= "Random"
}

function G_getFightTargetMgr()
	return GameWorld.Instance:getFightTargetMgr()
end