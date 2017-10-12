require"data.scene.scene"
require"data.monster.monster"
require("data.quest.sectionQuest")
require("ui.Main.MainView.MainTeammateHead")
--require("object.Quest.QuestDef")

MainQuest = MainQuest or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()

function MainQuest:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(visibleSize)
	self.rootNode:setTouchEnabled(true)
	
	self.viewNode = CCLayer:create()
	self.viewNode:setContentSize(visibleSize)
	self.rootNode:addChild(self.viewNode)
	--VisibleRect:relativePosition(self.viewNode, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(0,62))
	VisibleRect:relativePosition(self.viewNode, self.rootNode, LAYOUT_CENTER)
	
	self.scale = VisibleRect:SFGetScale()
	self.showtable = true
	self.cellWidth = 240
	self.cellHeight = 55
	self.killMonsterInfo = {}
	self.collectItemInfo = {}	
	self.cellByIndex = {}
	self.instanceTime = nil
	self.rebackId = -1	
	self.isShow = true
	self.showWidth = 80
	self.flyTime = 5
	
	self:showTaskView()
	self:createTabView()
	self.tagView:setSelIndex(1)
	--self:crateAnimate()
end

function MainQuest:__delete()
	if self.MainTeammateHead then
		self.MainTeammateHead:DeleteMe()
		self.MainTeammateHead = nil
	end
end

function MainQuest:getRootNode()
	return self.rootNode
end

function MainQuest:getViewNode()
	return self.viewNode
end

function MainQuest:eventQuestshow(arg)
	self:show(arg)
	VisibleRect:relativePosition(self.viewNode, self.rootNode, LAYOUT_CENTER)
end

function MainQuest:eventQuestUpdate()
	self:getListInfo()
	self:reloadQuestData()	
end

function MainQuest:show(arg)
	if arg then
		local instanceId = self.questMgr:getInstanceRefId()
		if instanceId then
			self.tasktable:setClippingToBounds(true)
			self.tasktable:setBounceable(true)
			self.instanceTime = nil
		end
		self.viewBtn:setVisible(false)
	else		
		self.tasktable:setClippingToBounds(false)
		self.tasktable:setBounceable(false)
		local instanceId = self.questMgr:getInstanceRefId()
		if not instanceId then
			self.viewBtn:setVisible(true)
		end
		self:killChronography()
	end	
	self:getListInfo()	
	self:reloadQuestData()
end

function MainQuest:getTabView()
	return self.tagView
end

function MainQuest:reloadQuestData()
	self.tasktable:reloadData()
	VisibleRect:relativePosition(self.viewNode, self.rootNode, LAYOUT_CENTER)
end

function MainQuest:getShowList(questList)
	if (not questList) then
		return
	end
	local list = {}
	
	local isInstance = self.questMgr:getInstanceRefId()
	local questListSize = table.size(questList)
	local setIndex = 1
	if not isInstance then
		for i=1,questListSize do
			local questObj = questList[i]
			if questObj then
				local questTpye = questObj:getQuestType()
				if questTpye==QuestType.eQuestTypeMain then--第一行只显示主线任务或推荐挂机
					list[setIndex] = questList[i]
					setIndex = setIndex + 1
				else
					--强制除主线任务外都从第二行开始显示
					if setIndex == 1 then
						setIndex = 2
					end
					
					--强制第二行只显示日常任务
					if questTpye==QuestType.eQuestTypeDaily and list[2]==nil then
						list[setIndex] = questList[i]
						setIndex = setIndex + 1
					end		
				end
				
				if i==1 and list[1]==nil then
					list[1] = QuestRecommendHandup
				end
				
				--最多只显示3行内容
				if setIndex>3 then
					break
				end
			end	
		end
	else
		for i,v in pairs(questList) do
			if v:getQuestType() == QuestType.eQuestTypeInstance then
				table.insert(list,v)
			end														
		end	
	end
	
	return list
end	

function MainQuest:checkListRemoveHandupData(questList)
	if (not questList) then
		return
	end
	
	local list = {}
	local isHandupData = false
	local isDailtQuest = false
	local saveIndex = nil
	for i,v in pairs(questList) do
		local questType = v:getQuestType()
		local questState = v:getQuestState()
		
		if questType == QuestType.eQuestTypeMain and questState == QuestState.eVisiableQuestState then
			isHandupData = true
			saveIndex = i
		else 
			isHandupData = false
		end

		list[i] = questList[i]
	end		
	return list
end	

function MainQuest:getQuestTitleNameWord(questRefId)
	if (not questRefId) then
		return
	end
	
	local titleword = ""
	local subType = QuestRefObj:getStaticDailyQusetSubType(questRefId)
	if subType==DailyQuestSubType.eDailyQuest then
		titleword = Config.Words[3115]
	elseif subType==DailyQuestSubType.eGoldQuest then
		titleword = Config.Words[3152]
	elseif subType==DailyQuestSubType.eMeritQuest then
		titleword = Config.Words[3153]
	end
	return titleword
end

