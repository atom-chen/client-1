InstanceAchieveView = InstanceAchieveView or BaseClass(BaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local Gproperty = 1
local Gitem = 2

local ProfessionGenderModel =
{
	[1] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderMale , tImage = "role_modelManWarior.png"},
	[2] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderFemale , tImage = "role_modelFemanWarior.png"},
	[3] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderMale , tImage = "role_modelManMagic.png"},
	[4] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderFemale , tImage = "role_modelFemanMagic.png"},
	[5] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderMale , tImage = "role_modelManDaoshi.png"},
	[6] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderFemale , tImage = "role_modelFemanDaoshi.png"}
}

function InstanceAchieveView:__init()
	self.viewName = "InstanceAchieveView"
	
	self:initStaticView()	
end

function InstanceAchieveView:__delete()
	
end

function InstanceAchieveView:create()
	return InstanceAchieveView.New()
end

function InstanceAchieveView:initStaticView()
			
	-- ±³¾°²ã
	local viewBgLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	viewBgLayer:setContentSize(visibleSize)
	self:addChild(viewBgLayer, -1)
	VisibleRect:relativePosition(viewBgLayer, self:getContentNode(), LAYOUT_CENTER,ccp(0,0))
	
	-- ±³¾°
	self.viewTopBg = createScale9SpriteWithFrameName(RES("instanceAcheieveBg.png"))
	self.viewTopBg:setScaleX(5.5)
	self:addChild(self.viewTopBg)
	VisibleRect:relativePosition(self.viewTopBg, self:getContentNode(), LAYOUT_CENTER, ccp(60,85))	
	self.viewBottomBg = createScale9SpriteWithFrameName(RES("instanceAcheieveBg.png"))
	self.viewBottomBg:setScaleY(-1)
	self.viewBottomBg:setScaleX(5.5)
	self:addChild(self.viewBottomBg)
	VisibleRect:relativePosition(self.viewBottomBg, self:getContentNode(), LAYOUT_CENTER, ccp(60,-85))	
	
	self.viewBgCircle = CCSprite:create("ui/ui_img/activity/instanceAcheieveCircle.pvr")--createSpriteWithFrameName(RES("instanceAcheieveCircle.png"))
	self:addChild(self.viewBgCircle)
	VisibleRect:relativePosition(self.viewBgCircle, self:getContentNode(), LAYOUT_CENTER, ccp(-250,60))
	
	local pictureName
	local heroObj = GameWorld.Instance:getEntityManager():getHero()
	local heroProfessionId = PropertyDictionary:get_professionId(heroObj:getPT())
	local genderId = PropertyDictionary:get_gender(heroObj:getPT())
	for k,v in pairs(ProfessionGenderModel) do
		if v.tProfession == heroProfessionId and v.tGender == genderId then
			pictureName = v.tImage
		end	
	end
	
	if pictureName then
		local roleFigure = createSpriteWithFrameName(RES(pictureName))
		self.viewBgCircle:addChild(roleFigure)
		VisibleRect:relativePosition(roleFigure, self.viewBgCircle, LAYOUT_CENTER, ccp(0,-50))
	end
	
	-- ÎÄ×ÖËµÃ÷
	self.resultLableText = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"),CCSizeMake(0,0))
	self.resultLableText:setAnchorPoint(ccp(0,0.5))
	self.viewBgCircle:addChild(self.resultLableText)		
	VisibleRect:relativePosition(self.resultLableText,self.viewBgCircle,LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE,ccp(-40,-210))
	
	local awardLableText = createLabelWithStringFontSizeColorAndDimension(Config.Words[3132],"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"),CCSizeMake(0,0))
	self.resultLableText:addChild(awardLableText)		
	VisibleRect:relativePosition(awardLableText,self.resultLableText,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(20,-15))
	
	self.awardSpriteText = createSpriteWithFrameName(RES("instanceAcheieveAward.png"))
	awardLableText:addChild(self.awardSpriteText)
	VisibleRect:relativePosition(self.awardSpriteText, awardLableText, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0,0))
	
	-- °´Å¥
	local btnFunc = function()	
		--[[local manager = GameWorld.Instance:getGameInstanceManager()
		manager:requestLeaveGameInstance(refId)--]]
		self:close()	
		local manager = GameWorld.Instance:getGameInstanceManager()
		manager:requestGetQuestReward()
		manager:requestLeaveGameInstance()		
		manager:leaveInstance()		
	end
	self.funcBtn = createButtonWithFramename(RES("btn_1_select.png"))
	self.funcBtn:addTargetWithActionForControlEvents(btnFunc,CCControlEventTouchDown)		
	self.viewBgCircle:addChild(self.funcBtn)
	VisibleRect:relativePosition(self.funcBtn, self.viewBgCircle, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_OUTSIDE, ccp(165, 25))
	
	local funcBtnText = createSpriteWithFrameName(RES("word_button_sure.png"))
	self.funcBtn:setTitleString(funcBtnText)
	VisibleRect:relativePosition(funcBtnText, self.funcBtn, LAYOUT_CENTER)
	
	local cancelBtnFunc = function()		
		self:close()
		local manager = GameWorld.Instance:getGameInstanceManager()
		if manager:getIsInstanceFinished() then
			manager:setFinishInstanceArrow("show")
		end		
	end
	self.cancelBtn = createButtonWithFramename(RES("btn_1_select.png"))
	self.cancelBtn:addTargetWithActionForControlEvents(cancelBtnFunc,CCControlEventTouchDown)		
	self.viewBgCircle:addChild(self.cancelBtn)
	
	VisibleRect:relativePosition(self.cancelBtn, self.viewBgCircle, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_OUTSIDE, ccp(-30, 25))
	
	local cancelBtnText = createSpriteWithFrameName(RES("word_button_cancel.png"))
	self.cancelBtn:setTitleString(cancelBtnText)
	VisibleRect:relativePosition(cancelBtnText, self.cancelBtn, LAYOUT_CENTER)
	
	
