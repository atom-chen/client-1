require("data.strong.strong")
require("data.strong.upgradePower")
require("data.monster.monster")
StrongerMgr = StrongerMgr or BaseClass()

--self.readyList[channel][refId] = func  
--@ self.readyList 保存请求服务器的数据 channel为内容种类，refId为每个Cell且是唯一的，func为回调

--self.countDownRefIdList[refId] = time、func  保存倒计时数据 每个refId保存对应的时间和回调

function StrongerMgr:__init()
	self.muneList = {}
	self.readyList = {}
	self.countDownRefIdList = {}
	self:clear()
end

function StrongerMgr:clear()
	self:stopCountDown()
end

function StrongerMgr:__delete()

end

--获取菜单列表
function StrongerMgr:getMuneList()
	if table.isEmpty(self.muneList) then
		local list = self:getStaticData_Mune()
		if type(list)=="table" then
			for i,v in pairs(list) do
				self.muneList[v.sort] = i
			end
		end
	end
	return self.muneList
end	

--获取菜单名
function StrongerMgr:getMuneName(refId)
	if not refId then
		return nil
	end
	local data = GameData.Strong["menu"]
	if data.configData then
		if data.configData[refId] then
			return data.configData[refId].name
		end
	end
	return nil
end	

function StrongerMgr:getContentList(optionRefId)
	if not optionRefId then
		return
	end
	local data = GameData.Strong.menu.configData[optionRefId]
	if not data then
		return
	end
	return data.contentList
end	

--获取静态数据菜单Icon
function StrongerMgr:getMenuIconByRefId(refId)
	if not refId then
		return
	end
	local data = GameData.Strong["menu"]
	if data and data.configData then
		local record = data.configData[refId]
		if  record then
			return record.iconId
		end
	end
	return nil
end	

	
--获取静态数据菜单--（不在外部调用）
function StrongerMgr:getStaticData_Mune()
	local data = GameData.Strong["menu"]
	if data.configData then
		return data.configData
	end
	return nil
end	

--获取材料数据--（不在外部调用）
function StrongerMgr:getStaticData_MaterialData(refId)
	if not refId then
		return nil
	end
	local data = GameData.Strong["material"]
	if not data then
		return
	end
	if not data.configData then
		return
	end
	
	return data.configData[refId]
end

--获取材料图标
function StrongerMgr:getStaticData_MaterialIcon(refId)
	if not refId then
		return nil
	end
	local data = self:getStaticData_MaterialData(refId)
	if not data then
		return
	end
	return data.iconId
end

--获取材料渠道
function StrongerMgr:getStaticData_MaterialChannel(refId)
	if not refId then
		return nil
	end
	local data = self:getStaticData_MaterialData(refId)
	if not data then
		return
	end
	return data.channel
end

--获取材料内容
function StrongerMgr:getStaticData_MaterialContent(refId)
	if not refId then
		return nil
	end
	local data = self:getStaticData_MaterialData(refId)
	if not data then
		return
	end
	return data.content
end	

--获取材料图片读取方式
function StrongerMgr:getIconMaterialWay(refId)
	if not refId then
		return nil
	end
	local data = self:getStaticData_MaterialData(refId)
	if not data then
		return
	end
	return data.iconWay
end

--获取材料图片缩放值
function StrongerMgr:getIconMaterialScale(refId)
	if not refId then
		return nil
	end
	local data = self:getStaticData_MaterialData(refId)
	if not data then
		return
	end
	if not data.iconScale then
		return
	end
	return data.iconScale/100
end

--todo 由于竞技场数据下发后就打开界面，因此要判断是否在数据请求中
function StrongerMgr:canOpenVewByStronger()
	if not self.readyList[StrongerChannel.Arena] then
		return true
	end
	return false
end

