require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")

MountActionHandler = MountActionHandler or BaseClass(ActionEventHandler)


function MountActionHandler:__init()	
	local handleNet_G2C_MountList = function(reader)	
		self:handleNet_G2C_MountList(reader)		
	end		
	local handleNet_G2C_Mount_IsOnMount = function(reader)	
		self:handleNet_G2C_Mount_IsOnMount(reader)		
	end		
	local handleNet_G2C_Mount_Feed = function(reader)
		self:handleNet_G2C_Mount_Feed(reader)
	end			
	local handleNet_G2C_Mount_GetMountQuestReward = function(reader)
		self:handleNet_G2C_Mount_GetMountQuestReward(reader)
	end		
	local handleNet_G2C_Mount_MountQuestResp = function(reader)
		self:handleNet_G2C_Mount_MountQuestResp(reader)
	end		

	self:Bind(ActionEvents.G2C_Mount_GetMountQuestReward,handleNet_G2C_Mount_GetMountQuestReward)
	--self:Bind(ActionEvents.G2C_Mount_MountQuestResp,handleNet_G2C_Mount_MountQuestResp)
	self:Bind(ActionEvents.G2C_Mount_List, handleNet_G2C_MountList)
	self:Bind(ActionEvents.G2C_Mount_IsOnMount, handleNet_G2C_Mount_IsOnMount)	
	self:Bind(ActionEvents.G2C_Mount_Feed,handleNet_G2C_Mount_Feed)	
end

function MountActionHandler:handleNet_G2C_MountList(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local refId = StreamDataAdapter:ReadStr(reader)	
	local exp = StreamDataAdapter:ReadULLong(reader)		
	local simId = StreamDataAdapter:ReadStr(reader)
	local state = StreamDataAdapter:ReadChar(reader)	
	
	local mgr = GameWorld.Instance:getMountManager()
	mgr:setCurrentUseMountId(refId)
	mgr:setCurrentMountExp(exp)		
	mgr:setMountState(state)
	if state ~= -1 then		
		GlobalEventSystem:Fire(GameEvent.EventSetSystemOpenStatus,MainMenu_Btn.Btn_mount,true)
		if state == 1 then
			GlobalEventSystem:Fire(GameEvent.EventIsOnMount,true)
		else
			GlobalEventSystem:Fire(GameEvent.EventIsOnMount,false)
		end
	else
		GlobalEventSystem:Fire(GameEvent.EventIsOnMount,false)
	end 
end		
	
function MountActionHandler:handleNet_G2C_Mount_IsOnMount(reader)
	reader = tolua.cast(reader, "iBinaryReader")	
	local state = StreamDataAdapter:ReadChar(reader)	
	local mgr = GameWorld.Instance:getMountManager()
	mgr:setMountState(state)
	GlobalEventSystem:Fire(GameEvent.EventSwitchMountState,state)	
end

function MountActionHandler:handleNet_G2C_Mount_Feed(reader)
	reader = tolua.cast(reader, "iBinaryReader")	
	local 	isUpgrade = false
	local  refId = StreamDataAdapter:ReadStr(reader)	
	local  exp = StreamDataAdapter:ReadULLong(reader)	
	local  state = StreamDataAdapter:ReadInt(reader)	
	local  mgr = GameWorld.Instance:getMountManager()			
	if ( mgr:getCurrentUseMountId() ~= refId) then					
		isUpgrade = true
	end
	
	mgr:setCurrentUseMountId(refId)
		
	local cuRecord = G_GetMountRecordByRefId(refId)		
	local modeId = PropertyDictionary:get_modelId(cuRecord.property)
	if ( modeId ) then
		mgr:setCurrentModeId(modeId)
	else		
	end

	mgr:setCurrentMountExp(exp)
	mgr:setBaoJi(state)
	
	if(state > 1) then
		GlobalEventSystem:Fire(GameEvent.EventMountBaoJi,state)
	end		
	if( isUpgrade == true) then	
		local msg = {}
		table.insert(msg,{word = Config.Words[15009], color = Config.FontColor["ColorBlue2"]})
		UIManager.Instance:showSystemTips(msg)			
	end		
	GlobalEventSystem:Fire(GameEvent.EventMountUpdate)
	
end

function MountActionHandler:handleNet_G2C_Mount_GetMountQuestReward(reader) --获取奖励 返回  返回成功移除可领取
	reader = tolua.cast(reader,"iBinaryReader")	
	local ret = StreamDataAdapter:ReadChar(reader)
	local mgr = GameWorld.Instance:getMountManager()	
	if( ret == 1 ) then	
		mgr:requestMountList()
		GlobalEventSystem:Fire(GameEvent.EventSetSystemOpenStatus,MainMenu_Btn.Btn_mount,true)
		GlobalEventSystem:Fire(GameEvent.EventOpenRideControl,true)
		
		local onMsgBoxCallBack = function(unused, text, id)
			if id==E_MSG_BT_ID.ID_OK then
				GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesOpenMount()--打开新手指引
			end			
		end
		local msg = showMsgBox(Config.Words[1059])		
		msg:setNotify(onMsgBoxCallBack)	
		msg:showArrow()
	end
end

function MountActionHandler:handleNet_G2C_Mount_MountQuestResp(reader)  --监听任务是否完成   为0  显示可领取    否则倒计时
	reader = tolua.cast(reader,"iBinaryReader")	
	local second = StreamDataAdapter:ReadInt(reader)	
end