require("data.quest.plotQuest")
require"data.wing.wing"
require("data.item.propsItem")
require("data.quest.sectionQuest")
require"data.monster.monster"	

QuestView = QuestView or BaseClass(BaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()

function QuestView:__init()
	local viewSize = CCSizeMake((874),(563))
	self:init(viewSize)
	self.viewName = "QuestView"
	local questImage = createSpriteWithFrameName(RES("quest_titleImage.png"))
	self:setFormImage(questImage)
	local questTitle = createSpriteWithFrameName(RES("word_window_quest.png"))
	self:setFormTitle(questTitle, TitleAlign.Left)	
	self.scale = VisibleRect:SFGetScale()
	
	--self.ClickBtn = nil
	self.QuestMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	self.beforeQuestList = self.QuestMgr:getQuestList()
	self.questList = self:getShowQuestList(self.beforeQuestList)--获取任务列表
	
	self.squestIndex = nil --当前选中的任务项
	self.squestId = nil	-- 当前选择的任务Id
	self.squestState = nil --当前任务状态	
	
	self.rightView = nil
	self.squestLevelCell = nil
	self.starLevel = 0

	self.transferSceneRefid = nil
	self.transferPos = nil
	
	self.questListCount = table.size(self.questList)
	
	self.bigBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(833,489))
	self:addChild(self.bigBg)
	VisibleRect:relativePosition(self.bigBg,self:getContentNode(),LAYOUT_CENTER,ccp(0,0))
	
	self:initRightView()
	self:ShowTaskView()
	self:updateQuestView()	
end

function QuestView:__delete()
	
end

function QuestView:create()
	return QuestView.New()
end	

function QuestView:initRightView()
	local viewSize = CCSizeMake(522,478)
	
	if self.rightView then
		self.rightView:removeAllChildrenWithCleanup(true)
		self.rightView = nil
		self.rewordLable = nil
	end

	self.rightView = CCNode:create()
	self.rightView:setContentSize(viewSize)
	self:addChild(self.rightView)
	VisibleRect:relativePosition(self.rightView,self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-6,-9))	
	
	local rightViewbg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),viewSize)
	self.rightView:addChild(rightViewbg)
	VisibleRect:relativePosition(rightViewbg,self.rightView,LAYOUT_CENTER,ccp(0,0))
	
	--self.viewNodeBg = CCSprite:create("ui/ui_img/common/kraft_dungeon.png")	
	self.viewNodeBg = CCSprite:create()
	local viewNodeBgRight = CCSprite:create("ui/ui_img/common/kraft_bg.pvr")
	local viewNodeBgLeft = CCSprite:create("ui/ui_img/common/kraft_bg.pvr")
	viewNodeBgLeft:setFlipX(true)
	self.viewNodeBg:setContentSize(CCSizeMake(viewNodeBgRight:getContentSize().width*2,viewNodeBgRight:getContentSize().height))
	self.viewNodeBg:addChild(viewNodeBgLeft)
	self.viewNodeBg:addChild(viewNodeBgRight)
	VisibleRect:relativePosition(viewNodeBgLeft,self.viewNodeBg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))
	VisibleRect:relativePosition(viewNodeBgRight,self.viewNodeBg,LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))	
	self.viewNodeBg : setScaleX(1.0070)
	self.viewNodeBg : setScaleY(1.0273)
	self.rightView:addChild(self.viewNodeBg)
	self.viewNodeBg:setScaleX(0.61)
	self.viewNodeBg:setScaleY(1.0)
	VisibleRect:relativePosition(self.viewNodeBg,self.rightView,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE ,ccp(0,0))
	self.viewNodeBg2 = CCSprite:create("ui/ui_img/common/common_kraftRole.pvr")
	self.rightView:addChild(self.viewNodeBg2)
	VisibleRect:relativePosition(self.viewNodeBg2,self.rightView,LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE)
	
	local line = createScale9SpriteWithFrameName(RES("npc_dividLine.png"))
	line:setScaleX(1.5)
	local titlesize = CCSizeMake(viewSize.width,line:getContentSize().height)
	--line:setContentSize(titlesize)
	self.rightView:addChild(line)
	VisibleRect:relativePosition(line,self.rightView, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(20, -110))
	
end

function QuestView:onEnter()
	self.QuestMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	self.questList = self:getShowQuestList(self.QuestMgr:getQuestList())--获取任务列表
	self.questListCount = table.size(self.questList)
	self.tasktable:reloadData()	
	if self.questListCount == 0 then
		self:clearQuesetView()
	end
end	

function QuestView:updateQuestView()
	self.QuestMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	self.questList = self:getShowQuestList(self.QuestMgr:getQuestList())--获取任务列表
	self.questListCount = table.size(self.questList)	
	if self.questListCount~=0 then
		local questObj = self.QuestMgr:getQuestObj(self.squestId)
		if questObj==nil then
			if self.questListCount~=0 then
				if self.QuestMgr:getQuestView_ClickQuestIndex()==nil or self.QuestMgr:getQuestView_ClickQuestIndex()>self.questListCount then
					self.QuestMgr:setQuestView_ClickQuestIndex(1)
				end
				self.squestIndex = self.QuestMgr:getQuestView_ClickQuestIndex()
				--self.squestId = self.questList[self.squestIndex]:getQuestId()
			end
		else
			self.squestState = questObj:getQuestState()
		end
		if self.QuestMgr:getQuestView_ClickQuestIndex() > self.questListCount then
			self.QuestMgr:setQuestView_ClickQuestIndex(1)
			self.squestIndex = 1
			--self.squestId = self.questList[self.squestIndex]:getQuestId()
		end
	else
		self.squestIndex = nil --当前选中的任务项
		self.squestId = nil	-- 当前选择的任务Id
		self.squestState = nil --当前任务状态
	end
	if self.questListCount ~=0 then
		self.squestId = self.questList[self.squestIndex]:getQuestId()
		self:UpdateView(self.squestIndex,self.squestId)
	elseif self.questListCount == 0 then
		self:clearQuesetView()
	end
	self.tasktable:reloadData()	
end

function QuestView:updateOrder()
	self:ShowOrder(self.squestIndex,self.squestId)
end

function QuestView:onExit()

end

function QuestView:EventUpdateQuestLevel()
	local manager = UIManager.Instance
	local bShowView = manager:isShowing("QuestView")
	if bShowView==true then
		self.descriptiontable:reloadData()

		local word = Config.Words[3310]..tostring(self.starLevel)..Config.Words[328]
		manager:showSystemTips(word)
		
		if self.squestIndex and self.squestId then
			self:ShowReword(self.squestIndex,self.squestId)
		end		
	end		
end

function QuestView:UpdateView(questIndex,questId)
	if (not questIndex) or (not questId) then
		return
	end
	
	self.squestIndex = questIndex
	self.squestId = questId	
	self:ShowDescription(questIndex,questId)
	self:ShowOrder(questIndex,questId)
	self:ShowReword(questIndex,questId)
	self:ShowBtn(questIndex,questId)
