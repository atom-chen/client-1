require ("gameevent.GameEvent")
require ("ui.UIManager")
require("ui.newGuidelines.WelcomeView")
require("ui.newGuidelines.NewGuidelinesView")
NewGuidelinesUIHandler = NewGuidelinesUIHandler or BaseClass(GameEventHandler)

function NewGuidelinesUIHandler:__init()
	self.saveIndex = 0
	self.newGuidelinesMgr = GameWorld.Instance:getNewGuidelinesMgr()	
	
	local eventOpenWelcomeView = function (arg)		
		UIManager.Instance:registerUI("WelcomeView",WelcomeView.create)
		UIManager.Instance:showUI("WelcomeView",E_ShowOption.eMiddle)	
	end					
	
	--响应打开窗口事件
	local function eventOnEnterView(name)
		self:onEnterView(name)
	end
	
	--响应关闭窗口事件
	local function eventOnExitView(name)
		self:onExitView(name)
	end
	
	--显示箭头
	local function eventDoNewGuidelinesByIndex(index,arg)
		self:showNewGuidelines(index,arg)
	end
	
	--响应点击事件
	local function eventDoNewGuidelinesByCilck(name,arg)
		self:doNewGuidelinesByCilck(name,arg)
	end
	
	local function eventHideArrow()
		self:hideArrow()
		self:resetStep()
	end
	GlobalEventSystem:Bind(GameEvent.EventOpenWelcomeView, eventOpenWelcomeView)	
	GlobalEventSystem:Bind(GameEvent.EventOnEnterView, eventOnEnterView)
	GlobalEventSystem:Bind(GameEvent.EventOnExitView, eventOnExitView)
	GlobalEventSystem:Bind(GameEvent.EventDoNewGuidelinesByIndex, eventDoNewGuidelinesByIndex)
	GlobalEventSystem:Bind(GameEvent.EventDoNewGuidelinesByCilck, eventDoNewGuidelinesByCilck)
	GlobalEventSystem:Bind(GameEvent.EventHideArrow, eventHideArrow)		
end

function NewGuidelinesUIHandler:__delete()

end