function StrongerMgr:requestSeverData(refId,readyFunc,registFunc)
	if not refId or type(readyFunc)~="function" or type(registFunc)~="function" then
		return
	end
	
	local channel = self:getStaticData_MaterialChannel(refId)
	if channel==StrongerChannel.ZhengMoTa or channel==StrongerChannel.Instance then
		if self:checkCanRequest(refId) then	
			GameWorld.Instance:getGameInstanceManager():requestGameInstanceList()
		end		
		self:registReadyCallBack(refId,registFunc)
		readyFunc(false)
	elseif channel==StrongerChannel.Boss then
		if self:checkCanRequest(refId) then	
			G_getHero():getWorldBossMgr():requestWorldBoss()
		end		
		self:registReadyCallBack(refId,registFunc)
		readyFunc(false)
	elseif channel==StrongerChannel.Arena then
		local arenaMgr = GameWorld.Instance:getArenaMgr()
	
		local openLevel =  arenaMgr:getOpenLevel()
		local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
		if heroLevel >= openLevel then
			if self:checkCanRequest(refId) then
				GameWorld.Instance:getArenaMgr():requestShowArenaView()	
			end
			self:registReadyCallBack(refId,registFunc)
			readyFunc(false)
		else
			readyFunc(true)
		end
	else
		readyFunc(true)
	end
end

function StrongerMgr:registReadyCallBack(refId,func)
	if not refId or type(func)~="function" then
		return
	end
	local channel = self:getStaticData_MaterialChannel(refId)
	
	local channelList = self.readyList[channel]
	if not channelList then
		channelList = {}
	end	
	channelList[refId] = func
	self.readyList[channel] = channelList	
end

function StrongerMgr:setReady(chan)
	if not chan then
		return
	end		
	
	local channelList = self.readyList[chan]
	if not channelList then
		return
	end
	
	for refId,func in pairs(channelList) do
		if func then
			func()
		end
	end
	
	self.readyList[chan] = nil
end

function StrongerMgr:checkCanRequest(refId)
	if not refId then
		return false
	end
	
	local channel = self:getStaticData_MaterialChannel(refId)
	
	if self.readyList[channel] then
		return false
	end
	
	return true
end

function StrongerMgr:clearReadyCallBackByRefId(refId)
	if not refId then
		return false
	end
	
	local channel = self:getStaticData_MaterialChannel(refId)	
	if not self.readyList[channel] then
		return
	end
	
	if not self.readyList[channel][refId] then
		return
	end
	
	self.readyList[channel][refId] = nil
end

function StrongerMgr:clearReadyCallBack()
	self.readyList = {}
end

--根据 战斗力 和 类型 获取提升的需要程度 返回值： 1 急需提升   2 有待提升  3完美提升   
function StrongerMgr:getRequireImproveLevel(fightValue , ttype)
	local level = PropertyDictionary:get_level(G_getHero():getPT())
	local record = GameData.UpgradePower[level]
	local state = 1
	if fightValue == 0 then
		return state
	end
	if record then
		local data 
		if ttype == 1 then		
			data = record.equipItem	
		elseif ttype == 2 then
			data = record.equipStrengthening	
		elseif ttype == 3 then
			data = record.equipWash			
		elseif ttype == 4 then
			data = record.ride			
		elseif ttype == 5 then
			data = record.wing			
		elseif ttype == 6 then
			data = record.talisman			
		elseif ttype == 7 then
			data = record.citta			
		elseif ttype == 8 then
			data = record.knight			
		end
		state = self:caculateState(data,fightValue)
	end
	return state
end	

function StrongerMgr:caculateState(sectionStr,fightVale)
	if type(sectionStr)~="string" or  type(fightVale)~="number"  then
		return 1
	end
	
	local  subStrList = string.split(sectionStr, "|")	
	for k ,v in pairs(subStrList) do
		local sectionIndex = string.match(v,"(%d+)")
		local sectionData = string.match(v,"%b()")
		local low = string.match(sectionData,"(%d+)")
		local high = string.match(sectionData,"-(%d+)")		
		if not high then
			high = fightVale + 1
		end
		if  fightVale >= tonumber(low) and fightVale <= tonumber(high) then
			return  sectionIndex
		end
	end
	return 1
