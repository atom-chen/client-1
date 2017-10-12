require("ui.UIManager")
require("common.BaseUI")
require("object.activity.ActivityObj")
require("ui.utils.ActivityIcon")
require("ui.utils.LayoutNode")

ActivityManageView = ActivityManageView or BaseClass(BaseUI)

local const_cellSize = CCSizeMake(84, 94)
local const_column = 6
function ActivityManageView:__init()
	self.viewName = "ActivityManageView"		
		
	self.typeActivityMap = 
	{	
		{ttype = ActivityType.Daily, name = "dailyActivity.png", nameLable = nil, line = nil ,layoutNode = nil},
		{ttype = ActivityType.OpenServer, name = "openActivity.png", nameLable = nil, line = nil ,layoutNode = nil},
		{ttype = ActivityType.BuyGuide, name = "recommendActivity.png", nameLable = nil, line = nil ,layoutNode = nil},
		{ttype = ActivityType.Feedback, name = "retroactionActivity.png", nameLable = nil, line = nil ,layoutNode = nil},
	}
	self.refIdActivityIconMap = {} --[refId]-iconNode 用于快速查找/缓存ActivityIcon
		
	self:initUI()	
	self:loadUI()
	self:layout()
	
	--注册活动管理的回调
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()		
	local onActivityNotify = function(refId, activityType, event, info)
		self:onActivityNotify(refId, activityType, event, info)
	end
	self.activityNotifyId = activityManageMgr:addActivityNotify(onActivityNotify)
end		

function ActivityManageView:__delete()
	self:clear()
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()		
	if self.activityNotifyId then
		activityManageMgr:removeActivityNotify(self.activityNotifyId)
	end
end	

function ActivityManageView:initUI()
	local title = createSpriteWithFrameName(RES("word_window_activity.png"))
	local frameSize = CCSizeMake(931, 578)
	self:createVipFrame(frameSize, title)	
	self:createVipFrameCloseBtn()
	
	local bg = createScale9SpriteWithFrameName(RES("squares_bg2.png"))
	bg:setContentSize(CCSizeMake(815, 510))
	self:addChild(bg)
	VisibleRect:relativePosition(bg, self:getContentNode(), LAYOUT_CENTER, ccp(0, 0))
	
	self.viewSize = self:getContentNode():getContentSize()
	self.viewSize.height = self.viewSize.height - 50
	self.scrollNode = CCNode:create()
	self.scrollNode:setContentSize(self.viewSize)	
	
	self.scrollView = createScrollViewWithSize(CCSizeMake(self.viewSize.width,self.viewSize.height))	
	self.scrollView:setDirection(2)
	self.scrollView:setContainer(self.scrollNode)
	self:addChild(self.scrollView)
	VisibleRect:relativePosition(self.scrollView, self:getContentNode(), LAYOUT_CENTER)	
	self:createLayoutNode()
end

--使用 LayoutNode 来管理每个类型的活动图标
function ActivityManageView:createLayoutNode()
	for k, v in ipairs(self.typeActivityMap) do
		v.nameLabel = createSpriteWithFrameName(RES(v.name))		
		self.scrollNode:addChild(v.nameLabel)
		
		if k ~= 1 then
			v.line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"), CCSizeMake(730, 2))
			self.scrollNode:addChild(v.line)
		end
				
		v.layoutNode = LayoutNode.New()
		v.layoutNode:initWithBatchPvr("ui/ui_game/ui_game_mainView.pvr")	--使用批处理的方式优化
		v.layoutNode:setSpacing(25, 7)
		v.layoutNode:setColumn(const_column)	--设置列数，超过该列数的活动分类则自动换行
		v.layoutNode:setCellSize(const_cellSize)
		v.layoutNode:setTouchEnabled(true)
		
		local onActivityClick = function(index)
			if not v.layoutNode:isVisible() then
				return
			end
			local grid = v.layoutNode:getGridAtIndex(index)
			if not grid then
				return
			end
			if grid:getData() then
				GlobalEventSystem:Fire(GameEvent.EventActivityClick, grid:getData():getRefId())					
			end
		end
		v.layoutNode:setTouchNotify(onActivityClick)
		self.scrollNode:addChild(v.layoutNode:getRootNode(), 10)	
	end
end

--onEnter不能删，需要引导活动指引
function ActivityManageView:onEnter()

end

--onExit不能删，需要引导活动指引
function ActivityManageView:onExit()

end

function ActivityManageView:clear()
	for k, v in pairs(self.typeActivityMap) do		
		if v.layoutNode then
			v.layoutNode:clear()			
		end
	end
	for k, v in pairs(self.refIdActivityIconMap) do
		v:DeleteMe()
	end
	self.refIdActivityIconMap = {}
