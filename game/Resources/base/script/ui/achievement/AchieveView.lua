require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.achievement.AchieveTabView")

AchieveView = AchieveView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

function AchieveView:__init()
	self.viewName = "AchieveView"
	self:initFullScreen()
	self.tabView = AchieveTabView.New(self : getContentNode())
	local titleImage = createSpriteWithFrameName(RES("main_achieve.png"))
	self:setFormImage(titleImage)
	local titleWord = createSpriteWithFrameName(RES("word_window_achievement.png"))
	self:setFormTitle(titleWord,TitleAlign.Left)	
	self:registerScriptTouchHandler()
	
	self:initAchieveNum()
	self:initGetAllRewardBtn()
	self:initExchangeBtn()	
	
end
function AchieveView:onEnter()
	local achieveMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()	
	local newReward = achieveMgr:checkNewReward()
	self:setGetAllRewardBtn(newReward)
	self:refreshAchieveNum()
	if self.tabView then
		self.tabView:onEnter()
	end	
end
function AchieveView:enterTabView(tag)
	self.tabView:enterSubView(tag)
end
function AchieveView:refreshSubScroll(key,cellIndex)
	self.tabView:refreshSubScroll(key,cellIndex)
end
function AchieveView:refreshTableView(vType)
	self.tabView:refreshTableView(vType)
end
function AchieveView:setSelIndex(index)
	self.tabView:setSelIndex(index)
end
function AchieveView:checkNewImage(achieveType)
	self.tabView:checkNewImage(achieveType)
	self.tabView:checkClearImage(achieveType)
end

function AchieveView:onExit()
	self.tabView :onExit()
end
function AchieveView:create()
	return AchieveView.New()
end

function AchieveView:__delete()
	self.tabView:DeleteMe()