end


function StrongerMgr:getNeedStrongLinkMenu(strongRefId)
	local strongData = GameData.Strong["strong"]
	local configData = strongData.configData
	if  configData and configData[strongRefId] then
		return configData[strongRefId].linkMenu
	end
end

function StrongerMgr:getNeedStrongBtTextByRefId(strongRefId)
	local strongData = GameData.Strong["strong"]
	local configData = strongData.configData
	if  configData and configData[strongRefId] then
		return configData[strongRefId].btText
	end
end

function StrongerMgr:getNeedStrongTitleIconAndTypeAndScaleByRefId(strongRefId)
	local strongData = GameData.Strong["strong"]
	local configData = strongData.configData
	if  configData and configData[strongRefId] then
		return configData[strongRefId].iconId,configData[strongRefId].iconWay , configData[strongRefId].iconScale
	end
end

function StrongerMgr:getWorldBossRefreshTime(refId,monsterRefId,sceneRefId)
	local time = self:getCountDownRefIdByTime(refId)
	if not time then
		time = G_getHero():getWorldBossMgr():getRefreshTimeByBoss(monsterRefId,sceneRefId)		
	end
	local timeWord = G_getHero():getWorldBossMgr():getTimeword(time)
	return timeWord
end

function StrongerMgr:getRecomandedInstanceRefId()
	local data = GameData.Strong["material"]
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	local tempLevel = 0
	local tempRefId = ""
	if  data and data.configData then	
		for k,v in pairs(data.configData) do
			if v.channel == StrongerChannel.Instance then
				local insRefId = v.content.insId
				local instanceManager = GameWorld.Instance:getGameInstanceManager()
				local obj = instanceManager:getGameInstanceObj(insRefId)				
				if obj and  obj:getOpenLevel() <= heroLevel and obj:getCountInDay()> 0 and  obj:getRefId() ~= "Ins_6" then
					if obj:getOpenLevel() >= tempLevel then
						tempLevel = obj:getOpenLevel()
						tempRefId = obj:getRefId()
					end	
				end						
			end
		end
	end
	return tempRefId	
end

function StrongerMgr:getRecomandedMapRefId(channel)
	local data = GameData.Strong["material"]
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	local tempLevel = 0
	local tempRefId = ""
	if  data and data.configData then	
		for k,v in pairs(data.configData) do
			if v.channel == channel then
				local monsterId = v.content.monsterId[1]
				local targetData = GameData.Monster[monsterId]
				local property = targetData["property"]
				local openLevel = PropertyDictionary:get_level(property)
				if heroLevel>= openLevel  then
					if openLevel > tempLevel then
						tempLevel = openLevel
						tempRefId = v.content.sceneId	
					end
				end						
			end
		end
	end
	return tempRefId	
end	

function StrongerMgr:getRecomandedHandupMapRefId()
	local data = GameData.Strong["material"]
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	local tempLevel = 0
	local tempRefId = ""
	if  data and data.configData then	
		for k,v in pairs(data.configData) do
			if v.channel == StrongerChannel.HandUpPoint then
				local sceneId = v.content.sceneId
				local targetData = GameData.Scene[sceneId]
				local property = targetData["property"]
				local openLevel = PropertyDictionary:get_openLevel(property)
				if heroLevel>= openLevel  then
					if openLevel > tempLevel then
						tempLevel = openLevel
						tempRefId = sceneId	
					end
				end						
			end
		end
	end
	return tempRefId	
end


