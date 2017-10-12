--挖宝界面
require("ui.UIManager")
require("common.BaseUI")
require("ui.utils.ItemGridView")
require("config.words")
require("ui.utils.BatchItemView")
DigTreasureView = DigTreasureView or BaseClass(BaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local g_boxSize = CCSizeMake(95*g_scale,105*g_scale)

local const_pvr = "ui/ui_game/ui_game_bag.pvr"
local const_plist = "ui/ui_game/ui_game_bag.plist"
local ZHANSHI = 1
local FASHI = 2
local DAOSHI = 3
local ZHANSHI_MALE = 1
local ZHANSHI_FEMALE = 2
local FASHI_MALE = 3
local FASHI_FEMALE = 4
local DAOSHI_MALE = 5
local DAOSHI_FEMALE = 6

local btnWord = {
	[1] = 1,
	[2] = 10,
	[3] = 50,	
}
local titleWordText = {
	[1] = Config.Words[13510],
	[2] = Config.Words[13511],
	[3] = Config.Words[13512],

}
local consumeNum = {
	[1] = 200,
	[2] = 2000,
	[3] = 10000,
}
function DigTreasureView:__init()
	self.viewName = "DigTreasureView"	
	self.btn = {}	
	self.itemBgList = {}
	self.startIndex = 1
	self.endIndex = 10
	self.hasPlay = false
	self.stopFlag = false
	self.awardMgr = GameWorld.Instance:getAwardManager()	
	self.itemView = {}
	self.batchNode = SFSpriteBatchNode:create(const_pvr, 50)
	--self.batchNode = CCNode:create()	
	self:initWindow()
	self:initRewardLayer()
end

function DigTreasureView:__delete()
	self:clearItemView()
end

function DigTreasureView:clearItemView()
	local rootNode
	for key,v in pairs(self.itemView) do
		rootNode = v:getRootNode()
		if rootNode and rootNode:getParent() then
			rootNode:removeFromParentAndCleanup(true)
		end
		v:DeleteMe()
	end		
	self.itemView = {}
	self.batchNode:removeAllChildrenWithCleanup(true)
end

function DigTreasureView:onEnter()
	local tex = CCTextureCache:sharedTextureCache():addImage("ui/ui_img/activity/digTreasure_Bg.pvr")
	if self.bgImage then	
		self.bgImage:setTexture(tex)
		local pixelWidth = tex:getContentSizeInPixels().width
		local pixelHeight = tex:getContentSizeInPixels().height
		local texRect = CCRectMake(0,0,pixelWidth,pixelHeight)
		self.bgImage:setTextureRect(texRect)	
	end
	self:refreshUnbindedGold()
end

function DigTreasureView:onExit()
	local tex = self.bgImage:getTexture()
	if tex then
		self.bgImage:setTexture(nil)
		CCTextureCache:sharedTextureCache():removeTexture(tex)
		--CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()		--打log查看是否删除
	end		
end

function DigTreasureView:create()
	return DigTreasureView.New()
end	

function DigTreasureView:initWindow()
	self:initFullScreen()
	local titleImage = createSpriteWithFrameName(RES("main_activityMine.png"))
	self:setFormImage(titleImage)
	local titleWord = createSpriteWithFrameName(RES("word_window_digTreasure.png"))
	self:setFormTitle(titleWord,TitleAlign.Left)
	self.allBg = createScale9SpriteWithFrameNameAndSize(RES("faction_editBoxBg.png"),CCSizeMake(832,486))
	self:addChild(self.allBg)
	VisibleRect:relativePosition(self.allBg,self:getContentNode(),LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,-0))		
	self.bgImage = CCSprite:create()
	self.bgImage:setContentSize(CCSizeMake(658,361))
	self:addChild(self.bgImage)
	VisibleRect:relativePosition(self.bgImage,self.allBg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(8,-7))		
	
	local hero = G_getHero()
	if hero then
		local professionId = PropertyDictionary:get_professionId(hero:getPT())
		local professionName = G_getProfessionNameById(professionId)
		if professionName then
			local titleStr = string.format("%s%s%s",Config.Words[13502],professionName,Config.Words[13527])
			local titleDes = createLabelWithStringFontSizeColorAndDimension(titleStr,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
			self:addChild(titleDes)
			VisibleRect:relativePosition(titleDes,self.bgImage,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(-30,-5))
		end			
	end
	
	--[[local titleDes2 = createLabelWithStringFontSizeColorAndDimension(Config.Words[13527],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	self:addChild(titleDes2)
	VisibleRect:relativePosition(titleDes2,titleDes,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))--]]
	
	self.rightBg = createScale9SpriteWithFrameName(RES("countDownBg.png"))
	self.rightBg:setContentSize(CCSizeMake(158*g_scale,473*g_scale))
	self:addChild(self.rightBg)
	VisibleRect:relativePosition(self.rightBg,self.allBg,LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-6,-7))	
	
	self.bottomBg = createScale9SpriteWithFrameName(RES("countDownBg.png"))
	self.bottomBg:setContentSize(CCSizeMake(656*g_scale,108*g_scale))
	self:addChild(self.bottomBg)
	VisibleRect:relativePosition(self.bottomBg,self.bgImage,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))	
	
	self:initTouchLayer()
	self:initDigBtn()
	--self:initLeftUI()
	self:addItemIcon()
	self:initRightUI()	
