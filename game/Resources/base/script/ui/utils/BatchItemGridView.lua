require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.PageIndicateView")
require("ui.utils.BatchItemView")
require("ui.utils.BatchGridView")
require("GameDef")

BatchItemGridView = BatchItemGridView or BaseClass(BatchGridView) 	--BatchItemGridView继承与BaseUI

local const_pvr = "ui/ui_game/ui_game_bag.pvr"
local const_plist = "ui/ui_game/ui_game_bag.plist"
local const_batchNodeTag = 1906
function BatchItemGridView:create()
	return BatchItemGridView.New()
end

function BatchItemGridView:__init()	
	self.usingGrids = {}	--item id 为key， ItemView 为 value
	self.emptyGrids = {}	--连续数组，空余的格子(没有parent)
	self.freeGrids = {}		--连续数组，空闲的格子(没有显示物品)	
	self.lockThresholdIndex = nil	--超过该索引则显示加锁。nil则为不需要显示枷锁	x
	self.loadedPage = {}			--记录已经加载的页数	
	
	local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
	frameCache:addSpriteFramesWithFile(const_plist)	
	self:setBatchPvr(const_pvr)	
	local onLoadPage = function(index)
		self:onLoadPage(index)
	end
	self:setLoadDelegate(onLoadPage)	
end

function BatchItemGridView:__delete()
	self:releaseCache()
end

function BatchItemGridView:updateItem(eventType, map, filterFunc)
	local filter = function(func, obj)
		return (not func or func(obj)) and (not self.filterFunc or self.filterFunc(self.filterParam, obj))
	end
	if (E_UpdataEvent.Add == eventType) then	
		for k, v in pairs(map) do
			if filter(filterFunc, v) then		
				if self:addOneItem(v) == -1 then
					return false
				end
			end
		end
	elseif (E_UpdataEvent.Delete == eventType) then
		for k, v in pairs(map) do
			if filter(filterFunc, v) then		
				self:removeOneItem(v)			
			end
		end
	elseif (E_UpdataEvent.Modify == eventType) then
		for k, v in pairs(map) do
			if filter(filterFunc, v) then			
				self:updateOneItem(v)				
			end
		end
	end	
	return true
end

--创建一个ItemView
function BatchItemGridView:createBatchItemView(item, bShowBindState, bShowText, bShowTips)
	local view = BatchItemView.New(self.cellSize)	
	self:updateItemView(view, item, bShowBindState, bShowText, bShowTips)
	return view
end

--更新一个ItemView
function BatchItemGridView:updateItemView(itemView, itemObj, bShowBindState, bShowText, bShowTips)
	itemView:setItem(itemObj)
	itemView:showLock(false)
	itemView:showBindStatus(bShowBindState)	--显示绑定状态
	itemView:showText(bShowText)			--显示堆叠数量/强化等级	
	if itemObj and bShowTips and (itemObj:getType() == ItemType.eItemEquip) then		
		G_showTipIcon(itemObj, itemView)		
	end
end

--清除一个ItemView
function BatchItemGridView:clearItemView(view)	
	view:showContent(true)	
	view:setItem(nil)
	view:showBindStatus(false)
	view:showText(false)		
	view:showTipIcon(nil)
	view:showLock(false)
end

--增加一个物品。如果空闲格子不够，则增加失败
function BatchItemGridView:addOneItem(itemObj)
	if not itemObj then
		return 0
	end
	
	if self.usingGrids[itemObj:getId()] then
		print("BatchItemGridView:addOneItem Warning. try to add duplicated item "..itemObj:getId())
		return 0
	end
	
	local view = self:takeFreeGrid()
	if not view then	--空余格子用完，加载所有页面
		self:loadAllPage()		
		view = self:takeFreeGrid()
	end		
	
	if view then
		self:updateItemView(view, itemObj, true, true, true)
		self.usingGrids[itemObj:getId()] = view		
		return 1
	else
		print("BatchItemGridView:addOneItem fail. free grid used out")
		return -1
	end
end

function BatchItemGridView:loadAllPage()
	for i = 1, self.pageCount do
		if not self.loadedPage[i] then
			self:onLoadPage(i)
		end
	end
end

