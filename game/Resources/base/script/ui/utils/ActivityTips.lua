require "data.gameInstance.Ins_8"

ActivityTips = ActivityTips or BaseClass(BaseUI)

local const_activity_guaiwuruqin = "activity_manage_6"
local const_activity_wakuang = "activity_manage_7"
local const_activity_shabake = "activity_manage_8"
local const_activity_unionInstance = "activity_manage_19"
local const_activity_multitimesexp = "activity_manage_23"
local const_activity_VIP = "activity_manage_25"

local viewSize = CCSizeMake(683,455)
local scrollViewSize = CCSizeMake(viewSize.width-55, 60)

local vipAward = {
	exp = 1,
	gift = 2,
}

function ActivityTips:__init()
	self.viewName = "ActivityTips"
	self:init(viewSize)	
	self:createBg()	
	self:createLimitDescription()
	self:createInstroduce()
	self:createRewardTitle()
	self:createEnterBtn()	
end

function ActivityTips:__delete()

end

function ActivityTips:create()
	return ActivityTips.New()
end

function ActivityTips:onEnter(refId)
	self.activityRefId = refId
	self:setTitle(refId)
	self:setLimitDescription(refId)
	self:setWarning(refId)
	self:setIntroduce(refId)	
	self:setReward(refId)
	self:updateBtns(refId)
end

function ActivityTips:onExit()
end

function ActivityTips:updateBtns(refId)
	self:setBtnUnvisible()
	self.enterBtn:setVisible(true)
	if refId == const_activity_shabake then
		if not self.shabakeGetGiftBtn then
			self.shabakeGetGiftBtn = createButtonWithFramename(RES("btn_1_select.png"))
			self:addChild(self.shabakeGetGiftBtn)
	
			local text = createSpriteWithFrameName(RES("recv_huangcheng_gifts.png"))
			self.shabakeGetGiftBtn:setTitleString(text)			
	
			local onClick = function()
				G_getCastleWarMgr():requestGetGift()
			end
			self.shabakeGetGiftBtn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)	
		end
		self.shabakeGetGiftBtn:setVisible(true)
		VisibleRect:relativePosition(self.enterBtn, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X, ccp(-130, 0))
		VisibleRect:relativePosition(self.shabakeGetGiftBtn, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X, ccp(130, 0))
	elseif refId == const_activity_unionInstance then
		if not self.applyInstanceBtn then
			self.applyInstanceBtn = createButtonWithFramename(RES("btn_1_select.png"))
			self:addChild(self.applyInstanceBtn)
	
			local text = createSpriteWithFrameName(RES("word_button_unionApply.png"))
			self.applyInstanceBtn:setTitleString(text)			
	
			local onClick = function()
				self:applyUnionInstance()
			end
			self.applyInstanceBtn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)	
		end
		self.applyInstanceBtn:setVisible(true)
		VisibleRect:relativePosition(self.enterBtn, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X, ccp(-130, 0))
		VisibleRect:relativePosition(self.applyInstanceBtn, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X, ccp(130, 0))
	elseif refId == const_activity_multitimesexp then
		self.enterBtn:setVisible(false)
	elseif refId == const_activity_VIP then
		self.enterBtn:setVisible(false)
		self:showVIPBtn()
	else
		VisibleRect:relativePosition(self.enterBtn, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X, ccp(0, 0))
	end
end

function ActivityTips:setBtnUnvisible()
	if self.shabakeGetGiftBtn then
		self.shabakeGetGiftBtn:setVisible(false)
	end
	if self.applyInstanceBtn then
		self.applyInstanceBtn:setVisible(false)
	end
	if self.becomeVipBtn then
		self.becomeVipBtn:setVisible(false)
	end
	if self.mulExpBtn then
		self.mulExpBtn:setVisible(false)
	end
	if self.getRewardBtn then
		self.getRewardBtn:setVisible(false)
	end
end

