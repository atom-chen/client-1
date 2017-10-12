require "common.baseclass"
require "gameevent.GameEvent"
require "ui.UIManager"
require "object.forging.ForgingDef"
require "ui.role.DetailPropertyView"
require "ui.role.PKGuidView"
require "data.monster.monster"
require "config.codefilter"

GameUIHandler = GameUIHandler or BaseClass(GameEventHandler)

function GameUIHandler:__init()
	self.selectEntityId = ""	-- 选中的EntityObject
	self.selectEntityType = ""
	
	local manager =UIManager.Instance
	
	local onOpenDetailProertyView = function(showOption, arg)
		
		manager:registerUI("DetailPropertyView", DetailPropertyView.create)
		manager:showUI("DetailPropertyView", showOption, arg)
	end
	local onHideDetailProertyView = function()
		manager:hideUI("DetailPropertyView")
	end
	
	local onOpenMyDetailProertyView = function(showOption, arg)
		
		manager:registerUI("MyDetailPropertyView", DetailPropertyView.create)
		manager:showUI("MyDetailPropertyView", showOption, arg)
		local detailPropertyView = manager:getViewByName("MyDetailPropertyView")
		detailPropertyView:updateTitle(arg.titleName)
	end
	local onHideMyDetailProertyView = function()
		manager:hideUI("MyDetailPropertyView")
	end
	
	local onOpenHisDetailProertyView = function(showOption, arg)
		
		manager:registerUI("HisDetailPropertyView", DetailPropertyView.create)
		manager:showUI("HisDetailPropertyView", showOption, arg)
		local detailPropertyView = manager:getViewByName("HisDetailPropertyView")
		detailPropertyView:updateTitle(arg.titleName)
	end
	local onHideHisDetailProertyView = function()
		manager:hideUI("HisDetailPropertyView")
	end
	
	local onHideAllUI = function()
		manager:hideAllUI()
	end
	
	local eventSetQuestBtnEnable = function (bEnable)
		self:setQuestBtnEnable(bEnable)
	end
	local onHeroProChanged = function(newPD,oldPD)
		self:onHeroProChanged(newPD,oldPD)
	end
	
	local eventShowPKGuidView = function()
		manager:registerUI("PKGuidView", PKGuidView.create)
		manager:showUI("PKGuidView",E_ShowOption.eMiddle)
	end
	
	
	local eventHeroUnusualRevieve = function()
		local hero = G_getHero()
		if hero and hero:getState():isState(CharacterState.CharacterStateDead) then
			hero:DoRevive()
		end
	end
	
	local onErrorFunc = function (msgId, errCode)
		self:onError(msgId, errCode)
	end
	
	local onHeroEnterGame = function ()
		-- 进入游戏, 重新注册注自己的对于EventErrorCode的监听
		self:registerErrorCodeEvent(onErrorFunc)
		
		local gameMapManager = GameWorld.Instance:getMapManager()
		if gameMapManager:getCurrentMapKind() ~= MapKind.instanceArea then
			G_getQuestMgr():requestQuestList()--发送任务列表请求
		end
	end
	
	local onHeroLeaveGame = function ()
		-- 退出游戏， 注销掉自己的对于EventErrorCode的监听
		self:UnBind(self.eventErrorCode)
		self.eventErrorCode = nil
	end
	
	self:Bind(GameEvent.EventHeroUnusualRevieve,eventHeroUnusualRevieve)
	self:Bind(GameEvent.EventShowPKGuidView,eventShowPKGuidView)
	self:Bind(GameEvent.EVENT_OpenDetailProperty, onOpenDetailProertyView)
	self:Bind(GameEvent.EVENT_HideDetailProperty, onHideDetailProertyView)
	self:Bind(GameEvent.EVENT_OpenMyDetailProperty, onOpenMyDetailProertyView)
	self:Bind(GameEvent.EVENT_HideMyDetailProperty, onHideMyDetailProertyView)
	self:Bind(GameEvent.EVENT_OpenHisDetailProperty, onOpenHisDetailProertyView)
	self:Bind(GameEvent.EVENT_HideHisDetailProperty, onHideHisDetailProertyView)
	self:Bind(GameEvent.EventHideAllUI, onHideAllUI)
	self:Bind(GameEvent.EventMainSetQuestBtnEnable, eventSetQuestBtnEnable)
	self:Bind(GameEvent.EventHeroProChanged, onHeroProChanged)
	
	self:Bind(GameEvent.EventHeroEnterGame,onHeroEnterGame)
	self:Bind(GameEvent.EventHeroLeaveGame,onHeroLeaveGame)
end

