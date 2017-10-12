--[[
游戏的逻辑载体
]]--
require("common.baseclass")

require("actionEvent.WorldActionHandler")
require("actionEvent.EntityActionHandler")
--require("actionEvent.HeroActionHandler")
require("actionEvent.BagActionHandler")
require("actionEvent.WarehouseActionHandler")
require("actionEvent.MountActionHandler")
require("actionEvent.SkillActionHandler")
require("actionEvent.WorldBossActionHandler")
require("actionEvent.QuestActionHandle")
require("actionEvent.EquipActionHandler")
require("actionEvent.MallActionHandler")
require("actionEvent.DebugActionHandler")
require("actionEvent.ChatActionHandler")
require("actionEvent.KnightActionHandler")
require("actionEvent.WingActionHandler")
require("actionEvent.MailActionHandler")
require("actionEvent.GameInstanceActionHandler")
require("actionEvent.ForgingActionHandler")
require("actionEvent.TalismanActionHandler")
require("actionEvent.AchieveActionHandler")
require("actionEvent.NpcActionHandler")
require("actionEvent.BuffActionHandler")
require("actionEvent.FactionActionHandler")
require("actionEvent.HeroStateActionHandler")
require("actionEvent.VipActionHandler")
require("actionEvent.SignActionHandler")
require("actionEvent.AwardActionHandler")
require("actionEvent.ActivityActionHandler")
require("actionEvent.LevelAwardActionHandler")
require("actionEvent.RankListActionHandler")
require("actionEvent.LimitTimeRankActionHandler")
require("actionEvent.CastleActionHandler")
require("actionEvent.ArenaActionHandler")
require("actionEvent.MiningActionHandler")
require("actionEvent.MonstorInvasionActionHandler")
require("actionEvent.ResDownloadActionHandler")
require("actionEvent.AuctionActionHandler")
require("gameevent.GameUIHandler")
require("gameevent.BagUIHandler")
require("gameevent.SkillUIHandler")
require("gameevent.WorldBossUIHandler")
require("gameevent.ResDownloadUIHandler")
require("gameevent.ChatUIHandler")
require("gameevent.MallUIHandler")
require("gameevent.FactionUIHandler")
require("gameevent.DebugUIHandler")
require("gameevent.ForgingUIHandler")
require("gameevent.MountUIHandler")
require("gameevent.HeroStateUIHandler")
require("gameevent.NpcUIHandler")
require("gameevent.SmallMapUIHandler")
require("gameevent.WingUIHandler")
require("gameevent.SettingUIHandler")
require("gameevent.AchieveUIHandler")
require("gameevent.WarehouseUIHandler")
require("gameevent.MailUIHandler")
require("gameevent.RoleUIHandler")
require("gameevent.TalismanUIHandler")
require("gameevent.InstanceUIHandler")
require("gameevent.QuestUIHandler")
require("gameevent.MainViewHandler")
require("gameevent.ShopUIHandler")
require("gameevent.BuffUIHandler")
require("gameevent.VipUIHandler")
require("gameevent.PlayerInteractionUIHandler")
require("gameevent.TeamInviteUIHandler")
require("actionEvent.TeamActionHandler")
require("gameevent.MainTeammateHeadUIHandler")
require("gameevent.FactionInviteUIHandler")
require("gameevent.SignUIHandler")
require("gameevent.RankingUIHandler")
require("gameevent.AwardUIHandler")
require("gameevent.LevelAwardUIHandler")
require("gameevent.VipLuckDrawUIHandler")
require("gameevent.FundUIHandler")
require("gameevent.AuctionUIHandler")
require("actionEvent.FundActionHandler")
require("gameevent.ActivityManageUIHandler")
require("gameevent.ArenaUIHandler")
require("gameevent.DiscountSellUIHandler")
require("object.actionPlayer.ActionPlayerMgr")
require("utils.DebugUtil")
require("gameevent.NewGuidelinesUIHandler")
require("gameevent.MonstorInvasionUIHandler")
require("gameevent.PayUIHandler")
require("gameevent.StrongerUIHandler")
require("gameevent.UnionInstanceUIHandler")
require("object.notify.GameNotifyManager")
require("object.notify.GameNotifyObj")
require("ui.notifyView.GameNotifyView")
require("gameevent.NearbyUIHandle")
require("gameevent.SubPackageLoadUIHandler")
require("gameevent.RechargeUIHandler")
require("object.activity.ActivityManageMgr")
require("object.activity.ActivityDelegate")
require("actionEvent.WorldBossActivityActionHandler")
require("gameevent.WorldBossActivityUIHandler")
require("object.setting.SettingMgr")
require ("config.GameColor")
require ("config.gameimage")
require("actionEvent.NewGuidelinesActionHandle")
require("actionEvent.RechargeActionHandler")
require("actionEvent.BossTempleActionHandler")
require("actionEvent.MultiTimesExpActionHandler")