function MainQuest:getListInfo()
	--任务追踪
	local fontSize = FSIZE("Size1")
	self.listInfo = {}
	self.killMonsterInfo = {}
	self.monsterId = nil
	self.sceneId = nil
	self.questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local questList = self.questMgr:getQuestList()--获取任务列表
	self.showList = self:getShowList(questList)	
	if self.showList~=nil then
		local listSize = table.size(self.showList)
		if listSize>0 then
			for i,v in pairs(self.showList) do			
				local questTitleword = ""
				local questStateword = ""
				
				local questOrderword = ""
				local questOrderSize = 0
				local questTransferPos = nil
				local questTransferSceneRefid = nil
				
				
				local questObj = v
				if not questObj then
					return
				end
				
				if questObj==QuestRecommendHandup then
					questOrderword, questOrderSize,questTransferSceneRefid,questTransferPos = self:getRecommendHandupData()	
				else
					local questRefId = v:getQuestId()
					local questTypeValue = questObj:getQuestType()
					local instanceId = self.questMgr:getInstanceRefId()
					local questState =  questObj:getQuestState()
					local questNameValue = QuestRefObj:getStaticQusetPropertyQuestName(questTypeValue,questRefId,instanceId)
					if not questNameValue then
						return
					end
					
					--日常任务环数
					if questTypeValue==QuestType.eQuestTypeDaily then
						local nowRing = questObj:getDailyRing()
						local maxRing = QuestRefObj:getStaticDailyQusetMaxRing(questRefId)						
						if nowRing<=maxRing then
							questNameValue = questNameValue.."("..nowRing.."/"..maxRing..")"
						else 
							questNameValue = questNameValue.."("..Config.Words[3143]..")"
						end						
					end
					
					--任务名称					
					if questTypeValue==QuestType.eQuestTypeMain then--主线
						if  questState == QuestState.eVisiableQuestState then --任务不可见					
							questTitleword = string.wrapHyperLinkRich(Config.Words[3114]..questNameValue,Config.FontColor["ColorRed1"], fontSize,questRefId)
						else
							local title = string.wrapHyperLinkRich(Config.Words[3114],Config.FontColor["ColorBlue1"], fontSize,questRefId)
							questTitleword = string.wrapHyperLinkRich(title..questNameValue,Config.FontColor["ColorWhite1"], fontSize,questRefId)
						end	
					elseif  questTypeValue==QuestType.eQuestTypeDaily then--日常
						local word = self:getQuestTitleNameWord(questRefId)
						local title = string.wrapHyperLinkRich(word,Config.FontColor["ColorBlue1"], fontSize,questRefId)
						questTitleword = string.wrapHyperLinkRich(title..questNameValue,Config.FontColor["ColorWhite1"],  fontSize,questRefId)
					elseif  questTypeValue==QuestType.eQuestTypeInstance then--副本
						local title = string.wrapHyperLinkRich(Config.Words[3116],Config.FontColor["ColorBlue1"], fontSize,questRefId)
						questTitleword = string.wrapHyperLinkRich(title..questNameValue,Config.FontColor["ColorWhite1"], fontSize,questRefId)
					end					
					
					--任务目标				
					if  questState == QuestState.eUnvisiableQuestState then --任务不可见
					elseif questState == QuestState.eVisiableQuestState then --任务仅可见
						--推荐挂机
						local questLevel = QuestRefObj:getStaticQusetConditionFieldAcceptLevel(questTypeValue,questRefId)	
						local titleword = string.wrapHyperLinkRich("("..questLevel..Config.Words[328]..")",Config.FontColor["ColorWhite1"], fontSize,questRefId)
						questTitleword = questTitleword.."  "..titleword
						
						--local handupscene,handupPos = self:getRecommendHandupData()		
						
						questOrderword, questOrderSize,questTransferSceneRefid,questTransferPos = self:getRecommendHandupData()	
							
						
					elseif questState == QuestState.eAcceptableQuestState then --任务可接
						questStateword = string.wrapHyperLinkRich("("..Config.Words[3305]..")",Config.FontColor["ColorWhite1"],FSIZE("Size2"),questRefId)				
									
						local ScnceRefid = QuestRefObj:getStaticQusetNpcFieldSceneRefId(questTypeValue,questRefId,"acceptNpc")
						local NpcRefid = QuestRefObj:getStaticQusetNpcFieldNcRefId(questTypeValue,questRefId,"acceptNpc")
						
						local strSceneWord,sceneWordSize = G_QusetChangStringScnce(ScnceRefid,fontSize)
						local strNpcWord,npcWordSize = G_QusetChangStringNpc(NpcRefid,fontSize)
						if strSceneWord and strNpcWord then					
							questOrderword = " "..string.wrapHyperLinkRich(Config.Words[3308]..strSceneWord..Config.Words[3309]..strNpcWord,Config.FontColor["ColorWhite1"],fontSize,questRefId)
							questOrderSize = string.len(Config.Words[3308]..Config.Words[3309])+sceneWordSize+npcWordSize
						end
											
						local orderPos = G_getNPCPosByOrderRefidAndSceneRefid(NpcRefid,ScnceRefid)										
						questTransferSceneRefid = ScnceRefid
						questTransferPos = orderPos
					elseif questState == QuestState.eAcceptedQuestState then --任务已接，但未完成
						if questTypeValue==QuestType.eQuestTypeMain or  questTypeValue==QuestType.eQuestTypeInstance then--主线、副本
							local orderNumber =  questObj:getOrderNumber()
							if orderNumber ~= nil then
								for j=1,orderNumber do
									local orderType = QuestRefObj:getStaticQusetOrderFieldType(questTypeValue,questRefId,j,instanceId)
									local nowNumberValue =  questObj:getNumber(j)
									if orderType == QuestOrderType.eOrderTypeKill then --任务类型-杀怪
										local orderNumberValue = QuestRefObj:getStaticQusetOrderFieldKillCount(questTypeValue,questRefId,j,instanceId)
										if orderNumberValue>=nowNumberValue then--当前步骤未完成
											local monsterId = QuestRefObj:getStaticQusetOrderFieldMonsterRefId(questTypeValue,questRefId,j,instanceId)
											local sceneId = QuestRefObj:getStaticQusetOrderFieldSceneRefId(questTypeValue,questRefId,j,instanceId)
											self:setKillMonsterInfo(questTypeValue,questRefId,sceneId,monsterId)
											
											local monsterName = PropertyDictionary:get_name(GameData.Monster[monsterId]["property"])--怪物名称
											
											local norword = string.wrapHyperLinkRich(Config.Words[3301],Config.FontColor["ColorWhite1"],fontSize,questRefId)
											local monsterNameword = string.wrapHyperLinkRich(monsterName,Config.FontColor[QuestFontColor.order],fontSize,questRefId)
											local numberword = string.wrapHyperLinkRich("("..nowNumberValue.."/"..orderNumberValue..")",Config.FontColor["ColorWhite1"],fontSize,questRefId)
											questOrderword = " "..questOrderword..norword..monsterNameword..numberword
											questOrderSize = string.len(Config.Words[3301]..monsterName.."("..nowNumberValue.."/"..orderNumberValue..")")
											
											--[[self.questSystemTip = {}
											self.questSystemTip.norword = Config.Words[3301]
											self.questSystemTip.monsterName = monsterName
											self.questSystemTip.nowNumberValue = nowNumberValue
											self.questSystemTip.orderNumberValue = orderNumberValue--]]
											
											local orderPos = G_getMonsterPosByOrderRefidAndSceneRefid(monsterId,sceneId)										
											questTransferSceneRefid = sceneId
											questTransferPos = orderPos
											--break
										end
									elseif orderType == QuestOrderType.eOrderTypeCollection then --任务类型-采集物品
										local orderNumberValue = QuestRefObj:getStaticQusetOrderFieldItemCount(questTypeValue,questRefId,j,instanceId)
										if nowNumberValue > orderNumberValue then--当前步骤未完成
											nowNumberValue = orderNumberValue
										end
										if (orderNumberValue-nowNumberValue) == 1 then
