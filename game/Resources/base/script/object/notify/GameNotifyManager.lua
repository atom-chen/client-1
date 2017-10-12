require("ui.utils.MessageBox")
require("object.manager.NotifyObj")
require("ui.login.NotifyView")	

NotifyManager = NotifyManager or BaseClass()

--[[
notify ����
]]

NotifyType={
	UpdateNotify = "1",
	CommonNotify = "2",
	MainTainNotify = "3",
	LoginNotify = "4",
}

function NotifyManager:__init()
	self.currentType = NotifyType.MainTainNotify		
end

function NotifyManager:__delete()
	if not table.isEmpty(self.notifyList) then
		for key,v in pairs(self.notifyList) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.notifyList = {}
	end
end

function NotifyManager:clear()
	--�������������ڽ�ɫ�л���ʱ��Ҫ�ã�������������
end

--���ݷ�����id���󹫸��ַ�б�
function NotifyManager:requireServerNotifyUrlList(serverId)
	if not table.isEmpty(self.notifyList) then
		for key,v in pairs(self.notifyList) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
	end
	
	self.notifyList = {}
	--���ⳡ���л�Ҳ��ʾ����
	self.isFirstLogin = true
	--������¹�����ʾ���
	self.isFirstShow = true
	
	local loginManager = LoginWorld.Instance:getLoginManager()
	local gameNoticeListUrl = LoginWorld.Instance:getServerMgr():getNoticeListUrl()
	local qdCode = SFLoginManager:getInstance():getQDCode1()
	local gameNoticeList
	if gameNoticeListUrl then
		gameNoticeList = string.gsub(gameNoticeListUrl, "{serverId}", serverId)	
		gameNoticeList = string.gsub(gameNoticeList, "{qdCode}", qdCode)			
	end		
	local httpTools = HttpTools:getInstance()
	httpTools:send(gameNoticeList, kTypePost, eHttpReqTag.Notify, 0, 0)	
end	

function NotifyManager:createAndInsertInNotifyList(notify)
	local notifyObj = NotifyObj.New()
	notifyObj:setId(notify.id)
	notifyObj:setStartTime(notify.beginTime)
	notifyObj:setEndTime(notify.endTime)
	notifyObj:setType(notify.noticeType)
	table.insert(self.notifyList, notifyObj)
end

--�����ַ�б��ش���
function NotifyManager:handleNotifyUrlList(state, responeData)
	self.notifysContent = {}	
	self.tatleNotify = 0
	self.haveReceive = 0	
	
	if state == 200 then
		local cjson = require "cjson.safe"
		local data,errorMsg = cjson.decode(responeData)
		if data and type(data) == "table" then
			local notifys = data	
			--���湫��id, beginTime, endTime, type	
			for key,notify in pairs(notifys) do			
				if self:checkIsValidNotify(notify) then
					if notify.noticeType ~= NotifyType.MainTainNotify or self:getNeedShowMaintainView() then															
						self:createAndInsertInNotifyList(notify)
						self.tatleNotify = self.tatleNotify+1
						self:requireNofifyContentById(notify.id)																																										
						--[[local requireNotify = function ()
							self:requireNofifyContentById(notify.id)
							self.tatleNotify = self.tatleNotify+1
							if self.delayRequire then
								CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayRequire)
								self.delayRequire = nil
							end
						end
						if self.delayRequire then
							CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayRequire)
							self.delayRequire = nil
						end						
						self.delayRequire = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(requireNotify, 0.1, false)--]]
					end
				end															
			end
													
		end					
	else
		--��ȡ�����ַ�б�ʧ��
		--UIManager.Instance:showSystemTips(Config.LoginWords[15011])
	end
end	
--�Ƿ�Ҫ��ʾά������
function NotifyManager:setNeedShowMaintainView(bShow)
	self.showMaintain = bShow	
end	

function NotifyManager:getNeedShowMaintainView()
	if self.showMaintain == nil then
		self.showMaintain = false
	end
	return self.showMaintain
