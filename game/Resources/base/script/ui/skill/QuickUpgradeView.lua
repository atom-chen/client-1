--[[
--快捷技能设置界面

--]]
require "common.BaseUI"

QuickUpgradeView = QuickUpgradeView or BaseClass(BaseUI)

local scale = VisibleRect:SFGetScale()

local TouchProperty = {
UpDir = 1,             --向上滑动
DownDir = 2,           --向下滑动
Distance = 20,         --滑动多长距离才算是移动到下一页
}

local PageProperty = {
Page1 = 1,            --第一页
Page2 = 2,            --第二页
TotalPage = 2,        --一共两页
ItemsPerPage = 4,     --每一页4个Item
}

local OperationType = {
Delete = 1,      --操作统一个技能槽，即删除icon
Add = 2,         --原来技能槽没有， 添加icon
Replace = 3,     --原来技能槽上的技能和要操作的不一样，即替换原来的icon
Move = 4,
}

local visibleSize = CCDirector:sharedDirector():getVisibleSize()

function QuickUpgradeView:__init()
	self.quickSkills = {} --存放快捷技能	
	self.curSkillRefId = nil --当前技能
	
	self.quickNodes = {}
	self.iconCache = {}
	
	self.point = {}
	self.curShowPage = PageProperty.Page1
	self.skillChangeCount = 0
	self.recvChangeCount = 0
	
	self.rootNode:setContentSize(visibleSize)
	self.viewName = "QuickUpgradeView"
	self.rootNode:setTouchEnabled(true)
	self:initView()
	self:createSolts()
end

function QuickUpgradeView:__delete()
	for refid, sprite in pairs(self.iconCache) do
		if sprite then
			sprite:release()
		end
	end
end

function QuickUpgradeView:create()
	return QuickUpgradeView.New()
end

function QuickUpgradeView:onEnter()
	self.forbidCicle = false
	self.rootNode:stopAllActions()
end

function QuickUpgradeView:onExit()
	GameWorld.Instance:getNewGuidelinesMgr():requestFunStepCompleteRequest("handUpSkillGuidence")
end

--ccp(x,y)是否在node里
function QuickUpgradeView:isTouchIn(node, x, y)
	if node:isVisible() and node:getParent() then
		local parent = node:getParent()
		local point = parent:convertToNodeSpace(ccp(x, y))
		local rect = node:boundingBox()
		if rect:containsPoint(point) then
			return true
		else
			return false
		end
	end
end

--检测哪个槽被点中了
function QuickUpgradeView:getClickIndex(x, y)
	for i = 1, PageProperty.TotalPage*PageProperty.ItemsPerPage do
		if self:isTouchIn(self.quickSkills[i], x, y) then
			return i
		end
	end
end

--根据检测槽对应的index是否合法
function QuickUpgradeView:isIndexLegal(index)
	if index and index>0 and index<=PageProperty.ItemsPerPage*PageProperty.TotalPage then
		return true
	else
		return false
	end
end