end

function QuestView:ShowDescription(questIndex,questId)--任务描述
	if (not questIndex) or (not questId) then
		return
	end
	local viewSize = CCSizeMake(548*self.scale,85*self.scale)
	
	if self.descriptionLable then
		self.descriptionLable:removeFromParentAndCleanup(true)
		self.descriptionLable = nil
	end
	
	self.descriptionLable = CCNode:create()
	self.descriptionLable:setContentSize(viewSize)
	self.rightView:addChild(self.descriptionLable )
	VisibleRect:relativePosition(self.descriptionLable,self.rightView, LAYOUT_CENTER+LAYOUT_TOP_INSIDE ,ccp(0,0))
	
	local tablesize = viewSize
	local cellSize = tablesize
	
	self.questList = self:getShowQuestList(self.QuestMgr:getQuestList())--获取任务列表
	local questListCount = table.size(self.questList)
	if  questListCount==0 then
		return
	end
	--定义
	local	kTableCellSizeForIndex = 0
	local	kCellSizeForTable = 1
	local	kTableCellAtIndex = 2
	local	kNumberOfCellsInTableView = 3
	
	local dataHandlerfunc = function(eventType,tableP,index,data)
		tableP = tolua.cast(tableP,"SFTableView")
		data = tolua.cast(data,"SFTableData")
		if eventType == kTableCellSizeForIndex then
			data:setSize(cellSize)
			return 1
		elseif eventType == kCellSizeForTable then
			data:setSize(cellSize)
			return 1
		elseif eventType == kTableCellAtIndex then
			local cell = SFTableViewCell:create()
			cell:setContentSize(cellSize)
			cell:setIndex(index)
			
			if questIndex~=nil then
				local questObj = self.QuestMgr:getQuestObj(questId)
				if questObj~=nil then
					local questType = questObj:getQuestType()
					--questType=2
					if questType==QuestType.eQuestTypeMain then--主线任务
						self:MainQuestDescriptionCell(cell,questId)--显示主线描述内容
					elseif questType==QuestType.eQuestTypeDaily then--日常任务
						self:DailyQuestDescriptionCell(cell,questId)--显示日常描述内容
					end
				end
			end
			
			data:setCell(cell)
			return 1
		elseif eventType == kNumberOfCellsInTableView then
			data:setIndex(1)
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")
--		CCLuaLog(x.." "..y)
	end
	
	
	self.descriptiontable = createTableView(dataHandlerfunc,tablesize)
	self.descriptiontable:setTableViewHandler(tableDelegate)
	self.descriptionLable:addChild(self.descriptiontable)
	VisibleRect:relativePosition(self.descriptiontable,self.descriptionLable, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(0,-10))
	self.descriptiontable:reloadData()
	
	
end

--主线任务描述cell
function QuestView:MainQuestDescriptionCell(cell,questId)
	if (not cell) or (not questId) then
		return
	end
	
	local qType = self.QuestMgr:getQuestObj(questId):getQuestType()
	--替换字符串
	local descriptionWord = PropertyDictionary:get_description(QuestRefObj:getStaticQusetProperty(qType,questId))
	local strWord = G_QusetChangString(descriptionWord)
	strWord = string.wrapRich(strWord,Config.FontColor["ColorBlack1"],FSIZE("Size4"))
	--任务描述
	local questDescriptionEventHandler = function (eventWord)
		if eventWord == "S" then--场景名称
			
		elseif eventWord == "N" then--NPC名称
			
		end
	end
	local questDescription = createRichLabel(CCSizeMake(cell:getContentSize().width-20,10))
	questDescription:setFont(Config.fontName["fontName1"])
	questDescription:setEventHandler(questDescriptionEventHandler)
	questDescription:appendFormatText(strWord)
	cell:addChild(questDescription)
	VisibleRect:relativePosition(questDescription,cell,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER, ccp(30.0, 0.0))
end	

--日常任务等级cell
function QuestView:DailyQuestDescriptionCell(cell,questId)
	if (not cell) or (not questId) then
		return
	end
	local questObj = self.QuestMgr:getQuestObj(questId)
	local qType = questObj:getQuestType()
	
	local questSubType = QuestRefObj:getStaticDailyQusetSubType(questId)
	if questSubType~=DailyQuestSubType.eGoldQuest then--不为金币任务时显示刷任务等级
		--服务端获取等级数
		self.starLevel = questObj:getDailyLevel()
		local starNumber = math.floor((self.starLevel/2))
		local starHalf = self.starLevel%2
		local posX  = 10
		local offectX  = 20
		local offectY  = 38
		local scale = 0.7
		--星星底
		for i=1,5 do
			local starbg = createSpriteWithFrameName(RES("common_star.png"))
			UIControl:SpriteSetGray(starbg)
			starbg:setScale(scale)
			cell:addChild(starbg)
			VisibleRect:relativePosition(starbg,cell, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE  ,ccp(posX+offectY*(i-1)+offectX,-23))
		end
		
		--星星
		for i=1,starNumber do
			local starbg = createSpriteWithFrameName(RES("common_star.png"))
			starbg:setScale(scale)
			cell:addChild(starbg)
			VisibleRect:relativePosition(starbg,cell, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE  ,ccp(posX+offectY*(i-1)+offectX,-23))
		end
		
		if starHalf~=0 then--显示半颗星
			local starbg = createSpriteWithFrameName(RES("common_halfStar.png"))
			starbg:setScale(scale)
			cell:addChild(starbg)
			VisibleRect:relativePosition(starbg,cell, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE  ,ccp(posX+offectY*starNumber+offectX,-23))
		end
		
		
		--提示文字
		local questLevelWord = createLabelWithStringFontSizeColorAndDimension(Config.Words[3119],"Arial",FSIZE("Size2"),FCOLOR("ColorRed1"))
		cell:addChild(questLevelWord)
		VisibleRect:relativePosition(questLevelWord, cell, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(30, -65))
		
		local btnRefreshLevel = createButtonWithFramename(RES("btn_1_select.png"))
		btnRefreshLevel:setScale(self.scale)	
		cell:addChild(btnRefreshLevel)
		VisibleRect:relativePosition(btnRefreshLevel,cell, LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE ,ccp(-34,-28))
		
		local btnRefreshLevelfunc = function ()
			hero = GameWorld.Instance:getEntityManager():getHero()
			local gold = PropertyDictionary:get_gold(hero:getPT())
			if gold<20000 then --金币少于100000不发送，暂时写死
				UIManager.Instance:showSystemTips(Config.Words[3124])
			elseif self.starLevel==10 then
				UIManager.Instance:showSystemTips(Config.Words[3311])
			else
				self.QuestMgr:reDailyFreshQuestLevel(questId)--发送刷新任务等级
			end
		end
		btnRefreshLevel:addTargetWithActionForControlEvents(btnRefreshLevelfunc, CCControlEventTouchDown)
		
		local btnWord = createSpriteWithFrameName(RES("word_button_refreshlevel.png"))	
		btnRefreshLevel:addChild(btnWord)
		VisibleRect:relativePosition(btnWord, btnRefreshLevel, LAYOUT_CENTER)
	end
	
	
	
	--替换字符串
	local descriptionWord = PropertyDictionary:get_description(QuestRefObj:getStaticQusetProperty(qType,questId))
	local strWord = G_QusetChangString(descriptionWord)
	strWord = string.wrapRich(strWord,Config.FontColor["ColorBlack1"],FSIZE("Size3"))
	--任务描述
	local questDescriptionEventHandler = function (eventWord)
		if eventWord == "S" then--场景名称
			
		elseif eventWord == "N" then--NPC名称
			
		end
	end
	local questDescription = createRichLabel(CCSizeMake(300,10))
	questDescription:setFont(Config.fontName["fontName1"])
	questDescription:setEventHandler(questDescriptionEventHandler)
	questDescription:appendFormatText(strWord)
	cell:addChild(questDescription)
	VisibleRect:relativePosition(questDescription,cell,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(10.0, -70.0))