function ActivityTips:showVIPBtn()
	local vipMgr = GameWorld.Instance:getVipManager()	
	
	if not self.becomeVipBtn then
		self.becomeVipBtn = createButtonWithFramename(RES("btn_1_select.png"))		
		self:addChild(self.becomeVipBtn)
		
		local text = createSpriteWithFrameName(RES("word_button_beVip.png"))
		self.becomeVipBtn:setTitleString(text)
				
		local becomeVipFun = function ()
			local vipState = vipMgr:getVipLevel()		
			if vipState == 3 then
				UIManager.Instance:showSystemTips(Config.Words[13035])
			else
				GlobalEventSystem:Fire(GameEvent.EventOpenMallView)
				self:close()
			end
		end
		self.becomeVipBtn:addTargetWithActionForControlEvents(becomeVipFun, CCControlEventTouchDown)
		VisibleRect:relativePosition(self.becomeVipBtn, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-30, 0))
	else
		self.becomeVipBtn:setVisible(true)
	end
	
	local vipState = vipMgr:getVipLevel()
	if vipState == 3 then
		UIControl:SpriteSetGray(self.becomeVipBtn)
	elseif vipState == 0 or vipState == 1 then
		UIControl:SpriteSetColor(self.becomeVipBtn)
	end
	
	if not self.mulExpBtn then
		self.mulExpBtn = createButtonWithFramename(RES("btn_1_select.png"))
		self:addChild(self.mulExpBtn)
		
		local text = createSpriteWithFrameName(RES("word_botton_multiExp.png"))
		self.mulExpBtn:setTitleString(text)
		
		local multiExpFun = function ()
			local vipLevel = vipMgr:getVipLevel()
			CCLuaLog("multiExpFun vipLevel===" .. vipLevel)
			if (vipLevel == Vip_Level.VIP_TONG or vipLevel == Vip_Level.VIP_JIN)then
				if vipMgr:getExpAwardState() then
					vipMgr:requestGetReward(vipAward.exp)
					vipMgr:requestVipAwardList()
				else					
					UIManager.Instance:showSystemTips(Config.Words[13033])										
				end	
			elseif vipLevel == Vip_Level.NOTVIP then
				UIManager.Instance:showSystemTips(Config.Words[13029])
			end				
		end
		self.mulExpBtn:addTargetWithActionForControlEvents(multiExpFun, CCControlEventTouchDown)
		VisibleRect:relativePosition(self.mulExpBtn, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X, ccp(0, 0))
	else
		self.mulExpBtn:setVisible(true)
	end
	local expAwardState = vipMgr:getExpAwardState()
	if not expAwardState then
		UIControl:SpriteSetGray(self.mulExpBtn)
	else	
		UIControl:SpriteSetColor(self.mulExpBtn)
	end
	
	if not self.getRewardBtn then
		self.getRewardBtn = createButtonWithFramename(RES("btn_1_select.png"))
		self:addChild(self.getRewardBtn)
		
		local text = createSpriteWithFrameName(RES("word_button_getreword.png"))
		self.getRewardBtn:setTitleString(text)		
		
		local getRewardFun = function ()
			local vipLevel = vipMgr:getVipLevel()	
			CCLuaLog("getRewardFun vipLevel===" .. vipLevel)
			if (vipLevel == Vip_Level.VIP_TONG or vipLevel == Vip_Level.VIP_JIN)then
				if vipMgr:getDayGiftAwardState() then
					vipMgr:requestGetReward(vipAward.gift)
					vipMgr:requestVipAwardList()
				else					
					UIManager.Instance:showSystemTips(Config.Words[13031])																								
				end	
			elseif vipLevel == Vip_Level.NOTVIP then
				UIManager.Instance:showSystemTips(Config.Words[13028])
			end					
		end
		self.getRewardBtn:addTargetWithActionForControlEvents(getRewardFun, CCControlEventTouchDown)
		VisibleRect:relativePosition(self.getRewardBtn, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE, ccp(30, 0))
	else
		self.getRewardBtn:setVisible(true)
	end
	local dayGiftAwardState = vipMgr:getDayGiftAwardState()
	if not dayGiftAwardState then
		UIControl:SpriteSetGray(self.getRewardBtn)
	else
		UIControl:SpriteSetColor(self.getRewardBtn)
	end
