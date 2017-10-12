require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require("data.activity.resDownload")

ResDownloadActionHandler = ResDownloadActionHandler or BaseClass(ActionEventHandler)

function ResDownloadActionHandler:__init()
	local canGetHandle = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handG2C_resDownloadCanGetReward(reader)
	end
	self:Bind(ActionEvents.G2C_resDownloadCanGetReward,canGetHandle)
end

function ResDownloadActionHandler:handG2C_resDownloadCanGetReward(reader)
	local count = StreamDataAdapter:ReadChar(reader)
	local data = {}
	local ref = ""
	for i=1,count do
		ref = StreamDataAdapter:ReadStr(reader)
		table.insert(data,ref)
	end
	ResManager.Instance:setResRewardData(data)				
end



