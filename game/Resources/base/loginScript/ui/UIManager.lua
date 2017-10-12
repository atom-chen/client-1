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

--dialog��zֵ����
E_DialogZOrder = 
{
	ReviveDlg = 0,
	HeroActiveState = 10, --�Զ�Ѱ·/�Զ����
	ReConnectDlg = 20,	
	Tips = 30,
}

--GameRoot��Zֵ����
E_GameRootNodeOder = 
{
	PluckRootNode = 10
}

--����View�������ļ�
--deleteOnExit: ����ʱ�Ƿ�ɾ������������Ϊtrue
--preload: 		Ԥ���أ��Ƿ���ע��ʱ��������������Ϊfalse
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
m_pGameRootNode: 	���ڼ�����Ϸ��������(��������ͼ)
m_pUIRootNode:		�����߼����ܵ�UI
m_pDialogRootNode:	MessageBox, Tips�ȵ�����
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
	
	--�Ѿ�������UI��ʵ��
	self.uiList = {}
	
	--����UI��key�ʹ���������ӳ��
	self.uiCreateList = {}
	self.message=nil
	self.loadingHUD = nil
	self.popupMenu = nil
	
	--����������ʾ��UI������levelΪ��ʾ�Ĳ�Σ�Ϊ0-n, Խ���ʾԽǰ  
	self.uiInShow = 
	{	
		--name = {obj = viewNode, pos = E_ViewPos.eMiddle, level = -1}
	}
	
	--����gameMainView��������
	self.gameMainView = nil
		
	self.maxUILevel = 0
end

--UIRootNode�赲����Touch
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
ע��UI�Ĵ�������
uiKey(string): 			���ڵ�����, showUI�������ҵĲ���
createFun(function): 	����UI��function
]]
function UIManager:registerUI(uiKey, createFun)
	local func = self.uiCreateList[uiKey]
	if func == nil then
		self.uiCreateList[uiKey] = createFun
	end				
	
	if (self:isPreload(uiKey))	 then	--�Ƿ�Ԥ����
		self:createUI(uiKey)
	end
end

--[[
�ֶ��ͷ�UI
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
		if (view.onExit) then 						--�ص�UI��onExit����
			view.onExit(view)						
		end	
		view:getRootNode():removeFromParentAndCleanup(false)
	end
	
	--Juchao@20131226: Ϊʲô��Ҫ�ٴ��жϣ���Ϊ���������onExit����������ܻ����hideUI()����showUI()������ܻᵼ�¸�UI����ǰɾ��			
	if self.uiList[name] then	
		view:DeleteMe()
		self.uiList[name] = nil					--��uiInShow�����Ƴ���		
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
arg		 :	�Զ���Ĳ�������������self���ᴫ�ݸ��ص�����
titleText:	��������
num		 :	��ʼ����
notify	 : 	�ص��������ص������Ĳ���˵����
	arg:		�Զ���Ĳ���
	eventType�� 1Ϊ���ֱ仯�¼���2Ϊȷ���¼���3Ϊȡ���¼�
	num 	 ��	��ǰ����
titleText�� ��������
minNum	: 	�������С����
maxNum	:	������������
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
size ��С
items ��ʽ��{{lable, id, callback, arg, disable},}
--lable Ҫ��ʾ������
--id  lable��id
--callback ���lable��Ļص�
--arg   �����ص��Ĳ���
--disable �Ƿ񲻿�ʹ�ã�����ɫ
--e.g. {{lable = "test", id = 1, callback = fun, arg = "����", disable = false},}
parent ��Ҫ��ӵ���Node
point ���븸�ڵ����Ͻǵľ���㣬��ȷ����ʾ��λ��
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
@��������
delay�ӳٶ��������ʧ
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
delay �ӳٶ��������ʧ
parent ��Ҫ��ӵ���Node
touchArea �������
func �ӳٺ����е�function
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
	self:doShowLoadingHUD(delay,parent,func,touchArea) --Juchao@20140626: ֱ��show��loading������ʹ��sch�ӳ�show���ܵ��µ����ü�������	
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
text��Tips������
duration ��delayTime
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
node: UI������
option:
E_ShowOption =
{
eRejectOther = 1, 	--��ʾ���м䣬������������
eMove2Left	 = 3,  	--���м��ƶ�����࣬��Ӱ����������
eMove2Right	 = 4,  	--���м��ƶ����Ҳ࣬��Ӱ����������
eMiddle	 = 5,		--��ʾ���м䣬��Ӱ����������
eLeft	 = 6,  		--��ʾ����ߣ���Ӱ����������
eRight	 = 7,  		--��ʾ���ұߣ���Ӱ����������
}
}
arg: �Զ���������ɴ��ݸ�onEnter()����
--]]
function UIManager:showUI(name, option, arg)
	if (option == nil) then
		option = E_ShowOption.eRejectOther
	end
	
	if type(name) == "string" then
		local view = self.uiList[name]
		
		if (self.uiInShow[name]) then	--���������ʾ����ֻ����UI���ݲ���
			if (view.onEnter) then 		--�ص�onEnter����
				view.onEnter(view, arg)
			end
			return
		end
		
		if (option == E_ShowOption.eRejectOther) then	--��������UI
			self:hideAllUI()
		end
		
		if view == nil then			--�����ڴ���
			view = self:createUI(name)
		end
		if (view == nil) then		--����ʧ�ܣ��˳�
			print("UIManager:showUI create UI"..name.." failed. return")
			return
		end
		
		self:handleShowOption(option, name, view)	
		self.m_pUIRootNode:addChild(view:getRootNode())
		self:updateViewLevel(false)
		
		--Juchao@20140314: ����onEnter������Ҫ��updateViewLevel()֮��
		--��ΪonEnter�п��ܻ�show�µ�UI�������ᵼ���µ�UI��level�ȸ�UI�ĵ�
		if (view.onEnter) then		
			view.onEnter(view, arg)
			if GameEvent.EventOnEnterView then
				GlobalEventSystem:Fire(GameEvent.EventOnEnterView,name)
			end
		end
	end
