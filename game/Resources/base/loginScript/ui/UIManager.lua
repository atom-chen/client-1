require("common.baseclass")
require("LoginGameDef")
require("ui.utils.LoadingHUD")
require("ui.utils.EditBoxDialog")
require("ui.utils.MessageBoxWithEdit")
require("ui.utils.PopupMenu")
require("ui.utils.SystemTips")
require("ui.utils.LoadingSence")
require("ui.utils.SystemTipsWithItem")
require("ui.utils.PromptBox.ComparePromptBox")
require("ui.utils.PromptBox.DescribePromptBox")
require("ui.utils.PromptBox.WeaponComparePromptBox")

--dialog层z值定义
E_DialogZOrder = 
{
	ReviveDlg = 0,
	HeroActiveState = 10, --自动寻路/自动打怪
	ReConnectDlg = 20,	
	Tips = 30,
}

--GameRoot层Z值定义
E_GameRootNodeOder = 
{
	PluckRootNode = 10
}

--各个View的配置文件
--deleteOnExit: 隐藏时是否删除，不定义则为true
--preload: 		预加载：是否在注册时创建，不定义则为false
local ViewConfig =
{
--[[
	RoleView = 					{deleteOnExit = false, preload = false},
	NormalItemDetailView = 		{deleteOnExit = false, preload = false},
	EquipItemDetailView = 		{deleteOnExit = false, preload = false},
	PutOnEquipItemDetailView = 	{deleteOnExit = false, preload = false},
	SkillView = {deleteOnExit = false, preload = false},	
	SmallMapView = {deleteOnExit = false, preload = false},
	InstanceView    =  {deleteOnExit = false, preload = false},
	--]]
}

local E_PromptBoxType = {
	describe = 1,
	compare = 2,
}
local E_PromptBoxName = {
	[1] = DescribePromptBox.create,
	[2] = ComparePromptBox.create,
	[3] = WeaponComparePromptBox.create
}
local const_animationDuration = 0.25

UIManager = UIManager or BaseClass()

function UIManager:__init()
	UIManager.Instance = self
end

--[[
m_pGameRootNode: 	用于加载游戏的主界面(不包括地图)
m_pUIRootNode:		各种逻辑功能的UI
m_pDialogRootNode:	MessageBox, Tips等弹出框
]]
function UIManager:initAll()
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	
	self.m_pGameRootNode = CCNode:create()	
	self.m_pGameRootNode:setContentSize(visibleSize)
	self.m_pGameRootNode:retain()
	
	self.m_pUIRootNode = CCLayer:create()
	self.m_pUIRootNode:setContentSize(visibleSize)
	self.m_pUIRootNode:retain()
	self.m_pUIRootNode:setTouchEnabled(true)
	self:registerUIRootNodeScriptTouchHandler()
	
	self.m_pDialogRootNode = CCLayer:create()
	self.m_pDialogRootNode:setContentSize(visibleSize)
	self.m_pDialogRootNode:retain()
	
	--已经创建的UI的实例
	self.uiList = {}
	
	--保存UI的key和创建函数的映射
	self.uiCreateList = {}
	self.message=nil
	self.loadingHUD = nil
	self.popupMenu = nil
	
	--保存正在显示的UI。其中level为显示的层次，为0-n, 越大表示越前  
	self.uiInShow = 
	{	
		--name = {obj = viewNode, pos = E_ViewPos.eMiddle, level = -1}
	}
	
	--保存gameMainView：主界面
	self.gameMainView = nil
		
	self.maxUILevel = 0
end

--UIRootNode阻挡所有Touch
function UIManager:registerUIRootNodeScriptTouchHandler()
	local function ccTouchHandler(eventType, x, y)		
		if not table.isEmpty(self.uiInShow) then
			return 1;	
		else
			return 0
		end
	end
	self.m_pUIRootNode:registerScriptTouchHandler(ccTouchHandler, false, 0, true)
end