end

function QuestView:ShowOrder(questIndex,questId)--任务目标
	if (not questIndex) or (not questId) then
		return
	end	
	local viewSize = CCSizeMake(548*self.scale,50*self.scale)
	
	if self.Lable2 then
		self.Lable2:removeFromParentAndCleanup(true)
		self.Lable2 = nil
	end
	
	self.Lable2 = CCNode:create()
	self.Lable2:setContentSize(viewSize)
	self.rightView:addChild(self.Lable2 )
	VisibleRect:relativePosition(self.Lable2,self.rightView, LAYOUT_CENTER+LAYOUT_TOP_INSIDE ,ccp(0,-150-23))
	
	
	
	if questIndex~=nil then
		local questObj = self.QuestMgr:getQuestObj(questId)
		self.squestState =  questObj:getQuestState()
		local qType =questObj:getQuestType()
		
		--日常任务描述
		if qType==QuestType.eQuestTypeDaily then
			if self.squestState == QuestState.eAcceptedQuestState or self.squestState == QuestState.eSubmittableQuestState then
				self:dailyQuestDescription(self.Lable2,questObj)
			end
		end
		
		local questOrderword = ""		
		self.transferSceneRefid = nil
		self.transferPos = nil
		local npcRefid = nil
		local sceneRefid = nil
		if self.squestState == QuestState.eAcceptableQuestState then --任务可接				
			questOrderword,npcRefid,sceneRefid = self:setOrderFindNpcWord(questOrderword,qType,questId,"acceptNpc")		
				
			local orderPos = G_getNPCPosByOrderRefidAndSceneRefid(npcRefid,sceneRefid)													
			self.transferSceneRefid = sceneRefid
			self.transferPos = orderPos	
		elseif self.squestState == QuestState.eAcceptedQuestState  then --任务已接
			if qType==QuestType.eQuestTypeMain then--主线
				local orderNumber =  questObj:getOrderNumber()
				if orderNumber ~= nil then
					for j=1,orderNumber do
						local orderType = QuestRefObj:getStaticQusetOrderFieldType(qType,questId,j)
						local nowNumberValue =  questObj:getNumber(j)
						if orderType == QuestOrderType.eOrderTypeKill then --任务类型-杀怪
							local killNumberValue = QuestRefObj:getStaticQusetOrderFieldKillCount(qType,questId,j)
							if self.squestState == QuestState.eSubmittableQuestState then--已完成任务
								nowNumberValue = killNumberValue
								
								sceneRefid = QuestRefObj:getStaticQusetNpcFieldSceneRefId(questTypeValue,questRefId,"submitNpc")	
								npcRefid = QuestRefObj:getStaticQusetNpcFieldNcRefId(questTypeValue,questRefId,"submitNpc")	
								local orderPos = G_getNPCPosByOrderRefidAndSceneRefid(npcRefid,sceneRefid)													
								self.transferSceneRefid = sceneRefid
								self.transferPos = orderPos	
							end
							if killNumberValue>=nowNumberValue then--当前步骤未完成
								questOrderword,monsterId,sceneRefid = self:setOrderTypeKillWord(questOrderword,j,questId,nowNumberValue,killNumberValue)
																
								local orderPos = G_getMonsterPosByOrderRefidAndSceneRefid(monsterId,sceneRefid)													
								self.transferSceneRefid = sceneRefid
								self.transferPos = orderPos	
								break
							end
						elseif orderType == QuestOrderType.eOrderTypeLoot then --任务类型-抢物品
							
						elseif orderType == QuestOrderType.eOrderTypeTalk then --任务类型-对话
							
						elseif orderType == QuestOrderType.eOrderTypeCollection then --任务类型-采集物品
							local itemNumberValue = QuestRefObj:getStaticQusetOrderFieldItemCount(qType,questId,j)
							if itemNumberValue>nowNumberValue then--当前步骤未完成
								questOrderword,collectRefId,sceneRefid = self:setOrderTypeItemWord(questOrderword,j,questId,nowNumberValue,itemNumberValue)
								
								local orderPos = G_getNPCPosByOrderRefidAndSceneRefid(collectRefId,sceneRefid)													
								self.transferSceneRefid = sceneRefid
								self.transferPos = orderPos	
								break
							end
						end
					end
				end
			elseif qType==QuestType.eQuestTypeDaily then--日常
				local randomOrder = questObj:getRandomOrderType()
				local orderType = QuestRefObj:getStaticQusetOrderFieldType(qType,questId,randomOrder)
				local nowNumberValue =  questObj:getNumber(randomOrder)
				if orderType == QuestOrderType.eOrderTypeKill then --任务类型-杀怪					
					local killNumberValue = QuestRefObj:getStaticQusetOrderFieldKillCount(qType,questId,randomOrder)
					local bOverOrder = false
					local nowRing = questObj:getDailyRing()
					local maxRing = QuestRefObj:getStaticDailyQusetMaxRing(questId)
					if nowRing>maxRing then--判断是否在推荐环外
						bOverOrder =true
						killNumberValue = QuestRefObj:getStaticDailyQusetOverOrderFieldKillCount(qType,questId,randomOrder)
					end	
					if self.squestState == QuestState.eSubmittableQuestState then--已完成任务
						nowNumberValue = killNumberValue
						
						sceneRefid = QuestRefObj:getStaticQusetNpcFieldSceneRefId(questTypeValue,questRefId,"submitNpc")	
						npcRefid = QuestRefObj:getStaticQusetNpcFieldNcRefId(questTypeValue,questRefId,"submitNpc")	
						local orderPos = G_getNPCPosByOrderRefidAndSceneRefid(npcRefid,sceneRefid)													
						self.transferSceneRefid = sceneRefid
						self.transferPos = orderPos	
					end
					if killNumberValue>=nowNumberValue then--当前步骤未完成
						questOrderword,monsterId,sceneRefid = self:setOrderTypeKillWord(questOrderword,randomOrder,questId,nowNumberValue,killNumberValue,bOverOrder)
						local orderPos = G_getMonsterPosByOrderRefidAndSceneRefid(monsterId,sceneRefid)													
						self.transferSceneRefid = sceneRefid
						self.transferPos = orderPos
					end
				elseif orderType == QuestOrderType.eOrderTypeLoot then --任务类型-抢物品
					
				elseif orderType == QuestOrderType.eOrderTypeTalk then --任务类型-对话
					
				elseif orderType == QuestOrderType.eOrderTypeCollection then --任务类型-采集物品
					local itemNumberValue = QuestRefObj:getStaticQusetOrderFieldItemCount(qType,questId,randomOrder)
					if itemNumberValue>nowNumberValue then--当前步骤未完成
						questOrderword,collectRefId,sceneRefid = self:setOrderTypeItemWord(questOrderword,randomOrder,questId,nowNumberValue,itemNumberValue)
						
						local orderPos = G_getNPCPosByOrderRefidAndSceneRefid(collectRefId,sceneRefid)													
						self.transferSceneRefid = sceneRefid
						self.transferPos = orderPos	
					end
				end
			end
		elseif self.squestState == QuestState.eSubmittableQuestState then --已完成但未提交			
			questOrderword,npcRefid,sceneRefid = self:setOrderFindNpcWord(questOrderword,qType,questId,"submitNpc")		
			local orderPos = G_getNPCPosByOrderRefidAndSceneRefid(npcRefid,sceneRefid)													
			self.transferSceneRefid = sceneRefid
			self.transferPos = orderPos
		end
		--end
		if questOrderword~="" then
			--任务目标
			local orderBg = createScale9SpriteWithFrameName(RES("common_blueBar.png"))
			orderBg:setContentSize(CCSizeMake(368,30))
			self.Lable2:addChild(orderBg)
			VisibleRect:relativePosition(orderBg,self.Lable2,  LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE ,ccp(20,5))			
		
			local orderPic = createSpriteWithFrameName(RES("word_level_questorder.png"))
			orderPic:setScale(1.3)
			self.Lable2:addChild(orderPic)
			VisibleRect:relativePosition(orderPic,self.Lable2,  LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE ,ccp(30,-1))		
		
			function OrderEventHandler(eventStr)