function GameUIHandler:onError(msgId, errCode)
	--  登录以后都是在这里处理相关的提示信息
	local data = GameData.Code[errCode]
	if data and Config.CodeFilter[errCode] == nil then
		CCLuaLog (msgId.." : ".. data)
		local msg = {[1] = {word = data, color = Config.FontColor["ColorYellow1"]}}
		UIManager.Instance:showSystemTips(msg)
		--UIManager.Instance:showSystemTips(data)
	end
	
	if errCode == 0x80000195 then
		-- 处理非法复活请求的提示
		GlobalEventSystem:Fire(GameEvent.EventReviveViewShow, false)
	elseif  errCode == 0x8000000F or errCode == 0x80000011 then
		-- 处理包速过快
		-- 主动断开
		LoginWorld.Instance:getLoginManager():getConnectionService():slientDisConnect()	
		
		if GameWorld and GameWorld.Instance then
			-- 断线重练的处理
			GameWorld.Instance:getAutoPathManager():cancel()
			GameWorld.Instance:getEntityManager():getHero():forceStop()
			GameWorld.Instance:getAnimatePlayManager():removeAll()
		
			G_getHandupMgr():stop()
			GameWorld.Instance:deleteScheduler()
		end
			
		local msg = showMsgBox(Config.LoginWords[351])	
		local errorFunc = function(arg,text,id)	
			LoginWorld.Instance:getLoginManager():clearAndReturnLogin()
		end			
		msg:setNotify(errorFunc)
	end
end

function GameUIHandler:registerErrorCodeEvent(func)
	if not self.eventErrorCode then
		self.eventErrorCode = self:Bind(GameEvent.EventErrorCode,func)
	end
end

function GameUIHandler:onHeroProChanged(newPD,oldPD)
	if oldPD and newPD then
		self:paserUnItemTips(newPD,oldPD)
		self:showProChangeTips(newPD,oldPD)
	end
end

function GameUIHandler:showProChangeTips(newPD,oldPD)
	for proName,proValue in pairs(newPD) do
		for oldProName,oldProValue in pairs(oldPD) do
			if proName == oldProName then
				if proName == "atkSpeedPer" or proName == "moveSpeedPer" then
					local name = nil
					if proName == "atkSpeedPer"  then
						name = Config.Words[10071]
					elseif proName == "moveSpeedPer" then
						name = Config.Words[10072]
					end
					local changeValue = proValue - oldProValue
					if changeValue > 0 then
						local msg = {}
						table.insert(msg,{word = name..":+", color = Config.FontColor["ColorBlue2"]})
						table.insert(msg,{word = tostring(changeValue).."%", color = Config.FontColor["ColorRed1"]})
						UIManager.Instance:showSystemTips(msg)
					elseif changeValue < 0 then
						local msg = {}
						table.insert(msg,{word = name..":", color = Config.FontColor["ColorBlue2"]})
						table.insert(msg,{word = tostring(changeValue).."%", color = Config.FontColor["ColorRed1"]})
						UIManager.Instance:showSystemTips(msg)
					end
				end
				
				for index,content in ipairs(E_ForgingDisplayPropertys) do
					if content.name == proName then
						local translateName = content.translateName
						local changeValue = proValue - oldProValue
						if changeValue > 0 then
							if content.name == "atkSpeed" or content.name == "moveSpeed" then
								return
							end
							local msg = {}
							table.insert(msg,{word = translateName..":+", color = Config.FontColor["ColorBlue2"]})
							table.insert(msg,{word = tostring(changeValue), color = Config.FontColor["ColorRed1"]})
							UIManager.Instance:showSystemTips(msg)
						elseif changeValue < 0 then
							if content.name == "atkSpeed" or content.name == "moveSpeed" then
								return
							end
							local msg = {}
							table.insert(msg,{word = translateName..":", color = Config.FontColor["ColorBlue2"]})
							table.insert(msg,{word = tostring(changeValue), color = Config.FontColor["ColorRed1"]})
							UIManager.Instance:showSystemTips(msg)
						end
					end
				end
			end
		end
	end
end

function GameUIHandler:paserUnItemTips(newPD,oldPD)
	local itemPt = GameData.UnPropsItem
	local tipsMgr = LoginWorld.Instance:getTipsManager()
	local showFlag = tipsMgr:getTipsShowFlag()
	for k,v in pairs(itemPt) do
		if newPD[k] then
			if newPD["level"] and k=="exp" then
				return
			end
			local itemCount = newPD[k] - oldPD[k]
			if itemCount > 0 then
				local nameStr =Config.Words[10119] .. itemCount	..	G_getStaticUnPropsName(k)
				if showFlag == true then
					local msg = {[1] = {word = Config.Words[10119], color = Config.FontColor["ColorYellow1"]},
								[2] = {word = tostring(itemCount), color = Config.FontColor["ColorRed3"]},
								[3] = {word = G_getStaticUnPropsName(k), color = Config.FontColor["ColorYellow1"]},}
					UIManager.Instance:showSystemTips(msg)
					--UIManager.Instance:showSystemTips(nameStr)
				elseif showFlag == false then
					tipsMgr:insertUnShowTipsList(nameStr)
				end
			end
		end
	end
	
end

function GameUIHandler:__delete()
	
end

function GameUIHandler:onTest()
	
end

function GameUIHandler:setQuestBtnEnable(bEnable)
	--待实现
end

--[[function GameUIHandler:loginRequest()
local miningMgr = GameWorld.Instance:getMiningMgr()
miningMgr:requestMiningBeOpen()
end--]]