function UIManager:isDeleteOnExit(name)
	local config = ViewConfig[name]
	if (config == nil) then
		return false
	end
	if (config.deleteOnExit == true) then
		return true
	end
	return false
end

function UIManager:setDeleteOnExit(name, bDelete)
	if not ViewConfig[name] then
		ViewConfig[name] = {}
	end
	ViewConfig[name].deleteOnExit = bDelete
end

function UIManager:isPreload(name)
	local config = ViewConfig[name]
	if (config == nil) then
		return false
	end
	if (config.preload == true) then
		return true
	end
	return false
end

--[[
注册UI的创建函数
uiKey(string): 			窗口的名字, showUI用来查找的参数
createFun(function): 	创建UI的function
]]
function UIManager:registerUI(uiKey, createFun)
	local func = self.uiCreateList[uiKey]
	if func == nil then
		self.uiCreateList[uiKey] = createFun
	end				
	
	if (self:isPreload(uiKey))	 then	--是否预加载
		self:createUI(uiKey)
	end
end

--[[
手动释放UI
]]
function UIManager:releaseUI(name)
	if type(name) ~= "string" then		
		return
	end
	
	local view = self.uiList[name]		
	if view == nil then		
		return
	end
	
	if self:isShowing(name) then
		self.uiInShow[name] = nil							
		if (view.onExit) then 						--回调UI的onExit函数
			view.onExit(view)						
		end	
		view:getRootNode():removeFromParentAndCleanup(false)
	end
	
	--Juchao@20131226: 为什么需要再次判断？因为在上面调用onExit函数里面可能会出现hideUI()或者showUI()，这可能会导致该UI被提前删除			
	if self.uiList[name] then	
		view:DeleteMe()
		self.uiList[name] = nil					--从uiInShow里面移除掉		
	end		
end

function UIManager:releaseAllUI()
	for kk, vv in pairs(self.uiList) do
		if kk ~= "SettingView"  then
			self:releaseUI(kk)
		end		
--		print("release "..kk)
	end
end

function UIManager:createUI(uiKey)
	local func = self.uiCreateList[uiKey]
	if func ~= nil then
		local view = func()
		self.uiList[uiKey] = view
		return view
	else
		return nil
	end
end

function UIManager:getGameRootNode()
	return self.m_pGameRootNode
end

function UIManager:getUIRootNode()
	return self.m_pUIRootNode
end

function UIManager:getDialogRootNode()
	return self.m_pDialogRootNode
end

function UIManager:showWnd(pWnd)
	if pWnd and pWnd:getParent() then
		self.m_pUIRootNode:addChild(pWnd)
	end
end

function UIManager:hideWnd(pWnd)
	if pWnd and pWnd:getParent() then
		self.m_pUIRootNode:removeChild(pWnd,true)
	end
end

function UIManager:showGameRootNode(pNode, create)
	if type(pNode) == "string" then	
		if  self.gameMainView then
			self.gameMainView:DeleteMe()
			self.gameMainView = nil
		end
		self.m_pGameRootNode:removeAllChildrenWithCleanup(true)
			
		self.gameMainView = create()
		self.m_pGameRootNode:removeAllChildrenWithCleanup(true)
		self.m_pGameRootNode:addChild(self.gameMainView:getRootNode())
	end
end

function UIManager:getMainView()
	return self.gameMainView
end	

function UIManager:showSystemTips(msg, tipsType, fontsize, duration, viewsize)
	if type(msg) ~= "table" then
		local text = msg
		msg = {}
		table.insert(msg,{word = text, color = Config.FontColor["ColorYellow1"]})
	end
	
	if  tipsType == nil then
		tipsType = E_TipsType.common--.emphasize
	end
	if msg == nil then
		msg = {}
	end
	if fontsize == nil then
		fontsize = FSIZE("Size5")
	end
	if duration == nil then
		duration = 2
	end	
	if viewsize == nil then
		viewsize = CCSizeMake(0, 0)
	end
	
	local data = {}
	data.type = tipsType	
	data.msg = msg
	data.fontsize = fontsize
	data.duration = duration
	data.viewsize = viewsize

	if table.getn(msg) > 0 then
		if self.tips == nil then
			self.tips = SystemTips.New(tipsType)	
		end
		
		LoginWorld.Instance:getTipsManager():insertTips(data)						
		UIManager.Instance:showDialog(self.tips:getRootNode(), 2)
	end