GameWorld = GameWorld or BaseClass()

function GameWorld:__init()
	GameWorld.Instance = self	
	self.mapManager = nil
	self.entityManager = nil
	self.fightTargetMgr = nil
	self.timeManager = nil
	self.autoPathManager = nil
	--add by panzhibang  2013/11/25
	self.mountManager = nil		
	--add by panzhibang  2013/12/12
	self.TalismanManager = nil
	self.vipManager = nil
	self.signMgr = nil
	self.rtwLevelMgr = nil
	self.npcManager = nil
	self.joyRockerManager = nil
	self.smallMapManager = nil
	self.animatePlayManager = nil
	self.gameInstanceManager = nil	
	self.activityOnlineTimeMgr = nil	
	self.limitTimeRankMgr = nil
	self.actionPlayerMgr = ActionPlayerMgr.New()
	self.skillMgr = nil  --技能
	self.buffMgr = nil  --buff
	self.mallMgr = nil--商城
	self.rechargeMgr = nil 
	self.pickUpManager = nil
	self.uiHandler = {}
	self.actionHandler = {}	
	self.gameMgr = {}
	self.awardMgr = nil
	self.vipLuckMgr = nil
	self.serverMgr = nil
	self.SettingMgr = SettingMgr.New()
	table.insert(self.gameMgr,self.SettingMgr)
	self.rankListMgr = nil
	self.ArenaMgr = nil
	self.discountSellMgr = nil
	self.fundMgr = nil
	self.monstorInvasionMgr = nil
	self.miningMgr = nil
	self.nearbyMgr = nil	
	self.unionInstanceMgr = nil
	self.soundManager = nil
	self.arenaSkillManager = nil
	self.offLineBagMgr = nil
	self.worldBossActivityMgr = nil
	self.warehouseMgr = nil
	self.strongerMgr = nil
	self.exchangeCodeMgr = nil
	-- 初始化handler
	self:initUIHandler()
	self:initActionHandler()
	
	-- 注册tick函数
	local SYNCTIME = 10
	local m_duringSyncTime = 0
	
	self:startScheduler()	
end

function GameWorld:__delete()
	self:deleteScheduler()
end

function GameWorld:deleteScheduler()
	if self.schedulerId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)	
		self.schedulerId = nil
	end
end

function GameWorld:getSchedulerId()
	return self.schedulerId
end

function GameWorld:startScheduler()
	local function tick(time)
		if not self.schedulerId then
			return
		end
		if self.entityManager then
			self.entityManager:tick(time)
		end
		
		if self.animatePlayManager then
			self.animatePlayManager:update(time)
		end
		
		if self.actionPlayerMgr then
			self.actionPlayerMgr:update(time)
		end
	end
	
	self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0, false)
end	

function GameWorld:getTextManager()
	if self.textManager == nil then
		require("object.map.GlobleTextManager")
		self.textManager = GlobleTextManager.New()
		table.insert(self.gameMgr, self.textManager)	
	end
	return self.textManager
end

function GameWorld:getArenaSkillManager()
	if self.arenaSkillManager == nil then
		require("object.skillShow.ArenaSkillShowManager")
		self.arenaSkillManager = ArenaSkillShowManager.New()
	end
	return self.arenaSkillManager
end

--服务器
function GameWorld:getServerMgr()
	if self.serverMgr == nil then
		require("object.server.ServerMgr")
		self.serverMgr = nil
	end
	return self.serverMgr	
end