--											GlobalEventSystem:Fire(GameEvent.EventAutoPluck,false)--提前告诉采集终止
										end
										
										local collectRefId = QuestRefObj:getStaticQusetOrderFieldItemNpcRefId(questTypeValue,questRefId,j,instanceId)
										local sceneId = QuestRefObj:getStaticQusetOrderFieldSceneRefId(questTypeValue,questRefId,j,instanceId)
										self:setCollectItemInfo(questTypeValue,questRefId,sceneId,collectRefId)
										local itemId = QuestRefObj:getStaticQusetOrderFieldItemRefId(questTypeValue,questRefId,j,instanceId)
										local itemName = G_getStaticPropsName(itemId)--物品名称
										local norword = string.wrapHyperLinkRich(Config.Words[3304],Config.FontColor["ColorWhite1"],fontSize,questRefId)
										local itemNameword = string.wrapHyperLinkRich(itemName,Config.FontColor[QuestFontColor.order],fontSize,questRefId)
										local numberword = string.wrapHyperLinkRich("("..nowNumberValue.."/"..orderNumberValue..")",Config.FontColor["ColorWhite1"],fontSize,questRefId)
										questOrderword = " "..questOrderword..norword..itemNameword..numberword
										questOrderSize = string.len(Config.Words[3304]..itemName.."("..nowNumberValue.."/"..orderNumberValue..")")
										
										local orderPos = G_getNPCPosByOrderRefidAndSceneRefid(collectRefId,sceneId)										
										questTransferSceneRefid = sceneId
										questTransferPos = orderPos											
									elseif orderType == QuestOrderType.eOrderTypeTime then --任务类型-限时任务
										local timeCount = questObj:getTime()
										local monsterRefId = QuestInstanceRefObj:getStaticQusetOrderFieldMonsterRefId(instanceId,questRefId,j)
										local killCount = QuestInstanceRefObj:getStaticQusetOrderFieldKillCount(instanceId,questRefId,j)
										local orderType , orderIndex = G_getQuestLogicMgr():getUpGradeInfo(QuestType.eQuestTypeMain,questRefId)
										
										local field = QuestRefObj:getStaticQusetOrderField(questTypeValue,questRefId)
										if field and orderIndex and orderIndex > 0 then
											
											local text = field[1].taskDescription	
											local pos = nil
											if text	then
												pos= string.find(text, "{")										
											end
											if pos then
												local subText = text
												while pos do
													local pos2 = string.find(subText, "}")
													local text1 = string.wrapHyperLinkRich(string.sub(subText, 0, pos-1), Config.FontColor["ColorWhite1"], fontSize)
													local text2 = string.wrapHyperLinkRich(string.sub(subText, pos+1, pos2-1), Config.FontColor["ColorGreen1"], fontSize)
													subText = string.sub(subText, pos2+1)
													pos = string.find(subText, "{")
													if not pos then													
														local text3 = string.wrapHyperLinkRich(subText, Config.FontColor["ColorWhite1"], fontSize)
														questOrderword = questOrderword .. text1 .. text2 .. text3
														break
													end														
													questOrderword = questOrderword .. text1 .. text2 
												end
																								
												if not questOrderword then
													questOrderword = " "
												end
												questOrderSize = string.len(text)
											else
												questOrderword = QuestRefObj:getStaticMainQusetDescription(questRefId)
												if not questOrderword then
													questOrderword = " "
												end
												questOrderSize = string.len(questOrderword)
											end
											
											local npcRefId = field[1].npcRefId
											local sceneId = field[1].sceneRefId
											if npcRefId and sceneId then
												local orderPos = G_getNPCPosByOrderRefidAndSceneRefid(npcRefId,sceneId)										
												questTransferSceneRefid = sceneId
												questTransferPos = orderPos	
											end																						
										else		
											if self.instanceTime==nil then
												self.instanceTime = timeCount
												self:chronography()
											end
													
											if timeCount~=nil and killCount~=nil and monsterRefId~=nil then--winbossOrder在多长时间内，杀死Boss
												local monsterName = PropertyDictionary:get_name(GameData.Monster[monsterRefId]["property"])--怪物名称
												local showTime = self:getQuestTimeWord(self.instanceTime)																								
												if showTime then
													local monsterNameword = string.wrapHyperLinkRich(monsterName,Config.FontColor[QuestFontColor.order],fontSize,questRefId)
													local showTimeword = string.wrapHyperLinkRich(showTime,Config.FontColor["ColorRed1"],fontSize,questRefId)
													questOrderword = " "..questOrderword..Config.Words[3136]..showTimeword..Config.Words[3301]..killCount..Config.Words[3137]..monsterNameword
													questOrderSize = string.len(Config.Words[3136]..showTime..Config.Words[3301]..killCount..Config.Words[3137]..monsterName)
													-- MainQuest:setKillMonsterInfo(questType,questId,sceneRefId,monsterRefId)													
													local sceneId = QuestRefObj:getStaticQusetOrderFieldSceneRefId(questTypeValue,questRefId,j,instanceId)
													self:setKillMonsterInfo( questTypeValue,questRefId,sceneId, monsterRefId)
												else
													questOrderword = Config.Words[3140]
													questOrderSize = string.len(Config.Words[3140])
												end
												
											elseif timeCount~=nil and killCount~=nil and monsterRefId==nil then--winOrder在多长时间内，杀死所有怪通关
											elseif timeCount~=nil and killCount==nil and monsterRefId==nil then--survivalOrder存活多长时间
											end
										end
									end
								end
							end
						elseif  questTypeValue==QuestType.eQuestTypeDaily then--日常
							local randomOrder = questObj:getRandomOrderType()
							local orderType = QuestRefObj:getStaticQusetOrderFieldType(questTypeValue,questRefId,randomOrder,instanceId)
							local orderNumberValue = QuestRefObj:getStaticQusetOrderFieldKillCount(questTypeValue,questRefId,randomOrder,instanceId)
							local nowNumberValue =  questObj:getNumber(randomOrder)
							local bOverOrder = false
							local nowRing = questObj:getDailyRing()
							local maxRing = QuestRefObj:getStaticDailyQusetMaxRing(questRefId)								
							if nowRing>maxRing then--判断是否在推荐环外
								bOverOrder =true
								orderNumberValue = QuestRefObj:getStaticDailyQusetOverOrderFieldKillCount(questTypeValue,questRefId,randomOrder,instanceId)
							end
							if orderType == QuestOrderType.eOrderTypeKill then --任务类型-杀怪							
								local function getDailyOrderInfo(bOverOrder,questTypeValue,questRefId,randomOrder)
									local monsterId
									local sceneId
									if bOverOrder then--推荐环外的杀怪数据
										monsterId = QuestRefObj:getStaticDailyQusetOverOrderFieldMonsterRefId(questTypeValue,questRefId,randomOrder)
										sceneId = QuestRefObj:getStaticDailyQusetOverOrderFieldSceneRefId(questTypeValue,questRefId,randomOrder)
									else--推荐环内杀怪数据
										monsterId = QuestRefObj:getStaticQusetOrderFieldMonsterRefId(questTypeValue,questRefId,randomOrder)
										sceneId = QuestRefObj:getStaticQusetOrderFieldSceneRefId(questTypeValue,questRefId,randomOrder)
									end
									return monsterId,sceneId
								end
								local monsterId,sceneId = getDailyOrderInfo(bOverOrder,questTypeValue,questRefId,randomOrder)
								self:setKillMonsterInfo(questTypeValue,questRefId,sceneId,monsterId)
								
								local monsterName = PropertyDictionary:get_name(GameData.Monster[monsterId]["property"])--怪物名称
								
								local norword = string.wrapHyperLinkRich(Config.Words[3301],Config.FontColor["ColorWhite1"],fontSize,questRefId)
								local monsterNameword = string.wrapHyperLinkRich(monsterName,Config.FontColor[QuestFontColor.order],fontSize,questRefId)
								local numberword = string.wrapHyperLinkRich("("..nowNumberValue.."/"..orderNumberValue..")",Config.FontColor["ColorWhite1"],fontSize,questRefId)
								questOrderword = " "..questOrderword..norword..monsterNameword..numberword
								questOrderSize = string.len(Config.Words[3301]..monsterName.."("..nowNumberValue.."/"..orderNumberValue..")")
								
								local orderPos = G_getMonsterPosByOrderRefidAndSceneRefid(monsterId,sceneId)										
								questTransferSceneRefid = sceneId
								questTransferPos = orderPos
									--break	
							elseif orderType == QuestOrderType.eOrderTypeCollection then --任务类型-采集
								local orderNumberValue = QuestRefObj:getStaticQusetOrderFieldItemCount(questTypeValue,questRefId,randomOrder,instanceId)
								if orderNumberValue>= nowNumberValue then--当前步骤未完成
									if (orderNumberValue-nowNumberValue) == 1 then
	--									GlobalEventSystem:Fire(GameEvent.EventAutoPluck,false)--提前告诉采集终止
									end
											
									local collectRefId = QuestRefObj:getStaticQusetOrderFieldItemNpcRefId(questTypeValue,questRefId,randomOrder,instanceId)
									local sceneId = QuestRefObj:getStaticQusetOrderFieldSceneRefId(questTypeValue,questRefId,randomOrder,instanceId)
									self:setCollectItemInfo(questTypeValue,questRefId,sceneId,collectRefId)
									local itemId = QuestRefObj:getStaticQusetOrderFieldItemRefId(questTypeValue,questRefId,randomOrder,instanceId)
									local itemName = G_getStaticPropsName(itemId)--物品名称
									local norword = string.wrapHyperLinkRich(Config.Words[3304],Config.FontColor["ColorWhite1"],fontSize,questRefId)
									local itemNameword = string.wrapHyperLinkRich(itemName,Config.FontColor[QuestFontColor.order],fontSize,questRefId)
									local numberword = string.wrapHyperLinkRich("("..nowNumberValue.."/"..orderNumberValue..")",Config.FontColor["ColorWhite1"],fontSize,questRefId)
									questOrderword = " "..questOrderword..norword..itemNameword..numberword
									questOrderSize = string.len(Config.Words[3304]..itemName.."("..nowNumberValue.."/"..orderNumberValue..")")
									
									local orderPos = G_getNPCPosByOrderRefidAndSceneRefid(collectRefId,sceneId)										
									questTransferSceneRefid = sceneId
									questTransferPos = orderPos
								end
							end	
						end
					elseif questState == QuestState.eSubmittableQuestState then --任务已经可提交。但还没提交
						questStateword = string.wrapHyperLinkRich("("..Config.Words[3300]..")",Config.FontColor["ColorGreen2"],FSIZE("Size2"),questObj:getQuestId())
						
						local sceneWord	= QuestRefObj:getStaticQusetNpcFieldSceneRefId(questTypeValue,questRefId,"submitNpc")
						local strSceneWord,sceneWordSize
						local strNpcWord,npcWordSize 
						if sceneWord then
							strSceneWord,sceneWordSize = G_QusetChangStringScnce(sceneWord,fontSize)
						end	
						local npcWord = QuestRefObj:getStaticQusetNpcFieldNcRefId(questTypeValue,questRefId,"submitNpc")
						if npcWord then
							strNpcWord,npcWordSize = G_QusetChangStringNpc(npcWord,fontSize)
						end						
						
						if strSceneWord and strNpcWord then	
							questOrderword = " "..string.wrapHyperLinkRich(Config.Words[3308]..strSceneWord..Config.Words[3309]..strNpcWord,Config.FontColor["ColorWhite1"],fontSize,questObj:getQuestId())
							questOrderSize = string.len(Config.Words[3308]..Config.Words[3309])+sceneWordSize+npcWordSize
							
							local orderPos = G_getNPCPosByOrderRefidAndSceneRefid(npcWord,sceneWord)										
							questTransferSceneRefid = sceneWord
							questTransferPos = orderPos
						else
							if questTypeValue==QuestType.eQuestTypeMain then
							questOrderword = " "..string.wrapHyperLinkRich(Config.Words[3315],Config.FontColor["ColorWhite1"],fontSize,questObj:getQuestId())
							questOrderSize = string.len(Config.Words[3315])
							end	
						end							
						
						if questTypeValue==QuestType.eQuestTypeInstance then--副本
							local monsterId = QuestRefObj:getStaticQusetOrderFieldMonsterRefId(questTypeValue,questRefId,1,instanceId)
							local orderNumberValue = QuestRefObj:getStaticQusetOrderFieldKillCount(questTypeValue,questRefId,1,instanceId)
							local monsterName = PropertyDictionary:get_name(GameData.Monster[monsterId]["property"])--怪物名称
							
							local norword = string.wrapHyperLinkRich(Config.Words[3301],Config.FontColor["ColorWhite1"],fontSize,questRefId)
							local monsterNameword = string.wrapHyperLinkRich(monsterName,Config.FontColor[QuestFontColor.order],fontSize,questRefId)
							local numberword = string.wrapHyperLinkRich("("..Config.Words[3127]..")",Config.FontColor["ColorWhite1"],fontSize,questRefId)
							questOrderword = " "..questOrderword..norword..monsterNameword..numberword
							questOrderSize = string.len(Config.Words[3301]..monsterName.."("..Config.Words[3127]..")")
						end
					end	
				end
				
				table.insert(self.listInfo,{
					iquestTitleword = questTitleword,
					iquestStateword = questStateword,
					iquestOrderword = questOrderword,
					iquestOrderSize = questOrderSize,
					questTransferSceneRefid = questTransferSceneRefid,
					questTransferPos = questTransferPos,
					})
			end	
		end
	end	