end

function UIManager:ShowTipsWithItem(refId,count)
	local tips = SystemTipsWithItem.New(refId,count)					
	UIManager.Instance:showDialog(tips:getRootNode(), 2)
	GlobalEventSystem:Fire(GameEvent.EventPickLootItem)
end

function UIManager:clearSystemTips()
	if self.tips then	
		self.tips:getRootNode():removeAllChildrenWithCleanup(true)
		self.tips:DeleteMe()
		self.tips = nil		
	end		
end
--[[
arg		 :	自定义的参数，如可以设成self，会传递给回调函数
titleText:	标题文字
num		 :	初始数量
notify	 : 	回调函数。回调函数的参数说明：
	arg:		自定义的参数
	eventType： 1为数字变化事件，2为确定事件，3为取消事件
	num 	 ：	当前数字
titleText： 标题文字
minNum	: 	允许的最小数字
maxNum	:	允许的最大数字
--]]
function UIManager:showEditBox(arg, notify, num , titleText, minNum, maxNum)
	if (type(num) ~= "number") then
		error("Fatal error! UIManager:showEditBox type(num) ~= number or notify == nil or arg == nil")
		return
	end
	local dialog
	if (self.uiList["EditBoxDialog"]) then
		dialog = self:getViewByName("EditBoxDialog")
	else
		dialog = self:createUI("EditBoxDialog")
	end
	
	dialog:setNum(num)
	dialog:setTitleText(titleText)
	dialog:setNotify(arg, notify)
	dialog:setRange(minNum, maxNum)
	self:showUI("EditBoxDialog", E_ShowOption.eMiddle)
end

function UIManager:showMsgBoxWithEdit(titleText, arg, notify, btns, editword, editWordSize)
	local msgBoxWithEdit
	if (self.uiList["MessageBoxWithEdit"]) then
		msgBoxWithEdit = self:getViewByName("MessageBoxWithEdit")
	else
		msgBoxWithEdit = self:createUI("MessageBoxWithEdit")
	end
		
	msgBoxWithEdit:initView(titleText or "")		
	if editword then
		msgBoxWithEdit:setEditWord(editword,editWordSize)
	else
		msgBoxWithEdit:reset()
	end
	msgBoxWithEdit:setBtns(btns)
	msgBoxWithEdit:setNotify(arg, notify)	
	msgBoxWithEdit:layout()	
	self:showUI("MessageBoxWithEdit", E_ShowOption.eMiddle)
end

--[[
size 大小
items 格式：{{lable, id, callback, arg, disable},}
--lable 要显示的文字
--id  lable的id
--callback 点击lable后的回调
--arg   传给回调的参数
--disable 是否不可使用，即灰色
--e.g. {{lable = "test", id = 1, callback = fun, arg = "参数", disable = false},}
parent 所要添加到的Node
point 距离父节点左上角的距离点，即确定显示的位置
--]]
function UIManager:showPopupMenu(size, items, parent, point)
	if self.popupMenu ~= nil then
		self.popupMenu:DeleteMe()
		self.popupMenu = nil
	end
	self.popupMenu = PopupMenu.New()
	self.popupMenu:initWithSize(size)
	self.popupMenu:setItems(items)
	if parent and parent.addChild then
		parent:addChild(self.popupMenu:getRootNode())
		VisibleRect:relativePosition(self.popupMenu:getRootNode(), parent, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, point)
	else
		UIManager.Instance:showDialog(self.popupMenu:getRootNode(),1)
	end
end

function UIManager:hidePopupMenu()
	if self.popupMenu ~= nil then
		self.popupMenu:removePopupMenu()
		self.popupMenu:DeleteMe()
		self.popupMenu = nil
	end