function NewGuidelinesUIHandler:showNewGuidelines(index,arg)
	if index==1  then--第一个任务指引
		local view = UIManager.Instance:getMainView()
		if view then
			local mainQuest = view:getQuest()
			if mainQuest then
				local node = mainQuest:getCellNode(0)	
				self:directToInstance(node,index,direction.left,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(-80,0))			
			end
		end
	elseif index==9 then
		--self.MainHeroHead:directToPKButton()
	elseif index==13 then--打开背包
		local view = UIManager.Instance:getMainView()
		if view then
			local mainMenu = view:getShowMenu()
			if mainMenu then
				local node = mainMenu:getBagBtn()	
				self:directToInstance(node,index,direction.down)
			end
		end
	elseif index==24 then--引导点击爵位
		local view =  UIManager.Instance:getViewByName("RoleView")
		if view then
			local bshow = UIManager.Instance:isShowing("RoleView")
			if bshow then
				local node = view:getKnightSubBtn()	
				self:directToInstance(node,index,direction.left)
			end
		end
	elseif index==36 then--点击左上角头像指引
		local view = UIManager.Instance:getMainView()
		if view then
			local mainHeroHead = view:getHeroHeadView()
			if mainHeroHead then
				local node = mainHeroHead:getHeroHeadNode()	
				self:directToInstance(node,index,direction.up,nil,ccp(0,-30))
			end
		end
	elseif index==37 then--使用小魔血石指引
		local view =  UIManager.Instance:getViewByName("BagView")
		if view then
			local bshow = UIManager.Instance:isShowing("BagView")
			if bshow then
				local gridView = view:getGridView()	
				local refId = "item_lixianmoxueshi"
				local itemNode,dindex = view:getItemNode(refId)
				if itemNode then
					local pageIndex, row, columu = gridView:getLayoutInfoByIndex(dindex)
					if pageIndex~=1 then
						gridView:setPageIndex(pageIndex)
					end	
					local dir = direction.up
					if row==5 then
						dir = direction.down
					end		
					self:directToInstance(itemNode:getRootNode(),index,dir)
				end	
			end
		end
	elseif index==39 then--引导点击药店中的指定道具
		local view =  UIManager.Instance:getViewByName("ShopView")
		if view then
			local bshow = UIManager.Instance:isShowing("ShopView")
			if bshow then
				local refId = "item_drug_2"
				local itemNode = view:getItemNode(refId)
				if itemNode then				
					self:directToInstance(itemNode,index,direction.left,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE)
				end	
			end
		end
	elseif index==53 then--引导点击日常任务刷新级别按钮
		local view =  UIManager.Instance:getViewByName("NpcQuestView")
		if view then
			local bshow = UIManager.Instance:isShowing("NpcQuestView")
			if bshow then
				local node = view:getBtnRefreshLevel()	
				self:directToInstance(node,index,direction.left)			
			end
		end	
	elseif index==56 then--坐骑进阶奖励
		local view = UIManager.Instance:getViewByName("MountView")
		if view then
			local bshow = UIManager.Instance:isShowing("MountView")
			if bshow then
				local node = view:getAwardBtn()	
				self:directToInstance(node,index,direction.left)			
			end
		end
	elseif index==55 then--引导打开等级礼包
		local view =  UIManager.Instance:getViewByName("BagView")
		if view then
			local bshow = UIManager.Instance:isShowing("BagView")
			if bshow then
				local hero = GameWorld.Instance:getEntityManager():getHero()
				local herolevel = PropertyDictionary:get_level(hero:getPT())	
				local professionId = PropertyDictionary:get_professionId(hero:getPT())
				
				local gridView = view:getGridView()
				self.saveLevelItemRefIdList = {}
				local count = herolevel/10
				for i=1,count do	
					local level = i*10
					local levelItemRefId = "item_gift_"..level.."_"..professionId
					table.insert(self.saveLevelItemRefIdList,levelItemRefId)
				end
				
				for i,v in pairs(self.saveLevelItemRefIdList) do
					local itemNode,dindex = view:getItemNode(v)
					if itemNode then
						local pageIndex, row, columu = gridView:getLayoutInfoByIndex(dindex)
						if pageIndex~=1 then
							gridView:setPageIndex(pageIndex)
						end	
						local dir = direction.up
						if row==5 then
							dir = direction.down
						end		
						self:directToInstance(itemNode:getRootNode(),index,dir)
						return
					end
				end
			end
		end
	elseif index==58 then--引导选择全体模式
		local view = UIManager.Instance:getMainView()
		if view then
			local mainHeroHead = view:getHeroHeadView()
			if mainHeroHead then
				local node = mainHeroHead:getHeroStatusBtn()	
				self:directToInstance(node,index,direction.up)
			end
		end
	elseif index==42 then
		local view = UIManager.Instance:getMainView()
		if view then
			local mainOtherMenu = view:getMainOtherMenu()
			if mainOtherMenu then
				local node = mainOtherMenu:getInstanceNode()	
				self:directToInstance(node,index,direction.up,LAYOUT_CENTER)			
			end
		end
	elseif index==43 then
		local view = UIManager.Instance:getViewByName("InstanceView")
		if view then 
			local bshow = UIManager.Instance:isShowing("InstanceView")
			if bshow then
				local node = view:getZhenMoTaTabNode()	
				self:directToInstance(node,index,direction.left,nil,ccp(30,0))			
			end
		end
	elseif index==44 then
		local view = UIManager.Instance:getViewByName("InstanceView")
		if view then
			local bshow = UIManager.Instance:isShowing("InstanceView")
			if bshow then
				local node = view:getZhenMoTaEnterBtn()	
				self:directToInstance(node,index,direction.up)			
			end
		end
	elseif index==47 then--引导打开活动面板
		local view = UIManager.Instance:getMainView()
		if view then
			local mainActivities = view:getMainActivities()
			if mainActivities then
				local node = mainActivities:getStaticBtn()	
				self:directToInstance(node,index,direction.up,LAYOUT_CENTER)			
			end
		end
	elseif index==48 then--引导点击竞技场图标
		local view = UIManager.Instance:getViewByName("ActivityManageView")
		if view then
			local bshow = UIManager.Instance:isShowing("ActivityManageView")
			if bshow then
				local node = view:getBtnByRefId("activity_manage_5")	
				self:directToInstance(node,index,direction.up)			
			end
		end
	elseif index==49 then--引导进入竞技场对战
		local view = UIManager.Instance:getViewByName("ArenaView")
		if view then
			local bshow = UIManager.Instance:isShowing("ArenaView")
			if bshow then
				local node = view:getChallengeTargetAreaBtnByIndex(1)	
				self:directToInstance(node,index,direction.up)			
			end
		end
	elseif index==59 then--引导点击普通攻击
		local view = UIManager.Instance:getMainView()
		if view then
			local attackSkillView = view:getAttackSkillView()
			if attackSkillView then
				local node = attackSkillView:getAttackBtn()	
				self:directToInstance(node,index,direction.down)
			end
		end
	elseif index==60 or index==61 then--坐骑解锁指引
		local view = UIManager.Instance:getMainView()
		if view then
			local mainMenu = view:getShowMenu()
			if mainMenu then
				local node = mainMenu:getMountBtn()	
				self:directToInstance(node,index,direction.down)
			end
		end
	elseif index==62 or index==63 then
		local view = UIManager.Instance:getMainView()
		if view then
			local mainMenu = view:getShowMenu()
			if mainMenu then
				local node = mainMenu:getWingBtn()	
				self:directToInstance(node,index,direction.down)
			end
		end
	elseif index==64  then--打开角色
		local view = UIManager.Instance:getMainView()
		if view then
			local mainMenu = view:getShowMenu()
			if mainMenu then
				local node = mainMenu:getRoleBtn()	
				self:directToInstance(node,index,direction.down)
			end
		end
	elseif index==65  then--爵位升级指引
		local view = UIManager.Instance:getViewByName("RoleView")
		if view then
			local bshow = UIManager.Instance:isShowing("RoleView")
			if bshow then
				local node = view:getUpgradeKnightBtn()	
				self:directToInstance(node,index,direction.left)			
			end
		end
	elseif index==66  then--点击坐骑升级按钮指引
		local view = UIManager.Instance:getViewByName("MountView")
		if view then
			local bshow = UIManager.Instance:isShowing("MountView")
			if bshow then
				local node = view:getAutoImproveBtn()	
				self:directToInstance(node,index,direction.down)			
			end
		end
	elseif index==67  then--点击翅膀升级按钮指引
		local view = UIManager.Instance:getViewByName("WingView")
		if view then
			local bshow = UIManager.Instance:isShowing("WingView")
			if bshow then
				local node = view:getAutoImproveBtn()	
				self:directToInstance(node,index,direction.down)			
			end
		end
	elseif index==68  then--引导选择全体模式
		local view = UIManager.Instance:getMainView()
		if view then
			local heroHeadView = view:getHeroHeadView()
			if heroHeadView then
				local node = heroHeadView:getHeroStateViewNode(E_HeroPKState.stateWhole)
				self:directToInstance(node,index,direction.left,nil,ccp(20,0))
			end
		end
	elseif index==69 then--引导法宝解锁引导
		local view = UIManager.Instance:getMainView()
		if view then
			local mainMenu = view:getShowMenu()
			if mainMenu then
				local node = mainMenu:getTalismanBtn()
				self:directToInstance(node,index,direction.down)
			end
		end
	elseif index==70 then--引导主活动面板
		local view = UIManager.Instance:getMainView()
		if view then
			local mainActivities = view:getMainActivities()
			if mainActivities then
				local node = mainActivities:getActivitiesBtn(arg)
				if node then
					self.whichActivity = arg
					self:directToInstance(node,index,direction.up,nil,ccp(0,-25))
				end
			end
		end
	elseif index==71 then--引导活动提示面板
		local view = UIManager.Instance:getViewByName("ActivityTips")
		if view then
			local bshow = UIManager.Instance:isShowing("ActivityTips")
			if bshow then
				local node = view:getEnterNode(self.whichActivity)	
				self:directToInstance(node,index,direction.left,nil,ccp(50,0))			
			end
		end
	elseif index==72 then--引导开服速冲面板
		local view = UIManager.Instance:getViewByName("QuickUpLevelView")
		if view then
			local bshow = UIManager.Instance:isShowing("QuickUpLevelView")
			if bshow then
				local node = view:getRewardNode()
				if node then
					self:directToInstance(node,index,direction.right,nil,ccp(280,140))			
				end
			end
		end
	elseif index==73 then--引导VIP抽奖面板
		local view = UIManager.Instance:getViewByName("VipLuckDraw")
		if view then
			local bshow = UIManager.Instance:isShowing("VipLuckDraw")
			if bshow then
				local node = view:getRewardTotalBtn()
				if node then
					self:directToInstance(node,index,direction.right,nil,ccp(-60,0))			
				end
			end
		end
	elseif index==74 then--引导下层镇魔塔面板
		local view = UIManager.Instance:getViewByName("NpcInstanceView")
		if view then
			local bshow = UIManager.Instance:isShowing("NpcInstanceView")
			if bshow then
				local node = view:getEnterNextBtn()
				if node then
					self:directToInstance(node,index,direction.left,nil,ccp(60,0))			
				end
			end
		end
	elseif index==75 then--引导7日登录面板
		local view = UIManager.Instance:getViewByName("SevenLoginAwardView")
		if view then
			local bshow = UIManager.Instance:isShowing("SevenLoginAwardView")
			if bshow then
				local node = view:getOpenServiceBtn()
				if node then
					self:directToInstance(node,index,direction.right,nil,ccp(-60,0))			
				end
			end
		end
	elseif index==76 then--引导使用魔血石
		local view = UIManager.Instance:getViewByName("NormalItemDetailView")
		if view then
			local bshow = UIManager.Instance:isShowing("NormalItemDetailView")
			if bshow then
				local node = view:getUseBtnNode()
				if node then
					self:directToInstance(node,index,direction.left,nil,ccp(60,0))			
				end
			end
		end
	elseif index==77 then--引导切换战斗UI
		local view = UIManager.Instance:getMainView()
		if view then
			local mainHeroHead = view:getHeroHeadView()
			if mainHeroHead then
				local node = mainHeroHead:getHeroHeadNode()	
				self:directToInstance(node,index,direction.up,nil,ccp(0,-30))
			end
		end
	---- 挂机技能设置新手指引（78~85）
	elseif index==78 then--引导点击头像
		local view = UIManager.Instance:getMainView()
		if view then
			local mainHeroHead = view:getHeroHeadView()
			if mainHeroHead then
				local node = mainHeroHead:getHeroHeadNode()	
				self:directToInstance(node,index,direction.up,nil,ccp(0,-30))
			end
		end
	elseif index==81 then--引导点击主菜单的技能
		local view = UIManager.Instance:getMainView()
		if view then
			local mainMenu = view:getShowMenu()
			if mainMenu then
				local node = mainMenu:getSkillBtn()
				self:directToInstance(node,index,direction.down)
			end
		end
	elseif index==82 then--引导点击快捷设置
		local view = UIManager.Instance:getViewByName("SkillView")
		if view then
			local quickSettingBtn = view:getQuickSettingBtn()
			if quickSettingBtn then
				self:directToInstance(quickSettingBtn,index,direction.left,nil,ccp(60,0))
			end
		end
	elseif index==84 then--引导点击挂机技能槽	
		local view = UIManager.Instance:getViewByName("QuickUpgradeView")	
		if self.guideFirstQuickSkillSolt and self.guideFirstQuickSkillSolt == true then
			if view then
				view:setIsNewGuide(true)								
				view:cancelAllSkill()

				local firstQuickSkillSolt = view:getFirstQuickSkillSolt()
				if firstQuickSkillSolt then
					self:directToInstance(firstQuickSkillSolt,index,direction.right,nil,ccp(-30,0))
					self.guideFirstQuickSkillSolt = nil
				end
			end
		end		
	elseif index==85 then
		local view =  UIManager.Instance:getViewByName("SkillView")
		if self.guideFirsthandupSkill and self.guideFirsthandupSkill == true then
			if view then
				local firstHandupSkillNode = view:getFirsetHandupSkillNode()
				if firstHandupSkillNode then
					self:directToInstance(firstHandupSkillNode,index,direction.up)
					self.guideFirsthandupSkill = nil
				end					
			end
		end
	elseif index==83 then--引导点击主菜单的设置
		local view = UIManager.Instance:getMainView()
		if view then
			local mainMenu = view:getShowMenu()
			if mainMenu then
				local node = mainMenu:getSettingBtn()
				self:directToInstance(node,index,direction.down)
			end
		end
	elseif index==79 then--引导点击挂机技能
		local view =  UIManager.Instance:getViewByName("SettingView")
		if view then
			local firstHandUpSkill = view:getFirstHandUpSkill()
			if firstHandUpSkill then
				self:directToInstance(firstHandUpSkill,index,direction.up,nil,ccp(-115,-20))
			end
		end	
	elseif index==80 then--引导点击挂机技能确定
		local view =  UIManager.Instance:getViewByName("SettingView")
		if view then
			local okBtn = view:getOKBtn()
			if okBtn then
				self:directToInstance(okBtn,index,direction.left,nil,ccp(60,0))
			end
		end	
	end	