end

function MainQuest:getRecommendHandupData()
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local level = PropertyDictionary:get_level(hero:getPT())
	local handupscene = recommendHandupRefObj:getStaticScene(level)
	local handupPos = recommendHandupRefObj:getStaticPos(level)
	
	local handupsceneName = ""
	if  GameData.Scene[handupscene] then
		handupsceneName = GameData.Scene[handupscene]["property"]["name"]	
	else
		CCLuaLog("Error:getRecommendHandupData() is  error,Scene:"..handupscene.."not find")
	end
		 				
	local questOrderword =  string.wrapHyperLinkRich(Config.Words[3101]..handupsceneName,Config.FontColor[QuestFontColor.order],fontSize)	
	local questOrderSize = string.len(Config.Words[3101]..handupsceneName	)			
		
	return questOrderword,questOrderSize,handupscene,handupPos
end

--倒计时
function MainQuest:chronography()
	if self.reBackCountDownFunction == nil then
		self.reBackCountDownFunction = function ()
			if self.instanceTime==0 then
				self:killChronography()
				return
			end
			if self.instanceTime then
				self.instanceTime = self.instanceTime - 1
				self:eventQuestUpdate()
			end
		end
	end
	self.rebackId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.reBackCountDownFunction,1, false)
end

function MainQuest:killChronography()
	if self.rebackId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackId)
		self.rebackId = -1
	end
