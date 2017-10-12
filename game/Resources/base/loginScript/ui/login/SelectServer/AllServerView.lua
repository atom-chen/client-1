require ("ui.login.SelectServer.ServerItemNode")

AllServerView = AllServerView or BaseClass(LoginBaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local viewSize = CCSizeMake(933, 631)  --界面大小
local cellSize = VisibleRect:getScaleSize(CCSizeMake(177, 64)) --tableview的cell大小
local detailCellSize = VisibleRect:getScaleSize(CCSizeMake(592, 85))
local tableViewBgSize = VisibleRect:getScaleSize(CCSizeMake(185, 440)) --tableview背景的大小

local detailNodeBgSize = VisibleRect:getScaleSize(CCSizeMake(620, 440))
local scrollViewContentSize = VisibleRect:getScaleSize(CCSizeMake(630, 500)) --scrollview的Container大小
local serverItemSize = VisibleRect:getScaleSize(CCSizeMake(285, 84)) --scrollview中的item大小
local cellGaps = 35 --cell之间的间隔

local detailCellGaps = 25
local serverPerArea = 10 --每个区服务器的个数

local itemsPerLine = 2 --每行两列
local marginHor = 9
local marginVer = 19

local CELL_TAG = 100

function AllServerView:__init()
	self.viewName = "AllServerView"	
	self:initVariables()	
	self:createRootNode()	
	self:createUI()		
	self:createCloseBtn()
end

function AllServerView:__delete()
	if self.node1 then
		self.node1:DeleteMe()
		self.node1 = nil
	end
	if self.node2 then
		self.node2:DeleteMe()
		self.node2 = nil
	end
	if self.lastTimeNode then
		self.lastTimeNode:DeleteMe()
		self.lastTimeNode = nil
	end
end

function AllServerView:onEnter()
	--每次进入必须先断开连接
	local loginMgr = LoginWorld.Instance:getLoginManager()
	loginMgr:getConnectionService():slientDisConnect()
	--更新界面
	self:update()
end

function AllServerView:initVariables()
	--tableview数据源的类型
	self.eventType = {}
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3
	
	self.textSize = FSIZE("Size4")
	self.textColor = FCOLOR("ColorWhite2")
	
	self.curPage = 1			 
	self.serverMgr = LoginWorld.Instance:getServerMgr()			
end

function AllServerView:createRootNode()
	local title = createSpriteWithFrameName(RES("login_sever_window_font.png"))
	self:createVipFrame(viewSize, title)
	--self.rootNode:setContentSize(visibleSize)
	local bg = CCScale9Sprite:create("loginUi/login/selectRoleBg.jpg")		
	self.rootNode:addChild(bg, -999)
	VisibleRect:relativePosition(bg, self.rootNode, LAYOUT_CENTER)
	G_setBigScale(bg)
	self:makeMeCenter()
	-- 背景图	
	local nodeSize = viewSize
	self.bgNode = CCNode:create()
	self.bgNode:setContentSize(nodeSize)	
	self.rootNode:addChild(self.bgNode)
	VisibleRect:relativePosition(self.bgNode, self.rootNode, LAYOUT_CENTER)	
	--local bg1 = createScale9SpriteWithFrameNameAndSize(RES("squares_bg1.png"), CCSizeMake(860, viewSize.height-20))
	--self.bgNode:addChild(bg1)
	--VisibleRect:relativePosition(bg1, self.bgNode, LAYOUT_CENTER, ccp(0, -8))		
	--local frameNode = self:createVipFrame(nodeSize)	
	--self.bgNode:addChild(frameNode)
	--VisibleRect:relativePosition(frameNode, self.bgNode, LAYOUT_CENTER)
	--标题	
	

	-- 关闭按钮
	--self:createCloseBtn()
	
	--[[self:initFullScreen()		
	local bg = CCSprite:create("loginUi/login/selectRoleBg.jpg")
	G_setBigScale(bg)
	self:addChild(bg, -999)
	VisibleRect:relativePosition(bg, self:getContentNode(), LAYOUT_CENTER)	
	--标题
	local title = createSpriteWithFrameName(RES("server_selectServer.png"))
	self:setFormTitle(title, TitleAlign.Center)--]]
	-- 关闭按钮
	--self:createCloseBtn()
end

function AllServerView:createCloseBtn()
	local backFunction = function ()
		SFLoginManager:getInstance():logout()
		GlobalEventSystem:Fire(GameEvent.EventShowGetServerListHUD)
		self:close()
	end
	
	self:createVipFrameCloseBtn(ClosebtnType.Back,backFunction)
	--[[
	self.btnBack = createButtonWithFramename(RES("btn_back.png"))
	self.btnBack:setScale(g_scale)	
	self.rootNode:addChild(self.btnBack, 50)
	VisibleRect:relativePosition(self.btnBack, self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE, CCPointMake(-30*g_scale, -15*g_scale))
	local backFunction = function ()	
		GlobalEventSystem:Fire(GameEvent.EventShowGetServerListHUD)
		self:close()
	end
	self.btnBack:addTargetWithActionForControlEvents(backFunction,CCControlEventTouchDown)
	
	--]]
end

function AllServerView:create()
	return AllServerView.New()
end

function AllServerView:createUI()
	self:createServerTable()
	self:createServerDetail()
	self:createLine()
	self:createLastTimeServer()
	
end	

function AllServerView:createServerTable()
	--背景
	self.tableViewBg = createScale9SpriteWithFrameNameAndSize(RES("login_squares_bg2.png"), tableViewBgSize)
	self.bgNode:addChild(self.tableViewBg)
	VisibleRect:relativePosition(self.tableViewBg, self.bgNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(58, -80))
	
	--tableview的数据源
	local function dataHandler(eventType,tableP,index,data)
		local data = tolua.cast(data,"SFTableData")
		local tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(CCSizeMake(cellSize.width, cellSize.height+cellGaps/2)))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createCellItem(index)
				cell:addChild(item)
				cell:setIndex(index+1)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				tableCell:setIndex(index+1)
				local item = self:createCellItem(index)
				tableCell:addChild(item)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			local cnt = math.modf((self:getServerCount()-1)/serverPerArea)+1 
			data:setIndex(cnt+1)  --加1是为了显示推荐服务器
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)
		cell = tolua.cast(cell,"SFTableViewCell")		
		
		self.curPage = cell:getIndex()
		self.serverTable:reloadData()
		self:updateServerList()
	end
	
	--创建tableview
	self.serverTable = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(cellSize.width, tableViewBgSize.height-5)))
	self.serverTable:setTableViewHandler(tableDelegate)
	self.serverTable:reloadData()
	self.serverTable:scroll2Cell(0, false)  --回滚到第一个cell
	self.bgNode:addChild(self.serverTable)
	VisibleRect:relativePosition(self.serverTable, self.tableViewBg, LAYOUT_CENTER)
		
