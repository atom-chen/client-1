
MaterialStrongCell = MaterialStrongCell or BaseClass(BaseStrongerCell)


function MaterialStrongCell:__init()
	self.srongerMgr = GameWorld.Instance:getStrongerMgr()
	self.isInitCell = false
	if self.refId then
		self:initCellReady(self.refId)
	end		
end

function MaterialStrongCell:__delete()
	if self.refId then
		self.srongerMgr:clearCountDownRefId(self.refId)
		self.srongerMgr:clearReadyCallBackByRefId(self.refId)
	end
end

function MaterialStrongCell:onEnter()
	if self.isInitCell==false and self.refId then
		self:initCell(self.refId)
		self.isInitCell = true
		
		self:startCountDown(self.refId)
	end
end

function MaterialStrongCell:startCountDown(refId)
	local channel = self.srongerMgr:getStaticData_MaterialChannel(self.refId)
	if channel==StrongerChannel.Boss then --BOSS	
		local monsterId = self.srongerMgr:getStaticData_MaterialContent(refId).monsterId
		if not monsterId then
			return
		end
		local time = G_getHero():getWorldBossMgr():getRefreshTimeByBoss(monsterId[1])
		if type(time) == "number" and time > 0 then
			local function func()
				self:setDescription(refId)
			end
			self.srongerMgr:addCountDownRefId(refId,func,time)
		end
	end
end

function MaterialStrongCell:initCell(refId)
	self:setCellTitleImage(refId)	
	self:setDescription(self.refId)
	self:setReward(refId)
	self:setBtn(refId)
	
	if self:isReady() then
		if self:isRecommended()	 then
			self:setReconmand()
		end	
	end	
end

function MaterialStrongCell:initCellReady(refId)
	local function registReadyCallBackFunc()
		self:setCellReady()
	end
	
	local function setReadyCallBackFunc(bReady)
		self:setReady(bReady)
	end
	
	self.srongerMgr:requestSeverData(refId,setReadyCallBackFunc,registReadyCallBackFunc)
end

function MaterialStrongCell:setCellReady()
	if self.refId then
		self:setDescription(self.refId)
		if self:isRecommended()	 then
			self:setReconmand()
		end
	end
	self:setReady(true)
end

function MaterialStrongCell:setReconmand()
	if not self.linkLabel then
		return
	end
	local lable = createSpriteWithFrameName(RES("strongRecommend.png"))
	lable:setRotation(-10)
	self.rootNode:addChild(lable)		
	VisibleRect:relativePosition(lable, self.linkLabel,  LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER,ccp(5,-2))
end

function MaterialStrongCell:isRecommended()
	return self.srongerMgr:getCelllRecomandedState(self.refId)
end

function MaterialStrongCell:setCellTitleImage(refId)
	if self.titleIcon then
		return
	end
	
	local titleIcon = self.srongerMgr:getStaticData_MaterialIcon(refId)
	if  titleIcon then
		local iconFrame = createSpriteWithFrameName(RES("bagBatch_itemBg.png"))
		self.rootNode:addChild(iconFrame)		
		VisibleRect:relativePosition(iconFrame, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y,ccp(16,0))		
		
		local iconWay = self.srongerMgr:getIconMaterialWay(refId)
		if iconWay == "res" then
			self.titleIcon = createSpriteWithFrameName(RES(titleIcon..".png"))
		elseif iconWay == "icon" then
			self.titleIcon = createSpriteWithFileName(ICON(titleIcon))
		end
		
		if self.titleIcon then
			self.titleIcon:setScale(self.srongerMgr:getIconMaterialScale(refId))
			iconFrame:addChild(self.titleIcon)		
			VisibleRect:relativePosition(self.titleIcon, iconFrame, LAYOUT_CENTER)	
		end	
	end	
end

function MaterialStrongCell:setDescription(refId)
	if not refId then
		return
	end		
	
	if not self.linkLabel then
		self.linkLabel = createRichLabel()
		self.linkLabel:setGaps(5)
		self.linkLabel:setAnchorPoint(ccp(0.5,1))
		self.linkLabel:setFontSize(FSIZE("Size3"))
		self.linkLabel:appendFormatText(self.srongerMgr:getCelllDescStrByRefId(refId))	

		self.rootNode:addChild(self.linkLabel)	
		VisibleRect:relativePosition(self.linkLabel, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(90,-5))
	else
		self.linkLabel:clearAll()
		self.linkLabel:appendFormatText(self.srongerMgr:getCelllDescStrByRefId(refId))	
		VisibleRect:relativePosition(self.linkLabel, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(90,-5))
	end
	
end