function GameWorld:getExchangeCodeMgr()
	if self.exchangeCodeMgr == nil then
		require("object.mall.ExchangeCodeMgr")
		self.exchangeCodeMgr = ExchangeCodeMgr.New()
		table.insert(self.gameMgr, self.exchangeCodeMgr)
	end
	return self.exchangeCodeMgr
end

function GameWorld:getWarehouseMgr()
	if self.warehouseMgr == nil then
		require("object.warehouse.warehouseMgr")
		self.warehouseMgr = WarehouseMgr.New()
		table.insert(self.gameMgr, self.warehouseMgr)
	end
	return self.warehouseMgr
end
	
function GameWorld:getSkillMgr()--陈宁已处理
	if self.skillMgr == nil then
		require ("object.skill.SkillMgr")
		self.skillMgr = SkillMgr.New()
		table.insert(self.gameMgr,self.skillMgr)
	end
	return self.skillMgr
end	

function GameWorld:getWorldBossMgr()
	if self.worldBossMgr == nil then
		require ("object.worldBoss.WorldBossMgr")
		self.worldBossMgr = WorldBossMgr.New()
		table.insert(self.gameMgr,self.worldBossMgr)
	end
	return self.worldBossMgr
end

function GameWorld:getResDownloadMgr()
	if self.resDownloadMgr == nil then
		require ("object.resourceDownload.ResDownloadMgr")
		self.resDownloadMgr = ResDownloadMgr.New()
		table.insert(self.gameMgr,self.resDownloadMgr)
	end
	return self.resDownloadMgr
end	

function GameWorld:getRechargeMgr()
	if self.rechargeMgr == nil then
		require ("object.Recharge.RechargeMgr")
		self.rechargeMgr = RechargeMgr.New()
		table.insert(self.gameMgr,self.rechargeMgr)
	end
	return self.rechargeMgr
end

function GameWorld:getBuffMgr()--陈宁已处理
	if self.buffMgr == nil then
		require ("object.buff.BuffMgr")
		self.buffMgr = BuffMgr.New()
		table.insert(self.gameMgr,self.buffMgr)
	end
	return self.buffMgr
end

function GameWorld:getUnionInstanceMgr()
	if self.unionInstanceMgr == nil then
		require ("object.activity.UnionInstanceMgr")
		self.unionInstanceMgr = UnionInstanceMgr.New()
		table.insert(self.gameMgr ,self.unionInstanceMgr)
	end
	return self.unionInstanceMgr
end

function GameWorld:getAutoPathManager()--文军已处理
	if self.autoPathManager == nil then
		require"object.auto.AutoPathManager"
		self.autoPathManager = AutoPathManager.New()
		table.insert(self.gameMgr,self.autoPathManager)
	end
	return self.autoPathManager
end

function GameWorld:getVipManager()--陈宁已处理
	if self.vipManager == nil then
		require("object.vip.VipManager")
		self.vipManager = VipManager.New()
		table.insert(self.gameMgr,self.vipManager)
	end
	return self.vipManager	
end

function GameWorld:getSignManager()--陈宁已处理
	if self.signMgr == nil then
		require("object.activity.SignMgr")
		self.signMgr = SignManager.New()
		table.insert(self.gameMgr,self.signMgr)
	end
	return self.signMgr	
end

function GameWorld:getPayActivityManager()--陈宁已处理
	if self.payActivityMgr == nil then
		require("object.activity.PayActivityMgr")
		self.payActivityMgr = PayActivityMgr.New()
		table.insert(self.gameMgr,self.payActivityMgr)
	end
	return self.payActivityMgr
end

function GameWorld:getEveryWeekConsumeManager()
	if self.everyWeekConsumeMgr == nil then	
		require("object.activity.EveryWeekConsumeMgr")
		self.everyWeekConsumeMgr = EveryWeekConsumeMgr.New()
		table.insert(self.gameMgr,self.everyWeekConsumeMgr)
	end
	return self.everyWeekConsumeMgr
end

function GameWorld:getLimitTimeRankManager()--陈宁已处理
	if self.limitTimeRankMgr == nil then
		require("object.activity.LimitTimeRankMgr")
		self.limitTimeRankMgr = LimitTimeRankMgr.New()
		table.insert(self.gameMgr,self.limitTimeRankMgr)
	end
	return self.limitTimeRankMgr