--删除一个物品。删除的格子将会放到self.freeGrids里面
function BatchItemGridView:removeOneItem(itemObj)
	local id = itemObj:getId()
	local view = self.usingGrids[id]
	if view then
		self:clearItemView(view)					--把它清除掉
		self.usingGrids[id] = nil
		table.insert(self.freeGrids, 1, view)		
	end
end

--更新一个物品
function BatchItemGridView:updateOneItem(itemObj)
	local id = itemObj:getId()
	local view = self.usingGrids[id]
	if view then
		self:updateItemView(view, itemObj, true, true, true)	
	end
end

--从空闲的格子里获取一个格子
function BatchItemGridView:takeFreeGrid()
	local view = self.freeGrids[1]
	if view then
		table.remove(self.freeGrids, 1)
	end
	return view	
end

--从空格子里获取一个格子
function BatchItemGridView:getEmptyItemView() 
	local max = #(self.emptyGrids)
	local view = self.emptyGrids[max]
	if view then	
		table.remove(self.emptyGrids, max)
	end						
	return view		
end

function BatchItemGridView:releaseCache()
	for k, v in pairs(self.usingGrids) do
		v:DeleteMe()
	end
	self.usingGrids = {}
	
	for k, v in pairs(self.emptyGrids) do
		v:DeleteMe()
	end
	self.emptyGrids = {}
	
	for k, v in pairs(self.freeGrids) do
		v:DeleteMe()
	end
	self.freeGrids = {}
end

function BatchItemGridView:getItemList()
	return self.itemList
end

--itemList: 需要显示的物品列表
--cellSize: 每个格子的大小
--pageIndex: 优先加载第几页。该函数只检查pageIndex的类型，不检查值合法性。
--pageCount: 需要加载的页数
--lockThresholdIndex: 超过该索引则显示加锁。传nil则为不需要显示枷锁
--function BatchGridView:setGrids(grids, cellSize, capacity)
function BatchItemGridView:setItemList(itemList, cellSize, pageIndex, pageCount, lockThresholdIndex)
	if (type(itemList) ~= "table") or (type(pageIndex) ~= "number") 
		or (type(pageCount) ~= "number") then
		error("BatchItemGridView:setItemList param error")
		return
	end
	self.lockThresholdIndex = lockThresholdIndex
	self:setCellSize(cellSize)
--[[	
	self.itemList = table.cp(itemList)	--Juchao@20140712: copy该table，防止外部改动该list影响内部的reload。
	Juchao@20140726: 为什么不再使用table.cp? 因为会导致一个bug：	
	1. 进入游戏，第一次打开背包，背包默认显示第一页。BatchItemGridView会动态地load需要显示的页，所以在不滑动背包的情况下，背包只load了第一页；	
	2. 这个时候点击快速出售，会从BagMgr里取出一堆符合条件的物品放到快速出售界面；
	3. 确认出售后，由于物品的变动，会调用到BatchItemGridView的updateItem(),该函数只对正在显示的物品进行更新，并不会更新自身的self.itemList；
	4. 此时self.itemList保存的还是快速出售前的列表。这个时候把背包滑到第二页，背包根据self.itemList来加载第二页。于是就会显示出一些已经卖掉的物品。	
--]]	
	self.itemList = itemList--table.cp(itemList)	--Juchao@20140726: 不需要copy，共享背包mgr里最新的列表即可。这没有什么问题。
	self.pageCount = pageCount	
	self.loadedPage = {}
	
	self:update()
	self:prepare()
	self:setPageIndex(pageIndex)	
end


function BatchItemGridView:clearAllItem()
	self:setItemList({}, self:getCellSize(), 1, 1, nil)	
end
function BatchItemGridView:debug()
	print("\nfreeGrids "..table.size(self.freeGrids))
	print("emptyGrids "..table.size(self.emptyGrids))
	print("usingGrids "..table.size(self.usingGrids))
end

function BatchItemGridView:prepare()

	--将空余格子放到空格子里
	for k, v in pairs(self.freeGrids) do
		table.insert(self.emptyGrids, v)
	end
	--将正在使用的格子放到空格子里
	for k, v in pairs(self.usingGrids) do
		self:clearItemView(v)
		table.insert(self.emptyGrids, v)
	end
	self.freeGrids = {}
	self.usingGrids = {}
end