--				CCLuaLog(eventStr)
			end
			local questOrder = createRichLabel(CCSizeMake(300,10))
			questOrder:setFont("heiti")
			questOrder:setEventHandler(OrderEventHandler)
			questOrder:appendFormatText(questOrderword)
			self.Lable2:addChild(questOrder)
			VisibleRect:relativePosition(questOrder,orderPic, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(5.0, -5))
		end	
	end
	
end

function QuestView:dailyQuestDescription(node,obj)
	if (not node) or (not obj) then
		return
	end
	local orderNumber =  obj:getOrderNumber()
	for j=1,orderNumber do
		local randomOrderType =  obj:getRandomOrderType()
		if randomOrderType~=0 then
			local number =  obj:getNumber(randomOrderType)
			local qType = obj:getQuestType()
			local questId = obj:getQuestId()
			local orderType = QuestRefObj:getStaticDailyQusetOrderType(questId,randomOrderType)
			local descriptionWord = QuestRefObj:getStaticDailyQusetDescription(questId,orderType)
			local nowRing = obj:getDailyRing()
			local bOverOrder = false
			local maxRing = QuestRefObj:getStaticDailyQusetMaxRing(questId)			

			if nowRing>maxRing then--判断是否在推荐环外
				bOverOrder = true				
			end	
			local strWord = G_DailyQusetChangString(questId,qType,randomOrderType,orderType,descriptionWord,bOverOrder)
			
			local questDescription = createRichLabel(CCSizeMake(300,10))
			questDescription:setFont("heiti")
			--questDescription:setEventHandler(OrderEventHandler)
			questDescription:appendFormatText(strWord)
			node:addChild(questDescription)
			VisibleRect:relativePosition(questDescription,node,  LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE ,ccp(30,37))
			
			break
		end
	end
end

function QuestView:setOrderFindNpcWord(word,questTypeValue,questRefId,state)
	if (not word) or (not questTypeValue) or (not questRefId)or (not state)then
		return
	end	
	local sceneRefid = QuestRefObj:getStaticQusetNpcFieldSceneRefId(questTypeValue,questRefId,state)	
	local npcRefid = QuestRefObj:getStaticQusetNpcFieldNcRefId(questTypeValue,questRefId,state)	
				
	local strSceneWord = G_QusetChangStringScnce(sceneRefid,FSIZE("Size3"))
	local strNpcWord = G_QusetChangStringNpc(npcRefid,FSIZE("Size3"))
	if strSceneWord and strNpcWord then
		local Acceptword = Config.Words[3308]..strSceneWord..Config.Words[3309]..strNpcWord
		word = string.wrapRich(Acceptword,Config.FontColor["ColorWhite1"],FSIZE("Size3"))		
	end
	return word,npcRefid,sceneRefid
end

function QuestView:setOrderTypeKillWord(word,orderIndex,questId,nowNumberValue,orderNumberValue,bOverOrder)
	if (not word) or (not orderIndex) or (not questId) or (not nowNumberValue) then
		return
	end	
	
	local qType = self.QuestMgr:getQuestObj(questId):getQuestType()
	local sceneRefid = nil
	local monsterId = nil
	if bOverOrder then
		sceneRefid = QuestRefObj:getStaticDailyQusetOverOrderFieldSceneRefId(qType,questId,orderIndex)
		monsterId = QuestRefObj:getStaticDailyQusetOverOrderFieldMonsterRefId(qType,questId,orderIndex)		
	else
		sceneRefid = QuestRefObj:getStaticQusetOrderFieldSceneRefId(qType,questId,orderIndex)
		monsterId = QuestRefObj:getStaticQusetOrderFieldMonsterRefId(qType,questId,orderIndex)
	end
	
	
	if monsterId==nil or orderNumberValue==nil then
		return word
	end		
	local monsterName = PropertyDictionary:get_name(GameData.Monster[monsterId]["property"])--怪物名称
	
	local norword = string.wrapRich(Config.Words[3301],Config.FontColor["ColorWhite1"],FSIZE("Size3"))
	local monsterNameword = string.wrapRich(monsterName,Config.FontColor[QuestFontColor.order],FSIZE("Size3"))
	local numberword = string.wrapRich("("..nowNumberValue.."/"..orderNumberValue..")",Config.FontColor["ColorWhite1"],FSIZE("Size3"))
	word = norword..monsterNameword..numberword
	return word,monsterId,sceneRefid