end

function NotifyManager:getNotifyById(notifyId)
	for key,notify in pairs(self.notifyList) do
		if tonumber(notify:getId()) == tonumber(notifyId) then
			return notify				
		end
	end						
	return nil
end

function NotifyManager:requireNofifyContentById(notifyId)	
	local myGameNoticeUrl
	local gameNoticeUrl = LoginWorld.Instance:getServerMgr():getNoticeListUrl()	
	local httpTools = HttpTools:getInstance()	
	local notify =self:getNotifyById(notifyId)		
	if not notify then
		return
	end			
	if self:checkIsValidNotify(notify) then
		myGameNoticeUrl = string.gsub(gameNoticeUrl, "{id}", notifyId)					
		httpTools:send(myGameNoticeUrl, kTypePost, eHttpReqTag.NotifyContent, 0, 0)													
	end
end

function NotifyManager:unescape(url)
	if url then
		local hex_to_char = function(x)
			return string.char(tonumber(x, 16))
		end		
		return url:gsub("%%(%x%x)", hex_to_char)
	end	
	return ""	
end	

function NotifyManager:handleNotifyContents(state, responeData)
	if state == 200 then
		local cjson = require "cjson.safe"
		local data, errorMsg = cjson.decode(responeData)	
		if data and type(data)=="table" then				
			local notify = self:getNotifyById(data.id)	
			if notify then
				notify:setNotifyTitle(self:unescape(data.noticeTitle))
				notify:setNotifyName(self:unescape(data.noticeName))
				if notify:getType()==NotifyType.UpdateNotify then
					notify:setNotifyVersion(data.version)
				end
				notify:setNotifyContent(self:unescape(data.content))
			
				if tonumber(notify:getType())==tonumber(NotifyType.MainTainNotify) then
					self:showMaintainNotifyView(notify)
				end	
			end																																				
		end	
		self.haveReceive = self.haveReceive+1	
		if self:getReadyShow() then		
			if self:getTotalNumber()==self:getHaveReceiveNumber()then
				self:removeValidNotifys()
				if self:needShow()  then
					self:showNotifyViewInLogin()
					self:setReadyShow(false)	
					self:setFirstRoleLogin(false)	
				end					
			end						
		end	
	else
		--��ȡ����ʧ�ܺ�Ĵ���
	end		
end	

function NotifyManager:checkIsValidNotify(notify)
	local currentTime = os.time()
	local notifyStartTime = notify.beginTime/1000
	local notifyEndTime = notify.endTime/1000
	if not notifyStartTime or not notifyEndTime then
		return false
	end
	if tonumber(notifyStartTime) < currentTime and tonumber(currentTime) < notifyEndTime then
		return true
	else
		return false
	end
end
--App����
function NotifyManager:setAppUpdate(bUpdate)
	self.appUpdate = bUpdate
end

function NotifyManager:getAppUpdate()
	if not self.appUpdate then
		return false
	end
	return self.appUpdate
end
--�ϰ�����
function NotifyManager:setBagUpdate(bUpdate)
	self.bagUpdate = bUpdate
end	

function NotifyManager:getBagUpdate()
	if not self.bagUpdate then
		return false
	end
	return self.bagUpdate
end	


function NotifyManager:getMaintainNotifyMsg(notify)		
	if (not notify) or (not notify:getNotifyName()) then
		return
	end
	local msg = ""
	if notify:getNotifyTitle() then
		msg = Config.LoginWords[15002] .. notify:getNotifyTitle() .. "\n"					
	end
	if notify:getNotifyName() then
		msg = msg .. Config.LoginWords[15003] .. notify:getNotifyName() .. "\n"
	end
	if notify:getNotifyContent() then
		msg = msg .. Config.LoginWords[15004].."\n" .. notify:getNotifyContent()
	end
	return msg										
