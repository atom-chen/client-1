--[[
���ܱ�����ص�����
]]

Config = Config or {}

-- DirType: 		1--�෽��  		0--������
-- TargetType:		1--���ڵ�ͼ��	0--����CharacterObject����
-- MapLayer:		0-�����, 1-������,  2-��Ч��
-- Offset:			λ�õ�ƫ����, ����ַ���Ҫ��5�����򶼱�ǳ���
-- Align:			���뷽��, ���û�У���Ĭ��ֱ����ӵ�Ŀ��λ��
--					��ѡֵ: top, center, bottom
-- Rotate:			�Ƿ���Ҫ��ת
-- Number:			�ظ����ֵ�������λ����RandomRadius�����
-- RandomRadius:	���λ�õİ뾶
-- RandomMaxDelay:	���ֵ�����������ӳ�
-- Scale:			����������ֵ

-- type:	�������  1=���㼼�ܣ�ѡ��Ŀ��ʩ�ţ�2=�����ܣ����Լ�������ʩ�ţ�3=���ӣ��㼼���ٵ㳡����
-- PrePlay: Ԥ�Ȳ��ż��ܶ���
-- caster:	ʩ������صĶ���
-- skill:	���ܱ���Ķ���
-- hit:		����Ŀ����صĶ���
-- bullet:	�ӵ���صĶ���
--isSingleSprite: �Ƿ��ǵ���ͼƬ
-- death:	��������ID�� ���û�У�����Ĭ�ϵ������Ķ���

-- actionType: 1--����ID 2--���� 3--����

Config.Animate = {
	["skill_0"] = {
		["name"] = "��ͨ����",
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
		["name"] = "��ɱ����",
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
		["name"] = "��ɱ����",
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
		["name"] = "��Ѫ��ɱ����",
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
		["name"] = "���ٴ�ɱ����",
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
		["name"] = "������ɱ����",
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
		["name"]="���½���",
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
		["name"]="ȫ���䵶",
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
		["name"]="��������䵶",
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
		["name"]="Ұ����ײ",
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
		["name"]="ѣ��Ұ����ײ",
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
		["name"]="��ɱҰ����ײ",
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
		["name"]="�һ𽣷�",	
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
		["name"]="�����һ𽣷�",	
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
		["name"]="��������",	
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
		["name"] = "С����",
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
		["name"] = "���ܻ�",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
			{["type"]="sound", ["name"]="skill_fs_2_1"},
			{["type"]="characterAni", ["animateId"] = 7070, ["DirType"] = 0}
		},
	},
	["skill_fs_3"] = {
		["name"] = "������",
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
		["name"] = "�߼�������",
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
		["name"] = "�׵�",
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
		["name"] = "����׵�",
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
		["name"] = "˲���ƶ�",
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
		["name"] = "�����",
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
		["name"] = "���ջ���",
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
		["name"] = "���ѻ���",
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
		["name"] = "�߼����ѻ���",
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
		["name"] = "��ǽ",
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
		["name"] = "�߼���ǽ",
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
		["name"] = "�����׵�",
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
		["name"] = "���������Ӱ",
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
		["name"] = "�����׹�",
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
		["name"] = "�߼������׹�",
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
		["name"] = "ħ����",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_fs_11_1"},
			{["type"]="characterAni", ["animateId"] = 7160, ["DirType"] = 0},	
		}
	},
	["skill_fs_11_1"] = {
		["name"] = "����ħ����",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_fs_11_1"},
			{["type"]="characterAni", ["animateId"] = 7160, ["DirType"] = 0},		
		}
	},	
	["skill_fs_12"] = {
		["name"] = "������",
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
		["name"] = "���ٱ�����",
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
		["name"] = "������",
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
		["name"] = "�߼�������",
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
		["name"] = "ʩ����",
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
		["name"] = "Ⱥ��ʩ����",
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
		["name"] = "�����",
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
		["name"] = "���������",
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
		["name"] = "���������",
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
		["name"] = "�ٻ�����",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_5_1"}	
		},	
	},
	["skill_ds_5_1"] = {
		["name"] = "�ٻ����þ���",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_5_1"}	
		},			
	},
	["skill_ds_5_2"] = {
		["name"] = "�ٻ����ü���",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_5_1"}	
		},
	},		
	["skill_ds_6"] = {
		["name"] = "������",
		["type"] = 1,
		["PrePlay"] = true,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 7},
			{["type"]="sound", ["name"]="skill_ds_6_1"}	,
			{["type"]="characterAni", ["animateId"] = 7220, ["DirType"] = 0},
		},			
	},
	["skill_ds_7"] = {
		["name"] = "ħ����",
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
		["name"] = "�￹��",
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
		["name"] = "Ⱥ��������",
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
		["name"] = "Ⱥ������",
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
		["name"] = "�ٻ�����",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_11_1"}
		}
	},
	["skill_ds_11_1"] = {
		["name"] = "�ٻ���������",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_11_1"}
		}
	},
	["skill_ds_11_2"] = {
		["name"] = "�ٻ���������",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_11_1"}
		}
	},
	["skill_ds_11_3"] = {
		["name"] = "�ٻ������������",
		["type"] = 1,
		["PrePlay"] = false,
		["caster"]= {
			{["type"]="characterAction", ["actionType"] = 1, ["actionId"] = 6},
			{["type"]="sound", ["name"]="skill_ds_11_1"}
		}
	},	
	--���＼��
	["skill_1"] = {
		["name"]="����ͷ",
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
		["name"] = "�´�",--�޴�����Ч������ʹ�õ��������
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
		["name"] = "��ζ���",
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
		["name"] = "������",
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
		["name"] = "���ѻ���",
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
		["name"] = "�����׵�",
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
		["name"] = "�����׹�",
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
		["name"] = "������",
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
		["name"] = "������",
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
		["name"] = "�����",
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
		["name"] = "ɳ�桤������������",
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
		["name"] = "���ޱ���",
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
		["name"] = "�ɶꡤ�����������",
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
		["name"] = "�����������ͨħ��",
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
		["name"] = "�����񡤷���",
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
		["name"] = "��ħ֩�롤�����������",
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
		["name"] = "���¶�ħ�������׹�",
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
		["name"] = "��Ȫ��������ͨħ��",
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
		["name"] = "���ü��ֱ�����Ͷ��",
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
		["name"] = "�������ޱ��������䣨����",
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
		["name"] = "�������ޱ��������䣨��",
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
		["name"] = "���ڽ���",
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