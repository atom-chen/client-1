require("common.baseclass")
require("actionEvent.ActionEventDef")
require"data.wing.wing"
WingMgr = WingMgr or BaseClass()

function WingMgr:__init()
	self.checkHaveReceive = false
	self.haveGetWing = false
	self.isLogin = true
	self.bNeedUpdate = false
	self.curExp = 0
end

function WingMgr:__delete()
	self.wingObj:DeleteMe()
end

function WingMgr:clear()
	self.checkHaveReceive = false
	self.haveGetWing = false
	self.isLogin = true
	if self.wingObj then
		self.wingObj:DeleteMe()	
		self.wingObj = nil
	end			
	self.bNeedUpdate = true
	--self:setNeedUpdateSubWingView(true)
end

--获取当前翅膀
function WingMgr:requestNowWing()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Wing_RequestNowWing)	
	simulator:sendTcpActionEventInLua(writer)	
end

--翅膀升级
function WingMgr:requestUpGradeWing(refId,num)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Wing_WingLevelUp)	
	writer:WriteString(refId)
	writer:WriteChar(num)
	simulator:sendTcpActionEventInLua(writer)
end	

--翅膀任务奖励领取
function WingMgr:requestGetWingQuestReward()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Wing_GetWingQuestReward)	
	simulator:sendTcpActionEventInLua(writer)
end

--VIP领取翅膀
function WingMgr:requestGetVipWingReward()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2C_Vip_GetWing)
	simulator:sendTcpActionEventInLua(writer) 
end

function WingMgr:setWingObject(WingObject)
	if WingObject then
		if self.wingObj then
			self.wingObj:DeleteMe()
		end
		self.wingObj = WingObject
	end
end

function WingMgr:getWingObject()
	return self.wingObj
end

function WingMgr:getWingRefId()
	if self.wingObj ~= nil then
		return self.wingObj:getRefId()
	end
end

function WingMgr:setWingList ()
	self.wingList = {}
	table.insert(self.wingList,self.wingObj)
end

function WingMgr:getWingList()
	return self.wingList
end

function WingMgr:setWingExp(exp)
	self.wingExp = exp
end

function WingMgr:getWingExp()
	return self.wingExp
end

function WingMgr:getWingNameById(refId)
	if refId then
		local curTabel = GameData.Wing[refId]["property"]
		if curTabel then
			WingName = PropertyDictionary:get_name(curTabel)	
			return WingName
		end						
	end		
end

function WingMgr:getWingLevelById(refId)
	local level = 0	
	if refId then
		level = tonumber( string.match(refId,"%a+_(%d+)"))
	end
	return level
end

function WingMgr:getWingIconIdById(refId)
	if refId then
		local curTabel = GameData.Wing[refId]["property"]	
		if curTabel then
			WingIconId = PropertyDictionary:get_iconId(curTabel)
			return WingIconId
		end			
	end		
end

function WingMgr:getWingNextRefIdById(refId)
	if refId then
		local curTabel = GameData.Wing[refId]["property"]	
		if curTabel then
			WingNextRefId = PropertyDictionary:get_wingNextRefId(curTabel)
			return WingNextRefId
		end			
	end	
end

function WingMgr:getWingFightById(refId)
	if refId then
		local curTabel = GameData.Wing[refId]["property"]			
		if curTabel then
			WingFight = PropertyDictionary:get_injure(curTabel)
			return WingFight
		end			
	end		
end

function WingMgr:getWingModelIdById(refId)
	if refId then
		local curTabel = GameData.Wing[refId]["property"]	
		if curTabel then
			WingModelId = PropertyDictionary:get_injure(self.curTabel)
			return WingmodelId
		end			
	end		
end

