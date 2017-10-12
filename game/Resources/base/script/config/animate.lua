--[[
技能表演相关的配置
]]

Config = Config or {}

-- DirType: 		1--多方向  		0--单方向
-- TargetType:		1--放在地图上	0--放在CharacterObject身上
-- MapLayer:		0-精灵层, 1-背景层,  2-特效层
-- Offset:			位置的偏移量, 如果分方向，要把5个方向都标记出来
-- Align:			对齐方法, 如果没有，就默认直接添加到目标位置
--					可选值: top, center, bottom
-- Rotate:			是否需要旋转
-- Number:			重复出现的数量，位置由RandomRadius内随机
-- RandomRadius:	随机位置的半径
-- RandomMaxDelay:	出现的最大的随机的延迟
-- Scale:			动画的缩放值

-- type:	技能类别  1=定点技能（选中目标施放）2=朝向技能（朝自己的面向施放）3=格子（点技能再点场景）
-- PrePlay: 预先播放技能动画
-- caster:	施法者相关的动作
-- skill:	技能本身的动画
-- hit:		击中目标相关的动作
-- bullet:	子弹相关的动作
--isSingleSprite: 是否是单张图片
-- death:	死亡动画ID， 如果没有，会用默认的死亡的动画

-- actionType: 1--动作ID 2--击退 3--击飞

