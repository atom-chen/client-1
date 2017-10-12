require("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")

NewGuidelinesActionHandle = NewGuidelinesActionHandle or BaseClass(ActionEventHandler)

function NewGuidelinesActionHandle:__init()
	local funGetStepList = function (reader)		
		reader = tolua.cast(reader,"iBinaryReader")
		self:getStepList(reader)
	end
	self:Bind(ActionEvents.G2C_FunStepList_Response,funGetStepList)
end	

function NewGuidelinesActionHandle:getStepList(reader)
	local number = reader:ReadChar()		
	local stepList = {}
	for i=1,number do
		local stepId = StreamDataAdapter:ReadStr(reader)
		table.insert(stepList,stepId)
	end
	GameWorld.Instance:getNewGuidelinesMgr():setStepList(stepList)
end