end

function MainQuest:getQuestTimeWord(time)
	if time and time>=0 then
		local outTime = nil
		if time>=60 then
			outTime = tostring(math.floor(time/60)+1)
			outTime = outTime..Config.Words[3138]
		elseif time<60 and time>=1 then
			outTime = tostring(time)
			outTime = outTime..Config.Words[3139]
		end
		return outTime
	end
end

function MainQuest:setKillMonsterInfo(questType,questId,sceneRefId,monsterRefId)
	if (not questType) or (not questId) then
		return
	end
	
	local list = {tquestType = questType,tquestId = questId,tsceneRefId = sceneRefId,tmonsterRefId = monsterRefId}
	table.insert(self.killMonsterInfo,list)
end

function MainQuest:getKillMonsterInfo(questType,questId)
	if (not questType) or (not questId) then
		return
	end
	
	for i,v in pairs(self.killMonsterInfo) do
		local lquestType = v.tquestType
		local lquestId = v.tquestId
		local lsceneRefId = v.tsceneRefId
		local lmonsterRefId = v.tmonsterRefId
		
		if lquestType==questType and lquestId==questId then
			if lquestId==questId then
				return lmonsterRefId,lsceneRefId
			end
		end
	end
end

function MainQuest:setCollectItemInfo(questType,questId,sceneRefId,collectRefId)
	if (not questType) or (not questId) then
		return
	end
	
	local list = {tquestType = questType,tquestId = questId,tsceneRefId = sceneRefId,tcollectRefId = collectRefId}
	table.insert(self.collectItemInfo,list)
end

function MainQuest:getCollectItemInfo(questType,questId)
	if (not questType) or (not questId) then
		return
	end
	
	for i,v in pairs(self.collectItemInfo) do
		local lquestType = v.tquestType
		local lquestId = v.tquestId
		local lsceneRefId = v.tsceneRefId
		local lcollectRefId = v.tcollectRefId
		
		if lquestType==questType and lquestId==questId then
			if lquestId==questId then
				return lcollectRefId,lsceneRefId
			end
		end
	end
end



function MainQuest:getTableSize()
	local tableHeight = 3 * self.cellHeight
	local tableSize = CCSizeMake(self.cellWidth, tableHeight)
	return tableSize
end

function MainQuest:showTaskView()
	--[[
	if self.tasktable then
		self.tasktable:reloadData()
		self.tasktable:scroll2Cell(0, false)
		return
	end
	--]]
	self.questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local tablesize = self:getTableSize()
	if self.cellNode then
		--self.cellNode:removeAllChildrenWithCleanup(true)
		self.cellNode:removeFromParentAndCleanup(true)
		self.cellNode = nil
		self.titleBg = nil
	end
	self.cellNode =  CCNode:create()
	self.cellNode:setContentSize(tablesize)	
	self.viewNode:addChild(self.cellNode)
	local instanceId = self.questMgr:getInstanceRefId()
	self.cellNode:setPosition(ccp(0, 0))	
	if self.isShow then
		VisibleRect:relativePosition(self.cellNode,self.viewNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE ,ccp(0,-220))
	else
		VisibleRect:relativePosition(self.cellNode,self.viewNode, LAYOUT_LEFT_OUTSIDE + LAYOUT_TOP_INSIDE ,ccp(-self.showWidth,-220))
	end
	
	--定义
	local	kTableCellSizeForIndex = 0
	local	kCellSizeForTable = 1
	local	kTableCellAtIndex = 2
	local	kNumberOfCellsInTableView = 3
	
	local cellSize = CCSizeMake(self.cellWidth,self.cellHeight)
	
	local dataHandlerfunc = function(eventType,tableP,index,data)
		tableP = tolua.cast(tableP,"SFTableView")
		data = tolua.cast(data,"SFTableData")
		if eventType == kTableCellSizeForIndex then
			data:setSize(cellSize)
			return 1
		elseif eventType == kCellSizeForTable then
			data:setSize(cellSize)
			return 1
		elseif eventType == kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)
			
			if not tableCell then
				local cell = SFTableViewCell:create()
				cell:setContentSize(cellSize)
				cell:setIndex(index)
				self:showView(cell,index)
				self.cellByIndex[index] = cell
				data:setCell(cell)
			else
				local childCount = tableCell:getChildrenCount()			
				if childCount > 0 then
					tableCell:removeAllChildrenWithCleanup(true)
				end													
				tableCell:setContentSize(cellSize)
				self:showView(tableCell,index)
				self.cellByIndex[index] = tableCell
				data:setCell(tableCell)
			end
			
			return 1
		elseif eventType == kNumberOfCellsInTableView then
			local questListCount = table.size(self.listInfo)
			data:setIndex(questListCount)
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")		
		local dindex = cell:getIndex()+1
		self:clickCell(dindex)		
	end
	
	self.tasktable = createTableView(dataHandlerfunc,tablesize)
	self.tasktable:setTableViewHandler(tableDelegate)
	--self.tasktable:setClippingToBounds(false)
	self.cellNode:addChild(self.tasktable)
	VisibleRect:relativePosition(self.tasktable,self.cellNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(0,-1))	
	self.tasktable:reloadData()
	self.tasktable:scroll2Cell(0, false)
	if not instanceId then
		self.tasktable:setClippingToBounds(false)
		self.tasktable:setBounceable(false)				
	end
	self:showQuestViewBtn()
end