function BatchItemGridView:onLoadPage(pageIndex)
	if self:isLegalPage(pageIndex) and (not self.loadedPage[pageIndex]) then
		print("BatchItemGridView onLoadPage "..pageIndex)		
		local itemView
		local obj
		local startIndex = 1 + (pageIndex - 1) * self.pageCap
		local totalIndex
		for i = 1, self.row do
			for j = 1, self.column do
				totalIndex = startIndex + (i - 1) * self.column + j - 1
				obj = self.itemList[totalIndex]		
				if self.filterFunc and (not (self.filterFunc(self.filterParam, obj))) then
					obj = nil
				end
				if type(self.lockThresholdIndex) == "number" and  totalIndex > self.lockThresholdIndex then
					itemView = self:createUsingItemView(nil)
					itemView:showLock(true)
					table.insert(self.freeGrids, itemView)
				else
					itemView = self:createUsingItemView(obj)	
					itemView:showLock(false)
					if obj then
						self.usingGrids[obj:getId()] = itemView
					else
						table.insert(self.freeGrids, itemView)
					end
				end
				self:addGrid(totalIndex, itemView)
			end
		end
		self.loadedPage[pageIndex] = true
	end
end

function BatchItemGridView:setBatchPvr(pvr)
	self.batchPvr = pvr
end

function BatchItemGridView:addBatchNode(parent)
	local batchNode = SFSpriteBatchNode:create(self.batchPvr, 300)	
	batchNode:setZOrder(-1)
	batchNode:setTag(const_batchNodeTag)		
	parent:addChild(batchNode)	
	batchNode:setContentSize(parent:getContentSize())
	VisibleRect:relativePosition(batchNode, parent, LAYOUT_CENTER)	
	return batchNode		
end

--增加一个node到指定格子
function BatchItemGridView:addGrid(index, grid)
	local pageIndex, row, column = self:getLayoutInfoByIndex(index)	
	local pageNode = self:getPageNode(pageIndex)
	if pageNode then
--		grid:removeParent()											
		local batchNode = pageNode:getChildByTag(const_batchNodeTag)
		if not batchNode then
			batchNode = self:addBatchNode(pageNode)
		end
		
		grid:setParent(pageNode, batchNode)	
		grid:layoutNormalRootNode(pageNode, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,
					ccp((column - 1) * self.cellSize.width + column * self.hSpacing, -((row - 1) * self.cellSize.height + row * self.vSpacing)))						
		grid:layoutBatchRootNode(batchNode, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,
					ccp((column - 1) * self.cellSize.width + column * self.hSpacing, -((row - 1) * self.cellSize.height + row * self.vSpacing)))						
		self.grids[index] = grid					
	end
end	

function BatchItemGridView:getUsingItemViews()
	return self.usingGrids
end

function BatchItemGridView:createUsingItemView(obj)
	local itemView	
	itemView = self:getEmptyItemView()
	
	if not itemView then
		itemView = self:createBatchItemView(obj, true, true, true)
	else			
		self:updateItemView(itemView, obj, true, true, true)			
	end			
	return itemView
end

--更新各个ItemView里的战力指示图标
function BatchItemGridView:doUpdateFpTips()
	local equipMgr = G_getEquipMgr()	
	local compareWithPlayer = nil
	for k, v in pairs(self.usingGrids) do
		local itemObj = v:getItem()	
		if itemObj and itemObj:getType() == ItemType.eItemEquip then	
			G_showTipIcon(itemObj,v)				
		end
	end
end

--Juchao@20140211: 延迟更新，提高性能
function BatchItemGridView:updateFpTips()
	local removeSchId = function()
		if self.delayUpdateFpTipsSchId then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayUpdateFpTipsSchId)
		end
		self.delayUpdateFpTipsSchId = nil
	end
	removeSchId()

	local onTimeout = function()
		if self.delayUpdateFpTipsSchId == nil then
			return
		end
		self:doUpdateFpTips()		
		removeSchId()
	end
	self.delayUpdateFpTipsSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 0.5, false);			
end

function BatchItemGridView:findItemNodeById(id)
	local node = self.usingGrids[id]
	if node then
		for k,v in pairs(self.grids) do
			if v == node then
				return node,k
			end
		end
	end
	return nil
end	

function BatchItemGridView:setGlobalFilterFunc(func, param)
	if type(func) == "function" then
		self.filterFunc = func
		self.filterParam = param
	end
end