function WingMgr:showGetWingBox()
	local refId = nil
	if refId == nil then
		refId = "wing_1_0"
	end

	local iicon = nil
	local iiconName = nil	
	local staticData = GameData.Wing[refId]
	if (staticData ~= nil) then
		iicon = staticData.property.iconId
		iiconName = staticData.property.name
	end
	
	if not iicon or not iiconName then
		return
	end
	local description = Config.Words[720]
	
	local btnNodify = function ()
		if self:getHaveGetWing() == false then
			self:requestGetWingQuestReward()
			self:setHaveGetWing(true)
		end			
		local view = UIManager.Instance:getViewByName("GetWingView")
		if view then
			UIManager.Instance:hideUI("GetWingView")
		end
	end
	local getWingView = UIManager.Instance:showPromptBox("GetWingView",1, true)
	getWingView:setBtn(Config.Words[722], btnNodify)
	getWingView:setTitleWords(Config.Words[721])
	getWingView:setIcon(iicon)
	getWingView:setIconWord(iiconName)
	getWingView:setDescrition(description)
end

function WingMgr:checkWingGet()
	if self.checkHaveReceive == false then	
		local curModleId = PropertyDictionary:get_wingModleId(G_getHero():getPT())
		if curModleId > 0 then
			self.checkHaveReceive = true
			return
		elseif curModleId == 0 then	
			self:showGetWingBox()
			self.checkHaveReceive = true
		end			
	end
end

function WingMgr:setHaveGetWing(haveGetWing)
	self.haveGetWing = haveGetWing
end

function WingMgr:getHaveGetWing()
	return self.haveGetWing
end

--断线重连是否要更新人物模型
--[[function WingMgr:setNeedUpdate(bUpdate)
	self.bNeedUpdate = bUpdate
end

function WingMgr:getNeedUpdate()
	return self.bNeedUpdate
end--]]

--断线重连是否要更新subWingView的人物模型
--[[function WingMgr:setNeedUpdateSubWingView(bUpdate)
	self.bUpdateSubWingView = bUpdate
end

function WingMgr:getNeedUpdateSubWingView()
	return self.bUpdateSubWingView
end--]]

--判断是否应该显示wingBtn
function WingMgr:checkShowWingBtn(refId)
	local wingLevel
	if refId ~= nil then
		wingLevel = self:getWingLevelById(refId)
	else
		WingLevel = 0
	end		
	
	--local mountMgr = GameWorld.Instance:getMountManager()
	--local mountId = mountMgr:getCurrentUseMountId()
	if wingLevel < 2 then
		return true
	else
		return false
	end
end

function WingMgr:showGetWingRewardBox(refId, level)
	if not refId or not level then
		return
	end
	
	local iicon = nil
	local iiconName = nil	
	local staticData = GameData.Wing[refId]
	if (staticData ~= nil) then
		iicon = staticData.property.iconId
		iiconName = staticData.property.name
	end
	
	if not iicon or not iiconName then
		return
	end
	local description = string.format(Config.Words[723], level)
	
	local btnNodify = function ()	
		self:requestGetVipWingReward()								
		local view = UIManager.Instance:getViewByName("GetWingVipView")
		if view then
			UIManager.Instance:hideUI("GetWingVipView")
		end
	end
	
	local closeNotify = function ()
		self:requestGetVipWingReward()										
	end
	
	local getWingVipView = UIManager.Instance:showPromptBox("GetWingVipView",1, true)
	getWingVipView:setBtn(Config.Words[722], btnNodify)
	getWingVipView:setTitleWords(Config.Words[721])
	getWingVipView:setIcon(iicon)
	getWingVipView:setIconWord(iiconName)
	getWingVipView:setDescrition(description)
	getWingVipView:setCloseNodify(closeNotify)
end

function WingMgr:getFeedNeedNum(refId)
	if not refId then
		return 0
	end
	
	local staticData = GameData.Wing[refId]
	if staticData then
		local pt = staticData.property
		if pt then
			return pt["featherMaxConsume"]
		end
	end
	return 0
end	


function WingMgr:getWingEffecData(refId)
	if not refId then
		return {}
	end
	
	local staticData = GameData.Wing[refId]
	if staticData then
		local pt = staticData.effectData
		if pt then
			return pt
		end
	end
	return {}
end	
	