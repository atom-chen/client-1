require("common.ActionEventHandler")

HeroStateActionHandler = HeroStateActionHandler or BaseClass(ActionEventHandler)

function  HeroStateActionHandler:__init()
	local handleNet_G2C_Pk_Model  = function(reader)
		self:handleNet_G2C_Pk_Model(reader)
	end	
	self:Bind(ActionEvents.G2C_Pk_Model,handleNet_G2C_Pk_Model)
		
	local handleNet_G2C_Rookie_Protectionl  = function(reader)
		self:handleNet_G2C_Rookie_Protectionl(reader)
	end	
	self:Bind(ActionEvents.G2C_Rookie_Protection, handleNet_G2C_Rookie_Protectionl)	
	
end

--Juchao@20140809: 让服务器把最新的PK模式返回来。客户端在申请改变pk state时就不需要记住之前申请的类型。
function  HeroStateActionHandler:handleNet_G2C_Pk_Model(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local stateId = StreamDataAdapter:ReadChar(reader)
	--stateId = stateId - 2
	if stateId == E_HeroPKState.statePeace 
		or stateId == E_HeroPKState.stateQueue 
		or stateId == E_HeroPKState.stateFaction 
		or stateId == E_HeroPKState.stateGoodOrEvil 
		or stateId == E_HeroPKState.stateWhole then
		G_getHero():setPKStateID(stateId)
		GlobalEventSystem:Fire(GameEvent.EventChangeStateBtn)
	else
		CCLuaLog("handleNet_G2C_Pk_Model illegal pk state id "..stateId)
	end
end

function  HeroStateActionHandler:handleNet_G2C_Rookie_Protectionl(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local attackerId  = StreamDataAdapter:ReadStr(reader)
	local targetId	  = StreamDataAdapter:ReadStr(reader)
	local attackerLevel = reader:ReadInt()
	local targetLevel = reader:ReadInt()
	local hero = G_getHero()
	if hero and attackerId and targetId then
		GlobalEventSystem:Fire(GameEvent.EventPKProtection, attackerId, targetId, attackerLevel, targetLevel)		
	end
end	