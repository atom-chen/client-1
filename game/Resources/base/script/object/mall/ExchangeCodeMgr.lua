ExchangeCodeMgr = ExchangeCodeMgr or BaseClass()

local m_isShowExchangeCode = true

function ExchangeCodeMgr:__init()

end

function ExchangeCodeMgr:__delete()

end

function ExchangeCodeMgr:clear()

end

function ExchangeCodeMgr:getIsShowExchangeCodeView()
	return m_isShowExchangeCode
end

--根据服务器id请求公告地址列表
function ExchangeCodeMgr:requireExchange(codeId)
	local loginManager = LoginWorld.Instance:getLoginManager()			
	
	local identityName = nil
	if loginManager.getIdentityName then
		identityName = loginManager:getIdentityName()
	else
		identityName = loginManager.gameServerAuthData.identityName
	end
	
	local playerName = PropertyDictionary:get_name(G_getHero():getPT())	
	local playerId = G_getHero():getId()
	local serverMgr = LoginWorld.Instance:getServerMgr()
	local server = serverMgr:getSelectServer()
	local serverId = server:getServerId()
	local serverUrl = server:getServicesUrl()
	
	local params = {}
	params["cardNo"] = codeId
	params["identityName"] = identityName
	params["playerName"] = playerName
	params["playerId"] = playerId
	params["serverId"] = serverId
	params["actionUrl"] = serverUrl	
	
	local url = self:buildRequestUrl("giftsCard", params)
	if url then 		
		local httpTools = HttpTools:getInstance()
		httpTools:send(url, kTypePost, eHttpReqTag.ExchangeCode, 0, 0)							
	else
		CCLuaLog("url install error")
	end		
end

function ExchangeCodeMgr:buildRequestUrl(action, params)
	local url = LoginWorld.Instance:getServerMgr():getServicesUrl()
	
	if url and action and params and type(action)=="string" and type(params)=="table" then 
		url = url .. "?action=" .. action
		for key, value in pairs(params) do 
			url = url .. "&" .. key .. "=" .. value
		end
		return url
	else
		UIManager.Instance:showSystemTips(Config.Words[25004])
	end
end

function ExchangeCodeMgr:handleRequireResult(state, responeData)
	UIManager.Instance:hideLoadingHUD()
	if state == 200 then
		local cjson = require "cjson.safe"
		local data,errorMsg = cjson.decode(responeData)
		if data and type(data) == "table" then
			local exchangeResult = data.code
			local errorCode = data.description
			if exchangeResult == 1 then
				GlobalEventSystem:Fire(GameEvent.EventResetEditeBox)
				UIManager.Instance:showSystemTips(errorCode)
			else
				UIManager.Instance:showSystemTips(errorCode)
			end
		end
	else
		
	end
end