end
function AchieveView:initAchieveNum()
	local g_hero = GameWorld.Instance:getEntityManager():getHero()
	self.achievement = PropertyDictionary:get_achievement(g_hero:getPT())	
	self.achiNumTitle = createScale9SpriteWithFrameName(RES("common_achievementNumber.png"))
	G_setScale(self.achiNumTitle)
	self : addChild(self.achiNumTitle)
	VisibleRect:relativePosition(self.achiNumTitle,self : getContentNode(),LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(-150,30))
	self.achiNum = createLabelWithStringFontSizeColorAndDimension(self.achievement, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	self : addChild(self.achiNum)
	VisibleRect:relativePosition(self.achiNum,self.achiNumTitle,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(20,0))
end

function AchieveView:refreshAchieveNum(achiNum)
	if achinum == nil then
		if not self.achiNum then
			return
		else
			local g_hero = GameWorld.Instance:getEntityManager():getHero()
			self.achievement = PropertyDictionary:get_achievement(g_hero:getPT())	
			self.achiNum:setString(self.achievement)
		end
	else
		if(achiNum ~= 0 and achiNum ~= self.achievement) then
			self.achievement = achiNum
			self.achiNum:setString(self.achievement)
		end
	end		
end

function AchieveView:initGetAllRewardBtn()
	local achieveMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()		
	self.getAllBtn = createButtonWithFramename(RES("btn_1_select.png"))
	self.unGetAllBtn = createSpriteWithFrameName(RES("btn_1_select.png"))
	UIControl:SpriteSetGray(self.unGetAllBtn)	
	local getAllWord = createSpriteWithFrameName(RES("word_button_getallreword.png"))
	local unGetAllWord = createSpriteWithFrameName(RES("word_button_getallreword.png"))
	UIControl:SpriteSetGray(unGetAllWord)
	self.getAllBtn:setTitleString(getAllWord)
	self.unGetAllBtn:addChild(unGetAllWord)
	VisibleRect:relativePosition(unGetAllWord,self.unGetAllBtn,LAYOUT_CENTER)
	self:addChild(self.getAllBtn)
	VisibleRect:relativePosition(self.getAllBtn,self:getContentNode(),LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(-20,-15))
	self:addChild(self.unGetAllBtn)
	VisibleRect:relativePosition(self.unGetAllBtn,self.getAllBtn,LAYOUT_CENTER,ccp(0,2))
	self.unGetAllBtn:setVisible(false)
	local getAllReward = function()	
		achieveMgr:requestAchievementGetAllReward()					
	end
	self.getAllBtn:addTargetWithActionForControlEvents(getAllReward,CCControlEventTouchDown)	
	local newReward = achieveMgr:checkNewReward()
	self:setGetAllRewardBtn(newReward)
end	

function AchieveView:resetButtonState()
	local achieveMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()
	achieveMgr:getAllReward()
	local newReward = achieveMgr:checkNewReward()
	self:setGetAllRewardBtn(newReward)	
	for i = 1,6 do
		self.tabView:checkClearImage(i)
	end
	self.tabView:hideAllReciveBtn()	
	self.tabView:hideNewImage()	
end

function AchieveView:initExchangeBtn()
	local achieveMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()		
	local exchangeBtn = createButtonWithFramename(RES("btn_1_select.png"))	
	local exchangeWord = createSpriteWithFrameName(RES("redeem_oints.png"))	
	exchangeBtn:setTitleString(exchangeWord)	
	self:addChild(exchangeBtn)
	VisibleRect:relativePosition(exchangeBtn,self.getAllBtn,LAYOUT_CENTER_Y+LAYOUT_LEFT_OUTSIDE,ccp(-10,0))
	local gotoExchangeNpc = function()	
		local hero = G_getHero()
		local heroLv = PropertyDictionary:get_level(hero:getPT())
		if heroLv < 10 then
			UIManager.Instance:showSystemTips(Config.Words[6529])
		else
			local vipMgr = GameWorld.Instance:getVipManager()   
			local vipLevel =  vipMgr:getVipLevel() 
			local gameMapManager = GameWorld.Instance:getMapManager()
			if vipLevel == 0 or (not gameMapManager:checkCanUseFlyShoes()) then
				local mapManager = GameWorld.Instance:getMapManager()
				local isInActivity = mapManager:isInGameAcitvity()
				local isInInstance = mapManager:isInGameInstance()
				if isInActivity == true or isInInstance == true then
					UIManager.Instance:showSystemTips(Config.Words[6532])
				else
					local AutoPathMgr = GameWorld.Instance:getAutoPathManager()
					AutoPathMgr:find("npc_16","S002")	
					self:close()
				end										
			else													
				local transferFun = function(arg,text,id)
					if id == 2 then
						local npcPosX,npcPosY = achieveMgr:getExchangeMedalNpcPos()
						gameMapManager:requestTransfer("S002", npcPosX,npcPosY,1)
						G_getHandupMgr():stop()
						self:close()
					end
				end							
				local msg = showMsgBox(Config.Words[6531],E_MSG_BT_ID.ID_CANCELAndOK)	
				msg:setNotify(transferFun)
			end
		end
	end
	exchangeBtn:addTargetWithActionForControlEvents(gotoExchangeNpc,CCControlEventTouchDown)	
end

function AchieveView:setGetAllRewardBtn(rewardFlag)
	if not self.getAllBtn then
		return
	end
	if rewardFlag == true then
		self.getAllBtn:setVisible(true)
		self.unGetAllBtn:setVisible(false)
	elseif rewardFlag == false then
		self.getAllBtn:setVisible(false)
		self.unGetAllBtn:setVisible(true)
	end
end	
--ÆÁÄ»×óÓÒ»¬¶¯ÊÂ¼þ
function AchieveView:registerScriptTouchHandler()
	local function ccTouchHandler(eventType, x,y)
		return self:touchHandler(eventType, x, y)
	end
	self.rootNode:registerScriptTouchHandler(ccTouchHandler,false,UIPriority.Control,true)
end

function AchieveView:touchHandler(eventType, x, y)
	self.endX = nil
	if(eventType == "began") then
		self.beganX = x
	elseif(eventType == "ended") then
		self.endX = x	
	end
	if(self.beganX ~= nil and self.endX ~= nil and (self.beganX+100)<self.endX) then
		self.tabView : turnNextPage()
	elseif(self.beganX ~= nil and self.endX ~= nil and (self.beganX-100)>self.endX)  then
		self.tabView : turnFontPage()
	end
	if self : getContentNode():isVisible() and self : getContentNode():getParent() then	
		local parent = self : getContentNode():getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = self : getContentNode():boundingBox()
		if rect:containsPoint(point) then
			
			return 1
		else
			return 0
		end
	else
		return 0
	end
	
end