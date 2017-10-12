require "common.baseclass"
require "gameevent.GameEvent"
require "ui.UIManager"
require "config.words"
require "ui.bag.BatchSellView"
require "ui.bag.BagView"
require "ui.utils.NormalItemDetailView"
require "ui.utils.GiftItemDetailView"
require "ui.utils.EquipItemDetailView"
require("ui.bag.OffLineBagView")
require"ui.utils.ItemView"
require"object.bag.ItemObject"
require "data.item.equipBest"
require "ui.utils.EquipDetailPropertyView"

BagUIHandler = BagUIHandler or BaseClass(GameEventHandler)
	
function BagUIHandler:__init()
	local manager = UIManager.Instance
	self.index = 0
		
	local onOpenBatchSellView = function (showOption, arg)
		
		manager:registerUI("BatchSellView", BatchSellView.New)	
		manager:showUI("BatchSellView",  showOption, arg)	
		GlobalEventSystem:Fire(GameEvent.EventCloseWarehouseView)	
	end
	
	local onHideBatchSellView = function ()	
		manager:hideUI("BatchSellView")		
	end
	
	-- 打开背包
	local onOpenBag = function (showOption, arg)
		
		manager:registerUI("BagView", BagView.create)	
		manager:showUI("BagView",  showOption, arg)		
	end
	
	local onHideBag  = function ()	
		manager:hideUI("BagView")				
	end
	
	local onResquestInit = function ()		
		local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()	
		local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
		bagMgr:requestBagCapacity()	
		bagMgr:requestItemList()
		equipMgr:requestEquipList()
	end		
	
	local onOpenNormalItemDetailView = function(showOption, arg)
		
		manager:registerUI("NormalItemDetailView", NormalItemDetailView.create)
		manager:showUI("NormalItemDetailView",  showOption, arg)
	end
	
	local onHideNormalItemDetailView = function()
		manager:hideUI("NormalItemDetailView")
		local mallMgr = GameWorld.Instance:getMallManager()
		mallMgr:setBuyObj(nil)	
	end
	
	local onOpenGiftItemDetailView = function(showOption, arg)
		
		manager:registerUI("GiftItemDetailView", GiftItemDetailView.create)
		manager:showUI("GiftItemDetailView",  showOption, arg)
	end
	
	local onHideGiftItemDetailView = function()
		manager:hideUI("GiftItemDetailView")
		local mallMgr = GameWorld.Instance:getMallManager()
		mallMgr:setBuyObj(nil)	
	end
	
	local onOpenEquipItemDetailView = function(showOption, arg)
		
		manager:registerUI("EquipItemDetailView", EquipItemDetailView.create)
		manager:showUI("EquipItemDetailView",  showOption, arg)
	end 		
	local onHideEquipItemDetailView = function()
		manager:hideUI("EquipItemDetailView")
		local mallMgr = GameWorld.Instance:getMallManager()
		GlobalEventSystem:Fire(GameEvent.EventCloseEquipDetailPropertyView)
		mallMgr:setBuyObj(nil)	
	end
	
	local onOpenPutOnEquipItemDetailView = function(showOption, arg)
		
		manager:registerUI("PutOnEquipItemDetailView", EquipItemDetailView.create)
		manager:showUI("PutOnEquipItemDetailView",  showOption, arg)
	end 
	local onHidePutOnEquipItemDetailView = function(showOption, arg)
		manager:hideUI("PutOnEquipItemDetailView")
		local mallMgr = GameWorld.Instance:getMallManager()
		mallMgr:setBuyObj(nil)	
	end				
	
	local onItemUpdate = function(eventType, map)
		local view = manager:getViewByName("BagView")
		if view then	
			view:updateItem(eventType, map)
			view:showCapacity()					
		end		
		if eventType == E_UpdataEvent.Add then				
			self:checkPutonTips(map)
		end
		
		local view2 = UIManager.Instance:getViewByName("RoleView")
		if view2 then
			view2 = view2:getNodeByName("RoleSubPropertyView");
		end
		if view2 and view2:isHero() then
			view2:updateAddIcon()										
		end
	end	
	
	local onLevelChanged = function()	--等级变化时提示是否有可提示穿戴装备
		self:checkPutonTips(G_getBagMgr():getItemListByType(ItemType.eItemEquip))		
	end
	
	local onEquipUpdate = function(eventType, map)
		local view = manager:getViewByName("BagView")
		if view then
			view:updateFpTips()				
		end						
	end
	
	local onEventBagCapacity = function(curCap, oldCurCap, maxCap, oldMaxCap)
		local view = manager:getViewByName("BagView")		
		if view then		
			view:showCapacity()			
			if curCap ~= oldCurCap then	
				view:reloadBagContent(view:getCurContentType(), true)
				local msg = {}
				table.insert(msg,{word = Config.Words[15004], color = Config.FontColor["ColorWhite1"]})
				UIManager.Instance:showSystemTips(msg)
			end
		end
	end	
	local onEventHeroProChanged = function(newPD)	
		if newPD["unbindedGold"] or newPD["bindedGold"] or newPD["gold"] then
			local view = manager:getViewByName("BagView")
			if view then
				view:showMoney(newPD)				
			end	
		end
	end	
	
	local onEventItemUnLockRemain = function(remainMins)
		local view = manager:getViewByName("BagView")
		if view then
			UIManager.Instance:showSystemTips(string.format(Config.Words [10009], remainMins))			
		end	
	end	
	
	local onItemList =function ()
		local view = manager:getViewByName("BagView")
		if view then
			view:setNeedReload(true)
		end	
	end		
											
	local openEquipDetailPropertyView = function (itemObj)
		if not manager:isShowing("EquipDetailPropertyView") and itemObj then
			GlobalEventSystem:Fire(GameEvent.EventHidePutOnEquipItemDetailView)
			
			manager:registerUI("EquipDetailPropertyView", EquipDetailPropertyView.create)					
		
			local layoutPos = manager:getViewPositon("EquipItemDetailView")
			if layoutPos ~= E_ViewPos.eLeft then		
				manager:moveViewByName("EquipItemDetailView", E_ViewPos.eLeft, true)
				manager:showUI("EquipDetailPropertyView", E_ShowOption.eMove2Right, itemObj)	
			else
				manager:showUI("EquipDetailPropertyView", E_ShowOption.eRight, itemObj)	
			end	
		else
			GlobalEventSystem:Fire(GameEvent.EventCloseEquipDetailPropertyView)
		end			
	end
		
	local closeEquipDetailPropertyView = function ()
		manager:hideUI("EquipDetailPropertyView")
	end
	
	self:Bind(GameEvent.EventHeroProChanged, onEventHeroProChanged)
	self:Bind(GameEvent.EventItemUpdate, onItemUpdate)
	self:Bind(GameEvent.EventHeroLevelChanged, onLevelChanged) --等级变化时提示是否有可提示穿戴装备
	self:Bind(GameEvent.EventItemList, onItemList)
	self:Bind(GameEvent.EventEquipUpdate, onEquipUpdate)
	self:Bind(GameEvent.EventBagCapacity, onEventBagCapacity)
	self:Bind(GameEvent.EventItemUnLockRemain, onEventItemUnLockRemain)
	self:Bind(GameEvent.EventOpenBag, onOpenBag)
	self:Bind(GameEvent.EventHideBag, onHideBag)
	self:Bind(GameEvent.EventHeroEnterGame, onResquestInit)
	
	self:Bind(GameEvent.EventOpenNormalItemDetailView, onOpenNormalItemDetailView)		
	self:Bind(GameEvent.EventHideNormalItemDetailView, onHideNormalItemDetailView)
	
	self:Bind(GameEvent.EventOpenGiftItemDetailView, onOpenGiftItemDetailView)		
	self:Bind(GameEvent.EventHideGiftItemDetailView, onHideGiftItemDetailView)
			
	self:Bind(GameEvent.EventOpenEquipItemDetailView, onOpenEquipItemDetailView)	
	self:Bind(GameEvent.EventHideEquipItemDetailView, onHideEquipItemDetailView)
			
	self:Bind(GameEvent.EventOpenPutOnEquipItemDetailView, onOpenPutOnEquipItemDetailView)		
	self:Bind(GameEvent.EventHidePutOnEquipItemDetailView, onHidePutOnEquipItemDetailView)		
	self:Bind(GameEvent.EventOpenBatchSellView, onOpenBatchSellView)		
	self:Bind(GameEvent.EventHideBatchSellView, onHideBatchSellView)	
	self:Bind(GameEvent.EventOpenEquipDetailPropertyView, openEquipDetailPropertyView)
	self:Bind(GameEvent.EventCloseEquipDetailPropertyView, closeEquipDetailPropertyView)
	
	-- 离线背包
	local eventOpenOffLineBag = function()
		
		manager:registerUI("OffLineBagView",OffLineBagView.create)
		manager:showUI("OffLineBagView",E_ShowOption.eMiddle)
		local offLineBagMgr = GameWorld.Instance:getOffLineBagMgr()
		offLineBagMgr:requestViewOffLineAIReward()
	end
	
	local eventUpdateOffLineBag = function()
		manager:showUI("OffLineBagView",E_ShowOption.eMiddle)
		local offLineBagView = manager:getViewByName("OffLineBagView")
		offLineBagView:updateBagView()
		offLineBagView:updateLogView()
	end
	
	local eventDrawOffLineAIReward = function()
		local offLineBagMgr = GameWorld.Instance:getOffLineBagMgr()
		offLineBagMgr:requestDrawOffLineAIReward()
	end
	
	local eventGetOffLineAIReward = function()
		local offLineBagMgr = GameWorld.Instance:getOffLineBagMgr()
		offLineBagObject = offLineBagMgr:getOffLineBagObject()
		offLineBagObject:clearItemList()
		offLineBagObject:clearGoldAndExp()
		manager:showUI("OffLineBagView",E_ShowOption.eMiddle)
		local offLineBagView = manager:getViewByName("OffLineBagView")
		offLineBagView:updateBagView()
		offLineBagView:updateLogView()
	end
	
	local eventSetOffLineAI = function()
		local setingTable = {}
		
		local offLineBagMgr = GameWorld.Instance:getEntityManager():getOffLineBagMgr()
		offLineBagMgr:requestOffLineAISeting(setingTable)
	end
	
	self:Bind(GameEvent.EventOpenOffLineBag,eventOpenOffLineBag)
	self:Bind(GameEvent.EventUpdateOffLineBag,eventUpdateOffLineBag)
	self:Bind(GameEvent.EventDrawOffLineAIReward,eventDrawOffLineAIReward)
	self:Bind(GameEvent.EventGetOffLineAIReward,eventGetOffLineAIReward)
	self:Bind(GameEvent.EventSetOffLineAI,eventSetOffLineAI)