end

function ActivityTips:applyUnionInstance()
	local onMsgBoxCallBack = function(unused, text, id)
		if (id == 2) then
			local unionInstanceMgr = GameWorld.Instance:getUnionInstanceMgr()
			unionInstanceMgr:requestUnionInstanceApply()
		end
	end	
	local unionInstanceMgr = GameWorld.Instance:getUnionInstanceMgr()
	local playerNumber = unionInstanceMgr:getNeedPlayerNumber()
	local goldNum = unionInstanceMgr:getNeedGoldNumber()/10000		
	local word = string.format(Config.Words[25406], playerNumber, goldNum)
	local msg = showMsgBox(word,E_MSG_BT_ID.ID_CANCELAndOK)			
	msg:setNotify(onMsgBoxCallBack)
end

function ActivityTips:setTitle(refId)
	local titlePng = ""
	if refId == const_activity_guaiwuruqin then 
		titlePng = "main_activityMonsterInvasion_word.png"
	elseif refId == const_activity_wakuang then 
		titlePng = "main_activityMining_word.png"
	elseif refId == const_activity_shabake then 
		titlePng = "main_activityShabake_word.png"
	elseif refId == const_activity_unionInstance then
		titlePng = "main_activityUnion_word.png"
	elseif refId == const_activity_multitimesexp then
		titlePng = "main_multipleExp_word.png"
	elseif refId == const_activity_VIP then
		titlePng = "word_window_VIP.png"
	else
		--print("activity Type error")
	end
	if titlePng ~= "" then 
		local title = createSpriteWithFrameName(RES(titlePng))
		self:setFormTitle(title, TitleAlign.Center)
	end
end

function ActivityTips:createBg()
	self.bodyBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(644,315))--CCSizeMake(831,479))	
	self:addChild(self.bodyBg)
	VisibleRect:relativePosition(self.bodyBg,self:getContentNode(),LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,0))
	self.reWardNode = CCNode:create()
	self.reWardNode:setContentSize(CCSizeMake(viewSize.width-55, 70))
	self:addChild(self.reWardNode)
end

function ActivityTips:createLimitDescription()
	--开始时间
	self.startTimeTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[24000], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self:addChild(self.startTimeTitle)
	VisibleRect:relativePosition(self.startTimeTitle, self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(10, -5))
	
	self.startTime = createLabelWithStringFontSizeColorAndDimension(""--[[Config.Words[24000]--]], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	self:addChild(self.startTime)
	self:positionStartTimeLabel()
	--结束时间
	self.endTimeTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[24001], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self:addChild(self.endTimeTitle)
	VisibleRect:relativePosition(self.endTimeTitle, self.startTimeTitle, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, 0))
	
	self.endTime = createLabelWithStringFontSizeColorAndDimension(""--[[Config.Words[24001]--]], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	self:addChild(self.endTime)
	self:positionEndTimeLabel()
	--需要等级
	self.limitLvTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[24002], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self:addChild(self.limitLvTitle)
	VisibleRect:relativePosition(self.limitLvTitle, self.endTimeTitle, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, 0))
	
	self.limitLv = createLabelWithStringFontSizeColorAndDimension(""--[[Config.Words[24002]--]], "Arial", FSIZE("Size3"), FCOLOR("ColorGreen1"))
	self:addChild(self.limitLv)
	self:positionLimitLvLabel()
	--需要战力
	self.limitFightTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[24008], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self:addChild(self.limitFightTitle)
	VisibleRect:relativePosition(self.limitFightTitle, self.limitLvTitle, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE)
	
	self.fightValue = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"), FCOLOR("ColorGreen1"))
	self:addChild(self.fightValue)
	self:positionLimitFightValue()
	--警告
	self.warning = createLabelWithStringFontSizeColorAndDimension(Config.Words[24005], "Arial", FSIZE("Size3"), FCOLOR("ColorRed1"))
	self:addChild(self.warning)
	self:positionwarningLabel()
	
	--分割线
	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"),CCSizeMake(600,2))
	self:addChild(line)
	VisibleRect:relativePosition(line, self.warning, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE, ccp(10, -10))
