require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require ("object.Talisman.TalismanObject")
require("object.quest.QuestObj")
require("object.Quest.QuestDef") 
TalismanActionHandler = TalismanActionHandler or BaseClass(ActionEventHandler)


function TalismanActionHandler:__init()	
	local handleNet_G2C_TalismanList = function(reader)	
		self:handleNet_G2C_TalismanList(reader)	
	end		
	local handleNet_G2C_Talisman_Activate = function(reader)	
		self:handleNet_G2C_Talisman_Activate(reader)		
	end	
	
	local handleNet_G2C_Talisman_GetQuestReward = function(reader)
		self:handleNet_G2C_Talisman_GetQuestReward(reader)
	end
	
	local handNet_G2C_Talisman_Statistics = function(reader)
		self:handNet_G2C_Talisman_Statistics(reader)
	end
	
	self:Bind(ActionEvents.G2C_Talisman_GetQuestReward, handleNet_G2C_Talisman_GetQuestReward)
	self:Bind(ActionEvents.G2C_Talisman_Statistics,handNet_G2C_Talisman_Statistics)	
	self:Bind(ActionEvents.G2C_Talisman_List, handleNet_G2C_TalismanList)
	self:Bind(ActionEvents.G2C_Talisman_Active, handleNet_G2C_Talisman_Activate)
	
	local handNet_G2C_Citta_LevelUp = function(reader)
		self:handNet_G2C_Citta_LevelUp(reader)
	end
	
	local handleNet_G2C_Talisman_Reward = function(reader)
		self:handleNet_G2C_Talisman_Reward(reader)
	end
	
	local handleNet_G2C_Talisman_GetReward = function(reader)
		self:handleNet_G2C_Talisman_GetReward(reader)
	end
	
	self:Bind(ActionEvents.G2C_Citta_LevelUp,handNet_G2C_Citta_LevelUp)	
	self:Bind(ActionEvents.G2C_Talisman_Reward, handleNet_G2C_Talisman_Reward)
	self:Bind(ActionEvents.G2C_Talisman_GetReward, handleNet_G2C_Talisman_GetReward)		
end

