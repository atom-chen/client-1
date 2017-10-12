require("common.baseclass")
require"data.mount.mount"
MountManager = MountManager or BaseClass()

local MOUNTUP = 0
local MOUNTDOWN = 1

function MountManager:__init()
	self.secondsRest = 0
	self.currentMountId = -1
	self.mountCD = 0
	self.MountState = -1
	self.isInQuestFind = false	
	--self.checkHaveReceive = false
end

function MountManager:clear()
	self.secondsRest = 0
	self.currentMountId = -1
	self.mountCD = 0
	self.MountState = -1
	self.isInQuestFind = false
	self.checkHaveReceive = false
	self.Exp =  0	
end	

function MountManager:requestGetMountAward()	
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mount_GetMountQuestReward)
	simulator:sendTcpActionEventInLua(writer)
end

function MountManager:requestMountList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mount_List)
	simulator:sendTcpActionEventInLua(writer)	
end

function MountManager:requestMountState()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mount_IsOnMount)
	simulator:sendTcpActionEventInLua(writer)	
end

function MountManager:requestMountFeed(refId , ItemNum)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mount_Feed)
	writer:WriteInt(ItemNum)	
	writer:WriteString(refId)
	simulator:sendTcpActionEventInLua(writer)		
end
--
--type ==0  请求上马    type == 1  请求下马 
function MountManager:requestMountRide(ttype)
	if(ttype == nil) then
		return 
	end		
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mount_Action)
	writer:WriteInt(ttype)
	simulator:sendTcpActionEventInLua(writer)	
end

function MountManager:requestEquipedMount()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mount_EquipMount)
	simulator:sendTcpActionEventInLua(writer)	
end
--装备
function MountManager:requestMountEquip(mountState,gridIndex,command)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mount_Equip)
	writer:WriteChar(command)
	writer:WriteChar(mountState)
	writer:WriteShort(gridIndex)
	simulator:sendTcpActionEventInLua(writer)
end	

function MountManager:isMountSystemOpen()
	if self.currentMountId ~= -1 then
		return  true
	end
	return false
end

function MountManager:getCurrentUseMountId()
	return self.currentMountId
end

function MountManager:getBaoJi()
	return self.baoji
end


function MountManager:setBaoJi( rate )
	self.baoji = rate
end

function MountManager:setCurrentUseMountId(id)
	self.currentMountId = id
	--self.currentMountId = "ride_1"
end	

--取得当前显示的模型id
function MountManager:getCurrentModeId()
--[[	if self.mountList	[self.currentMountId] then
		local modeId =	self.mountList[self.currentMountId]:getPropertyTable()["mountSharpId"]	
		return modeId
	else
		return nil
	end--]]
	return self.modeId
end

--设置Id对应的模型id
function MountManager:setCurrentModeId(modeId)
--[[	if self.mountList[self.currentMountId] then
		local modeId =	self.mountList[self.currentMountId]:getPropertyTable()["mountSharpId"]	
		return modeId
	else
		return nil
	end--]]
	self.modeId = modeId
	
end	

function MountManager:setCurrentMountExp( exp)
	self.Exp =  exp	
--	self.Exp =  1150
end

function MountManager:getCurrentMountExp()
	return self.Exp
end	


function MountManager:setMountState(state)
	self.MountState =  state	
end

function MountManager:getMountState()
	return self.MountState
end	

function MountManager:setSecondsRest(seconds)
	self.secondsRest = seconds
end

function MountManager:getSecondsRest()
	return self.secondsRest
end

function MountManager:saveMountCD(cd)
	self.mountCD = cd
end

function MountManager:getMountCD()
	return self.mountCD
end

function MountManager:canMountUp()
	if( self.mountCD > 0  or  self.currentMountId == -1 ) then
		return false
	else
		return true
	end
end

function MountManager:callMountUp()
	if self:IsOnMount() then
		return 	
	end
	if self:canMountUp() then
		self:requestMountRide(MOUNTUP)
		return true
	else
		return false
	end
end

function MountManager:setIsInQuestFind(state)
	self.isInQuestFind = state
end

function MountManager:getIsInQuestFind()
	return self.isInQuestFind
end

function MountManager:IsOnMount()
	if self.MountState == 1 then
		return true
	else
		return false
	end
end

function MountManager:showGetMountBox()
	local hero = G_getHero()
	--local curLevel = self:getCurrentUseMountId()
	local refId = "ride_1"
	local iicon 
	local iiconName
		
	local staticData = GameData.Mount[refId]
	if (staticData ~= nil) then
		iicon = staticData.property.iconId
		iiconName = staticData.property.name
	end
	local description = Config.Words[1059]
	
	local btnNodify = function ()
		self:requestGetMountAward() 
		local view = UIManager.Instance:getViewByName("GetFirstMountView")
		if view then
			UIManager.Instance:hideUI("GetFirstMountView")
		end	
		--self.checkHaveReceive = true	
	end

	local exitNodify = function ()
		local view = UIManager.Instance:getViewByName("GetFirstMountView")
		if view then
			UIManager.Instance:hideUI("GetFirstMountView")
		end
		--self.checkHaveReceive = false
	end	
	
	local getMountView = UIManager.Instance:showPromptBox("GetFirstMountView",1, true)
	getMountView:setBtn(Config.Words[1061], btnNodify)
	getMountView:setCloseNodify(exitNodify)
	getMountView:setTitleWords(Config.Words[1060])	
	getMountView:setIcon(iicon)
	getMountView:setIconWord(iiconName)
	getMountView:setDescrition(description)	
	--self.checkHaveReceive = true	
end

function MountManager:checkMountGet()
	--if self.checkHaveReceive == false then
	local curLevel = self:getCurrentUseMountId()
	if type(curLevel) == "string" then
		self.checkHaveReceive = true
		return
	else			
		self:showGetMountBox()			
	end
	--end
end

function MountManager:getLevelByMountStateId(mountStateId)
	local mountStateId = tonumber(mountStateId)
	if mountStateId >= 5000 then
		return mountStateId - 4999
	end
	return 0
end