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

--按钮点击回调
function AcitvityManageUIHandler:onActivityClick(refid)
	if refid=="activity_manage_1" then--签到
		self:clickSign()
	elseif refid=="activity_manage_2" then--七天登录
		self:clickSevenLogin()
		--self:clickOffLineBag()
	elseif refid=="activity_manage_3" then--在线时长
		self:clickBtnByOnlineTimer()
	elseif refid=="activity_manage_17" then--限时速冲
		self:clickLevelUpAward()
	elseif refid=="activity_manage_16" then--vip抽奖
		self:clickVipLuck()
	elseif refid=="activity_manage_4" then--进阶奖励
		self:clickUpGradeAward()
	elseif refid=="activity_manage_18" then--限时冲榜
		self:clickLimitTimeRank()
	elseif refid=="activity_manage_13" then--首充
		self:clickFirstPay()
	elseif refid=="activity_manage_15" then--挖宝
		self:clickDigTreasure()
	elseif refid == "activity_manage_14" then--充值礼包
		self:clickPayGiftBag()	
	elseif refid=="activity_manage_5" then--天梯
		self:clickArena()	
	elseif refid=="activity_manage_9" then--打折出售
		self:clickDiscountSell()
	elseif refid == "activity_manage_10" then --每日充值
		self:clickPayEveryDay()
	elseif refid == "activity_manage_11" then --每周消费奖励
		self:clickEveryWeekAward()
	elseif refid=="activity_manage_7" then--采矿
		self:clickMining()
	elseif refid == "activity_manage_6" then --怪物入侵
		self:clickMonsterInvasion()
	elseif refid == "activity_manage_12" then -- 遮天基金
		self:clickFund()
	elseif 	refid == "activity_manage_20" or 
			refid == "activity_manage_21" or 
			refid == "activity_manage_22" then  --组队BOSS
		self:clickTeamBoss()
	end	
end

--点击遮天基金
function AcitvityManageUIHandler:clickFund()
	GlobalEventSystem:Fire(GameEvent.EventOpenFundView)
end

--点击怪物入侵
function AcitvityManageUIHandler:clickMonsterInvasion()
	local monstroMgr = G_getHero():getMonstorInvasionMgr()
	monstroMgr:requestEnterMonstorInvasionActivity()		
end

--点击在线时长
function AcitvityManageUIHandler:clickBtnByOnlineTimer()
	local activityOnlineTimeMgr = GameWorld.Instance:getActivityOnlineTimeMgr()
	local getRewardState = activityOnlineTimeMgr:getOnlineTimeRewardState()
	local onlineTimeRefId = activityOnlineTimeMgr:getOnlineTimeRefId()
	if onlineTimeRefId and getRewardState==true then
		activityOnlineTimeMgr:requestGetReward(E_sendSeverRewardType.onlineTime,onlineTimeRefId)--发送消息
	else
		UIManager.Instance:showSystemTips(Config.Words[13201])
	end
end	

--点击7天登录
function AcitvityManageUIHandler:clickSevenLogin()
	local awardMgr = GameWorld.Instance:getAwardManager()
	awardMgr:requestReceiveState()
	GlobalEventSystem:Fire(GameEvent.EventOpenSevenLoginView)
end

--点击签到
function AcitvityManageUIHandler:clickSign()
	GlobalEventSystem:Fire(GameEvent.EventSignViewOpen)
end

--点击vip抽奖
function AcitvityManageUIHandler:clickVipLuck()
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()  
	vipLuckMgr:requestOpenLuckDraw()
	GlobalEventSystem:Fire(GameEvent.EventVipLuckDrawOpen)	
	local openFailedFunc = function()
		GlobalEventSystem:Fire(GameEvent.EventVipLuckDrawOpenFailed)	
	end
	UIManager.Instance:showLoadingHUD(5,nil,openFailedFunc)		
end

--点击升级奖励
function AcitvityManageUIHandler:clickLevelUpAward()
	GlobalEventSystem:Fire(GameEvent.EventOpenQuickUpLevelView)
end

--点击挖宝
function AcitvityManageUIHandler:clickDigTreasure()
	GlobalEventSystem:Fire(GameEvent.EventDigTreasureViewOpen)
end

--点击充值礼包
function AcitvityManageUIHandler:clickPayGiftBag()
	GlobalEventSystem:Fire(GameEvent.EventOpenPayGiftBag)
end
--点击首充礼包
function AcitvityManageUIHandler:clickFirstPay()
	GlobalEventSystem:Fire(GameEvent.EventOpenFirstPayGiftBag)
end
--点击每日充值
function AcitvityManageUIHandler:clickPayEveryDay()
	GlobalEventSystem:Fire(GameEvent.EventOpenEveryDayPayBag)
end
--点击每周消费奖励
function AcitvityManageUIHandler:clickEveryWeekAward()
	GlobalEventSystem:Fire(GameEvent.EventOpenEveryWeekPayGiftBag)
end

--点击限时冲榜
function AcitvityManageUIHandler:clickLimitTimeRank()
	GlobalEventSystem:Fire(GameEvent.EventOpenRankListView,2)	
end

--点击天梯排名
function AcitvityManageUIHandler:clickArena()
	if PropertyDictionary:get_level(G_getHero():getPT()) >= 35 then
		GlobalEventSystem:Fire(GameEvent.EventOpenArenaView)
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"ActivityManageView","Arena")--新手指引点击消息
	else
		local msg = {}
		table.insert(msg,{word = Config.Words[16044], color = Config.FontColor["ColorYellow1"]})	
		UIManager.Instance:showSystemTips(msg)
	end
end

function AcitvityManageUIHandler:clickUpGradeAward()
	GlobalEventSystem:Fire(GameEvent.EventOpenRTWLevelAwardView,1)
end
--点击采矿
function AcitvityManageUIHandler:clickMining()
	--未加等级限制
	local miningMgr = GameWorld.Instance:getMiningMgr()
	miningMgr:requestEnterMining()
end

--点击打折出售
function AcitvityManageUIHandler:clickDiscountSell()
	local discountSellMgr = GameWorld.Instance:getDiscountSellMgr()
	discountSellMgr:OpenDiscountSellView()
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()
	activityManageMgr:setActivityState("activity_manage_9", false)	
end
--组队BOSS
function AcitvityManageUIHandler:clickTeamBoss()
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local level = PropertyDictionary:get_level(hero:getPT())
	if level<40 then
		UIManager.Instance:showSystemTips(Config.Words[25530])
	else
		GlobalEventSystem:Fire(GameEvent.EventOpenWorldBossActivityView)
	end 		
end

--离线背包
function AcitvityManageUIHandler:clickOffLineBag()
	GlobalEventSystem:Fire(GameEvent.EventOpenOffLineBag)
end

function AcitvityManageUIHandler:__delete()
	
end	