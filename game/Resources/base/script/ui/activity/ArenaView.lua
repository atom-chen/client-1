require("ui.UIManager")
require("common.BaseUI")

ArenaView = ArenaView or BaseClass(BaseUI)

local ProfessionGenderPicture = {
	[1] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderMale , tImage = "main_headManWarior.png", offset = ccp(-1,-5)},
	[2] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderFemale , tImage = "main_headFemanWarior.png", offset = ccp(6,2)},
	[3] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderMale , tImage = "main_headManMagic.png", offset = ccp(0,-6)},
	[4] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderFemale , tImage = "main_headFemanMagic.png", offset = ccp(1,-3)},
	[5] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderMale , tImage = "main_headManDaoshi.png", offset = ccp(0,5)},
	[6] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderFemale , tImage = "main_headFemanDaoshi.png", offset = ccp(0,5)}
}

local cellSize = VisibleRect:getScaleSize(CCSizeMake(600,30))

function ArenaView:__init()
	self.viewName = "ArenaView"		
	
	local ArenaMgr = GameWorld.Instance:getArenaMgr()
	self.arenaObject = ArenaMgr:getArenaObject()
	
	self.heroInfoArea = {}
	self.prizeArea = nil
	self.receiveRewardTime = nil
	self.noticeBoardArea = nil
	self.challengeTargetArea = {
		member = {
			[1] = {bg = nil, profession = nil, rank = nil, name = nil, level = nil, fighting = nil},
			[2] = {bg = nil, profession = nil, rank = nil, name = nil, level = nil, fighting = nil},
			[3] = {bg = nil, profession = nil, rank = nil, name = nil, level = nil, fighting = nil},
			[4] = {bg = nil, profession = nil, rank = nil, name = nil, level = nil, fighting = nil},
			[5] = {bg = nil, profession = nil, rank = nil, name = nil, level = nil, fighting = nil}
		},
		cdTime = nil
	}
	self.fightingRecordArea = nil
	self.rebackCDTimerId = -1
	self.rebackRewardTimerId = -1
	self:initWindow()
	self:initLayer()
	self.selectMember = nil
end

function ArenaView:__delete()
	if self.heroProfessionIdNode then
		self.heroProfessionIdNode:removeFromParentAndCleanup(true)
		self.heroProfessionIdNode = nil
	end
	if self.rebackCDTimerId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackCDTimerId)
		self.rebackCDTimerId = -1
	end
	if self.rebackRewardTimerId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackRewardTimerId)
		self.rebackRewardTimerId = -1
	end
end

function ArenaView:create()
	return ArenaView.New()
end

function ArenaView:onEnter()
	if G_getHero():isMoving() then
		G_getHero():sysHeroLocation()
	end
	G_getHero():forceStop()
	local autoPath = GameWorld.Instance:getAutoPathManager()
	autoPath:cancel()
	G_getHandupMgr():stop()
end

--onExit不能删，需引导活动指引
function ArenaView:onExit()

end

function ArenaView:initWindow()
	self:initFullScreen()
	
	local wholeBg = createScale9SpriteWithFrameName(RES("squares_bg2.png"))
	wholeBg:setContentSize(CCSizeMake(832, 480))
	self:addChild(wholeBg)
	VisibleRect:relativePosition(wholeBg,self:getContentNode(),LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,0))
	
	local titleSign = createSpriteWithFrameName(RES("main_activityHonor.png"))
	self:setFormImage(titleSign)
	local titleName = createSpriteWithFrameName(RES("word_window_arenaTitleName.png"))
	self:setFormTitle(titleName, TitleAlign.Left)

	self.leftBg = createScale9SpriteWithFrameName(RES("squares_bg3.png"))
	self.leftBg:setContentSize(CCSizeMake(200,466))
	wholeBg:addChild(self.leftBg)
	VisibleRect:relativePosition(self.leftBg,wholeBg,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(8,0))
	self:initLeft()
	
	self.rightTopNode = createScale9SpriteWithFrameName(RES("squares_bg3.png"))
	self.rightTopNode:setContentSize(CCSizeMake(613,320))	
	wholeBg:addChild(self.rightTopNode)
	VisibleRect:relativePosition(self.rightTopNode,wholeBg,LAYOUT_RIGHT_INSIDE,ccp(-8,0))
	VisibleRect:relativePosition(self.rightTopNode, self.leftBg, LAYOUT_TOP_INSIDE)
	self:initRightTop()
	
	self.rightBottomNode = createScale9SpriteWithFrameName(RES("squares_bg3.png"))
	self.rightBottomNode:setContentSize(CCSizeMake(614,140))	
	wholeBg:addChild(self.rightBottomNode)
	VisibleRect:relativePosition(self.rightBottomNode,wholeBg,LAYOUT_RIGHT_INSIDE,ccp(-8,0))
	VisibleRect:relativePosition(self.rightBottomNode, self.leftBg, LAYOUT_BOTTOM_INSIDE)
	self:initRightBottom()
end