end

--[[
@场景加载
delay延迟多少秒后消失
--]]
function UIManager:showLoadingSence(delay)
	if self.loadingScene ~=nil then
		self.loadingScene:DeleteMe()
		self.loadingScene = nil
	end
	self.loadingScene = LoadingSence.New()
	self.loadingScene:setDelay(delay)
	UIManager.Instance:showDialog(self.loadingScene:getRootNode(),1)
	self.loadingScene:show()
end

function UIManager:hideLoadingSence()
	if self.loadingScene ~= nil and self.loadingScene:getRootNode() then
		self.loadingScene:reBackTimeFun()
		self.loadingScene:DeleteMe()
	end
	self.loadingScene = nil
end

--[[
delay 延迟多少秒后消失
parent 所要添加到的Node
touchArea 点击区域
func 延迟后运行的function
--]]
function UIManager:doShowLoadingHUD(delay,parent,func,touchArea)
	self.loadingHUD = LoadingHUD.New()
	self.loadingHUD:setDelay(delay)
	if func then
		self.loadingHUD:setHideFunction(func)
	end
	if parent and parent.addChild then
		parent:addChild(self.loadingHUD:getRootNode())
		VisibleRect:relativePosition(self.loadingHUD:getRootNode(),parent,LAYOUT_CENTER)
		if touchArea then
			self.loadingHUD:setTouchArea(touchArea)
		end
		
	else
		UIManager.Instance:showDialog(self.loadingHUD:getRootNode(),1)
	end
	self.loadingHUD:show()	
	return self.loadingHUD
end

local const_delayShowLoadingInterval = 0.3
function UIManager:showLoadingHUD(delay,parent,func,touchArea)
	self:hideLoadingHUD()
	self:doShowLoadingHUD(delay,parent,func,touchArea) --Juchao@20140626: 直接show出loading，避免使用sch延迟show可能导致的引用计数问题	
end

function UIManager:hideLoadingHUD()
	if self.loadingHUD ~= nil then
		self.loadingHUD:DeleteMe()
		self.loadingHUD = nil
	end		
end

function UIManager:showDialog(pDialog, order)
	if pDialog and pDialog:getParent() == nil then
		self.m_pDialogRootNode:addChild(pDialog,order)
		VisibleRect:relativePosition(pDialog, self.m_pDialogRootNode, LAYOUT_CENTER)
	end
end

function UIManager:hideDialog(pDialog)
	if pDialog and pDialog:getParent()then
		pDialog:removeFromParentAndCleanup(true)
		self.message=nil
	end
end

function UIManager:hideLoadingTips()
	if self.tipsLabel then
		self.tipsLabel:removeFromParentAndCleanup(true)
		self.tipsLabel = nil
	end
	self:hideLoadingHUD()
end
--[[
text：Tips的文字
duration ；delayTime
--]]
function UIManager:showLoadingTips(text, duration)
	self:hideLoadingTips()
	self.tipsLabel = createLabelWithStringFontSizeColorAndDimension(text, "Arial", 30, FCOLOR("ColorWhite1"))	
	self.m_pDialogRootNode:addChild(self.tipsLabel)
	VisibleRect:relativePosition(self.tipsLabel, self.m_pDialogRootNode, LAYOUT_CENTER)		
	local LoadingHUD = self:showLoadingHUD(duration)
	VisibleRect:relativePosition(LoadingHUD:getRootNode(), self.m_pDialogRootNode, LAYOUT_CENTER, ccp(0, -100))			
end