end

function DigTreasureView:initTouchLayer()
	self.touchLayer = CCLayer:create()
	self.touchLayer:setContentSize(self:getContentNode():getContentSize())
	self:addChild(self.touchLayer)
	VisibleRect:relativePosition(self.touchLayer,self:getContentNode(), LAYOUT_CENTER)
	
	self.batchNode:setContentSize(self:getContentNode():getContentSize())
	self:addChild(self.batchNode, 10)
	VisibleRect:relativePosition(self.batchNode, self:getContentNode(), LAYOUT_CENTER)
	self:registerContentNodeTouchHandler(self.touchLayer)
	self.touchLayer:setTouchEnabled(true)
end

function DigTreasureView:touchHandle(x, y)
	local point = self.batchNode:convertToNodeSpace(ccp(x, y))
	for key, item in pairs(self.itemView) do
		local itemRootNode = item:getRootNode()
		if itemRootNode then
			if itemRootNode:boundingBox():containsPoint(point) then
				local itemObj = item:getItem()
				if itemObj then
					G_clickItemEvent(itemObj)
					return 1
				end
			end
		end
	end	
end

function DigTreasureView:registerContentNodeTouchHandler(node)
	local function ccTouchHandler(eventType, x, y)
		if eventType == "began" then		
			self:touchHandle(x, y)
			return 0
		elseif eventType == "moved" then			
		elseif eventType == "cancelled" then
			return 0
		elseif eventType == "ended" then			
			return 0
		end			
		return 0
	end
	node:registerScriptTouchHandler(ccTouchHandler, false, UIPriority.Control, true)
end

