--�Զ�ѡ��Ŀ��ģʽ
E_AutoSelectTargetMode = 
{
	Normal 				= "Normal", 	--ֻѡ�����
	CastleWar			= "CastleWar", 	--ɳ�Ϳ˹���ģʽ
	Collect				= "Collect", 	--
}

--����ѡ��Ŀ��Ĳ���
E_SelectTargetType = 
{
	Closest = "Closest",
	Random 	= "Random"
}

function G_getFightTargetMgr()
	return GameWorld.Instance:getFightTargetMgr()
end