--[[
node: UI的名字
option:
E_ShowOption =
{
eRejectOther = 1, 	--显示在中间，隐藏其他窗口
eMove2Left	 = 3,  	--从中间移动到左侧，不影响其他窗口
eMove2Right	 = 4,  	--从中间移动到右侧，不影响其他窗口
eMiddle	 = 5,		--显示在中间，不影响其他窗口
eLeft	 = 6,  		--显示在左边，不影响其他窗口
eRight	 = 7,  		--显示在右边，不影响其他窗口
}
}
arg: 自定义参数，可传递给onEnter()函数
--]]
function UIManager:showUI(name, option, arg)
	if (option == nil) then
		option = E_ShowOption.eRejectOther
	end
	
	if type(name) == "string" then
		local view = self.uiList[name]
		
		if (self.uiInShow[name]) then	--如果正在显示，则只给该UI传递参数
			if (view.onEnter) then 		--回调onEnter函数
				view.onEnter(view, arg)
			end
			return
		end
		
		if (option == E_ShowOption.eRejectOther) then	--隐藏所有UI
			self:hideAllUI()
		end
		
		if view == nil then			--不存在创建
			view = self:createUI(name)
		end
		if (view == nil) then		--创建失败，退出
			print("UIManager:showUI create UI"..name.." failed. return")
			return
		end
		
		self:handleShowOption(option, name, view)	
		self.m_pUIRootNode:addChild(view:getRootNode())
		self:updateViewLevel(false)
		
		--Juchao@20140314: 调用onEnter函数需要在updateViewLevel()之后。
		--因为onEnter中可能会show新的UI，这样会导致新的UI的level比该UI的低
		if (view.onEnter) then		
			view.onEnter(view, arg)
			if GameEvent.EventOnEnterView then
				GlobalEventSystem:Fire(GameEvent.EventOnEnterView,name)
			end
		end
	end
end	

--增加一个view到UIManager的管理当中。会记录该view的层次
function UIManager:addShowingView(name, view, pos, animation)	
	self.uiInShow[name] = {obj = view, pos = pos, level = self.maxUILevel}
	self.maxUILevel = self.maxUILevel + 1
	self:moveView(view:getRootNode(), pos, animation)		
end	

function UIManager:handleShowOption(option, name, view)		
	if (option == E_ShowOption.eRejectOther or option == E_ShowOption.eMiddle) then	
		self:addShowingView(name, view, E_ViewPos.eMiddle, false)
	elseif (option == E_ShowOption.eMove2Left) then
		self:addShowingView(name, view, E_ViewPos.eLeft, true)
	elseif (option == E_ShowOption.eMove2Right) then
		self:addShowingView(name, view, E_ViewPos.eRight, true)
	elseif (option == E_ShowOption.eLeft) then
		self:addShowingView(name, view, E_ViewPos.eLeft, false)
	elseif (option == E_ShowOption.eRight) then
		self:addShowingView(name, view, E_ViewPos.eRight, false)	
	else
		self:addShowingView(name, view, E_ViewPos.eMiddle, false)
	end		
end

function UIManager:moveView(viewNode, pos, animation)
	if (pos == E_ViewPos.eLeft) then	
		self:move2Left(viewNode, animation)
	elseif (pos == E_ViewPos.eRight) then
		self:move2Right(viewNode, animation)
	else--[[if (pos == E_ViewPos.eMiddle) then--]]
		self:move2Middle(viewNode, animation)
	end
end

function UIManager:move2Left(viewNode, animation)
	if (animation == nil) then
		animation =  true
	end
	if animation ==  true then
		VisibleRect:relativePosition(viewNode, self.m_pUIRootNode, LAYOUT_CENTER)
		self:moveBy(viewNode, ccp(-viewNode:getContentSize().width/2, 0))
	else
		VisibleRect:relativePosition(viewNode, self.m_pUIRootNode, LAYOUT_CENTER, ccp(-viewNode:getContentSize().width/2, 0))
	end
end

function UIManager:move2Middle(viewNode, animation)
	if (animation == nil) then
		animation =  true
	end
	if animation ==  true then
		local visibleSize = CCDirector:sharedDirector():getVisibleSize()
		local posX = (visibleSize.width - viewNode:getContentSize().width)/2
		local posY = (visibleSize.height - viewNode:getContentSize().height)/2
		self:moveTo(viewNode, ccp(posX, posY))
	else
		VisibleRect:relativePosition(viewNode, self.m_pUIRootNode, LAYOUT_CENTER)
	end