function MaterialStrongCell:setReward(refId)
	local rewardLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[6511], "Arial", FSIZE("Size3"), FCOLOR("Yellow3"))
	self.rootNode:addChild(rewardLabel)
	VisibleRect:relativePosition(rewardLabel,  self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(90,25))	
	
	local content = self.srongerMgr:getStaticData_MaterialContent(refId)
	local reward = content.reward
	if not reward then
		return
	end
	
	local offsetX = 60
	for i,v in pairs(reward) do
		local rewardIcon = G_createItemShowByItemBox(v,nil,nil,nil,nil,-1)
		rewardIcon:setScale(0.8)
		self.rootNode:addChild(rewardIcon)
		VisibleRect:relativePosition(rewardIcon,  rewardLabel, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp((i-1)*offsetX,0))	
	end
end

function MaterialStrongCell:setBtn(refId)
	local channel = self.srongerMgr:getStaticData_MaterialChannel(refId)
	if channel== StrongerChannel.ZhengMoTa 
		or channel== StrongerChannel.Instance
		or channel== StrongerChannel.Arena
		or channel== StrongerChannel.Mining
		or channel== StrongerChannel.monstInvasion then
		if self:canCreateBtn(refId) then
			self:createTranInBtn(refId)
		end
	else		
		if self:canCreateBtn(refId) then
			self:crateNormalBtn(refId)
		end
	end
end

function MaterialStrongCell:canCreateBtn(refId)
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	
	local channel = self.srongerMgr:getStaticData_MaterialChannel(refId)
	if channel == StrongerChannel.DailyQuest then --日常任务
		local content = self.srongerMgr:getStaticData_MaterialContent(refId)
		local questId = content.questId
		if not questId then
			return true
		end	
		local acceptLevel = QuestRefObj:getStaticQusetConditionFieldAcceptLevel(QuestType.eQuestTypeDaily,questId)		
		if heroLevel<acceptLevel then
			self:showUnCreateLabel(acceptLevel)
			return false
		end
	elseif channel == StrongerChannel.ZhengMoTa or --镇魔塔
			channel == StrongerChannel.Instance then --副本
		local content = self.srongerMgr:getStaticData_MaterialContent(refId)
		local insRefid = content.insId
		if not insRefid then
			return true
		end
		
		local openLevel = QuestInstanceRefObj:getInstancelevel(insRefid)
		if heroLevel < openLevel then		
			self:showUnCreateLabel(openLevel)
			return false
		end
	elseif channel == StrongerChannel.Boss or channel==StrongerChannel.HandUpPoint or channel==StrongerChannel.eliteMonster then --BOSS、挂机点、精英怪
		local content = self.srongerMgr:getStaticData_MaterialContent(refId)
		local sceneId = content.sceneId
		if not sceneId then
			return true
		end	
		
		targetData = GameData.Scene[sceneId]
		local property = targetData["property"]
		local openLevel = PropertyDictionary:get_openLevel(property)		
		if heroLevel< openLevel then
			self:showUnCreateLabel(openLevel)
			return false
		end
	elseif channel == StrongerChannel.monstInvasion then --怪物入侵
		local openLevel = G_getHero():getMonstorInvasionMgr():getOpenLevel()
		if heroLevel<openLevel then
			self:showUnCreateLabel(openLevel)
			return false
		end
	elseif channel == StrongerChannel.Mining then --挖矿活动
		local openLevel = GameWorld.Instance:getMiningMgr():getOpenLevel()
		if heroLevel < openLevel then
			self:showUnCreateLabel(openLevel)
			return false
		end
	elseif channel==StrongerChannel.Arena then --竞技场
		local arenaMgr = GameWorld.Instance:getArenaMgr()
	
		local openLevel =  arenaMgr:getOpenLevel()
		if heroLevel < openLevel then
			self:showUnCreateLabel(openLevel)
			return false
		end
	end
	return true
end	

function MaterialStrongCell:showUnCreateLabel(level)
	local rewardLabel = createLabelWithStringFontSizeColorAndDimension(level..Config.Words[10218], "Arial", FSIZE("Size3"), FCOLOR("Yellow3"))
	self.rootNode:addChild(rewardLabel)
	VisibleRect:relativePosition(rewardLabel,  self.rootNode, LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER,ccp(-10,0))
end

function MaterialStrongCell:createTranInBtn(refId)
	local tranInBtn = createButtonWithFramename(RES("btn_1_select.png"))				
	self.rootNode:addChild(tranInBtn)
	VisibleRect:relativePosition(tranInBtn,self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE ,ccp(-14,2))
	local tranInBtnWord = createSpriteWithFrameName(RES("word_enter.png"))				
	tranInBtn:setTitleString(tranInBtnWord)
	local tranInBtnfunc = function ()
		self:clickTranInBtn(refId)
		GlobalEventSystem:Fire(GameEvent.EventCloseStrongerView)
	end
	tranInBtn:addTargetWithActionForControlEvents(tranInBtnfunc, CCControlEventTouchDown)
end