end

function InstanceAchieveView:onEnter()
	self:initAchieveData()
	self:updateAchieveSign()
	self:updateAchieveResult()
	self:updateAwardItem()
end

function InstanceAchieveView:initAchieveData()
	self.questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	self.instanceId = self.questMgr:getInstanceRefId()
	self.bInBag,self.instanceList,self.passInstanceTime = self.questMgr:getInstanceRewordList()	
	
	self.awardDataList = {}
	
	for i,v in pairs(self.instanceList) do
		local propertyRewardList = {}
		local itemRewardList = {}
		local questRefId = v
		--ÊôÐÔ½±Àø		
		local propertyReward = QuestRefObj:getStaticQusetRewardProperty(QuestType.eQuestTypeInstance,questRefId,self.instanceId)		
		if propertyReward~=nil then
			for j,v in pairs(propertyReward) do
				local itemRefId = j
				local itemCount = v						
				self:insertAwardList(Gproperty,itemRefId,itemCount)		
			end				
		end
		--µÀ¾ß½±Àø
		local itemReward = QuestRefObj:getStaticQusetItemReward(QuestType.eQuestTypeInstance,questRefId,self.instanceId)
		if itemReward~=nil then
			for l,v in pairs(itemReward) do			
				local tItemList = v					
				local itemCount = QuestRefObj:getStaticQusetItemListItemCount(tItemList)
				local itemRefId = QuestRefObj:getStaticQusetItemListItemRefId(tItemList)
				self:insertAwardList(Gitem,itemRefId,itemCount)				
			end				
		end
	end
	self:sortAwardList()
end

function InstanceAchieveView:insertAwardList(itemType,itemRefId,itemCount)
	bInsert = false
	for i,v in pairs(self.awardDataList) do
		if v.RefId == itemRefId then
			v.Count = v.Count + itemCount
			bInsert = true
		end
	end
	
	if not bInsert then
		local list = {RefId = itemRefId,Type = itemType,Count = itemCount}
		table.insert(self.awardDataList,list)
	end				
end

function InstanceAchieveView:sortAwardList()	
	function sortType(a, b)
		if b.Type > a.Type then
			return  a.Type < b.Type			
		end
	end
	table.sort(self.awardDataList, sortType)	
end	

function InstanceAchieveView:updateAchieveSign()
	if self.achieveSign then
		self.achieveSign:removeFromParentAndCleanup(true)
	end
	if true then
		self.achieveSign = createScale9SpriteWithFrameName(RES("instanceAcheieveClearance.png"))
		self.viewBgCircle:addChild(self.achieveSign)
		VisibleRect:relativePosition(self.achieveSign,self.viewBgCircle, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE,ccp(0,-80))
	end
end

function InstanceAchieveView:updateAchieveResult()
	local date = ""
	local time = ""
	if self.passInstanceTime then
		local SystemTime = math.floor(self.passInstanceTime/1000)
		date = os.date("%Y/%m/%d", SystemTime) 
		time = os.date("%H"..Config.Words[3128].."%M"..Config.Words[3129], SystemTime)	
	end				
	if not date then
		date = " "
	end
	if not time then
		time = " "
	end	
	local name = QuestInstanceRefObj:getStaticInstanceName(self.instanceId)
	if not name then
		name = " "
	end
	local achieveResultText = Config.Words[3134]..date..","..time..Config.Words[3130]..name..Config.Words[3131]	
	self.resultLableText:setString(achieveResultText)
end

function InstanceAchieveView:updateAwardItem()	
	local itemList = {}
	for k, v in pairs(self.awardDataList) do
		local itemNode = CCNode:create()
		itemNode:setContentSize(VisibleRect:getScaleSize(CCSizeMake(80, 110)))		
			
		local itemBoxShow = G_createItemShowByItemBox(v.RefId,v.Count,nil,nil,nil,-1)
		itemNode:addChild(itemBoxShow)
		VisibleRect:relativePosition(itemBoxShow,itemNode, LAYOUT_CENTER)	

		if itemNode then
			itemList[k] = itemNode
		end
	end
	
	local height = itemList[1]:getContentSize().height
	local width = itemList[1]:getContentSize().width * table.getn(itemList)
	local viewSize = CCSizeMake(width, height)
	
	local container = CCNode:create()
	container:setContentSize(viewSize)
	G_layoutContainerNode(container, itemList, 0, E_DirectionMode.Horizontal, viewSize, true)	
	
	if self.awardScrollView then
		self.awardScrollView:removeFromParentAndCleanup(true)
		self.awardScrollView = nil
	end
	self.awardScrollView = createScrollViewWithSize(viewSize)
	self.awardScrollView:setContainer(container)
	self.awardScrollView:setDirection(1)
	self.awardSpriteText:addChild(self.awardScrollView)
	VisibleRect:relativePosition(self.awardScrollView, self.awardSpriteText, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE, ccp(0, 0))
end