end	

function BagUIHandler:showPutonTips(putOnTipsEquipList)
	local manager =UIManager.Instance
	--local index = 0	
	if self.index > 1000 then
		self.index = self.index % 1000
	end
	local viewName = " " 
	local icon = ""			
	local descStr = " "
	local curWord = " "
	local nextWord = " "
	local equipMgr = G_getEquipMgr()
	for k, v in pairs(putOnTipsEquipList) do	
		for kk, vv in pairs(v) do 		
			if vv:getSource() == E_EquipSource.inBag then	
				local exitFunc = function(arg)
					self:handlerExitFunc(arg)
				end
				
				local putOnEquip =  function(arg)
					self:handlerPutOnEquip(arg)			
				end
				
				
				--icon = G_GetItemICONByRefId(vv.refId)													
				
				local arg = {}
				arg.key = k
				arg.vv = vv
				arg.Id = vv:getPosId()
				
				
				local list = equipMgr:getEquipListByBodyAreaId(arg.key)
				local areaObj = nil 	
				if list then
					areaObj = list[arg.Id]
				end		
				if areaObj == nil  then
					viewName = "equipPutOnTips1" .. self.index
					arg.viewName = viewName
					curWord = G_getStaticPropsName(vv.refId)
					local view = UIManager.Instance:showPromptBox(viewName, 1)					
					view:setBtn("word_button_puton.png",putOnEquip,arg)
					view:setCloseNodify(exitFunc,arg)							
					arg.curIcon = ItemView.New()
					arg.curIcon:setItem(vv)	
					local showItemDetail = function()
						G_clickItemEvent(vv)
					end
					view:setIcon(arg.curIcon:getRootNode(),showItemDetail)
					view:setTitleWords(Config.Words[10191])	
					--view:setIconWord(curWord,G_getColorByItem(vv))
					descStr = Config.Words[10191]..":".. G_getStaticPropsName(vv.refId)
					view:setDescrition(descStr)							
					self.index = self.index + 1
				elseif areaObj:getType() == ItemType.eItemEquip then
					local ptTable = GameWorld.Instance:getEntityManager():getHero():getPT()
					local curLevel = PropertyDictionary:get_level(ptTable)
					local curGender = PropertyDictionary:get_gender(ptTable)
					local curProfessionId = PropertyDictionary:get_professionId(ptTable)

					local upperLimitLevel
					if curLevel<30 then
						upperLimitLevel = 30
					else
						upperLimitLevel = math.floor((curLevel)/10)*10
					end
					local refIdName = "level_" .. upperLimitLevel .. "_".. curProfessionId .. "_0"
					local bestEquitId = nil
					if GameData.EquipBest[refIdName] then
						bestEquitId =  GameData.EquipBest[refIdName].equitId
					end
					if bestEquitId and areaObj:getAreaOfBody(areaObj:getStaticData()) == E_BodyAreaId.eWeapon then
						viewName = "equipPutOnTips3" .. self.index
						arg.viewName = viewName							
						curWord = G_getStaticPropsName( areaObj:getStaticData().refId)
						nextWord = 	G_getStaticPropsName(vv.refId)								
						arg.curIcon = ItemView.New()
						arg.curIcon:setItem(areaObj)											
						arg.nextIcon = ItemView.New()
						arg.nextIcon:setItem(vv)
						
						local view = UIManager.Instance:showPromptBox(viewName, 3)					
						view:setBtn("word_button_puton.png",putOnEquip,arg)
						view:setCloseNodify(exitFunc,arg)
						local showCurItemDetail = function()
							G_clickItemEvent(areaObj)
						end
						local showNextItemDetail = function()
							G_clickItemEvent(vv)
						end
						view:setIcon(arg.curIcon:getRootNode(),arg.nextIcon:getRootNode(),showCurItemDetail,showNextItemDetail)
						view:setTitleWords(Config.Words[10191],Config.Words[10195])		
						--view:setIconWord(curWord , nextWord ,G_getColorByItem(areaObj) ,G_getColorByItem(vv) )
						
						local preFightValue = PropertyDictionary:get_fightValue(vv:getPT()) 
						local curFightValue =  PropertyDictionary:get_fightValue(areaObj:getPT())
						local fightValueImp = preFightValue - curFightValue 
						view:setCompareLabel( Config.Words[10193] .. fightValueImp)
						
						-- 当前等级最高装备						
						local itemObj = ItemObject.New()
						itemObj:setRefId(bestEquitId)
						itemObj:setStaticData(G_getStaticDataByRefId(bestEquitId))			
						local pt = table.cp(G_getStaticDataByRefId(bestEquitId).effectData)
						pt["fightValue"] = 0			
						itemObj:setPT(pt)		
						local bestFightValue = G_getEquipFightValue(itemObj.refId)
						if bestFightValue then
							itemObj:updatePT({fightValue = bestFightValue})	
						end								
						arg.bestIcon = ItemView.New()
						arg.bestIcon:setItem(itemObj)
						local bestWord = G_getStaticPropsName(itemObj.refId)	
						local showBestItemDetail = function()
							G_clickItemEvent(itemObj)
						end
						view:setBestIcon(arg.bestIcon:getRootNode(),showBestItemDetail,G_getColorByItem(itemObj))
						--PropertyDictionary:get_fightValue(itemObj:getPT()) 	
						local fightValueGap = bestFightValue - curFightValue
						view:setBestLabel( Config.Words[10193] .. fightValueGap)
						local exchangeFunc = function(arg)
							GlobalEventSystem:Fire(GameEvent.EventOpenMallView,3)
						end 
						view:setExchangeBtn(Config.Words[10196],exchangeFunc,arg)
						itemObj:DeleteMe()		
					else
						viewName = "equipPutOnTips2" .. self.index
						arg.viewName = viewName							
						curWord = G_getStaticPropsName( areaObj:getStaticData().refId)
						nextWord = 	G_getStaticPropsName(vv.refId)								
						arg.curIcon = ItemView.New()
						arg.curIcon:setItem(areaObj)											
						arg.nextIcon = ItemView.New()
						arg.nextIcon:setItem(vv)
						
						local view = UIManager.Instance:showPromptBox(viewName, 2)					
						view:setBtn("word_button_puton.png",putOnEquip,arg)
						view:setCloseNodify(exitFunc,arg)
						local showCurItemDetail = function()
							G_clickItemEvent(areaObj)
						end
						local showNextItemDetail = function()
							G_clickItemEvent(vv)
						end
						view:setIcon(arg.curIcon:getRootNode(),arg.nextIcon:getRootNode(),showCurItemDetail,showNextItemDetail)
						view:setTitleWords(Config.Words[10191],Config.Words[10195])		
						--view:setIconWord(curWord , nextWord ,G_getColorByItem(areaObj) ,G_getColorByItem(vv) )
						
						local preFightValue = PropertyDictionary:get_fightValue(vv:getPT()) 
						local curFightValue =  PropertyDictionary:get_fightValue(areaObj:getPT())
						local fightValueImp = preFightValue - curFightValue 
						view:setCompareLabel( Config.Words[10193] .. fightValueImp)
					end					
					self.index = self.index + 1
				end
				
			end
		end	
	end		
