require("ui.UIManager")
require("common.LoginBaseUI")

ResourcesUpdateView = ResourcesUpdateView or BaseClass(LoginBaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local total = -1
local percentage = 0
local count= 0
local fileName = ""
local maxErrorCount = 3
local lastName = ""
function ResourcesUpdateView:__init()
	self.viewName = "ResourcesUpdateView"
	
	self.fadeIn = 0.2
	self.time = 0.05
	self.errorCount = 0
	self:createRootNode()
	self.errCode = -1
end

function ResourcesUpdateView:__delete()
	self:unschedulePatchEntry()
	self:unscheduleDownloadEntry()
	
	if self.loadSpeed then
		self.loadSpeed:release()
		self.loadSpeed = nil
	end
	if self.currentRate then
		self.currentRate:release()
		self.currentRate = nil
	end
	self.nameLabel = nil
	self.UpdateSpriteWhite2BG = nil
end

function ResourcesUpdateView:create()
	return ResourcesUpdateView.New()
end

function ResourcesUpdateView:setSpeed(str)
	if type(str) == "string" and self.loadSpeed then
		self.loadSpeed:setString(str)
	end
end

function ResourcesUpdateView:setProgress(str)
	if type(str) == "string" and self.currentRate then
		self.currentRate:setString(str)
	end
end

function ResourcesUpdateView:createRootNode()
	self:makeMeCenter()
	
	local colorBg = CCSprite:create("loginUi/login/enterGameBg.jpg")
	G_setBigScale(colorBg)
	self.rootNode:addChild(colorBg)
	VisibleRect:relativePosition(colorBg, self.rootNode, LAYOUT_CENTER)
	
	self.currentNum = 0
	self.allNum = 0
	self.loadNum = CCLabelTTF:create("", "Arial", 30)
	self.rootNode:addChild(self.loadNum, 1)
	
	--进度条背景
	local progressBg = createScale9SpriteWithFrameNameAndSize(RES("login_progressBg.png"),CCSizeMake(600,107))
	colorBg:addChild(progressBg)
	VisibleRect:relativePosition(progressBg, colorBg, LAYOUT_CENTER, ccp(0,-205))
	
	--下载速度
	self.loadSpeed = CCLabelTTF:create(" ", "Arial", 15)
	self.loadSpeed:retain()
	progressBg:addChild(self.loadSpeed)
	VisibleRect:relativePosition(self.loadSpeed, progressBg, LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE)
	
	--当前进度
	self.currentRate = CCLabelTTF:create(" ", "Arial", 15)
	self.currentRate:retain()
	progressBg:addChild(self.currentRate)
	VisibleRect:relativePosition(self.currentRate, progressBg, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE)
	
	--进度条底
	local length = visibleSize.width * 0.45
	
	local UpdateSpriteWhite1BG = createScale9SpriteWithFrameName(RES("login_loadProgressBg.png"))
	progressBg:addChild(UpdateSpriteWhite1BG)
	VisibleRect:relativePosition(UpdateSpriteWhite1BG, progressBg, LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X, ccp(0, -30))
	
	self.UpdateSpriteWhite2BG = createScale9SpriteWithFrameName(RES("login_loadProgressBg.png"))
	progressBg:addChild(self.UpdateSpriteWhite2BG)
	VisibleRect:relativePosition(self.UpdateSpriteWhite2BG, progressBg, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X, ccp(0, 30))
	
	--蓝进度条
	local loadProgressBlue = createSpriteWithFrameName(RES("login_loadProgressBlue.png"))
	UpdateSpriteWhite1BG:addChild(loadProgressBlue)
	VisibleRect:relativePosition(loadProgressBlue, UpdateSpriteWhite1BG, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER,ccp(0,0))
	
	local CallFucnCallback1 = function()
		VisibleRect:relativePosition(loadProgressBlue, UpdateSpriteWhite1BG, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER,ccp(0,0))
	end
	local actionArray1 = CCArray:create()
	actionArray1:addObject(CCFadeIn:create(0.5))
	actionArray1:addObject(CCMoveBy:create(3, ccp(length, 0)))
	actionArray1:addObject(CCFadeOut:create(1))
	actionArray1:addObject(CCCallFunc:create(CallFucnCallback1))
	
	local sequenceAction1 = CCSequence:create(actionArray1)
	loadProgressBlue:runAction(CCRepeatForever:create(sequenceAction1))
	
	--红进度条
	local loadProgressRed = createSpriteWithFrameName(RES("login_loadProgressRed.png"))
	self.UpdateSpriteWhite2BG:addChild(loadProgressRed)
	VisibleRect:relativePosition(loadProgressRed, self.UpdateSpriteWhite2BG, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER,ccp(0,0))
	
	local CallFucnCallback2 = function()
		VisibleRect:relativePosition(loadProgressRed, self.UpdateSpriteWhite2BG, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER,ccp(0,0))
	end
	
	local label = createLabelWithStringFontSizeColorAndDimension(Config.LoginWords[14014], "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
	self.UpdateSpriteWhite2BG:addChild(label)
	VisibleRect:relativePosition(label, self.UpdateSpriteWhite2BG, LAYOUT_CENTER_X+LAYOUT_TOP_OUTSIDE, ccp(0, 10))
	
	local actionArray2 = CCArray:create()
	actionArray2:addObject(CCFadeIn:create(0.5))
	actionArray2:addObject(CCMoveBy:create(3, ccp(length, 0)))
	actionArray2:addObject(CCFadeOut:create(2))
	actionArray2:addObject(CCCallFunc:create(CallFucnCallback2))
	
	local sequenceAction2 = CCSequence:create(actionArray2)
	loadProgressRed:runAction(CCRepeatForever:create(sequenceAction2))
	
	self.nameLabel = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size3"), FCOLOR("ColorWhite1"))
	self.UpdateSpriteWhite2BG:addChild(self.nameLabel)	
	VisibleRect:relativePosition(self.nameLabel, self.UpdateSpriteWhite2BG, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -20))
end

function ResourcesUpdateView:onEnter()
	self:setSpeed("")
	self:setProgress(Config.LoginWords[14011].."0%")
end

function ResourcesUpdateView:startDownload(urlList,func)
	percentage = 0
	fileName = ""
	self.dowloadSpeed = 0
	self.finish = false
	self.dowloadError = false
	local tick = function ()
		if self.dowloadError then
			self:unscheduleDownloadEntry()
			DownloadManager.Instance:stop()
			self:showDownloadErrorNotify(urlList,func)
			self.dowloadError  = false
		else
			if self.finish then
				self:unscheduleDownloadEntry()
				self:setProgress(Config.LoginWords[14011].."100%")
				DownloadManager.Instance:stop()
				self.finish = false
				
				if func then
					func()
				end
				local callback = function(list)
					self:delayFunc(list)
				end
				DownloadManager.Instance:moveDownloadedFile(callback)
			else
				self.dowloadSpeed = string.format("%.2f",self.dowloadSpeed)
				local showingTitle = self.dowloadSpeed.."kb/s"
				self:setSpeed(showingTitle)
				percentage = math.ceil(percentage)
				self:setProgress(Config.LoginWords[14011]..percentage.."%")
				self:setCurrentNumAndAllNum(fileName,percentage,total)
			end
		end
	end
	
	local downloadCallBack = function(eventCode, intValue, stringData, doubleValue)
		self:handleDownloadDelegate(eventCode, intValue, stringData, doubleValue)
	end
	
	ResManager.Instance:startDownload(downloadCallBack)
	self:unscheduleDownloadEntry()
	self.tickid = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1, false)
