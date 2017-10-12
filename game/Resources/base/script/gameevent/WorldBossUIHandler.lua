require ("common.GameEventHandler")
require ("ui.UIManager")
require "ui.worldBossUI.WorldBossView"

WorldBossUIHandler = WorldBossUIHandler or BaseClass(GameEventHandler)

function WorldBossUIHandler:__init()
	self.eventObjTable = {}
	local manager =UIManager.Instance
		
	local showWorldBossView = function (arg)		
		manager:registerUI("WorldBossView", WorldBossView.create)
		manager:showUI("WorldBossView",E_ShowOption.eMiddle,arg)	
	end
	
	local lvChange = function (newLv, preLv)
		self:handle_heroLvChange(newLv, preLv)
	end
		
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventHeroLevelChanged, lvChange))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventShowWorldBossView, showWorldBossView))
end

function WorldBossUIHandler:__delete()
	for k, v in pairs(self.eventObjTable) do
		self:UnBind(v)
	end
end

function WorldBossUIHandler:handle_heroLvChange(newLv, preLv)
	local mainView = UIManager.Instance:getMainView()
	if mainView ==nil then 
		return
	end
	if newLv >= 40 then 
		mainView:setMainOtherBtnVisible(MainOtherType.WorldBoss,true)
		mainView:setMainOtherBtnVisible(MainOtherType.Stronger,true)			
	else
		mainView:setMainOtherBtnVisible(MainOtherType.WorldBoss,false)
	end
end