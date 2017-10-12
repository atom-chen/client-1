require("object.npc.NpcDef")
require("data.npc.npc")
require("ui.Npc.NpcBaseView")

VipAwardView = VipAwardView or BaseClass(NpcBaseView)

visibleSize = CCDirector:sharedDirector():getVisibleSize()
viewScale = VisibleRect:SFGetScale()
local width = 460
local height = 540
local grideSize = VisibleRect:getScaleSize(CCSizeMake(375,80))
local viewTransSize = CCSizeMake(400*viewScale,540*viewScale)

local cellWords = {
[1] = Config.Words[13011],
[2] = Config.Words[13012],
[3] = Config.Words[13013],
}

local itemIcon = {}
local equipAwardList = {}

function VipAwardView:__init()
	self.viewName = "VipAwardView"		
	self:initHalfScreen()	
	self.eventType = {}	-- tableview的数据类型
	self:initValue()									
	self:createVipAwardView()			
end

function VipAwardView:initValue()
	local vipMgr = GameWorld.Instance:getVipManager()	
	self.vipLevel = vipMgr:getVipLevel()
	local level = PropertyDictionary:get_level(G_getHero():getPT())
	local professionId = PropertyDictionary:get_professionId(G_getHero():getPT())
	if self.vipLevel < 2  then
		itemIcon[1] = "exp"
		itemIcon[2] = "item_gift_vip_1"		
		itemIcon[3] = self:getEquipItem(professionId, level)--"equip_80_1100",			

	elseif self.vipLevel == 2 then
		itemIcon[1] = "exp"
		itemIcon[2] = "item_gift_vip_2"
		itemIcon[3] = self:getEquipItem(professionId, level)
	elseif self.vipLevel == 3 then
		itemIcon[1] = "exp"
		itemIcon[2] = "item_gift_vip_3"
		itemIcon[3] = self:getEquipItem(professionId, level)		
	end
		
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3		
end

function VipAwardView:getEquipItem(professionId,level)
	local equiplist = G_GetVipWeaponAward(professionId)
	local vipMgr = GameWorld.Instance:getVipManager()	
	
	if level < 50 then
		return equiplist[1]
	elseif level <60 then
		return equiplist[2]
	else
		return equiplist[3]
	end
end

function VipAwardView:__delete()

end

function VipAwardView:onExit()
	
end

function VipAwardView:onEnter()
	self:initValue()
end

function VipAwardView:create()
	return VipAwardView.New()
end

--显示NPC图片
function VipAwardView:showNpcPic(viewNpcId)
	self:setNpcAvatar(viewNpcId)
	self:setNpcName(viewNpcId)
end

--显示谈话内容
function VipAwardView:showTalkConcent(viewNpcId,viewSize)
	--[[local childViewSize	
	if( viewSize == nil ) then
		childViewSize = CCSizeMake((393-20)*viewScale,180*viewScale)
	else
		childViewSize = viewSize
	end
	
	local containerNode = CCNode:create()
	containerNode:setContentSize(childViewSize)
	
	--ScrollView
	local scrollView = createScrollViewWithSize(childViewSize)
	scrollView:setDirection(kSFScrollViewDirectionVertical)	
	scrollView:setContainer(containerNode)
	self:addChild(scrollView)
	VisibleRect:relativePosition(scrollView, self:getContentNode(), LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(10.0, -20.0))--]]

	--NPC谈话内容
	local npcTalkWord = ""
	if GameData.Npc[viewNpcId]~=nil then
		npcTalkWord = GameData.Npc[viewNpcId]["property"]["description"]
		--npcTalkWord = "        "..string.wrapRich( GameData.Npc[viewNpcId]["property"]["description"],Config.FontColor["ColorBlack1"],FSIZE("Size3"))
	else
		npcTalkWord = Config.Words[3202]
		--npcTalkWord = "        "..string.wrapRich(Config.Words[3202],Config.FontColor["ColorBlack1"],FSIZE("Size3"))
	end
	npcTalkWord = "    " .. npcTalkWord
	self:setNpcText(npcTalkWord)
	--[[local questTitle = createRichLabel(CCSizeMake(childViewSize.width-40,0))
	questTitle:setFont(Config.fontName["fontName1"])	
	questTitle:appendFormatText(npcTalkWord)
	containerNode:addChild(questTitle)
	VisibleRect:relativePosition(questTitle,containerNode,LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  , ccp(40, -10))
	scrollView:setContentOffset(ccp(0,-10))--]]
	
end

function VipAwardView:updateCellAtIndex(index)		
	if index > 0 then
		vipMgr:setIndexState(self.selectedCell,false)
		self.awardTable:updateCellAtIndex(index-1)	
	else
		self.awardTable:reloadData()
	end
	self:updateButton()	
end

function VipAwardView:createVipAwardView()
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local viewNpcId = questMgr:getNpcTalkViewInfo()
	
	--显示背景
	self:createViewBg()
	
	local viewLine1 =  createScale9SpriteWithFrameNameAndSize(RES("npc_dividLine.png"), CCSizeMake(373,8))
	self:addChild(viewLine1)	
	VisibleRect:relativePosition(viewLine1,self:getContentNode(), LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  ,ccp(10,-85))
			
	--显示NPC图片
	self:showNpcPic(viewNpcId)	
	--显示谈话内容
	local contentviewSize = CCSizeMake((393-20)*viewScale,80*viewScale)
	self:showTalkConcent(viewNpcId,contentviewSize)
	
	if self.vipLevel >= 0 then
		self:initAwardListView()
	end
end

function VipAwardView:updateVipAwardView()
	self:initAwardListView()
end	