function QuickUpgradeView:handleSoltClick(x, y)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"QuickUpgradeView")
	--快捷技能设置后，在退出之前不能再次选择
	if self.forbidCicle then
		return
	end
	local index = self:getClickIndex(x, y)
	local bLegal = self:isIndexLegal(index)
	if bLegal then
		local updateTable = {}  --用于向服务器更新
		local operate = self:getOperationType(index)
		local icon = self:getIconSprite(self.curSkillRefId)
		local skillMgr = G_getHero():getSkillMgr()
		local orgRefId =skillMgr:getOrginalRefId(self.curSkillRefId)
		if icon then
			if OperationType.Add == operate then
				self.skillChangeCount = self.skillChangeCount + 1
				self:setUpdateTable(updateTable, "modify", orgRefId, index)
				icon:setTag(index)
				self.quickSkills[index]:addChild(icon)
				VisibleRect:relativePosition(icon, self.quickSkills[index], LAYOUT_CENTER)
			elseif OperationType.Delete == operate then
				self.skillChangeCount = self.skillChangeCount + 1
				self:setUpdateTable(updateTable, "delete", orgRefId, -1)
				self:removeIconByIndex(index)
			elseif OperationType.Replace == operate then
				local tagRefId = skillMgr:getQuickSkillRefIdByIndex(index)
				tagRefId =skillMgr:getOrginalRefId(tagRefId)
				self.skillChangeCount = self.skillChangeCount + 2
				self:setUpdateTable(updateTable, "delete", tagRefId, index)
				self:setUpdateTable(updateTable, "modify", orgRefId, index)
				
				if icon:getParent() then
					icon:removeFromParentAndCleanup(true)
					icon:setTag(0)
				end
				self:removeIconByIndex(index)
				icon:setTag(index)
				self.quickSkills[index]:addChild(icon)
				VisibleRect:relativePosition(icon, self.quickSkills[index], LAYOUT_CENTER)
			else--[[if OperationType.Move == operate then--]]
				self.skillChangeCount = self.skillChangeCount + 1
				self:setUpdateTable(updateTable, "modify", orgRefId, index)
				icon:removeFromParentAndCleanup(true)
				icon:setTag(index)
				self.quickSkills[index]:addChild(icon)
				VisibleRect:relativePosition(icon, self.quickSkills[index], LAYOUT_CENTER)
			end
			--向服务器更新MarkList
			skillMgr:requestSetPutdownSkills(updateTable)
			
			local skillName = PropertyDictionary:get_name(GameData.Skill[orgRefId].property)
			local msg = {}
			if OperationType.Delete == operate then
				table.insert(msg,{word = Config.Words[2510], color = Config.FontColor["ColorWhite1"]})
			else
				table.insert(msg,{word = Config.Words[2508], color = Config.FontColor["ColorWhite1"]})
			end
			table.insert(msg,{word = "\""..skillName.."\"", color = Config.FontColor["ColorRed3"]})
			UIManager.Instance:showSystemTips(msg)
			
			self.forbidCicle = true
		end
				
		self:hideMyself(0.5)				
	end
end

function QuickUpgradeView:cancelAllSkill()
	local skillMgr = G_getHero():getSkillMgr()
	local quickList = skillMgr:getMarkList()
	self.skillChangeCount = table.size(quickList)
	for refId, v in pairs(quickList) do 
		local updateTable = {}		
		local refId = skillMgr:getQuickSkillRefIdByIndex(v.index)
		refId = skillMgr:getOrginalRefId(refId)	
		self:setUpdateTable(updateTable, "delete", refId, -1)
		self:removeIconByIndex(v.index)
		skillMgr:requestSetPutdownSkills(updateTable)
	end
	--[[if not self:getIsNewGuide() then
		self.forbidCicle = true
	end--]]
end

function QuickUpgradeView:doCancelSkill(index)
	self.skillChangeCount = self.skillChangeCount + 1
	local updateTable = {}
	local skillMgr = G_getHero():getSkillMgr()
	local refId = skillMgr:getQuickSkillRefIdByIndex(index)
	refId = skillMgr:getOrginalRefId(refId)	
	self:setUpdateTable(updateTable, "delete", refId, -1)
	self:removeIconByIndex(index)

	skillMgr:requestSetPutdownSkills(updateTable)
	if not self:getIsNewGuide() then
		self.forbidCicle = true
	end
			
end

function QuickUpgradeView:removeIconByIndex(index)
	local tagIcon = self.quickSkills[index]:getChildByTag(index)
	if tagIcon then
		tagIcon:removeFromParentAndCleanup(true)
		tagIcon:setTag(0)
	end
end

function QuickUpgradeView:setUpdateTable(updateTable, updateType, refId, index)
	if updateType == "delete" then
		updateTable.delete = {}
		updateTable.delete.refId = refId
		updateTable.delete.index = -1 --表示要取消

	elseif updateType == "modify" then
		updateTable.modify = {}
		updateTable.modify.refId = refId
		updateTable.modify.index = index
	end
end