end

--活动简介
function ActivityTips:createInstroduce()
	local introduceTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[24003], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self:addChild(introduceTitle)
	VisibleRect:relativePosition(introduceTitle, self.warning, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -15))	
	
	self.scrollView = createScrollViewWithSize(scrollViewSize)
	self.scrollView:setDirection(kSFScrollViewDirectionVertical)
	self.scrollView:setPageEnable(false)
	self:addChild(self.scrollView)		
	VisibleRect:relativePosition(self.scrollView, introduceTitle, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE)
	
	self.scrollContentNode = CCNode:create()
	self.scrollContentNode:setContentSize(scrollViewSize)
	self.scrollView:setContainer(self.scrollContentNode)
	
	--self.introduce = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size4"), FCOLOR("ColorWhite1"), CCSizeMake(scrollViewSize.width, 0))
	self.introduce = createRichLabel(CCSizeMake(scrollViewSize.width,0))	
	self.introduce:setFontSize(FSIZE("Size3"))	
	self.scrollContentNode:addChild(self.introduce)
--	self:positionIntroduceLabel()
end

--获取奖品
function ActivityTips:createRewardTitle()
	self.reWardTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[24004], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self:addChild(self.reWardTitle)
	VisibleRect:relativePosition(self.reWardTitle, self.bodyBg, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(10, 25))		
end

--[[		local AutoPathMgr = GameWorld.Instance:getAutoPathManager()
		local HeroPosX,HeroPosY = hero:getCellXY()
		local NpcPosX,NpcPosY = AutoPathMgr:findNpcXY(npcRefId,sceneRefId)--]]
function ActivityTips:createEnterBtn()
	self.enterBtn = createButtonWithFramename(RES("btn_1_select.png"))
	self:addChild(self.enterBtn)
	VisibleRect:relativePosition(self.enterBtn, self:getContentNode(), LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X, ccp(0, 0))
	
	local enterLabel = createSpriteWithFrameName(RES("word_enter.png"))
	self.enterBtn:setTitleString(enterLabel)
	--VisibleRect:relativePosition(enterLabel, self.enterBtn, LAYOUT_CENTER)
	
	local enterFunction = function()
		local function callback()
			self:clickEnterBtn()
		end
		GameWorld.Instance:getGameInstanceManager():leaveInstaceToActivity(callback)
	end
	self.enterBtn:addTargetWithActionForControlEvents(enterFunction,CCControlEventTouchDown)	
end

function ActivityTips:clickEnterBtn()
	
	if self.activityRefId == const_activity_guaiwuruqin then 
		local monstroMgr = G_getHero():getMonstorInvasionMgr()
		monstroMgr:requestEnterMonstorInvasionActivity()
	elseif self.activityRefId == const_activity_shabake then 
		local level = PropertyDictionary:get_level(G_getHero():getPT())
		if level >= 40 then 	
			local autoPathMgr = GameWorld.Instance:getAutoPathManager()	
			local gameMapManager = GameWorld.Instance:getMapManager()
			
			local x, y					
			local list = autoPathMgr:getTransferInList("S009")
			if type(list) == "table" and list[1] then
				x = list[1].x
				y = list[1].y					
			end
			if gameMapManager:checkCanUseFlyShoes() and x and y then
				gameMapManager:requestTransfer("S009", x, y, 1)
			else		
				autoPathMgr:startFindTargetPaths("S009")	
			end
		else
			UIManager.Instance:showSystemTips(Config.Words[21009])
		end
	elseif self.activityRefId == const_activity_wakuang then 
		local miningMgr = GameWorld.Instance:getMiningMgr()
		miningMgr:requestEnterMining()
		miningMgr:requestNextMineralTime()
	elseif self.activityRefId == const_activity_unionInstance then
		local unionInstanceMgr = GameWorld.Instance:getUnionInstanceMgr()
		unionInstanceMgr:requestUnionInstanceEnter()
	else
		
	end
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"ActivityTips")
	self:close()
