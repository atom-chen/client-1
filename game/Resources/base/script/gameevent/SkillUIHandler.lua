require ("common.GameEventHandler")
require ("ui.UIManager")
require ("ui.skill.SkillView")
require "ui.skill.QuickUpgradeView"
require "ui.skill.SkillDef"
SkillUIHandler = SkillUIHandler or BaseClass(GameEventHandler)

function SkillUIHandler:__init()
	self.eventObjTable = {}
	local manager =UIManager.Instance
	
	local handleClient_Open = function (selectIndex)
		self:handle_GetSkills()      --ÿ�δ򿪽��涼������,��ΪҪ��̬���³����
		--����Ƿ��м��ܵ�װ���� ��������滻��ԭ���ļ���
		--local skillMgr = GameWorld.Instance:getSkillMgr()
		--skillMgr:resetSkillRefId()
		
		manager:registerUI("SkillView", SkillView.create)		
		manager:showUI("SkillView",  E_ShowOption.eMiddle, nil)	
	end
	
	local handle_updateSwitchSkill = function (index)
		if index == 0 then
			return
		end
		local mainView = manager:getMainView()
		if mainView then
			local mainAttackView = mainView:getAttackSkillView()
			if mainAttackView then
				mainAttackView:updateSwitchSkill(index)
			end
		end
	end
	
	local showQuickView = function (skill)
		self:handle_showQuickView(skill)
	end
	
	--update UI
	local refreshSkillView = function()
		local manager = UIManager.Instance
		local skillView = manager:getViewByName("SkillView")
		if skillView and manager:isShowing("SkillView") then		
			skillView:updateSkills()											
		end			
	end
		
	local updateSuccess = function ()
		self:handleQuickUpdateSuccess()
	end
	local updateAttackView = function()
		self:handleUpdateAttackView()
	end
	
	local getSkills = function ()
		--����Ҷ�Ӧְҵ�ļ���ȫ��װ��
		local skillMgr = GameWorld.Instance:getSkillMgr()
		if skillMgr then
			skillMgr:loadAllSkill()
		end
		self:handle_GetSkills()
	end
	
	local showSkillDetailInfo = function (skillObject)
		self:handle_showSkillDetailInfo(skillObject)
	end
	
	local enableSkill = function ()
		self:handle_EnableSkill()
	end
	
	local heroLvChange = function (newLv, preLv)
		self:handle_HeroLvChange(newLv, preLv)
	end
	
	local updateExtendSkill = function (eventType, equipList)
		self:handle_UpdateExtendSkill(eventType, equipList)
	end
	
	local getExtendSkill = function ()
		self:handle_GetExtendSkill()
	end

	local onItemUpdate = function (eventType, items)  
		self:handle_jinengdanChange(eventType, items)  --��⼼�ܵ��Ƿ�ı�
	end
	
	local removeCdSprite = function (delIndex)
		self:handle_removeCdSprite(delIndex)
	end
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventRemoveCdSprite, removeCdSprite)) --ɾ���������cd progressTimer
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventItemUpdate, onItemUpdate))  --��Ҫ�Ǽ�⼼����ҩ
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateExtendSkillRefId, updateAttackView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventEquipList, getExtendSkill))--ɨ��װ�����Ƿ�����չ���ܣ����ڸ��������漼�ܲ�(��һ�ν�����Ϸ��
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventEquipUpdate, updateExtendSkill)) --����װ�����Ϻ�ж�£�������չ����
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventHeroLevelChanged, heroLvChange))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventHeroMpChange, enableSkill))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventShowSkillDetailInfo, showSkillDetailInfo))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventHeroEnterGame, getSkills))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventRefreshView, updateAttackView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateQuickSkillViewSuccess, updateSuccess))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventRefreshView, refreshSkillView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateSwitchSkill, handle_updateSwitchSkill))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventOpenSkillView,handleClient_Open))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventShowQuickView, showQuickView))
end

function SkillUIHandler:__delete()
	for k, v in pairs(self.eventObjTable) do
		self:UnBind(v)
	end
end

function SkillUIHandler:handle_removeCdSprite(delIndex)
	local mainView = UIManager.Instance:getViewByName("MainView")
	if mainView then 
		local skillSoltView = mainview:getAttackSkillView()
		if skillSoltView then 
			skillSoltView:deleteIfExists(delIndex)
		end
	end
