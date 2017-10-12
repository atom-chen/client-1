--[[
--分包下载
--]]
require ("common.GameEventHandler")
require "ui.resourceDownload.ResDownloadView"	
require "ui.resourceDownload.ResUpdateLogView"

ResDownloadUIHandler = ResDownloadUIHandler or BaseClass(GameEventHandler)

function ResDownloadUIHandler:__init()
	local showResLoadingView = function ()		
		UIManager.Instance:registerUI("ResDownloadView", ResDownloadView.create)
		UIManager.Instance:showUI("ResDownloadView")				
	end
	
	local showResLogView = function ()
		UIManager.Instance:registerUI("ResUpdateLogView", ResUpdateLogView.create)
		UIManager.Instance:showUI("ResUpdateLogView")	
	end
			
	self:Bind(GameEvent.EventShowResDownloadView,showResLoadingView)
	self:Bind(GameEvent.EventShowResLogView,showResLogView)	
end

function ResDownloadUIHandler:__delete()

end