end

function GameWorld:getEntityManager()--陈宁已处理
	if self.entityManager == nil then
		require("object.entity.EntityManager")
		self.entityManager = EntityManager.New()
		table.insert(self.gameMgr,self.entityManager)
	end
	return self.entityManager
end

function GameWorld:getJoyRockerManager()
	if self.joyRockerManager == nil then
		require"object.joyRocker.JoyRockerManager"
		self.joyRockerManager = JoyRockerManager.New()
		table.insert(self.gameMgr, self.joyRockerManager)
	end
	return self.joyRockerManager
end

function GameWorld:getLoginManager()
	return self.loginManager
end

function GameWorld:getMapManager()
	if self.mapManager == nil then
		require("object.map.GameMapManager")
		self.mapManager = GameMapManager.New()
	end
	return self.mapManager
end

function GameWorld:getAnimatePlayManager()
	if self.animatePlayManager == nil then
		require "object.skillShow.AnimatePlayManager"
		self.animatePlayManager = AnimatePlayManager.New()
	end
	return self.animatePlayManager
end

function GameWorld:getTimeManager()--文军已处理
	if self.timeManager == nil then
		require("object.time.TimeManager")
		self.timeManager = TimeManager.New()
		table.insert(self.gameMgr,self.timeManager)
	end
	return self.timeManager
end

function GameWorld:getMountManager()--陈宁已处理
	if self.mountManager == nil then
		require"object.mount.MountManager"
		self.mountManager = MountManager.New()
		table.insert(self.gameMgr,self.mountManager)
	end
	return self.mountManager	
end

function GameWorld:getTalismanManager()--陈宁已处理
	if self.TalismanManager	== nil then
		require("object.Talisman.TalismanManager")
		self.TalismanManager = TalismanManager.New()
		table.insert(self.gameMgr,self.TalismanManager)
	end
	return self.TalismanManager	
end

function GameWorld:getFundManager()--陈宁已处理
	if self.fundMgr == nil then
		require("object.activity.FundMgr")
		self.fundMgr = FundMgr.New()
		table.insert(self.gameMgr,self.fundMgr)
	end
	return self.fundMgr
end

function GameWorld:getLevelAwardManager()--陈宁已处理
	if self.rtwLevelMgr	== nil then
		require("object.activity.LevelAwardMgr")
		self.rtwLevelMgr = LevelAwardMgr.New()
		table.insert(self.gameMgr,self.rtwLevelMgr)
	end
	return self.rtwLevelMgr	
end

function GameWorld:getActivityOnlineTimeMgr()--陈宁已处理
	if self.activityOnlineTimeMgr == nil then
		require("object.activity.ActivityOnlineTimeMgr")
		self.activityOnlineTimeMgr = ActivityOnlineTimeMgr
		table.insert(self.gameMgr,self.activityOnlineTimeMgr)
	end
	return self.activityOnlineTimeMgr
end	

function GameWorld:getMallManager()--陈宁已处理
	if self.mallMgr == nil then
		require("object.mall.MallMgr")
		self.mallMgr = MallMgr.New()
		table.insert(self.gameMgr,self.mallMgr)
	end
	return self.mallMgr
end

function GameWorld:getNpcManager()--陈宁已处理
	if self.npcManager == nil then
		require("object.npc.NpcManager")
		self.npcManager = NpcManager.New()
		table.insert(self.gameMgr,self.npcManager)
	end
	return self.npcManager
end

function GameWorld:getSmallMapManager()--陈宁已处理
	if self.smallMapManager == nil then
		require"object.smallMap.SmallMapManager"
		self.smallMapManager = SmallMapManager.New()
		table.insert(self.gameMgr,self.smallMapManager)
	end
	return self.smallMapManager
end

function GameWorld:getGameInstanceManager()--陈宁已处理
	if self.gameInstanceManager == nil then	
		require("object.gameInstance.GameInstanceManager")
		self.gameInstanceManager = GameInstanceManager.New()
		table.insert(self.gameMgr,self.gameInstanceManager)
	end
	return self.gameInstanceManager
end

