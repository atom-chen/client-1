#ifndef EntityData_h__
#define EntityData_h__

#include <map>
#include <string>

/// 实体动作
enum EntityAction
{
	eEntityAction_Effect = 0,

	eEntityAction_Idle=1,//站立
	eEntityAction_Run=0,		//跑步动作
	eEntityAction_Attack=2,	//攻击
	eEntityAction_Dead,
	eEntityAction_RideIdle=4,	//角色的坐骑动作
	eEntityAction_RideRun=5,//角色的坐骑移动
	eEntityAction_Hit = 3,
	eEntityAction_Skill1=6,
	eEntityAction_Skill2=7,
	eEntityAction_Skill3=8,
	EntityAction_Max,				/// 动作最大值
};



/// 实体部件
enum EntityParts
{
	eEntityPart_Mount = 0,//坐骑
	eEntityPart_Body,		// 裸体
	eEntityPart_Cloth,		//衣服
	eEntityPart_Weapon,//武器
	eEntityPart_Wing,//翅膀
	eEntityPart_Max,
};

#endif // EntityData_h__