end

function NewGuidelinesUIHandler:onEnterView(name)
	local step = self.newGuidelinesMgr:getSaveStep()
	if name=="BagView" and step==13 then--使用小魔血石指引				
		--self.newGuidelinesMgr:doNewGuidelinesUseXiaoMoXueShi()	
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,37)		
	elseif name=="InstanceView" and step==42 then			
		self.newGuidelinesMgr:doNewGuidelinesZhenMoTa()	
	elseif name=="ActivityManageView" and (step==47 or step==48)then	--打开活动面板		
		self.newGuidelinesMgr:doNewGuidelinesClickActivityHonorBtn()
	elseif name=="ArenaView" and (step==47 or step==48 or step==49) then	--打开天梯				
		self.newGuidelinesMgr:doNewGuidelinesPKInArena()	
	elseif name == "BatchSellView" and step == 55 then--打开出售界面时取消等级礼包指引
		self:hideArrow()
		self:resetStep()		
	elseif name=="RoleView" and (step==24 or step==64) then--引导点击爵位			
		self.newGuidelinesMgr:doNewGuidelinesClickKnight()
	elseif name=="MountView" then--坐骑升级指引
		if step==66 then
			self.newGuidelinesMgr:doNewGuidelinesClickUpgradeMountBtn()
		else
			--todu判断是否满足进阶领取条件
			--self.newGuidelinesMgr:doNewGuidelinesRideAward()
		end			
	elseif name=="WingView" and step==67 then--翅膀升级指引				
		self.newGuidelinesMgr:doNewGuidelinesClickUpgradeWingBtn()
	elseif name=="NpcQuestView"  then--日常任务刷星级	
		local view =  UIManager.Instance:getViewByName(name)
		if view then			
			local isShow = view:IsShowNewGuidelines()	
			if isShow then
				self.newGuidelinesMgr:doNewGuidelinesRefreshDailyQuestLevel()	
			end	
		end	
	elseif name == "ActivityTips" and step == 70 then
		local view =  UIManager.Instance:getViewByName(name)
		if view then			
			self.newGuidelinesMgr:doNewGuidelinesActivityTips()
		end	
	elseif name == "QuickUpLevelView" and step == 70 then
		local view =  UIManager.Instance:getViewByName(name)
		if view then			
			self.newGuidelinesMgr:doNewGuidelinesQuickUpLevel()
		end		
	elseif name == "VipLuckDraw" and step == 70 then
		local view =  UIManager.Instance:getViewByName(name)
		if view then			
			self.newGuidelinesMgr:doNewGuidelinesVipLuck()
		end	
	elseif name == "SevenLoginAwardView" and step == 74 then
		local view =  UIManager.Instance:getViewByName(name)
		if view then			
			self.newGuidelinesMgr:doNewGuidelinesSevenLogin()
		end
	elseif name == "NormalItemDetailView" and step == 37 then
		local view =  UIManager.Instance:getViewByName(name)
		if view then
			GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,76)
		end
		
	---- 挂机技能设置新手指引（78~85）
	elseif name == "SkillView" and step == 81 then
		self.guideFirsthandupSkill = true
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,85)
	elseif name == "QuickUpgradeView" and step == 82 then		
		self.guideFirstQuickSkillSolt = true
	elseif name == "SettingView" and step == 83 then
		local view =  UIManager.Instance:getViewByName(name)
		if view then
			view:selHandupView()
		end	
	end
