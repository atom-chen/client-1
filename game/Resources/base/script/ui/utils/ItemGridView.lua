require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.PageIndicateView")
require("ui.utils.ItemView")
require("ui.utils.GridView")
require("GameDef")

ItemGridView = ItemGridView or BaseClass(GridView) 	--ItemGridView继承与BaseUI

function ItemGridView:create()
	return ItemGridView.New()
end

function ItemGridView:__init()	
	self.itemViewCache = {}	
	self.emptyViewCache = {}
	self.freeGrids = {}		
	self.itemList = {}
	self.isLoading = false
end	

function ItemGridView:__delete()
	self:releaseCache()
end

function ItemGridView:setShowNameInfo(bShow)
	self.bShowNameInfo = bShow
end

function ItemGridView:updateItem(eventType, map, filterFunc)
	if self.isLoading then
		return true	
	end
	if (E_UpdataEvent.Add == eventType) then	
		for k, v in pairs(map) do
			if not filterFunc or filterFunc(v) then		
				if not self:addOneItem(v) then
					return false
				end
			end
		end
	elseif (E_UpdataEvent.Delete == eventType) then
		for k, v in pairs(map) do
			if not filterFunc or filterFunc(v) then		
				self:removeOneItem(v)			
			end
		end
	elseif (E_UpdataEvent.Modify == eventType) then
		for k, v in pairs(map) do
			if not filterFunc or filterFunc(v) then
				local view = self.itemViewCache[v:getId()]
				if view then
					G_updateItemView(view, v, true, true, true)
				end
			end
		end
	end	
	return true
end

function ItemGridView:getItemViewCache()
	return self.itemViewCache
end

--注意：该接口不会改变self.itemList
function ItemGridView:addOneItem(itemObj)
	local view = self:takeFreeGrid()
	if view then				
		G_updateItemView(view, itemObj, true, true, true)
		self.itemViewCache[itemObj:getId()] = view		
		return true
	else --free grid used out. reload now
		print("ItemGridView:addOneItem fail. free grid used out")
		return false
	end
end

--注意：该接口不会改变self.itemList
function ItemGridView:removeOneItem(itemObj)
	local id = itemObj:getId()
	local view = self.itemViewCache[id]
	if view then
		G_clearItemView(view)					--把它清除掉
		self.itemViewCache[id] = nil
		table.insert(self.freeGrids, 1, view)		
	end
end

function ItemGridView:takeFreeGrid()
	local view = self.freeGrids[1]
	if view then
		table.remove(self.freeGrids, 1)
	end
	return view	
end

function ItemGridView:getItemViewWithCreate(id, item)
	local addItemView = function(itemObj)
		local view = G_createItemView(itemObj, true, true, true,self.bShowNameInfo, self.cellSize)
		self.itemViewCache[itemObj:getId()] = view
		return view
	end	
	local view = self.itemViewCache[id]
	if not view then
		view = addItemView(item)
	else
		G_updateItemView(view, item, true, true, true)
	end
	return view
end	

function ItemGridView:takeEmptyViewWithCreate(bShowLock) 
	local max = #(self.emptyViewCache)
	local view = self.emptyViewCache[max]
	if not view then
		view = ItemView.New(self.cellSize)
	else
		table.remove(self.emptyViewCache, max)
	end		
	view:showLock(bShowLock)					
	return view		
end

function ItemGridView:releaseCache()
	for k, v in pairs(self.itemViewCache) do
		v:DeleteMe()
	end
	self.itemViewCache = {}
	
	for k, v in pairs(self.emptyViewCache) do
		v:DeleteMe()
	end
	self.emptyViewCache = {}
	
	for k, v in pairs(self.freeGrids) do
		v:DeleteMe()
	end
	self.freeGrids = {}
end

function ItemGridView:getItemList()
	return self.itemList
end

