require("object.npc.NpcDef")
require("ui.UIManager")
require("data.npc.npc")	

NpcInstanceView = NpcInstanceView or BaseClass(NpcBaseView)

function NpcInstanceView:__init()
	self.viewName = "NpcInstanceView"
	self.viewSize = CCSizeMake(414,564)
	self:init(self.viewSize)								
	self:createViewBg()
	self:createNextBtn()
end

function NpcInstanceView:__delete()

end

function NpcInstanceView:onExit()

end

function NpcInstanceView:onEnter(npcRefId)
	self:setNpcAvatar(npcRefId)
	self:setNpcName(npcRefId)
	self:setTalkConcent(npcRefId)	
	self:setInstanceDescription(npcRefId)
end

function NpcInstanceView:create()
	return NpcInstanceView.New()
end

--改变谈话内容
function NpcInstanceView:setTalkConcent(npcRefId)
	local npcTalkWord = ""
	if GameData.Npc[npcRefId]~=nil then
		npcTalkWord = GameData.Npc[npcRefId]["property"]["description"]
		--npcTalkWord = string.wrapRich( "        "..GameData.Npc[npcRefId]["property"]["description"],Config.FontColor["ColorWhite1"],FSIZE("Size3"))
	else
		npcTalkWord = Config.Words[3202]
		--npcTalkWord = string.wrapRich(Config.Words[3202],Config.FontColor["ColorWhite1"],FSIZE("Size3"))
	end
	npcTalkWord = "    " .. npcTalkWord
	self:setNpcText(npcTalkWord)
	--[[if self.questTitle then
		self.questTitle:clearAll()
		self.questTitle:appendFormatText(npcTalkWord)
	else
		local containerNode = CCNode:create()
		local scrollViewSize = CCSizeMake(viewSize.width-20,120)
		containerNode:setContentSize(scrollViewSize)

		--ScrollView
		self.scrollView = createScrollViewWithSize(scrollViewSize)
		self.scrollView:setDirection(kSFScrollViewDirectionVertical)
		self.scrollView:setPageEnable(true)
		self.scrollView:setContainer(containerNode)
		self.view:addChild(self.scrollView)
		VisibleRect:relativePosition(self.scrollView, self.view, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(10.0, -50.0))
	
		self.questTitle = createRichLabel(CCSizeMake(scrollViewSize.width-30,0))
		self.questTitle:setFont(Config.fontName["fontName1"])	
		self.questTitle:appendFormatText(npcTalkWord)
		containerNode:addChild(self.questTitle)
		VisibleRect:relativePosition(self.questTitle,containerNode,LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  , ccp(40,-20))
		
		---提示
		local tips = createLabelWithStringFontSizeColorAndDimension(Config.Words[1506], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow1"))		
		self:addChild(tips)
		VisibleRect:relativePosition(tips,self.scrollView,  LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(15,-10))
		
		--分割线
		local viewLine = createScale9SpriteWithFrameName(RES("npc_dividLine.png"))
		self:addChild(viewLine)
		VisibleRect:relativePosition(viewLine,tips,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE,ccp(-20,-5))		
	end--]]
end

function NpcInstanceView:setInstanceDescription(npcRefId)
	if self.instanceNode then
		self.instanceNode:removeAllChildrenWithCleanup(true)
	end
	
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local bgmgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	
	local insRefid = questMgr:getInstanceRefId()
	self.intanceRefId = insRefid
	local currentMapRefId =  GameWorld.Instance:getMapManager():getCurrentMapRefId()
	
	local itemRefId = QuestInstanceRefObj:getStaticQusetToNextLayerItemRefid(insRefid,currentMapRefId)
	local itemCount = QuestInstanceRefObj:getStaticQusetToNextLayerItemCount(insRefid,currentMapRefId)

	if not itemRefId or not itemCount then
		return
	end
	
	if not self.instanceNode then
		self.instanceNode = CCNode:create()	
		self.instanceNode:setContentSize(CCSizeMake(300,500))
		self:addChild(self.instanceNode)
		VisibleRect:relativePosition(self.instanceNode,self:getContentNode(), LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,0))	
	end
	
	local offsetPosY = 20
	
	--下层消耗的镇魔令
	local itemName = G_getStaticDataByRefId(itemRefId)["property"]["name"]
	local need = createLabelWithStringFontSizeColorAndDimension(Config.Words[1504], "Arial", FSIZE("Size4")*viewScale, FCOLOR("ColorWhite1"))		
	self.instanceNode:addChild(need)
	VisibleRect:relativePosition(need,self.instanceNode,  LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(25,-170))	
	local needWord = createLabelWithStringFontSizeColorAndDimension(itemName.." "..tostring(itemCount), "Arial", FSIZE("Size4")*viewScale, FCOLOR("ColorYellow1"))		
	self.instanceNode:addChild(needWord)
	VisibleRect:relativePosition(needWord,need,  LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(5,0))	
	
	--当前拥有的镇魔令
	local hasCount = bgmgr:getItemNumByRefId(itemRefId)		
	local has = createLabelWithStringFontSizeColorAndDimension(Config.Words[1505], "Arial", FSIZE("Size4")*viewScale, FCOLOR("ColorWhite1"))		
	self.instanceNode:addChild(has)
	VisibleRect:relativePosition(has,need,  LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-offsetPosY))	
	self.ownCount = createLabelWithStringFontSizeColorAndDimension(hasCount, "Arial", FSIZE("Size4")*viewScale, FCOLOR("ColorYellow1"))		
	self.instanceNode:addChild(self.ownCount)
	VisibleRect:relativePosition(self.ownCount, has, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(5,0))	
	
	
	--本层获得经验
	local questList = QuestInstanceRefObj:getStaticQusetToQuestList(insRefid,currentMapRefId)	
	local expMax = 0	
	for i,v in pairs(questList) do
		local questid = v
		local propertyReward = QuestInstanceRefObj:getStaticQusetRewardProperty(insRefid,questid)
		if  propertyReward and  propertyReward.exp then
			expMax = expMax + propertyReward.exp
		end
	end
	local nowexp = createLabelWithStringFontSizeColorAndDimension(Config.Words[1507], "Arial", FSIZE("Size4")*viewScale, FCOLOR("ColorWhite1"))		
	self.instanceNode:addChild(nowexp)
	VisibleRect:relativePosition(nowexp,has,  LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-offsetPosY))	
	local nowexpWord = createLabelWithStringFontSizeColorAndDimension(expMax, "Arial", FSIZE("Size4")*viewScale, FCOLOR("ColorYellow1"))		
	self.instanceNode:addChild(nowexpWord)
	VisibleRect:relativePosition(nowexpWord,nowexp,  LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(5,0))
	
	--下层获得经验
	--local Layerlist = QuestInstanceRefObj:getStaticQusetToNextLayerRefId(insRefid,currentMapRefId)
	local nextMapRefId = self:getInstanceNextlayer(currentMapRefId)
	if nextMapRefId then
		local nexyquestList = QuestInstanceRefObj:getStaticQusetToQuestList(insRefid,nextMapRefId)	
		local nextexpMax = 0	
		for i,v in pairs(nexyquestList) do
			local questid = v
			local propertyReward = QuestInstanceRefObj:getStaticQusetRewardProperty(insRefid,questid)
			if  propertyReward and  propertyReward.exp then
				nextexpMax = nextexpMax + propertyReward.exp
			end
		end
		local nextexp = createLabelWithStringFontSizeColorAndDimension(Config.Words[1508], "Arial", FSIZE("Size4")*viewScale, FCOLOR("ColorWhite1"))		
		self.instanceNode:addChild(nextexp)
		VisibleRect:relativePosition(nextexp,nowexp,  LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-offsetPosY))	
		local nowexpWord = createLabelWithStringFontSizeColorAndDimension(nextexpMax, "Arial", FSIZE("Size4")*viewScale, FCOLOR("ColorYellow1"))		
		self.instanceNode:addChild(nowexpWord)
		VisibleRect:relativePosition(nowexpWord,nextexp,  LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(5,0))
	end				
	
