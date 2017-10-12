require("ui.UIManager")
require("ui.Npc.NpcBaseView")
require("object.quest.QuestDef")
require("object.quest.QuestRefObj")
require("data.npc.npc")		
require ("data.wing.wing")
NpcQuestView = NpcQuestView or BaseClass(NpcBaseView)

visibleSize = CCDirector:sharedDirector():getVisibleSize()

function NpcQuestView:__init()
	self.viewWidth = 378
	self:init(CCSizeMake(414,564))
	self.viewName = "NpcQuestView"
	self.scale = VisibleRect:SFGetScale()
	self.QuestMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	
	self:clearData()
	self:createViewBg()
end

function NpcQuestView:__delete()
	
end

function NpcQuestView:onEnter(arg)
	--self:initViewPos()
	
	self:createNewView(arg)
	self:setTheCountdown()--�뵹��ʱ
end

function NpcQuestView:clearData()
	self.starLevel = 0
	self.pViewType = nil
	self.pQuestState = nil
	self.pQuestId = nil
	self.isHaveEquip = false
	self.rebackTimerId = -1
	self.rewardBox = {}
	if self.btnRefreshLevel then
		self.btnRefreshLevel:removeFromParentAndCleanup(true)
		self.btnRefreshLevel = nil
	end
	
end

function NpcQuestView:createViewBg()
	--���ô���
	local viewSize = self.contentNode:getContentSize()
	local height = 140
	--�߿�
	local frameBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(viewSize.width, viewSize.height-height))
	self.contentNode:addChild(frameBg)
	VisibleRect:relativePosition(frameBg,self:getContentNode(),LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)
	
	local frameTextBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(viewSize.width, height))
	self:addChild(frameTextBg)
	VisibleRect:relativePosition(frameTextBg, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE)	
end

function NpcQuestView:onExit()
	self:killTheCountdown()--ɾ������ʱ
	self:clearData()
end

function NpcQuestView:create()
	return NpcQuestView.New()
end

--[[function NpcQuestView:getRootNode()
	return self.rootNode
end--]]

function NpcQuestView:initViewPos()
	self:makeMeCenter()
	self.rootNode:setPositionX(15)
end

function NpcQuestView:EventUpdateQuestLevel(questId)
	if not questId then
		return
	end
	
	self:showQuestLevel(questId)
	
	local word = Config.Words[3310]..tostring(self.starLevel)..Config.Words[328]
	UIManager.Instance:showSystemTips(word)
	
	if self.pViewType~=nil and  self.pQuestState~=nil and self.pQuestId~=nil then
		self:showReword(self.pViewType,self.pQuestState,self.pQuestId)
	end			
end

function NpcQuestView:createNewView(arg)
	self.QuestMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local viewType,questState,questId,npcRefId = self:getInfo(arg)
	if not questId then
		return
	end
	
	self:setNpcAvatar(npcRefId)
	self:setNpcName(npcRefId)
			
	self:showAllView(viewType,questState,questId)
end	

function NpcQuestView:getInfo(arg)
	local returnviewType = nil
	local returnQuestState = nil
	local returnQuestId = nil
	local staticsNpcRefId = nil
	
	--local npcRefId,questObj =  self.QuestMgr:getNpcTalkViewInfo()
	local npcRefId = arg.npcRefId
	local questObj = arg.questObj
	if questObj~=nil then
		local questState = questObj:getQuestState()
		local questRefId = questObj:getQuestId()
		local qType = questObj:getQuestType()
		if npcRefId~=nil then--���NPC�������񴰿�			
			local staticsSceneRefId = nil
			local staticsTalkContent = nil
			
			if questState == QuestState.eAcceptableQuestState then--�ɽ���
				staticsNpcRefId = QuestRefObj:getStaticQusetNpcFieldNcRefId(qType,questRefId,"acceptNpc")
				staticsSceneRefId = QuestRefObj:getStaticQusetNpcFieldSceneRefId(qType,questRefId,"acceptNpc")
				staticsTalkContent = QuestRefObj:getStaticQusetNpcFieldTalkContent(qType,questRefId,"acceptNpc")
			elseif questState == QuestState.eSubmittableQuestState then--���ύ
				staticsNpcRefId = QuestRefObj:getStaticQusetNpcFieldNcRefId(qType,questRefId,"submitNpc")
				staticsSceneRefId = QuestRefObj:getStaticQusetNpcFieldSceneRefId(qType,questRefId,"submitNpc")
				staticsTalkContent = QuestRefObj:getStaticQusetNpcFieldTalkContent(qType,questRefId,"submitNpc")
			elseif questState == QuestState.eAcceptedQuestState then--�����ѽӣ���δ���
			end
			if --[[sceneRefId == staticsSceneRefId and--]] npcRefId == staticsNpcRefId then--�жϳ���id��npc���Ӧ
				returnviewType = qType
				returnQuestState = questState
				returnQuestId = questRefId
			end
		else--�Զ��������񴰿�
			returnviewType = qType
			returnQuestState = questState
			returnQuestId = questRefId
		end
	end
	
	local questList = self.QuestMgr:getQuestList()--��ȡ������Ϣ
	return returnviewType,returnQuestState,returnQuestId,staticsNpcRefId
