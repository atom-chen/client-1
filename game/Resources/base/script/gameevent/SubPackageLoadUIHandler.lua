require "common.GameEventHandler"
require "ui.UIManager"
require "ui.subPackageLoadUI.SubPackageLoadView"

SubPackageLoadUIHandler = SubPackageLoadUIHandler or BaseClass(GameEventHandler)
local percentage = 0
local total = 0
local speed = 0
local complete = false
local fileName = ""
function SubPackageLoadUIHandler:__init()
	local manager = UIManager.Instance
	self.dowloadError = false
	local showSubPackageLoadView = function ()		
		manager:registerUI("SubPackageLoadView", SubPackageLoadView.create)
		manager:showUI("SubPackageLoadView")
		local view = manager:getViewByName("SubPackageLoadView")
		if complete == true then
			view:setError(self.dowloadError)
			view:updateBtn(1)
		end		
	end
	
	local handleBackgroundDownload = function (eventCode, intValue, stringData, doubleValue)
		self:handleDownloadUpdate(eventCode, intValue, stringData, doubleValue)	
	end
	
	local reset = function ()
		self.dowloadError = false
		percentage = 0
		total = 0
		speed = 0
		complete = false
		fileName = ""
	end
	
	local close = function ()
		local view = manager:getViewByName("SubPackageLoadView")
		reset()
		if view then		
			view:close()
		end	
	end
	self:Bind(GameEvent.EventCloseSubPackageView,close)	
	self:Bind(GameEvent.EventSubPackageLoadViewReset,reset) 
	self:Bind(GameEvent.EventSubPackageLoadViewOpen, showSubPackageLoadView)
	self:Bind(GameEvent.EventSubPackageLoadViewUpdate,handleBackgroundDownload)	
end

function SubPackageLoadUIHandler:__delete()
	
end

function SubPackageLoadUIHandler:handleDownloadUpdate(eventCode, intValue, stringData, doubleValue)
	
	if eventCode == kOnDownloadSpeed then
		speed = string.format("%.2f",doubleValue)		
	elseif eventCode == kOnError then
		--  ¿Õ¼ä²»×ã
		self.dowloadError = true
		if intValue ==  kCreateFile then
			showMsgBox(Config.LoginWords[354])
		else
			showMsgBox(Config.Words[349])
		end
	elseif eventCode == kOnProgress then
		if intValue < total or intValue == total then
			if total == 0 then
				percentage = 0
			else
				percentage = intValue/total*100
				percentage = math.ceil(percentage)
			end				
		end
		
	elseif eventCode == kOnFilesize then		
		if fileName ~= stringData then
			fileName = stringData
			total = intValue					
		end	
	elseif eventCode == kOnAllFilesSize then
		
	elseif eventCode == kOnSuccess then		
			
	elseif eventCode == kOnComplete then			
		complete = true
	end
	
	local view = UIManager.Instance:getViewByName("SubPackageLoadView")
	if view then
		if not complete then
			view:updateProgress("",percentage,speed)
		else
			view:setError(self.dowloadError)
			view:updateBtn(1)
		end			
	end
end