--根据refId  获取是否要推荐
function StrongerMgr:getCelllRecomandedState(refId)
	local channel = self:getStaticData_MaterialChannel(refId)
	local content = self:getStaticData_MaterialContent(refId)
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	if channel == StrongerChannel.DailyQuest then --日常任务

		local questId = content.questId	
		if questId then
			local questAcceptLevel = QuestRefObj:getStaticQusetConditionFieldAcceptLevel(QuestType.eQuestTypeDaily,questId)
			if 	heroLevel >= questAcceptLevel then
				local questObj = G_getQuestMgr():getQuestObj(questId) 
				if questObj then
					local nowRin = questObj:getDailyRing() --任务当前环数
					local maxRing = QuestRefObj:getStaticDailyQusetMaxRing(questObj:getQuestId())--任务最大环数
					if nowRin <= maxRing then
						return true
					end
				end
			end
		end	
	elseif channel== StrongerChannel.ZhengMoTa then--镇魔塔
		local insRefid = content.insId
		if  insRefid then
			local instanceManager = GameWorld.Instance:getGameInstanceManager()
			local obj = instanceManager:getGameInstanceObj(insRefid)
			if obj and obj:getCountInDay() > 0 and heroLevel >= obj:getOpenLevel() then
				return true	
			end
		end
	elseif channel== StrongerChannel.Instance then--副本
		local insRefId = content.insId
		if self:getRecomandedInstanceRefId() == insRefId then
			return true
		end
	elseif channel== StrongerChannel.Arena then	--竞技场	
		local arenaObject = GameWorld.Instance:getArenaMgr():getArenaObject()
		if arenaObject then
			local leftCount =  arenaObject:getLeftChallengeCnt()
			if  leftCount and leftCount > 0 then
				return true
			end
		end
	elseif channel== StrongerChannel.Mining then--挖矿
		if  GameWorld.Instance:getMiningMgr():getMiningOpenState() and heroLevel >= 40 then
			return true
		end
	elseif channel== StrongerChannel.monstInvasion then
		local archiveLv = GameData.MonsterInvasion["monsterInvasion1"].activityData["monsterInvasion1"].property.level	
		if heroLevel >= archiveLv and G_getHero():getMonstorInvasionMgr():isStart() then
			return true
		end
	elseif channel== StrongerChannel.Boss then--世界BOSS
		local targetMapRefId = content.sceneId
		if targetMapRefId == self:getRecomandedMapRefId(channel) then
			return true	
		end		
	elseif channel== StrongerChannel.eliteMonster  then--世界BOSS
		local targetMapRefId = content.sceneId
		if targetMapRefId == self:getRecomandedMapRefId(channel) then
			return true	
		end				
	elseif channel== StrongerChannel.HandUpPoint then--黄金挂机点
		local targetMapRefId = content.sceneId	
		if targetMapRefId == self:getRecomandedHandupMapRefId() then
			return true	
		end
	end
	return false
end