end

function ResourcesUpdateView:delayFunc(list)
	local delayFunc = function ()
		local size = table.size(list)
		if size > 0 then
			ResManager.Instance:reloadZpk(list)
			if ResManager.Instance:checkResVersion() == true then
				local serverMgr = LoginWorld.Instance:getServerMgr()
				local selectServer = serverMgr:getSelectServer()
				ResManager.Instance:requestUpdateRes(selectServer:getServerId(),nil, nil, eHttpReqTag.ResUpdateTag)
			else
				GlobalEventSystem:Fire(GameEvent.EVENT_SELECTALLSERVER_UI)
			end
		else
			GlobalEventSystem:Fire(GameEvent.EventPatch,DownloadManager.Instance:getDownloadList())
		end
	end
	UIManager.Instance:showLoadingHUD(1.5,nil,delayFunc)
end

function ResourcesUpdateView:showDownloadErrorNotify(dowloadList,func)
	-- 网络错误的处理
	local networkError = function ()
		local downloadErrorNotice = function(arg,text,id)
			if id == 0 then
				self:startDownload(dowloadList,func)
			else
				GlobalEventSystem:Fire(GameEvent.EVENT_SELECTALLSERVER_UI)
			end
		end
		local btns ={
		{text = Config.LoginWords[10043], id = 0},
		{text = Config.LoginWords[10045], id = 1},
		}
		local notic = Config.LoginWords[14001]
		if self.errorCount == maxErrorCount then
			btns = {
			{text = Config.LoginWords[10043], id = 0},
			}
			notic = Config.LoginWords[14002]
			downloadErrorNotice = function ()
				GlobalEventSystem:Fire(GameEvent.EVENT_SELECTALLSERVER_UI)
			end
			self.errorCount = 0
		end
		local msg = showMsgBox(notic)
		msg:setBtns(btns)
		msg:setNotify(downloadErrorNotice)
	end
	
	local spaceError = function ()
		local clickCallback = function ()
			GlobalEventSystem:Fire(GameEvent.EVENT_SELECTALLSERVER_UI)
		end
		local msg = showMsgBox(Config.LoginWords[354]..Config.LoginWords[356])
		msg:setNotify(clickCallback)
	end
	
	if self.errCode == kCreateFile then
		spaceError()
	else
		networkError()
	end