function MainQuest:clickCell(dindex,newGuide)
	if (not dindex) then
		return
	end
	
	self:newGuidelinesClickCell(dindex)
	local questList = self.showList
	local questObj = questList[dindex]
	if not questObj then
		return
	end				
	
	if questObj~=QuestRecommendHandup then	
		local questId = questObj:getQuestId()
		local questType = questObj:getQuestType()
		local questState = questObj:getQuestState()
		local monsterId,msceneId = self:getKillMonsterInfo(questType,questId)
		local collectId,csceneId = self:getCollectItemInfo(questType,questId)
		local orderType , orderIndex = G_getQuestLogicMgr():getUpGradeInfo(questType,questId)
				
		if questType==QuestType.eQuestTypeMain or questType==QuestType.eQuestTypeDaily then--主线任务--日常任务
			local bShow =  UIManager.Instance:isShowing("NpcQuestView")
			if questState==QuestState.eVisiableQuestState  then
				self:doRecommendHandup() 
			elseif questState==QuestState.eAcceptedQuestState and msceneId~=nil and monsterId~=nil then --未完成任务，要杀怪	
				self:setHeroMoveStop()							
				G_getQuestLogicMgr():AutoPathFindMonster(monsterId,msceneId)--自动寻怪
			elseif questState==QuestState.eAcceptedQuestState and csceneId~=nil and collectId~=nil then --未完成任务，要采集
				G_getQuestLogicMgr():AutoCollectItem(collectId,csceneId)--自动寻采集物
			elseif questState==QuestState.eAcceptedQuestState and orderType == 9 then
				if orderIndex == QuestOrderEventType.eTransferInstanceEvent then
					local pkInstanceId = G_getQuestLogicMgr():getInstanceTransInfo(QuestType.eQuestTypeMain , questId)
					self.questMgr:requestInstanceTrans(questId, pkInstanceId)
				else	
					G_getQuestLogicMgr():handOrderEvent(orderIndex, questId, questType)
				end
			else
				if bShow and questType==QuestType.eQuestTypeMain then--点击主线任务响应接交消息
					if questState == QuestState.eAcceptableQuestState then--可接
						self.questMgr:requestAcceptQuest(questId)--发送接收消息
					elseif questState == QuestState.eSubmittableQuestState then--可提交
						self.questMgr:requestSubmitQuest(questId)--发送提交消息
					end
					UIManager.Instance:hideUI("NpcQuestView")
				else					
					self:setHeroMoveStop()
					G_getQuestLogicMgr():AutoPathFindNpc(questId)--自动寻路
				end
			end
			self:setMainQuestCilckInfo(questId,questState)	
		elseif questType==QuestType.eQuestTypeInstance then--副本任务
			--[[if questState==QuestState.eAcceptedQuestState and monsterId~=nil then --未完成任务，要杀怪、采集
				--G_getQuestLogicMgr():AutoPathFindMonster(monsterId)--自动寻怪--副本暂不自动寻怪
				--自动挂机
				local instanceRefId = G_getQuestMgr():getInstanceRefId()
				if not GameData.AllIns_PK[instanceRefId] then
					G_getHandupMgr():start(E_AutoSelectTargetMode.Normal, {EntityType.EntityType_Monster}, {}, nil, nil, E_SearchTargetMode.Random)
				end							
			end--]]
			local insMgr = GameWorld.Instance:getGameInstanceManager()
			if insMgr:getIsInstanceFinished() then
				local instanceRefId = G_getQuestMgr():getInstanceRefId()
				if instanceRefId == "Ins_6" then
					insMgr:setFinishInstanceArrow("remove")
					return
				end
				insMgr:requestShowQuestReward()
				self:removeFinishInstanceArrow()
			else
				local instanceRefId = G_getQuestMgr():getInstanceRefId()
				if not GameData.AllIns_PK[instanceRefId] then
					G_getHandupMgr():start(E_AutoSelectTargetMode.Normal, {EntityType.EntityType_Monster}, {}, nil, nil, E_SearchTargetMode.Random)
				end
			end
		end			
	else
		self:doRecommendHandup() 
	end
	
	--if not newGuide then
	local listInfo = self.listInfo[dindex]	
	local transferSceneRefid = listInfo.questTransferSceneRefid
	local transferPos = listInfo.questTransferPos	
	if transferSceneRefid and transferPos then
		local cell = self.cellByIndex[dindex-1]
		if questObj~=QuestRecommendHandup then	
			local questId = questObj:getQuestId()
			self:updateFlyinShoes(transferSceneRefid,transferPos,cell,questId,newGuide)
		else
			self:updateFlyinShoes(transferSceneRefid,transferPos,cell,QuestRecommendHandup,newGuide)
		end
	end
end

function MainQuest:setHeroMoveStop()
	local hero = G_getHero()
	if not hero:isMoving() then
		hero:moveStop()
	end	
end

function MainQuest:setMainQuestCilckInfo(questId,questState)
	self.saveClickquestId = questId
	self.saveClickquestState = questState
end

function MainQuest:updateFlyinShoesTime(time)
	if time and self.flyButton and self.flyButtonLable and self.flyButtonLable.setString then
		self.flyButton:setVisible(true)
		self.flyButtonLable:setString(time)
	else
		--self.flyButton:setVisible(false)
	end
end

function MainQuest:setFlyinShoesVisible(bShow)	
	self.flyButton:setVisible(bShow)
end


function MainQuest:doRecommendHandup()
	local handupword,handupSize,handupscene,handupPos = self:getRecommendHandupData()	
	G_getQuestLogicMgr():AutoRecommendHandup(handupscene,handupPos)
end

function MainQuest:showView(cell,index)
	if (not cell) or (not index) then
		return
	end
	
	local questList = self.showList
	
	if (questList[index+1]==nil)  then
		return
	end		
	local wordPosX = 0
	local listInfo = self.listInfo[index+1]
	local title = listInfo.iquestTitleword
	local state = listInfo.iquestStateword
	local order = listInfo.iquestOrderword
	local orderSize = listInfo.iquestOrderSize	
	local transferSceneRefid = listInfo.questTransferSceneRefid
	local transferPos = listInfo.questTransferPos	
	
	local btnline = createScale9SpriteWithFrameName(RES("main_questLine.png"))	
	cell:addChild(btnline)
	VisibleRect:relativePosition(btnline,cell,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER,ccp(-10,-4))	
	
	local questObj =  questList[index+1]
	if not questObj then
		return
	end
	
	local questId = nil
	local questState = nil
	if questObj == QuestRecommendHandup then
		questId = QuestRecommendHandup
	else
		questId = questObj:getQuestId()
		questState = questObj:getQuestState()
	end	
	
	self:updateTransferInfo(questId,transferSceneRefid,transferPos)
	
	--任务名称	
	local questTitle = createRichLabel(CCSizeMake(cell:getContentSize().width,10))	
	questTitle:appendFormatText(title)
	cell:addChild(questTitle)
	VisibleRect:relativePosition(questTitle,cell,LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  , CCPointMake(wordPosX,-12))
	
	--任务目标
	if order~="" then
		local minusWidth = 0
		local addHeight = 0
		if orderSize>=42 then
			minusWidth = 20
			addHeight = 10
		end
		
		local questOrder = createRichLabel(CCSizeMake(cell:getContentSize().width-minusWidth,10))

		questOrder:appendFormatText(order)
		cell:addChild(questOrder)
		VisibleRect:relativePosition(questOrder,cell,LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  , CCPointMake(wordPosX+2,-36-addHeight))
	end	

