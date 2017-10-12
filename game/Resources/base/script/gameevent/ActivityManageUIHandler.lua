require ("ui.UIManager")
require ("ui.activity.ActivityManageView")
require ("ui.utils.ActivityTips")	

AcitvityManageUIHandler = AcitvityManageUIHandler or BaseClass(GameEventHandler)

function AcitvityManageUIHandler:__init()
	local manager = UIManager.Instance
	manager:registerUI("ActivityManageView", ActivityManageView.New)
	manager:registerUI("ActivityTips", ActivityTips.create)
		
	local function openActivityManageView()				
		manager:showUI("ActivityManageView")	
		local vipMgr = GameWorld.Instance:getVipManager()
		vipMgr:requestVipAwardList()	
	end	
	self:Bind(GameEvent.EventOpenActivityManageView,openActivityManageView)	

	local function onEventActivityClick(refId)	
		require ("ui.utils.ActivityTips")				
		local obj = GameWorld.Instance:getActivityManageMgr():getActivityByRefId(refId)
		if obj and obj:needTips() then
			manager:showUI("ActivityTips", E_ShowOption.eMiddle, refId)
		else
			self:onActivityClick(refId)					
		end
	end	
	self:Bind(GameEvent.EventActivityClick, onEventActivityClick)	
end

--��ť����ص�
function AcitvityManageUIHandler:onActivityClick(refid)
	if refid=="activity_manage_1" then--ǩ��
		self:clickSign()
	elseif refid=="activity_manage_2" then--�����¼
		self:clickSevenLogin()
		--self:clickOffLineBag()
	elseif refid=="activity_manage_3" then--����ʱ��
		self:clickBtnByOnlineTimer()
	elseif refid=="activity_manage_17" then--��ʱ�ٳ�
		self:clickLevelUpAward()
	elseif refid=="activity_manage_16" then--vip�齱
		self:clickVipLuck()
	elseif refid=="activity_manage_4" then--���׽���
		self:clickUpGradeAward()
	elseif refid=="activity_manage_18" then--��ʱ���
		self:clickLimitTimeRank()
	elseif refid=="activity_manage_13" then--�׳�
		self:clickFirstPay()
	elseif refid=="activity_manage_15" then--�ڱ�
		self:clickDigTreasure()
	elseif refid == "activity_manage_14" then--��ֵ���
		self:clickPayGiftBag()	
	elseif refid=="activity_manage_5" then--����
		self:clickArena()	
	elseif refid=="activity_manage_9" then--���۳���
		self:clickDiscountSell()
	elseif refid == "activity_manage_10" then --ÿ�ճ�ֵ
		self:clickPayEveryDay()
	elseif refid == "activity_manage_11" then --ÿ�����ѽ���
		self:clickEveryWeekAward()
	elseif refid=="activity_manage_7" then--�ɿ�
		self:clickMining()
	elseif refid == "activity_manage_6" then --��������
		self:clickMonsterInvasion()
	elseif refid == "activity_manage_12" then -- �������
		self:clickFund()
	elseif 	refid == "activity_manage_20" or 
			refid == "activity_manage_21" or 
			refid == "activity_manage_22" then  --���BOSS
		self:clickTeamBoss()
	end	
end

--����������
function AcitvityManageUIHandler:clickFund()
	GlobalEventSystem:Fire(GameEvent.EventOpenFundView)
end

--�����������
function AcitvityManageUIHandler:clickMonsterInvasion()
	local monstroMgr = G_getHero():getMonstorInvasionMgr()
	monstroMgr:requestEnterMonstorInvasionActivity()		
end

--�������ʱ��
function AcitvityManageUIHandler:clickBtnByOnlineTimer()
	local activityOnlineTimeMgr = GameWorld.Instance:getActivityOnlineTimeMgr()
	local getRewardState = activityOnlineTimeMgr:getOnlineTimeRewardState()
	local onlineTimeRefId = activityOnlineTimeMgr:getOnlineTimeRefId()
	if onlineTimeRefId and getRewardState==true then
		activityOnlineTimeMgr:requestGetReward(E_sendSeverRewardType.onlineTime,onlineTimeRefId)--������Ϣ
	else
		UIManager.Instance:showSystemTips(Config.Words[13201])
	end