end

function NpcQuestView:showAllView(pViewType,pQuestState,pQuestId)
	if (not pViewType) or (not pQuestState) or (not pQuestId) then
		return
	end
	
	self.pViewType = pViewType
	self.pQuestState = pQuestState
	self.pQuestId = pQuestId
	local obj = self.QuestMgr:getQuestObj(pQuestId)
	local questType 
	if obj then
		questType = obj:getQuestType()	
	else
		return
	end

	--�ָ���
	--[[if not self.viewLine then
		self.viewLine = createScale9SpriteWithFrameName(RES("npc_dividLine.png"))
		self.contentNode:addChild(self.viewLine)
		VisibleRect:relativePosition(self.viewLine,self.contentNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(28,-205))
	end--]]
	
	local titleText = self:getQuestName(pQuestId)
	local desText = self:getDescription(pViewType,pQuestState,pQuestId)
	local text = ""
	if titleText then
		text = text .. titleText 
	end
	if desText then
		desText = "    " .. desText
	end
	self:setQuestNpcText(text, desText)
	
	self:showQuestLevel(pQuestId)			
	self:showReword(pViewType,pQuestState,pQuestId)
	self:showBtn(pViewType,pQuestState,pQuestId)	
	if questType then
		self:showLastRewardShow(questType,pQuestState,pQuestId)
	end
end

function NpcQuestView:getQuestName(questId)
	if not questId then
		return
	end
	--��������
	local npcNameWord = ""
	local questObj = self.QuestMgr:getQuestObj(questId)
	if not questObj then
		CCLuaLog("Invalid QuestObj .  QuestId : " .. questId)
		return
	end
	local questType = questObj:getQuestType()
	if questType==QuestType.eQuestTypeMain then--��������
		npcNameWord = Config.Words[3114]
		npcNameWord = npcNameWord..QuestRefObj:getStaticQusetPropertyQuestName(questType,questId)
	elseif questType==QuestType.eQuestTypeDaily then--�ճ�����
		npcNameWord = Config.Words[3115]
		npcNameWord = npcNameWord..QuestRefObj:getStaticQusetPropertyQuestName(questType,questId)
		local nowRing = questObj:getDailyRing()
		local maxRing = QuestRefObj:getStaticDailyQusetMaxRing(questId)	
		if nowRing>maxRing then
			npcNameWord = npcNameWord.."("..Config.Words[3143]..")"
		else
			npcNameWord = npcNameWord.."("..nowRing.."/"..maxRing..")"
		end
	end
	return npcNameWord
	--[[if not self.questName then
		self.questName = createLabelWithStringFontSizeColorAndDimension(npcNameWord,"Arial",FSIZE("Size3"),FCOLOR("ColorBlack1"),CCSizeMake(self.viewWidth-20,0))
		self.contentNode:addChild(self.questName)
		VisibleRect:relativePosition(self.questName,self.contentNode, LAYOUT_TOP_INSIDE + LAYOUT_CENTER , ccp(100, -10))
	else
		self.questName:setString(npcNameWord)
	end--]]
end