end

function AllServerView:createCellItem(index)
	local item = CCNode:create()
	item:setContentSize(cellSize)
	--cell背景
	local cellBg = createScale9SpriteWithFrameNameAndSize(RES("login_squares_serverFrame.png"), cellSize)
	item:addChild(cellBg)
	VisibleRect:relativePosition(cellBg, item, LAYOUT_CENTER)
	
	local serverInfo = "" 
	if index == 0 then  --推荐登陆列表
		serverInfo = Config.LoginWords[8504]
	else
		local firstStr = nil 
		local lastStr = nil	
		local count = math.modf((self:getServerCount()-1)/serverPerArea)+1 	
		if index == 1 then 			
			firstStr = string.format("%d", (count-1)*serverPerArea+1)
			lastStr =  string.format("%d", self:getServerCount())
		else		
			firstStr = string.format("%d", (count-index+1-1)*serverPerArea+1)
			lastStr =  string.format("%d", (count-index+1)*serverPerArea)
		end
		serverInfo = firstStr .. "-" .. lastStr.. Config.LoginWords[8500]
	end
	
	--选中框
	if self.curPage == (index+1) then		
		local selectFrame = createScale9SpriteWithFrameNameAndSize(RES("login_squares_serverSelectedFrame.png"), cellSize)
		item:addChild(selectFrame)
		VisibleRect:relativePosition(selectFrame, item, LAYOUT_CENTER)
	end
		
	local strLabel = createLabelWithStringFontSizeColorAndDimension(serverInfo, "Arial", FSIZE("Size5"), FCOLOR("ColorWhite1"))	
	item:addChild(strLabel)
	VisibleRect:relativePosition(strLabel, item, LAYOUT_CENTER)
	
	return item
end