function ArenaView:initLeft()
	local heroObj = GameWorld.Instance:getEntityManager():getHero()

	self.heroProfessionBg = createSpriteWithFrameName(RES("ins_clickFrame.png"))
	self.leftBg:addChild(self.heroProfessionBg)
	VisibleRect:relativePosition(self.heroProfessionBg,self.leftBg,LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X,ccp(0,-6))

	------------------个人基础信息-----------------------
	local heroProfessionId = PropertyDictionary:get_professionId(heroObj:getPT())
	local genderId = PropertyDictionary:get_gender(heroObj:getPT())
	local professionGenderPicture
	local offset
	for k,v in pairs(ProfessionGenderPicture) do
		if (v.tProfession and v.tGender) and v.tProfession == heroProfessionId and v.tGender == genderId then
			professionGenderPicture = v.tImage
			offset = v.offset
			break
		end	
	end
	if professionGenderPicture then
		self.heroProfessionIdNode = createSpriteWithFrameName(RES(professionGenderPicture))
		self.heroProfessionBg:addChild(self.heroProfessionIdNode)
		VisibleRect:relativePosition(self.heroProfessionIdNode,self.heroProfessionBg, LAYOUT_CENTER, ccp(offset.x,-4+offset.y))
	end
	
	local nameBg = createScale9SpriteWithFrameNameAndSize(RES("skill_skillBg.png"),CCSizeMake(150,30))
	self.heroProfessionBg:addChild(nameBg)
	VisibleRect:relativePosition(nameBg,self.heroProfessionBg,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER_X,ccp(0,-5))
	
	local heroName = PropertyDictionary:get_name(heroObj:getPT())
	self.heroNameNode = createLabelWithStringFontSizeColorAndDimension(heroName,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"),CCSizeMake(0,0))
	nameBg:addChild(self.heroNameNode)
	VisibleRect:relativePosition(self.heroNameNode,nameBg, LAYOUT_CENTER)

	local levelBg = createSpriteWithFrameName(RES("arenaLevelCircle.png"))
	self.leftBg:addChild(levelBg)
	VisibleRect:relativePosition(levelBg,self.leftBg,LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-30,-15))
	
	local heroLevel = PropertyDictionary:get_level(heroObj:getPT())
	self.heroLevelNode = createLabelWithStringFontSizeColorAndDimension(heroLevel,"Arial",15,FCOLOR("ColorWhite1"),CCSizeMake(0,0))
	levelBg:addChild(self.heroLevelNode)
	VisibleRect:relativePosition(self.heroLevelNode,levelBg, LAYOUT_CENTER)
	------------------个人天梯信息-----------------------
	self.heroInfoArea = createRichLabel(CCSizeMake(150,0))
	self.heroInfoArea:setAnchorPoint(ccp(0.5,0.5))
	self.heroInfoArea:setGaps(2)
	self.heroInfoArea:clearAll()
	
	self.leftBg:addChild(self.heroInfoArea)
	VisibleRect:relativePosition(self.heroInfoArea,self.leftBg, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(85,-280))
	
	self.rankBg = createSpriteWithFrameName(RES("arenaRankLable.png"))
	self.leftBg:addChild(self.rankBg)
	VisibleRect:relativePosition(self.rankBg,self.leftBg,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(3,-192))
	
	self.fightBg = createSpriteWithFrameName(RES("arenaFightLable.png"))
	self.leftBg:addChild(self.fightBg)
	VisibleRect:relativePosition(self.fightBg,self.leftBg,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(3,-217))
	
	-------------------分割线----------------------	
	local line = createSpriteWithFrameName(RES("talisman_propertyBg.png"))
	line:setScaleX(0.3)
	line:setScaleY(0.5)
	self.leftBg:addChild(line)
	VisibleRect:relativePosition(line,self.leftBg,LAYOUT_CENTER,ccp(0,-75))	
	
	-------------------奖励区域----------------------	
	self.prizeArea = createRichLabel(CCSizeMake(150,0))
	self.prizeArea:setAnchorPoint(ccp(0.5,0.5))
	self.prizeArea:setGaps(2)
	self.prizeArea:setFontSize(FSIZE("Size3"))
	self.prizeArea:clearAll()
	self.leftBg:addChild(self.prizeArea)
	VisibleRect:relativePosition(self.prizeArea,self.leftBg, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(85,-370))
	-------------------领取奖励时间----------------------	
	self.receiveRewardTime = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"),CCSizeMake(170,0))
	self.prizeArea:setAnchorPoint(ccp(0.5,0.5))
	self.leftBg:addChild(self.receiveRewardTime)
	VisibleRect:relativePosition(self.receiveRewardTime, self.fightBg, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER,ccp(56,-175))

	--------------------领取奖励按钮---------------------
	local receiveAwardFunction = function()
		GlobalEventSystem:Fire(GameEvent.EventReceiveReward)
		GlobalEventSystem:Fire(GameEvent.EventRequireCanReceive)
	end
	
	self.receiveAwardBtn = createButtonWithFramename(RES("btn_1_select.png"))
	self.leftBg:addChild(self.receiveAwardBtn)
	VisibleRect:relativePosition(self.receiveAwardBtn, self.leftBg, LAYOUT_TOP_INSIDE+LAYOUT_CENTER, ccp(0, -395))
	self.receiveAwardBtn:addTargetWithActionForControlEvents(receiveAwardFunction,CCControlEventTouchDown)
	local receiveAwardLable = createSpriteWithFrameName(RES("word_button_receive.png"))
	self.receiveAwardBtn:setTitleString(receiveAwardLable)
	VisibleRect:relativePosition(receiveAwardLable, self.receiveAwardBtn, LAYOUT_CENTER)
		
	self.rebackRewardTimerFunc = function()
		local ArenaMgr = GameWorld.Instance:getArenaMgr()
		local arenaObject = ArenaMgr:getArenaObject()
		if not arenaObject or not arenaObject.prizeArea.leftTime then
			return
		end
		if arenaObject.prizeArea.leftTime <= 1 then
			if self.rebackRewardTimerId ~= -1 then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackRewardTimerId)
				self.rebackRewardTimerId = -1
			end
			self.receiveAwardBtn:setVisible(true)
			self.receiveRewardTime:setVisible(false)
		else
			arenaObject.prizeArea.leftTime = arenaObject.prizeArea.leftTime - 1
			self:updateReceiveRewardTime()
		end
	end
