require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")

--[[
C2G_Bag_Streng			        = Forge_Message_Begin+1,
C2G_Body_Streng                 = Forge_Message_Begin+2,
C2G_Bag_StrengScroll		    = Forge_Message_Begin+3,
C2G_Body_StrengScroll           = Forge_Message_Begin+4,
G2C_Streng_Ret                  = Forge_Message_Begin+5,
C2G_Bag_Wash                    = Forge_Message_Begin+6,
C2G_Body_Wash                   = Forge_Message_Begin+7,
C2G_Bag_Decompose               = Forge_Message_Begin+8,       
C2G_Body_Decompose              = Forge_Message_Begin+9,  
G2C_ForgeOpen					= Forge_Message_Begin+10,
--]]

ForgingActionHandler = ForgingActionHandler or BaseClass(ActionEventHandler)
local simulator = SFGameSimulator:sharedGameSimulator()

function ForgingActionHandler:__init()	
	local handleNet_G2C_Streng_Ret = function(reader)	
		return self:handleNet_G2C_Streng_Ret(reader)
	end
	self:Bind(ActionEvents.G2C_Streng_Ret, handleNet_G2C_Streng_Ret)		
	
	local handleNet_G2C_Decompose_Ret = function(reader)	
		return self:handleNet_G2C_Decompose_Ret(reader)
	end
	self:Bind(ActionEvents.G2C_Bag_Decompose, handleNet_G2C_Decompose_Ret)	
	local handleNet_G2C_ForgeOpen = function(reader)	
		return self:handleNet_G2C_ForgeOpen(reader)
	end
	self:Bind(ActionEvents.G2C_ForgeOpen, handleNet_G2C_ForgeOpen)		
end		

function ForgingActionHandler:handleNet_G2C_Decompose_Ret(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local decomposeRet = {}
	decomposeRet.totalGold = reader:ReadInt()  		--获得总金币
	decomposeRet.exp = reader:ReadLLong()			--获得金币
	decomposeRet.itemKindCount = reader:ReadShort()	--获得物品种类
	decomposeRet.itemCount = reader:ReadShort()
	decomposeRet.items = {}
	for i = 1, decomposeRet.itemCount do
		local trefId = StreamDataAdapter:ReadStr(reader)
		local tnumber = reader:ReadShort()  --int->short
		table.insert(decomposeRet.items, {refId = trefId, number = tnumber})
	end
	GlobalEventSystem:Fire(GameEvent.EventDecomposeRet, decomposeRet)
end

function ForgingActionHandler:handleNet_G2C_Streng_Ret(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local ret = reader:ReadChar()
	if (ret == 0) then
		GlobalEventSystem:Fire(GameEvent.EventStrengthenRet, false)
	else
		GlobalEventSystem:Fire(GameEvent.EventStrengthenRet, true)
	end			
end	

function ForgingActionHandler:handleNet_G2C_ForgeOpen(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local isStrengOpen = reader:ReadChar()
	local isWashOpen= reader:ReadChar()	
	if isStrengOpen == 1 or isWashOpen == 1 then
		G_getForgingMgr():setOpenFlag(ForgeSubViewType.Strengthen,isStrengOpen)
		G_getForgingMgr():setOpenFlag(ForgeSubViewType.Wash,isWashOpen)
		GlobalEventSystem:Fire(GameEvent.EventForgeSystemOpen)
	end
end