function GameWorld:getPickUpMnanager()
	if self.pickUpManager == nil then
		require("object.pickUp.PickUpManager")
		self.pickUpManager = PickUpManager.New()
	end
	return self.pickUpManager
end

function GameWorld:getAwardManager()--陈宁已处理
	if self.awardMgr == nil then
		require("object.activity.AwardMgr")
		self.awardMgr = AwardMgr.New()
		table.insert(self.gameMgr,self.awardMgr)
	end
	return self.awardMgr
end
function GameWorld:getVipLuckManager()--陈宁已处理
	if self.vipLuckMgr == nil then
		require("object.activity.VipLuckDrawMgr")
		self.vipLuckMgr = VipLuckDrawMgr.New()
		table.insert(self.gameMgr,self.vipLuckMgr)
	end
	return self.vipLuckMgr
end

function GameWorld:getActivityManageMgr()--陈宁已处理
	if self.activityManageMgr == nil then
		self.activityManageMgr = ActivityManageMgr.New()
		self.activityManageMgr:start()
		
		ActivityDelegate.New()	
		table.insert(self.gameMgr,self.activityManageMgr)
	end
	return self.activityManageMgr
end	

function GameWorld:getDiscountSellMgr()--文军已处理
	if self.discountSellMgr == nil then
		require("object.activity.DiscountSellMgr")
		self.discountSellMgr = DiscountSellMgr.New()
		table.insert(self.gameMgr,self.discountSellMgr)
	end
	return self.discountSellMgr
end	


function GameWorld:getFightTargetMgr()
	if self.fightTargetMgr == nil then
		require("object.target.FightTargetMgr")
		self.fightTargetMgr = FightTargetMgr.New()
		table.insert(self.gameMgr,self.fightTargetMgr)	
	end
	return self.fightTargetMgr
end

--[[function GameWorld:getHandupConfigMgr()--陈宁已处理
	if self.handupConfigMgr == nil then
		require("object.handup.API.HandupConfigMgr")
		self.handupConfigMgr = HandupConfigMgr.New()
		table.insert(self.gameMgr,self.handupConfigMgr)	
	end
	return self.handupConfigMgr
end]]

function GameWorld:getRankListManager()--陈宁已处理
	if self.rankListMgr == nil then
		require("object.rankList.RankListMgr")
		self.rankListMgr = RankListMgr.New()
		table.insert(self.gameMgr,self.rankListMgr)
	end
	return self.rankListMgr
end

function GameWorld:getSettingMgr()--陈宁已处理
	--[[if self.SettingMgr == nil then
		table.insert(self.gameMgr,self.SettingMgr)
	end--]]
	return self.SettingMgr
end

function GameWorld:getArenaMgr()--陈宁已处理
	if self.ArenaMgr == nil then
		require("object.activity.ArenaMgr")
		self.ArenaMgr = ArenaMgr.New()
		table.insert(self.gameMgr,self.ArenaMgr)
	end
	return self.ArenaMgr
end

function GameWorld:getOffLineBagMgr()
	if self.offLineBagMgr == nil then
		require("object.bag.OffLineBagMgr")
		self.offLineBagMgr = OffLineBagMgr.New()
		table.insert(self.gameMgr,self.offLineBagMgr)
	end
	return self.offLineBagMgr
end

function GameWorld:getMiningMgr()
	if self.miningMgr == nil then
		require("object.activity.MiningMgr")
		self.miningMgr = MiningMgr.New()
		table.insert(self.gameMgr, self.miningMgr)
	end		
	return self.miningMgr
end	

function GameWorld:getActivityDataMgr()
	if self.activityDataMgr == nil then
		require("object.activity.ActivityDataManager")
		self.activityDataMgr = ActivityDataManager.New()
		table.insert(self.gameMgr,self.activityDataMgr)
	end		
	return self.activityDataMgr
end	

function GameWorld:getMonstorInvasionMgr()
	if self.monstorInvasionMgr == nil then 
		require("object.activity.MonstorInvasionMgr")
		self.monstorInvasionMgr = MonstorInvasionMgr.New()
		table.insert(self.gameMgr,self.monstorInvasionMgr)
	end
	return self.monstorInvasionMgr
end