end

function ArenaView:initRightTop()
	--------------------公告栏---------------------	
	local noticeBoardArea = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"),CCSizeMake(450,60))
	self.rightTopNode:addChild(noticeBoardArea)
	VisibleRect:relativePosition(noticeBoardArea,self.rightTopNode,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER,ccp(-85,10))
	
	self.noticeBoardArea = createRichLabel(CCSizeMake(0,0))
	self.noticeBoardArea:setAnchorPoint(ccp(0.5,0.5))	
	noticeBoardArea:addChild(self.noticeBoardArea)
	VisibleRect:relativePosition(self.noticeBoardArea,noticeBoardArea, LAYOUT_CENTER)
	--------------------天梯排名按钮---------------------	
	local seeLadderFunction = function()
		GlobalEventSystem:Fire(GameEvent.EventOpenLadderView)
	end
	
	local seeLadderBtn = createButtonWithFramename(RES("btn_1_select.png"))		
	G_setScale(seeLadderBtn)
	--seeLadderBtn:setScaleY(0.5)
	self.rightTopNode:addChild(seeLadderBtn)
	VisibleRect:relativePosition(seeLadderBtn, self.rightTopNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-6, 10))
	local seeLadderLable = createSpriteWithFrameName(RES("view_tianti_ranking.png"))
	seeLadderBtn:setTitleString(seeLadderLable)
	VisibleRect:relativePosition(seeLadderLable, seeLadderBtn, LAYOUT_CENTER)
	seeLadderBtn:addTargetWithActionForControlEvents(seeLadderFunction,CCControlEventTouchDown)
	--------------------挑战目标---------------------
	local ArenaMgr = GameWorld.Instance:getArenaMgr()
	local arenaObject = ArenaMgr:getArenaObject()
	if arenaObject == nil then
		return
	end
	for i = 1,5 do
		local selectMemberFunction = function()
			self:clickChallengeTargetAreaBtnByIndex(i)
			self.selectMember = i
			
			if arenaObject.challengeTargetArea.cdTime and arenaObject.challengeTargetArea.cdTime > 0 then
				local leftTime = arenaObject:getLeftChallengeCnt()
				if leftTime and leftTime > 0 then
					--弹出界面
					if self.layer then
						self.layer:setVisible(true)
						self:updateCDClearWindow()
						self.initCDTimerClearWindow:setVisible(true)
					end	
				else					
					UIManager.Instance:showSystemTips(Config.Words[16045])
				end
			else
				GlobalEventSystem:Fire(GameEvent.EventChallenge,arenaObject.challengeTargetArea.member[i].rank)
			end
		end
		
		self.challengeTargetArea.member[i].bg = createButtonWithFramename(RES("sevenLoginFrame.png"),RES("sevenLoginFrame.png"),CCSizeMake(120,200))
		self.challengeTargetArea.member[i].bg:setContentSize(CCSizeMake(120,200))
		self.challengeTargetArea.member[i].bg:setVisible(false)
		self.challengeTargetArea.member[i].bg:addTargetWithActionForControlEvents(selectMemberFunction,CCControlEventTouchDown)
		self.rightTopNode:addChild(self.challengeTargetArea.member[i].bg)
		VisibleRect:relativePosition(self.challengeTargetArea.member[i].bg,self.rightTopNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(7+(i-1)*120,-10))
		
		self.challengeTargetArea.member[i].heroProfessionBg = createSpriteWithFrameName(RES("ins_clickFrame.png"))
		self.challengeTargetArea.member[i].bg:addChild(self.challengeTargetArea.member[i].heroProfessionBg)
		VisibleRect:relativePosition(self.challengeTargetArea.member[i].heroProfessionBg,self.challengeTargetArea.member[i].bg,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER,ccp(0,60))

		self.challengeTargetArea.member[i].levelBg = createSpriteWithFrameName(RES("arenaLevelCircle.png"))
		self.challengeTargetArea.member[i].bg:addChild(self.challengeTargetArea.member[i].levelBg)
		VisibleRect:relativePosition(self.challengeTargetArea.member[i].levelBg,self.challengeTargetArea.member[i].bg,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(40,-5))

		self.challengeTargetArea.member[i].level = createLabelWithStringFontSizeColorAndDimension("","Arial", FSIZE("Size2"),FCOLOR("ColorWhite1"))
		self.challengeTargetArea.member[i].level:setAnchorPoint(ccp(0.5,0.5))
		self.challengeTargetArea.member[i].levelBg:addChild(self.challengeTargetArea.member[i].level)
		VisibleRect:relativePosition(self.challengeTargetArea.member[i].level,self.challengeTargetArea.member[i].levelBg, LAYOUT_CENTER)

		self.challengeTargetArea.member[i].name = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size2"),FCOLOR("ColorOrange1"))
		self.challengeTargetArea.member[i].name:setAnchorPoint(ccp(0,0.5))
		self.challengeTargetArea.member[i].bg:addChild(self.challengeTargetArea.member[i].name)
		VisibleRect:relativePosition(self.challengeTargetArea.member[i].name,self.challengeTargetArea.member[i].bg, LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(15,55))

		local rankLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[16001],"Arial",FSIZE("Size2"),FCOLOR("ColorYellow2"))
		rankLable:setAnchorPoint(ccp(0,0.5))
		self.challengeTargetArea.member[i].bg:addChild(rankLable)
		VisibleRect:relativePosition(rankLable,self.challengeTargetArea.member[i].bg, LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(15,26))

		self.challengeTargetArea.member[i].rank = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size2"),FCOLOR("ColorWhite2"))
		self.challengeTargetArea.member[i].rank:setAnchorPoint(ccp(0,0.5))
		self.challengeTargetArea.member[i].bg:addChild(self.challengeTargetArea.member[i].rank)
		VisibleRect:relativePosition(self.challengeTargetArea.member[i].rank,self.challengeTargetArea.member[i].bg, LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(62,36))

		local fightLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[16002],"Arial",FSIZE("Size2"),FCOLOR("ColorYellow2"))
		fightLable:setAnchorPoint(ccp(0,0.5))
		self.challengeTargetArea.member[i].bg:addChild(fightLable)
		VisibleRect:relativePosition(fightLable,self.challengeTargetArea.member[i].bg, LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(15,6))

		self.challengeTargetArea.member[i].fighting = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size2"),FCOLOR("ColorWhite2"))
		self.challengeTargetArea.member[i].fighting:setAnchorPoint(ccp(0,0.5))
		self.challengeTargetArea.member[i].bg:addChild(self.challengeTargetArea.member[i].fighting)
		VisibleRect:relativePosition(self.challengeTargetArea.member[i].fighting,self.challengeTargetArea.member[i].bg, LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(62,16))
	end	
	self:updateChallengeTargetArea()
		
	--------------------挑战CD时间---------------------	
	self.cdTimeNode = createScale9SpriteWithFrameName(RES("talisman_bg.png"))
	self.cdTimeNode:setContentSize(CCSizeMake(100,36))
	self.rightTopNode:addChild(self.cdTimeNode)
	VisibleRect:relativePosition(self.cdTimeNode,self.rightTopNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER,ccp(-25,70))
	
	self.challengeTargetArea.cdTime = createLabelWithStringFontSizeColorAndDimension("","Arial",20,FCOLOR("ColorGreen1"),CCSizeMake(0,0))
	self.cdTimeNode:addChild(self.challengeTargetArea.cdTime)
	VisibleRect:relativePosition(self.challengeTargetArea.cdTime,self.cdTimeNode, LAYOUT_CENTER,ccp(0,0))
	
	--------------------挑战CD清除按钮---------------------	
	local clearCDTimerFunction = function()
		--弹出界面
		local cdTime = arenaObject.challengeTargetArea.cdTime
		if cdTime and cdTime > 0 then
			if self.layer then
				self.selectMember = nil
				self.layer:setVisible(true)
				self:updateCDClearWindow()
				self.initCDTimerClearWindow:setVisible(true)
			end
		end	
	end	
	
	self.clearCDTimerBtn = createButtonWithFramename(RES("btn_1_select.png"))
	self.clearCDTimerBtn:setScaleDef(0.6)
	self.clearCDTimerBtn:addTargetWithActionForControlEvents(clearCDTimerFunction,CCControlEventTouchDown)
	self.cdTimeNode:addChild(self.clearCDTimerBtn)
	VisibleRect:relativePosition(self.clearCDTimerBtn,self.cdTimeNode, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(0,0))
	
	local twoTriangle = createSpriteWithFrameName(RES("arenaTriangle.png"))
	self.clearCDTimerBtn:addChild(twoTriangle)
	VisibleRect:relativePosition(twoTriangle,self.clearCDTimerBtn, LAYOUT_CENTER)