end
--ά������ר��
function NotifyManager:showMaintainNotifyView(notify)
	local msg = self:getMaintainNotifyMsg(notify)
	if not msg then	
		return
	end
			
	local msgBox = MessageBox.New()
		
	msgBox:setMsg(msg)
	msgBox:setSwallowAllTouch(true)
	msgBox:setSize(CCSizeMake(385, 564))
	local btns = {}
	msgBox:setBtns(btns)
	local notifyFunc = function (arg)
		if arg then		
			arg:DeleteMe()	
			arg = nil	
		end
	end
	msgBox:setNotify(notifyFunc, msgBox)
	msgBox:layout()		
	
	local titleNode = createLabelWithStringFontSizeColorAndDimension(Config.LoginWords[15005], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow2"))	
	msgBox:setFormTitle(titleNode, TitleAlign.Center)
	
	UIManager.Instance:showDialog(msgBox:getRootNode(), 1)		
end

function NotifyManager:getSequenceNotifyList()
	local notifys = {}
	for key,v in pairs(self.notifyList) do
		table.insert(notifys, v)
	end
	return notifys
end	

function NotifyManager:sortListByStartTime(list)
	sortFunc = function(a, b) 	
		return b:getStartTime() > a:getStartTime()
	end		
	
	if table.size(list) > 1 then
		table.sort(list, sortFunc)
	end		
end

function NotifyManager:getSortByStartTimeNotifyList()
	local notifys = self:getSequenceNotifyList()
	self:sortListByStartTime(notifys)
	return notifys
end		

function NotifyManager:isHaveNotifyContent()
	for key,notify in pairs(self.notifyList) do
		if notify:getNotifyName() then
			return true
		end
	end
	return false
end

--�жϽ�ɫ�Ƿ��һ�ε�¼�����ڽ�ɫ�л����ж�
function NotifyManager:setFirstRoleLogin(bFirstLogin)
	self.isFirstLogin = bFirstLogin
end

function NotifyManager:getFirstRoleLogin()
	return self.isFirstLogin	
end	

--�˺ŵ�һ�ε�¼,�����ж��Ƿ�Ҫ��ʾ���¹���
function NotifyManager:setIsFirstShow(isFirstShow)
	self.isFirstShow = isFirstShow
end

function NotifyManager:getIsFirstShow()
	return self.isFirstShow
end

--���й�������
function NotifyManager:getTotalNumber()
	return self.tatleNotify
end

--�ѽ��յĹ���
function NotifyManager:getHaveReceiveNumber()
	return self.haveReceive
end	

function NotifyManager:removeValidNotifys()
	for key,notify in pairs(self.notifyList) do	
		if not notify:getNotifyName() then
			--table.remove(self.notifyList,key)
			self.notifyList[key]:DeleteMe()
			self.notifyList[key] = nil
		else
			if tonumber(notify:getType())==tonumber(NotifyType.UpdateNotify) and self:checkRemoveUpdateNotify() then		
				--table.remove(self.notifyList, key)
				self.notifyList[key]:DeleteMe()
				self.notifyList[key] = nil				
			end
		end
	end		
end

--����Ƿ���ʾ���¹��棬����ʾ����б���ɾ��
function NotifyManager:checkRemoveUpdateNotify()
	if self:getIsFirstShow() and (self:getAppUpdate() or self:getBagUpdate()) then	
		self:setIsFirstShow(false)
		self:setAppUpdate(false)
		self:setBagUpdate(false)		
		return false
	else
		return true
	end	
end

function NotifyManager:needShow()
	if self:isHaveNotifyContent() and self:getFirstRoleLogin() then
		self:setFirstRoleLogin(false)
		self:setReadyShow(false)
		return true
	end
	return false
end	

function NotifyManager:showNotifyViewInLogin()
	local view = NotifyView:create()
	view:setSwallowAllTouch(true)
	UIManager.Instance:showDialog(view:getRootNode(), 1)						
end

function NotifyManager:setReadyShow(bShow)
	self.readyShow = bShow
end

function NotifyManager:getReadyShow()
	if self.readyShow==nil then
		self.readyShow = false
	end
	return self.readyShow
end