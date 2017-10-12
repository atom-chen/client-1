require("common.baseclass")
require("actionEvent.ActionEventDef")
StrengthenQuestMgr = StrengthenQuestMgr or BaseClass()

function StrengthenQuestMgr:__init()

end

function StrengthenQuestMgr:clear()

end

--获取变强任务
function StrengthenQuestMgr:requestStrengthenQuest()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_SectionQuest_Begin)	
	simulator:sendTcpActionEventInLua(writer)	
end
