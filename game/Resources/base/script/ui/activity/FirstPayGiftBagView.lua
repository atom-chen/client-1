require("common.BaseUI")
require("object.bag.BagDef")
require("ui.utils.ItemView")

FirstPayGiftBagView = FirstPayGiftBagView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local width = 850*g_scale
local height = 374*g_scale

function FirstPayGiftBagView:__init()
	self.viewName = "FirstPayGiftBagView"
	self:init(CCSizeMake(width, height))
	self.payActivityMgr = GameWorld.Instance:getPayActivityManager()
	self.firstPayObj = self.payActivityMgr:getFirstPayObj()	
	self:initStaticView()
	self:createButton()	
	self.background:setVisible(false)
end

function FirstPayGiftBagView:__delete()

end

function FirstPayGiftBagView:onEnter()
	local texture = CCTextureCache:sharedTextureCache():addImage("ui/ui_img/activity/everyDayRechargeBg.pvr") 
	local pixelWidth = texture:getContentSizeInPixels().width
	local pixelHeight = texture:getContentSizeInPixels().height
	local textRect = CCRectMake(0, 0, pixelWidth, pixelHeight)
	if self.itemViewRightBg then
		self.itemViewRightBg:setTexture(texture)
		self.itemViewRightBg:setTextureRect(textRect)
	end
	if self.itemViewLeftBg then
		self.itemViewLeftBg:setTexture(texture)
		self.itemViewLeftBg:setTextureRect(textRect)
	end
	local girlTexture = CCTextureCache:sharedTextureCache():addImage("ui/ui_img/activity/giftGirl1.pvr")
	if self.girlPicture then
		self.girlPicture:setTexture(girlTexture)
		local pixelWidth = girlTexture:getContentSizeInPixels().width
		local pixelHeight = girlTexture:getContentSizeInPixels().height
		local textRect = CCRectMake(0, 0, pixelWidth, pixelHeight)
		self.girlPicture:setTextureRect(textRect)
	end
end

function FirstPayGiftBagView:onExit()
	local texture = self.itemViewRightBg:getTexture()
	if texture then
		self.itemViewRightBg:setTexture(nil)
		CCTextureCache:sharedTextureCache():removeTexture(texture)
	end	
	local girlTexture = self.girlPicture:getTexture()
	if girlTexture then
		self.girlPicture:setTexture(nil)
		CCTextureCache:sharedTextureCache():removeTexture(girlTexture)
	end	
	if self.awardDes then
		self.awardDes:removeFromParentAndCleanup(true)
		self.awardDes = nil
	end	
		
	if self.node then
		self.node:removeFromParentAndCleanup(true)		
		self.node = nil		
	end
end

function FirstPayGiftBagView:initStaticView()
	--背景	
	self.itemViewRightBg = CCSprite:create()
	self:addChild(self.itemViewRightBg)
	VisibleRect:relativePosition(self.itemViewRightBg, self:getContentNode(), LAYOUT_CENTER, ccp(244,-30))
	self.itemViewLeftBg = CCSprite:create()
	self.itemViewLeftBg:setScaleX(-1)
	self:addChild(self.itemViewLeftBg)
	VisibleRect:relativePosition(self.itemViewLeftBg, self:getContentNode(), LAYOUT_CENTER, ccp(-124,-30))	
	-- 妹子
	self.girlPicture = CCSprite:create()
	self:addChild(self.girlPicture)
	VisibleRect:relativePosition(self.girlPicture, self:getContentNode(), LAYOUT_CENTER, ccp(-270,-5))	
	-- 标题
	local titleText = createSpriteWithFrameName(RES("firstPayTitle.png"))
	self:addChild(titleText)
	VisibleRect:relativePosition(titleText, self:getContentNode(), LAYOUT_CENTER, ccp(0,180))
	-- 礼花	
	local payFlower = createSpriteWithFrameName(RES("payFlower.png"))
	self:addChild(payFlower)
	VisibleRect:relativePosition(payFlower, self:getContentNode(), LAYOUT_CENTER, ccp(340,95))
	--半透明黑影图片
	local halfBackColor = CCLayerColor:create(ccc4(0, 0, 0, 200))
	halfBackColor:setContentSize(visibleSize)
	self:addChild(halfBackColor, -1)
	VisibleRect:relativePosition(halfBackColor, self:getContentNode(), LAYOUT_CENTER, ccp(0, 15))
	self:initWords()
end

