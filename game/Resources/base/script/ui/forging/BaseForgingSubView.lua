require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("config.words")
require("ui.forging.EquipSimpleListView")

BaseForgingSubView = BaseForgingSubView or BaseClass()

--local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_forgingSubViewSize = VisibleRect:getScaleSize(CCSizeMake(865, 564))	

function BaseForgingSubView:__init()
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(const_forgingSubViewSize)
	self.btns =
	{
		{name = Config.Words[10065], ttype = E_EquipSource.inBag, 	obj = nil},
		{name = Config.Words[10066], ttype = E_EquipSource.inBody, 	obj = nil},
	}		
			
	self:_initTabView()
	self:initTabelView()	
	self:_initBg()	
	
	self.curEquipSource = E_EquipSource.inBody
	self.equipList = {}
	
	self.needUpdateItem = false
	self.needUpdateEquip = false
	self.needHandleUpdateEvent = true	--是否需要处理更新事件（分解界面在得到分解结果后再统一更新）
end	

function BaseForgingSubView:getRootNode()
	return self.rootNode
end	

function BaseForgingSubView:itemMapContainEquip(map)
	if type(map) ~= "table" then
		return false
	end
	for k, v in pairs(map) do
		if v:getType() == ItemType.eItemEquip then
			return true
		end
	end
	return false
end

function BaseForgingSubView:onItemUpdate(eventType, map)
	if not self:itemMapContainEquip(map) then
		if self.showMaterialNum then
			self:showMaterialNum()		
		end
		return false
	end
	if (self.curEquipSource == E_EquipSource.inBag) then
		if self.rootNode:isVisible() and self.needHandleUpdateEvent and UIManager.Instance:isShowing("ForgingView") then		
			if E_UpdataEvent.Modify == eventType then	
				for k, v in pairs(map) do
					self:updateOneEquip(v)
				end
			else
				self:switchEquipSource(E_EquipSource.inBag)	--reload
			end
			self.needUpdateItem = false
		else
			self.needUpdateItem = true
		end
	end
end

function BaseForgingSubView:updateOneEquip(newEquip)
	for k, v in ipairs(self.equipList) do
		if v:getId() == newEquip:getId() then
			self.equipList[k] = newEquip
			local index, data = self.equipSimpleListView:findEquipById(newEquip:getId())			
			if index and data then
				self.equipSimpleListView:updateEquipAtIndex(index, newEquip)
				if (self.onEquipSelected) and data.view and data.view:getSelected() then 
					self:onEquipSelected(index, newEquip, true) 
				end
			end
			break
		end
	end
end

function BaseForgingSubView:onEquipUpdate(eventType, map)
	if (self.curEquipSource == E_EquipSource.inBody) then
		if self.rootNode:isVisible() and self.needHandleUpdateEvent and UIManager.Instance:isShowing("ForgingView") then		
			if E_UpdataEvent.Modify == eventType then
				for k, v in pairs(map) do
					for kk, vv in pairs(v) do
						self:updateOneEquip(vv)
					end
				end
			else
				self:switchEquipSource(E_EquipSource.inBody)
			end
			self.needUpdateEquip = false
		else
			self.needUpdateEquip = true
		end
	end
end

function BaseForgingSubView:onEnter()
	if self.subOnEnter then
		self:subOnEnter()
	end		
	self.tagView:setSelIndex(1)	
end

function BaseForgingSubView:onExit()
	if self.subOnExit then
		self:subOnExit()
	end
end	

function BaseForgingSubView:setOperatorVisible(flag)
	self.operatorBg:setVisible(flag)
end

function BaseForgingSubView:switchEquipSource(source)
	if self.curEquipSource then
		self.btns[self.curEquipSource].label:setColor(FCOLOR("ColorWhite4"))
	end
	self.curEquipSource = source
	self.btns[self.curEquipSource].label:setColor(FCOLOR("ColorWhite3"))		
	if (source == E_EquipSource.inBag) then
		self.equipList = G_getBagMgr():getItemListByType(ItemType.eItemEquip)		
	else
		self.equipList = G_getEquipMgr():getEquipArray()	
	end
	
	if table.isEmpty(self.equipList) then --table.isEmpty
		self:showTips(true)
	else
		self:showTips(false)
	end
	
	self.equipSimpleListView:setEquipList(self.equipList, (source == E_EquipSource.inBag))	
	if (self.onSwitchEquipSource) then
		self:onSwitchEquipSource()
	end	
end