end

function QuestView:setOrderTypeItemWord(word,orderIndex,questId,nowNumberValue,orderNumberValue)
	if (not word) or (not orderIndex) or (not questId) or (not nowNumberValue)  or (not orderNumberValue) then
		return
	end
	
	local qType = self.QuestMgr:getQuestObj(questId):getQuestType()
	local sceneRefid = QuestRefObj:getStaticQusetOrderFieldSceneRefId(qType,questId,orderIndex)
	local collectRefId = QuestRefObj:getStaticQusetOrderFieldItemNpcRefId(qType,questId,orderIndex)
	local itemId = QuestRefObj:getStaticQusetOrderFieldItemRefId(qType,questId,orderIndex)

	local itemName = PropertyDictionary:get_name(GameData.PropsItem[itemId]["property"])--物品名称
	
	local norword = string.wrapRich(Config.Words[3304],Config.FontColor["ColorWhite1"],FSIZE("Size3"))
	local itemNameword = string.wrapRich(itemName,Config.FontColor["ColorBlue1"],FSIZE("Size3"))
	local numberword = string.wrapRich("("..nowNumberValue.."/"..orderNumberValue..")",Config.FontColor["ColorWhite1"],FSIZE("Size3"))
	word = norword..itemNameword..numberword
	return word,collectRefId,sceneRefid
end

--获取英雄职业性别
function QuestView:getHeroProfessionGender()
	local heroPt = GameWorld.Instance:getEntityManager():getHero():getPT()
	local professionId = PropertyDictionary:get_professionId(heroPt)		
	local genderId = PropertyDictionary:get_gender(heroPt)
	for i,v in pairs(self.ProfessionGenderTable) do
		local tprofession  = v.tProfession
		local tgender  = v.tGender
		if tprofession == professionId and genderId ==tgender then
			return v.tIndex
		end
	end		
end	

function QuestView:ShowReword(questIndex,questId)--任务奖励
	if (not questIndex) or (not questId) then
		return
	end
	local viewSize = CCSizeMake(548*self.scale,200*self.scale)

	if self.rewardTitleBg then
		self.rewardTitleBg:removeFromParentAndCleanup(true)
		self.rewardTitleBg = nil
	end	

	
	if self.rewordLable then
		self.rewordLable:removeAllChildrenWithCleanup(true)
	else
	self.rewordLable = CCNode:create()
	self.rewordLable:setContentSize(viewSize)
	self.rightView:addChild(self.rewordLable )
	VisibleRect:relativePosition(self.rewordLable,self.rightView,LAYOUT_CENTER+LAYOUT_TOP_INSIDE  ,ccp(0,-220))		
	end
	
	
	self.rewardTitle = createScale9SpriteWithFrameName(RES("quest_reward.png"))
	self.rewordLable:addChild(self.rewardTitle)
	VisibleRect:relativePosition(self.rewardTitle,self.rewordLable,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE ,ccp(35,10))
	
	if questIndex~=nil then
		local rewardBoxPosX = 45
		local rewardBoxoffectX = 130
		local rewardBoxoffectY = -54
		local rewardNameoffsetY = 0
		local offectIndex = 0
		local gridArray = {}
		self.itemList = {}
		local questObj = self.QuestMgr:getQuestObj(questId)
		local questType = questObj:getQuestType()
		
		
		local propertyReward = nil
		local itemReward = nil
		if questType==QuestType.eQuestTypeMain then
			propertyReward = QuestRefObj:getStaticQusetRewardProperty(questType,questId)
			itemReward = QuestRefObj:getStaticQusetItemReward(questType,questId)
		elseif  questType==QuestType.eQuestTypeDaily then
			local dailyRing = questObj:getDailyRing()
			local dailyMaxRing = QuestRefObj:getStaticDailyQusetMaxRing(questId)
					
			local questState = questObj:getQuestState()
			if dailyRing==dailyMaxRing then
				--末环
				propertyReward = QuestRefObj:getStaticDailyQusetLastRewardProperty(questType,questId)
				itemReward = QuestRefObj:getStaticDailyQusetLastRewardItem(questType,questId)
			elseif dailyRing<dailyMaxRing then
				--环内
				propertyReward = QuestRefObj:getStaticQusetRewardProperty(questType,questId)
				itemReward = QuestRefObj:getStaticQusetItemReward(questType,questId)
			else
				--环外
				propertyReward = QuestRefObj:getStaticDailyQusetOverOrderRewardProperty(questType,questId)
				itemReward = QuestRefObj:getStaticDailyQusetOverOrderRewardItem(questType,questId)
			end				
		end
		
		local propertysum = 1
		if propertyReward ~= nil then	--属性奖励
			for j,v in pairs(propertyReward) do
				local propertyRewardtype = j
				local propertyRewardvalue = v
				
				local propertyRewardColor = ""
				if propertyRewardtype=="exp" then
					propertyRewardColor = FCOLOR("ColorOrange2")
					if self.starLevel~=0 then
						propertyRewardvalue = 0.2*self.starLevel*propertyRewardvalue + propertyRewardvalue
					end
				elseif propertyRewardtype=="gold" then
					propertyRewardColor = FCOLOR("ColorYellow3")
				else
					propertyRewardColor = FCOLOR("ColorYellow3")
				end					
				
				--格子背景
				local rewardBoxBg  = createSpriteWithFrameName(RES("bagBatch_itemBg.png"))
				self.rewordLable:addChild(rewardBoxBg)				
				VisibleRect:relativePosition(rewardBoxBg,self.rewordLable,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(rewardBoxPosX+rewardBoxoffectX*(propertysum-1),rewardBoxoffectY))
				
				--属性
				local rewardBox = G_createUnPropsItemBox(propertyRewardtype)
				rewardBoxBg:addChild(rewardBox)
				VisibleRect:relativePosition(rewardBox,rewardBoxBg, LAYOUT_CENTER)
												
				--名称		
				local propertyRewardName = G_getStaticUnPropsName(propertyRewardtype)
				--local propertyRewardNameWord = string.wrapRich(propertyRewardName,Config.FontColor["ColorWhite1"],FSIZE("Size3"))
				local propertyRewardvalueWord = string.wrapRich("+"..propertyRewardvalue,Config.FontColor["ColorYellow1"],FSIZE("Size3"))								
				
				--副文本显示				
				local questTitle = createRichLabel()				
				questTitle:appendFormatText(propertyRewardvalueWord)
				local size = questTitle:getContentSize()
				rewardBoxBg:addChild(questTitle)
				VisibleRect:relativePosition(questTitle,rewardBoxBg, LAYOUT_CENTER + LAYOUT_BOTTOM_OUTSIDE,ccp(0,rewardNameoffsetY))
				
				
				offectIndex = offectIndex+1
				propertysum = propertysum +1
			end
		end			

				
		if itemReward~=nil then--物品奖励
			local relatedType = QuestRefObj:getStaticQusetRelatedType(itemReward)--职业类型
			local itemList = nil
			if relatedType==0 then
				itemList =  QuestRefObj:getStaticQusetItemList(itemReward)
			else				
				local professionGender = G_getHeroProfessionGender()
				itemList =  QuestRefObj:getStaticQusetProfessionItemList(itemReward,professionGender)
			end
			
			for j,v in pairs(itemList) do
				local tIndex = propertysum
				local tItemList = v	
				local itemCount = QuestRefObj:getStaticQusetItemListItemCount(tItemList)
				local itemRefId = QuestRefObj:getStaticQusetItemListItemRefId(tItemList)				
				
				--格子背景
				local rewardBoxBg  = createSpriteWithFrameName(RES("bagBatch_itemBg.png"))
				self.rewordLable:addChild(rewardBoxBg)				
				VisibleRect:relativePosition(rewardBoxBg,self.rewordLable,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(rewardBoxPosX+rewardBoxoffectX*(propertysum-1),rewardBoxoffectY))
				
				--道具
				local rewardBox = G_createItemBoxByRefId(itemRefId,nil,nil,-1)					
				G_setScale(rewardBox)
				rewardBoxBg:addChild(rewardBox)
				VisibleRect:relativePosition(rewardBox,rewardBoxBg, LAYOUT_CENTER)
				
				--名称		
				local itemRewardName = G_getStaticDataByRefId(itemRefId)["property"]["name"]
				--local itemRewardNameWord = string.wrapRich(itemRewardName,Config.FontColor["ColorWhite1"],FSIZE("Size3"))
				local itemCountWord = string.wrapRich("X"..itemCount,Config.FontColor["ColorYellow1"],FSIZE("Size3"))
				--local word = itemRewardNameWord..itemCountWord				
				
				--副文本显示				
				local questTitle = createRichLabel()				
				questTitle:appendFormatText(itemCountWord)
				rewardBoxBg:addChild(questTitle)
				VisibleRect:relativePosition(questTitle,rewardBoxBg, LAYOUT_CENTER + LAYOUT_BOTTOM_OUTSIDE,ccp(0,rewardNameoffsetY))				
				
				propertysum = propertysum +1
				offectIndex = offectIndex+1
			end
		end	
	end