end

function SkillUIHandler:handle_jinengdanChange(eventType, items)
	for k, item in pairs(items) do 
		if "item_jinengExp" == item:getRefId() then 		
			local manager =UIManager.Instance
			local skillView = manager:getViewByName("SkillView")
			if skillView then
				local skillMgr = G_getHero():getSkillMgr()
				local curSel = skillView:getCurSel()
				local skillObj = skillMgr:getSkillObjectById(curSel)
				if skillObj then
					local refId = PropertyDictionary:get_skillRefId(skillObj:getPT())
					skillMgr:addSkillNeedUpdate(refId)					
					if manager:isShowing("SkillView") then 
						skillView:updateSkills()
					end
				end					
			end
			break
		end
	end
end

function SkillUIHandler:handle_HeroLvChange(newLv, preLv)
	local manager =UIManager.Instance
	local skillMgr = GameWorld.Instance:getSkillMgr()
	local uiIndex = skillMgr:getUiIndex()
	local hasLearnTbl = {}	
	local minLv = 1000
	local showItemRefId = ""
	local heroProId = tonumber(PropertyDictionary:get_professionId(G_getHero():getPT()))
	
	for index, uiSkillRefId in pairs(uiIndex) do
		local skillObj = skillMgr:getSkillObjectByRefId(uiSkillRefId)
		if skillObj then
			local property = skillObj:getStaticData()
			if property and property["skillLearnLevel"] then	
				local learnLv = property["skillLearnLevel"]						
				if learnLv>preLv and learnLv<=newLv then
					local skill = {}					
					skill.skillName = PropertyDictionary:get_name(property)
					skill.iconName = PropertyDictionary:get_iconId(property)	
					skill.refId = uiSkillRefId
					table.insert(hasLearnTbl, skill)	
					local skillRefId = PropertyDictionary:get_skillRefId(skillObj:getPT())
					skillMgr:addSkillNeedUpdate(skillRefId)
					
					local msg = {}
					table.insert(msg,{word = Config.Words[2019], color = Config.FontColor["ColorWhite1"]})
					table.insert(msg,{word = "\""..skill.skillName.."\"", color = Config.FontColor["ColorRed3"]})
					--GameWorld.Instance:getEntityManager():getHero():twinkleTip(msg,6)
					UIManager.Instance:showSystemTips(msg)
					--��ȡѧϰ�ȼ��͵ģ������ڼ��ܽ�����Ϊ��ѡ����ʾ
					if minLv > learnLv then 
						minLv = learnLv
						showItemRefId = skillRefId
					end	
					--�һ�������������
					GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesHandupSkill(skill.refId)	
					--�Զ�װ�������ܲ۵ļ��ܲ�����������ʾ
					if Skill_Auto_Solt[heroProId] and Skill_Auto_Solt[heroProId][uiSkillRefId]==true then
						--todo
					else
						--����������ʾ				
						local viewName = "SkillTips" .. index
						local skillTips = UIManager.Instance:showPromptBox(viewName, 1)
						skillTips:setIcon(skill.iconName)
						skillTips:setIconWord(skill.skillName)					
						skillTips:setDescrition(skillObj:getDescByLevel(1))	
						local openSkillView = function ()
							GlobalEventSystem:Fire(GameEvent.EventOpenSkillView)
							skillTips:close()
						end
						skillTips:setBtn("skill_detail_normal_label.png",openSkillView, self)	
					end							
				end
			end
		end			
	end
	
	if showItemRefId ~= "" then 
		local selIndex = skillMgr:getIndexByRefId(showItemRefId)
		if selIndex then 
			skillMgr:setDefSel(selIndex)
		end			
	end		
	
	--�����ǰ�ĸ���װ���������Զ���ӵ����ܲ�
	if table.size(hasLearnTbl) ~= 0 then
		--������õļ��ܲ�����
		local solt = {}
		for i=1, 8 do 
			solt[i] = true
		end
		local markList = skillMgr:getMarkList()
		for k, v in pairs(markList) do 
			if v then 
				solt[v.index] = false
			end
		end		
		local bUpdateQuickSkill = false	
	
		local mainView = UIManager.Instance:getMainView()					
		for k, v in pairs(hasLearnTbl) do 
			if Skill_Auto_Solt[heroProId] and Skill_Auto_Solt[heroProId][v.refId] then	
				for availableIndex=1, 8 do 
					if solt[availableIndex]==true then
						local list = {}				
						list.modify = {}
						list.modify.refId = v.refId
						solt[availableIndex] = false
						list.modify.index = availableIndex							
						skillMgr:requestSetPutdownSkills(list)						
									
						if mainView then						
							local attackView = mainView:getAttackSkillView()
							attackView:showAutoSkillAmi(v.refId, availableIndex)
						end
						bUpdateQuickSkill = true						
						break
					end
				end															
			end
		end
		if bUpdateQuickSkill == true then 			
			local schedulerId = 0
			local scheduleCallback = function(time)
				skillMgr:requestSkillList()
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(schedulerId)
			end
			schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(scheduleCallback, 1.8, false)
		end			
		GlobalEventSystem:Fire(GameEvent.EventNewSkillLearned, hasLearnTbl)
	end