function BaseForgingSubView:showTips(bShow)
	if not self.noEquipeLabel then
		self.noEquipeLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[573],"Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
		self.rootNode:addChild(self.noEquipeLabel, 2)
		VisibleRect:relativePosition(self.noEquipeLabel, self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(188, 70))
	end
	
	if not self.choiseEquipLabel then
		self.choiseEquipLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[574], "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
		self.rootNode:addChild(self.choiseEquipLabel, 2)
		VisibleRect:relativePosition(self.choiseEquipLabel, self.rootNode, LAYOUT_CENTER, ccp(160, 182))
	end
	
	self.choiseEquipLabel:setVisible(bShow)
	self.noEquipeLabel:setVisible(bShow)
end

function BaseForgingSubView:__delete()
	if (self.equipSimpleListView) then
		self.equipSimpleListView:DeleteMe()
		self.equipSimpleListView = nil
	end
end

function BaseForgingSubView:_initBg()
	local bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(838, 448))
	self.rootNode:addChild(bg)
	VisibleRect:relativePosition(bg, self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(15, 0))
		
	local subRightBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), CCSizeMake(488, 427))
	self.rootNode:addChild(subRightBg)
	VisibleRect:relativePosition(subRightBg, self.rootNode, LAYOUT_TOP_INSIDE +LAYOUT_RIGHT_INSIDE, ccp(-25, -10))
	
	self.previewBg = createScale9SpriteWithFrameNameAndSize(RES("talisman_bg.png"), const_forgingPreviewSize)
	self.rootNode : addChild(self.previewBg)	
	VisibleRect:relativePosition(self.previewBg, self.equipSimpleListView:getRootNode(), LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_OUTSIDE, ccp(23, -10))
	
	self.operatorBg = CCNode:create()--createScale9SpriteWithFrameNameAndSize(RES("talisman_bg.png"), const_opratorSize)--
	self.operatorBg:setContentSize(const_opratorSize)
	self.rootNode : addChild(self.operatorBg)
	VisibleRect:relativePosition(self.operatorBg, self.previewBg, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE, ccp(0, -10))	
	
	local glideFlag = createSpriteWithFrameName(RES("main_questcontraction.png"))
	glideFlag:setRotation(-90)
	self.previewBg:addChild(glideFlag)
	VisibleRect:relativePosition(glideFlag, self.previewBg, LAYOUT_BOTTOM_INSIDE +LAYOUT_CENTER, ccp(0,-10))
	
	self.needTipsLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[10102], "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorYellow1"))
	self.operatorBg:addChild(self.needTipsLabel)
	VisibleRect:relativePosition(self.needTipsLabel, self.operatorBg, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(50, -135))	
	self.needTipsLabel:setVisible(false)
end

function BaseForgingSubView:initTabelView()
	local tableBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), CCSizeMake(276, 427))
	self.rootNode:addChild(tableBg, 2)
	VisibleRect:relativePosition(tableBg, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(68, -10))
	self.equipSimpleListView = EquipSimpleListView.New()
	self.rootNode:addChild(self.equipSimpleListView:getRootNode(), 100)
	VisibleRect:relativePosition(self.equipSimpleListView:getRootNode(), tableBg, LAYOUT_CENTER)
	
	local onEquipSelected = function(unused, index, equipObject, selected) 
		if (self.onEquipSelected) then
			self:onEquipSelected(index, equipObject, selected)
		end
	end
	self.equipSimpleListView:setTouchNotify(self, onEquipSelected)
end

function BaseForgingSubView:createScrollView(viewSize, mode)
	if (mode == nil) then
		mode = 2
	end
	local scrollView = createScrollViewWithSize(viewSize)
	scrollView:setDirection(mode) --2为垂直
	return scrollView
end			

function BaseForgingSubView:_initTabView()
	local btnArray = CCArray:create()	
	for key, value in pairs(self.btns) do
		local function createBtn(key)
			value.obj = createButtonWithFramename(RES("tab_2_normal.png"), RES("tab_2_select.png"))						
			value.label = createLabelWithStringFontSizeColorAndDimension(value.name, "Arial", FSIZE("Size4") * const_scale, FCOLOR("ColorWhite4"), CCSizeMake(25*const_scale,0))								
			btnArray:addObject(value.obj)
			local onTabPress = function()
				if (value.ttype ~= self.curEquipSource) then
					self:switchEquipSource(value.ttype)
				end
			end
			value.obj:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
		end
		createBtn(key)
	end
	self.tagView = createTabView(btnArray, 10 * const_scale, tab_vertical)
	self.rootNode:addChild(self.tagView, 100)
	VisibleRect:relativePosition(self.tagView, self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(20, -15))	

	for key, value in pairs(self.btns) do		
		self.tagView:addChild(value.label)	
		VisibleRect:relativePosition(value.label, value.obj, LAYOUT_CENTER, ccp(2, -3))
	end
end

function BaseForgingSubView:showSwitchBtn(bShow)
	for key, value in pairs(self.btns) do		
		value.obj:setVisible(bShow)
		value.label:setVisible(bShow)
	end
end	