end

function ArenaView:initRightBottom()
	local function dataHandler(eventType,tableP,index,data)
		local data = tolua.cast(data,"SFTableData")
		local tableP = tolua.cast(tableP, "SFTableView")
		local cellSize = VisibleRect:getScaleSize(CCSizeMake(600,40))
			
		if eventType == 0 then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == 1 then				-- TableView的大小
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == 2 then				-- TableView中的cell内容
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createFightRecordCell(index)
				cell:addChild(item)
				VisibleRect:relativePosition(item,cell,LAYOUT_CENTER)
				cell:setIndex(index)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				tableCell:setIndex(index)
				local item = self:createFightRecordCell(index)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == 3 then				-- TableView中的cell数量
			local ArenaMgr = GameWorld.Instance:getArenaMgr()
			local arenaObject = ArenaMgr:getArenaObject()
			if arenaObject then
				data:setIndex(table.getn(arenaObject.fightingRecordArea.record))
			end
			return 1
		end
	end
		
	local tableDelegate = function (tableP,cell,x,y)
	end
		
	self.fightingRecordArea = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(600, 120)))	
	self.fightingRecordArea:setTableViewHandler(tableDelegate)
	self.fightingRecordArea:reloadData()
	self.fightingRecordArea:scroll2Cell(0, false)  --回滚到第一个cell
	self.rightBottomNode:addChild(self.fightingRecordArea)
	VisibleRect:relativePosition(self.fightingRecordArea, self.rightBottomNode, LAYOUT_CENTER)	
	end