end

--点击物品响应
function QuestView:clickItemEvent(item)
	if (item) then
		local arg = ItemDetailArg.New()
		arg:setItem(item)
		
		if (item:getType() == ItemType.eItemEquip) then
			arg:setBtnArray({E_ItemDetailBtnType.ePutOn, E_ItemDetailBtnType.eShow, E_ItemDetailBtnType.eSell})
			arg:setBtnArray({})
			GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
			
		else
			arg:setBtnArray({E_ItemDetailBtnType.eUse, E_ItemDetailBtnType.eShow, E_ItemDetailBtnType.eSell})
			arg:setBtnArray({})
			GlobalEventSystem:Fire(GameEvent.EventOpenNormalItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
		end
	end
end

function QuestView:ShowBtn(questIndex,questId)
	if (not questIndex) or (not questId) then
		return
	end
	
	local viewSize = CCSizeMake(548,80)
	
	if self.btnLable then
		self.btnLable:removeAllChildrenWithCleanup(true)
		self.btnMain = nil
		self.flyButton = nil
	else
		self.btnLable = CCNode:create()
		self.btnLable:setContentSize(viewSize)
		self.rightView:addChild(self.btnLable )
		VisibleRect:relativePosition(self.btnLable,self.rightView,  LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE ,ccp(0,0))
	end				
	
	if self.btnMain then
		self.btnMain:removeFromParentAndCleanup(true)
		self.btnMain = nil
	end	
	if self.flyButton then
		self.flyButton:removeFromParentAndCleanup(true)
		self.flyButton = nil
	end
	
	if questIndex~=nil then
		--local questType = QuestRefObj:getStaticQusetPropertyQuestType(questId)
		local questObj = self.QuestMgr:getQuestObj(questId)
		if not questObj then
			return
		end
		self.btnQuestType = questObj:getQuestType()
		self.btnQuestState = questObj:getQuestState()
		local function createBtn()
			--按钮上显示的文字
			local btnWord = nil
			if self.btnQuestState==QuestState.eAcceptableQuestState then--任务可接
				btnWord = "word_button_gotoaccpet.png"
				if self.btnQuestType==QuestType.eQuestTypeDaily then				
					local npcId = QuestRefObj:getStaticQusetNpcFieldNcRefId(self.btnQuestType,questId,"acceptNpc")
					if not self.questNpcId then
						btnWord = "word_button_getquest.png"
					end
				end	
			elseif self.btnQuestState==QuestState.eAcceptedQuestState then--任务已接，但未完成
				btnWord = "word_button_goquest.png"	--缺少资源				
			elseif self.btnQuestState==QuestState.eSubmittableQuestState then--任务可提交
				btnWord = "word_button_gotocomplete.png"
				if self.btnQuestType==QuestType.eQuestTypeDaily then
					local npcId = QuestRefObj:getStaticQusetNpcFieldNcRefId(self.btnQuestType,questId,"submitNpc")
					if not npcId then
						btnWord = "word_button_getreword.png"
			end
				end	
			end	
			
			if btnWord then
				self.btnMain = createButtonWithFramename(RES("btn_1_select.png"))
				local scale = VisibleRect:SFGetScale()
				self.btnMain:setScale(scale)				
				self.btnLable:addChild(self.btnMain)
				VisibleRect:relativePosition(self.btnMain,self.btnLable, LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE ,ccp(-21,40))
													
				local btnMainfunc =function ()																	
					if self.btnQuestState==QuestState.eAcceptableQuestState then--任务可接						
						local npcId = QuestRefObj:getStaticQusetNpcFieldNcRefId(self.btnQuestType,questId,"acceptNpc")
						if not npcId and self.btnQuestType==QuestType.eQuestTypeDaily then
							--self.QuestMgr:setNpcTalkViewInfo(self.questNpcId,self.QuestMgr:getQuestObj(questId))	
							local arglist = {npcRefId=self.questNpcId,questObj=questObj}						
							GlobalEventSystem:Fire(GameEvent.EVENT_NpcQuest_UI,arglist)
						else
						G_getQuestLogicMgr():AutoPathFindNpc(questId)
						end
						
					elseif self.btnQuestState==QuestState.eAcceptedQuestState then--任务已接，未完成
						--todo
						self:AnalysisAction(self.btnQuestType,questId)
					elseif self.btnQuestState==QuestState.eSubmittableQuestState then--任务可提交						
						local npcId = QuestRefObj:getStaticQusetNpcFieldNcRefId(self.btnQuestType,questId,"submitNpc")
						if not npcId and self.btnQuestType==QuestType.eQuestTypeDaily then
							--self.QuestMgr:setNpcTalkViewInfo(self.questNpcId,self.QuestMgr:getQuestObj(questId))
							local arglist = {npcRefId=self.questNpcId,questObj=questObj}
							GlobalEventSystem:Fire(GameEvent.EVENT_NpcQuest_UI,arglist)
						else
						G_getQuestLogicMgr():AutoPathFindNpc(questId)
					end	
						
					end	
					self:close()
					
				end
				self.btnMain:addTargetWithActionForControlEvents(btnMainfunc, CCControlEventTouchDown)
				
				
				--按钮文字
				local btnSendWord = createSpriteWithFrameName(RES(btnWord))				
				self.btnMain:setTitleString(btnSendWord)		
				
				--飞鞋按钮
				if self.transferSceneRefid and self.transferPos then
					self.flyButton = createButtonWithFramename(RES("btn_1_select.png"))
					self.btnLable:addChild(self.flyButton)
					VisibleRect:relativePosition(self.flyButton,self.btnMain,LAYOUT_TOP_OUTSIDE+LAYOUT_CENTER,ccp(0,150))
					local flyToFunction = function ()
						local gameMapManager = GameWorld.Instance:getMapManager()
						local ret, reason = gameMapManager:checkCanUseFlyShoes(true)
						if ret then
							if self.transferPos then
								gameMapManager:requestTransfer(self.transferSceneRefid, self.transferPos.x,self.transferPos.y,1)
							end
							self:close()
						elseif reason ~= CanNotFlyReason.CastleWar then
							UIManager.Instance:showSystemTips(Config.Words[13021])
						end						
					end
					self.flyButton:addTargetWithActionForControlEvents(flyToFunction,CCControlEventTouchDown)
					
					--按钮文字					
					--local flyButtonword	 = createLabelWithStringFontSizeColorAndDimension(Config.Words[3142],"Arial",FSIZE("Size3"),FCOLOR("ColorWhite1"))
					--self.flyButton:addChild(flyButtonword)
					--VisibleRect:relativePosition(flyButtonword,self.flyButton,LAYOUT_CENTER)
					local flyButtonword = createSpriteWithFrameName(RES("word_button_shoes.png"))				
					self.flyButton:setTitleString(flyButtonword)
				end
				
			end
		end
		
		createBtn()
	end
end

--分析行为
function QuestView:AnalysisAction(questType,questId)
	if (not questType) or (not questId) then
		return
	end
	
	local questObj = self.QuestMgr:getQuestObj(questId)
	local orderIndex = nil
	local bOverOrder = nil
	
	if questType == QuestType.eQuestTypeMain  then--主线任务
		orderIndex = 1--暂时写死
	elseif questType == QuestType.eQuestTypeDaily then--日常任务
		orderIndex = questObj:getRandomOrderType()
		local dailyRing = questObj:getDailyRing()
		local dailyMaxRing = QuestRefObj:getStaticDailyQusetMaxRing(questId)
		if dailyRing>dailyMaxRing then
			bOverOrder = true
		end
	end
	
	
			
	local orderType = QuestRefObj:getStaticQusetOrderFieldType(questType,questId,orderIndex)	
	if orderType == QuestOrderType.eOrderTypeKill then --任务类型-杀怪
		local monsterId = nil
		local sceneId = nil		
		if bOverOrder then
			sceneId = QuestRefObj:getStaticDailyQusetOverOrderFieldSceneRefId(questType,questId,orderIndex)
			monsterId = QuestRefObj:getStaticDailyQusetOverOrderFieldMonsterRefId(questType,questId,orderIndex)	
		else
			sceneId = QuestRefObj:getStaticQusetOrderFieldSceneRefId(questType,questId,orderIndex)	
			monsterId = QuestRefObj:getStaticQusetOrderFieldMonsterRefId(questType,questId,orderIndex)			
		end
			
		G_getQuestLogicMgr():AutoPathFindMonster(monsterId,sceneId)--自动寻怪
	elseif orderType == QuestOrderType.eOrderTypeCollection then --任务类型-采集物品
		local collectRefId = QuestRefObj:getStaticQusetOrderFieldItemNpcRefId(questType,questId,orderIndex)
		local sceneId = QuestRefObj:getStaticQusetOrderFieldSceneRefId(questType,questId,orderIndex)		
		G_getQuestLogicMgr():AutoCollectItem(collectRefId,sceneId)--自动寻采集物
	elseif  orderType == QuestOrderType.eOrderTypeTime and questType == QuestType.eQuestTypeMain then --其他类型
		local InfoType , InfoIndex = G_getQuestLogicMgr():getUpGradeInfo(questType,questId)
		G_getQuestLogicMgr():handOrderEvent(InfoIndex, questId, questType)
	end
end

function QuestView:ShowTaskView()
	local tablesize = CCSizeMake(298, 479)
	local cellLable = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),tablesize)	
	self:addChild(cellLable)
	VisibleRect:relativePosition(cellLable,self.bigBg, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(6,-7) )
	
	local scale = VisibleRect:SFGetScale()
	self.questList = self:getShowQuestList(self.QuestMgr:getQuestList())--获取任务列表
	
	--定义
	local	kTableCellSizeForIndex = 0
	local	kCellSizeForTable = 1
	local	kTableCellAtIndex = 2
	local	kNumberOfCellsInTableView = 3
	
	local cellSize = CCSizeMake(293,65)
	
	local dataHandlerfunc = function(eventType,tableP,index,data)
		tableP = tolua.cast(tableP,"SFTableView")
		data = tolua.cast(data,"SFTableData")
		if eventType == kTableCellSizeForIndex then
			data:setSize(cellSize)
			return 1
		elseif eventType == kCellSizeForTable then
			data:setSize(cellSize)
			return 1
		elseif eventType == kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)
			if not tableCell then
				local cell = SFTableViewCell:create()
				cell:setContentSize(cellSize)
				cell:setIndex(index)
				local questId = self.questList[index+1]:getQuestId()
				self:ShowCell(cell,questId,index)--显示内容
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(cellSize)
				local questId = self.questList[index+1]:getQuestId()
				self:ShowCell(tableCell,questId,index)--显示内容
				data:setCell(tableCell)
			end
			
			return 1
		elseif eventType == kNumberOfCellsInTableView then			
			data:setIndex(self.questListCount)
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")
--		CCLuaLog(x.." "..y)
		local dIndex = cell:getIndex()+1
		self:clickCell(dIndex,tableP)
	end
	
	self.tasktable = createTableView(dataHandlerfunc,tablesize)
	self.tasktable:setTableViewHandler(tableDelegate)	
	cellLable:addChild(self.tasktable)
	VisibleRect:relativePosition(self.tasktable,cellLable, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(0,0))
	self.tasktable:reloadData()