function DigTreasureView:initDigBtn()
	--底部挖宝按钮
	for i = 1,3 do
		self.btn[i] = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))		
		local btnFontLb = createSpriteWithFrameName(RES("digging_times.png"))
		local btnNumLb = createAtlasNumber(Config.AtlasImg.DiggingNum,btnWord[i])		
		--local btnLastLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[13514],"Arial",FSIZE("Size2"),FCOLOR("ColorYellow4"))
		self.btn[i]:setTitleString(btnFontLb)
		self.btn[i]:addChild(btnNumLb)
		--self.btn[i]:addChild(btnLastLb)
		--VisibleRect:relativePosition(btnFontLb,self.btn[i],LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(2,0))
		VisibleRect:relativePosition(btnNumLb,btnFontLb,LAYOUT_CENTER,ccp(10,0))
		--VisibleRect:relativePosition(btnLastLb,btnNumLb,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
		self:addChild(self.btn[i])
		VisibleRect:relativePosition(self.btn[i],self.bottomBg,LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(21+(i-1)*244,3))
		local digsFunc = function()	
			local hero = GameWorld.Instance:getEntityManager():getHero()
			local myGold = PropertyDictionary:get_unbindedGold(hero:getPT())
			if i == 1 then
				local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
				local cardNum =	bagMgr:getItemNumByRefId("item_giftcard")
				if cardNum > 0 then
					self.awardMgr:requestDigTreasure(i)
					return
				end
			end
			if myGold < consumeNum[i] then	--元宝不足
				local btns =
				{
					{text = Config.Words[13526],	id = 1},	
					{text = Config.Words[13317],		id = 0},	
				}												
				local rechargeFunc = function(arg,text,id)
					if id == 1 then
						--充值
						local rechargeMgr = GameWorld.Instance:getRechargeMgr()
						local rechargeFun = function(tag, state)
							if tag == "pay" then 	
								if state == 1 then 
									CCLuaLog("success")			
								else
									CCLuaLog("fail")
								end
							end
						end
						rechargeMgr:openPay(rechargeFun)
					end
				end											
				local msg = showMsgBox(Config.Words[13518])
				msg:setBtns(btns)
				msg:setNotify(rechargeFunc)											
				return
			end					
			self.awardMgr:requestDigTreasure(i)
			UIManager.Instance:showLoadingHUD(5,self:getContentNode())		
		end
		self.btn[i]:addTargetWithActionForControlEvents(digsFunc,CCControlEventTouchDown)	
		
		local titleImg = createScale9SpriteWithFrameNameAndSize(RES("digTreasure_Explain.png"),CCSizeMake(135,30))
		local icon = createSpriteWithFrameName(RES("common_iocnWind.png"))		
		local titleLb = createLabelWithStringFontSizeColorAndDimension(titleWordText[i],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"),CCSizeMake(0,0))				
		titleImg:addChild(icon)
		titleImg:addChild(titleLb)
		self:addChild(titleImg)
		VisibleRect:relativePosition(icon,titleImg,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(35,0))
		VisibleRect:relativePosition(titleLb,icon,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y)
		VisibleRect:relativePosition(titleImg,self.btn[i],LAYOUT_CENTER+LAYOUT_TOP_OUTSIDE,ccp(0,6))
	end
end

--[[function DigTreasureView:initLeftUI()
	--极品展示列表位置节点
	for i = 1 , 3 do
		self.itemBgList[i] = createButtonWithFramename(RES("common_seniorFrame.png"))
		self.batchNode:addChild(self.itemBgList[i])
	end
	VisibleRect:relativePosition(self.itemBgList[1],self.bgImage,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,35	))
	VisibleRect:relativePosition(self.itemBgList[2],self.bgImage,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(165,143))
	VisibleRect:relativePosition(self.itemBgList[3],self.bgImage,LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(-165,143))
	for i = 4,19 do
		--self.itemBgList[i] = CCNode:create()
		self.itemBgList[i] = createButtonWithFramename(RES("bagBatch_itemBg.png"))
		--self.itemBgList[i]:setContentSize(CCSizeMake(60,60))
		self.batchNode :addChild(self.itemBgList[i])
	end
	for i = 4,7 do
		VisibleRect:relativePosition(self.itemBgList[i],self.bgImage,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(11,-18-(i-4)*82))
	end
	for i = 8,11 do
		VisibleRect:relativePosition(self.itemBgList[i],self.bgImage,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(85,-18-(i-8)*82))
	end		
	for i = 12,15 do
		VisibleRect:relativePosition(self.itemBgList[i],self.bgImage,LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(-85,-18-(i-12)*82))
	end
	for i = 16,19 do
		VisibleRect:relativePosition(self.itemBgList[i],self.bgImage,LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(-11,-18-(i-16)*82))
	end
	--self:addItemIcon()
	
end--]]

function DigTreasureView:addItemIcon()
	local hero = G_getHero()
	if hero then
		local professionId = PropertyDictionary:get_professionId(hero:getPT())
		local gender = PropertyDictionary:get_gender(hero:getPT())
		local listCondition
		if not professionId or not gender then
			return
		else			
			if professionId == ZHANSHI then
				if gender == 1 then
					listCondition = ZHANSHI_MALE
				elseif gender == 2 then
					listCondition = ZHANSHI_FEMALE
				end
			elseif professionId == FASHI then
				if gender == 1 then
					listCondition = FASHI_MALE
				elseif gender == 2 then
					listCondition = FASHI_FEMALE
				end
			elseif professionId == DAOSHI then
				if gender == 1 then
					listCondition = DAOSHI_MALE
				elseif gender == 2 then
					listCondition = DAOSHI_FEMALE
				end
			end
			self.itemList = self.awardMgr:getDigTreasureShowList(listCondition)
		end
	end
	--极品展示列表物品图标	
	if self.itemList then
		local refId
		self:clearItemView()
		for i,v in pairs(self.itemList) do
			--if v.property.itemGroup == 1 then
				refId = v.property.itemRefId
				local index = tonumber(string.sub(i,10,-1))
				if index%19 == 0 then
					index = 19
				else
					index =index - math.floor(index/19)*19
				end
				--ItemView
				local itemObj = ItemObject.New()
				itemObj:setRefId(refId)				
				local staticData = G_getStaticDataByRefId(refId)
				itemObj:setStaticData(staticData)	
				local itemName = staticData.property.name
				if staticData.effectData~="" then
					local pt = table.cp(staticData.effectData)
					pt["fightValue"] = 0			
					itemObj:setPT(pt)
					local fightValue = G_getEquipFightValue(refId)
					if fightValue then
						itemObj:updatePT({fightValue = fightValue})	
					end		
				end
				PropertyDictionary:set_bindStatus(itemObj:getPT(),-1)					
				local itemView = BatchItemView.New()
				if not string.match(refId,"equip") then
					local number = v.property.number
					local pt = itemObj:getPT()
					if not pt then
						pt["number"] = 0
						itemObj:setPT(pt)						
					end
					itemObj:updatePT({number = number})
				end
				itemView:setItem(itemObj)
				itemView:showText(true)
				--local itemViewNode = itemView:getRootNode()
				--self.itemBgList[index]:addChild(itemViewNode)
				--VisibleRect:relativePosition(itemViewNode, self.itemBgList[index], LAYOUT_CENTER)
				--BatchItemView:setParent(parent, layout, offset)
				
				if index <= 3 then
					self:layoutCenterItem(itemView, index,itemName)
				elseif index >3 and index <= 11 then
					self:layoutLeftItem(itemView, index)
				elseif index > 11 then
					self:layoutRightItem(itemView, index)
				end					
				
				table.insert(self.itemView, itemView)	
				
				--[[local showItem = function()	
					G_clickItemEvent(itemObj)
				end
				self.itemBgList[index]:addTargetWithActionForControlEvents(showItem,CCControlEventTouchDown)--]]
				--[[local icon = G_createItemBoxByRefId(refId)
				local numLb = createLabelWithStringFontSizeColorAndDimension(v.property.number,"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
				if v.property.number ~= 1 then
					icon:addChild(numLb)
					VisibleRect:relativePosition(numLb,icon,LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE)
				end--]]
				
				--[[self.itemBgList[index]:addChild(icon)
				VisibleRect:relativePosition(icon,self.itemBgList[index],LAYOUT_CENTER)--]]
				itemObj:DeleteMe()
			--end
		end
	end
end

function DigTreasureView:layoutCenterItem(childNode, index,itemName)
	local bg = createSpriteWithFrameName(RES("common_seniorFrame.png"))	
	self.batchNode:addChild(bg)	
	
	childNode:setParent(self.batchNode, self.batchNode)
	local offset = nil	
	if index == 1 then
		offset = ccp(-75, -16)
	elseif index == 2 then
		offset = ccp(-187, 72)	
	elseif index == 3 then
		offset = ccp(34, 72)
	end
	if offset then
		childNode:layoutNormalRootNode(self.batchNode, LAYOUT_CENTER, offset)	
		childNode:layoutBatchRootNode(self.batchNode, LAYOUT_CENTER, offset)	
		VisibleRect:relativePosition(bg, self.batchNode, LAYOUT_CENTER, offset)	
		if itemName then
			local itemNameLb = createLabelWithStringFontSizeColorAndDimension(itemName,"Arial",FSIZE("Size2"),FCOLOR("ColorPurple2"))
			self.batchNode:addChild(itemNameLb)	
			VisibleRect:relativePosition(itemNameLb, bg, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE,ccp(0,5))	
		end
	end
end

function DigTreasureView:layoutLeftItem(childNode, index)
	local x1 = 24
	local x2 = 100
	childNode:setParent(self.batchNode, self.batchNode)
	local offset = nil
	if index == 4 then
		offset = ccp(x1, 183)
	elseif index ==5 then
		offset = ccp(x1, 103)
	elseif index == 6 then
		offset = ccp(x1, 23)
	elseif index == 7 then
		offset = ccp(x1, -57)
	elseif index ==8 then
		offset = ccp(x2, 183)
	elseif index == 9 then
		offset = ccp(x2, 103)
	elseif index == 10 then
		offset = ccp(x2, 23)
	elseif index == 11 then
		offset = ccp(x2, -57)
	end
	if offset then
		childNode:layoutNormalRootNode(self.batchNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, offset)	
		childNode:layoutBatchRootNode(self.batchNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, offset)		
	end
end

function DigTreasureView:layoutRightItem(childNode, index)
	local x1 = 127
	local x2 = 203
	local offset = nil
	childNode:setParent(self.batchNode, self.batchNode)
	if index == 12 then
		offset = ccp(x1, 183)
	elseif index ==13 then
		offset = ccp(x1, 103)
	elseif index == 14 then
		offset = ccp(x1, 23)
	elseif index == 15 then
		offset = ccp(x1, -57)
	elseif index ==16 then
		offset = ccp(x2, 183)
	elseif index == 17 then
		offset = ccp(x2, 103)
	elseif index == 18 then
		offset = ccp(x2, 23)
	elseif index == 19 then
		offset = ccp(x2, -57)
	end
	if offset then
		childNode:layoutNormalRootNode(self.batchNode, LAYOUT_CENTER, offset)	
		childNode:layoutBatchRootNode(self.batchNode, LAYOUT_CENTER, offset)
	end
end

function DigTreasureView:initRightUI()
	--挖宝说明标题
	local explainTitleBg = createScale9SpriteWithFrameNameAndSize(RES("digTreasure_Explain.png"),CCSizeMake(156,30))
	local explainTitle = createSpriteWithFrameName(RES("word_label_digTreasureExplain.png"))
	explainTitleBg:addChild(explainTitle)
	self:addChild(explainTitleBg)
	VisibleRect:relativePosition(explainTitle,explainTitleBg,LAYOUT_CENTER)
	VisibleRect:relativePosition(explainTitleBg,self.rightBg,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(3,0))	
	
	self.explainBg = createScale9SpriteWithFrameName(RES("mallCellBg.png"))
	self.explainBg:setContentSize(CCSizeMake(148*g_scale,164*g_scale))
	self:addChild(self.explainBg)
	VisibleRect:relativePosition(self.explainBg,explainTitleBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))	
	--挖宝说明文字标签
	--挖宝10次
	local explainFontLb_1 = createLabelWithStringFontSizeColorAndDimension(Config.Words[13500],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite2"))
	local explainNumLb_1 = createAtlasNumber(Config.AtlasImg.DiggingNum,10)
	local explainLastLb_1 = createLabelWithStringFontSizeColorAndDimension(Config.Words[13514],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite2"))
	--至少1次挖到极品
	local explainLb_1 = createLabelWithStringFontSizeColorAndDimension(Config.Words[13517],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite2"))
	local num_1 = createAtlasNumber(Config.AtlasImg.DiggingNum,1)
	local explainLb_1_last = createLabelWithStringFontSizeColorAndDimension(Config.Words[13515],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite2"))
	--挖宝50次
	local explainFontLb_2 = createLabelWithStringFontSizeColorAndDimension(Config.Words[13500],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite2"))
	local explainNumLb_2 = createAtlasNumber(Config.AtlasImg.DiggingNum,50)
	local explainLastLb_2 = createLabelWithStringFontSizeColorAndDimension(Config.Words[13514],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite2"))
	--至少7次挖到极品
	local explainLb_2 = createLabelWithStringFontSizeColorAndDimension(Config.Words[13517],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite2"))
	local num_2= createAtlasNumber(Config.AtlasImg.DiggingNum,7)
	local explainLb_2_last = createLabelWithStringFontSizeColorAndDimension(Config.Words[13515],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite2"))
	
	self:addChild(explainFontLb_1)
	self:addChild(explainNumLb_1)
	self:addChild(explainLastLb_1)
	
	self:addChild(explainFontLb_2)
	self:addChild(explainNumLb_2)
	self:addChild(explainLastLb_2)
	
	self:addChild(explainLb_1)
	self:addChild(num_1)
	self:addChild(explainLb_1_last)
	
	self:addChild(explainLb_2)
	self:addChild(num_2)
	self:addChild(explainLb_2_last)
	
	VisibleRect:relativePosition(explainFontLb_1,self.explainBg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(3,-5))
	VisibleRect:relativePosition(explainNumLb_1,explainFontLb_1,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
	VisibleRect:relativePosition(explainLastLb_1,explainNumLb_1,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
	
	VisibleRect:relativePosition(explainLb_1,explainFontLb_1,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	VisibleRect:relativePosition(num_1,explainLb_1,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
	VisibleRect:relativePosition(explainLb_1_last,num_1,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
	
	VisibleRect:relativePosition(explainFontLb_2,explainLb_1,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	VisibleRect:relativePosition(explainNumLb_2,explainFontLb_2,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
	VisibleRect:relativePosition(explainLastLb_2,explainNumLb_2,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
	
	VisibleRect:relativePosition(explainLb_2,explainFontLb_2,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	VisibleRect:relativePosition(num_2,explainLb_2,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
	VisibleRect:relativePosition(explainLb_2_last,num_2,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))	
	
	local useExplainLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[13524],"Arial",FSIZE("Size2"),FCOLOR("ColorYellow1"),CCSizeMake(148,0))
	self:addChild(useExplainLb)
	VisibleRect:relativePosition(useExplainLb,explainLb_2,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-12))
	--我的元宝标题
	local myMoneyTitleBg = createScale9SpriteWithFrameNameAndSize(RES("digTreasure_Explain.png"),CCSizeMake(156,30))
	local myMoneyTitle = createSpriteWithFrameName(RES("word_label_myGold.png"))
	myMoneyTitleBg:addChild(myMoneyTitle)
	self:addChild(myMoneyTitleBg)
	VisibleRect:relativePosition(myMoneyTitle,myMoneyTitleBg,LAYOUT_CENTER)
	VisibleRect:relativePosition(myMoneyTitleBg,self.explainBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-50))
	--我的元宝
	local goldIcon = createSpriteWithFrameName(RES("common_iocnWind.png"))
	self:addChild(goldIcon)
	VisibleRect:relativePosition(goldIcon,myMoneyTitleBg,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(10,-14))
	
	self.numFrame = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"),CCSizeMake(102,20))
	self:addChild(self.numFrame)
	VisibleRect:relativePosition(self.numFrame,goldIcon,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(10,2))
	
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local myGold = PropertyDictionary:get_unbindedGold(hero:getPT())
	self.goldNum = createLabelWithStringFontSizeColorAndDimension(myGold,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	
	self.numFrame:addChild(self.goldNum)
	VisibleRect:relativePosition(self.goldNum,self.numFrame,LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(6,0))	
	
	
	--我的挖宝卡
	local cardIcon = createSpriteWithFileName(ICON("item_giftcard"))
	cardIcon:setScale(0.35)
	self:addChild(cardIcon)
	VisibleRect:relativePosition(cardIcon,goldIcon,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-18))
	
	self.cardNumFrame = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"),CCSizeMake(102,20))
	self:addChild(self.cardNumFrame)
	VisibleRect:relativePosition(self.cardNumFrame,cardIcon,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(10,0))
	
	--local hero = GameWorld.Instance:getEntityManager():getHero()
--	local myGold = PropertyDictionary:get_unbindedGold(hero:getPT())
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	self.cardNum =	bagMgr:getItemNumByRefId("item_giftcard")
	self.cardNumLb = createLabelWithStringFontSizeColorAndDimension(self.cardNum,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	
	self.cardNumFrame:addChild(self.cardNumLb)
	VisibleRect:relativePosition(self.cardNumLb,self.cardNumFrame,LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(6,0))	
	
	--打开仓库按钮
	local openBtn = createButtonWithFramename(RES("digTreasure_Icon.png"))		
	G_setScale(openBtn)
	self.rightBg:addChild(openBtn)
	VisibleRect:relativePosition(openBtn, self.rightBg, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER, ccp(0, 10))	
	local openWarehouse = function()	
		self.awardMgr:requestWareHouseList()
	end
	openBtn:addTargetWithActionForControlEvents(openWarehouse,CCControlEventTouchDown)	
end

function DigTreasureView:refreshUnbindedGold()	
	--刷新我的元宝
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local myGold = PropertyDictionary:get_unbindedGold(hero:getPT())
	if self.goldNum then
		self.goldNum:setString(myGold)
		VisibleRect:relativePosition(self.goldNum,self.numFrame,LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(6,0))	
	end
end

function DigTreasureView:refreshGiftCard()
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local newNum = bagMgr:getItemNumByRefId("item_giftcard")
	if self.cardNum ~= newNum then
		self.cardNum = newNum
		self.cardNumLb:setString(self.cardNum)
		VisibleRect:relativePosition(self.cardNumLb,self.cardNumFrame,LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(6,0))	
	end
end

function DigTreasureView:showRewardAction()
	if not self.iconNode then
		self.iconNode = CCNodeRGBA:new()	
		self.rewardList = self.awardMgr:getUpdateShowList()	
		self.stopFlag = false
	end			
	if self.rewardList then	
		local listSize = table.size(self.rewardList)
		if listSize == 1 then
			self.iconNode:setContentSize(CCSizeMake(60,60))
		elseif listSize >= 10 then		
			self.iconNode:setContentSize(CCSizeMake(60*5,60*2))
		end
		if listSize <= 10 then
			if self.hasPlay == false then
				self:addRewardIcon(1,listSize)
				self.hasPlay = true
			elseif self.hasPlay == true then
				self:stopNodeAction()
				self.hasPlay = false
			end
		else
			if self.endIndex <= listSize then
				self:addRewardIcon(self.startIndex,self.endIndex)
				self.startIndex = self.startIndex + 10
				self.endIndex = self.endIndex + 10
			else
				self:stopNodeAction()
				self.startIndex = 1
				self.endIndex = 10
				self.stopFlag = true
			end
		end 
	end
end
function DigTreasureView:stopNodeAction()
	self:setRewardLayerShowState(false)
	self.iconNode:stopAllActions()
	self.iconNode:removeFromParentAndCleanup(true)			
	--self.iconNode:delete()
	self.iconNode = nil
end

function DigTreasureView:initRewardLayer()
	local function ccTouchHandler(eventType, x,y)	
		if self.stopFlag == false then
			self.iconNode:stopAllActions()
			VisibleRect:relativePosition(self.iconNode,self.rewardNode,LAYOUT_CENTER)
			self:showRewardFlyAway()
			self.stopFlag = true	
			return self:touchHandler(eventType, x, y)
		else
			return
		end	
	end
	local function ccBlockTouchHandler(eventType,x,y)
		return self:touchHandler(eventType, x, y)
	end
	self.rewardNode = CCLayerColor:create(ccc4(0,0,0,200))
	self.blockNode =CCLayer:create()
	self.rewardNode:setTouchEnabled(true)
	self.blockNode:setTouchEnabled(true)
	self.rewardNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.LoadingHUD, true)
	self.blockNode:registerScriptTouchHandler(ccBlockTouchHandler, false,UIPriority.LoadingHUD, true)
	self.rewardNode:setContentSize(visibleSize)	
	self.blockNode:setContentSize(visibleSize)							
	self.rootNode:addChild(self.rewardNode,1000)
	VisibleRect:relativePosition(self.rewardNode,self.rootNode,LAYOUT_CENTER)
	self.rootNode:addChild(self.blockNode,999)
	VisibleRect:relativePosition(self.blockNode,self:getContentNode(),LAYOUT_CENTER)
	self.rewardNode:setVisible(false)	
	self.blockNode:setVisible(false)
end

function DigTreasureView:addRewardIcon(startIndex,endIndex)
	for i = startIndex , endIndex do
		local refId = self.rewardList[i].refId
		local itemNum = self.rewardList[i].num
		local itemBox = G_createItemShowByItemBox(refId,nil,nil,nil,nil,-1)
		if not string.match(refId,"equip") then
			local itemNumLb = createLabelWithStringFontSizeColorAndDimension(itemNum,"Arial",FSIZE("Size3") * g_scale, FCOLOR("ColorGreen1"))
			itemBox:addChild(itemNumLb)
			VisibleRect:relativePosition(itemNumLb, itemBox,  LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(-4, 2))	
		end
		self.iconNode:addChild(itemBox)
		local widthLayout = ((i%5)-1)*70
		local heightLayout = -math.floor((i%10)/5)*70	
		VisibleRect:relativePosition(itemBox,self.iconNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(widthLayout,heightLayout))	
	end
	local child = self.rewardNode:getChildByTag(100)
	if child == nil then
		self.rewardNode:addChild(self.iconNode)
		self.iconNode:setTag(100)
		VisibleRect:relativePosition(self.iconNode,self.rewardNode,LAYOUT_CENTER)
	else
		VisibleRect:relativePosition(self.iconNode,self.rewardNode,LAYOUT_CENTER)
	end
	self:setRewardLayerShowState(true)
	local delay = CCDelayTime:create(1.5)
	local finishDelayFunc = function()
		self:showRewardFlyAway()
	end
	local callback = CCCallFunc:create(finishDelayFunc)
	local actionArray = CCArray:create()
	actionArray:addObject(delay)
	actionArray:addObject(callback)
	self.delayAction = CCSequence:create(actionArray)
	self.iconNode:runAction(self.delayAction)
end
function DigTreasureView:setRewardLayerShowState(bshow)
	self.rewardNode:setTouchEnabled(bshow)
	self.rewardNode:setVisible(bshow)	
	self.blockNode:setVisible(bshow)
end

function DigTreasureView:showRewardFlyAway()
	if self.iconNode then
		--[[if self.delayAction then
			self.iconNode:stopAction(self.delayAction)
		end--]]
		self.iconNode:setCascadeOpacityEnabled(true)		
		local curPosX,curPosY = self.iconNode:getPosition()
		local moveTo = CCMoveTo:create(0.5,ccp(curPosX,curPosY+60))
		local fadeOut = CCFadeOut:create(0.5)
		local spawnArray = CCArray:create()
		local actionArray = CCArray:create()
		spawnArray:addObject(moveTo)
		spawnArray:addObject(fadeOut)
		local spawn = CCSpawn:create(spawnArray)
		local finishFly = function()
			self.iconNode:stopAllActions()
			self.iconNode:removeAllChildrenWithCleanup(true)
			self:showRewardAction()
			self.stopFlag = false
		end
		local callBack = CCCallFunc:create(finishFly)
		actionArray:addObject(spawn)
		actionArray:addObject(callBack)
		self.iconNode:runAction(CCSequence:create(actionArray))
	end
end	