function GameWorld:getNewGuidelinesMgr()
	if self.newGuidelinesMgr == nil then
		require("object.newGuidelines.NewGuidelinesMgr")
		self.newGuidelinesMgr = NewGuidelinesMgr.New()
		table.insert(self.gameMgr,self.newGuidelinesMgr)
	end
	return self.newGuidelinesMgr
end	

function GameWorld:getNearbyMgr()
	if self.nearbyMgr == nil then
		require("object.nearby.NearbyManager")
		self.nearbyMgr = NearbyManager.New()
		table.insert(self.gameMgr, self.nearbyMgr)
	end
	return self.nearbyMgr
end

function GameWorld:getSoundMgr()
	if self.soundManager == nil then
		require("object.sound.SoundManager")
		self.soundManager = SoundManager.New()
		table.insert(self.gameMgr, self.soundManager)
	end
	return self.soundManager
end

function GameWorld:getWorldBossActivityMgr()
	if self.worldBossActivityMgr == nil then 
		require("object.activity.WorldBossActivityMgr")
		self.worldBossActivityMgr = WorldBossActivityManager.New()
		table.insert(self.gameMgr,self.worldBossActivityMgr)
	end
	return self.worldBossActivityMgr
end

function GameWorld:getBossTempleMgr()
	if self.bossTempleMgr == nil then 
		require("object.activity.BossTempleMgr")
		self.bossTempleMgr = BossTempleMgr.New()
		table.insert(self.gameMgr,self.bossTempleMgr)
	end
	return self.bossTempleMgr
end

function GameWorld:getMultiTimesExpMgr()
	if self.multiTimesExpMgr == nil then 
		require("object.activity.MultiTimesExpMgr")
		self.multiTimesExpMgr = MultiTimesExpMgr.New()
		table.insert(self.gameMgr,self.multiTimesExpMgr)
	end
	return self.multiTimesExpMgr
end

function GameWorld:getStrongerMgr()
	if self.strongerMgr == nil then 
		require("object.stronger.StrongerMgr")
		self.strongerMgr = StrongerMgr.New()
		table.insert(self.gameMgr,self.strongerMgr)
	end
	return self.strongerMgr
end


function GameWorld:addUIHandler(nHandler)
	table.insert(self.uiHandler,nHandler)
end

function GameWorld:initUIHandler()
	self:addUIHandler(GameUIHandler.New())
	self:addUIHandler(BagUIHandler.New())
	self:addUIHandler(SkillUIHandler.New())
	self:addUIHandler(ChatUIHandler.New())
	self:addUIHandler(MallUIHandler.New())
	self:addUIHandler(FactionUIHandler.New())
	self:addUIHandler(DebugUIHandler.New())
	self:addUIHandler(ForgingUIHandler.New())
	self:addUIHandler(NpcUIHandler.New())
	self:addUIHandler(SmallMapUIHandler.New())
	self:addUIHandler(AchieveUIHandler.New())
	self:addUIHandler(WingUIHandler.New())
	self:addUIHandler(MountUIHandler.New())	
	self:addUIHandler(RoleUIHandler.New())	
	self:addUIHandler(MailUIHandler.New())	
	self:addUIHandler(TalismanUIHandler.New())
	self:addUIHandler(InstanceUIHandler.New())
	self:addUIHandler(QuestUIHandler.New())
	self:addUIHandler(MainViewHandler.New())	
	self:addUIHandler(BuffUIHandler.New())
	self:addUIHandler(SettingUIHandler.New())
	self:addUIHandler(ShopUIHandler.New())
	self:addUIHandler(VipUIHandler.New())
	self:addUIHandler(SignUIHandler.New())
	self:addUIHandler(PlayerInteractionUIHandler.New())
	self:addUIHandler(TeamInviteUIHandler.New())
	self:addUIHandler(MainTeammateHeadUIHandler.New())
	self:addUIHandler(FactionInviteUIHandler.New())
	self:addUIHandler(AwardUIHandler.New())
	self:addUIHandler(RankingUIHandler.New())
	self:addUIHandler(LevelAwardUIHandler.New())
	self:addUIHandler(VipLuckDrawUIHandler.New())
	self:addUIHandler(AcitvityManageUIHandler.New())
	self:addUIHandler(ArenaUIHandler.New())
	self:addUIHandler(CastleActionHandler.New())
	self:addUIHandler(DiscountSellUIHandler.New())
	self:addUIHandler(FundUIHandler.New())
	self:addUIHandler(NewGuidelinesUIHandler.New())
	self:addUIHandler(MonstorInvasionUIHandler.New())
	self:addUIHandler(UnionInstanceUIHandler.New())
	self:addUIHandler(PayUIHandler.New())
	self:addUIHandler(ResDownloadUIHandler.New())
	self:addUIHandler(WorldBossUIHandler.New())
	self:addUIHandler(NearbyUIHandle.New())
	self:addUIHandler(SubPackageLoadUIHandler.New())
	self:addUIHandler(AuctionUIHandler.New())
	self:addUIHandler(WorldBossActivityUIHandler.New())	
	self:addUIHandler(RechargeUIHandler.New())	
	self:addUIHandler(WarehouseUIHandler.New())	
	self:addUIHandler(StrongerUIHandler.New())	
