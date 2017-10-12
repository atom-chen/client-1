require("object.npc.NpcDef")
require("object.npc.TransObject")
require("ui.Npc.NpcBaseView")
require("data.npc.npc")
require("common.BaseUI")
NpcTransView = NpcTransView or BaseClass(NpcBaseView)

visibleSize = CCDirector:sharedDirector():getVisibleSize()
viewScale = VisibleRect:SFGetScale()

viewTransSize = CCSizeMake(400*viewScale,540*viewScale)

function NpcTransView:__init()
	self.viewName = "NpcTransView"
		
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()	
	local npcMgr = GameWorld.Instance:getNpcManager()
	local viewNpcId = questMgr:getNpcTalkViewInfo()	
	self:initHalfScreen()									
	self:createViewBg()
	self:InitTransValue(viewNpcId)
	self:createTransView()	
end

function NpcTransView:__delete()

end

function NpcTransView:onExit()
	self.moveToItem = nil
end

function NpcTransView:onEnter(moveToItem)
	self.moveToItem = moveToItem
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()	
	local viewNpcId = questMgr:getNpcTalkViewInfo()	
	self:InitTransValue(viewNpcId)
	self:updateAreaView()
	self:setTalkConcent()
end

function NpcTransView:create()
	return NpcTransView.New()
end	

--显示谈话内容
function NpcTransView:showTalkConcent(viewNpcId,viewSize)
	--[[local childViewSize	
	if( viewSize == nil ) then
		childViewSize = CCSizeMake((393-20-50)*viewScale,150*viewScale)
	else
		childViewSize = viewSize
	end
	
	local containerNode = CCNode:create()
	containerNode:setContentSize(childViewSize)
	
	--ScrollView
	local scrollView = createScrollViewWithSize(childViewSize)
	scrollView:setDirection(kSFScrollViewDirectionVertical)
	scrollView:setPageEnable(true)
	scrollView:setContainer(containerNode)
	self.view:addChild(scrollView)
	VisibleRect:relativePosition(scrollView, self.view, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(10+50, -50))--]]

	--NPC谈话内容
	local npcTalkWord = ""
	if GameData.Npc[viewNpcId]~=nil then
		npcTalkWord = GameData.Npc[viewNpcId]["property"]["description"]
		--npcTalkWord = string.wrapRich( GameData.Npc[viewNpcId]["property"]["description"],Config.FontColor["ColorWhite1"],FSIZE("Size2"))
	else
		npcTalkWord = Config.Words[3202]
		--npcTalkWord = string.wrapRich(Config.Words[3202],Config.FontColor["ColorBlack1"],FSIZE("Size2"))
	end
	npcTalkWord = "       " .. npcTalkWord 
	self:setNpcText(npcTalkWord)
	--[[self.questTitle = createRichLabel(CCSizeMake(childViewSize.width-20,0))
	self.questTitle:setFont(Config.fontName["fontName1"])	
	self.questTitle:appendFormatText(npcTalkWord)
	containerNode:addChild(self.questTitle)
	VisibleRect:relativePosition(self.questTitle,containerNode,LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  , CCPointMake(40,-20))--]]
end

--改变谈话内容
function NpcTransView:setTalkConcent()
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local viewNpcId = questMgr:getNpcTalkViewInfo()
	
	local npcTalkWord = ""
	if GameData.Npc[viewNpcId]~=nil then
		npcTalkWord = GameData.Npc[viewNpcId]["property"]["description"]
		--npcTalkWord = string.wrapRich( GameData.Npc[viewNpcId]["property"]["description"],Config.FontColor["ColorWhite1"],FSIZE("Size2"))
	else
		npcTalkWord = Config.Words[3202]
		--npcTalkWord = string.wrapRich(Config.Words[3202],Config.FontColor["ColorBlack1"],FSIZE("Size2"))
	end
	npcTalkWord = "    " .. npcTalkWord
	self:setNpcText(npcTalkWord)
	--[[if self.questTitle then
		self.questTitle:clearAll()
		self.questTitle:appendFormatText(npcTalkWord)
	end--]]
end

function NpcTransView:createTransView()
	transCount = table.size(self.transList)		
	self.view = CCNode:create()
	self.view:setContentSize(viewTransSize)
	self:addChild(self.view )
	VisibleRect:relativePosition(self.view,self:getContentNode(), LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE ,ccp(0,40))	
	
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local viewNpcId = questMgr:getNpcTalkViewInfo()	
	
	local label = createLabelWithStringFontSizeColorAndDimension(Config.Words[3145],"Arial",FSIZE("Size2")*viewScale, FCOLOR("ColorWhite1"))
	self.view:addChild(label)	
	VisibleRect:relativePosition(label,self.view,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(40,20))	
	--显示NPC图片
	self:setNpcAvatar(viewNpcId)
	self:setNpcName(viewNpcId)
	--self:showNpcPic()		
	--显示谈话内容
	local contentviewSize = CCSizeMake((393-20)*viewScale,65*viewScale)
	self:showTalkConcent(viewNpcId,contentviewSize)	
	
