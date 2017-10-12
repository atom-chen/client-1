require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require "data.achievement.achievement"
require"data.code"	
AchieveActionHandler = AchieveActionHandler or BaseClass(ActionEventHandler)
local simulator = SFGameSimulator:sharedGameSimulator()

function AchieveActionHandler:__init()
	local handleNet_G2C_AchievementID_List  = function(reader)
		self:handleNet_G2C_AchievementID_List(reader)
	end
	self:Bind(ActionEvents.G2C_AchievementID_List ,handleNet_G2C_AchievementID_List)
	
	local handleNet_G2C_Achievement_Get  = function(reader)
		self:handleNet_G2C_Achievement_Get(reader)
	end
	self:Bind(ActionEvents.G2C_Achievement_Get,handleNet_G2C_Achievement_Get)
	
	local handleNet_G2C_Achievement_GetReward  = function(reader)
		self:handleNet_G2C_Achievement_GetReward(reader)
	end
	self:Bind(ActionEvents.G2C_Achievement_GetReward,handleNet_G2C_Achievement_GetReward)
	
	local handleNet_G2C_Achievement_ExchangeMedal  = function(reader)
		self:handleNet_G2C_Achievement_ExchangeMedal(reader)
	end
	self:Bind(ActionEvents.G2C_Achievement_ExchangeMedal,handleNet_G2C_Achievement_ExchangeMedal)
	
	local handleNet_G2C_Achievement_LevlUpMedal  = function(reader)
		self:handleNet_G2C_Achievement_LevlUpMedal(reader)
	end
	self:Bind(ActionEvents.G2C_Achievement_LevlUpMedal,handleNet_G2C_Achievement_LevlUpMedal)
	
end

function AchieveActionHandler:__delete()
	
end	

function AchieveActionHandler:handleNet_G2C_AchievementID_List(reader)
	local achieveMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	local count = StreamDataAdapter:ReadShort(reader)
	if(count ~= 0) then
		for i=1,count do
			local refId = StreamDataAdapter:ReadStr(reader)
					
			local data = GameData.Achievement[refId]
			if(data) then
				if(data.property) then
					self.achieveType = data.property.achieveType
					local nextRefId = data.property.nextAchieve
					if(nextRefId ~= "") then
						self.nextAchiType = GameData.Achievement[nextRefId].property.achieveType			
					else 
						self.nextAchiType = nil
					end
					local isGetReward = StreamDataAdapter:ReadChar(reader)
					if(isGetReward == 0) then --未领取
						self.getFlag = false
					elseif(isGetReward == 1) then --已经领取过了
						self.getFlag = true
					end
					achieveMgr:setCompletedListByTypeAndIdAndFlag(self.achieveType,refId,self.getFlag,nextRefId,self.nextAchiType)
				end
			end
		end
		achieveMgr:fireCompleteList(self.achieveType)	
	end
	
end

function AchieveActionHandler:handleNet_G2C_Achievement_Get(reader)
	local achieveMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	
	local refId = StreamDataAdapter:ReadStr(reader)
	local data = GameData.Achievement[refId]
	if(data)then
		if(data.property) then
			local achieveName = data.property.name
			--local tipsWord = string.format("%s%s",Config.Words[15003],achieveName)
			local msg = {}
			table.insert(msg,{word = Config.Words[15003], color = Config.FontColor["ColorBlue2"]})
			table.insert(msg,{word = achieveName, color = Config.FontColor["ColorRed3"]})
			UIManager.Instance:showSystemTips(msg)
			local achieveType = data.property.achieveType
			local nextRefId = data.property.nextAchieve
			if(nextRefId ~= "") then
				self.nextAchiType = GameData.Achievement[nextRefId].property.achieveType	
			else 		
				self.nextAchiType = nil
			end	
			achieveMgr:setCompletedListByTypeAndIdAndFlag(achieveType,refId,false,nextRefId,self.nextAchiType)
			achieveMgr:fireCheckNewImage(achieveType)
			achieveMgr:fireCheckNewReward()		
			achieveMgr:fireCompleteList(achieveType)
		end
	end
end	

function AchieveActionHandler:handleNet_G2C_Achievement_GetReward(reader)
	local achieveMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	local refId = StreamDataAdapter:ReadStr(reader)
	local manager =UIManager.Instance
	manager:hideLoadingHUD()
	
	local data = GameData.Achievement[refId]
	if(data)then
		if(data.property) then
			local achieveType = data.property.achieveType
			local nextRefId = data.property.nextAchieve
			if(nextRefId ~= "") then
				self.nextAchiType = GameData.Achievement[nextRefId].property.achieveType	
			else 		
				self.nextAchiType = nil
			end	
			local isSuccess = StreamDataAdapter:ReadChar(reader)
			if(isSuccess == 1) then
				achieveMgr:setCompletedListByTypeAndIdAndFlag(achieveType,refId,true,nextRefId,self.nextAchiType)
				achieveMgr:setRequestFlag(true)
				achieveMgr:fireCheckNewImage(achieveType)
				achieveMgr:fireCheckNewReward()	
				GlobalEventSystem:Fire(GameEvent.EventSetButtonVisible)
			elseif(isSuccess == 0) then
				achieveMgr:setCompletedListByTypeAndIdAndFlag(achieveType,refId,false,nextRefId,self.nextAchiType)
			end
			achieveMgr:fireCompleteList(achieveType)
		end
	end
end	


function AchieveActionHandler:handleNet_G2C_Achievement_ExchangeMedal(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local manager =UIManager.Instance
	manager:hideLoadingHUD()
	local refId = "equip_10_9000"
	GlobalEventSystem:Fire(GameEvent.EventRefreshBtn,refId)	
end

function AchieveActionHandler:handleNet_G2C_Achievement_LevlUpMedal(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local manager =UIManager.Instance
	manager:hideLoadingHUD()
	local refId = StreamDataAdapter:ReadStr(reader)
	GlobalEventSystem:Fire(GameEvent.EventRefreshBtn,refId)
end		
