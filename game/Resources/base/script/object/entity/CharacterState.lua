-- 角色的状态定义

-- 角色的行为状态
CharacterState={
	CharacterStateNone = 100,
	CharacterStateIdle = 101,
	CharacterStateMove = 102,			-- 移动
	CharacterStateHit = 103,			-- 受击
	CharacterStateUseSkill = 104,		-- 使用技能
	CharacterStateDead = 105,			-- 死亡
	CharacterStateWillDead = 106,		-- 死亡的预备状态, 用于做一些死亡的效果表现
	CharacterStateHitFly = 107,			-- 击飞
	CharacterStateHitBack = 108,		-- 击退
	CharacterStateRideIdle = 109,		-- 坐骑待机
	CharacterStateRideMove = 110,		-- 坐骑移动	
	CharacterStateCollect = 306,		-- 采集	
}

CharacterFightState={
	Bleed = 501,			-- 流血
	Burn = 502,				-- 灼烧
	Dizzy = 503,			-- 眩晕
	Slient = 504,			-- 沉默
	Invincible = 505,		-- 无敌
	MagicImmune = 506,		-- 魔法免疫
	Paresis = 507,			-- 麻痹
	PhysicalImmune = 508,	-- 物理免疫
	Poison = 509,			-- 中毒
	Slow = 510,				-- 减速
	Invisible = 511,		-- 隐身
	Mofadun =   512,		-- 魔法盾
}

-- 角色的action切换的类型
CharacterMovement={
	Start = 0,
	Finish = 1,
	LoopFinish = 2,
	Cancel = 3
}