function ArenaView:createFightRecordCell(index)
	local cellNode = CCNode:create()
	cellNode:setContentSize(cellSize)
	
	local cellBg = createScale9SpriteWithFrameNameAndSize(RES("left_line.png"),CCSizeMake(600,2))
	--cellBg:setAnchorPoint(ccp(0.5,0.5))
	cellNode:addChild(cellBg)
	VisibleRect:relativePosition(cellBg,cellNode,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER)	
	
	local text = self:createFightingRecordText(index+1)
	cellNode:addChild(text)
	VisibleRect:relativePosition(text, cellNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER,ccp(10,0))
		
	return cellNode
end		

function ArenaView:createFightingRecordText(index)
	local textNode = createRichLabel()
	textNode:clearAll()
	local staticColor = Config.FontColor["ColorWhite2"]
	local staticSize = FSIZE("Size3")
	local ArenaMgr = GameWorld.Instance:getArenaMgr()
	local arenaObject = ArenaMgr:getArenaObject()
	if arenaObject == nil then
		return
	end		
	if arenaObject.fightingRecordArea.record[index].isAction and arenaObject.fightingRecordArea.record[index].isAction == 0 then	
		textNode:appendFormatText(string.wrapHyperLinkRich(Config.Words[16017], staticColor, staticSize, nil, "false"))
		if self.selectMember then
			textNode:appendFormatText(string.wrapHyperLinkRich(arenaObject.challengeTargetArea.member[self.selectMember].name, Config.FontColor["ColorBlue2"], staticSize, nil, "false"))
			self.selectMember = nil
		else
			textNode:appendFormatText(string.wrapHyperLinkRich(arenaObject.fightingRecordArea.record[index].targetName, Config.FontColor["ColorBlue2"], staticSize, nil, "false"))
		end
		textNode:appendFormatText(string.wrapHyperLinkRich(Config.Words[16018], staticColor, staticSize, nil, "false"))
	elseif arenaObject.fightingRecordArea.record[index].isAction and arenaObject.fightingRecordArea.record[index].isAction == 1 then
		textNode:appendFormatText(string.wrapHyperLinkRich(arenaObject.fightingRecordArea.record[index].targetName, Config.FontColor["ColorBlue2"], staticSize, nil, "false"))
		textNode:appendFormatText(string.wrapHyperLinkRich(Config.Words[16019], staticColor, staticSize, nil, "false"))
	end
	if arenaObject.fightingRecordArea.record[index].fightingResult and arenaObject.fightingRecordArea.record[index].fightingResult == 0 then
		textNode:appendFormatText(string.wrapHyperLinkRich(Config.Words[16020], Config.FontColor["ColorRed1"], staticSize, nil, "false"))
	elseif arenaObject.fightingRecordArea.record[index].fightingResult and arenaObject.fightingRecordArea.record[index].fightingResult == 1 then
		textNode:appendFormatText(string.wrapHyperLinkRich(Config.Words[16021], Config.FontColor["ColorGreen1"], staticSize, nil, "false"))
	end
	if arenaObject.fightingRecordArea.record[index].rankChange and arenaObject.fightingRecordArea.record[index].rankChange < 0 then
		textNode:appendFormatText(string.wrapHyperLinkRich(Config.Words[16022], staticColor, staticSize, nil, "false"))
		textNode:appendFormatText(string.wrapHyperLinkRich(tostring(arenaObject.fightingRecordArea.record[index].rankChange*(-1)), Config.FontColor["ColorWhite1"], staticSize, nil, "false"))
	elseif arenaObject.fightingRecordArea.record[index].rankChange and arenaObject.fightingRecordArea.record[index].rankChange == 0 then
		textNode:appendFormatText(string.wrapHyperLinkRich(Config.Words[16023], staticColor,staticSize, nil, "false"))
	elseif arenaObject.fightingRecordArea.record[index].rankChange and arenaObject.fightingRecordArea.record[index].rankChange > 0 then
		textNode:appendFormatText(string.wrapHyperLinkRich(Config.Words[16024], staticColor, staticSize, nil, "false"))
		textNode:appendFormatText(string.wrapHyperLinkRich(tostring(arenaObject.fightingRecordArea.record[index].rankChange), Config.FontColor["ColorWhite1"], staticSize, nil, "false"))
	end
	return textNode
end