function AllServerView:createDetailCellItem(index)
	local totalPage = math.modf((self:getServerCount()-1)/serverPerArea)+1
	local serverCount = self:getServerCount()	
	
	local item = CCNode:create()
	item:setContentSize(detailCellSize)	
	
	
	local pageCount = serverPerArea
	local serverIndex = -1
	if self.curPage == 1 then   --推荐服务器从推荐列表拿	
		local recommendList = self.serverMgr:getRecommendServerList()
		pageCount = table.size(recommendList)	
		if recommendList[index*2+1] and recommendList[index*2+1].getShowOrders then
			serverIndex = recommendList[index*2+1]:getShowOrders()
		end
	elseif self.curPage == 2 then 
		pageCount = serverCount-(totalPage-1)*serverPerArea	
		serverIndex = pageCount - index*2+(totalPage-self.curPage+1)*serverPerArea
	else
		pageCount = serverPerArea
		serverIndex = pageCount - index*2+(totalPage-self.curPage+1)*serverPerArea
	end
		
	local t, tt = math.modf(pageCount/2)
	local bSingle = false	
	if index== t and (self.curPage==2 or self.curPage==1)then
		if tt ~= 0 then    --单数		
			bSingle = true					
		end			
	end				
	
	local server = self.serverMgr:getServerByShowOrder(serverIndex)
	if server==nil then 
		return item
	end
	
	self.node1 = ServerItemNode.New()
	self.node1:setServerInfo(server)	
	self.node1:getRootNode():setTag(1)
	item:addChild(self.node1:getRootNode())
	VisibleRect:relativePosition(self.node1:getRootNode(), item, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE)
	if bSingle == false	then
		if self.curPage ~= 1 then 
			server = self.serverMgr:getServerByShowOrder(serverIndex-1)
		else
			local recommendList = self.serverMgr:getRecommendServerList()
			serverIndex = recommendList[index*2+2]:getShowOrders()
			server = self.serverMgr:getServerByShowOrder(serverIndex)
		end
		self.node2 = ServerItemNode.New()
		self.node2:setServerInfo(server)		
		item:addChild(self.node2:getRootNode())
		self.node2:getRootNode():setTag(2)
		VisibleRect:relativePosition(self.node2:getRootNode(), item, LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE)
	end
	item:setTag(CELL_TAG)
	return item
end

function AllServerView:createServerDetail()
	--背景
	local serverDetailBg = createScale9SpriteWithFrameNameAndSize(RES("login_squares_bg2.png"), detailNodeBgSize)
	self.bgNode:addChild(serverDetailBg)
	VisibleRect:relativePosition(serverDetailBg, self.tableViewBg, LAYOUT_RIGHT_OUTSIDE+LAYOUT_TOP_INSIDE, ccp(8, 0))
	
	--tableview的数据源
	local function serverDetailHandler(eventType,tableP,index,data)
		local data = tolua.cast(data,"SFTableData")
		local tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(CCSizeMake(detailCellSize.width, tableViewBgSize.height/5))
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(CCSizeMake(detailCellSize.width, tableViewBgSize.height/5)))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(CCSizeMake(detailCellSize.width, tableViewBgSize.height/5))
				local item = self:createDetailCellItem(index)
				cell:addChild(item)
				cell:setIndex(index+1)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(CCSizeMake(detailCellSize.width, tableViewBgSize.height/5))
				tableCell:setIndex(index+1)
				local item = self:createDetailCellItem(index)
				tableCell:addChild(item)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			local itemCount = self:calculateItemCnt()			
			data:setIndex(itemCount)
			return 1
		end
	end
	
	--点击事件
	local tableDelegate = function (tableP,cell,x,y)	
		cell = tolua.cast(cell,"SFTableViewCell")
		local item = cell:getChildByTag(CELL_TAG)	
		if item == nil then 
			return
		end
		local cellIndex = cell:getIndex()	
		local count = item:getChildren():count()
		local touchPoint = ccp(x,y)		
		for i = 1, count do 		
			local rect = item:getChildByTag(i):boundingBox()
			if rect:containsPoint(touchPoint) then		
				local totalPage = math.modf((self:getServerCount()-1)/serverPerArea)+1
				local serverCount = self:getServerCount()	
				local pageCount = serverPerArea
				local realIndex = -1
				if self.curPage == 1 then   --推荐服务器
					local recommendList = self.serverMgr:getRecommendServerList()
					if recommendList[(cellIndex-1)*2+i] and recommendList[(cellIndex-1)*2+i].getShowOrders then
						realIndex = recommendList[(cellIndex-1)*2+i]:getShowOrders()	
					end				
				elseif self.curPage == 2 then 
					pageCount = serverCount-(totalPage-1)*serverPerArea
					realIndex = pageCount-((cellIndex-1)*2+i-1)+(totalPage-self.curPage+1)*serverPerArea										
				else
					pageCount = serverPerArea
					realIndex = pageCount-((cellIndex-1)*2+i-1)+(totalPage-self.curPage+1)*serverPerArea
				end
																				
				local server = self.serverMgr:getServerByShowOrder(realIndex)																				
				self.serverMgr:handleServerLogin(server)
				break
			end
		end
	end
	
	--创建tableview
	self.serverDetailTable = createTableView(serverDetailHandler, VisibleRect:getScaleSize(CCSizeMake(detailCellSize.width, tableViewBgSize.height)))
	self.serverDetailTable:setTableViewHandler(tableDelegate)
	self.serverDetailTable:reloadData()
	self.serverDetailTable:scroll2Cell(0, false)  --回滚到第一个cell
	self.bgNode:addChild(self.serverDetailTable)
	VisibleRect:relativePosition(self.serverDetailTable, serverDetailBg, LAYOUT_CENTER)
	
