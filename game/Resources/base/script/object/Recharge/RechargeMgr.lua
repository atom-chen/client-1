require ("data.activity.yuanbao")
require("object.Recharge.RechargeObject")
RechargeMgr = RechargeMgr or BaseClass()

function RechargeMgr:__init()
	self.rechargeList = {}
	self.needUpdate = false	
	self.objectList = {}
	self:setRechargeList()
	self.reset = false	
end

function RechargeMgr:clear()
	self.reset = false
end

function RechargeMgr:openPay()	
	--showMsgBox(Config.Words[455])
	if SFLoginManager:getInstance():needShowCustomTopupView() then
		local heroName = PropertyDictionary:get_name(G_getHero():getPT())
		local url = LoginWorld.Instance:getServerMgr():getRechargeChannelUrl()			
		local jsonData = self:encodeToJson(nil,nil,nil,url,heroName, nil, nil)
		SFLoginManager:getInstance():openPayWithCustomAmount(jsonData)
	else
		GlobalEventSystem:Fire(GameEvent.EventOpenRechargeView, onEventOpenRechargeView)	
	end			
end	

function RechargeMgr:openPayView(refId,productName,money, yuanBao, reward, callback)
	if callback == nil then	
		callback = function ()		
		end
	end
	local heroName = PropertyDictionary:get_name(G_getHero():getPT())
	local url = LoginWorld.Instance:getServerMgr():getRechargeChannelUrl()	
	if url and productName and money then 	
		local schId
		local onTimeout = function()	
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(schId)	
			local jsonData = self:encodeToJson(refId,productName,money,url,heroName, yuanBao, reward)			
			SFLoginManager:getInstance():openPay(jsonData,callback)			
		end
		schId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 0.5, false);	
	end
end

--[[
	key1 = serverURl
	key2 =  heroName
	key3 = amount
	key4 = productName
	key5 = refId 
]]
function RechargeMgr:encodeToJson(refId,productName,amount,url,heroName,yuanBao, reward)
	local data = {}
	data["serverURl"]  = SFGameHelper:urlEncode(url)
	data["heroName"]   = heroName
	data["productName"]  = productName
	data["amount"] = tostring(amount)	
	data["refId"] = refId
	data["yuanbao"] = yuanBao
	data["reward"] = reward
	local cjson = require "cjson.safe"		
	local jsonData = cjson.encode(data)
	return jsonData
end

function RechargeMgr:setRechargeList()
	local rechargeTable = GameData.Yuanbao
	local count = 1
	for key,v in pairs(rechargeTable) do
		local object = RechargeObject.New(v,count)
				
		table.insert(self.rechargeList, object)
		self.objectList[key]  = object
		count = count + 1		
	end		
	local sortFun = function (a, b)
		return a:getLevel() < b:getLevel()		
	end
	table.sort(self.rechargeList, sortFun)
end

function RechargeMgr:getRechargeList()
	return self.rechargeList
end

function RechargeMgr:requestFirstTopupList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_QuickRecharge_List)
	simulator:sendTcpActionEventInLua(writer)
end

function RechargeMgr:needToUpdateView()
	return self.needUpdate
end

function RechargeMgr:setNeedUpdate(needToUpdate)
	self.needUpdate = needToUpdate
end

function RechargeMgr:updateWithList(list)
	self.needUpdate = false
	local inforList = {}
	for k,v in pairs(self.objectList) do
		inforList[k] = false
	end	
	
	for k,v in pairs(list) do
		inforList[k] = true
	end
	for theKey,v in pairs(self.objectList) do
		if v:isFirstTopup() ~= inforList[theKey] then
			self.needUpdate = true
		end
		v:setFirstTopup(inforList[theKey])				
	end
end

function RechargeMgr:resetAll()
	for k,v in pairs(self.objectList) do
		v:setFirstTopup(false)		
	end
	self.reset = true
	self.needUpdate = true
end

function RechargeMgr:hasBeenReset()
	return self.reset
end

