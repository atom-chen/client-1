require("common.BaseUI")
require("object.bag.BagDef")
require("ui.utils.ItemView")

EveryDayPayGiftBagView = EveryDayPayGiftBagView or BaseClass(BaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local width = 850*g_scale
local height = 370*g_scale

function EveryDayPayGiftBagView:__init()
	self.viewName = "EveryDayPayGiftBagView"
	self:init(CCSizeMake(width, height))
	self.payActivityMgr = GameWorld.Instance:getPayActivityManager()
	self.background:setVisible(false)
	self:initStaticView()	
	--self:createDesText(1888)
	self.itemView = {}	
end

function EveryDayPayGiftBagView:__delete()

end

function EveryDayPayGiftBagView:create()
	return EveryDayPayGiftBagView.New()
end

function EveryDayPayGiftBagView:initStaticView()
	--背景			
	self.pictureBgRight = CCSprite:create()
	self:addChild(self.pictureBgRight)
	VisibleRect:relativePosition(self.pictureBgRight, self:getContentNode(), LAYOUT_CENTER, ccp(244,-30))
	self.pictureBgLeft = CCSprite:create()
	self.pictureBgLeft:setScaleX(-1)
	self:addChild(self.pictureBgLeft)
	VisibleRect:relativePosition(self.pictureBgLeft, self:getContentNode(), LAYOUT_CENTER, ccp(-124,-30))	
	-- 妹子
	self.girlPicture = CCSprite:create()
	self:addChild(self.girlPicture)
	VisibleRect:relativePosition(self.girlPicture, self:getContentNode(), LAYOUT_CENTER, ccp(-270,-5))		
	-- 标题
	local titleText = createSpriteWithFrameName(RES("everyDayPayTitle.png"))
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
	--充值按钮	
	local payButton = createButtonWithFramename(RES("btn_normal1.png"), RES("btn_select1.png"))
	self:addChild(payButton)
	VisibleRect:relativePosition(payButton, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(15, -18))		
		
	local peyText = createSpriteWithFrameName(RES("payNowText.png"))
	payButton:setTitleString(peyText)
	local payFunc = function()
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
	payButton:addTargetWithActionForControlEvents(payFunc, CCControlEventTouchDown)	
end

function EveryDayPayGiftBagView:initWords()
	local word1 = createSpriteWithFrameName(RES("everyDayPayWord1.png"))
	local word2 = createSpriteWithFrameName(RES("firstPayWord1.png"))
	local word3 = createSpriteWithFrameName(RES("firstPayWord2.png"))
	local word4 = createSpriteWithFrameName(RES("firstPayWord3.png"))
	local word5 = createSpriteWithFrameName(RES("firstPayWord4.png"))
	local word6 = createSpriteWithFrameName(RES("everyDayPayWord2.png"))
	self:addChild(word1)
	word1:addChild(word2)
	word2:addChild(word3)
	word3:addChild(word4)
	word4:addChild(word5)
	word5:addChild(word6)
	VisibleRect:relativePosition(word1, self:getContentNode(), LAYOUT_CENTER, ccp(-165,115))
	VisibleRect:relativePosition(word2, word1, LAYOUT_RIGHT_OUTSIDE+LAYOUT_BOTTOM_INSIDE, ccp(-7,0))
	VisibleRect:relativePosition(word3, word2, LAYOUT_RIGHT_OUTSIDE+LAYOUT_BOTTOM_INSIDE, ccp(0,0))
	VisibleRect:relativePosition(word4, word3, LAYOUT_RIGHT_OUTSIDE+LAYOUT_BOTTOM_INSIDE, ccp(0,0))
	VisibleRect:relativePosition(word5, word4, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(-5,-10))
	VisibleRect:relativePosition(word6, word5, LAYOUT_RIGHT_OUTSIDE+LAYOUT_BOTTOM_INSIDE, ccp(0,0))
end

function EveryDayPayGiftBagView:createDesText(number)
	if self.descLabel then
		self.descLabel:removeFromParentAndCleanup(true)
	end
	local atlasName = Config.AtlasImg.PayGiftBagNumber
	self.descLabel = createAtlasNumber(atlasName, number)
	self:addChild(self.descLabel)
	VisibleRect:relativePosition(self.descLabel, self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X, ccp(-37, -53))
end

function EveryDayPayGiftBagView:updateView()
	self.giftBagList = self.payActivityMgr:getEveryPayObj()
	local number = self.giftBagList.worth
	for key,item in pairs(self.itemView) do
		ItemViewRootNode = item:getRootNode()
		if ItemViewRootNode and ItemViewRootNode:getParent() then
			ItemViewRootNode:removeFromParentAndCleanup(true)
		end
		item:DeleteMe()
	end
	self.itemView = {}
	self:createDesText(number)
	self:createItemView()		
end

function EveryDayPayGiftBagView:createItemView()
	local itemContainer = CCNode:create()
	itemContainer:setContentSize(CCSizeMake(545*g_scale, 250*g_scale))
	self:addChild(itemContainer)
	itemContainer:setTag(10)
	VisibleRect:relativePosition(itemContainer, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(64, -100))
	
	local itemList = self.giftBagList.itemList
	--领取物品品质背景，物品，数量
	local key = 0
	for i, item in pairs(itemList) do
		local itemRefId = item["refId"]	
		local number = item["number"]
		
		local itemBoxShow = G_createItemShowByItemBox(itemRefId,number,nil,nil,nil,-1)
		itemContainer:addChild(itemBoxShow)
		VisibleRect:relativePosition(itemBoxShow, itemContainer, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(key*100+50, 25))	
		
		key = key + 1
	end	
	self:createReceiveButton(itemContainer)
end

function EveryDayPayGiftBagView:onEnter()
	local texture = CCTextureCache:sharedTextureCache():addImage("ui/ui_img/activity/everyDayRechargeBg.pvr") 	
	local pixelWidth = texture:getContentSizeInPixels().width
	local pixelHeight = texture:getContentSizeInPixels().height
	local textRect = CCRectMake(0, 0, pixelWidth, pixelHeight)
	if self.pictureBgRight then
		self.pictureBgRight:setTexture(texture)	
		self.pictureBgRight:setTextureRect(textRect)
	end
	if self.pictureBgLeft then
		self.pictureBgLeft:setTexture(texture)	
		self.pictureBgLeft:setTextureRect(textRect)
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

function EveryDayPayGiftBagView:onExit()
	local texture = self.pictureBgRight:getTexture()
	if texture then
		self.pictureBgRight:setTexture(nil)
		CCTextureCache:sharedTextureCache():removeTexture(texture)
	end
	
	local girlTexture = self.girlPicture:getTexture()
	if girlTexture then
		self.girlPicture:setTexture(nil)
		CCTextureCache:sharedTextureCache():removeTexture(girlTexture)
	end
	
	local itemContainer = self:getContentNode():getChildByTag(10)
	if itemContainer then
		itemContainer:removeFromParentAndCleanup(true)
	end
	for key,item in pairs(self.itemView) do
		ItemViewRootNode = item:getRootNode()
		if ItemViewRootNode and ItemViewRootNode:getParent() then
			ItemViewRootNode:removeFromParentAndCleanup(true)
		end
		item:DeleteMe()
	end
	self.itemView = {}
end	

function EveryDayPayGiftBagView:createReceiveButton(itemContainer)
	local status = self.giftBagList.status	
		
	local receiveLabel = createSpriteWithFrameName(RES("receiveGiftText.png"))
	self.receiveButton = createButtonWithFramename(RES("btn_normal1.png"), RES("btn_select1.png"))
	self.receiveButton :setTitleString(receiveLabel)
	itemContainer:addChild(self.receiveButton )
	VisibleRect:relativePosition(self.receiveButton , itemContainer, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(15, 20))			
		
	--领取回调
	local receiveFun = function ()	
		status = self.giftBagList.status	
		if status == 0 then
			UIManager.Instance:showSystemTips(Config.Words[13716])
		elseif status == 1 then
			self.payActivityMgr:requestReceiveEveryDayPayGiftBag()	
		elseif status == 2 then
			UIManager.Instance:showSystemTips(Config.Words[13718])	
		end
	end
	self.receiveButton :addTargetWithActionForControlEvents(receiveFun, CCControlEventTouchUpInside)	
	
end

function EveryDayPayGiftBagView:receiveEveryDayPayGiftBag()
	UIManager.Instance:showSystemTips(Config.Words[13717])
	self.giftBagList.status = 2		
	self.payActivityMgr:requestCanReceiveActivityList()	
end