--[[	if self.questSystemTip then
		local msg = {[1] = {word = Config.Words[3301], color = Config.FontColor["ColorWhite1"]},
					[2] = {word = self.questSystemTip.monsterName, color = Config.FontColor["ColorGreen1"]},
					[3] = {word = "("..tostring(self.questSystemTip.nowNumberValue).."/"..tostring(self.questSystemTip.orderNumberValue)..")", color = Config.FontColor["ColorWhite1"]}}
		UIManager.Instance:showSystemTips(msg)
	end--]]
		
	self:showAnimate(cell,index+1,questState)		
end

function MainQuest:updateTransferInfo(questId,transferSceneRefid,transferPos)
	if not questId or not transferSceneRefid or not transferPos then
		return
	end
	
	if questId == self.oldflySavequestid then
		if self.flyButton and  self.flyButton:isVisible()==true then
			self.savetransferSceneRefid = transferSceneRefid
			self.savetransferPos = transferPos
		end
	end
end

--创建飞鞋按钮
function MainQuest:updateFlyinShoes(transferSceneRefid,transferPos,cell,questId,newGuide)
	if (not transferSceneRefid) or (not transferPos) or (not cell) or (not questId) then
		return
	end
	
	if not self.flyButton  then
		self.flyButton = createButtonWithFramename(RES("map_shoes.png"))
		if not self.flyButton then
			return
		end
		self.flyButton:setScaleDef(1.3)
		self.flyButton:setOpacityDef(150)
		self.tasktable:addChild(self.flyButton)	
		
		local flyToFunction = function ()
			local gameMapManager = GameWorld.Instance:getMapManager()
			local ret, reason = gameMapManager:checkCanUseFlyShoes(true)
			if ret then
				if self.savetransferSceneRefid and self.savetransferPos then
					gameMapManager:requestTransfer(self.savetransferSceneRefid, self.savetransferPos.x,self.savetransferPos.y,1)
				end
				G_getHandupMgr():stop(false)
				
				self.flyButton:setVisible(false)
				G_getQuestLogicMgr():setFlyinShoesTimer(nil)
			elseif reason ~= CanNotFlyReason.CastleWar then
				UIManager.Instance:showSystemTips(Config.Words[13021])
			end
			
		end
		self.flyButton:addTargetWithActionForControlEvents(flyToFunction,CCControlEventTouchDown)
	end	
	VisibleRect:relativePosition(self.flyButton,cell,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(0,0))	
	
	self.savetransferSceneRefid = transferSceneRefid
	self.savetransferPos = transferPos
		
	
		
	if questId~=self.oldflySavequestid or newGuide then
		self.flyButton:setVisible(true)		
	else
		if self.flyButton:isVisible()==true then
			self.flyButton:setVisible(false)			
		else
			self.flyButton:setVisible(true)
		end
	end
	self.oldflySavequestid = questId
		
	local time = self.flyTime
	if self.flyButton:isVisible()==true then
		G_getQuestLogicMgr():setFlyinShoesTimer(time)
	else
		G_getQuestLogicMgr():setFlyinShoesTimer(nil)
	end
		
	if not self.flyButtonLable then
		self.flyButtonLable = createLabelWithStringFontSizeColorAndDimension(time,"Arial",FSIZE("Size2"),FCOLOR("ColorWhite1"))
		self.flyButton:addChild(self.flyButtonLable )
		VisibleRect:relativePosition(self.flyButtonLable ,self.flyButton,LAYOUT_CENTER,ccp(0,0))
	else
		self.flyButtonLable:setString(time)
	end	
end

function MainQuest:showAnimate(cell,index,questState)
	if (not cell) or (not index) or (not questState) then
		return
	end
	
	if questState == QuestState.eSubmittableQuestState then
		self:crateAnimate(cell,index)
	end
end

function MainQuest:crateAnimate(cell,index)
	if (not cell) or (not index) then
		return
	end
	
	--帧动画
	if self.tasktable then	
		if index then
			local animate = createAnimate("questframe",6,0.175)
			local framesprite = CCSprite:create()
			local forever = CCRepeatForever:create(animate)
			framesprite:runAction(forever)
			framesprite:setScaleX(1.32)
			framesprite:setScaleY(0.9)
			cell:addChild(framesprite)
			VisibleRect:relativePosition(framesprite, cell, LAYOUT_CENTER, ccp(-10,0))	
		end	
	end
end	

function MainQuest:showQuestViewBtn()
--[[	do
		return
	end--]]
	--if self.tasktable then
		local instanceId = self.questMgr:getInstanceRefId()
--[[		if self.titleBg then
			self.titleBg:removeFromParentAndCleanup(true)
			self.titleBg = nil
		end--]]
		local size = table.size(self.showList)
		self.btnQuest = createScale9SpriteWithFrameName(RES("main_questListBackground.png"))--背景
		self.btnQuest:setContentSize(CCSizeMake(self.cellWidth,self.cellHeight*3))
		self.viewNode:addChild(self.btnQuest,-1)
		VisibleRect:relativePosition(self.btnQuest,self.cellNode,LAYOUT_CENTER + LAYOUT_TOP_INSIDE, ccp(0,0))
--[[		--按钮背景
		self.titleBg = createScale9SpriteWithFrameName(RES("main_questCurrentBackground.png"))
		self.titleBg :setContentSize(CCSizeMake(165,30))
		self.cellNode:addChild(self.titleBg )
		VisibleRect:relativePosition(self.titleBg , self.cellNode, LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_OUTSIDE, ccp(-5,5))--]]
		--按钮
		self.viewBtn = createButtonWithFramename(RES("main_questHead.png"))
		--viewBtn:setOpacityDef(150)
		--viewBtn:setScaleDef(0.9)
		self.viewNode:addChild(self.viewBtn ,20)
		if instanceId then
			self.viewBtn:setVisible(false)
		end
		VisibleRect:relativePosition(self.viewBtn ,self.cellNode ,  LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_OUTSIDE,ccp(18,0) )
		
		--VisibleRect:relativePosition(viewBtn, self.cellNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_OUTSIDE, ccp(5,0))
		--文字
