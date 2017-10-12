require "common.BaseObj"
DownloadManager = DownloadManager or BaseClass(BaseObj)

function DownloadManager:__init()
	DownloadManager.Instance = self
	self.download = nil
	self.callBack = nil
	self.downloadPath = nil
	self.downloadDelegate = nil
	self.downloadList = nil	
	self.bDownload = false
end

function DownloadManager:__delete()
	self.callBack = nil
	self.downloadPath = nil
	self.downloadDelegate = nil
	if self.download then
		self.download:delete()
		self.download = nil
	end
end

function DownloadManager:stop()
	if self.download then
		self.download:stopDownLoad()
		self.download:delete()
		self.download = nil
		self.bDownload = false
	end
end

function DownloadManager:isDownload()
	return self.bDownload
end

function DownloadManager:startDownloadURL(urlList)
	if self.bDownload == true then
		return 
	end
	if self.download == nil then
		self.download = SFDownload:new()
		self.download:setConnectionTimeout(2)
	else
		self.download:stopDownLoad()
	end
	self.downloadList  = {}	
	for k,v in pairs(urlList) do
		print("startDownloadURL:"..v.url)
		self.download:addPackageUrl(v.url,v.md5)
		table.insert(self.downloadList,v.name)
	end
	
	local function callback(eventCode, intValue, stringData, doubleValue)
		if self.callBack then
			self.callBack(eventCode, intValue, stringData, doubleValue)
		end
		
		if eventCode == kOnComplete then
			LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.ResDownloadFinish)
			self.bDownload = false
		end
	end
	
	if self.downloadPath then
		self:checkDownloadPath(self.downloadPath)
		self.download:setStoragePath(self.downloadPath)
	end
	if self.callBack then
		local downloadDelegate = SFDownLoadDelegateLua:new()
		downloadDelegate:setHandler(callback)
		downloadDelegate:autorelease()
		self.download:setDelegate(downloadDelegate)
	end
	LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.ResDownloadStart)
	self.download:startDownload()
	self.bDownload = true
end

function DownloadManager:registerCallBack(func)
	self.callBack = func
end

function DownloadManager:unregisterCallBack()
	self.callBack = nil
end

function DownloadManager:setDownloadPath(path)
	self.downloadPath = path
end

function DownloadManager:getDownloadPath()
	return self.downloadPath
end

function DownloadManager:checkDownloadPath(path)
	if not SFGameHelper:isDirExist(path)then
		SFGameHelper:createDir(path)
	end
end

function DownloadManager:getDownloadList()
	return self.downloadList
end

function DownloadManager:getFileNameList()
	return self.fileNameList
end

function DownloadManager:moveDownloadedFile(callbackFunc)
	local needMove = {}	
	local count = 0	
	local moveCallBack = function ()
		count = count - 1			
		if count < 0 or count == 0 then
			callbackFunc(needMove)
		end	
	end
	
	local donotNeedMove = true
	local keyList = {}
	for k,v in pairs(self.downloadList) do
		if string.find(v,"base") or string.find(v,"extend") then		
			count = count + 1
			table.insert(keyList,k)					
		end
	end
	
	local value = ""
	for k,v in pairs(keyList) do
		value = self.downloadList[v]
		if string.find(value,"base") or string.find(value,"extend") then		
			local oldName = self.downloadPath.."/"..value						
			local reloadName =	tempNameToRealName(value)
			if reloadName then
				table.insert(needMove,reloadName)	
				local newName = SFGameHelper:getExtStoragePath()..reloadName			
				SFGameHelper:moveFile(oldName,newName,moveCallBack)
				donotNeedMove = false
			end										
		end
	end
			
	if donotNeedMove then
		callbackFunc(needMove)
	end
	self:delayStop()
end

function DownloadManager:delayStop()
	local function stop()
		self:stop()
		if self.stopTick and self.stopTick ~= -1 then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.stopTick)
			self.stopTick = -1	
		end
		
	end
	self.stopTick = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(stop, 0, false)
end


