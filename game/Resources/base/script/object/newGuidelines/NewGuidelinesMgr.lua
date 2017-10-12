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

--��ʾ��ӭ����
function NewGuidelinesMgr:showWelcomeView()
	if self.bCreateNewRole == true then
		GlobalEventSystem:Fire(GameEvent.EventOpenWelcomeView)
	end
end


function NewGuidelinesMgr:getDoNewGuidelinesMgr()
	return self.isDoNewGuidelinesMgr
end	

--��һ������ָ��
function NewGuidelinesMgr:doNewGuidelinesFirstQuest()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,1)
end

--���ʹ��СħѪ���Ͻ�ͷ��ָ��
function NewGuidelinesMgr:doNewGuidelinesHeroHead()
	--todo��Ҫ�����ж�����
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local refId = "item_lixianmoxueshi"
	local hasInBag = bagMgr:hasItem(refId)
	if hasInBag then
		GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FightView)--�л���ս��UI
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,36)
	end
end

--ʹ��СħѪ�򿪱���
function NewGuidelinesMgr:doNewGuidelinesOpenBag()
	--todo��Ҫ�����ж�����
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,13)
end	

--ʹ��СħѪʯָ��
function NewGuidelinesMgr:doNewGuidelinesUseXiaoMoXueShi()
	--todo��Ҫ�����ж�����
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,37)
end

--�����򿪵ȼ����
function NewGuidelinesMgr:doNewGuidelinesUseLevelReward()
	if self.saveStep==0 then
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,55)
	end
end

--�������ҩ���е�ָ������
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


--��������ճ�����ˢ�¼���ť
function NewGuidelinesMgr:doNewGuidelinesRefreshDailyQuestLevel()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,53)
end

--������׽���
function NewGuidelinesMgr:doNewGuidelinesRideAward()--ȱ�ٴ����ж�
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,56)
end

--�������״̬ģʽ
function NewGuidelinesMgr:doNewGuidelinesChosePKState()
	--todo��Ҫ�����ж�����
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,58)
end

--����ѡ��ȫ��ģʽ
function NewGuidelinesMgr:doNewGuidelinesChosePKByWhole()
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local instanceRefId = questMgr:getInstanceRefId()
	if self.saveStep == 58 and  GameData.AllIns_PK[instanceRefId] then
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,68)
	end			
end

--���������ͨ����
function NewGuidelinesMgr:doNewGuidelinesClickAttackBtn()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.AutoFightView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,59)	
end

--��λ����ָ��
function NewGuidelinesMgr:doNewGuidelinesOpenKnight()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,64)	
end

--���������λ
function NewGuidelinesMgr:doNewGuidelinesClickKnight()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,24)	
end

--��λ����ָ��
function NewGuidelinesMgr:doNewGuidelinesUpgradeKnight()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,65)	
end

--�������ָ��
function NewGuidelinesMgr:doNewGuidelinesOpenMount()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,60)
end

--��������ָ��
function NewGuidelinesMgr:doNewGuidelinesUpgradeMount()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,61)
end

--��������������ťָ��
function NewGuidelinesMgr:doNewGuidelinesClickUpgradeMountBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,66)
end

--������ָ��
function NewGuidelinesMgr:doNewGuidelinesOpenWing()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,62)
end

--�������ָ��
function NewGuidelinesMgr:doNewGuidelinesUpgradeWing()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,63)
end

--������������ťָ��
function NewGuidelinesMgr:doNewGuidelinesClickUpgradeWingBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,67)
end

--��������ָ��
function NewGuidelinesMgr:doNewGuidelinesOpenTalisman()
	GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FunctionView)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,69)
end

--�������ͼ��ָ��
function NewGuidelinesMgr:doNewGuidelinesOpenInstance()	
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,42)
end

--��������ħ������
function NewGuidelinesMgr:doNewGuidelinesZhenMoTa()	
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,43)
end

--����������ħ��
function NewGuidelinesMgr:doNewGuidelinesEnterZhenMoTa()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,44)
end

--�����򿪻���
function NewGuidelinesMgr:doNewGuidelinesClickActivity()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,47)
end

--�������������ͼ��
function NewGuidelinesMgr:doNewGuidelinesClickActivityHonorBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,48)
end

--�������뾺������ս
function NewGuidelinesMgr:doNewGuidelinesPKInArena()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,49)
end	

--����������
function NewGuidelinesMgr:doNewGuidelinesMainActivity(refId)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,70,refId)
end

--�������ʾ���
function NewGuidelinesMgr:doNewGuidelinesActivityTips()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,71)
end

--���������ٳ����
function NewGuidelinesMgr:doNewGuidelinesQuickUpLevel()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,72)
end

--����VIP�齱���
function NewGuidelinesMgr:doNewGuidelinesVipLuck()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,73)
end

--������ħ��NPC�Ի����
function NewGuidelinesMgr:doNewGuidelinesNpcTalk()
	local gameInstanceMgr = GameWorld.Instance:getGameInstanceManager()
	if not gameInstanceMgr:getIsInstanceFinished() then		
		return
	end
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,74)
end

--����7���¼���
function NewGuidelinesMgr:doNewGuidelinesSevenLogin()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,75)
end

--�����һ���������
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
		self:doNewGuidelinesHeroHead()--���ʹ��СħѪ���Ͻ�ͷ��ָ��
	elseif step == 47 then
		self:doNewGuidelinesClickActivity()--�����򿪻���
	elseif step == 64 then
		self:doNewGuidelinesOpenKnight()--��λ����ָ��
	elseif step == 42 then
		self:doNewGuidelinesOpenInstance()--�������ͼ��ָ��
	elseif step == 61 then
		self:doNewGuidelinesUpgradeMount()--��������ָ��
	elseif step == 63 then
		self:doNewGuidelinesUpgradeWing()--�������ָ��
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