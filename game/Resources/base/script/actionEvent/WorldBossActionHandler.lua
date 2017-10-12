require("actionEvent.ActionEventDef")
require("common.ActionEventHandler")
require("object.worldBoss.WorldBossMgr")

WorldBossActionHandler = WorldBossActionHandler or BaseClass(ActionEventHandler)

function WorldBossActionHandler:__init()
	local bossList = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handle_BossList(reader)
	end
	
	local showAni = function (reader)
		reader = tolua.cast(reader, "iBinaryReader")
		self:handle_showAni(reader)
	end
	self:Bind(ActionEvents.G2C_Boss_Refresh, showAni)
	self:Bind(ActionEvents.G2C_Boss_List, bossList)
end

function WorldBossActionHandler:__delete()

end

function WorldBossActionHandler:handle_BossList(reader)
	local bossList = {}
	local cnt = reader:ReadChar()	
	for i=1, cnt do 
		bossList[i] = {}		
		bossList[i].bossId = StreamDataAdapter:ReadStr(reader)			
		bossList[i].refreshTime = reader:ReadInt()					
	end
	local worldBossMgr = G_getHero():getWorldBossMgr()
	worldBossMgr:setBossList(bossList)
		
	--数据回来后更新界面	
	local view = UIManager.Instance:getViewByName("WorldBossView")
	if view then 
		if view:isShowing() then 
			view:update()
		end
	end		
	
	GameWorld.Instance:getStrongerMgr():setReady(StrongerChannel.Boss)
end

function WorldBossActionHandler:handle_showAni(reader)
	local bossId = StreamDataAdapter:ReadStr(reader)
	local worldBossMgr = G_getHero():getWorldBossMgr()
	worldBossMgr:setRefreshBossId(bossId)
	
	local mainView = UIManager.Instance:getMainView()
	if mainView then 
		mainView:showWorldBossAni()
	end
end