end

function GameWorld:addActionHandler(nHandler)
	table.insert(self.actionHandler,nHandler)
end

function GameWorld:initActionHandler()
	self:addActionHandler(WorldActionHandler.New())
	self:addActionHandler(EntityActionHandler.New())
	
	--self:addActionHandler(HeroActionHandler.New())
	self:addActionHandler(BagActionHandler.New())
	self:addActionHandler(SkillActionHandler.New())
	self:addActionHandler(QuestActionHandle.New())
	self:addActionHandler(EquipActionHandler.New())
	self:addActionHandler(MallActionHandler.New())
	self:addActionHandler(DebugActionHandler.New())
	self:addActionHandler(ChatActionHandler.New())
	self:addActionHandler(KnightActionHandler.New())
	self:addActionHandler(MountActionHandler.New())
	self:addActionHandler(WingActionHandler.New())	
	self:addActionHandler(ForgingActionHandler.New())
	self:addActionHandler(GameInstanceActionHandler.New())	
	self:addActionHandler(TalismanActionHandler.New())
	self:addActionHandler(AchieveActionHandler.New())
	self:addActionHandler(MailActionHandler.New())
	self:addActionHandler(NpcActionHandle.New())
	self:addActionHandler(BuffActionHandler.New())
	self:addActionHandler(FactionActionHandler.New())
	self:addActionHandler(TeamActionHandler.New())
	self:addActionHandler(HeroStateActionHandler.New())
	self:addActionHandler(VipActionHandler.New())
	self:addActionHandler(SignActionHandler.New())
	self:addActionHandler(ActivityActionHandler.New())
	self:addActionHandler(AwardActionHandler.New())
	self:addActionHandler(HeroStateUIHandler.New())
	self:addActionHandler(LevelAwardActionHandler.New())
	self:addActionHandler(RankListActionHandler.New())
	self:addActionHandler(LimitTimeRankActionHandler.New())
	self:addActionHandler(ArenaActionHandler.New())
	self:addActionHandler(MiningActionHandler.New())
	self:addActionHandler(FundActionHandler.New())
	self:addActionHandler(MonstorInvasionActionHandler.New())
	self:addActionHandler(WorldBossActionHandler.New())
	self:addActionHandler(ResDownloadActionHandler.New())
	self:addActionHandler(AuctionActionHandler.New())
	self:addActionHandler(WorldBossActivityActionHandler.New())	
	self:addActionHandler(NewGuidelinesActionHandle.New())
	self:addActionHandler(RechargeActionHandler.New())
	self:addActionHandler(BossTempleActionHandler.New())
	self:addActionHandler(MultiTimesExpActionHandler.New())
	self:addActionHandler(WarehouseActionHandler.New())
end

function GameWorld:getUIHandlerByName(name)
	for k,v in pairs(self.uiHandler) do
		if v.handleName == name then
			return v
		end
	end
end

function GameWorld:clearMgr()
	for _,v in pairs(self.gameMgr) do
		if v.clear then
			v:clear()
		end
	end
	self.actionPlayerMgr:clear()
	UIManager.Instance:clear()	
	UIManager.Instance:releaseAllUI()	--Juchao@20140623: 在断线重连时，销毁所有UI
end