--获取用户操作的类型
function QuickUpgradeView:getOperationType(index)
	local orgIcon = self.quickSkills[index]:getChildByTag(index)
	local tagIcon = self:getIconSprite(self.curSkillRefId)
	if not orgIcon then
		if not tagIcon:getParent() then
			return OperationType.Add
		else
			return OperationType.Move
		end
	else
		if tagIcon == orgIcon then
			return OperationType.Delete
		else
			return OperationType.Replace
		end
	end
end

function QuickUpgradeView:registerScriptTouchHandler()
	local function ccTouchHandlerqwe(eventType, x,y)
		if self:isTouchIn(self.rootNode, x, y) then
			if eventType == "began" then
				self.point.x = x
				self.point.y = y
			elseif eventType == "moved" then
				if x < self.point.x-TouchProperty.Distance and y < self.point.y-TouchProperty.Distance then
					if self.forbidCicle == false then
						self:runAsCicle(TouchProperty.DownDir)
					end
				elseif x > self.point.x+TouchProperty.Distance and y > self.point.y+TouchProperty.Distance then
					if self.forbidCicle == false then
						self:runAsCicle(TouchProperty.UpDir)
					end
				end
			else--[[if eventType == "ended" then--]]				
				local xOffset = self.point.x - x
				if (math.abs(xOffset) < 5) then	--当x坐标偏移在5以内，才认为是点击	
					self:handleSoltClick(x, y)
				end
			end
			return 1
		else
			return 0
		end
		
	end
	self.rootNode:registerScriptTouchHandler(ccTouchHandlerqwe, false,UIPriority.Control, true)
end

function QuickUpgradeView:initView()
	--背景
	self.bg =  createScale9SpriteWithFrameName(RES("squares_bag_bg.png"))
	self.bg:setPreferredSize(visibleSize)
	self.rootNode:addChild(self.bg)
	VisibleRect:relativePosition(self.bg, self.rootNode, LAYOUT_CENTER)
	
	--旋转的Node
	self.rotateNode = CCLayer:create()
	self.rotateNode:setContentSize(visibleSize)
	self.rootNode:addChild(self.rotateNode)
	VisibleRect:relativePosition(self.rotateNode, self.rootNode, LAYOUT_CENTER)
	self.rotateNode:setAnchorPoint(ccp(1, 0))
	
	for i = 1, PageProperty.TotalPage do
		self.quickNodes[i] = CCLayer:create()
		self.quickNodes[i]:setContentSize(visibleSize)
		self.rotateNode:addChild(self.quickNodes[i])
		VisibleRect:relativePosition(self.quickNodes[i], self.rootNode, LAYOUT_CENTER)
	end
	
	-- 关闭按钮
	self.btnClose = createButtonWithFramename(RES("btn_close.png"))
	self.rootNode:addChild(self.btnClose)
	local btnCloseSize = self.btnClose:getContentSize()
	VisibleRect:relativePosition(self.btnClose,self.bg,LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(-60*scale, -43*scale))
	function close()
		self:hideMyself()
	end
	self.btnClose:addTargetWithActionForControlEvents(close, CCControlEventTouchDown)
end	

--创建技能槽
function QuickUpgradeView:createSolts()
	for i = 1, PageProperty.TotalPage do
		for j = 1, PageProperty.ItemsPerPage do
			local index = (i-1)*PageProperty.ItemsPerPage+j
			self.quickSkills[index] = createSpriteWithFrameName(RES("main_skillframe.png"))
			self.quickNodes[i]:addChild(self.quickSkills[index])
			VisibleRect:relativePosition(self.quickSkills[index], self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, SkillUtils.Instance:getSkillSoltPos(j))
		end
		SkillUtils.Instance:createArrowNode(self.quickNodes[i], i, true, self.rootNode)
		--第二页旋转90度,第三页旋转180度,以此类推
		if i > 1 then
			self.quickNodes[i]:setAnchorPoint(ccp(1, 0))
			self.quickNodes[i]:setRotation(90*(i-1))
		end
	end
end