end

function UIManager:move2Right(viewNode, animation)
	if (animation == nil) then
		animation =  true
	end		
	if animation ==  true then
		VisibleRect:relativePosition(viewNode, self.m_pUIRootNode, LAYOUT_CENTER)
		self:moveBy(viewNode, ccp(viewNode:getContentSize().width/2, 0))
	else
		VisibleRect:relativePosition(viewNode, self.m_pUIRootNode, LAYOUT_CENTER, ccp(viewNode:getContentSize().width/2, 0))
	end
end

function UIManager:moveBy(viewNode, point)
	local move = CCMoveBy:create(const_animationDuration, point)
	self:runMoveWithDelay(viewNode, move)
end

function UIManager:moveTo(viewNode, point)
	local move = CCMoveTo:create(const_animationDuration, point)
	self:runMoveWithDelay(viewNode, move)	
end

function UIManager:runMoveWithDelay(viewNode, move)
	local delay = CCDelayTime:create(0.03) 	--delay一定时间再运行动画，避免卡顿
	local sequence = CCSequence:createWithTwoActions(delay, move)
	viewNode:runAction(sequence)		
end

--隐藏UI
--name: 
function UIManager:hideUI(name)
	self:doHideUI(name)
	self:updateViewLevel(true)
end

function UIManager:doHideUI(name)
	if type(name) ~= "string" then		
		return
	end
	
	local view = self.uiList[name]		
	if view == nil then		
		return
	end
	
	local node = view:getRootNode() --先将node保存起来，防止view内部将node置为nil，getRootNode()为nil值
	if self:isShowing(name) and node then	
		node:retain()	
		self.uiInShow[name] = nil							
		if (view.onExit) then 						--回调UI的onExit函数
			view.onExit(view)	
			if GameEvent.EventOnExitView then
				GlobalEventSystem:Fire(GameEvent.EventOnExitView,name)	
			end						
		end	
		node:removeFromParentAndCleanup(false)
		node:release()
	end
	
	--Juchao@20131226: 为什么需要再次判断？因为在上面调用onExit函数里面可能会出现hideUI()或者showUI()，这可能会导致该UI被提前删除			
	if self.uiList[name] then
		if (self:isDeleteOnExit(name)) then			--是否删除
			view:DeleteMe()
			self.uiList[name] = nil					--从uiInShow里面移除掉
		end
	end			
end

--将最顶层的view的zorder设为0，其他的设为-1。
--这样其他UI就在m_pUIRootNode的底下，m_pUIRootNode可以挡住这些view的触摸事件。
--autoMove: 是否在只有一个显示view时将view移到中间
function UIManager:updateViewLevel(autoMove)
	local views = {}	
	local size = 0
		
	for k, v in pairs(self.uiInShow) do		--根据view的level来排序，存放到views里
		if size == 0 then
			table.insert(views, v)
		else
			local inserted = false
			for kk, vv in ipairs(views) do
				if v.level > vv.level then
					table.insert(views, kk, v)
					inserted = true
					break
				end
			end
			if not inserted then
				table.insert(views, v)
			end
		end
		size = size + 1
	end		
	
	local viewPosMark = {[E_ViewPos.eMiddle] = true, [E_ViewPos.eLeft] = true, [E_ViewPos.eRight] = true}
	local isTopLevelView = function(pos)	--判断是否最顶层的view
		if (viewPosMark[E_ViewPos.eMiddle] == nil) or (table.size(viewPosMark) == 1) then
			return false
		else
			viewPosMark[pos] = nil
			return true
		end
	end
	
	local zOffset = 0
	for k, v in ipairs(views) do	
		if isTopLevelView(v.pos) then
			v.obj:getRootNode():setZOrder(v.level)			
		else
			v.obj:getRootNode():setZOrder(-1 - zOffset)
			zOffset = zOffset + 1
		end
	end
end