end

function AllServerView:calculateItemCnt()
	local itemCount = 5
	local serverCount = self:getServerCount()
	local totalPage = math.modf((serverCount-1)/serverPerArea)+1
	if self.curPage == 1 then 
		--todo
		local recommendCnt = table.size(self.serverMgr:getRecommendServerList())		
		itemCount = math.modf((recommendCnt-1)/2)+1
	elseif self.curPage==2 then
		itemCount = serverCount - (totalPage-1)*serverPerArea
		itemCount = math.modf((itemCount-1)/2)+1
	else
		itemCount = 5
	end	
	return itemCount
end

function AllServerView:updateServerList()
	self.serverDetailTable:reloadData()
end

--服务器的数量
function AllServerView:getServerCount()
	return table.size(self.serverMgr:getServerList())
end


--界面下方的上次登陆
function AllServerView:createLastTimeServer()
	local lastTimeSprite = createSpriteWithFrameName(RES("server_lastTimeLogin.png"))
	
	local itemSize = CCSizeMake(263, 70)
	local nodeSize = CCSizeMake(itemSize.width+lastTimeSprite:getContentSize().width+10, itemSize.height)
	local serverNode = CCNode:create()
	serverNode:setContentSize(nodeSize)
	self:addChild(serverNode)
	VisibleRect:relativePosition(serverNode, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)
	local lastTimeBtn = createButtonWithFramename(RES("login_squares_serverFrame.png"), nil, itemSize)
	serverNode:addChild(lastTimeBtn)
	VisibleRect:relativePosition(lastTimeBtn, serverNode, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(0, 20))
		
	local lastTimeServer = self.serverMgr:getLastTimeLgoinServer()
	self.lastTimeNode = ServerItemNode.New(itemSize)
	self.lastTimeNode:setServerInfo(lastTimeServer)
	if self.lastTimeNode then 
		lastTimeBtn:addChild(self.lastTimeNode:getRootNode())
		VisibleRect:relativePosition(self.lastTimeNode:getRootNode(), lastTimeBtn, LAYOUT_CENTER)
	end
	
	local lastTimeCallBack = function ()			
		local server = self.serverMgr:getLastTimeLgoinServer()	
		local serverMgr = LoginWorld.Instance:getServerMgr()
		serverMgr:handleServerLogin(server)
	end
	lastTimeBtn:addTargetWithActionForControlEvents(lastTimeCallBack, CCControlEventTouchDown)
	
	--上次登陆文字	
	serverNode:addChild(lastTimeSprite)
	VisibleRect:relativePosition(lastTimeSprite, lastTimeBtn, LAYOUT_LEFT_OUTSIDE+LAYOUT_CENTER_Y, ccp(-10, 0))		
end

function AllServerView:createLine()
	self.line = createSpriteWithFrameName(RES("login_server_line.png"))
	self:addChild(self.line)
	VisibleRect:relativePosition(self.line, self:getContentNode(), LAYOUT_CENTER_X)
	VisibleRect:relativePosition(self.line, self.tableViewBg, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -4))
end				

function AllServerView:updateLastTimeServer()
	local lastTimeServer = self.serverMgr:getLastTimeLgoinServer()
	self.lastTimeNode:update(lastTimeServer)
end

function AllServerView:update()
	self:updateLastTimeServer()
	self.serverTable:reloadData()
end