function ArenaView:updateHeroInfoArea()
	local heroObj = GameWorld.Instance:getEntityManager():getHero()
	
	if self.heroProfessionIdNode == nil then
		local heroProfessionId = PropertyDictionary:get_professionId(heroObj:getPT())
		local genderId = PropertyDictionary:get_gender(heroObj:getPT())
		local professionGenderPicture
		local offset
		for k,v in pairs(ProfessionGenderPicture) do
			if (v.tProfession and v.tGender) and v.tProfession == heroProfessionId and v.tGender == genderId then
				professionGenderPicture = v.tImage
				offset = v.offset
			end	
		end
		if professionGenderPicture then
			self.heroProfessionIdNode = createSpriteWithFrameName(RES(professionGenderPicture))
			self.heroProfessionBg:addChild(self.heroProfessionIdNode)
			VisibleRect:relativePosition(self.heroProfessionIdNode,self.heroProfessionBg, LAYOUT_CENTER, ccp(offset.x,-4+offset.y))
		end
	end		
	
	local heroName = PropertyDictionary:get_name(heroObj:getPT())
	self.heroNameNode:setString(heroName)
	
	local heroLevel = PropertyDictionary:get_level(heroObj:getPT())
  	self.heroLevelNode:setString(heroLevel)
	
	local ArenaMgr = GameWorld.Instance:getArenaMgr()
	local arenaObject = ArenaMgr:getArenaObject()
	if arenaObject == nil then
		return
	end	
	local rankWord = "1000+"
	if arenaObject.heroInfoArea.rank  and arenaObject.heroInfoArea.rank <= 1000 then
		rankWord = tostring(arenaObject.heroInfoArea.rank)
	end
	
	self.heroInfoArea:clearAll()
	
	if not self.rankTextLabel then
		self.rankTextLabel = createLabelWithStringFontSizeColorAndDimension(rankWord, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
		self.leftBg:addChild(self.rankTextLabel)
	else
		self.rankTextLabel:setString(rankWord)
	end
	if not self.fightTextLabel then
		self.fightTextLabel = createLabelWithStringFontSizeColorAndDimension(tostring(PropertyDictionary:get_fightValue(heroObj:getPT())), "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
		self.leftBg:addChild(self.fightTextLabel)
	else
		self.fightTextLabel:setString(tostring(PropertyDictionary:get_fightValue(heroObj:getPT())))
	end	
	VisibleRect:relativePosition(self.rankTextLabel, self.rankBg, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(10, 0))
	VisibleRect:relativePosition(self.fightTextLabel, self.fightBg, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(10, 0))
	
	self.heroInfoArea:appendFormatText(string.wrapHyperLinkRich(Config.Words[16003], Config.FontColor["ColorYellow2"], FSIZE("Size3"), nil, "false"))
	self.heroInfoArea:appendFormatText(string.wrapHyperLinkRich(arenaObject.heroInfoArea.victoryCnt.."\n", Config.FontColor["ColorBrown3"], FSIZE("Size3"), nil, "false"))
	self.heroInfoArea:appendFormatText(string.wrapHyperLinkRich(Config.Words[16004], Config.FontColor["ColorYellow2"], FSIZE("Size3"), nil, "false"))
	self.heroInfoArea:appendFormatText(string.wrapHyperLinkRich(arenaObject.heroInfoArea.leftChallengeCnt, Config.FontColor["ColorBrown3"], FSIZE("Size3"), nil, "false"))
	self.heroInfoArea:appendFormatText(string.wrapHyperLinkRich(Config.Words[16005].."\n", Config.FontColor["ColorYellow2"], FSIZE("Size3"), nil, "false"))	
	
	local leftTime = arenaObject:getLeftChallengeCnt()
	if leftTime and leftTime <= 0 then
		self:updateChallengeCDTime()
	end
end

function ArenaView:updatePrizeArea()
	local ArenaMgr = GameWorld.Instance:getArenaMgr()
	local arenaObject = ArenaMgr:getArenaObject()
	if arenaObject == nil then
		return
	end
	local  prizeAreaPt = arenaObject.prizeArea
	local prizeAreaText = ""	
	if not  prizeAreaPt.rewardRank then
		 prizeAreaPt.rewardRank = " "
	end
	if not  prizeAreaPt.gold then
		 prizeAreaPt.gold = " "
	end
	if not prizeAreaPt.exploit then
		prizeAreaPt.exploit = " "
	end	
	prizeAreaText = Config.Words[16006]..prizeAreaPt.rewardRank..Config.Words[16007].."\n"
	prizeAreaText = prizeAreaText..Config.Words[16008]..prizeAreaPt.gold.."\n"
	prizeAreaText = prizeAreaText..Config.Words[16009]..prizeAreaPt.exploit.."\n"	

	self.prizeArea:clearAll()
	self.prizeArea:appendFormatText(string.wrapHyperLinkRich(prizeAreaText, Config.FontColor["ColorYellow2"], FSIZE("Size3"), nil, "false"))
end

function ArenaView:updateNoticeBoardArea()
	self.noticeBoardArea:clearAll()
	local ArenaMgr = GameWorld.Instance:getArenaMgr()
	local arenaObject = ArenaMgr:getArenaObject()
	if arenaObject == nil then
		return
	end
	local noticeType = arenaObject.noticeBoardArea.noticeType
	if noticeType and  noticeType>0 and noticeType<4 then
		self.noticeBoardArea:appendFormatText(string.wrapHyperLinkRich(Config.Words[16011], Config.FontColor["ColorWhite1"], FSIZE("Size4"), nil, "false"))		
		if noticeType == 1 then
			self.noticeBoardArea:appendFormatText(string.wrapHyperLinkRich(arenaObject.noticeBoardArea[noticeType].playerName, Config.FontColor["ColorBlue1"], FSIZE("Size4"), nil, "false"))
			self.noticeBoardArea:appendFormatText(string.wrapHyperLinkRich(Config.Words[16012], Config.FontColor["ColorWhite1"], FSIZE("Size4"), nil, "false"))
		elseif noticeType == 2 then
			self.noticeBoardArea:appendFormatText(string.wrapHyperLinkRich(arenaObject.noticeBoardArea[noticeType].playerAName, Config.FontColor["ColorBlue1"], FSIZE("Size4"), nil, "false"))
			self.noticeBoardArea:appendFormatText(string.wrapHyperLinkRich(Config.Words[16013], Config.FontColor["ColorWhite1"], FSIZE("Size4"), nil, "false"))
			self.noticeBoardArea:appendFormatText(string.wrapHyperLinkRich(arenaObject.noticeBoardArea[noticeType].playerBName, Config.FontColor["ColorBlue1"], FSIZE("Size4"), nil, "false"))
			self.noticeBoardArea:appendFormatText(string.wrapHyperLinkRich(Config.Words[16014], Config.FontColor["ColorWhite1"], FSIZE("Size4"), nil, "false"))
		elseif noticeType == 3 then
			self.noticeBoardArea:appendFormatText(string.wrapHyperLinkRich(arenaObject.noticeBoardArea[noticeType].playerName, Config.FontColor["ColorBlue1"], FSIZE("Size4"), nil, "false"))
			self.noticeBoardArea:appendFormatText(string.wrapHyperLinkRich(Config.Words[16015], Config.FontColor["ColorWhite1"], FSIZE("Size4"), nil, "false"))
			self.noticeBoardArea:appendFormatText(string.wrapHyperLinkRich(tostring(arenaObject.noticeBoardArea[noticeType].raiseRank), Config.FontColor["ColorYellow1"], FSIZE("Size4"), nil, "false"))
			self.noticeBoardArea:appendFormatText(string.wrapHyperLinkRich(Config.Words[16016], Config.FontColor["ColorWhite1"], FSIZE("Size4"), nil, "false"))
		end
	end
end

function ArenaView:updateChallengeTargetArea()
	local ArenaMgr = GameWorld.Instance:getArenaMgr()
	local arenaObject = ArenaMgr:getArenaObject()
	if arenaObject == nil then
		return
	end
	for i = 1,table.getn(arenaObject.challengeTargetArea.member) do			
		self.challengeTargetArea.member[i].bg:setVisible(true)
		
		if self.challengeTargetArea.member[i].profession then
			self.challengeTargetArea.member[i].profession:removeFromParentAndCleanup(true)
			self.challengeTargetArea.member[i].profession = nil
		end			
		
		local professionId = arenaObject.challengeTargetArea.member[i].profession
		local genderId = arenaObject.challengeTargetArea.member[i].gender
		local professionGenderPicture
		for k,v in pairs(ProfessionGenderPicture) do
			if (v.tProfession and v.tGender) and v.tProfession == professionId and v.tGender == genderId then
				professionGenderPicture = v.tImage
				offset = v.offset
			end
		end
		if professionGenderPicture then
			self.challengeTargetArea.member[i].profession = createSpriteWithFrameName(RES(professionGenderPicture))
			self.challengeTargetArea.member[i].heroProfessionBg:addChild(self.challengeTargetArea.member[i].profession)
			VisibleRect:relativePosition(self.challengeTargetArea.member[i].profession,self.challengeTargetArea.member[i].heroProfessionBg, LAYOUT_CENTER, ccp(offset.x,-4+offset.y))	

			
			local rankText = arenaObject.challengeTargetArea.member[i].rank
			self.challengeTargetArea.member[i].rank:setString(rankText)
			
			local nameText = arenaObject.challengeTargetArea.member[i].name
			self.challengeTargetArea.member[i].name:setString(nameText)
			
			local levelText = arenaObject.challengeTargetArea.member[i].level
			self.challengeTargetArea.member[i].level:setString(levelText)
			
			local fightingText = arenaObject.challengeTargetArea.member[i].fighting
			self.challengeTargetArea.member[i].fighting:setString(fightingText)
		end
	end
end

function ArenaView:updateReceiveRewardTime()
	local ArenaMgr = GameWorld.Instance:getArenaMgr()
	local arenaObject = ArenaMgr:getArenaObject()
	if arenaObject == nil then
		return
	end
	local hour = math.modf(arenaObject.prizeArea.leftTime/3600)
	local min = math.modf((arenaObject.prizeArea.leftTime-3600*hour)/60)
	local sec = arenaObject.prizeArea.leftTime-3600*hour-60*min
	local receiveRewardTimeText =  Config.Words[16010]..string.format("%02d:%02d:%02d",hour,min,sec)
	self.receiveRewardTime:setString(receiveRewardTimeText)
	
	if arenaObject.prizeArea.leftTime and  arenaObject.prizeArea.leftTime <= 0 then
		self.receiveAwardBtn:setVisible(true)
		self.receiveRewardTime:setVisible(false)
		GlobalEventSystem:Fire(GameEvent.EventHandleCanReceive,1)
	else
		self.receiveAwardBtn:setVisible(false)
		self.receiveRewardTime:setVisible(true)
		GlobalEventSystem:Fire(GameEvent.EventHandleCanReceive,0)
	end

	if self.rebackRewardTimerId and self.rebackRewardTimerId == -1 then
		self.rebackRewardTimerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.rebackRewardTimerFunc, 1, false)
	end
	VisibleRect:relativePosition(self.receiveRewardTime, self.fightBg, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER,ccp(56,-175))
end

function ArenaView:updateChallengeCDTime()
	local ArenaMgr = GameWorld.Instance:getArenaMgr()
	local arenaObject = ArenaMgr:getArenaObject()
	if arenaObject == nil then
		return
	end
	
	if arenaObject.heroInfoArea.victoryCnt then
		if arenaObject.heroInfoArea.victoryCnt <= 0 then
			self.cdTimeNode:setVisible(false)
			if self.rebackCDTimerId ~= -1 then	
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackCDTimerId)
				self.rebackCDTimerId = -1
			end
		end
	end
	if arenaObject.challengeTargetArea.cdTime then	
		local leftTime = arenaObject:getLeftChallengeCnt()
		if arenaObject.challengeTargetArea.cdTime == 0 or leftTime <= 0 then
			self.cdTimeNode:setVisible(false)
			if self.rebackCDTimerId ~= -1 then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackCDTimerId)
				self.rebackCDTimerId = -1
			end
		else
			self.rebackCDTimerFunc = function()
				if not arenaObject.challengeTargetArea.cdTime or arenaObject.challengeTargetArea.cdTime == 0 then
					self.cdTimeNode:setVisible(false)
					if self.rebackCDTimerId ~= -1 then	
						CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackCDTimerId)
						self.rebackCDTimerId = -1
					end
				else
					arenaObject.challengeTargetArea.cdTime = arenaObject.challengeTargetArea.cdTime - 1					
					local min = math.modf(arenaObject.challengeTargetArea.cdTime/60)
					local sec = arenaObject.challengeTargetArea.cdTime-60*min
					local challengeCDTimeText =  string.format("%02d:%02d",min,sec)
					self.challengeTargetArea.cdTime:setString(challengeCDTimeText)
				end	
			end
			if self.rebackCDTimerId == -1 then
				self.cdTimeNode:setVisible(true)
				self.rebackCDTimerId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.rebackCDTimerFunc, 1, false)
			end
		end
		local min = math.modf(arenaObject.challengeTargetArea.cdTime/60)
		local sec = arenaObject.challengeTargetArea.cdTime-60*min
		local challengeCDTimeText =  string.format("%02d:%02d",min,sec)
		self.challengeTargetArea.cdTime:setString(challengeCDTimeText)
	end