end

function ResourcesUpdateView:unschedulePatchEntry()
	if self.patchTickid then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.patchTickid)
		self.patchTickid = nil
	end
end

function ResourcesUpdateView:unscheduleDownloadEntry()
	if self.tickid then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.tickid)
		self.tickid = nil
	end
end

function ResourcesUpdateView:startPatch(patchList, callback)
	if self.nameLabel then
		self.nameLabel:setString(" ")
	end
	percentage = 0
	self.current = 0
	self.total = 0
	self.patchFinish = false
	self.patchError = false
	local patchTick = function ()
		if self.patchError == true then
			self.patchError = false
		end
		if self.patchFinish then
			self:setProgress(Config.LoginWords[14011].."100%")
			
			self.patchFinish = false
			local completeFunc = function ()
				local schId
				local onTimeout = function()
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(schId)
					GlobalEventSystem:Fire(GameEvent.EVENT_SELECTALLSERVER_UI)
				end
				schId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 1, false)
			end
			
			if callback then
				PatchManager.Instance:complete(callback)
			else
				PatchManager.Instance:complete(completeFunc)
			end
		else
			if self.current ~= 0 and self.total ~= 0 then
				local showString = self.current.." / "..self.total
				percentage = self.current/self.total*100
				percentage = math.ceil(percentage)
				self:setProgress(Config.LoginWords[14011]..percentage.."%")
			end
		end
	end
	local patchCallback = function(eventCode,errorCode,current,total)
		self:handlePatchDelegate(eventCode,errorCode,current,total)
	end
	
	local manager = PatchManager.Instance
	manager:registerCallBack(patchCallback)
	manager:startPatch(patchList)
	self:unschedulePatchEntry()
	self.patchTickid = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(patchTick, 1, false)
end

function ResourcesUpdateView:handlePatchDelegate(eventCode,errorCode,current,total)
	if eventCode == eOnPatchProgress then
		self.current = current
		self.total = total
	elseif eventCode == eOnSuccess then
		self.patchFinish = true
	elseif eventCode == eOnError then
		self.patchError = true
	end
end

function ResourcesUpdateView:handleDownloadDelegate(eventCode, intValue, stringData, doubleValue)
	
	if eventCode == kOnDownloadSpeed then
		self.dowloadSpeed = string.format("%.2f",doubleValue)
	elseif eventCode == kOnError then
		-- 保存errCode
		self.errCode = intValue
		self.dowloadError = true
		
		if self.errCode ~= kCreateFile then
			-- 空间不足不需要加errorCount
			self.errorCount = self.errorCount + 1
		end
	elseif eventCode == kOnProgress then
		if total ~= -1 then
			percentage = intValue/total*100
		end
		percentage = math.ceil(percentage)
	elseif eventCode == kOnFilesize then
		fileName = stringData
	elseif eventCode == kOnAllFilesSize then
		total = intValue
	elseif eventCode == kOnSuccess then
		if fileName == "" then
			fileName = stringData
		end
	elseif eventCode == kOnComplete then
		self.finish = true
	end
end

function ResourcesUpdateView:setCurrentNumAndAllNum(currentNum, allNum,size)
	if allNum then
		self:setProgress(Config.LoginWords[14011]..allNum.."%")
	end
	if currentNum and lastName ~= currentNum then
		if self.nameLabel and self.UpdateSpriteWhite2BG then
			self.nameLabel:setString(currentNum)						
			VisibleRect:relativePosition(self.nameLabel, self.UpdateSpriteWhite2BG, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -20))					
		end
		lastName = currentNum
	end
end