end

function NpcInstanceView:getInstanceNextlayer(mapRefId)
	local count =  string.sub(mapRefId,2,-1)
	local numberCount = tonumber(count)
	if numberCount then
		numberCount = numberCount + 1
		local newmapRefId = "S"..numberCount
		return newmapRefId
	end		
end

function NpcInstanceView:createNextBtn()
	self.nextBtn = createButtonWithFramename(RES("btn_1_select.png"))	
	self:addChild(self.nextBtn)
	VisibleRect:relativePosition(self.nextBtn,self:getContentNode(), LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE,ccp(0,40))	
	
	local nextBtnWord = createLabelWithStringFontSizeColorAndDimension(Config.Words[3146], "Arial", FSIZE("Size4")*viewScale, FCOLOR("ColorWhite1"))		
	self.nextBtn:addChild(nextBtnWord)
	VisibleRect:relativePosition(nextBtnWord,self.nextBtn,  LAYOUT_CENTER)	
		
	local hero = G_getHero()
	local bagMgr = G_getBagMgr()
	local nextBtnfunc = function ()		
		if self.intanceRefId then
			local currentMapRefId =  GameWorld.Instance:getMapManager():getCurrentMapRefId()			
			local itemCount = QuestInstanceRefObj:getStaticQusetToNextLayerItemCount(self.intanceRefId,currentMapRefId)
			if not itemCount then
				CCLuaLog("NpcInstanceView:createNextBtn itemCount nil,currentMapRefId="..tostring(currentMapRefId))
				return
			end
			local itemRefId = QuestInstanceRefObj:getStaticQusetToNextLayerItemRefid(self.intanceRefId,currentMapRefId)
			local bagCount = bagMgr:getItemNumByRefId(itemRefId)
			if bagCount >= itemCount then
				local gameInstanceManager = GameWorld.Instance:getGameInstanceManager()
				gameInstanceManager:requestEnterNextLayer(self.intanceRefId)
				self:close()
			else
				local mObj = G_IsCanBuyInShop(itemRefId)
				if(mObj ~=  nil) then
					GlobalEventSystem:Fire(GameEvent.EventBuyItem,mObj, itemCount-bagCount)
				end
					
				--[[--如果7天没领
				local hadOperate = GameWorld.Instance:getNewGuidelinesMgr():hadOperate("activity_manage_2")
				if not hadOperate then
					local awardMgr = GameWorld.Instance:getAwardManager()
					awardMgr:requestReceiveState()
					GlobalEventSystem:Fire(GameEvent.EventOpenSevenLoginView)
					GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"NpcInstanceView")
				else					
					local mObj = G_IsCanBuyInShop(itemRefId)
					if(mObj ~=  nil) then
						GlobalEventSystem:Fire(GameEvent.EventBuyItem,mObj, itemCount-bagCount)
					end
				end--]]
			end			
		end
	end
	self.nextBtn:addTargetWithActionForControlEvents(nextBtnfunc, CCControlEventTouchDown)
end

function NpcInstanceView:updateView(bagCount)
	self.ownCount:setString(bagCount)		
end

----------------------------------------新手指引---------------------------------------
function NpcInstanceView:getEnterNextBtn()
	return self.nextBtn
end