function FirstPayGiftBagView:initWords()
	local word1 = createSpriteWithFrameName(RES("firstPayWord1.png"))
	local word2 = createSpriteWithFrameName(RES("firstPayWord2.png"))
	local word3 = createSpriteWithFrameName(RES("firstPayWord3.png"))
	local word4 = createSpriteWithFrameName(RES("firstPayWord4.png"))
	local word5 = createSpriteWithFrameName(RES("firstPayWord5.png"))
	
	if (not word1) or (not word2) or (not word3) or (not word4) or (not word5) then --如果word创建失败，则不执行下面逻辑
		CCLuaLog("FirstPayGiftBagView:initWords create word failed")
		return
	end
	self:addChild(word1)
	word1:addChild(word2)
	word2:addChild(word3)
	word3:addChild(word4)
	word4:addChild(word5)
	VisibleRect:relativePosition(word1, self:getContentNode(), LAYOUT_CENTER, ccp(-165,115))
	VisibleRect:relativePosition(word2, word1, LAYOUT_RIGHT_OUTSIDE+LAYOUT_BOTTOM_INSIDE, ccp(0,0))
	VisibleRect:relativePosition(word3, word2, LAYOUT_RIGHT_OUTSIDE+LAYOUT_BOTTOM_INSIDE, ccp(0,0))
	VisibleRect:relativePosition(word4, word3, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(25,-10))
	VisibleRect:relativePosition(word5, word4, LAYOUT_RIGHT_OUTSIDE+LAYOUT_BOTTOM_INSIDE, ccp(0,0))
end

function FirstPayGiftBagView:create()
	return FirstPayGiftBagView.New()
end

function FirstPayGiftBagView:createButton()
	--充值按钮
	local payButton = createButtonWithFramename(RES("btn_normal1.png"), RES("btn_select1.png"))
	local payText = createSpriteWithFrameName(RES("payNowText.png"))
	self:addChild(payButton)
	payButton:setTitleString(payText)
	VisibleRect:relativePosition(payButton, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(28, -80))
	--充值回调
	local payFun = function ()	
		local pay = function (tag, state)
			if tag == "pay" then 	
				if state == 1 then 
					CCLuaLog("success")			
				else
					CCLuaLog("fail")
				end
			end
		end
		local rechargeMgr = GameWorld.Instance:getRechargeMgr()
		rechargeMgr:openPay(pay)
	end
	payButton:addTargetWithActionForControlEvents(payFun,CCControlEventTouchDown)
	--领取按钮	
	local receiveButton = createButtonWithFramename(RES("btn_normal1.png"), RES("btn_select1.png"))
	local receiveText = createSpriteWithFrameName(RES("receiveGiftText.png"))
	receiveButton:setTitleString(receiveText)
	self:addChild(receiveButton)
	VisibleRect:relativePosition(receiveButton, self:getContentNode(), LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-50, -80))
	--领取回调
	local receiveFun = function ()
		local status = nil
		if self.firstPayObj then
			status = self.firstPayObj.status
		end
		
		if status and status==1 then
			self.payActivityMgr:requestFirstPayReceive()										
		elseif status and status==0 then
			UIManager.Instance:showSystemTips(Config.Words[13712])
		elseif status and status==2 then
			UIManager.Instance:showSystemTips(Config.Words[13735])
		end										
	end
	receiveButton:addTargetWithActionForControlEvents(receiveFun,CCControlEventTouchUpInside)
end

function FirstPayGiftBagView:receiveFirstPayGiftBag()
	self.payActivityMgr:requestCanReceiveActivityList()	
	self.firstPayObj.status = 2	
end

function FirstPayGiftBagView:updateView()
	self.firstPayObj = self.payActivityMgr:getFirstPayObj()
	self:createItem()
end

function FirstPayGiftBagView:createItem()
	--奖励描述
	self.node = CCNode:create()
	self.node:setContentSize(CCSizeMake(546, 184))
	local worthValue = self.firstPayObj["worth"]	
	local atlasName = Config.AtlasImg.PayGiftBagNumber
	self.awardDes  = createAtlasNumber(atlasName, worthValue)	
	self:addChild(self.awardDes)
	VisibleRect:relativePosition(self.awardDes, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(-70, -55))	
	--最上面的物品TODO	
	
	local itemList = self.firstPayObj.itemList
	--领取物品品质背景，物品，数量
	local itemRefId, quality	
	local itemIcon, itemNumLabel, bindSprite	
	local key = 0
	for i, item in pairs(itemList) do
		local itemRefId = item["refId"]	
		local number = item["number"]
		local itemBoxShow = G_createItemShowByItemBox(itemRefId,number,nil,nil,nil,-1)
		self.node:addChild(itemBoxShow)
		VisibleRect:relativePosition(itemBoxShow, self.node, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(key*90, 0))		
		key = key + 1		
	end	
	self:addChild(self.node)
	VisibleRect:relativePosition(self.node, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(82, 25))
end