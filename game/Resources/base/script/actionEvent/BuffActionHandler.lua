require("object.buff.BuffObject")
require ("object.buff.BuffEffectObject")
BuffActionHandler = BuffActionHandler or BaseClass(ActionEventHandler)

function BuffActionHandler:__init()
	local g2c_BuffList_func = function (reader)
		self:handleAttachBuff(reader)
	end
	local g2c_buffeffect_func = function (reader)
		self:handleBuffEffect(reader)
	end		
	local g2c_getBuffList_func = function (reader)
		self:handleBuffList(reader)
	end		
	local g2c_moxueshi_amount_func = function (reader)
		self:handleMoxueshiAmount(reader)
	end
	self:Bind(ActionEvents.G2C_Attach_Buff, g2c_BuffList_func)
	self:Bind(ActionEvents.G2C_Effect_Buff, g2c_buffeffect_func)		
	self:Bind(ActionEvents.G2C_Buff_List, g2c_getBuffList_func)	
	self:Bind(ActionEvents.G2C_MoXueShi_Amount, g2c_moxueshi_amount_func)
end	

function BuffActionHandler:handleMoxueshiAmount(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local buffRefId = StreamDataAdapter:ReadStr(reader)
	local createTime = reader:ReadLLong()
	local amount = reader:ReadInt()
	local buffObj = BuffObject.New()
	local pt = {}
	pt["buffRefId"] = buffRefId
	pt["index"] = createTime
	pt["amount"] = amount
	buffObj:setPT(pt)
	
	local buffMgr = GameWorld.Instance:getBuffMgr()
	buffMgr:setMoxueshiAmount(buffObj)
	GlobalEventSystem:Fire(GameEvent.EventMoXueShiAmount)
end	

function BuffActionHandler:handleBuffList(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local count = reader:ReadChar()  --int ->byte
	
	for i = 1, count do 
		local pt = {}
		local casterType = StreamDataAdapter:ReadChar(reader)  --string->byte
		local caster = StreamDataAdapter:ReadStr(reader)
		local targetType = StreamDataAdapter:ReadChar(reader)  --string->byte
		local target = StreamDataAdapter:ReadStr(reader)			
		local buffRefId = StreamDataAdapter:ReadStr(reader)
		local index = reader:ReadLLong()
		local duration = reader:ReadLLong()	--buff的剩余持续时间
		local absoluteDuration = reader:ReadLLong() --buff 初始持续时间
		
		pt["buffRefId"] = buffRefId	
		pt["casterType"] = casterType
		pt["caster"] = caster
		pt["targetType"] = targetType
		pt["target"] = target
		pt["index"] = index
		pt["duration"] = duration	
		pt["absoluteDuration"] = absoluteDuration		
		
		local buffObj = BuffObject.New()
		buffObj:setPT(pt)
		
		local buffMgr = GameWorld.Instance:getBuffMgr()
		buffMgr:attachBuff(buffObj)
	end		
end

function BuffActionHandler:handleAttachBuff(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local propertyTable = {}	
	local casterType = StreamDataAdapter:ReadChar(reader)  --string  -->byte
	local caster = StreamDataAdapter:ReadStr(reader)
	local targetType = StreamDataAdapter:ReadChar(reader) --string  -->byte
	local target = StreamDataAdapter:ReadStr(reader)	
	local buffType = reader:ReadChar()	
	local buffRefId = StreamDataAdapter:ReadStr(reader)
	local index = reader:ReadLLong()	
	local duration = reader:ReadLLong()	--buff的剩余持续时间
	local absoluteDuration = reader:ReadLLong() --buff 初始持续时间
	 
	propertyTable["buffRefId"] = buffRefId		
	propertyTable["casterType"] = casterType
	propertyTable["caster"] = caster
	propertyTable["targetType"] = targetType
	propertyTable["target"] = target
	propertyTable["index"] = index
	propertyTable["duration"] = duration
	propertyTable["absoluteDuration"] = absoluteDuration
	
	local buffObject = BuffObject.New()
	buffObject:setPT(propertyTable)	
	
	local buffMgr = GameWorld.Instance:getBuffMgr()
	if buffType == 0 then --取消
		buffMgr:detachBuff(buffObject)
	else --增加		
		buffMgr:attachBuff(buffObject)	
	end
end
--[[
	
G2C_Effect_Buff 	= Buff_Message_Begin + 2
	casterType		= string
	caster			= string
	targetType		= string
	target			= string
	type			= byte  // 1=hp  2 = mp 3 = die (死亡忽略下面) 4 = 位移(麻痹或者眩晕)
	value = int  	//伤害值  or 减魔
	{	
		if(type == 1 type == 2){		
			crtValue = int		// 当前血量 or mp
			MaxValue = int		//当前血量最大值 or maxMp
		}
		if(type = 4){
			positionX 	=  int	//X坐标
			positionY	=  int	//Y坐标
		}
		
	}

]]
local  BuffEffectType = {
	Hp = 1,
	Mp = 2,
	Die = 3,
	Position = 4,
}

local BuffHpEffectType = 1
function BuffActionHandler:handleBuffEffect(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local propertyTable = {}		
	local casterType = StreamDataAdapter:ReadChar(reader)  --string  -->byte
	local caster = StreamDataAdapter:ReadStr(reader)
	local targetType = StreamDataAdapter:ReadChar(reader)  --string  -->byte
	local target = StreamDataAdapter:ReadStr(reader)
	local effectType = reader:ReadChar()
	local value = reader:ReadInt()
	
	--Juchao@20140728: 增加对buff的伤害处理
	if effectType == BuffHpEffectType 
		and value < 0
		and caster ~= G_getHero():getId() 
		and target == G_getHero():getId() then 
		G_getFightTargetMgr():addAttacker(casterType, caster)
	end
	local buffEffectObject = BuffEffectObject.New()
	propertyTable["targetType"] = targetType
	propertyTable["casterType"] = casterType
	propertyTable["caster"] = caster
	propertyTable["target"] = target
	propertyTable["effectType"] = effectType		
	propertyTable["value"] = value
	if effectType ==  BuffEffectType.Hp or effectType ==  BuffEffectType.Mp then 
		propertyTable["CurrentValue"] = reader:ReadInt()
		propertyTable["MaxValue"] = reader:ReadInt()		
	elseif effectType ==  BuffEffectType.Position then 
		propertyTable["positionX"] = reader:ReadInt()
		propertyTable["positionY"] = reader:ReadInt()		
	end
	
	buffEffectObject:setPT(propertyTable)	
	local buffMgr = GameWorld.Instance:getBuffMgr()
	buffMgr:setBuffEffectObj(buffEffectObject)
	GlobalEventSystem:Fire(GameEvent.EventBuffEffect)	
end