end

function QuestView:clickCell(dIndex,tableP)
	if (not dIndex) then
		return
	end
	
	if dIndex == self.squestIndex then
		return
	end
	self.QuestMgr:setQuestView_ClickQuestIndex(dIndex)
	if tableP then
		tableP:reloadData()
	end
	
	local questId = self.questList[dIndex]:getQuestId()
	self:UpdateView(dIndex,questId)
end

function  QuestView:ShowCell(cell,questId,index)
	if (not cell) or (not questId) or (not index) then
		return
	end
	
	if self.QuestMgr:getQuestView_ClickQuestIndex() == (index+1) then
		local titleUp = createScale9SpriteWithFrameNameAndSize(RES("commom_SelectFrame.png"),CCSizeMake(292,58))
		G_setScale(titleUp)
		cell:addChild(titleUp)
		VisibleRect:relativePosition(titleUp,cell, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER,ccp(3,0))
	end
	local questObj = self.QuestMgr:getQuestObj(questId)
	local questType = questObj:getQuestType()
	local questState =  self.QuestMgr:getQuestObj(questId):getQuestState()
	
	--任务类型
	--local questtypeBtn = QuestRefObj:getStaticQusetPropertyQuestType(questId)
	local questtypeBtn = self.QuestMgr:getQuestObj(questId):getQuestType()
	--local wordNumber = 3114+(questtypeBtn-1)
	--local questTypeWord = string.wrapRich(Config.Words[wordNumber],Config.FontColor["ColorWhite1"],FSIZE("Size1"))
	--任务名字
	local questName =QuestRefObj:getStaticQusetPropertyQuestName(questtypeBtn,questId)
	
	if  questType==QuestType.eQuestTypeMain then
		local mianIcon = createSpriteWithFrameName(RES("quest_mianIcon.png"))
		G_setScale(mianIcon)
		cell:addChild(mianIcon)
		VisibleRect:relativePosition(mianIcon,cell, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER, ccp(0, -2))
	elseif questType==QuestType.eQuestTypeDaily then--日常任务
		local mianIconBg = createSpriteWithFrameName(RES("quest_riFrame.png"))	
		cell:addChild(mianIconBg)
		VisibleRect:relativePosition(mianIconBg,cell, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER, ccp(0, -2))
		
		local dailyQuestType =  QuestRefObj:getStaticDailyQusetSubType(questId)
		local mianIconWordName  = nil
		if dailyQuestType==DailyQuestSubType.eDailyQuest then
			mianIconWordName = "quest_ri.png"
		elseif dailyQuestType==DailyQuestSubType.eGoldQuest then
			mianIconWordName = "quest_jin.png"
		elseif dailyQuestType==DailyQuestSubType.eMeritQuest then
			mianIconWordName = "quest_gong.png"
		end
		local mianIconWord = createSpriteWithFrameName(RES(mianIconWordName))	
		mianIconBg:addChild(mianIconWord)
		VisibleRect:relativePosition(mianIconWord,mianIconBg, LAYOUT_CENTER)
		
		local nowRing = questObj:getDailyRing()
		if questState == QuestState.eAcceptableQuestState then
			nowRing = nowRing
		end
		local maxRing = QuestRefObj:getStaticDailyQusetMaxRing(questId)		
		
		if nowRing<=maxRing then
		questName = questName.."("..nowRing.."/"..maxRing..")"
		else 
			questName = questName.."("..Config.Words[3143]..")"
		end
	end
	
	if self.QuestMgr:getQuestView_ClickQuestIndex() == (index+1) then
		questName = string.wrapRich(questName,Config.FontColor["ColorYellow1"],FSIZE("Size4"))
	else
		questName = string.wrapRich(questName,Config.FontColor["ColorWhite1"],FSIZE("Size4"))
	end
	
	
	
	--显示名称
	local reichWord = questName
	local wordNextBtnName = createRichLabel(CCSizeMake(cell:getContentSize().width,10))
	wordNextBtnName:appendFormatText(reichWord)
	cell:addChild(wordNextBtnName)
	VisibleRect:relativePosition(wordNextBtnName,cell, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER, ccp(50,0))
	
	--分割线
	local line = createSpriteWithFrameName(RES("knight_line.png"))
	line:setScaleX(1.9)
	cell:addChild(line)
	VisibleRect:relativePosition(line,cell, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE, ccp(0, 0))
	
	--显示状态
	local stateName = nil
	if questState == QuestState.eAcceptableQuestState then --任务可接
	elseif questState == QuestState.eAcceptedQuestState then --任务已接，但未完成
	elseif questState == QuestState.eSubmittableQuestState then --任务已经可提交。但还没提交
		stateName = RES("main_questFinish.png")
		self:crateAnimate(cell)
	end
	if stateName~=nil then
		local questStatePic = createSpriteWithFrameName(stateName)
		questStatePic:setRotation(-30)
		G_setScale(questStatePic)
		cell:addChild(questStatePic)
		VisibleRect:relativePosition(questStatePic,cell,LAYOUT_RIGHT_INSIDE + LAYOUT_CENTER,ccp(-10,0))
	end		