end

function NewGuidelinesUIHandler:onExitView(name)
	local step = self.newGuidelinesMgr:getSaveStep()
	if (step == 37 and name=="BagView") or--使用小魔血石指引
		(step == 55 and name=="BagView") then--打开背包									
		self:hideArrow()
		self:resetStep()
	elseif (step == 24 and name=="RoleView")  then--关闭角色
		self:hideArrow()
	elseif (step == 48 and name=="ActivityManageView")  then--关闭活动面板
		self:hideArrow()
	elseif (step == 49 and name=="ArenaView")  then--关闭竞技场
		self:hideArrow()
	elseif (step == 65 and name=="RoleView")  then--关闭角色
		self:hideArrow()
		self:resetStep()
	elseif (step == 66 and name=="MountView")  then--关闭坐骑
		self:hideArrow()
	elseif (step == 56 and name=="MountView")  then--关闭坐骑
		self:hideArrow()
		self:resetStep()
	elseif (step == 67 and name=="WingView")  then--关闭翅膀
		self:hideArrow()
	elseif (step == 71 and name == "ActivityTips") then
		self:hideArrow()
		self:resetStep()
	elseif (step == 72 and name == "QuickUpLevelView") then
		self:hideArrow()
		self:resetStep()
	elseif (step == 73 and name == "VipLuckDraw") then
		self:hideArrow()
		self:resetStep()
	elseif (step == 74 and name == "NpcInstanceView") then
		self:hideArrow()
		self:resetStep()
	elseif (step == 75 and name == "SevenLoginAwardView") then
		self:hideArrow()
		self:resetStep()
	elseif (step == 76 and name == "NormalItemDetailView") then
		self:hideArrow()
	elseif (step == 76 and name == "BagView") then
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,77)
	
	---- 挂机技能设置新手指引（78~85）
	elseif (name == "SettingView") then
		self:hideArrow()
		self:resetStep()
	end
