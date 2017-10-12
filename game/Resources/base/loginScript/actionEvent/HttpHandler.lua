--[[
专门处理http协议的返回
]]

require("common.ActionEventHandler")
require("object.manager.HttpDef")

HttpHandler = HttpHandler or BaseClass(ActionEventHandler)

function HttpHandler:__init()
	function httpCallback(state, tag, responeData)
		if tag == eHttpReqTag.ServerListTag then		
			-- 服务器列表返回
			LoginWorld.Instance:getLoginManager():handleServerList(state, responeData)
		elseif tag == eHttpReqTag.BridgeAuthTag then
--			UIManager.Instance:hideLoadingHUD()
			-- 桥接认证返回
			LoginWorld.Instance:getLoginManager():handleBridgeAuth(state, responeData)
		elseif tag == eHttpReqTag.ResUpdateTag or tag == eHttpReqTag.ResUpdateSilentTag or tag == eHttpReqTag.ExtendVersion then
			require("object.res.ResManager")
			UIManager.Instance:hideLoadingHUD()
			-- 资源更新列表
			ResManager.Instance:handleResUpdateList(state, responeData, tag)
		elseif tag == eHttpReqTag.Notify then 
			-- 公告列表
			LoginWorld.Instance:getNotifyManager():handleNotifyUrlList(state, responeData)
		elseif tag == eHttpReqTag.NotifyContent then
			-- 公告数据
			LoginWorld.Instance:getNotifyManager():handleNotifyContents(state, responeData)	
		elseif tag == eHttpReqTag.ErrorLogUpload then 
			--todo
			--错误日志上传返回
		elseif tag == eHttpReqTag.ExchangeCode then
			GameWorld.Instance:getExchangeCodeMgr():handleRequireResult(state, responeData)
		end
	end
	
	HttpTools:getInstance():registLuaCallBack(httpCallback)
end

function HttpHandler:__delete()
	
end