require ("common.GameEventHandler")
require ("gameevent.GameEvent")
require ("ui.UIManager")
require ("ui.faction.FactionApplyView")
require ("ui.faction.FactionCreateView")
require ("ui.faction.FactionInfoView")
require ("ui.faction.FactionPlayerInfoView")
require ("ui.faction.FactionApplyInfoView")
require ("ui.faction.FactionListView")
FactionUIHandler = FactionUIHandler or BaseClass(GameEventHandler)

function FactionUIHandler:__init()
	local manager =UIManager.Instance
		
	local showApplyView = function ()
		
		manager:registerUI("FactionApplyView", FactionApplyView.create)
		manager:showUI("FactionApplyView")		
	end
	local showCreateView = function()
		
		manager:registerUI("FactionCreateView", FactionCreateView.create)
		manager:showUI("FactionCreateView",E_ShowOption.eRejectOther)
	end
	local showInfoView = function()
		
		manager:registerUI("FactionInfoView", FactionInfoView.create)
		manager:showUI("FactionInfoView")
	end
	local showPlayerInfoView = function()
		
		manager:registerUI("FactionPlayerInfoView", FactionPlayerInfoView.create)
		manager:showUI("FactionPlayerInfoView",E_ShowOption.eMiddle)
	end
	local showApplyInfoView = function()
		
		manager:registerUI("FactionApplyInfoView", FactionApplyInfoView.create)
		manager:showUI("FactionApplyInfoView",E_ShowOption.eMiddle)
	end
	local showListView = function()
		
		manager:registerUI("FactionListView", FactionListView.create)
		manager:showUI("FactionListView")
	end
		
	local refreshApplyBtn = function()	
		local view = manager:getViewByName("FactionApplyView")
		if view then
			view:refreshApplyBtn()
		end		
	end
	
	local refreshCancelApplyBtn = function()	
		local view = manager:getViewByName("FactionApplyView")
		if view then
			view:refreshCancelApplyBtn()
		end		
	end
	
	local changeOffice = function()
		local view = manager:getViewByName("FactionPlayerInfoView")
		if view then
			view:refreshOffice()
		end		
		local view = manager:getViewByName("FactionInfoView")
		if view then
			view:refreshInfoTableView(1)
		end		
	end
	
	local refreshApplyList = function()	
		local view = manager:getViewByName("FactionListView")
		if view then
			view:refreshApplyList()
			view:refreshLeftLabel()
		end		
	end
	
	local closePlayerInfoView = function()
		local view = manager:getViewByName("FactionPlayerInfoView")
		if view then
			view:close()
		end	
	end
	
	local refreshApplyTableView = function()
		local view = manager:getViewByName("FactionApplyView")
		if view then
			view:refreshApplyTableView()
		end	
	end
	
	local refreshInfoTableView = function()
		local view = manager:getViewByName("FactionInfoView")
		if view then
			view:refreshInfoTableView(2)
		end	
	end
	
	local refreshMemberList = function()	
		local isShow = manager:isShowing("FactionInfoView")
		if isShow == true then
			local view = manager:getViewByName("FactionInfoView")
			if view then
				view:refreshMemberList()
			end
		end	
	end
	local memberUpdate = function(updateType)
		self:memberUpdate(updateType)
	end
	local officeUpdate = function()
		self:officeUpdate()
	end
	self:Bind(GameEvent.EventOpenFactionApplyView,showApplyView)
	self:Bind(GameEvent.EventOpenCreateView,showCreateView)
	self:Bind(GameEvent.EventOpenInfoView,showInfoView)
	self:Bind(GameEvent.EventOpenPlayerInfoView,showPlayerInfoView)
	self:Bind(GameEvent.EventOpenApplyInfoView,showApplyInfoView)
	self:Bind(GameEvent.EventOpenListView,showListView)	
	self:Bind(GameEvent.EventRefreshApplyBtn,refreshApplyBtn)
	self:Bind(GameEvent.EventRefreshCancelBtn,refreshCancelApplyBtn)
	self:Bind(GameEvent.EventOfficeChanged,changeOffice)
	self:Bind(GameEvent.EventRefreshApplyList,refreshApplyList)
	self:Bind(GameEvent.EventClosePlayerInfoView,closePlayerInfoView)
	self:Bind(GameEvent.EventRefreshApplyTableView,refreshApplyTableView)
	self:Bind(GameEvent.EventRefreshInfoTableView,refreshInfoTableView)
	self:Bind(GameEvent.EventRefreshMemberList,refreshMemberList)
	self:Bind(GameEvent.EventMemberUpdate,memberUpdate)
	self:Bind(GameEvent.EventOfficeUpdate,officeUpdate)
	
end

function FactionUIHandler:memberUpdate(updateType)
	local manager =UIManager.Instance
	local isShow = manager:isShowing("FactionInfoView")
	if isShow == true then
		local view = manager:getViewByName("FactionInfoView")
		if view then
			view:memberUpdate(updateType)
		end
	end	
end

function FactionUIHandler:officeUpdate()
	local manager =UIManager.Instance
	local isShow = manager:isShowing("FactionInfoView")
	if isShow == true then
		local view = manager:getViewByName("FactionInfoView")
		if view then
			view:officeUpdate()
		end
	end	
end