function VipAwardView:createItem(index)
	local item = CCNode:create()
	item:setContentSize(grideSize)

	local leftBg = createScale9SpriteWithFrameNameAndSize(RES("faction_editBoxBg.png"),CCSizeMake(211,80))
	VisibleRect:relativePosition(leftBg,item,LAYOUT_CENTER + LAYOUT_LEFT_INSIDE,ccp(10,0))			
	item:addChild(leftBg)
	
	local blueBg = createScale9SpriteWithFrameNameAndSize(RES("common_blueBar.png"),CCSizeMake(633,33))
	blueBg:setScaleX(0.33)
	VisibleRect:relativePosition(blueBg,item,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(10,-3))			
	item:addChild(blueBg)	

	--背景		
	local cellItem = G_createItemShowByItemBox(itemIcon[index+1],nil,nil,nil,nil,-1)
	VisibleRect:relativePosition(cellItem,item,LAYOUT_CENTER + LAYOUT_LEFT_INSIDE,ccp(20,0))			
	item:addChild(cellItem)
--[[	
	--tudo
	local itemsprite = createSpriteWithFileName(ICON(itemIcon[index+1]))	
	item:addChild(itemsprite)
	VisibleRect:relativePosition(itemsprite,cellBg,LAYOUT_CENTER)			
	--]]
	--名称
	local goodsName = createLabelWithStringFontSizeColorAndDimension(cellWords[index+1],"Arial",FSIZE("Size4"),FCOLOR("ColorWhite1"))
	goodsName:setAnchorPoint(ccp(0,1))
	VisibleRect:relativePosition(goodsName,cellItem,LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_OUTSIDE,ccp(10,0))								
	item:addChild(goodsName)
	--判断是否可点击   可点击则创建按钮   否则创建精灵
	local vipMgr = GameWorld.Instance:getVipManager()		
	if  vipMgr:getIndexState(index+1)  then				
		local getAwardBt = createButtonWithFramename(RES("btn_1_select.png"))		
		local textlabel = createSpriteWithFrameName(RES("word_button_receive.png"))
		getAwardBt:setTitleString(textlabel)
		
		VisibleRect:relativePosition(getAwardBt,item,LAYOUT_CENTER + LAYOUT_RIGHT_INSIDE,ccp(-10,0))
		item:addChild(getAwardBt)	
		local getAwardBtFunc = function()
			vipMgr:requestGetReward(index+1)
			vipMgr:setAwardGetIndex(index + 1)			
		end
		getAwardBt:addTargetWithActionForControlEvents(getAwardBtFunc,CCControlEventTouchDown)								
	else		
		local getAwardBt = createButtonWithFramename(RES("btn_1_disable.png"))		
		local textlabel = createSpriteWithFrameName(RES("word_button_receive.png"))
		getAwardBt:setTitleString(textlabel)
		VisibleRect:relativePosition(getAwardBt,item,LAYOUT_CENTER + LAYOUT_RIGHT_INSIDE,ccp(-10,0))
		item:addChild(getAwardBt)	
	end					
	return item
end	

function VipAwardView:initAwardListView()
		
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")		
		self.selectedCell  = cell:getIndex()+1																											
	end	
	function dataHandler(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(grideSize))
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(grideSize))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)		
			if tableCell == nil then
				tableCell = SFTableViewCell:create()
				tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
				local item = self:createItem(index)
				tableCell:addChild(item)
				data:setCell(tableCell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
				local item = self:createItem(index)				
				tableCell:addChild(item)
				data:setCell(tableCell)
			end
			tableCell:setIndex(index)																								
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			data:setIndex(3)
			return 1
		end
	end			

	--创建tableview
	if self.awardTable == nil then
		self.awardTable = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(375, height-250)))
		self.awardTable:reloadData()
		self.awardTable:setTableViewHandler(tableDelegate)
		self.awardTable:scroll2Cell(0, false)  --回滚到第一个cell
		self:addChild(self.awardTable)		
		VisibleRect:relativePosition(self.awardTable, self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X, ccp(0, -105))
	else
		self.awardTable:reloadData()
	end
	self:updateButton()				
end

function VipAwardView:updateButton()
	local vipMgr = GameWorld.Instance:getVipManager()
	self:getContentNode():removeChildByTag(10,true)			
	if  vipMgr:CanGetAward() then				
		local getAwardBt = createButtonWithFramename(RES("btn_1_select.png"))
		getAwardBt:setTag(10)
		local textlabel = createSpriteWithFrameName(RES("word_button_receive.png"))	
		getAwardBt:setTitleString(textlabel)
		self:addChild(getAwardBt)	
		VisibleRect:relativePosition(getAwardBt,self:getContentNode(),LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(-10,10))
		
		local getAwardBtFunc = function()
			vipMgr:setAwardGetIndex(4)		
			vipMgr:requestGetReward(4)						
		end
		getAwardBt:addTargetWithActionForControlEvents(getAwardBtFunc,CCControlEventTouchDown)								
	else
				
		local getAwardBt = createButtonWithFramename(RES("btn_1_disable.png"))		
		local textlabel = createSpriteWithFrameName(RES("word_button_receive.png"))
		getAwardBt:setTitleString(textlabel)		
		getAwardBt:setTag(10)		
		self:addChild(getAwardBt)	
		VisibleRect:relativePosition(getAwardBt,self:getContentNode(),LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(-10,10))
	end			
end
--[[

function VipAwardView:touchHandler(eventType, x, y)
	if self.rootNode:isVisible() and self.rootNode:getParent() then	
		local parent = self.rootNode:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = self.rootNode:boundingBox()
		if rect:containsPoint(point) then
			self:close()
			return 1
		else
			self:close()
			return 0
		end
	else
		self:close()
		return 0
	end
end--]]