require ("object.newGuidelines.NewGuidelinesStaticData")
require ("object.newGuidelines.NewGuidelinesDef")
NewGuidelinesMgr = NewGuidelinesMgr or BaseClass()

function NewGuidelinesMgr:__init()
	self.bCreateNewRole = LoginWorld.Instance:getLoginManager():getIsCreateNewRole()
	self.isDoNewGuidelinesMgr = false
	self.saveStep = 0
end

function NewGuidelinesMgr:__delete()

end

function NewGuidelinesMgr:clear()

end

function NewGuidelinesMgr:setIsCreateNewRole(bCreate)
	self.bCreateNewRole = bCreate
end

--显示欢迎界面
function NewGuidelinesMgr:showWelcomeView()
	if self.bCreateNewRole == true then
		GlobalEventSystem:Fire(GameEvent.EventOpenWelcomeView)
	end
end


function NewGuidelinesMgr:getDoNewGuidelinesMgr()
	return self.isDoNewGuidelinesMgr
end	

--第一个任务指引
function NewGuidelinesMgr:doNewGuidelinesFirstQuest()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,1)
end

--点击使用小魔血左上角头像指引
function NewGuidelinesMgr:doNewGuidelinesHeroHead()
	--todo需要任务判断条件
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local refId = "item_lixianmoxueshi"
	local hasInBag = bagMgr:hasItem(refId)
	if hasInBag then
		GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FightView)--切换到战斗UI
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,36)
	end
end

--使用小魔血打开背包
function NewGuidelinesMgr:doNewGuidelinesOpenBag()
	--todo需要任务判断条件
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,13)
end	

--使用小魔血石指引
function NewGuidelinesMgr:doNewGuidelinesUseXiaoMoXueShi()
	--todo需要任务判断条件
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,37)
end

--引导打开等级礼包
function NewGuidelinesMgr:doNewGuidelinesUseLevelReward()
	if self.saveStep==0 then
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,55)
	end
end

--引导点击药店中的指定道具
function NewGuidelinesMgr:doNewGuidelinesUseItemInShop()
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()	
	local questId = questMgr:getNewGuidelinesMainQuestId()
	local questObj = questMgr:getQuestObj(questId)
	if questObj then
		local queststate = questObj:getQuestState()
		local orderEventId = QuestRefObj:getOrderEventId(QuestType.eQuestTypeMain,questId)	
		if orderEventId==QuestOrderEventType.eShopEvent and queststate==QuestState.eAcceptedQuestState then
			GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,39)
		end
	end		
end


--引导点击日常任务刷新级别按钮
function NewGuidelinesMgr:doNewGuidelinesRefreshDailyQuestLevel()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,53)
end

--坐骑进阶奖励
function NewGuidelinesMgr:doNewGuidelinesRideAward()--缺少触发判断
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,56)
end

--引导点击状态模式
function NewGuidelinesMgr:doNewGuidelinesChosePKState()
	--todo需要任务判断条件
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,58)
end

--引导选择全体模式
function NewGuidelinesMgr:doNewGuidelinesChosePKByWhole()
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local instanceRefId = questMgr:getInstanceRefId()
	if self.saveStep == 58 and  GameData.AllIns_PK[instanceRefId] then
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,68)
	end			
end

--引导点击普通攻击
function NewGuidelinesMgr:doNewGuidelinesClickAttackBtn()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.AutoFightView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,59)	
end

--爵位解锁指引
function NewGuidelinesMgr:doNewGuidelinesOpenKnight()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,64)	
end

--引导点击爵位
function NewGuidelinesMgr:doNewGuidelinesClickKnight()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,24)	
end

--爵位升级指引
function NewGuidelinesMgr:doNewGuidelinesUpgradeKnight()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,65)	
end

--坐骑解锁指引
function NewGuidelinesMgr:doNewGuidelinesOpenMount()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,60)
end

--坐骑升级指引
function NewGuidelinesMgr:doNewGuidelinesUpgradeMount()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,61)
end

--坐骑升级升级按钮指引
function NewGuidelinesMgr:doNewGuidelinesClickUpgradeMountBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,66)
end

--翅膀解锁指引
function NewGuidelinesMgr:doNewGuidelinesOpenWing()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,62)
end

--翅膀升级指引
function NewGuidelinesMgr:doNewGuidelinesUpgradeWing()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,63)
end