function UIManager:hideAllUI()
	local tmp = {}	
	for k, v in pairs(self.uiInShow) do	--先将所有的View放到这里面来，因为hideUI会从self.uiInShow删除某项，导致直接对self.uiInShow遍历出错
		table.insert(tmp, k)
	end
	for kk, vv in pairs(tmp) do
		self:doHideUI(vv)
	end
end

function UIManager:getUIByTag(tag)
	return self.m_pUIRootNode:getChildByTag(tag)
end

function UIManager:getDialogUIByTag(tag)
	return self.m_pDialogRootNode:getChildByTag(tag)
end

function UIManager:clear(state)
	self:hideAllUI()
	self:hideAllDialog()
	self.m_pGameRootNode:removeAllChildrenWithCleanup(true)	
	if self.gameMainView then
		self.gameMainView:DeleteMe()
		self.gameMainView = nil		
	end
	if state then
		self.m_pUIRootNode:removeFromParentAndCleanup(true)
		self.m_pGameRootNode:removeFromParentAndCleanup(true)
		self.m_pDialogRootNode:removeFromParentAndCleanup(true)
	end
end

function UIManager:hideAllDialog()
	self.m_pDialogRootNode:removeAllChildrenWithCleanup(true)
	self:clearSystemTips()
	self:hideLoadingHUD()
end

function UIManager:getViewByName(name)
	return self.uiList[name]
end

function UIManager:getShowingViews()
	return self.uiInShow
end

function UIManager:isShowing(name)
	if (table.size(self.uiInShow) > 0) then
		if (self.uiInShow[name]) then
			return true
		else	
			return false
		end
	end
	return false
end

-- 移动view self.uiInShow[node] = {obj = view, pos = E_ViewPos.eRight}
function UIManager:moveViewByName(name, pos, animation)
	local ui = self.uiInShow[name]
	if (ui and (ui.pos ~= pos)) then
		ui.pos = pos
		self:moveView(ui.obj:getRootNode(), pos, animation)
		self:updateViewLevel()
	end
end

function UIManager:getViewPositon(name)
	local ui = self.uiInShow[name]
	if (ui) then
		return ui.pos
	end
end

--测试使用
function UIManager:showTextList(textList)
	local ui = LoginBaseUI.New()
	local size = ui:initFullScreen()
	
	local nodes = {}
	for k, v in pairs(textList) do
		local label = createLabelWithStringFontSizeColorAndDimension(v, "Arial", FSIZE("Size4"), FCOLOR("ColorYellow5"))								
		table.insert(nodes, label)
		print(v)
	end
	
	local viewSize = CCSizeMake(size.width - 20, size.height - 100)
	scrollNode = CCNode:create()
	G_layoutContainerNode(scrollNode, nodes, 5, E_DirectionMode.Vertical, viewSize, true)		
	
	local scrollView = createScrollViewWithSize(viewSize)
	scrollView:setDirection(2)
	scrollView:setContainer(scrollNode)
	
	ui:getRootNode():addChild(scrollView)
	VisibleRect:relativePosition(scrollView, ui:getRootNode(), LAYOUT_CENTER)
	self:showDialog(ui:getRootNode(), 10)
end

--[[local E_PromptBoxType = {
	describe = 1,
	compare = 2,
}--]]
function UIManager:showPromptBox(viewName, boxType,bShowBtn)
	if type(boxType) ~= "number" then
		error("Fatal error! UIManager:showPromptBox type(boxType) ~= number")
	end
	local createFunc = E_PromptBoxName[boxType]
		if not createFunc then
		error("Fatal error! UIManager:showPromptBox boxType Illegal ")
	end
	
	self:registerUI(viewName, createFunc)
	self:showUI(viewName,E_ShowOption.eLeft)
	local view = self:getViewByName(viewName)
	if view then
		local parentNode = view:getRootNode():getParent()
		VisibleRect:relativePosition(view:getRootNode(),parentNode,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(20,0))
		self:setDeleteOnExit(viewName, true)
		view:setViewName(viewName)
		view:setBeShowBtn(bShowBtn)
		return view
	end
		
end