--根据refId  获取富文本描述
function StrongerMgr:getCelllDescStrByRefId(refId)
	local channel = self:getStaticData_MaterialChannel(refId)
	local content = self:getStaticData_MaterialContent(refId)
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	
	local richText = ""
	if channel == StrongerChannel.DailyQuest then --日常任务
		local questId = content.questId
		
		if questId then
			local questAcceptLevel = QuestRefObj:getStaticQusetConditionFieldAcceptLevel(QuestType.eQuestTypeDaily,questId)			
			local questName = 	QuestRefObj:getStaticQusetPropertyQuestName(QuestType.eQuestTypeDaily,questId)	
			local maxRing = QuestRefObj:getStaticDailyQusetMaxRing(questId)--任务最大环数
			local word = G_getHero():getQuestMgr():getQuestTitleNameWord(questId)		
			local title = string.wrapHyperLinkRich(word,Config.FontColor["ColorBlue1"], FSIZE("Size3"),questId) 
			local numberword
		    if 	heroLevel >= questAcceptLevel then				
				local questObj = G_getQuestMgr():getQuestObj(questId)
				local nowRin = 0
				if questObj then
					nowRin = questObj:getDailyRing() --任务当前环数	
					if nowRin> maxRing then
						numberword = string.wrapHyperLinkRich("("..Config.Words[3143]..")",Config.FontColor["ColorWhite1"],FSIZE("Size3"))		
					else
						numberword = string.wrapHyperLinkRich("("..nowRin.."/"..maxRing..")",Config.FontColor["ColorWhite1"],FSIZE("Size3"))
					end
				else
					numberword = string.wrapHyperLinkRich("("..Config.Words[3317]..")",Config.FontColor["ColorGreen1"],FSIZE("Size3"))		
				end				
			else	
				local str = string.format(Config.Words[3316],questAcceptLevel)
				numberword = string.wrapHyperLinkRich("("..str..")",Config.FontColor["ColorRed1"],FSIZE("Size3"))	
			end								
			richText = string.wrapHyperLinkRich(title..questName .. numberword,Config.FontColor["ColorWhite1"],FSIZE("Size3"),questId)
		end	
	elseif channel== StrongerChannel.ZhengMoTa then--镇魔塔
		local insRefid = content.insId
		if  insRefid then
			local instanceManager = GameWorld.Instance:getGameInstanceManager()
			local obj = instanceManager:getGameInstanceObj(insRefid)
			if obj then		
				local  title = string.wrapHyperLinkRich(obj:getInstanceName(),Config.FontColor["ColorBlue1"], FSIZE("Size3"),questId)
				local level = string.wrapHyperLinkRich(obj:getOpenLevel(),Config.FontColor["ColorWhite1"], FSIZE("Size3"),questId)
				
				local restTimes 
				if  heroLevel >= obj:getOpenLevel() then	
					restTimes = Config.Words[26023] .. obj:getCountInDay()
				else
					restTimes = " "
				end	
				richText = string.wrapHyperLinkRich(title .. "     Lv" .. level .. "      " .. restTimes,Config.FontColor["ColorWhite1"], FSIZE("Size3"),questId)
			end
		end	
	elseif channel== StrongerChannel.Instance  then--副本
		local insRefid = content.insId
		if  insRefid then
			local instanceManager = GameWorld.Instance:getGameInstanceManager()
			local obj = instanceManager:getGameInstanceObj(insRefid)
			if obj then		
				local  title = string.wrapHyperLinkRich(obj:getInstanceName(),Config.FontColor["ColorBlue1"], FSIZE("Size3"),questId)
				local suggestlevel = string.wrapHyperLinkRich(obj:getSuggestlevel(),Config.FontColor["ColorWhite1"], FSIZE("Size3"),questId)
				local restTimes = Config.Words[26023] .. obj:getCountInDay()
				richText = string.wrapHyperLinkRich(title .. "     Lv" .. suggestlevel .. "      " .. restTimes,Config.FontColor["ColorWhite1"], FSIZE("Size3"),questId)
			end
		end	
	elseif channel== StrongerChannel.Arena then	--竞技场	
		local arenaObject = GameWorld.Instance:getArenaMgr():getArenaObject()
		if arenaObject then
			local leftCount =  arenaObject:getLeftChallengeCnt()
			if not leftCount then
				leftCount = 0
			end	
			local  title = string.wrapHyperLinkRich(Config.Words[26024],Config.FontColor["ColorBlue1"], FSIZE("Size3"))	
			richText = string.wrapHyperLinkRich(title .. "      " .. Config.Words[26023] .. leftCount,Config.FontColor["ColorWhite1"], FSIZE("Size3"))			
		end
	elseif channel== StrongerChannel.Mining then--挖矿		
			local  title = string.wrapHyperLinkRich(Config.Words[26025],Config.FontColor["ColorBlue1"], FSIZE("Size3"))	
			local timeStr =	GameWorld.Instance:getMiningMgr():getMingOpenTime()
			richText = string.wrapHyperLinkRich(title .. "     Lv40      " ..Config.Words[26027] ..timeStr,Config.FontColor["ColorWhite1"], FSIZE("Size3"))
	elseif channel== StrongerChannel.monstInvasion then
		local archiveLv = GameData.MonsterInvasion["monsterInvasion1"].activityData["monsterInvasion1"].property.level		
		local  title = string.wrapHyperLinkRich(Config.Words[19500],Config.FontColor["ColorBlue1"], FSIZE("Size3"))	
		local timeStr =	 G_getHero():getMonstorInvasionMgr():getMonsterInvasionOpenTime()
		richText = string.wrapHyperLinkRich(title .. "     Lv40      ".. Config.Words[26027] .. timeStr,Config.FontColor["ColorWhite1"], FSIZE("Size3"))			
	elseif channel== StrongerChannel.Boss or channel== StrongerChannel.eliteMonster then--世界BOSS
		local targetMapRefId = content.sceneId
		targetData = GameData.Scene[targetMapRefId]
		local property = targetData["property"]
		local openLevel = PropertyDictionary:get_openLevel(property)		
		local  title = string.wrapHyperLinkRich(PropertyDictionary:get_name(GameData.Monster[content.monsterId[1]].property),Config.FontColor["ColorBlue1"], FSIZE("Size3"))	
			local level = PropertyDictionary:get_level(GameData.Monster[content.monsterId[1]].property)
			if channel== StrongerChannel.Boss  then
				local timeStr =	self:getWorldBossRefreshTime(refId,content.monsterId[1],targetMapRefId)
				richText = string.wrapHyperLinkRich(title .. "     Lv" .. level .. "      " ..Config.Words[23502].. timeStr,Config.FontColor["ColorWhite1"], FSIZE("Size3"))				
			else
				local timeStr =	Config.Words[23503] .. content.refreshTime .. Config.Words[23504] 
				richText = string.wrapHyperLinkRich(title .. "     Lv" .. level .. "      " .. timeStr,Config.FontColor["ColorWhite1"], FSIZE("Size3"))	
			end
	elseif channel== StrongerChannel.HandUpPoint then--黄金挂机点
		local targetMapRefId = content.sceneId
		targetData = GameData.Scene[targetMapRefId]
		local property = targetData["property"]
		local openLevel = PropertyDictionary:get_openLevel(property)		
		local  title = string.wrapHyperLinkRich(Config.Words[26026],Config.FontColor["ColorBlue1"], FSIZE("Size3"))				
		local name = PropertyDictionary:get_name(property)
		richText = string.wrapHyperLinkRich(title .. "     Lv" .. openLevel .. "      " ..name,Config.FontColor["ColorWhite1"], FSIZE("Size3"))			
	end
	return richText