function NpcQuestView:showLastRewardShow(questType,pQuestState,pQuestId)
	if (not questType) or (not pQuestState) or (not pQuestId) then
		return
	end
	
	local viewSize = CCSizeMake(self.viewWidth*self.scale,100*self.scale)
	
	if self.lastRewordLable then
		self.lastRewordLable:removeAllChildrenWithCleanup(true)
	else
		self.lastRewordLable = CCNode:create()
		self.lastRewordLable:setContentSize(viewSize)
		self.contentNode:addChild(self.lastRewordLable )
		VisibleRect:relativePosition(self.lastRewordLable,self.contentNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER ,ccp(0,0))
	end		
	
	if questType == QuestType.eQuestTypeDaily and pQuestState == QuestState.eAcceptableQuestState then
		local questObj = self.QuestMgr:getQuestObj(pQuestId)
		local dailyRing = questObj:getDailyRing()
		local dailyMaxRing = QuestRefObj:getStaticDailyQusetMaxRing(pQuestId)
		local offsetY = 110
		local firstPosX = 145
		local questSubType = QuestRefObj:getStaticDailyQusetSubType(pQuestId)	
		if questSubType==DailyQuestSubType.eGoldQuest then
			offsetY = 180
			firstPosX = 13
		end	
		if dailyRing<=dailyMaxRing then		
			local Rewardlist = QuestRefObj:getStaticDailyQusetLastRewardShowItem(questType,pQuestId)
			if Rewardlist and table.size(Rewardlist)>0 then

				local labelword = createLabelWithStringFontSizeColorAndDimension(Config.Words[3147],"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
				self.lastRewordLable:addChild(labelword )				
				VisibleRect:relativePosition(labelword,self.lastRewordLable, LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE ,ccp(30,offsetY))					

				
				
				local firstPosY = -13
				local offsetPosX = 104
				for i,v in pairs(Rewardlist) do
					local itemRefId = v.itemRefId
					local itemCount = v.itemCount
					
					local item = G_createItemShowByItemBox(itemRefId,itemCount,FCOLOR("ColorYellow1"),nil,nil,-1)			
					labelword:addChild(item)
					VisibleRect:relativePosition(item,labelword, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE  ,ccp(firstPosX+(offsetPosX*(i-1)),firstPosY))			
				end
			end			
		end
	end
end

--���񼶱��ճ�����ʾ��ˢ��
function NpcQuestView:showQuestLevel(pQuestId)
	if not pQuestId then
		return
	end
	
	local viewSize = CCSizeMake(self.viewWidth*self.scale,100*self.scale)
	local questObj = self.QuestMgr:getQuestObj(pQuestId)
	if not questObj then
		return
	end
	
	if self.starLevel then
		self.starLevel = 0
	end
	
	if self.questLevelView then	
		self.questLevelView:removeAllChildrenWithCleanup(true)
	else
		self.questLevelView = CCNode:create()--CCLayerColor:create(ccc4(255, 0, 0, 105))
		self.questLevelView:setContentSize(viewSize)
		self.contentNode:addChild(self.questLevelView )
		VisibleRect:relativePosition(self.questLevelView,self.contentNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER ,ccp(0,-145))
	end

	local questType = questObj:getQuestType()
	if questType ~= QuestType.eQuestTypeDaily then --�ճ�����	
		return
	end
	
		
	local questSubType = QuestRefObj:getStaticDailyQusetSubType(pQuestId)
	if questSubType~=DailyQuestSubType.eGoldQuest then--��Ϊ�������ʱ��ʾˢ����ȼ�
		--���񼶱�����
		local questLevelWord = createSpriteWithFrameName(RES("word_level_questlevel.png"))
		self.questLevelView:addChild(questLevelWord)
		VisibleRect:relativePosition(questLevelWord, self.questLevelView, LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X, ccp(25, -5))
		
		--����˻�ȡ�ȼ���
		self.starLevel = questObj:getDailyLevel()
		local starNumber = math.floor((self.starLevel/2))
		local starHalf = self.starLevel%2
		local offectX  = 32
		local scale = 0.7
		--���ǵ�
		for i=1,5 do
			local starbg = createSpriteWithFrameName(RES("common_star.png"))
			UIControl:SpriteSetGray(starbg)
			starbg:setScale(scale)
			self.questLevelView:addChild(starbg)
			VisibleRect:relativePosition(starbg,questLevelWord, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE  ,ccp(offectX*(i-1),-3))
		end
		
		--����
		for i=1,starNumber do
			local star = createSpriteWithFrameName(RES("common_star.png"))
			star:setScale(scale)
			self.questLevelView:addChild(star)
			VisibleRect:relativePosition(star,questLevelWord, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE  ,ccp(offectX*(i-1),-3))
		end
		
		if starHalf~=0 then--��ʾ�����
			local halfstar = createSpriteWithFrameName(RES("common_halfStar.png"))
			halfstar:setScale(scale)
			self.questLevelView:addChild(halfstar)
			VisibleRect:relativePosition(halfstar,questLevelWord, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE  ,ccp(offectX*starNumber,-3))
		end
		
		
		--��ʾ����
		local questLevelWord = createLabelWithStringFontSizeColorAndDimension(Config.Words[3119],"Arial",FSIZE("Size3"),FCOLOR("ColorRed1"))
		self.questLevelView:addChild(questLevelWord)
		VisibleRect:relativePosition(questLevelWord, self.questLevelView, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(28, -63))
		
	
		self.btnRefreshLevel = createButtonWithFramename(RES("btn_1_select.png"))
		self.btnRefreshLevel:setScale(self.scale)
		self.questLevelView:addChild(self.btnRefreshLevel)
		VisibleRect:relativePosition(self.btnRefreshLevel,self.questLevelView, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE ,ccp(25, 0))
		local btnRefreshLevelfunc =function ()
			self:clickBtnRefreshLevel()
			hero = GameWorld.Instance:getEntityManager():getHero()
			local gold   	= PropertyDictionary:get_gold(hero:getPT())
			if gold<20000 then --�������20000�����ͣ���ʱд��
				UIManager.Instance:showSystemTips(Config.Words[3124])
			elseif self.starLevel==10 then
				UIManager.Instance:showSystemTips(Config.Words[3311])
			else
				self.QuestMgr:reDailyFreshQuestLevel(pQuestId)--����ˢ������ȼ�
			end
		end
		self.btnRefreshLevel:addTargetWithActionForControlEvents(btnRefreshLevelfunc, CCControlEventTouchDown)
		
		local btnWord = createSpriteWithFrameName(RES("word_button_refreshlevel.png"))
		self.btnRefreshLevel:addChild(btnWord)
		VisibleRect:relativePosition(btnWord, self.btnRefreshLevel, LAYOUT_CENTER)
	
	end
end

--��������
function NpcQuestView:getDescription(pViewType,pQuestState,pQuestId)
	if pQuestId and pQuestState then
		local qType = self.QuestMgr:getQuestObj(pQuestId):getQuestType()
		local descriptionWord = " "
		if pQuestState == QuestState.eAcceptableQuestState then--�ɽ���
			descriptionWord = QuestRefObj:getStaticQusetNpcFieldTalkContent(qType,pQuestId,"acceptNpc")
		elseif pQuestState == QuestState.eSubmittableQuestState then--���ύ
			descriptionWord = QuestRefObj:getStaticQusetNpcFieldTalkContent(qType,pQuestId,"submitNpc")
		elseif pQuestState == QuestState.eAcceptedQuestState then--�����ѽӣ���δ���
			descriptionWord = QuestRefObj:getStaticQusetNpcFieldTalkContent(qType,pQuestId,"acceptNpc")
		end	
		
		return descriptionWord
	end
end	

--������
function NpcQuestView:showReword(pViewType,pQuestState,pQuestId)
	if (not pViewType) or (not pQuestState) or (not pQuestId) then
		return
	end
	local viewSize = CCSizeMake(self.viewWidth*self.scale,100*self.scale)
	
	--��������ͼ
	if not self.rewardTitle then
		self.rewardTitle = createScale9SpriteWithFrameName(RES("word_label_questReward.png"))
		self.contentNode:addChild(self.rewardTitle)
		
	end
	
	if self.rewordLable then
		if self.rewordLable:getParent() then
			self.rewordLable:removeFromParentAndCleanup(true)
		end
		--self.rewordLable:removeAllChildrenWithCleanup(true)
		self.rewordLable = nil
	end
	self.rewordLable = CCNode:create()--[[CCLayerColor:create(ccc4(255, 0, 0, 120))--]]--
	self.rewordLable:setContentSize(viewSize)
	self.contentNode:addChild(self.rewordLable )
	
	local questSubType = QuestRefObj:getStaticDailyQusetSubType(pQuestId)	
	if pViewType == QuestType.eQuestTypeDaily then
		if questSubType~=DailyQuestSubType.eGoldQuest then --��Ϊ�������ʱ��ʾˢ����ȼ�
			VisibleRect:relativePosition(self.rewordLable,self.contentNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER ,ccp(0,-155))
			VisibleRect:relativePosition(self.rewardTitle,self.contentNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE ,ccp(25,-233))
		else
			VisibleRect:relativePosition(self.rewordLable,self.contentNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER ,ccp(0,-155))
			VisibleRect:relativePosition(self.rewardTitle,self.contentNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE ,ccp(25,-165))
		end			
	else
		VisibleRect:relativePosition(self.rewordLable,self.contentNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER ,ccp(0,-85))
		VisibleRect:relativePosition(self.rewardTitle,self.contentNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE ,ccp(25,-155))
	end
	
	
	if pQuestId~=nil then
		local rewardfrontSize = "Size3"
		local rewardBoxPosX = 45
		local rewardBoxPosY = -110
		if questSubType==DailyQuestSubType.eGoldQuest then
			rewardBoxPosY = -40
		end		
		local rewardBoxoffectX = 40
		local rewardBoxoffectY = 0
		local gridArray = {}
		local itemReward = {}
				
		local questObj = self.QuestMgr:getQuestObj(pQuestId)
		if not questObj then
			return
		end
		local qType = questObj:getQuestType()
		local dailyRing = questObj:getDailyRing()
		local dailyMaxRing = QuestRefObj:getStaticDailyQusetMaxRing(pQuestId)
		local questState = questObj:getQuestState()
		
		local propertyReward = nil
		if qType==QuestType.eQuestTypeMain then
			propertyReward = QuestRefObj:getStaticQusetRewardProperty(qType,pQuestId)
			itemReward = QuestRefObj:getStaticQusetItemReward(qType,pQuestId)
		elseif  qType==QuestType.eQuestTypeDaily then
			local dailyRing = questObj:getDailyRing()
			local dailyMaxRing = QuestRefObj:getStaticDailyQusetMaxRing(pQuestId)
			local questState = questObj:getQuestState()
			if dailyRing==dailyMaxRing  then
				--ĩ��
				propertyReward = QuestRefObj:getStaticDailyQusetLastRewardProperty(qType,pQuestId)
				itemReward = QuestRefObj:getStaticDailyQusetLastRewardItem(qType,pQuestId)
			elseif dailyRing<dailyMaxRing then
				--����
				propertyReward = QuestRefObj:getStaticQusetRewardProperty(qType,pQuestId)
				itemReward = QuestRefObj:getStaticQusetItemReward(qType,pQuestId)
			else
				--����
				propertyReward = QuestRefObj:getStaticDailyQusetOverOrderRewardProperty(qType,pQuestId)
				itemReward = QuestRefObj:getStaticDailyQusetOverOrderRewardItem(qType,pQuestId)
			end				
		end
		local propertysum = 1
		if propertyReward ~= nil then	--���Խ���
			for j,v in pairs(propertyReward) do
				local propertyRewardtype = j
				local propertyRewardvalue = v
				
				local propertyRewardColor = FCOLOR("ColorYellow1")
				if propertyRewardtype=="exp" then				
					if self.starLevel~=0 then
						propertyRewardvalue = 0.2*self.starLevel*propertyRewardvalue + propertyRewardvalue
					end
				end	

				self.rewardBox[propertysum] = G_createItemShowByItemBox(propertyRewardtype,propertyRewardvalue,FCOLOR("ColorYellow1"),nil,nil,-1)
				self.rewordLable:addChild(self.rewardBox[propertysum])
				if propertysum == 1 then				
					VisibleRect:relativePosition(self.rewardBox[propertysum],self.rewordLable,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(rewardBoxPosX,rewardBoxPosY))
				else
					VisibleRect:relativePosition(self.rewardBox[propertysum],self.rewardBox[propertysum-1],LAYOUT_RIGHT_OUTSIDE + LAYOUT_TOP_INSIDE,ccp(rewardBoxoffectX,rewardBoxoffectY))
				end
				
				propertysum = propertysum +1
			end
		end
		
		--local itemReward = QuestRefObj:getStaticQusetItemReward(qType,pQuestId)
		if itemReward~=nil then--��Ʒ����
			local relatedType = QuestRefObj:getStaticQusetRelatedType(itemReward)--ְҵ����
			local itemList = {}
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
				
				self.rewardBox[propertysum] = G_createItemShowByItemBox(itemRefId,itemCount,FCOLOR("ColorYellow1"),nil,nil,-1)
				self.rewordLable:addChild(self.rewardBox[propertysum])
				if self.rewardBox[propertysum-1] then
					VisibleRect:relativePosition(self.rewardBox[propertysum],self.rewardBox[propertysum-1],LAYOUT_RIGHT_OUTSIDE + LAYOUT_TOP_INSIDE,ccp(rewardBoxoffectX,rewardBoxoffectY))
				else					
					VisibleRect:relativePosition(self.rewardBox[propertysum],self.rewordLable,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE,ccp(rewardBoxPosX,rewardBoxPosY))
				end					
				
				propertysum = propertysum +1
			end
		end
	end
	
end

function NpcQuestView:createBtn(questType, questState, pQuestId)
	if (not questType) or (not questState) or (not pQuestId) then
		return
	end
	--��ť����ʾ������
	local btnWord = nil
	if questState==QuestState.eAcceptableQuestState then--����ɽ�
		btnWord = "word_button_getquest.png"
	elseif questState==QuestState.eSubmittableQuestState then--������ύ
		btnWord = "word_button_getreword.png"
	else
		print("questState====="..questState)		
	end	
		
	if btnWord then
		local btnMain = createButtonWithFramename(RES("btn_1_select.png"))
		local scale = VisibleRect:SFGetScale()
		btnMain:setScale(scale)
		self.btnlabel:addChild(btnMain)
		VisibleRect:relativePosition(btnMain,self.btnlabel, LAYOUT_RIGHT_INSIDE + LAYOUT_LEFT_INSIDE ,ccp(25,44))
		local btnMainfunc =function ()
			self:clickBtn(self.savequestType,self.savequestState,self.savepQuestId)
		end
		btnMain:addTargetWithActionForControlEvents(btnMainfunc, CCControlEventTouchDown)
			
		--��ť����
		local btnSendWord = createSpriteWithFrameName(RES(btnWord))
		btnMain:addChild(btnSendWord)
		VisibleRect:relativePosition(btnSendWord, btnMain, LAYOUT_CENTER)
	end
end

--��ť
function NpcQuestView:showBtn(pViewType,pQuestState,pQuestId)
	if (not pViewType) or (not pQuestState) or (not pQuestId) then
		return
	end
	
	local viewSize = CCSizeMake(self.viewWidth*self.scale,90*self.scale)
		
	if not self.btnlabel then
		self.btnlabel = CCNode:create()
		self.btnlabel:setContentSize(viewSize)
		self.contentNode:addChild(self.btnlabel )
		VisibleRect:relativePosition(self.btnlabel,self.contentNode, LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE  ,ccp(0,0))
	else
		self.btnlabel:removeAllChildrenWithCleanup(true)
	end
	
	
	local questObj = self.QuestMgr:getQuestObj(pQuestId)
	local questType = questObj:getQuestType()
	local questState = questObj:getQuestState()
	
	self.savequestType = questType
	self.savequestState = questState
	self.savepQuestId = pQuestId	
				
	if questType==QuestType.eQuestTypeMain then--��������
		self:createBtn(questType, questState, pQuestId)
	elseif questType==QuestType.eQuestTypeDaily then--�ճ�����
		if questState==QuestState.eAcceptableQuestState then--����ɽ�
			self:createBtn(questType, questState, pQuestId)
		elseif questState==QuestState.eSubmittableQuestState then--������ύ
			
			--��ȡ����
			local btnGetReWord = createButtonWithFramename(RES("btn_1_select.png"))
			local scale = VisibleRect:SFGetScale()
			btnGetReWord:setScale(scale)
			self.btnlabel:addChild(btnGetReWord)
			VisibleRect:relativePosition(btnGetReWord,self.btnlabel,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE ,ccp(25, 38))
			local btnGetReWordfunc =function ()
				self.QuestMgr:reDailyQuestSubmitQuest(pQuestId,1)--������ȡ����
				self:clickBtnCloseView()
			end
			btnGetReWord:addTargetWithActionForControlEvents(btnGetReWordfunc, CCControlEventTouchDown)
			--��ť����
			local btnSendWord = createSpriteWithFrameName(RES("word_button_getreword.png"))
			btnGetReWord:addChild(btnSendWord)
			VisibleRect:relativePosition(btnSendWord, btnGetReWord, LAYOUT_CENTER)
			
			local questSubType = QuestRefObj:getStaticDailyQusetSubType(pQuestId)
				if questSubType~=DailyQuestSubType.eGoldQuest then--��Ϊ�������ʱ��ʾˢ����ȼ�
					--��ȡ2������
				local btnGet2ReWord = createButtonWithFramename(RES("btn_1_select.png"))
				local scale = VisibleRect:SFGetScale()
				btnGet2ReWord:setScale(scale)
				self.btnlabel:addChild(btnGet2ReWord)
				VisibleRect:relativePosition(btnGet2ReWord,btnGetReWord,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER ,ccp(30,0))
				local btnGet2ReWordfunc =function ()
					hero = GameWorld.Instance:getEntityManager():getHero()
					local gold = PropertyDictionary:get_gold(hero:getPT())
					if gold<200000 then --�������200000�����ͣ���ʱд��
						UIManager.Instance:showSystemTips(Config.Words[3124])
					else
						self.QuestMgr:reDailyQuestSubmitQuest(pQuestId,2)--����2����ȡ����
						self:clickBtnCloseView()
					end
				end
				btnGet2ReWord:addTargetWithActionForControlEvents(btnGet2ReWordfunc, CCControlEventTouchDown)
				--��ť����
				local btnSend2Word = createSpriteWithFrameName(RES("word_button_2reword.png"))
				btnGet2ReWord:addChild(btnSend2Word)
				VisibleRect:relativePosition(btnSend2Word, btnGet2ReWord, LAYOUT_CENTER)
				
				--��ʾ����
				local tipsWord = createLabelWithStringFontSizeColorAndDimension(Config.Words[3123],"Arial",FSIZE("Size3"),FCOLOR("ColorRed1"))
				self.btnlabel:addChild(tipsWord)
				VisibleRect:relativePosition(tipsWord, self.btnlabel , LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-8, 8))
			end	
		end
	end