end


function NpcTransView:InitTransValue(viewNpcId)
	self.transList = {}
	self.cityAreaList = {}
	self.damageAreaList = {}
	self.activityAreaList = {}			
	local x = 1
	local y = 1
	local z = 1
	self.total = 0
			
	for k,v in pairs(G_GetNpcTransList(viewNpcId))	do
		local limLevel = G_GetLimitLevel(v.targetScene)
		local heroObj = GameWorld.Instance:getEntityManager():getHero()
		local Level = PropertyDictionary:get_level(heroObj:getPT())
		if(Level < limLevel)then
			
		else
			local obj = TransObject.New()
			stype = G_GetSceneType(v.targetScene)					
			obj:setType(stype)
			obj:setTransName(v.name .." ( Lv." ..limLevel .." )")
			obj:setTransInId(v.tranferInId)
			obj:setTargetScene(v.targetScene)
			self.transList[k] = obj
			if(stype == 0 or stype == 4 ) then
				self.cityAreaList[x] = obj
				x = x + 1
				self.total = self.total + 1
			elseif(stype == 1 or stype == 2) then
				self.damageAreaList[y]= obj
				y = y + 1
				self.total = self.total + 1	
--[[			elseif(stype == 2) then  健圻说: 新手村+野外场景在城市区域 活动地图+地宫在危险区域 原来的活动区域取消
				self.activityAreaList[z] = obj
				z = z + 1
				self.total = self.total + 1--]]
			else							
			end
		end
	end
	
end