end

function QuestView:crateAnimate(cell)
	if (not cell) then
		return
	end
	
	--帧动画	
	local animate = createAnimate("questframe",6,0.175)	
	local framesprite = CCSprite:create()
	framesprite:setScaleX(1.65)
	framesprite:setScaleY(0.90)
	local forever = CCRepeatForever:create(animate)
	framesprite:runAction(forever)		
	cell:addChild(framesprite)
	VisibleRect:relativePosition(framesprite, cell, LAYOUT_CENTER, ccp(-5,4))		
end

function QuestView:getShowQuestList(list)
	if (not list) then
		return
	end
	
	local saveList = {}
	local listSize = table.size(list)
	local index = 1	
	for i=1,listSize do
		local obj = list[i]
		if obj then
			local queststate = obj:getQuestState()
			local questtype = obj:getQuestType()
			if  queststate ~= QuestState.eVisiableQuestState then
				saveList[index] = list[i]
				index = index + 1
			end	
		end	
	end
	
	return saveList	
end

function QuestView:clearQuesetView()
	if self.btnMain then
		self.btnMain:removeFromParentAndCleanup(true)
		self.btnMain = nil
	end	
	if self.rewardTitleBg then
		self.rewardTitleBg:removeFromParentAndCleanup(true)
		self.rewardTitleBg = nil
	end	
	if self.Lable2 then
		self.Lable2:removeFromParentAndCleanup(true)
		self.Lable2 = nil
	end		
	if self.descriptionLable then
		self.descriptionLable:removeFromParentAndCleanup(true)
		self.descriptionLable = nil
	end
	if self.rewordLable then
		self.rewordLable:removeFromParentAndCleanup(true)
		self.rewordLable = nil
end
	if self.flyButton then
		self.flyButton:removeFromParentAndCleanup(true)
		self.flyButton = nil
	end
end