end	

--���7���¼
function AcitvityManageUIHandler:clickSevenLogin()
	local awardMgr = GameWorld.Instance:getAwardManager()
	awardMgr:requestReceiveState()
	GlobalEventSystem:Fire(GameEvent.EventOpenSevenLoginView)
end

--���ǩ��
function AcitvityManageUIHandler:clickSign()
	GlobalEventSystem:Fire(GameEvent.EventSignViewOpen)
end

--���vip�齱
function AcitvityManageUIHandler:clickVipLuck()
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()  
	vipLuckMgr:requestOpenLuckDraw()
	GlobalEventSystem:Fire(GameEvent.EventVipLuckDrawOpen)	
	local openFailedFunc = function()
		GlobalEventSystem:Fire(GameEvent.EventVipLuckDrawOpenFailed)	
	end
	UIManager.Instance:showLoadingHUD(5,nil,openFailedFunc)		
end

--�����������
function AcitvityManageUIHandler:clickLevelUpAward()
	GlobalEventSystem:Fire(GameEvent.EventOpenQuickUpLevelView)
end

--����ڱ�
function AcitvityManageUIHandler:clickDigTreasure()
	GlobalEventSystem:Fire(GameEvent.EventDigTreasureViewOpen)
end

--�����ֵ���
function AcitvityManageUIHandler:clickPayGiftBag()
	GlobalEventSystem:Fire(GameEvent.EventOpenPayGiftBag)
end
--����׳����
function AcitvityManageUIHandler:clickFirstPay()
	GlobalEventSystem:Fire(GameEvent.EventOpenFirstPayGiftBag)
end
--���ÿ�ճ�ֵ
function AcitvityManageUIHandler:clickPayEveryDay()
	GlobalEventSystem:Fire(GameEvent.EventOpenEveryDayPayBag)
end
--���ÿ�����ѽ���
function AcitvityManageUIHandler:clickEveryWeekAward()
	GlobalEventSystem:Fire(GameEvent.EventOpenEveryWeekPayGiftBag)
end

--�����ʱ���
function AcitvityManageUIHandler:clickLimitTimeRank()
	GlobalEventSystem:Fire(GameEvent.EventOpenRankListView,2)	
end

--�����������
function AcitvityManageUIHandler:clickArena()
	if PropertyDictionary:get_level(G_getHero():getPT()) >= 35 then
		GlobalEventSystem:Fire(GameEvent.EventOpenArenaView)
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"ActivityManageView","Arena")--����ָ�������Ϣ
	else
		local msg = {}
		table.insert(msg,{word = Config.Words[16044], color = Config.FontColor["ColorYellow1"]})	
		UIManager.Instance:showSystemTips(msg)
	end
end

function AcitvityManageUIHandler:clickUpGradeAward()
	GlobalEventSystem:Fire(GameEvent.EventOpenRTWLevelAwardView,1)
end
--����ɿ�
function AcitvityManageUIHandler:clickMining()
	--δ�ӵȼ�����
	local miningMgr = GameWorld.Instance:getMiningMgr()
	miningMgr:requestEnterMining()
end

--������۳���
function AcitvityManageUIHandler:clickDiscountSell()
	local discountSellMgr = GameWorld.Instance:getDiscountSellMgr()
	discountSellMgr:OpenDiscountSellView()
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()
	activityManageMgr:setActivityState("activity_manage_9", false)	
end
--���BOSS
function AcitvityManageUIHandler:clickTeamBoss()
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local level = PropertyDictionary:get_level(hero:getPT())
	if level<40 then
		UIManager.Instance:showSystemTips(Config.Words[25530])
	else
		GlobalEventSystem:Fire(GameEvent.EventOpenWorldBossActivityView)
	end 		
end

--���߱���
function AcitvityManageUIHandler:clickOffLineBag()
	GlobalEventSystem:Fire(GameEvent.EventOpenOffLineBag)
end

function AcitvityManageUIHandler:__delete()
	
end	