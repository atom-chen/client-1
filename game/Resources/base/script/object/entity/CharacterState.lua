-- ��ɫ��״̬����

-- ��ɫ����Ϊ״̬
CharacterState={
	CharacterStateNone = 100,
	CharacterStateIdle = 101,
	CharacterStateMove = 102,			-- �ƶ�
	CharacterStateHit = 103,			-- �ܻ�
	CharacterStateUseSkill = 104,		-- ʹ�ü���
	CharacterStateDead = 105,			-- ����
	CharacterStateWillDead = 106,		-- ������Ԥ��״̬, ������һЩ������Ч������
	CharacterStateHitFly = 107,			-- ����
	CharacterStateHitBack = 108,		-- ����
	CharacterStateRideIdle = 109,		-- �������
	CharacterStateRideMove = 110,		-- �����ƶ�	
	CharacterStateCollect = 306,		-- �ɼ�	
}

CharacterFightState={
	Bleed = 501,			-- ��Ѫ
	Burn = 502,				-- ����
	Dizzy = 503,			-- ѣ��
	Slient = 504,			-- ��Ĭ
	Invincible = 505,		-- �޵�
	MagicImmune = 506,		-- ħ������
	Paresis = 507,			-- ���
	PhysicalImmune = 508,	-- ��������
	Poison = 509,			-- �ж�
	Slow = 510,				-- ����
	Invisible = 511,		-- ����
	Mofadun =   512,		-- ħ����
}

-- ��ɫ��action�л�������
CharacterMovement={
	Start = 0,
	Finish = 1,
	LoopFinish = 2,
	Cancel = 3
}