end

function ActivityTips:setIntroduce(activityRefId)
	local str = " "
	if activityRefId ~= "" then 
		str = GameData.ActivityManage[activityRefId]["property"]["description"]
	end
	
	self.introduce:clearAll()
	self.introduce:appendFormatText("   "..str)
	local size = CCSizeMake(self.introduce:getContentSize().width, self.introduce:getContentSize().height)	
	if size.height < scrollViewSize.height then	
		size.height = scrollViewSize.height
	end		
	
	self.scrollContentNode:setContentSize(size)				
	self.scrollView:setContentOffset(ccp(0, -size.height + scrollViewSize.height))	
	self.scrollView:updateInset()	

	self:positionIntroduceLabel()
end

function ActivityTips:setLimitDescription(refId)
	local startTime,endTime,lv,weekDay = "", "", "", ""
	if refId == const_activity_guaiwuruqin then 	
		startTime, endTime, _ = self:getStartAndEndTime(refId)
		lv = GameData.Scene["S218"]["property"]["openLevel"]
	elseif refId == const_activity_wakuang then 
		startTime, endTime, _ = self:getStartAndEndTime(refId)
		lv = GameData.Scene["S217"]["property"]["openLevel"]
	elseif refId == const_activity_shabake then 
		startTime, endTime, weekDay = self:getStartAndEndTime(refId)
		lv = GameData.Scene["S216"]["property"]["openLevel"]
	elseif refId == const_activity_unionInstance then
		startTime, endTime, _ = self:getStartAndEndTime(refId)
		lv = 10
	elseif refId == const_activity_multitimesexp then
		startTime, endTime, _ = self:getStartAndEndTime(refId)
		lv = 40
	elseif refId == const_activity_VIP then
		startTime = Config.Words[13026]
		endTime = Config.Words[13027]
		lv = 1
	else
		--print("activity Type error")
	end		
	
	local activityMgr = GameWorld.Instance:getActivityManageMgr()
	local fightValue = 	activityMgr:getFigthValueByRefId(refId)
	self:setStartTime(startTime)
	self:setEndTime(endTime)
	self:setLimitLvDescription(lv)
	self:setLimitFightValue(fightValue)
end	

function ActivityTips:setStartTime(time)
	time = time or " "
	local startTime = --[[Config.Words[24000] .. --]]time
	self.startTime:setString(startTime)
	self:positionStartTimeLabel()
end

function ActivityTips:setEndTime(time)
	time = time or " "
	local endTime = --[[Config.Words[24001] .. --]]time
	self.endTime:setString(endTime)
	self:positionEndTimeLabel()
end

function ActivityTips:setLimitLvDescription(lv)
	lv = lv or " "
	local limitLv = --[[Config.Words[24002] .. --]]lv .. Config.Words[24006]
	self.limitLv:setString(limitLv)
	self:positionLimitLvLabel()
end

function ActivityTips:setLimitFightValue(fightValue)
	if fightValue and fightValue > 0 then
		self.fightValue:setString(fightValue)
		self:positionLimitFightValue()
		self.limitFightTitle:setVisible(true)
		self.fightValue:setVisible(true)
	else
		self.limitFightTitle:setVisible(false)
		self.fightValue:setVisible(false)
	end
end

function ActivityTips:setWarning(activityRefId,warning)
	local warningStr = " "
	local datawarning = GameData.ActivityManage[activityRefId]["property"]["warning"]
	if string.len(datawarning)~=0 then
		warningStr = Config.Words[24005] .. datawarning	
	end
	self.warning:setString(warningStr)
	local hasLose = GameData.ActivityManage[activityRefId]["property"]["hasLose"]
	if hasLose == 0 then
		self.warning:setColor(FCOLOR("ColorRed5"))
	else
		self.warning:setColor(FCOLOR("ColorRed1"))
	end
	self:positionwarningLabel()	