end

function StrongerMgr:getMenuIconId(refId)
	local data = GameData.Strong.menu.configData[refId]
	if not data then
		return		
	end		
	return data.iconId, data.iconWay
end

function StrongerMgr:getCountDownRefIdByTime(refId)
	if not refId then
		return
	end
	
	if self.countDownRefIdList[refId] then
		return	self.countDownRefIdList[refId].time
	end
end

function StrongerMgr:addCountDownRefId(refId,func,time)
	if not refId or type(func)~="function" or type(time)~="number" then
		return
	end
	
	self.countDownRefIdList[refId] = {}
	self.countDownRefIdList[refId].func = func
	self.countDownRefIdList[refId].time = time
	
	self:startCountDown()
end

function StrongerMgr:clearCountDownRefId(refId)
	if not refId then
		return
	end
	self.countDownRefIdList[refId] = nil
	
	if table.isEmpty(self.countDownRefIdList) then
		self:stopCountDown()
	end
end	

function StrongerMgr:startCountDown()
	self:stopCountDown()
	
	if self.schedulerId then
		return
	end
	
	if table.isEmpty(self.countDownRefIdList) then
		return
	end
	
	local tick = function ()
		self:doCountDown()
	end
	self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1, false)
end	

function StrongerMgr:stopCountDown()
	if self.schedulerId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil
	end
end

function StrongerMgr:doCountDown()
	if table.isEmpty(self.countDownRefIdList) then
		self:stopCountDown()
		return
	end
	
	for i,v in pairs(self.countDownRefIdList) do
		v.time = v.time - 1
		
		if v.time>=0 then
			if v.func then
				v.func()
			end
		end	
		
		if v.time <= 0 then
			self:clearCountDownRefId(i)
		end
	end
end