end

function BagUIHandler:isFpLess(a, b) 
	return PropertyDictionary:get_fightValue(a:getPT()) < PropertyDictionary:get_fightValue(b:getPT())
end

--将装备插入到穿戴提示列表
function BagUIHandler:insertEquip2TipsList(list, equipObj)
	for k, v in ipairs(list) do		
		if self:isFpLess(equipObj, v) then
			table.insert(list, k, equipObj)
			return
		end
	end
	table.insert(list, equipObj)	
end

--itemObj:setSource(E_EquipSource.inBag)
--初始化穿戴提示列表，如果为空，则将身上的装备放入这里
function BagUIHandler:getInitPutOnTipsEquipList()
	local putOnTipsEquipList = {}
	local bodyEquipList = G_getEquipMgr():getEquipList()
	if type(bodyEquipList) == "table" then
		for k, v in pairs(bodyEquipList) do
			for kk, vv in pairs(v) do
				if putOnTipsEquipList[k] == nil then
					putOnTipsEquipList[k] = {}
				end
				self:insertEquip2TipsList(putOnTipsEquipList[k], vv)
			end
		end
	end
	return putOnTipsEquipList
end

--检测该装备是否比list中的任意一个装备战斗力更大
function BagUIHandler:add2PutonTips(putOnTipsEquipList, equipObj)
	local equipMgr = G_getEquipMgr()
	local bodyAreaId = PropertyDictionary:get_areaOfBody(equipObj:getStaticData().property)		--该装备的穿戴部位
	local posCount = equipMgr:getPosCountByBodyAreaId(bodyAreaId)								--该部位可穿戴的装备数量
	local equipListInBodyArea = putOnTipsEquipList[bodyAreaId]									--该部位下已存放的用于提示自动穿戴的装备列表
	if equipListInBodyArea == nil then
		equipListInBodyArea = {}
	end
	if table.size(equipListInBodyArea) < posCount then
		self:insertEquip2TipsList(equipListInBodyArea, equipObj)
		local tmpList = G_getEquipMgr():getEquipListByBodyAreaId(bodyAreaId)
		if type(tmpList) ~= "table" then
			tmpList = {}
		end
		
		local usedPos = {}
		for k, v in pairs(equipListInBodyArea) do 
			if v:getPosId() then		
				usedPos[v:getPosId()] = true
			end
		end
		for i = 0, posCount - 1 do		--查询穿戴部位下的某个pos有没有装备
			if usedPos[i] == nil then
				equipObj:setPosId(i)	--设置穿戴部位，在自动穿戴时使用	
				break
			end
		end
	else		
		local first = equipListInBodyArea[1]	--equipListInBodyArea根据战力低到高排列	
		if self:isFpLess(first, equipObj) then	--跟战力最低的进行比较
			equipObj:setPosId(first:getPosId())		--设置穿戴部位，在自动穿戴时使用
			table.remove(equipListInBodyArea, 1)	--删除掉战力最小的			
			self:insertEquip2TipsList(equipListInBodyArea, equipObj) --把这个obj插入到equipListInBodyArea中
		else
			return false
		end
	end
	putOnTipsEquipList[bodyAreaId] = equipListInBodyArea
	return true