end

function ArenaView:updateFightingRecordArea()
	self.fightingRecordArea:reloadData()
	self.fightingRecordArea:scroll2Cell(0, false)  --回滚到第一个cell
end

-----------------------------------------------------------cd清除界面-----------------------------------------------------------

function ArenaView:initLayer()
	local touchArea = CCSizeMake(960,640)
	local function ccTouchHandler(eventType, x, y)
		return 1
	end
	self.layer = CCLayer:create()
	self.layer:setContentSize(touchArea)
	self.layer:setVisible(false)
	self:addChild(self.layer)
	VisibleRect:relativePosition(self.layer,self:getContentNode(), LAYOUT_CENTER)
	self.layer:setTouchEnabled(true)
	self.layer:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.LoadingHUD, true)
	
	self:initCDClearWindow()
end

function ArenaView:initCDClearWindow()
	self.initCDTimerClearWindow = createScale9SpriteWithFrameName(RES("squares_bg1.png"))
	self.initCDTimerClearWindow:setVisible(false)
	self.initCDTimerClearWindow:setContentSize(CCSizeMake(300, 150))
	self.layer:addChild(self.initCDTimerClearWindow)
	VisibleRect:relativePosition(self.initCDTimerClearWindow,self.layer,LAYOUT_CENTER)
	
	local yesFunction = function()
		self.layer:setVisible(false)
		self.initCDTimerClearWindow:setVisible(false)
		GlobalEventSystem:Fire(GameEvent.EventClearCDTime)
		local ArenaMgr = GameWorld.Instance:getArenaMgr()
		local arenaObject = ArenaMgr:getArenaObject()

		if arenaObject and self.selectMember then
			GlobalEventSystem:Fire(GameEvent.EventChallenge,arenaObject.challengeTargetArea.member[self.selectMember].rank)
		end
	end
	local yesBtn = createButtonWithFramename(RES("btn_1_select.png"))	
	yesBtn:setScaleDef(0.8)
	self.initCDTimerClearWindow:addChild(yesBtn)
	VisibleRect:relativePosition(yesBtn, self.initCDTimerClearWindow, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(25, 30))
	yesBtn:addTargetWithActionForControlEvents(yesFunction,CCControlEventTouchDown)
	local yesLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[16036],"Arial",25,FCOLOR("ColorWhite1"),CCSizeMake(0,0))
	yesBtn:setTitleString(yesLable)
	VisibleRect:relativePosition(yesLable, yesBtn, LAYOUT_CENTER)
	
	local noFunction = function()
		self.layer:setVisible(false)
		self.initCDTimerClearWindow:setVisible(false)
	end
	local noBtn = createButtonWithFramename(RES("btn_1_select.png"))	
	noBtn:setScaleDef(0.8)
	self.initCDTimerClearWindow:addChild(noBtn)
	VisibleRect:relativePosition(noBtn, self.initCDTimerClearWindow, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(-25, 30))
	noBtn:addTargetWithActionForControlEvents(noFunction,CCControlEventTouchDown)
	local yesLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[16037],"Arial",25,FCOLOR("ColorWhite1"),CCSizeMake(0,0))
	noBtn:setTitleString(yesLable)
	VisibleRect:relativePosition(yesLable, noBtn, LAYOUT_CENTER)
	
	self.contentLable = createLabelWithStringFontSizeColorAndDimension("","Arial",15,FCOLOR("ColorWhite1"))
	self.initCDTimerClearWindow:addChild(self.contentLable)
	VisibleRect:relativePosition(self.contentLable,self.initCDTimerClearWindow, LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-40))	
end	

function ArenaView:updateCDClearWindow()
	local ArenaMgr = GameWorld.Instance:getArenaMgr()
	local arenaObject = ArenaMgr:getArenaObject()
	if arenaObject and arenaObject.challengeTargetArea.cdTime then
		local goldNum = 10*math.ceil(arenaObject.challengeTargetArea.cdTime/60)
		self.contentLable:setString(Config.Words[16038]..goldNum..Config.Words[16039])
	end
end

function ArenaView:getChallengeTargetAreaBtnByIndex(index)
	if self.challengeTargetArea.member[index] then
		local btn = self.challengeTargetArea.member[index].bg
		return btn
	end
end

function ArenaView:clickChallengeTargetAreaBtnByIndex(index)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"ArenaView",index)
end