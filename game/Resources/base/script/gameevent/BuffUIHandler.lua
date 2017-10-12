require ("common.GameEventHandler")
require ("ui.buff.BuffEffect")
require ("ui.Main.MainView")
BuffUIHandler = BuffUIHandler or BaseClass(GameEventHandler)

function BuffUIHandler:__init()
	self.eventObjTable = {}
	local manager =UIManager.Instance
	--update buff
	local refreshBuff = function(buffObject, action)
		local mainView = self:getMainView()
		if mainView then
			local buffView = mainView:getBuffView()
			if buffView then
				buffView:updateBuffView(buffObject, action)
			end
		end
	end		
	--ɾ��buff��tips
	local deleteTips = function ()
		self:deleteBuffTips()		
	end
	
	--buffЧ��
	local effectBuff = function ()
		self:handleEffectBuff()
	end
	--���buffЧ����player����
	local addBuffEffect2Player = function (object)
		self:handleAddBuffEffect2Player(object)
	end
	--ɾ��buffЧ��
	local deleteBuffEffect = function (object)
		self:handleDeleteBuffEffect(object)
	end 
	
	local requestBuff = function ()
		self:handleRequestBuff()
	end

	local moxueshiAmount = function ()
		self:handleMoXueshiAmount()
	end
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventMoXueShiAmount, moxueshiAmount))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventHeroEnterGame, requestBuff))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventDeleteEffect, deleteBuffEffect))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventAddBuffEffect2Player, addBuffEffect2Player))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventBuffEffect, effectBuff))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventRefreshBuff, refreshBuff))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventMainViewClick, deleteTips))
end

function BuffUIHandler:__delete()
	for k, v in pairs(self.eventObjTable) do
		self:UnBind(v)
	end
end

function BuffUIHandler:handleRequestBuff()
	local buffMgr = GameWorld.Instance:getBuffMgr()
	buffMgr:requestBuffList()
end

function BuffUIHandler:handleDeleteBuffEffect(object)
	if self.buffEffect then
		self.buffEffect:deleteBuffEffect(object)
	end
end

function BuffUIHandler:handleAddBuffEffect2Player(object)
	if not self.buffEffect then
		
		self.buffEffect = BuffEffect.New()
	end
	self.buffEffect:addBuffEffect2Player(object)
end

function BuffUIHandler:handleEffectBuff()
	if not self.buffEffect then
		
		self.buffEffect = BuffEffect.New()
	end
	local buffMgr = GameWorld.Instance:getBuffMgr()
	local buffEffectObject = buffMgr:getBuffEffectObj()
	self.buffEffect:showEffectBuff(buffEffectObject)
end

function BuffUIHandler:deleteBuffTips()
	local mainView = self:getMainView()
	if mainView then
		local buffView = mainView:getBuffView()
		if buffView then
			buffView:deleteTips()
		end
	end
end	

function BuffUIHandler:getMainView()
	local manager =UIManager.Instance
	local mainView = manager:getMainView()	
	return mainView
end

function BuffUIHandler:handleMoXueshiAmount()
	local mainView = self:getMainView()
	if mainView then
		local buffMgr = GameWorld.Instance:getBuffMgr()
		local moxueshiObj = buffMgr:getMoxueshiAmount()
		local buffView = mainView:getBuffView()
		if buffView then
			buffView:showMoxueshiAmount(moxueshiObj)
		end
	end		
end