end

function ActivityManageView:loadUI()	
	for k, v in ipairs(self.typeActivityMap) do	
		self:updateActivity(v.ttype)
	end
end	

function ActivityManageView:createActivityIcon(obj)
	local activityIcon = self.refIdActivityIconMap[obj:getRefId()]	--先从缓存里面获取
	if not activityIcon then --缓存里不存在则创建
		activityIcon = ActivityIcon.New(createSpriteWithFrameName(RES("activityBox.png")))	
		self.refIdActivityIconMap[obj:getRefId()] = activityIcon
	end
	activityIcon:setData(obj)					
	return activityIcon
end

function ActivityManageView:updateActivityIconText(refId)
	local icon = self.refIdActivityIconMap[refId]
	if icon and icon:getData() then
		local option = icon:getData():getCountDownOption()			
		if option == 1 then		--显示开始倒计时
			icon:setText(icon:getData():getRemainTimeStr(true), "ColorWhite3")
		elseif option == 2 then	--显示结束倒计时
			icon:setText(icon:getData():getRemainTimeStr(false), "ColorRed2")
		else 					--不需要显示倒计时
			icon:setText(" ")
		end
	end
end

function ActivityManageView:onActivityNotify(refId, activityType, event, info)
--	print("ActivityManageView "..refId.." "..event)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()		
	if event == "time" then
		self:updateActivityIconText(refId)
	elseif event == "active" or event == "open" or event == "enable" then	
		local obj = activityManageMgr:getActivityByRefId(refId)
		if obj then				
			self:updateActivity(activityType)
		end
	end
end

function ActivityManageView:findByType(activityType)
	for k, v in pairs(self.typeActivityMap) do
		if v.ttype == activityType then
			return v
		end
	end
	return nil
end

function ActivityManageView:updateActivity(activityType)
	local data = self:findByType(activityType)
	if not data then
		return
	end
	
	data.layoutNode:clear()
	
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	local list = activityManageMgr:getTypeActivityMap()

	local nodeList = {}		
	local hasPushed = false
	for kk, vv in ipairs(list[activityType]) do	
		if ((not hasPushed) and vv:canPush()) then		--可以push并且还没有push过活动，则不处理
			hasPushed = true
		elseif vv:isEnable() then	--不显示enable的活动
			local activityIcon = self:createActivityIcon(vv)				
			table.insert(nodeList, activityIcon)	
			self:updateActivityIconText(vv:getRefId())
		end
	end				

	--显示活动图标
	data.layoutNode:setGrids(nodeList, true)		
	--重新布局
	self:layout()
end

local const_activityTypeSpacinbg = 45
function ActivityManageView:layout()
	local height = 30
	--计算高度
	for k, v in ipairs(self.typeActivityMap) do	
		if not v.layoutNode:isEmpty() then		
			height = height + v.layoutNode:getContentSize().height + const_activityTypeSpacinbg			
		end
	end
	height = height - 20
	if height < self.viewSize.height then
		height = self.viewSize.height
	end
	self.scrollNode:setContentSize(CCSizeMake(self.viewSize.width, height))
	self.scrollNode:retain()
	self.scrollView:setContainer(self.scrollNode)
	self.scrollNode:release()
	self.scrollView:setContentOffset(ccp(0, -self.scrollNode:getContentSize().height + self.viewSize.height), false)
	
	local heightOffset = 20
	for k, v in ipairs(self.typeActivityMap) do	
		if not v.layoutNode:isEmpty() then	--有图标，才显示
			v.layoutNode:setVisible(true)
			v.nameLabel:setVisible(true)
			
			VisibleRect:relativePosition(v.layoutNode:getRootNode(), self.scrollNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(58, -heightOffset))			
			VisibleRect:relativePosition(v.nameLabel, self.scrollNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(30, -heightOffset + 17))	
			if v.line then
				v.line:setVisible(true)
				VisibleRect:relativePosition(v.line, v.nameLabel, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_OUTSIDE, ccp(30, 2))
			end
			heightOffset = heightOffset + v.layoutNode:getContentSize().height + const_activityTypeSpacinbg
		else
			v.layoutNode:setVisible(false)
			v.nameLabel:setVisible(false)
			if v.line then
				v.line:setVisible(false)
			end
		end
	end
end

function ActivityManageView:getBtnByRefId(refId)
	local btn = self.refIdActivityIconMap[refId]
	if btn then
		return btn:getRootNode()
	else
		return nil
	end
end

function ActivityManageView:clickHonorBtn()
	
end