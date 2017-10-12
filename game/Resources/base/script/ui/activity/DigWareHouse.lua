--挖宝仓库
require("ui.UIManager")
require("common.BaseUI")
require("ui.utils.ItemGridView")
require("ui.utils.BatchItemGridView")
require("config.words")
DigWareHouse = DigWareHouse or BaseClass(BaseUI)

local g_scale = VisibleRect:SFGetScale()
local g_boxSize = CCSizeMake(65*g_scale,65*g_scale)
local const_pageCount = 10

function DigWareHouse:__init()
	self.viewName = "DigWareHouse"	
	self.itemList = {}
	self.needRoload = false
	self.awardMgr = GameWorld.Instance:getAwardManager()	
	self:init(CCSizeMake(500+E_OffsetView.eWidth*2, 556+E_OffsetView.eHeight*2))
	self:initBg()
	self:initBtn()
	self:initGridView()
	self:showCapacity()
	self:initPageIndicateView()
end

function DigWareHouse:onEnter()
	if self.needRoload == true then
		self.itemList = self.awardMgr:getItemList()	
		self.gridView:setItemList(self.itemList,g_boxSize,1,const_pageCount,nil)
		self.needRoload = false	
	end
end

function DigWareHouse:onExit()
	self.gridView:setPageIndex(1)	
end

function DigWareHouse:__delete()
	self.gridView:DeleteMe()
end

function DigWareHouse:create()
	return DigWareHouse.New()
end

function DigWareHouse:initBg()
	self.bg = createScale9SpriteWithFrameName(RES("common_bgNumFrame.png"))
	self.bg:setContentSize(CCSizeMake(470,400))
	self:addChild(self.bg)
	VisibleRect:relativePosition(self.bg,self:getContentNode(),LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))	
	--说明文本
	--local title = createLabelWithStringFontSizeColorAndDimension(Config.Words[13519],"Arial",FSIZE("Size4"),FCOLOR("ColorYellow5"))
	local explainLb_1 = createLabelWithStringFontSizeColorAndDimension(Config.Words[13520],"Arial",FSIZE("Size4"),FCOLOR("ColorYellow5"))
	--local explainLb_2 = createLabelWithStringFontSizeColorAndDimension(Config.Words[13521],"Arial",FSIZE("Size4"),FCOLOR("ColorYellow5"))
	--self:addChild(title)
	self:addChild(explainLb_1)
	--self:addChild(explainLb_2)
	--VisibleRect:relativePosition(title,self.bg,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-15))	
	VisibleRect:relativePosition(explainLb_1,self.bg,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-40))	
	--VisibleRect:relativePosition(explainLb_2,explainLb_1,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))		
end

function DigWareHouse:initGridView()
	self.itemList = self.awardMgr:getItemList()	
--	self.gridView = ItemGridView.New()	
	self.gridView = BatchItemGridView.New()	--Juchao@20140521: 使用批处理控件，优化性能
	self.gridView:setPageOption(5, 6)
	self.gridView:setSpacing(3, 3)
	self.gridView:setTouchNotify(self, self.handleTouchItem)
	self.gridView:setItemList(self.itemList,g_boxSize,1,const_pageCount,nil)
	self.bg:addChild(self.gridView:getRootNode())
	VisibleRect:relativePosition(self.gridView:getRootNode(), self.bg, LAYOUT_CENTER--[[+LAYOUT_TOP_INSIDE,ccp(0,-10)--]])	
end
-- 显示仓库容量
function DigWareHouse:showCapacity()
	local count = self.awardMgr:getCapacity()
	if not count then
		count = 0
	end
	local curCap = 300
		
	if self.itemCount == count and self.curCap == curCap then
		return
	end
	self.itemCount = count
	self.curCap = curCap
	
	if (self.capacityLabel == nil) then
		self.capacityLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size1") * g_scale, FCOLOR("ColorBrown2"))		
		self:addChild(self.capacityLabel)
		self.capacityLabel:setAnchorPoint(ccp(1, 0.5))
	end
	if (count ~= nil and curCap ~= nil) then
		self.capacityLabel:setString(string.format("%d/%d", count, curCap))
	else --加载失败
		self.capacityLabel:setString("")
	end
	VisibleRect:relativePosition(self.capacityLabel, self.bg, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-5, 5))
end

function DigWareHouse:refreshCapacity()
	local count = self.awardMgr:getCapacity()
	if not count then
		count = 0
	end
	local curCap = 300
	if self.capacityLabel then
		self.capacityLabel:setString(string.format("%d/%d", count, curCap))
	end
end

-- 初始化页数指示
function DigWareHouse:initPageIndicateView()
	self.pageIndicateView = createPageIndicateView(10, 1) 
	self:addChild(self.pageIndicateView:getRootNode())	
	self.gridView:setPageChangedNotify(self.pageIndicateView, self.pageIndicateView.setIndex)
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self.bg, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 60))
end

function DigWareHouse:initBtn()
	local allGetBtn = createButtonWithFramename(RES("btn_1_select.png"))
	self:addChild(allGetBtn)
	VisibleRect:relativePosition(allGetBtn,self.bg,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_RIGHT_INSIDE,ccp(0,-20))
	local btnWord = createLabelWithStringFontSizeColorAndDimension(Config.Words[13507],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow5"))	
	allGetBtn:setTitleString(btnWord)
	local allGetFunc = function()	
		--Juchao@20140514: 提取全部时不要客户端判断。让服务器端判断就行了
		--全部提取
--[[		local canGetAll = self.awardMgr:canGetAllReward()
		if canGetAll == true then--]]
			if not self.awardMgr:isDigWareHouseEmpty() then
				self.awardMgr:setIsShowAllGetTips(true)
				self.awardMgr:requestRemoveItem(-1)		
			else
				UIManager.Instance:showSystemTips(Config.Words[13525])
			end
--[[		elseif canGetAll == false then
			UIManager.Instance:showSystemTips(Config.Words[13525])
		end--]]
	end
	allGetBtn:addTargetWithActionForControlEvents(allGetFunc,CCControlEventTouchDown)	
end

function DigWareHouse.handleTouchItem(self,index,itemView)
	local item 
	if itemView then
		item = itemView:getItem()
	end
	if (item) then
		local id = item:getGridId()
		if id then
			self.awardMgr:requestRemoveItem(id)
		end
	end			
end

function DigWareHouse:updateItem(eventType, map)
	self.gridView:updateItem(eventType, map)
	self.needRoload = true
end

function DigWareHouse:clearAllItem()
	if self.gridView then
		self.gridView:clearAllItem()
	end
end