end

function SkillUIHandler:handle_EnableSkill()
	local manager =UIManager.Instance
	local mainView = manager:getMainView()
	if mainView then
		local attackView = mainView:getAttackSkillView()
		attackView:setSkillGray()
	end
end

function SkillUIHandler:handle_GetSkills()
	-- ������
	local skillMgr = GameWorld.Instance:getSkillMgr()
	skillMgr:requestSkillList()
end

function SkillUIHandler:handle_showSkillDetailInfo(skillObject)
	local manager =UIManager.Instance
	local skillView = manager:getViewByName("SkillView")
	if skillView then
		skillView:showSkillDetails(skillObject)
	end
end

function SkillUIHandler:handle_showQuickView(skill)
	local manager =UIManager.Instance
	local skillView = manager:getViewByName("SkillView")
	if skillView then
		local skillMgr = GameWorld.Instance:getSkillMgr()
		if skillMgr:canSetQuickSkill(skill) == false then
			UIManager.Instance:showSystemTips(Config.Words[2501])
		else
			
			manager:registerUI("QuickUpgradeView", QuickUpgradeView.create)
			manager:showUI("QuickUpgradeView", E_ShowOption.eMiddle)
			local skillMgr = GameWorld.Instance:getSkillMgr()
			local curSel = skillView:getCurSel()
			local skillObject = skillMgr:getSkillObjectById(curSel)
			local curSkillRefId = PropertyDictionary:get_skillRefId(skillObject:getPT())
			local upgradeView = UIManager.Instance:getViewByName("QuickUpgradeView")
			if upgradeView ~= nil then
				upgradeView:updateQuickSkills(curSkillRefId)
				GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,84)
			end
		end
	end
end

function SkillUIHandler:handleQuickUpdateSuccess()
	local manager =UIManager.Instance
	local quickSkillView = manager:getViewByName("QuickUpgradeView")
	
	if quickSkillView then
		if UIManager.Instance:isShowing("QuickUpgradeView") == false then 
			return
		end
		quickSkillView.recvChangeCount = quickSkillView.recvChangeCount + 1
		--���³ɹ������»�ȡ����
		if quickSkillView.recvChangeCount == quickSkillView.skillChangeCount then
			local skillMgr = GameWorld.Instance:getEntityManager():getHero():getSkillMgr()
			skillMgr:requestSkillList()
			quickSkillView.recvChangeCount = 0
			quickSkillView.skillChangeCount = 0
			
			if quickSkillView:getIsNewGuide()==true then
				quickSkillView:setIsNewGuide(false)				
			end	
		end			
	end
end

function SkillUIHandler:handleUpdateAttackView()
	local manager =UIManager.Instance
	local mainView = manager:getMainView()
	if mainView then
		local attackView = mainView:getAttackSkillView()
		if attackView then		
			attackView:updateAttackSkill()
		end
	end
end

function SkillUIHandler:handle_UpdateExtendSkill(eventType, equipList)
	if eventType == E_UpdataEvent.Add or eventType == E_UpdataEvent.Delete then 
		local skillMgr = GameWorld.Instance:getEntityManager():getHero():getSkillMgr()
		if skillMgr then 
			skillMgr:resetSkillRefId(equipList, eventType)
		end
	end
end

function SkillUIHandler:handle_GetExtendSkill()
	local skillMgr = GameWorld.Instance:getEntityManager():getHero():getSkillMgr()
	if skillMgr then 
		skillMgr:resetSkillRefId()
	end
end