end

--判断是否新装备，并提示穿戴
function BagUIHandler:checkPutonTips(map)		
	local equipMgr = G_getEquipMgr()
	local bagMgr = G_getBagMgr()	
	local record = bagMgr:getItemRecord()			
	local putOnTipsEquipList = nil
	local needTip = false	
	
	for k, v in pairs(map) do
		local canPut, des
		if v:getType() == ItemType.eItemEquip and (not record[v:getId()]) then	
			canPut, _, des = G_getBagMgr():getOperator():checkCanPutOnEquip(v) 	
			if canPut then
				if not putOnTipsEquipList then
					putOnTipsEquipList = self:getInitPutOnTipsEquipList()						
				end
				local ret = self:add2PutonTips(putOnTipsEquipList, v)		
				if ret then
					needTip = true
				end
				record[v:getId()] = 1
			else
				if des ~= E_UnableEquipType.Level then
					record[v:getId()] = 1
				end
			end
		end
	end		
	if needTip then
		self:showPutonTips(putOnTipsEquipList)
	end
end

function BagUIHandler:__delete()
	
end	

-------------------------------------------------------
function BagUIHandler:handlerPutOnEquip(arg)
	local equipMgr = G_getEquipMgr()
	equipMgr:requestEquipPutOn(arg.vv, arg.key, arg.Id)							
	local vView = UIManager.Instance:getViewByName(arg.viewName)							
	vView:close()	
	if arg.curIcon then
		arg.curIcon:DeleteMe()
		arg.curIcon = nil								
	end
		
	if arg.nextIcon then
		arg.nextIcon:DeleteMe()
		arg.nextIcon = nil	
	end	
	
	if arg.bestIcon then
		arg.bestIcon:DeleteMe()
		arg.bestIcon = nil
	end				
end

function BagUIHandler:handlerExitFunc(arg)
	local vView = UIManager.Instance:getViewByName(arg.viewName)							
	vView:close()	
	if arg.curIcon then
		arg.curIcon:DeleteMe()
		arg.curIcon = nil								
	end
		
	if arg.nextIcon then
		arg.nextIcon:DeleteMe()
		arg.nextIcon = nil	
	end	
	
	if arg.bestIcon then
		arg.bestIcon:DeleteMe()
		arg.bestIcon = nil
	end	
end