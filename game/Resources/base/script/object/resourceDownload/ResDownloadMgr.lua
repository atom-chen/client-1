--[[
--分包下载
--]]
--ttype:1=元宝, 2=绑定元宝,3=金币,4=物品
RewardType = {
YuanBao = 1, 
BindYuanBao = 2, 
Gold = 3,
Item = 4,
}

ResDownloadMgr = ResDownloadMgr or BaseClass()

function ResDownloadMgr:__init()

end

function ResDownloadMgr:__delete()

end

function ResDownloadMgr:getversionNode()
	return "9999-0000"
end

function ResDownloadMgr:getUpdateLog()
	local log = {}
	log[1] = "123"
	log[2] = "456"
	log[3] = "798"
	return log
end


function ResDownloadMgr:getReward()
	local reward = {}
	for i=1, 4 do 	
		reward[i] = {}
		reward[i].ttype = i
		reward[i].num = i
		reward[i].refId = "item_danyao_" .. i
	end
	return reward
end

--附件
function ResDownloadMgr:setRewardItem(Reward)
	if Reward == "" or Reward == nil then
		return nil
	end
	--json转数据
	local cjson = require "cjson.safe"		
	local data,erroMsg = cjson.decode(Reward)	
	if data then
		self.itemList = data
	else
		UIManager.Instance:showSystemTips("Error:  " .. erroMsg)
	end
end