end

function NpcQuestView:clickBtn(questType,questState,pQuestId)
	if (not questType) or (not questState) or (not pQuestId) then
		return
	end
	
	if questType==QuestType.eQuestTypeMain then--��������
		if questState==QuestState.eAcceptableQuestState then--����ɽ�
			local bAchieveLevel = G_getQuestLogicMgr():IsAchieveLevel(pQuestId)--У��ȼ��Ƿ�ɽ�
			if bAchieveLevel then
				self.QuestMgr:requestAcceptQuest(pQuestId)--���ͽ�����Ϣ
			end
		elseif questState==QuestState.eSubmittableQuestState then--������ύ
			self.QuestMgr:requestSubmitQuest(pQuestId)--�����ύ��Ϣ
		end
	elseif questType==QuestType.eQuestTypeDaily then--�ճ�����
		if questState==QuestState.eAcceptableQuestState then--����ɽ�
			local bAchieveLevel = G_getQuestLogicMgr():IsAchieveLevel(pQuestId)--У��ȼ��Ƿ�ɽ�
			if bAchieveLevel then
				self.QuestMgr:reDailyQuestAcceptQuest(pQuestId)--���ͽ�����Ϣ
			end
		end
	end
	self:clickBtnCloseView()
end

function NpcQuestView:clickBtnCloseView()
	GlobalEventSystem:Fire(GameEvent.EventCloseQuestView)
	self:close()