function MaterialStrongCell:crateNormalBtn(refId)	
	local goBtn = createButtonWithFramename(RES("btn_1_select.png"))				
	self.rootNode:addChild(goBtn)
	VisibleRect:relativePosition(goBtn,self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE ,ccp(-14,2))
	local goBtnWord = createSpriteWithFrameName(RES("world_boss_goto_label.png"))				
	goBtn:setTitleString(goBtnWord)
	local goBtnfunc = function ()
		self:clickGoBtn(refId)
		--GlobalEventSystem:Fire(GameEvent.EventCloseStrongerView)
	end
	goBtn:addTargetWithActionForControlEvents(goBtnfunc, CCControlEventTouchDown)
	
	local flyShopBtn = createButtonWithFramename(RES("map_shoes.png"))				
	self.rootNode:addChild(flyShopBtn)
	VisibleRect:relativePosition(flyShopBtn,goBtn, LAYOUT_CENTER + LAYOUT_LEFT_OUTSIDE ,ccp(-10,0))	
	local flyShopBtnfunc = function ()
		self:clickFlyShopBtn(refId)
		GlobalEventSystem:Fire(GameEvent.EventCloseStrongerView)
	end
	flyShopBtn:addTargetWithActionForControlEvents(flyShopBtnfunc, CCControlEventTouchDown)	
end

function MaterialStrongCell:clickTranInBtn(refId)
	local channel = self.srongerMgr:getStaticData_MaterialChannel(refId)
	local content = self.srongerMgr:getStaticData_MaterialContent(refId)
	
	if channel== StrongerChannel.ZhengMoTa or channel== StrongerChannel.Instance then --镇魔塔、副本
		local insRefid = content.insId
		if not insRefid then
			return
		end
		local instanceManager = GameWorld.Instance:getGameInstanceManager()
		local obj = instanceManager:getGameInstanceObj(insRefid)
		if not obj then
			return
		end
		local id = obj:getId()
		instanceManager:requesEnterGameInstance(id)
	elseif channel== StrongerChannel.Arena then	--竞技场
		GlobalEventSystem:Fire(GameEvent.EventOpenArenaView)
	elseif channel== StrongerChannel.Mining then --挖矿活动
		GlobalEventSystem:Fire(GameEvent.EventActivityClick, "activity_manage_7")
	elseif channel== StrongerChannel.monstInvasion then --怪物入侵活动
		GlobalEventSystem:Fire(GameEvent.EventActivityClick, "activity_manage_6")
	end
end

function MaterialStrongCell:clickGoBtn(refId)
	local channel = self.srongerMgr:getStaticData_MaterialChannel(refId)
	local content = self.srongerMgr:getStaticData_MaterialContent(refId)
	
	if channel== StrongerChannel.DailyQuest then--日常任务	
		local questId = content.questId
		if not questId then
			return
		end	
		local questObj = G_getQuestMgr():getQuestObj(questId) 
		if not questObj then
			return
		end
		local questState = questObj:getQuestState()
		G_getQuestLogicMgr():autoDoDailyQuest(questId)
	elseif channel== StrongerChannel.HandUpPoint or channel== StrongerChannel.Boss or channel== StrongerChannel.eliteMonster then--挂机点、BOSS、精英怪
		local monsterId = content.monsterId
		local sceneId = content.sceneId
		if not monsterId or not sceneId then
			return
		end
		
		G_getQuestLogicMgr():AutoPathFindMonster(monsterId[1],sceneId)
	end
end

function MaterialStrongCell:clickFlyShopBtn(refId)
	local transferSceneRefid = nil
	local transferPos = nil	
	
	local channel = self.srongerMgr:getStaticData_MaterialChannel(refId)
	local content = self.srongerMgr:getStaticData_MaterialContent(refId)
		
	if channel== StrongerChannel.DailyQuest then--日常任务
		local questId = content.questId
		if not questId then
			return
		end
		transferSceneRefid,transferPos = G_getQuestLogicMgr():getTransferByDailyQuest(questId)
	elseif channel== StrongerChannel.HandUpPoint or channel== StrongerChannel.eliteMonster then--挂机点、精英怪
		local monsterId = content.monsterId
		transferSceneRefid = content.sceneId
		if not monsterId or not transferSceneRefid then
			return
		end						
		transferPos = G_getMonsterPosByOrderRefidAndSceneRefid(monsterId[1],transferSceneRefid)
	elseif channel== StrongerChannel.Boss then--BOSS
		transferSceneRefid = content.sceneTranferInId
		local tranferInId = content.tranferInId
		if not tranferInId or not transferSceneRefid then
			return
		end
		GameWorld.Instance:getAutoPathManager():requestTeleportTransferIn(transferSceneRefid,tranferInId)
	end		
	
	if transferSceneRefid and transferPos then
		GameWorld.Instance:getMapManager():requestTransfer(transferSceneRefid, transferPos.x,transferPos.y,1)
		G_getHandupMgr():stop(false)
	end	
end