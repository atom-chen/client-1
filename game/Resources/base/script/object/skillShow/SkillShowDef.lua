--[[
技能表演的一些基本的结构和枚举定义
]]--

SkillShowDef = SkillShowDef or {}

SkillShowDef.MaxSpawnPlayCount = 3				-- 每帧播放的AnimatePlayer的最大数量
SkillShowDef.MaxBeHitCount = 10					-- 全屏最大的受击动作的播放数量
SkillShowDef.MaxMapAnimateCount = 15			-- 地图特效的全屏最大播放数量
SkillShowDef.MaxCharacterAnimateCount = 15		-- 加载在角色身上的特效的最大播放数量
SkillShowDef.MaxFightTextCount = 15				-- 全屏播放最大的飘字的数量
SkillShowDef.MaxMapUniqueCount = 3				-- 单个特效的全屏最大的播放数量
SkillShowDef.MaxCharacterUniqueCount = 1		-- 一个角色身上单个特效的最大堆叠次数