end

function NewGuidelinesUIHandler:doNewGuidelinesByCilck(name,arg)
	local step = self.newGuidelinesMgr:getSaveStep()
	if step==0 then
		return
	end			
	local bshow = UIManager.Instance:isShowing(name)
	
	if name =="MainQuest" and step==1 then
		self:hideArrow()
		self:resetStep()
	elseif name =="MainMenu" and step==13 and arg==MainMenu_Btn.Btn_bag then--点击菜单背包
		self:hideArrow()
	elseif name =="RoleView" and step==24 then--引导点击爵位
		--判断是否满足爵位升级的任务条件
		--tudo
		local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()	
		local questId = questMgr:getNewGuidelinesMainQuestId()
		local questObj = questMgr:getQuestObj(questId)
		local queststate = nil
		if questObj then
			queststate = questObj:getQuestState()
		end
		if questId=="quest_42" and queststate==QuestState.eAcceptedQuestState and arg~="upgradeKnightBtn" then
			self:hideArrow()
			self.newGuidelinesMgr:doNewGuidelinesUpgradeKnight()
		else
			self:hideArrow()
			self:resetStep()
		end	
	elseif name =="ActivityManageView" and step==48 then--引导活动面板天梯	
		self:hideArrow()
	elseif name =="RoleView" and step==65 then--引导点击爵位	
		self:hideArrow()
		self:resetStep()
	elseif name =="MainMenu" and step==64 and arg==MainMenu_Btn.Btn_role then--点击菜单角色
		self:hideArrow()
		--self:resetStep()
	elseif name=="MainHeroHead" and step==36 and arg=="heroHead" then--点击左上角头像指引
		self:hideArrow()
		self.newGuidelinesMgr:doNewGuidelinesOpenBag()
	elseif name=="MainHeroHead" and step==77 and arg=="heroHead" then--点击左上角头像指引
		self:hideArrow()
		self:resetStep()
	elseif bshow and name =="InstanceView" and step==43 then
		self:hideArrow()
		self:resetStep()
		self.newGuidelinesMgr:doNewGuidelinesEnterZhenMoTa()
	elseif bshow and name =="BagView" and step==37 then--使用小魔血石指引
		if arg=="item_lixianmoxueshi"  then
			self:hideArrow()
			self:resetStep()
		end
	elseif bshow and name =="ShopView" and step==39 then--引导点击药店中的指定道具 
		self:hideArrow()
		self:resetStep()		
	elseif name =="MainActivity" and step==47 then--引导打开活动面板 
		self:hideArrow()
	elseif name =="ArenaView" and step==49 then--引导进入竞技场对战 
		self:hideArrow()
		self:resetStep()
	elseif bshow and name =="BagView" and step==55 then--引导打开等级礼包 
		for i,v in pairs(self.saveLevelItemRefIdList) do
			if v==arg then
				self:hideArrow()
				self:resetStep()
				return
			end
		end
	elseif name=="MountView" and step==56 and arg=="AwardBtn" then--点击坐骑进阶奖励
		self:hideArrow()
		self:resetStep()
	elseif name=="MainAttackSkill" and step==59 and arg=="attackBtn" then--点击普通攻击
		self:hideArrow()	
		self:resetStep()
	elseif name=="MainHeroHead" and step==58 and arg=="heroStatusBtn" then--点击状态模式
		self:hideArrow()	
	elseif name =="MainMenu" and step==60 and arg==MainMenu_Btn.Btn_mount then--点击菜单坐骑
		self:hideArrow()
		self:resetStep()
	elseif name =="MainMenu" and step==61 and arg==MainMenu_Btn.Btn_mount then--点击菜单坐骑
		self:hideArrow()
		self.newGuidelinesMgr:doNewGuidelinesClickUpgradeMountBtn()
	elseif name =="MainMenu" and step==62 and arg==MainMenu_Btn.Btn_wing then--点击菜单翅膀
		self:hideArrow()
		self:resetStep()		
	elseif name =="MainMenu" and step==63 and arg==MainMenu_Btn.Btn_wing then--点击菜单翅膀
		self:hideArrow()
		self.newGuidelinesMgr:doNewGuidelinesClickUpgradeWingBtn()
	elseif name =="MountView" and step==66 and arg=="AutoImproveBtn" then--点击坐骑自动升级按钮
		self:hideArrow()
		self:resetStep()
	elseif name =="WingView" and step==67 and arg=="AutoImproveBtn" then--点击翅膀自动升级按钮
		self:hideArrow()
		self:resetStep()
	elseif name =="MainHeroHead" and step==68 and arg=="stateWhole" then--点击善恶状态
		self:hideArrow()
		self.newGuidelinesMgr:doNewGuidelinesClickAttackBtn()
	elseif name =="MainMenu" and step==69 and arg==MainMenu_Btn.Btn_talisman then--点击菜单翅膀
		self:hideArrow()
		self:resetStep()
	elseif name == "MainActivity" and step == 70 then
		self:hideArrow()
		if arg == "staticBtn" then
			self:resetStep()
		end
	elseif name == "ActivityTips" and step == 71 then
		self:hideArrow()
		self:resetStep()
	elseif name == "QuickUpLevelView" and step == 72 then
		self:hideArrow()
		self:resetStep()
	elseif name == "VipLuckDraw" and step == 73 then
		self:hideArrow()
		self:resetStep()
	elseif name == "NpcInstanceView" and step == 74 then
		self:hideArrow()	
	elseif name == "SevenLoginAwardView" and step == 75 then
		self:hideArrow()
		self:resetStep()

	---- 挂机技能设置新手指引（78~85）
	elseif name=="MainHeroHead" and step==78 and arg=="heroHead" then				--点击左上角头像指引
		self:hideArrow()
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,81)
	elseif name == "MainMenu" and step == 81 and arg==MainMenu_Btn.Btn_skill then	--点击主菜单技能指引
		self:hideArrow()
	elseif name == "SkillView" and step == 85 then									--点击第一个技能项指引
		self:hideArrow()
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,82)
	elseif name == "SkillView" and step == 82 then									--点击快捷设置指引
		self:hideArrow()
	elseif name == "QuickUpgradeView" and step == 84 then							--点击技能槽指引
		self:hideArrow()
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,83)
	elseif name == "MainMenu" and step == 83 and arg==MainMenu_Btn.Btn_setting then	--点击主菜单设置指引
		self:hideArrow()
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,79)
	elseif name == "SettingView" and step == 79 and arg=="firstHandUpSkill" then	--点击第一个挂机技能指引
		self:hideArrow()
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByIndex,80)	
	elseif name == "SettingView" and step == 80 and arg=="okBtn" then				--点击设置面板确定按钮指引
		self:hideArrow()
		self:resetStep()
	end			
end



function NewGuidelinesUIHandler:directToInstance(node,index,dir,layout,offset)
	if node and node:isVisible()==true then
		local parent = node:getParent()
		self:hideArrow()
		if not self.arrow then
			self.newGuidelinesMgr:setSaveStep(index)
			self.saveIndex = index
			local function callback()
				self:hideArrow()
				self:resetStep()
			end
			self.arrow = createArrow(dir,callback)		
			parent:addChild(self.arrow:getRootNode(),100)	
			
			local clayout = LAYOUT_CENTER
			if layout then
				clayout = layout
			end	
			if offset then
				VisibleRect:relativePosition(self.arrow:getRootNode(),node,clayout,offset)
			else
				VisibleRect:relativePosition(self.arrow:getRootNode(),node,clayout)
			end	
		end
	end
end	

function NewGuidelinesUIHandler:hideArrow()
	if self.arrow then
		self.arrow:DeleteMe()
		self.arrow = nil
	end
end

function NewGuidelinesUIHandler:resetStep()
	self.newGuidelinesMgr:setSaveStep(0)
	self.saveIndex = 0
end