Config.Animate = {
	["skill_0"] = {
		["name"] = "普通攻击",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="sound", ["name"]="skill_0_1"}
		},
		["hit"]={
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3}
		},
	},
	["skill_zs_2"] = {
		["name"] = "攻杀剑法",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="sound", ["name"]="skill_zs_2_1"},			
			{["type"]="characterAni", ["animateId"] = 7010, ["DirType"] = 1}
		},
		["hit"]={
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="characterAni", ["animateId"] = 7011, ["DirType"] = 0, ["Align"] = "center"}
		},
	},
	["skill_zs_3"] = {
		["name"] = "刺杀剑法",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="sound", ["name"]="skill_zs_3_1"},
			{["type"]="characterAni", ["animateId"] = 7020, ["DirType"] = 1},
			{["type"]="mapAni", ["animateId"] = 7022, ["DirType"] = 1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			--{["type"]="characterAni", ["animateId"] = 7021, ["DirType"] = 0, ["Align"] = "center"}
		},
	},
	["skill_zs_3_1"] = {
		["name"] = "流血刺杀剑法",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="sound", ["name"]="skill_zs_3_1"},
			{["type"]="characterAni", ["animateId"] = 7460, ["DirType"] = 1},
			{["type"]="mapAni", ["animateId"] = 7461, ["DirType"] = 1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="characterAni", ["animateId"] = 7462, ["DirType"] = 0, ["Align"] = "center"}
		},
	},
	["skill_zs_3_2"] = {
		["name"] = "减速刺杀剑法",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="sound", ["name"]="skill_zs_3_1"},
			{["type"]="characterAni", ["animateId"] = 7460, ["DirType"] = 1},
			{["type"]="mapAni", ["animateId"] = 7022, ["DirType"] = 1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			--{["type"]="characterAni", ["animateId"] = 7021, ["DirType"] = 0, ["Align"] = "center"}
		},
	},
	["skill_zs_3_3"] = {
		["name"] = "暴击刺杀剑法",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="sound", ["name"]="skill_zs_3_1"},
			{["type"]="characterAni", ["animateId"] = 7020, ["DirType"] = 1},
			{["type"]="mapAni", ["animateId"] = 7022, ["DirType"] = 1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			--{["type"]="characterAni", ["animateId"] = 7021, ["DirType"] = 0, ["Align"] = "center"}
		},
	},				
	["skill_zs_4"] = {
		["name"]="半月剑法",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 8},
			{["type"]="sound", ["name"]="skill_zs_4_1"},
			{["type"]="characterAni", ["animateId"] = 7030, ["DirType"] = 1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			--{["type"]="characterAni", ["animateId"] = 7021, ["DirType"] = 0, ["Align"] = "center"}
		},
	},
	["skill_zs_4_1"] = {
		["name"]="全月弯刀",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 8},
			{["type"]="sound", ["name"]="skill_zs_4_1_1"},
			{["type"]="characterAni", ["animateId"] = 7470, ["DirType"] = 1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},		
		},
	},
	["skill_zs_4_2"] = {
		["name"]="火焰半月弯刀",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 8},
			{["type"]="sound", ["name"]="skill_zs_6_1"},
			{["type"]="characterAni", ["animateId"] = 7480, ["DirType"] = 1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			--{["type"]="characterAni", ["animateId"] = 7021, ["DirType"] = 0, ["Align"] = "center"}
		},
	},	
	["skill_zs_5"] = {
		["name"]="野蛮冲撞",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAni", ["animateId"] = 7040, ["DirType"] = 1},
			{["type"]="sound", ["name"]="skill_zs_5_1"},
			{["type"]="characterAction", ["actionType"] = 2, ["time"] = 0.6}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 3, ["time"] = 0.6}
		},
	},
	["skill_zs_5_1"] = {
		["name"]="眩晕野蛮冲撞",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAni", ["animateId"] = 7040, ["DirType"] = 1},
			{["type"]="sound", ["name"]="skill_zs_5_1"},
			{["type"]="characterAction", ["actionType"] = 2, ["time"] = 0.6}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 3, ["time"] = 0.6}
		},
	},
	["skill_zs_5_2"] = {
		["name"]="刺杀野蛮冲撞",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAni", ["animateId"] = 7040, ["DirType"] = 1},
			{["type"]="sound", ["name"]="skill_zs_5_1"},
			{["type"]="characterAction", ["actionType"] = 2, ["time"] = 0.6}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 3, ["time"] = 0.6}
		},
	},	
	["skill_zs_6"] = {
		["name"]="烈火剑法",	
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="sound", ["name"]="skill_zs_6_1"},
			{["type"]="characterAni", ["animateId"] = 7050, ["DirType"] = 1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="characterAni", ["animateId"] = 7051, ["DirType"] = 0, ["Align"] = "center"}
		},
		["death"]=8016
	},
	["skill_zs_6_1"] = {
		["name"]="极速烈火剑法",	
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="sound", ["name"]="skill_zs_6_1"},
			{["type"]="characterAni", ["animateId"] = 7050, ["DirType"] = 1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="characterAni", ["animateId"] = 7051, ["DirType"] = 0, ["Align"] = "center"}
		},
		["death"]=8016
	},	
	["skill_zs_6_2"] = {
		["name"]="雷霆剑法",	
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="sound", ["name"]="skill_fs_4_4"},
			{["type"]="characterAni", ["animateId"] = 7500, ["DirType"] = 1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="characterAni", ["animateId"] = 7501, ["DirType"] = 0, ["Align"] = "center"}
		},
		["death"]=8015
	},
	["skill_fs_1"] = {
		["name"] = "小火球",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_fs_1_1"},
			{["type"]="characterAni", ["animateId"] = 7060, ["DirType"] = 1}
		},
		["bullet"] = {
			{["type"]="bulletAni", ["animateId"] = 7061, ["Rotate"]=1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="sound", ["name"]="skill_fs_1_4"},
			{["type"]="characterAni", ["animateId"] = 7062, ["DirType"] = 0, ["Align"] = "center"}
		},
		["death"]=8016
	},
	["skill_fs_2"] = {
		["name"] = "抗拒火环",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
			{["type"]="sound", ["name"]="skill_fs_2_1"},
			{["type"]="characterAni", ["animateId"] = 7070, ["DirType"] = 0}
		},
	},
	["skill_fs_3"] = {
		["name"] = "地狱火",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},		
			{["type"]="mapAni", ["animateId"] = 7080, ["DirType"] = 1, ["MapLayer"] = 1,["Offset"]={[1] = {110,65}, [3] = {-45 , -55},[4]={0,-88}}},
			{["type"]="sound", ["name"]="skill_fs_3_3"}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		},
		["death"]=8016
	},
	["skill_fs_3_1"] = {
		["name"] = "高级地狱火",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_fs_3_3"},
			{["type"]="mapAni", ["animateId"] = 7080, ["DirType"] = 1, ["MapLayer"] = 1,["Offset"]={[1] = {110,65}, [3] = {-45 , -55},[4]={0,-88}}}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		},
		["death"]=8016
	},	
	["skill_fs_4"] = {
		["name"] = "雷电",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
			{["type"]="sound", ["name"]="skill_fs_4_1"},
			{["type"]="characterAni", ["animateId"] = 7092, ["DirType"] = 0}
		},
		["skill"]={
			{["type"]="mapAni", ["animateId"] = 7090, ["DirType"] = 0, ["MapLayer"] = 2},
			{["type"]="mapAni", ["animateId"] = 7091, ["DirType"] = 0, ["MapLayer"] = 1},
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="sound", ["name"]="skill_fs_4_4"}
		},
		["death"]=8015
	},
	["skill_fs_4_1"] = {
		["name"] = "麻痹雷电",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
			{["type"]="sound", ["name"]="skill_fs_4_1"},
			{["type"]="characterAni", ["animateId"] = 7092, ["DirType"] = 0}
		},
		["skill"]={
			{["type"]="mapAni", ["animateId"] = 7090, ["DirType"] = 0, ["MapLayer"] = 2},
			{["type"]="mapAni", ["animateId"] = 7091, ["DirType"] = 0, ["MapLayer"] = 1},
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="sound", ["name"]="skill_fs_4_4"},
		},
		["death"]=8015
	},	
	["skill_fs_5"]={
		["name"] = "瞬间移动",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
			{["type"]="sound", ["name"]="skill_fs_5_1"},
			{["type"]="sequence", ["animate"]={
				{["type"]="characterAni", ["animateId"] = 7100, ["DirType"] = 0},
				{["type"]="characterAlpha", ["alpha"]=0},
				{["type"]="characterPosition"},
				{["type"]="sound", ["name"]="skill_fs_5_4"},
				{["type"]="characterAni", ["animateId"] = 7101, ["DirType"] = 0},
				{["type"]="characterAlpha", ["alpha"]=255},

			}}
		},
	},
	["skill_fs_6"] = {
		["name"] = "大火球",
		["type"] = 1,	
		["PrePlay"] = true,	
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_fs_1_1"},
			{["type"]="characterAni", ["animateId"] = 7060, ["DirType"] = 1}
		},
		["bullet"] = {
			{["type"]="bulletAni", ["animateId"] = 7111, ["Rotate"]=0}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="sound", ["name"]="skill_fs_1_4"},
			{["type"]="characterAni", ["animateId"] = 7062, ["DirType"] = 0, ["Align"] = "center"}
		},
		["death"]=8016
	},
	["skill_fs_6_1"] = {
		["name"] = "灼烧火球",
		["type"] = 1,	
		["PrePlay"] = true,	
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_fs_1_1"},
			{["type"]="characterAni", ["animateId"] = 7060, ["DirType"] = 1}
		},
		["bullet"] = {
			{["type"]="bulletAni", ["animateId"] = 7111, ["Rotate"]=0}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="sound", ["name"]="skill_fs_1_4"},
			{["type"]="characterAni", ["animateId"] = 7062, ["DirType"] = 0, ["Align"] = "center"}
		},
		["death"]=8016
	},	
	["skill_fs_7"] = {
		["name"] = "爆裂火焰",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
		},
		["skill"] = {
			{["type"]="sound", ["name"]="skill_fs_7_3"},
			{["type"]="mapAni", ["animateId"] = 7122, ["DirType"] = 0, ["MapLayer"] = 1},
			{["type"]="mapAni", ["animateId"] = 7121, ["DirType"] = 0, ["MapLayer"] = 2}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		},
		["death"]=8016
	},
	["skill_fs_7_1"] = {
		["name"] = "高级爆裂火焰",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
		},
		["skill"] = {
			{["type"]="sound", ["name"]="skill_fs_7_3"},
			{["type"]="mapAni", ["animateId"] = 7122, ["DirType"] = 0, ["MapLayer"] = 1},
			{["type"]="mapAni", ["animateId"] = 7121, ["DirType"] = 0, ["MapLayer"] = 2}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		},
		["death"]=8016
	},	
	["skill_fs_8"] = {
		["name"] = "火墙",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
			{["type"]="sound", ["name"]="skill_fs_1_1"},
			{["type"]="characterAni", ["animateId"] = 7081, ["DirType"] = 0}
		},
		["skill"] = {
			{["type"]="sound", ["name"]="skill_fs_8_3"}
		},		
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			--{["type"]="RectGroup", ["width"]=3, ["height"]=3, ["animate"]={["type"]="mapAni", ["animateId"] = 7130, ["DirType"] = 0, ["MapLayer"] = 2}},
		}
	},
	["skill_fs_8_1"] = {
		["name"] = "高级火墙",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
			{["type"]="sound", ["name"]="skill_fs_1_1"},
			{["type"]="characterAni", ["animateId"] = 7081, ["DirType"] = 0}
		},
		["skill"] = {
			{["type"]="sound", ["name"]="skill_fs_8_3"}
		},			
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			--{["type"]="RectGroup", ["width"]=3, ["height"]=3, ["animate"]={["type"]="mapAni", ["animateId"] = 7130, ["DirType"] = 0, ["MapLayer"] = 2}},
		}
	},	
	["skill_fs_9"] = {
		["name"] = "疾光雷电",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_fs_9_3"},
			{["type"]="mapAni", ["animateId"] = 7140, ["DirType"] = 1, ["MapLayer"] = 2, ["Offset"]={[0]={0, -1},[1]={0, -1}, [2]={0, 0}, [3]={0, 0}, [4]={0, 0}}},
			{["type"]="mapAni", ["animateId"] = 7141, ["DirType"] = 0, ["MapLayer"] = 2, ["Rotate"]=1, ["Offset"]={[0]={-5, -88},[1]={30, -100}, [2]={47,-88}, [3]={40, -70}, [4]={23, -70}}}
		},
		["hit"] = {	
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		},
		["death"]=8015
	},
	["skill_fs_9_1"] = {
		["name"] = "连锁疾光电影",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_fs_9_1_3"},
			{["type"]="mapAni", ["animateId"] = 7140, ["DirType"] = 1, ["MapLayer"] = 2, ["Offset"]={[0]={0, -1},[1]={0, -1}, [2]={0, 0}, [3]={0, 0}, [4]={0, 0}}},
			{["type"]="mapAni", ["animateId"] = 7141, ["DirType"] = 0, ["MapLayer"] = 2, ["Rotate"]=1, ["Offset"]={[0]={-5, -88},[1]={30, -100}, [2]={47,-88}, [3]={40, -70}, [4]={23, -70}}}
		},
		["hit"] = {	
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="characterAni", ["animateId"] = 7561, ["DirType"] = 0, ["Align"] = "center"}
		},
		["death"]=8015
	},	
	["skill_fs_10"] = {
		["name"] = "地狱雷光",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
			{["type"]="sound", ["name"]="skill_fs_10_1"},
			{["type"]="characterAni", ["animateId"] = 7150, ["DirType"] = 0},
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		},
		["death"]=8015
	},
	["skill_fs_10_1"] = {
		["name"] = "高级地狱雷光",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
			{["type"]="sound", ["name"]="skill_fs_10_1"},
			{["type"]="characterAni", ["animateId"] = 7150, ["DirType"] = 0},
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		},
		["death"]=8015
	},
	["skill_fs_11"] = {
		["name"] = "魔法盾",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_fs_11_1"},
			{["type"]="characterAni", ["animateId"] = 7160, ["DirType"] = 0},	
		}
	},
	["skill_fs_11_1"] = {
		["name"] = "闪避魔法盾",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_fs_11_1"},
			{["type"]="characterAni", ["animateId"] = 7160, ["DirType"] = 0},		
		}
	},	
	["skill_fs_12"] = {
		["name"] = "冰咆哮",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
		},
		["skill"] = {		
			{["type"]="mapAni", ["animateId"] = 7170, ["DirType"] = 0, ["MapLayer"] = 2},
			{["type"]="sound", ["name"]="skill_fs_12_3"}
		},
		["hit"]={
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		},
		["death"]=8015
	},
	["skill_fs_12_1"] = {
		["name"] = "减速冰咆哮",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
		},
		["skill"] = {		
			{["type"]="mapAni", ["animateId"] = 7170, ["DirType"] = 0, ["MapLayer"] = 2},
			{["type"]="sound", ["name"]="skill_fs_12_3"}
					},
		["hit"]={
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		},
		["death"]=8015
	},	
	["skill_ds_1"] = {
		["name"] = "治愈术",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_1_1"},
			{["type"]="characterAni", ["animateId"] = 7180, ["DirType"] = 0},
		},
		["skill"] = {
			{["type"]="characterAni", ["animateId"] = 7181, ["DirType"] = 0},
			{["type"]="sound", ["name"]="skill_ds_1_4"}
		}
	},
	["skill_ds_1_1"] = {
		["name"] = "高级治愈术",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_1_1"},
			{["type"]="characterAni", ["animateId"] = 7180, ["DirType"] = 0},
		},
		["skill"] = {
			{["type"]="characterAni", ["animateId"] = 7181, ["DirType"] = 0},
			{["type"]="sound", ["name"]="skill_ds_1_4"}
		}
	},	
	["skill_ds_3"] = {
		["name"] = "施毒术",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
		},
		["skill"]={
			{["type"]="mapAni", ["animateId"] = 7190, ["DirType"] = 0, ["MapLayer"] = 2},
			{["type"]="sound", ["name"]="skill_ds_3_4"}	
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},		
		},
		["death"]=8011
	},
	["skill_ds_3_1"] = {
		["name"] = "群体施毒术",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},		
		},
		["skill"]={
			{["type"]="mapAni", ["animateId"] = 7190, ["DirType"] = 0, ["MapLayer"] = 2},
			{["type"]="sound", ["name"]="skill_ds_3_4"}	
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},		
		},
		["death"]=8011
	},	
	["skill_ds_4"] = {
		["name"] = "灵魂火符",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_4_1"},	
			{["type"]="characterAni", ["animateId"] = 7200, ["DirType"] = 0},
		},
		["bullet"] = {
			{["type"]="bulletAni", ["animateId"] = 7201, ["Rotate"]=1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="sound", ["name"]="skill_ds_4_4"}	,
			{["type"]="characterAni", ["animateId"] = 7202, ["DirType"] = 0, ["Align"] = "center"},
		},
		["death"]=8016
	},
	["skill_ds_4_1"] = {
		["name"] = "爆裂灵魂火符",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_4_1"},	
			{["type"]="characterAni", ["animateId"] = 7200, ["DirType"] = 0},
		},
		["bullet"] = {
			{["type"]="bulletAni", ["animateId"] = 7201, ["Rotate"]=1}
		},
		["skill"] = {
			{["type"]="mapAni", ["animateId"] = 7202, ["DirType"] = 0, ["MapLayer"] = 2, ["Scale"]=1.5},
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="sound", ["name"]="skill_ds_4_4"}	
		},
		["death"]=8016
	},
	["skill_ds_4_2"] = {
		["name"] = "毒蛊灵魂火符",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_4_1"},	
			{["type"]="characterAni", ["animateId"] = 7200, ["DirType"] = 0},
		},
		["bullet"] = {
			{["type"]="bulletAni", ["animateId"] = 7201, ["Rotate"]=1}
		},
		["skill"] = {
			{["type"]="mapAni", ["animateId"] = 7202, ["DirType"] = 0, ["MapLayer"] = 2, ["Scale"]=1.5},
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="sound", ["name"]="skill_ds_4_4"}
		},
		["death"]=8016
	},	
	["skill_ds_5"] = {
		["name"] = "召唤骷髅",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_5_1"}	
		},	
	},
	["skill_ds_5_1"] = {
		["name"] = "召唤骷髅精灵",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_5_1"}	
		},			
	},
	["skill_ds_5_2"] = {
		["name"] = "召唤骷髅箭手",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_5_1"}	
		},
	},		
	["skill_ds_6"] = {
		["name"] = "隐身术",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
			{["type"]="sound", ["name"]="skill_ds_6_1"}	,
			{["type"]="characterAni", ["animateId"] = 7220, ["DirType"] = 0},
		},			
	},
	["skill_ds_7"] = {
		["name"] = "魔抗术",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
		},
		["skill"] = {
			{["type"]="mapAni", ["animateId"] = 7230, ["DirType"] = 0, ["MapLayer"] = 2},
			{["type"]="sound", ["name"]="skill_ds_7_4"}
		}
	},
	["skill_ds_8"] = {
		["name"] = "物抗术",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},	
		},
		["skill"] = {
			{["type"]="mapAni", ["animateId"] = 7240, ["DirType"] = 0, ["MapLayer"] = 2},
			{["type"]="sound", ["name"]="skill_ds_8_4"}
		}
	},
	["skill_ds_9"] = {
		["name"] = "群体隐身术",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
			{["type"]="sound", ["name"]="skill_ds_6_1"}
		},
		["skill"] = {
			{["type"]="mapAni", ["animateId"] = 7250, ["DirType"] = 0, ["MapLayer"] = 2},		
		}
	},
	["skill_ds_10"] = {
		["name"] = "群体治疗",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},	
		},
		["skill"] = {
			{["type"]="mapAni", ["animateId"] = 7260, ["DirType"] = 0, ["MapLayer"] = 2},
			{["type"]="sound", ["name"]="skill_ds_10_4"}
		}
	},
	["skill_ds_11"] = {
		["name"] = "召唤神兽",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_11_1"}
		}
	},
	["skill_ds_11_1"] = {
		["name"] = "召唤寒冰神兽",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_11_1"}
		}
	},
	["skill_ds_11_2"] = {
		["name"] = "召唤火焰神兽",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_11_1"}
		}
	},
	["skill_ds_11_3"] = {
		["name"] = "召唤闪电沃玛教主",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_11_1"}
		}
	},	
	--怪物技能
	["skill_1"] = {
		["name"]="掷斧头",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},		
		},
		["bullet"] = {
			{["type"]="bulletAni", ["animateId"] = 7700, ["Rotate"]=1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},		
		}
	},	
	["skill_2"] = {
		["name"] = "吐刺",--无此美术效果，暂使用地狱火代替
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},			
		},
		["bullet"] = {
			{["type"]="bulletAni", ["animateId"] = 7701, ["Rotate"]=1 , ["isSingleSprite"] = 1}
		},					
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		}
	},
	["skill_3"] = {
		["name"] = "三味真火",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="characterAni", ["animateId"] = 7310, ["DirType"] = 1}
		},						
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="characterAni", ["animateId"] = 7062, ["DirType"] = 0, ["Align"] = "center"}
		}
	},
	["skill_4"] = {
		["name"] = "惊雷闪",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
		},
		["skill"]={
			{["type"]="mapAni", ["animateId"] = 7090, ["DirType"] = 0, ["MapLayer"] = 2},
			{["type"]="mapAni", ["animateId"] = 7091, ["DirType"] = 0, ["MapLayer"] = 2},
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3}
		}
	},
	["skill_5"] = {
		["name"] = "爆裂火焰",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
		},
		["skill"] = {
			{["type"]="mapAni", ["animateId"] = 7122, ["DirType"] = 0, ["MapLayer"] = 1},
			{["type"]="mapAni", ["animateId"] = 7121, ["DirType"] = 0, ["MapLayer"] = 2}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		},
	},
	["skill_6"] = {
		["name"] = "疾光雷电",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="characterAni", ["animateId"] = 7140, ["DirType"] = 1},
			{["type"]="mapAni", ["animateId"] = 7141, ["DirType"] = 0, ["MapLayer"] = 2, ["Rotate"]=1, ["Offset"]={[0]={-5, -88},[1]={30, -100}, [2]={47,-88}, [3]={40, -70}, [4]={23, -70}}}
		},
		["hit"] = {	
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		}
	},
	["skill_7"] = {
		["name"] = "地狱雷光",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="characterAni", ["animateId"] = 7150, ["DirType"] = 0},
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		}
	},
	["skill_8"] = {
		["name"] = "冰咆哮",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
		},
		["skill"] = {		
			{["type"]="mapAni", ["animateId"] = 7170, ["DirType"] = 0, ["MapLayer"] = 2}
					},		
		["hit"]={
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
		}
	},
	["skill_9"] = {
		["name"] = "毒蛊术",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},		
		},	
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},	
		}
	},
	["skill_10"] = {
		["name"] = "麻痹术",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},				
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},	
		}
	},
	["skill_11"] =  {
		["name"] = "沙虫·毒蛊术·喷射",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="characterAni", ["animateId"] = 7290, ["DirType"] = 1}			
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},	
		}
	},
	["skill_12"] = {
		["name"] = "神兽宝宝",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="characterAni", ["animateId"] = 7703, ["DirType"] = 1}			
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},	
		}
	},
	["skill_13"]  =  {
		["name"] = "飞蛾·麻痹术·喷射",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="characterAni", ["animateId"] = 7340, ["DirType"] = 1}			
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},	
		}
	},
	["skill_14"] =  {
		["name"] = "祖玛教主·普通魔攻",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},	
			{["type"]="characterAni", ["animateId"] = 7350, ["DirType"] = 1, ["MapLayer"] = 2},								
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},																	
		}
	},
	["skill_15"] =  {
		["name"] = "触龙神·辐射",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="characterAni", ["animateId"] = 7360, ["DirType"] = 0, ["Align"] = "center"}			
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},	
		}
	},
	["skill_16"] =  {
		["name"] = "月魔蜘蛛·麻痹术·喷射",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="characterAni", ["animateId"] = 7370, ["DirType"] = 1}			
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},	
		}
	},
	["skill_17"] = {
		["name"] = "赤月恶魔·地狱雷光",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},	
		},											
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="characterAni", ["animateId"] = 7380, ["DirType"] = 0}		
		}
	},
	["skill_18"] = {
		["name"] = "黄泉教主·普通魔攻",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="characterAni", ["animateId"] = 7410, ["DirType"] = 1,},								
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},	
			{["type"]="characterAni", ["animateId"] = 7411, ["DirType"] = 1,},				
		}
	},
	["skill_19"] = {
		["name"] = "骷髅箭手宝宝·投射",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},				
		},
		["bullet"] = {
			{["type"]="bulletAni", ["animateId"] = 7702, ["Rotate"]=1 , ["isSingleSprite"] = 1}
		},				
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},	
		}
	},
	["skill_20"] = {
		["name"] = "寒冰神兽宝宝·喷射（冰）",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},
			{["type"]="characterAni", ["animateId"] = 7530, ["DirType"] = 1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},	
		}
	},
	["skill_21"] = {
		["name"] = "火球神兽宝宝·喷射（火）",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},			
		},
		["bullet"] = {
			{["type"]="bulletAni", ["animateId"] = 7061, ["Rotate"]=1}
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},
			{["type"]="characterAni", ["animateId"] = 7062, ["DirType"] = 0, ["Align"] = "center"}
		},
		["death"]=8016
	},
	["skill_22"] = {
		["name"] = "暗黑教主",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 2},	
			{["type"]="characterAni", ["animateId"] = 7350, ["DirType"] = 1, ["MapLayer"] = 2},					
		},
		["hit"] = {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 3},	
		}
	},			
}

Config.Animate.DefalutDeathEffect = 8011