function NpcTransView:updateAreaView()
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local viewNpcId = questMgr:getNpcTalkViewInfo()
	local scrollViewSize = self:getNpcViewNode():getContentSize()	
	local  lineNum = math.ceil(table.size(self.cityAreaList) /2 ) +  math.ceil(table.size(self.damageAreaList) /2 ) +  math.ceil(table.size(self.activityAreaList) /2 )
	local height = 0	
	if((lineNum + 3)*40*viewScale  <  scrollViewSize.height-50) then
		height =  scrollViewSize.height-50
	else
		height = (lineNum + 3)*40*viewScale
	end
	local DesViewSize = CCSizeMake((393-20)*viewScale,height)	
	if self.contNode then
		self.contNode:removeFromParentAndCleanup(true)
		self.contNode = nil
	end
	self.contNode = CCNode:create()	
	self.contNode:setContentSize(DesViewSize)

	local col1 = 1	
	if table.size(self.cityAreaList)>0 then
		local citySprite = createScale9SpriteWithFrameName(RES("npc_cityAreatext.png"))
		VisibleRect:relativePosition(citySprite,self.contNode,LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  ,ccp(20,-40*(col1-1)))
		self.contNode:addChild(citySprite)			
		col1 = col1 + 1
		--分割线
		local viewLine1 =  createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake((393-20)*viewScale, 2))
		self.contNode:addChild(viewLine1)
		VisibleRect:relativePosition(viewLine1,self.contNode, LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  ,ccp(10,20 - 40*(col1-1)))		
		--显示功能按钮		
		for k,v in pairs(self.cityAreaList) do			
			local bt = createButtonWithFramename(RES("common_wordBg2.png"),RES("common_wordBg2.png"))					
			if(k%2 == 1)then		
				VisibleRect:relativePosition(bt,self.contNode,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE ,ccp(20,-40*(col1-1)))	
			else
				VisibleRect:relativePosition(bt,self.contNode,LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE ,ccp(-20,-40*(col1-1)))	
				col1 = col1 + 1
			end
			self.contNode:addChild(bt)		
			local bt_text = createLabelWithStringFontSizeColorAndDimension(v:getTransName(), "Arial", FSIZE("Size2")*viewScale, FCOLOR("ColorWhite1"))		
			bt:setTitleString(bt_text)
			VisibleRect:relativePosition(bt_text,bt,  LAYOUT_CENTER)									
			local npcFunc = function()				
				if self.moveToItem then
					G_getHandupMgr():stop()		
					local gridId = self.moveToItem:getGridId()
					G_getBagMgr():requestUseTransferStone(gridId,v:getTargetScene(),v:getTransInId())
					self.moveToItem = nil
				else
					local gameMapManager = GameWorld.Instance:getMapManager()
					gameMapManager:requestNpcSceneSwitch(viewNpcId,v:getTargetScene(),v:getTransInId())
				end
				local uiManager = UIManager.Instance
				uiManager:hideUI(self.viewName)
			end				
			bt:addTargetWithActionForControlEvents(npcFunc,CCControlEventTouchDown)		
		end	
		if(table.size(self.cityAreaList)%2 == 1)then 
			col1 = col1 + 1
		end				
	end	
	--危险区域
	
	if  table.size(self.damageAreaList) >0 then 
		local damageSprite = createScale9SpriteWithFrameName(RES("npc_damageAreatext.png"))
		VisibleRect:relativePosition(damageSprite,self.contNode,LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  ,ccp(20,-40*(col1-1)))
		self.contNode:addChild(damageSprite)
		--分割线	
		col1 = col1 + 1	
		local viewLine2 = createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake((393-20)*viewScale,2))
		self.contNode:addChild(viewLine2)
		VisibleRect:relativePosition(viewLine2,self.contNode, LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  ,ccp(10,20-40*(col1-1)))			
		for k,v in pairs(self.damageAreaList) do			
			local bt = createButtonWithFramename(RES("common_wordBg2.png"),RES("common_wordBg2.png"))				
			if(k%2 == 1)then		
				VisibleRect:relativePosition(bt,self.contNode,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE ,ccp(20,-40*(col1-1)))			
			else
				VisibleRect:relativePosition(bt,self.contNode,LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE ,ccp(-20,-40*(col1-1)))
				col1 = col1 + 1				
			end
			self.contNode:addChild(bt)		
			local bt_text = createLabelWithStringFontSizeColorAndDimension(v:getTransName(), "Arial", FSIZE("Size2")*viewScale, FCOLOR("ColorWhite1"))		
			bt:setTitleString(bt_text)
			VisibleRect:relativePosition(bt_text,bt,  LAYOUT_CENTER)									
			local npcFunc = function()		
				if self.moveToItem then
					G_getHandupMgr():stop()		
					local gridId = self.moveToItem:getGridId()
					G_getBagMgr():requestUseTransferStone(gridId,v:getTargetScene(),v:getTransInId())
					self.moveToItem = nil
				else
					local gameMapManager = GameWorld.Instance:getMapManager()
					gameMapManager:requestNpcSceneSwitch(viewNpcId,v:getTargetScene(),v:getTransInId())
				end
				local uiManager = UIManager.Instance
				uiManager:hideUI(self.viewName)
			end	
			bt:addTargetWithActionForControlEvents(npcFunc,CCControlEventTouchDown)		
		end	
		if(table.size(self.damageAreaList)%2 == 1)then 
			col1 = col1 + 1
		end	
	end
	if table.size(self.activityAreaList) > 0 then					
		--活动区域
		local activitySprite = createScale9SpriteWithFrameName(RES("npc_activityAreatext.png"))
		VisibleRect:relativePosition(activitySprite,self.contNode,LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  ,ccp(20,-(40*(col1-1))))
		self.contNode:addChild(activitySprite)
		col1 = col1 + 1
		--分割线
		local viewLine3 = createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake((393-20)*viewScale,2))
		self.contNode:addChild(viewLine3)
		VisibleRect:relativePosition(viewLine3,self.contNode, LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  ,ccp(10,20-(40*(col1-1))))			
		for k,v in pairs(self.activityAreaList) do			
			local bt = createButtonWithFramename(RES("common_wordBg2.png"),RES("common_wordBg2.png"))	
			if(k%2 == 1)then		
				VisibleRect:relativePosition(bt,self.contNode,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE ,ccp(20,-40*(col1-1)))	
			else
				VisibleRect:relativePosition(bt,self.contNode,LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE ,ccp(-20,-40*(col1-1)))	
				col1 = col1 + 1
			end
			self.contNode:addChild(bt)		
			local bt_text = createLabelWithStringFontSizeColorAndDimension(v:getTransName(), "Arial", FSIZE("Size2")*viewScale, FCOLOR("ColorWhite1"))		
			bt:setTitleString(bt_text)
			VisibleRect:relativePosition(bt_text,bt,  LAYOUT_CENTER)														
			local npcFunc = function()			
				if self.moveToItem then
					G_getHandupMgr():stop()		
					local gridId = self.moveToItem:getGridId()
					G_getBagMgr():requestUseTransferStone(gridId,v:getTargetScene(),v:getTransInId())
					self.moveToItem = nil
				else
					local gameMapManager = GameWorld.Instance:getMapManager()
					gameMapManager:requestNpcSceneSwitch(viewNpcId,v:getTargetScene(),v:getTransInId())
				end
				local uiManager = UIManager.Instance
				uiManager:hideUI(self.viewName)
			end	
			bt:addTargetWithActionForControlEvents(npcFunc,CCControlEventTouchDown)		
		end	
	end	
	
	--ScrollView
	local scrollViewSize = self:getNpcViewNode():getContentSize()
	local DesscrollView3 = createScrollViewWithSize(CCSizeMake(scrollViewSize.width, scrollViewSize.height-50))
	DesscrollView3:setDirection(kSFScrollViewDirectionVertical)	
	DesscrollView3:setContainer(self.contNode)
	DesscrollView3:setContentOffset(ccp(0, scrollViewSize.height-DesViewSize.height-50))
	self:addChild(DesscrollView3)
	VisibleRect:relativePosition(DesscrollView3, self:getNpcViewNode(), LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X,ccp(0,-10))
	
	
end

function NpcTransView:touchHandler(eventType, x, y)
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
end