end	

function NpcQuestView:showNpc()
	local npcMpduleId =  self.QuestMgr:getNpcModuleId()
	
	self.npcUI = createBaseActorView(npcMpduleId)
	self:addChild(self.npcUI)
	
	VisibleRect:relativePosition(self.npcUI, self:getContentNode(), LAYOUT_CENTER + LAYOUT_LEFT_INSIDE, ccp(20, 0))
end

function NpcQuestView:setTheCountdown()
	if self.savequestType==QuestType.eQuestTypeMain then--�������� then
		if self.savequestState==QuestState.eAcceptableQuestState then--�ɽ�״̬
			if self.reBackTimerFunc == nil then
				self.reBackTimerFunc = function ()					
					self:clickBtn(self.savequestType,self.savequestState,self.savepQuestId)
				end	
			end
			self.rebackTimerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.reBackTimerFunc, 10, false)
		end	
	end
	
end

function NpcQuestView:killTheCountdown()
	if self.rebackTimerId ~= -1  then	
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackTimerId)
		self.rebackTimerId = -1
	end
end

--����NPC��������
function NpcQuestView:setQuestNpcText(title, textString)
	if not title or title == "" then
		return
	end
	
	if not textString or textString == "" then
		return
	end

	local contentSize = self.contentNode:getContentSize()
	local scrollViewSize = CCSizeMake(contentSize.width, 135)
	
	local container = CCNode:create()
	local pos = string.find(title, Config.Words[3149])
	local titleTypeDec = string.match(title, Config.Words[3150])
	local titleText = string.sub(title, pos+3)
	local titleTypeDecLabel = createLabelWithStringFontSizeColorAndDimension(titleTypeDec, "Arial", FSIZE("Size3"), FCOLOR("ColorBlue1"))
	local titleTextLabel = createLabelWithStringFontSizeColorAndDimension(titleText, "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
	local textLabel = createLabelWithStringFontSizeColorAndDimension(textString, "Arial", FSIZE("Size3"), FCOLOR("ColorWhite3"), CCSizeMake(contentSize.width-60, 0))
		
	local titleSize = titleTypeDecLabel:getContentSize()
	local labelSize = textLabel:getContentSize()	
	local labelHeight = labelSize.height+titleSize.height
	local  offSetY = 0
	if labelHeight > scrollViewSize.height then
		container:setContentSize(CCSizeMake(contentSize.width, labelHeight))
		offSetY = scrollViewSize.height - labelHeight
	else
		container:setContentSize(scrollViewSize)
	end					
	
	container:addChild(titleTypeDecLabel)
	container:addChild(titleTextLabel)
	container:addChild(textLabel, 1)
	VisibleRect:relativePosition(titleTypeDecLabel, container, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(80, 0))
	VisibleRect:relativePosition(titleTextLabel, titleTypeDecLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(textLabel,container, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(60, -20))	
	
	if not self.topScrollView then
		self.topScrollView = createScrollViewWithSize(scrollViewSize)
		self.topScrollView:setDirection(2)
		self:addChild(self.topScrollView)
		VisibleRect:relativePosition(self.topScrollView, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0,-2))	
	else
		self.topScrollView:removeAllChildrenWithCleanup(true)
	end		
	self.topScrollView:setContainer(container)
	self.topScrollView:setContentOffset(ccp(0,offSetY))	
end

-----------------------------------------------------------
--����ָ��
function NpcQuestView:getBtnRefreshLevel()
	return self.btnRefreshLevel
end

function NpcQuestView:clickBtnRefreshLevel()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"NpcQuestView","btnRefreshLevel")
end

function NpcQuestView:IsShowNewGuidelines()
	if self.pQuestId then
		local questObj = self.QuestMgr:getQuestObj(self.pQuestId)
		if questObj then
			local questType = questObj:getQuestType()
			local questState = questObj:getQuestState() 
			local questSubType = QuestRefObj:getStaticDailyQusetSubType(self.pQuestId)
			if questType == QuestType.eQuestTypeDaily and questState==QuestState.eAcceptableQuestState then --�ճ��������ǿɽ�״̬
				if questSubType~=DailyQuestSubType.eGoldQuest then--��Ϊ�������
					if self.btnRefreshLevel and self.starLevel and self.starLevel<10 then--�ȼ���Ϊ����
						return true
					end
				end
			end
		end
	end
	return false
end
-----------------------------------------------------------