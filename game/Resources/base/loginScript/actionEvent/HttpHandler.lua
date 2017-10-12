--[[
ר�Ŵ���httpЭ��ķ���
]]

require("common.ActionEventHandler")
require("object.manager.HttpDef")

HttpHandler = HttpHandler or BaseClass(ActionEventHandler)

function HttpHandler:__init()
	function httpCallback(state, tag, responeData)
		if tag == eHttpReqTag.ServerListTag then		
			-- �������б���
			LoginWorld.Instance:getLoginManager():handleServerList(state, responeData)
		elseif tag == eHttpReqTag.BridgeAuthTag then
--			UIManager.Instance:hideLoadingHUD()
			-- �Ž���֤����
			LoginWorld.Instance:getLoginManager():handleBridgeAuth(state, responeData)
		elseif tag == eHttpReqTag.ResUpdateTag or tag == eHttpReqTag.ResUpdateSilentTag or tag == eHttpReqTag.ExtendVersion then
			require("object.res.ResManager")
			UIManager.Instance:hideLoadingHUD()
			-- ��Դ�����б�
			ResManager.Instance:handleResUpdateList(state, responeData, tag)
		elseif tag == eHttpReqTag.Notify then 
			-- �����б�
			LoginWorld.Instance:getNotifyManager():handleNotifyUrlList(state, responeData)
		elseif tag == eHttpReqTag.NotifyContent then
			-- ��������
			LoginWorld.Instance:getNotifyManager():handleNotifyContents(state, responeData)	
		elseif tag == eHttpReqTag.ErrorLogUpload then 
			--todo
			--������־�ϴ�����
		elseif tag == eHttpReqTag.ExchangeCode then
			GameWorld.Instance:getExchangeCodeMgr():handleRequireResult(state, responeData)
		end
	end
	
	HttpTools:getInstance():registLuaCallBack(httpCallback)
end

function HttpHandler:__delete()
	
end