--点击翅膀升级按钮指引
function NewGuidelinesMgr:doNewGuidelinesClickUpgradeWingBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,67)
end

--法宝解锁指引
function NewGuidelinesMgr:doNewGuidelinesOpenTalisman()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,69)
end

--点击副本图标指引
function NewGuidelinesMgr:doNewGuidelinesOpenInstance()	
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,42)
end

--引导打开镇魔塔界面
function NewGuidelinesMgr:doNewGuidelinesZhenMoTa()	
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,43)
end

--引导进入镇魔塔
function NewGuidelinesMgr:doNewGuidelinesEnterZhenMoTa()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,44)
end

--引导打开活动面板
function NewGuidelinesMgr:doNewGuidelinesClickActivity()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,47)
end

--引导点击竞技场图标
function NewGuidelinesMgr:doNewGuidelinesClickActivityHonorBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,48)
end

--引导进入竞技场对战
function NewGuidelinesMgr:doNewGuidelinesPKInArena()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,49)
end	

--引导活动主面板
function NewGuidelinesMgr:doNewGuidelinesMainActivity(refId)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,70,refId)
end

--引导活动提示面板
function NewGuidelinesMgr:doNewGuidelinesActivityTips()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,71)
end

--引导开服速冲面板
function NewGuidelinesMgr:doNewGuidelinesQuickUpLevel()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,72)
end

--引导VIP抽奖面板
function NewGuidelinesMgr:doNewGuidelinesVipLuck()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,73)
end

--引导镇魔塔NPC对话面板
function NewGuidelinesMgr:doNewGuidelinesNpcTalk()
	local gameInstanceMgr = GameWorld.Instance:getGameInstanceManager()
	if not gameInstanceMgr:getIsInstanceFinished() then		
		return
	end
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,74)
end

--引导7天登录面板
function NewGuidelinesMgr:doNewGuidelinesSevenLogin()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,75)
end

--引导挂机技能设置
function NewGuidelinesMgr:doNewGuidelinesHandupSkill(skillRefId)
	local hadOperateHandupSkill = GameWorld.Instance:getNewGuidelinesMgr():hadOperate("handUpSkillGuidence")
	if hadOperateHandupSkill == false then
		if GameData.HandUpSkill[skillRefId] then
			self.hasHandupSkill = true
		end
		if self.hasHandupSkill == true then
			--GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
			GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,78)
		end
	end		
end

function NewGuidelinesMgr:setSaveStep(step)
	self.saveStep = step
end	

function NewGuidelinesMgr:getSaveStep()
	return self.saveStep
end

function NewGuidelinesMgr:doQuestNewGuidelinesByStep(step)
	if step == 36 then
		self:doNewGuidelinesHeroHead()--点击使用小魔血左上角头像指引
	elseif step == 47 then
		self:doNewGuidelinesClickActivity()--引导打开活动面板
	elseif step == 64 then
		self:doNewGuidelinesOpenKnight()--爵位升级指引
	elseif step == 42 then
		self:doNewGuidelinesOpenInstance()--点击副本图标指引
	elseif step == 61 then
		self:doNewGuidelinesUpgradeMount()--坐骑升级指引
	elseif step == 63 then
		self:doNewGuidelinesUpgradeWing()--翅膀升级指引
	end
end

function NewGuidelinesMgr:requestFunStep()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_FunStep_Request)
	simulator:sendTcpActionEventInLua(writer)
end

function NewGuidelinesMgr:requestFunStepCompleteRequest(stepId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_FunStep_Complete_Request)
	writer:WriteString(stepId)
	simulator:sendTcpActionEventInLua(writer)
end

function NewGuidelinesMgr:setStepList(list)
	self.stepList = list
end

function NewGuidelinesMgr:getStepList()
	return self.stepList
end

function NewGuidelinesMgr:hadOperate(stepId)
	if self.stepList then
		for k,v in pairs(self.stepList) do
			if v == stepId then
				return true
			end
		end
	end
	return false
end

function NewGuidelinesMgr:insertStep(stepId)
	if self.stepList then
		table.insert(self.stepList,stepId)
	end
end

function NewGuidelinesMgr:clearArrow()
	GlobalEventSystem:Fire(GameEvent.EventHideArrow)
end