require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.PageIndicateView")
require("ui.utils.BatchItemView")
require("ui.utils.BatchGridView")
require("GameDef")

BatchItemGridView = BatchItemGridView or BaseClass(BatchGridView) 	--BatchItemGridView�̳���BaseUI

local const_pvr = "ui/ui_game/ui_game_bag.pvr"
local const_plist = "ui/ui_game/ui_game_bag.plist"
local const_batchNodeTag = 1906
function BatchItemGridView:create()
	return BatchItemGridView.New()
end

function BatchItemGridView:__init()	
	self.usingGrids = {}	--item id Ϊkey�� ItemView Ϊ value
	self.emptyGrids = {}	--�������飬����ĸ���(û��parent)
	self.freeGrids = {}		--�������飬���еĸ���(û����ʾ��Ʒ)	
	self.lockThresholdIndex = nil	--��������������ʾ������nil��Ϊ����Ҫ��ʾ����	x
	self.loadedPage = {}			--��¼�Ѿ����ص�ҳ��	
	
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

--����һ��ItemView
function BatchItemGridView:createBatchItemView(item, bShowBindState, bShowText, bShowTips)
	local view = BatchItemView.New(self.cellSize)	
	self:updateItemView(view, item, bShowBindState, bShowText, bShowTips)
	return view
end

--����һ��ItemView
function BatchItemGridView:updateItemView(itemView, itemObj, bShowBindState, bShowText, bShowTips)
	itemView:setItem(itemObj)
	itemView:showLock(false)
	itemView:showBindStatus(bShowBindState)	--��ʾ��״̬
	itemView:showText(bShowText)			--��ʾ�ѵ�����/ǿ���ȼ�	
	if itemObj and bShowTips and (itemObj:getType() == ItemType.eItemEquip) then		
		G_showTipIcon(itemObj, itemView)		
	end
end

--���һ��ItemView
function BatchItemGridView:clearItemView(view)	
	view:showContent(true)	
	view:setItem(nil)
	view:showBindStatus(false)
	view:showText(false)		
	view:showTipIcon(nil)
	view:showLock(false)
end

--����һ����Ʒ��������и��Ӳ�����������ʧ��
function BatchItemGridView:addOneItem(itemObj)
	if not itemObj then
		return 0
	end
	
	if self.usingGrids[itemObj:getId()] then
		print("BatchItemGridView:addOneItem Warning. try to add duplicated item "..itemObj:getId())
		return 0
	end
	
	local view = self:takeFreeGrid()
	if not view then	--����������꣬��������ҳ��
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

--ɾ��һ����Ʒ��ɾ���ĸ��ӽ���ŵ�self.freeGrids����
function BatchItemGridView:removeOneItem(itemObj)
	local id = itemObj:getId()
	local view = self.usingGrids[id]
	if view then
		self:clearItemView(view)					--���������
		self.usingGrids[id] = nil
		table.insert(self.freeGrids, 1, view)		
	end
end

--����һ����Ʒ
function BatchItemGridView:updateOneItem(itemObj)
	local id = itemObj:getId()
	local view = self.usingGrids[id]
	if view then
		self:updateItemView(view, itemObj, true, true, true)	
	end
end

--�ӿ��еĸ������ȡһ������
function BatchItemGridView:takeFreeGrid()
	local view = self.freeGrids[1]
	if view then
		table.remove(self.freeGrids, 1)
	end
	return view	
end

--�ӿո������ȡһ������
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

--itemList: ��Ҫ��ʾ����Ʒ�б�
--cellSize: ÿ�����ӵĴ�С
--pageIndex: ���ȼ��صڼ�ҳ���ú���ֻ���pageIndex�����ͣ������ֵ�Ϸ��ԡ�
--pageCount: ��Ҫ���ص�ҳ��
--lockThresholdIndex: ��������������ʾ��������nil��Ϊ����Ҫ��ʾ����
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
	self.itemList = table.cp(itemList)	--Juchao@20140712: copy��table����ֹ�ⲿ�Ķ���listӰ���ڲ���reload��
	Juchao@20140726: Ϊʲô����ʹ��table.cp? ��Ϊ�ᵼ��һ��bug��	
	1. ������Ϸ����һ�δ򿪱���������Ĭ����ʾ��һҳ��BatchItemGridView�ᶯ̬��load��Ҫ��ʾ��ҳ�������ڲ���������������£�����ֻload�˵�һҳ��	
	2. ���ʱ�������ٳ��ۣ����BagMgr��ȡ��һ�ѷ�����������Ʒ�ŵ����ٳ��۽��棻
	3. ȷ�ϳ��ۺ�������Ʒ�ı䶯������õ�BatchItemGridView��updateItem(),�ú���ֻ��������ʾ����Ʒ���и��£���������������self.itemList��
	4. ��ʱself.itemList����Ļ��ǿ��ٳ���ǰ���б����ʱ��ѱ��������ڶ�ҳ����������self.itemList�����صڶ�ҳ�����Ǿͻ���ʾ��һЩ�Ѿ���������Ʒ��	
--]]	
	self.itemList = itemList--table.cp(itemList)	--Juchao@20140726: ����Ҫcopy��������mgr�����µ��б��ɡ���û��ʲô���⡣
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

	--��������ӷŵ��ո�����
	for k, v in pairs(self.freeGrids) do
		table.insert(self.emptyGrids, v)
	end
	--������ʹ�õĸ��ӷŵ��ո�����
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

--����һ��node��ָ������
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

--���¸���ItemView���ս��ָʾͼ��
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

--Juchao@20140211: �ӳٸ��£��������
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