--[[		local word = createSpriteWithFrameName(RES("word_label_questlist.png.png"))	
		word:setOpacity(150)
		word:setScale(0.8)
		viewBtn:addChild(word)
		VisibleRect:relativePosition(word,viewBtn,LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE,ccp(0,5))--]]
		
		local BT_viewBtnfunc = function ()
			GlobalEventSystem:Fire(GameEvent.EVENT_Quest_UI)
		end
		self.viewBtn :addTargetWithActionForControlEvents(BT_viewBtnfunc,CCControlEventTouchDown)
		
		--缩进按钮
			
		local hideBtnfunc = function ()
			self:setViewHideOrShow(false)
		end
		if not self.hideBtn then
			self.hideBtn = createButtonWithFramename(RES("main_questcontraction.png"))				
			self.rootNode :addChild(self.hideBtn,20)
			self.hideBtn:setTouchAreaDelta(0, 10)
			VisibleRect:relativePosition(self.hideBtn,self.rootNode ,  LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,-178) )	
			self.hideBtn:addTargetWithActionForControlEvents(hideBtnfunc,CCControlEventTouchDown)
		end		
		
		--显示按钮
		local showBtnfunc = function ()
			self:setViewHideOrShow(true)
		end
		
		if not self.showBtn then
			self.showBtn = createButtonWithFramename(RES("main_questcontraction.png"))
			self.showBtn:setRotation(180)
			self.rootNode :addChild(self.showBtn,20)
			self.showBtn:setVisible(false)
			VisibleRect:relativePosition(self.showBtn,self.rootNode ,  LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,-178) )
			self.showBtn:addTargetWithActionForControlEvents(showBtnfunc,CCControlEventTouchDown)
		end
	--end
end

function MainQuest:setViewHideOrShow(bShow)
	if self.showBtn and self.hideBtn then
		if self.showBtn:isVisible() == true and bShow==true then
			self.showBtn:setVisible(false)
			self.hideBtn:setVisible(true)
			self:showMainQuestView()
		elseif self.showBtn:isVisible() == false and bShow==false then
			self.hideBtn:setVisible(false)
			self.showBtn:setVisible(true)			
			self:hideMainQuestView()
		end
	end
end

function MainQuest:getListquestInfo()
	local questListCount = table.size(self.showList)
	local questtype = nil
	local queststate = nil
	if questListCount==1 then
		for i,v in pairs(self.showList) do
			questtype = v:getQuestType()
			queststate = v:getQuestState()
		end
	end
	return questtype,queststate
end

function MainQuest:hideMainQuestView()	
	local deleteMyself = function ()
		self.viewNode:setVisible(false)
	end
	local ccfunc = CCCallFuncN:create(deleteMyself)
	local actionArray = CCArray:create()	
	local moveTo = CCMoveTo:create(cont_UIMoveSpeed, ccp(-self.cellWidth - self.showWidth,self.viewNode:getPositionY())	)
	actionArray:addObject(moveTo)	
	actionArray:addObject(ccfunc)
	local sequence = CCSequence:create(actionArray)		
	self.viewNode:runAction(sequence)
	self.isShow = false
end

function MainQuest:showMainQuestView()
	local moveTo = CCMoveTo:create(cont_UIMoveSpeed, ccp(0 ,self.viewNode:getPositionY()))
	self.viewNode:setVisible(true)
	self.viewNode:runAction(moveTo)
	self.isShow = true
end


--点击事件
function MainQuest:doNewGuidelinesByClickMainQuest()
	local index = 0
	local cell = self:getCellNode(index)
	if cell then
		self:clickCell(index+1,"NewGuide")
	end
end	
----------------------------------------------------------------------
--新手指引

function MainQuest:getCellNode(index)
	if (not index) then
		return
	end
	
	if self.tasktable then
		if self.tasktable:cellAtIndex(index) then
			local cell = self.tasktable:cellAtIndex(index)
			return cell
		end
	end
end		

function MainQuest:newGuidelinesClickCell(index)
	if index==1 then
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"MainQuest")	
	end
end	

function MainQuest:createTabView()
	local createContent = {	
		[1] = Config.Words[25506],
		[2] = Config.Words[25507],
	}
	local btnArray = CCArray:create()
	
	local buttonTeam = createButtonWithFramename(RES("tab_4_normal.png"), RES("tab_4_select.png"))			
	buttonTeam:setTitleString(createSpriteWithFrameName(RES("mainteamtext.png")))
	btnArray:addObject(buttonTeam)
	local onTabTeamPress = function()
		--UIManager.Instance:showSystemTips(Config.Words[25525])	
		self:showNode(1)
	end
	buttonTeam:addTargetWithActionForControlEvents(onTabTeamPress, CCControlEventTouchDown)	
	
	local normalSpr = createScale9SpriteWithFrameName(RES("tab_4_normal.png"))
	normalSpr:setRotation(180)
	local selSpr =  createScale9SpriteWithFrameName(RES("tab_4_select.png"))
	selSpr:setRotation(180)
	local buttonQuest = createButton(normalSpr,selSpr)			
	buttonQuest:setTitleString(createSpriteWithFrameName(RES("mainquesttext.png")))
	btnArray:addObject(buttonQuest)
	local onTabQuestPress = function()
		self:showNode(2)
	end
	buttonQuest:addTargetWithActionForControlEvents(onTabQuestPress, CCControlEventTouchDown)			
	
	self.tagView = createTabView(btnArray, -10, tab_horizontal)	
	self.viewNode:addChild(self.tagView)
	VisibleRect:relativePosition(self.tagView,self.viewNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE ,ccp(30,-185))
end

function MainQuest:UpdateTeammateHead()
	if not self.MainTeammateHead then
		self.MainTeammateHead = MainTeammateHead.New()		
		self.rootNode:addChild(self.MainTeammateHead:getRootNode())
		self.MainTeammateHead:getRootNode():setVisible(false)	
		VisibleRect:relativePosition(self.MainTeammateHead:getRootNode(),self.cellNode,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(10,-10))
	end
	if self.MainTeammateHead and self.MainTeammateHead:getRootNode():isVisible() then
		self.MainTeammateHead:updateTeam()
	end		
end

function MainQuest:showNode(key)
	if key == 1 then
		self.cellNode:setVisible(false)
		if self.MainTeammateHead then
			self.MainTeammateHead:updateTeam()
			self.MainTeammateHead:getRootNode():setVisible(true)
		end
	else
		self.cellNode:setVisible(true)
		if self.MainTeammateHead then
			self.MainTeammateHead:getRootNode():setVisible(false)	
		end
	end
end

function MainQuest:showFinishInstanceArrow()
	if self.arrow then
		self:removeFinishInstanceArrow()
	end
	local callback = function()
		self:removeFinishInstanceArrow()
	end
	self.arrow = createArrow(direction.left,callback)		
	self.tagView:addChild(self.arrow:getRootNode(),100)
	VisibleRect:relativePosition(self.arrow:getRootNode(),self.tagView,LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE,ccp(-30,-40))
end

function MainQuest:removeFinishInstanceArrow()
	if self.arrow then
		self.arrow:getRootNode():removeFromParentAndCleanup(true)
		self.arrow:DeleteMe()
		self.arrow = nil
	end
end