function QuickUpgradeView:getIconSprite(refId)
	if self.iconCache[refId] == nil then
		local skillMgr = GameWorld.Instance:getEntityManager():getHero():getSkillMgr()
		local skillObject = skillMgr:getSkillObjectByRefId(refId)
		if skillObject ~= nil then
			local iconId = PropertyDictionary:get_iconId(skillObject:getStaticData())
			if iconId ~= nil then
				local sprite = createSpriteWithFileName(ICON(iconId))
				sprite:setTag(0)
				sprite:retain()
				self.iconCache[refId] = sprite
			end
		end
	end
	return self.iconCache[refId]
end

function QuickUpgradeView:updateQuickSkills(skillRefId)
	self.curSkillRefId = G_getHero():getEquipSkill(skillRefId)
	local skillMgr = GameWorld.Instance:getEntityManager():getHero():getSkillMgr()
	local markTable = skillMgr:getMarkList()
	--todo
	for i = 1, PageProperty.ItemsPerPage*PageProperty.TotalPage do
		self.quickSkills[i]:removeChildByTag(i, true)
	end
	for refId, value in pairs(markTable) do
		refId = G_getHero():getEquipSkill(refId)
		local icon = self:getIconSprite(refId)
		local index = value.index
		icon:setTag(index)
		if  index > 0 and index < 9 then
			self.quickSkills[index]:addChild(icon)
			VisibleRect:relativePosition(icon, self.quickSkills[index], LAYOUT_CENTER)
		end
	end
end


function QuickUpgradeView:runAsCicle(dir)
	if self.rotateNode:numberOfRunningActions()>0 then
		return
	end
	local actionArray = CCArray:create()
	if dir == TouchProperty.UpDir then
		if self.curShowPage == PageProperty.Page2 then
			self.rotateNode:setRotation(-90)
			local rotateBy = CCRotateBy:create(0.3, 95)
			local bounce = CCEaseBounceInOut:create(rotateBy)
			local rotateBack = CCRotateBy:create(0.1, -5)
			actionArray:addObject(bounce)
			actionArray:addObject(rotateBack)
			local actions = CCSequence:create(actionArray)
			actions:setTag(dir)
			self.rotateNode:runAction(actions)
			self.curShowPage = PageProperty.Page1
			
			--[[self.rotateNode:setRotation(-90)
			local rotateBy = CCRotateBy:create(0.2, 90)
			self.rotateNode:runAction(rotateBy)
			self.curShowPage = PageProperty.Page1--]]
		end
	else
		if self.curShowPage == PageProperty.Page1 then
			self.rotateNode:setRotation(0)
			local rotateBy = CCRotateBy:create(0.3, -95)
			local bounce = CCEaseBounceInOut:create(rotateBy)
			local rotateBack = CCRotateBy:create(0.1, 5)
			local bounce = CCEaseBounceOut:create(rotateBy)
			actionArray:addObject(bounce)
			actionArray:addObject(rotateBack)
			local actions = CCSequence:create(actionArray)
			actions:setTag(dir)
			self.rotateNode:runAction(actions)
			self.curShowPage = PageProperty.Page2
			
			--[[self.rotateNode:setRotation(0)
			local rotateBy = CCRotateBy:create(0.2, -90)
			self.rotateNode:runAction(rotateBy)
			self.curShowPage = PageProperty.Page2--]]
		end
		
	end
end	

function QuickUpgradeView:hideMyself(delay)
	if delay and type(delay)=="number" then
		local TimeFunc = function ()
			local manager =UIManager.Instance
			manager:hideUI("QuickUpgradeView")
		end
		local ccfunc = CCCallFunc:create(TimeFunc)
		local delayAction = CCDelayTime:create(tonumber(delay))
		local sequence = CCSequence:createWithTwoActions(delayAction,ccfunc)
		self.rootNode:runAction(sequence)
	else
		local manager =UIManager.Instance
		manager:hideUI("QuickUpgradeView")
	end						
end	

----------------------新手指引----------------------
function QuickUpgradeView:getFirstQuickSkillSolt()
	if self.quickSkills and self.quickSkills[1] then
		return self.quickSkills[1]--[[:getChildByTag(10)--]]
	end
end

function QuickUpgradeView:setIsNewGuide(inNewGuide)
	self.isNewGuide = inNewGuide
end

function QuickUpgradeView:getIsNewGuide()
	return self.isNewGuide
end