end

function ActivityTips:setReward(activityRefId)
	local rewards = nil	
	if activityRefId ~= "" then 	
		rewards = GameData.ActivityManage[activityRefId]["property"]["reward"]			
	end
		
	if rewards then 
		self.reWardNode:removeAllChildrenWithCleanup(true)
		rewards = string.split(rewards, "|")
		local preNode =self.reWardTitle
		local cnt = 0
		
		if activityRefId == const_activity_VIP then
			local vipLevel = PropertyDictionary:get_vipType(G_getHero():getPT())
			if vipLevel == Vip_Level.VIP_TONG then
				table.remove(rewards, 3)
			elseif vipLevel == Vip_Level.VIP_JIN then
				table.remove(rewards, 2)
			else
				table.remove(rewards, 2)
			end			
		end
		
		for k, refId in pairs(rewards) do 
			local itemBox = G_createItemShowByItemBox(refId,nil,nil,nil,nil,-1)
			cnt = cnt+1
			if itemBox and cnt<8 then 
				itemBox:setScale(0.8)
				self.reWardNode:addChild(itemBox)				
				if cnt == 1 then 
					VisibleRect:relativePosition(itemBox, preNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER, ccp(160, 0))					
				else
					VisibleRect:relativePosition(itemBox, preNode, LAYOUT_RIGHT_OUTSIDE+LAYOUT_TOP_INSIDE, ccp(25, 0))
				end
				preNode = itemBox
			end
		end
	end
end

--private
function ActivityTips:positionStartTimeLabel()
	VisibleRect:relativePosition(self.startTime, self.startTimeTitle, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE)
end

function ActivityTips:positionEndTimeLabel()
	VisibleRect:relativePosition(self.endTime, self.endTimeTitle, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE)
end

function ActivityTips:positionLimitLvLabel()
	VisibleRect:relativePosition(self.limitLv, self.limitLvTitle, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE)
end

function ActivityTips:positionwarningLabel()
	VisibleRect:relativePosition(self.warning, self.limitFightTitle, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, 0))
end

function ActivityTips:positionIntroduceLabel()
	VisibleRect:relativePosition(self.introduce, self.scrollContentNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE)
end

function ActivityTips:positionLimitFightValue()
	VisibleRect:relativePosition(self.fightValue, self.limitFightTitle, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE)
end	

--获取开始和结束时间
function ActivityTips:getStartAndEndTime(refId)
	local startTime, endTime = "", ""
	local weekDay = ""
	if refId == const_activity_guaiwuruqin then	 
		require "data.activity.monsterInvasion"	
		local time = GameData.MonsterInvasion["monsterInvasion1"]["time"]["duration"]
		time = string.split(time, "&")
		if time and time[1] then 
			local tmpTime = string.split(time[1], "|")
			if tmpTime then 
				startTime = tmpTime[1]
				endTime = tmpTime[2]
			end
		end
		if time and time[2] then 
			local tmpTime = string.split(time[2], "|")
			if tmpTime then 
				startTime = startTime .."   ".. tmpTime[1]
				endTime = endTime .. "   "..tmpTime[2]
			end
		end
	elseif refId == const_activity_wakuang then 
		local tmpTime = ""
		require "data.activity.mining"
		local time = GameData.Mining["sa_1"]["time"]["duration"]
		time = string.split(time, "&")
		if time and time[1] then 
			tmpTime = string.split(time[1], "|")
			if tmpTime then 
				startTime = tmpTime[1]
				endTime = tmpTime[2]
			end
		end
		if time and time[2] then 
			tmpTime = string.split(time[2], "|")
			if tmpTime then 
				startTime = startTime .."   ".. tmpTime[1]
				endTime = endTime .. "   "..tmpTime[2]
			end
		end
	elseif refId == const_activity_shabake then
		startTime, endTime = G_getCastleWarMgr():getNextWarTime()
	elseif refId == const_activity_unionInstance then
		local time = GameData.Ins_8["Ins_8"].configData["game_instance"].configData["Ins_8"].gameInstanceData.openDetailsData
		--.configData.gameInstanceData.openDetailsData
		time = string.split(time, "&")
		if time and time[1] then 
			local tmpTime = string.split(time[1], "|")
			if tmpTime then 
				startTime = tmpTime[1]
				local tmpEndTime = string.split(startTime, ":")
				temendTime = tonumber(tmpTime[2])
				local hour = 00
				local minute = 00
				local second = 00
				if tmpEndTime[1] then
					hour = tonumber(tmpEndTime[1]) + temendTime/3600										
				end
				if tmpEndTime[2] then
					minute = tonumber(tmpEndTime[2]) + (temendTime%3600)/60
				end
				if tmpEndTime[3] then
					second = tonumber(tmpEndTime[3]) + (temendTime%3600) - minute*60
				end					
				endTime = string.format("%02d:%02d:%02d", hour, minute, second)				
			end
		end		
	elseif refId == const_activity_multitimesexp then--TODO  多倍经验活动的开始和结束时间
		require "data.activity.multiExp"
		local time = GameData.MultiExp["multiExp"].time.duration
		time = string.split(time, "&")
		if time and time[1] then 
			local tmpTime = string.split(time[1], "|")
			if tmpTime then 
				startTime = tmpTime[1]
				endTime = tmpTime[2]
			end
		end
		if time and time[2] then 
			local tmpTime = string.split(time[2], "|")
			if tmpTime then 
				startTime = startTime .."   ".. tmpTime[1]
				endTime = endTime .. "   "..tmpTime[2]
			end
		end	
	else
		--print("activity Type error")
	end
	return startTime, endTime, weekDay