function TalismanActionHandler:handleNet_G2C_TalismanList(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local mgr = GameWorld.Instance:getTalismanManager()
	mgr:clearTalismanList()
	
	local state = StreamDataAdapter:ReadChar(reader)
	if(state == 1 ) then
		GlobalEventSystem:Fire(GameEvent.EventSetSystemOpenStatus,MainMenu_Btn.Btn_talisman,true) --发送法宝系统开始的消息	
	else
		GlobalEventSystem:Fire(GameEvent.EventSetSystemOpenStatus,MainMenu_Btn.Btn_talisman,false) --发送法宝系统开始的消息	
	end
	local talisManLevel = StreamDataAdapter:ReadChar(reader)	
	mgr:setCittaLevel(talisManLevel)
	local list = mgr:getTalismanList()
	
	local count = StreamDataAdapter:ReadShort(reader)
	for i=0,count-1  do
		--初始化法宝列表	
		local index = StreamDataAdapter:ReadShort(reader)	
		local state = StreamDataAdapter:ReadChar(reader)
		local talisRefId = StreamDataAdapter:ReadStr(reader)		

		local obj = TalismanObject:New()
		obj:setRefId(talisRefId)		
		obj:setIndex(index)
		obj:setState(state)	
		if list[index] then
			list[index]:DeleteMe()
		end
		list[index] = obj				
	end
	GlobalEventSystem:Fire(GameEvent.EventUpdateTilismanView,5)	
end		
	        
function TalismanActionHandler:handleNet_G2C_Talisman_Activate(reader)
	reader = tolua.cast(reader, "iBinaryReader")	
	local ttype = StreamDataAdapter:ReadChar(reader)
	local index = StreamDataAdapter:ReadShort(reader)
	local ret = StreamDataAdapter:ReadChar(reader)
	--ttype =   1、获取法宝   2、法宝激活  3、取消激活 	 
	--ret   1代表操作成功   0代表操作失败	
	local artiMgr =	GameWorld.Instance:getTalismanManager()	
	local list = artiMgr:getTalismanList()
	if type(list) == "table" and list[index] then
		if( ret == 1 ) then	
			if(ttype == Talisman_Operate_Type.Achieve)then		
				if  list[index]:getRefId() then
					local pt = GetPtByRefId(list[index]:getRefId() .."_1")
					local name = pt.name
					local msg = {}
					table.insert(msg,{word = Config.Words[15008], color = Config.FontColor["ColorWhite1"]})
					table.insert(msg,{word = "["..name.."]", color = Config.FontColor["ColorRed3"]})
					table.insert(msg,{word = Config.Words[15035], color = Config.FontColor["ColorWhite1"]})
					UIManager.Instance:showSystemTips(msg)
				end	
				list[index]:setState(Talisman_State.NotActivate)			
				artiMgr:setTalismanList(list)		
			elseif(ttype == Talisman_Operate_Type.Activate ) then
				-- 修改之前被激活法宝的状态
				for k,v in pairs(list) do
					local idx = v:getIndex()/2
					if math.ceil(idx) == idx then
						if v:getState() == Talisman_State.Activate then
							v:setState(Talisman_State.NotActivate)
						end
					end
				end
				-- 修改现在要激活法宝的状态
				list[index]:setState(Talisman_State.Activate)
				artiMgr:setTalismanList(list)	
				UIManager.Instance:showSystemTips(Config.Words[15007])						
			elseif(ttype == Talisman_Operate_Type.CancelActivate) then			
				list[index]:setState(Talisman_State.NotActivate)		
				artiMgr:setTalismanList(list)				
			end	
			GlobalEventSystem:Fire(GameEvent.EventUpdateTilismanView,ttype)
		else
			--操作失败
		end
	end	
	GlobalEventSystem:Fire(GameEvent.EventRetTilismanView,ret,ttype)	
end	
	
function TalismanActionHandler:handleNet_G2C_Talisman_GetQuestReward(reader)		
	reader = tolua.cast(reader,"iBinaryReader")
	local ttype =  StreamDataAdapter:ReadChar(reader)				
	if( ttype == 1) then
		GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesOpenTalisman()--打开新手指引
		GlobalEventSystem:Fire(GameEvent.EventSetSystemOpenStatus,MainMenu_Btn.Btn_talisman,true) --发送法宝系统开始的消息						
	end	
end

function TalismanActionHandler:handNet_G2C_Talisman_Statistics(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local count = StreamDataAdapter:ReadShort(reader)	
	local mgr = GameWorld.Instance:getTalismanManager()
	local talismList = mgr:getTalismanList()
	for i=1,count  do
		--初始化法宝列表	
		local index = StreamDataAdapter:ReadChar(reader)
		local totalCount = StreamDataAdapter:ReadLLong(reader)
		local obj = talismList[index]
		if obj then
			local descStr = string.format(Config.Words[7520 + index],totalCount)
			obj:setStatisticsStr(descStr)
		end
	end	
	GlobalEventSystem:Fire(GameEvent.EventUpdateTilismanView,ttype)
end

function TalismanActionHandler:handNet_G2C_Citta_LevelUp(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local mgr = GameWorld.Instance:getTalismanManager()	
	local ret = StreamDataAdapter:ReadChar(reader)	
	if ret > mgr:getCittaLevel() then
		mgr:setCittaLevel(ret)
		local msg = {}
		table.insert(msg,{word = Config.Words[15006], color = Config.FontColor["ColorBlue2"]})
		UIManager.Instance:showSystemTips(msg)
	else
		local msg = {}
		table.insert(msg,{word = Config.Words[7544], color = Config.FontColor["ColorRed3"]})
		UIManager.Instance:showSystemTips(msg)
	end
	local manager =UIManager.Instance
	local view = manager:getViewByName("TalismanView")
	view:updateMiddleView()
	view:updateDetailsView()
end		
	
function TalismanActionHandler:handleNet_G2C_Talisman_Reward(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local ret = StreamDataAdapter:ReadShort(reader)	
	if ret == 1 then
		local artiMgr =	GameWorld.Instance:getTalismanManager()
		artiMgr:requestTalismanGetReward()
	end
end

function TalismanActionHandler:handleNet_G2C_Talisman_GetReward(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	
	local totalbaoxiang = StreamDataAdapter:ReadInt(reader)	
	local baoxiang = StreamDataAdapter:ReadInt(reader)	
	local totalgold = StreamDataAdapter:ReadInt(reader)	
	local gold = StreamDataAdapter:ReadInt(reader)	
	local totalstone = StreamDataAdapter:ReadInt(reader)	
	local stone = StreamDataAdapter:ReadInt(reader)	
	local totalexp = StreamDataAdapter:ReadInt(reader)	
	local exp = StreamDataAdapter:ReadInt(reader)	
	
	local awardList = {}
	awardList[1] = totalbaoxiang
	awardList[2] = baoxiang
	awardList[3] = totalgold
	awardList[4] = gold
	awardList[5] = totalstone
	awardList[6] = stone
	awardList[7] = totalexp
	awardList[8] = exp
	
	local mgr = GameWorld.Instance:getTalismanManager()
	mgr:setAwardList(awardList)
	
	GlobalEventSystem:Fire(GameEvent.EventUpdateTilismanView,4)
end
