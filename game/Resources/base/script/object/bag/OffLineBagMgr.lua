require("common.baseclass")
require("actionEvent.ActionEventDef")
require("object.bag.OffLineBagObject")
require("ui.UIManager")

OffLineBagMgr = OffLineBagMgr or BaseClass()

function OffLineBagMgr:__init()
	self.offLineBagObject = OffLineBagObject.New()
end

function OffLineBagMgr:clear()
	if self.offLineBagObject then
		self.offLineBagObject:DeleteMe()
		self.offLineBagObject = nil
	end
end	

function OffLineBagMgr:getOffLineBagObject()
	return self.offLineBagObject
end	

function OffLineBagMgr:requestViewOffLineAIReward()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_ViewOffLineAIReward)
	simulator:sendTcpActionEventInLua(writer)
end

function OffLineBagMgr:requestDrawOffLineAIReward()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_DrawOffLineAIReward)
	simulator:sendTcpActionEventInLua(writer)
end