end	

--2014-07-01 20:30:00
local const_shabakeTimeLen = 19
function ActivityTips:shabeke_str2time(str)
	if type(str) ~= "string" or string.len(str) ~= const_shabakeTimeLen then
		CCLuaLog("shabeke_str2time error. type(str) ~= string or string.len(str) ~= const_shabakeTimeLen")
		return -1
	end
	local year = tonumber(string.sub(str, 1, 4))
	local month = tonumber(string.sub(str, 6, 7))
	local day = tonumber(string.sub(str, 9, 10))
	local hour = tonumber(string.sub(str, 12, 13))
	local min  = tonumber(string.sub(str, 15, 16))
	local sec = tonumber(string.sub(str, 18, 19))
	
	if year and month and day and hour and min and sec then
		return os.time{year = year, month = month, day = day, hour = hour, min = min, sec = sec}
	else
		return -1
	end
end

--duration = "2014-07-01 20:30:00|2014-07-01 21:00:00&2014-07-04 20:30:00|2014-07-04 21:00:00&2014-07-07 20:30:00|2014-07-07 21:00:00&2014-07-10 20:30:00|2014-07-10 21:00:00&2014-07-13 20:30:00|2014-07-13 21:00:00&2014-07-16 20:30:00|2014-07-16 21:00:00"
function ActivityTips:pareseShabakeTime()
	local startTimeStr = "-"
	local endTimeStr = "-"
		
	local ret = GameData.CastleWar["castleWar"]["time"]["duration"]
	if string.find(ret, "&") then
		ret = string.split(ret, "&")	
	end
	if type(ret) ~= "table" then
		return startTimeStr, endTimeStr 
	end
	
	for k, v in ipairs(ret) do 
		local timeStr
		if string.find(v, "|") then 
			timeStr = string.split(v, "|")	
		end
		if timeStr and type(timeStr) == "table" and table.size(timeStr) == 2 then
			startTimeStr = timeStr[1]
			endTimeStr = timeStr[2]				
			local startTime = self:shabeke_str2time(startTimeStr)			
			if startTime >= os.time() then	--显示比当前时间大的时间
				return startTimeStr, endTimeStr
			end
		end
	end			
end


-------------------------------------------------新手引导------------------------------------------------
function ActivityTips:getEnterNode(activityType)
	if activityType and self.activityRefId == activityType then
		return self.enterBtn
	end
end















