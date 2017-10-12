require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require("object.wing.WingObject")
require("object.quest.QuestObj")
require("object.quest.QuestDef")
WingActionHandler = WingActionHandler or BaseClass(ActionEventHandler)
local simulator = SFGameSimulator:sharedGameSimulator()
local wingMgr = nil

function WingActionHandler:__init()
	local handleNet_G2C_GetNowWingEvent  = function(reader)
		self:handleNet_G2C_GetNowWingEvent(reader)
	end				
	
	local handleNet_G2C_UpGradeWingEvent   = function(reader)
		self:handleNet_G2C_UpGradeWingEvent(reader)
	end			
	
	local handleNet_G2C_GetWingQuestReward   = function(reader)
		self:handleNet_G2C_GetWingQuestReward(reader)
	end	
	 
	local handleNet_G2C_Vip_SendWing = function (reader)
		self:handleNet_G2C_Vip_SendWing(reader)
	end
	
	self:Bind(ActionEvents.G2C_Wing_RequestNowWing,handleNet_G2C_GetNowWingEvent)
	self:Bind(ActionEvents.G2C_Wing_WingLevelUp,handleNet_G2C_UpGradeWingEvent)	
	self:Bind(ActionEvents.G2C_Wing_GetWingQuestReward,handleNet_G2C_GetWingQuestReward)
	self:Bind(ActionEvents.G2C_Vip_SendWing, handleNet_G2C_Vip_SendWing)
end

function WingActionHandler:__delete()
	
end

function WingActionHandler:handleNet_G2C_GetNowWingEvent(reader)	
	local WingMgr = GameWorld.Instance:getEntityManager():getHero():getWingMgr()	
	reader = tolua.cast(reader,"iBinaryReader")
	local refId = StreamDataAdapter:ReadStr(reader)
	local exp = StreamDataAdapter:ReadULLong(reader)
	local WingObj = WingObject.New()
	WingMgr:setWingObject(WingObj)
	WingMgr:setWingExp(exp)
	if(refId ~= nil) then
		WingObj:setRefId(refId)
		GlobalEventSystem:Fire(GameEvent.EventGetNowWing,refId)	
		GlobalEventSystem:Fire(GameEvent.EventSetSystemOpenStatus,MainMenu_Btn.Btn_wing,true) --开启翅膀系统
				
		local bShowBtn = WingMgr:checkShowWingBtn(refId)
		GlobalEventSystem:Fire(GameEvent.EventUpdateGetWingBtn, bShowBtn)				
	end
end

function WingActionHandler:handleNet_G2C_UpGradeWingEvent(reader)
	local WingMgr = GameWorld.Instance:getEntityManager():getHero():getWingMgr()	
	reader = tolua.cast(reader,"iBinaryReader")
	local isUpgrade = false
	local upgradedWingId = StreamDataAdapter:ReadStr(reader)
	local baojiType = StreamDataAdapter:ReadChar(reader)
	local exp = StreamDataAdapter:ReadULLong(reader)
	WingMgr:setWingExp(exp)
	local foreignRefId = string.match(WingMgr:getWingRefId(),"%a+_%d+")
	if foreignRefId ~= string.match(upgradedWingId,"%a+_%d+") then
		isUpgrade = true
	end
	if baojiType > 1  then
		GlobalEventSystem:Fire(GameEvent.EventWingBaoJi,baojiType)
	end	

	if(upgradedWingId ~= nil) then
		local WingObj = WingMgr:getWingObject()
		WingObj:setRefId(upgradedWingId)
		GlobalEventSystem:Fire(GameEvent.EventWingUpGrade,isUpgrade,upgradedWingId,exp)		
		local bShowBtn = WingMgr:checkShowWingBtn(upgradedWingId)
		GlobalEventSystem:Fire(GameEvent.EventUpdateGetWingBtn, bShowBtn)
	end
end	

function WingActionHandler:handleNet_G2C_GetWingQuestReward(reader)
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	reader = tolua.cast(reader,"iBinaryReader")	
	local isSuccess = StreamDataAdapter:ReadInt(reader)	
	if isSuccess == 1 then
		local WingMgr = GameWorld.Instance:getEntityManager():getHero():getWingMgr()
		WingMgr:requestNowWing()
		local onMsgBoxCallBack = function(unused, text, id)
			if id==E_MSG_BT_ID.ID_OK then
				GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesOpenWing()--打开新手指引
			end			
		end		
		local msg = showMsgBox(Config.Words[720])		
		msg:setNotify(onMsgBoxCallBack)	
		msg:showArrow()
	end
end

function WingActionHandler:handleNet_G2C_Vip_SendWing(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local wingLevel = StreamDataAdapter:ReadChar(reader)
		
	local refId = "wing_"..wingLevel

	self.WingObj = WingObject.New()
	WingMgr:setWingObject(self.WingObj)
	if(refId ~= nil) then	
		local newRefId = string.match(refId,"%a+_%d+") .. "_0" 
		self.WingObj:setRefId(newRefId)
		--GlobalEventSystem:Fire(GameEvent.EventGetNowWing,refId)	
		--GlobalEventSystem:Fire(GameEvent.EventSetSystemOpenStatus,MainMenu_Btn.Btn_wing,true) --开启翅膀系统
				
		local bShowBtn = WingMgr:checkShowWingBtn(newRefId)
		GlobalEventSystem:Fire(GameEvent.EventUpdateGetWingBtn, bShowBtn)
		local hero = GameWorld.Instance:getEntityManager():getHero()
		local currentWingRefId = PropertyDictionary:get_wingModleId(hero:getPT())
		if currentWingRefId < 6001 then
			WingMgr:showGetWingRewardBox(newRefId, wingLevel)
		end
				
		local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
		local questId = "wing_quest_1"
		local questObj = questMgr:getQuestObj(questId)
		if questObj then
			--questMgr:removeQuest(questId)--删除任务
			GlobalEventSystem:Fire(GameEvent.EVENT_Main_Quest_UI)
		end					
	end
end