end	

--����һ��view��UIManager�Ĺ����С����¼��view�Ĳ��
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
	local delay = CCDelayTime:create(0.03) 	--delayһ��ʱ�������ж��������⿨��
	local sequence = CCSequence:createWithTwoActions(delay, move)
	viewNode:runAction(sequence)		
end

--����UI
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
	
	local node = view:getRootNode() --�Ƚ�node������������ֹview�ڲ���node��Ϊnil��getRootNode()Ϊnilֵ
	if self:isShowing(name) and node then	
		node:retain()	
		self.uiInShow[name] = nil							
		if (view.onExit) then 						--�ص�UI��onExit����
			view.onExit(view)	
			if GameEvent.EventOnExitView then
				GlobalEventSystem:Fire(GameEvent.EventOnExitView,name)	
			end						
		end	
		node:removeFromParentAndCleanup(false)
		node:release()
	end
	
	--Juchao@20131226: Ϊʲô��Ҫ�ٴ��жϣ���Ϊ���������onExit����������ܻ����hideUI()����showUI()������ܻᵼ�¸�UI����ǰɾ��			
	if self.uiList[name] then
		if (self:isDeleteOnExit(name)) then			--�Ƿ�ɾ��
			view:DeleteMe()
			self.uiList[name] = nil					--��uiInShow�����Ƴ���
		end
	end			
end

--������view��zorder��Ϊ0����������Ϊ-1��
--��������UI����m_pUIRootNode�ĵ��£�m_pUIRootNode���Ե�ס��Щview�Ĵ����¼���
--autoMove: �Ƿ���ֻ��һ����ʾviewʱ��view�Ƶ��м�
function UIManager:updateViewLevel(autoMove)
	local views = {}	
	local size = 0
		
	for k, v in pairs(self.uiInShow) do		--����view��level�����򣬴�ŵ�views��
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
	local isTopLevelView = function(pos)	--�ж��Ƿ�����view
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
	for k, v in pairs(self.uiInShow) do	--�Ƚ����е�View�ŵ�������������ΪhideUI���self.uiInShowɾ��ĳ�����ֱ�Ӷ�self.uiInShow��������
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

-- �ƶ�view self.uiInShow[node] = {obj = view, pos = E_ViewPos.eRight}
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

--����ʹ��
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