--itemList: 需要显示的物品列表（必须为连续数组）
--cellSize: 每个格子的大小
--pageIndex: 优先加载第几页。该函数只检查pageIndex的类型，不检查值合法性。
--totalGridCount: 需要加载的总格数目
--lockCriticalIndex: 超过该索引则显示加锁
function ItemGridView:setItemList(itemList, cellSize, pageIndex, totalGridCount, lockCriticalIndex)
	if self.isLoading or (not itemList) then
		return
	end		
	self.cellSize = cellSize
	self.itemList = itemList
	self.pageCap = self.row * self.columu
	self.isLoading = true
	local itemCount = #(itemList)
	
	if type(pageIndex) ~= "number" then
		pageIndex = 1
	end
	
	self.gridDatas = {}			
	for k, v in pairs(self.freeGrids) do		
		table.insert(self.emptyViewCache, v)
	end
	self.freeGrids = {}
	
	local preLoadedStart = (pageIndex - 1) * self.pageCap + 1
	local preLoadedEnd = pageIndex * self.pageCap
	
	local createFreeGrid  = function(index)
		local view
		if lockCriticalIndex and index > lockCriticalIndex then		
			view = self:takeEmptyViewWithCreate(true)
		else
			view = self:takeEmptyViewWithCreate(false)
		end
		self.gridDatas[index] = view
		table.insert(self.freeGrids, view)
	end
	local createItemView = function(index)
		local item = itemList[index]
		if item then
			self.gridDatas[index] = self:getItemViewWithCreate(item:getId(), item)
		end
	end
		
	for i = preLoadedStart, preLoadedEnd do
		if i <= itemCount then
			createItemView(i)			
		elseif i <= totalGridCount then
			createFreeGrid(i)
		end
	end
	
	local createOtherGrid = function()
		for i = 1, totalGridCount do 
			if not (i >= preLoadedStart and i <= preLoadedEnd) then
				if i <= itemCount then
					createItemView(i)
				else
					createFreeGrid(i)
				end
			end
		end	
		if self.delaySchId then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delaySchId)
			self.delaySchId = nil			
		end
		self:setGrids(self.gridDatas, cellSize)
		self:reloadAll()		
		self.isLoading = false
		self:setPageIndex(pageIndex)
	end		
				
	if totalGridCount > self.pageCap and self.delayLoadingInterval > 0 then --如果需要延迟创建且没有加载完，则延迟创建
		self:setGrids(self.gridDatas, cellSize)				
		self:reloadAll()
		self:setPageIndex(pageIndex)
		self.delaySchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(createOtherGrid, self.delayLoadingInterval, false)		
	else
		if totalGridCount > self.pageCap then
			createOtherGrid()
		else
			self:setGrids(self.gridDatas, cellSize)				
			self:reloadAll()
			self.isLoading = false
		end
		self:setPageIndex(pageIndex)
	end		
end	

function ItemGridView:doUpdateFpTips()
	local equipMgr = G_getEquipMgr()	
	local compareWithPlayer = nil
	for k, v in pairs(self.itemViewCache) do
		local itemObj = v:getItem()
--		compareWithPlayer = equipMgr:compareWithPlayerLevel(itemObj)	
		
		if itemObj and itemObj:getType() == ItemType.eItemEquip then	
			G_showTipIcon(itemObj,v)	
			--[[local canUse, des, unableUseRet = G_getBagMgr():getOperator():checkCanPutOnEquip(itemObj)
			local levelRet = equipMgr:compareLp(itemObj)
			if canUse and levelRet == E_CompareRet.Smaller then			 
				local ret = equipMgr:compareFp(itemObj)		--显示战力提示						
				if (ret == E_CompareRet.Greater) then
					v:showTipIcon("up")
				elseif (ret == E_CompareRet.Smaller) then
					v:showTipIcon("down")				
				end
			else
				if unableUseRet == E_UnableEquipType.Level then
					if compareWithPlayer == E_CompareRet.Smaller then
						v:showTipIcon("lessLevel")
					elseif compareWithPlayer == E_CompareRet.Greater then
						v:showTipIcon("level")
					end						
				elseif unableUseRet == E_UnableEquipType.Profression then
					v:showTipIcon("profression")
				elseif unableUseRet == E_UnableEquipType.Gender then
					v:showTipIcon("gender")
				end
			end--]]
		end
	end
end

--Juchao@20140211: 延迟更新，提高性能
function ItemGridView:updateFpTips()
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


function ItemGridView:findItemNodeById(id)
	local node = self.itemViewCache[id]
	if node then
		if table.size(self.gridDatas)>0 then
			for k,v in pairs(self.gridDatas) do
				if v == node then
					return node,k
				end
			end
		end	
	end
	return nil
end