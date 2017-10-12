require "common.baseclass"	
require "gameevent.GameEvent"
require "ui.UIManager"
require "ui.activity.VipLuckDraw"
VipLuckDrawUIHandler = VipLuckDrawUIHandler or BaseClass(GameEventHandler)
	
function VipLuckDrawUIHandler:__init()
	local manager =UIManager.Instance	
	
	local eventOpenVipLuckDraw = function (showOption, arg)	
		local isShow = manager:isShowing("VipLuckDraw")
		if isShow == false then
			
			manager:registerUI("VipLuckDraw", VipLuckDraw.create)
			manager:showUI("VipLuckDraw",E_ShowOption.eMiddle, arg)						
--[[		elseif isShow == true then
			local view = manager:getViewByName("VipLuckDraw")
			if view then
				view:refreshLabelNum()				
			end	--]]
		end
	end
	
	local function showMarquee()	
		local view = manager:getViewByName("VipLuckDraw")
		if view then
			view:openBottomMarquee()
		end	
	end
	
	local function closeMarquee()	
		local view = manager:getViewByName("VipLuckDraw")
		if view then
			view:closeBottomMarquee()
		end	
	end
	local function showVipReward(index)	
		local view = manager:getViewByName("VipLuckDraw")
		if view then		
			if index ~= 100 then
				view:showAnimation()
			elseif index == 100 then
				view:showVipReward()
				-- 新手指引已完成
				GameWorld.Instance:getNewGuidelinesMgr():requestFunStepCompleteRequest("activity_manage_16")	
			end
		end	
	end
	
	local eventRefreshVipLuckDraw = function()
		local view = manager:getViewByName("VipLuckDraw")
		if view then					
			view:refreshLabelNum()
			if self.isShow == false then
				view:refreshItemIcon()
			end
		end			
	end
	local openFailedFunc = function()
		local view = manager:getViewByName("VipLuckDraw")
		if view then
			view:openFailedFunc()
		end
	end
	
	self:Bind(GameEvent.EventVipLuckRefresh,eventRefreshVipLuckDraw)
	self:Bind(GameEvent.EventVipLuckDrawOpen, eventOpenVipLuckDraw)	
	self:Bind(GameEvent.EventShowVipMarquee,showMarquee)
	self:Bind(GameEvent.EventCloseMarquee,closeMarquee)
	self:Bind(GameEvent.EventShowVipReward,showVipReward)
	self:Bind(GameEvent.EventVipLuckDrawOpenFailed,openFailedFunc)
end

function VipLuckDrawUIHandler:__delete()
		
end		