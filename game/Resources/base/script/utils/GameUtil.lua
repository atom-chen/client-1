-- 存放一些可全局使用的动画
require ("ui.utils.UIControl")

GameUtil = GameUtil or BaseClass()

function GameUtil:__init()
	
end	

--[[
note,addChild节点
time,循环次数，不输入为1次
--]]
function  GameUtil:createFlashAnimateWithTime(node,time)
	local animateSprite = CCSprite:create()
	node:addChild(animateSprite)
	VisibleRect:relativePosition(animateSprite, node, LAYOUT_CENTER)
	local animate = createAnimate("iconFlash", 8, 0.1, 0)
	local actionArray = CCArray:create()
	local removeSelf = function ()
		if animateSprite then
			animateSprite:removeFromParentAndCleanup(true)
			animateSprite = nil
		end
	end
	local removeSelfFun = CCCallFunc:create(removeSelf)
	local action = nil
	if time then
		local repeatAction = CCRepeat:create(animate, time)
		actionArray:addObject(repeatAction)
		actionArray:addObject(removeSelfFun)
		action = CCSequence:create(actionArray)
		animateSprite:runAction(action)
	else
		actionArray:addObject(animate)
		actionArray:addObject(removeSelfFun)
		action = CCSequence:create(actionArray)
		animateSprite:runAction(action)
	end
end

--解锁动画精灵
function GameUtil:createMoveLight(node, tag)
	local nodeSize = node:getContentSize()
	local lightSprite = createScale9SpriteWithFrameName(RES("common_moveLight.png"))
	lightSprite:setContentSize(CCSizeMake(49, nodeSize.height))
	node:addChild(lightSprite, 0, tag)
	VisibleRect:relativePosition(lightSprite, node, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE)
	
	local nodeWidth = nodeSize.width
	local moveBy = CCEaseExponentialInOut:create(CCMoveBy:create(2, ccp(nodeWidth/2, 0)))
	local delay = CCDelayTime:create(1)
	local resetPosition = function ()	
		VisibleRect:relativePosition(lightSprite, node, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE)		
	end
	local resetFun = CCCallFunc:create(resetPosition)
	local fadeIn = CCFadeIn:create(1)
	
	local arraySpawn = CCArray:create()
	arraySpawn:addObject(fadeIn)
	arraySpawn:addObject(moveBy)
	local spawn = CCSpawn:create(arraySpawn)
	
	local fadeOut = CCFadeOut:create(0)
	local array = CCArray:create()
	
	array:addObject(spawn)
	array:addObject(fadeOut)
	array:addObject(resetFun)		
	local seqAction = CCSequence:create(array)
	
	local foreverAction = CCRepeatForever:create(seqAction)
	lightSprite:runAction(foreverAction)
end

--技能槽更新技能动画
--node 添加动画的node
--time 播放次数
--name:帧动画图片名称(不带数字下标和.png)
--number：图片数量(图片的下标从0开始)
--delay:设置帧频速度
function GameUtil:createChangeAnimate(node, time, name, number, delay, startIndex)
	local sprite = CCSprite:create()
	node:addChild(sprite)
	VisibleRect:relativePosition(sprite, node, LAYOUT_CENTER)
	local animate = createAnimate(name, number, delay, startIndex)
	local removeSelf = function ()
		if sprite then
			sprite:removeFromParentAndCleanup(true)
			sprite = nil
		end
	end
	local removeFun = CCCallFunc:create(removeSelf)
	
	local array = CCArray:create()
	if not time or time < 2 then
		array:addObject(animate)
	else
		local animateAction = CCRepeat:create(animate, time)
		array:addObject(animateAction)
	end		
	array:addObject(removeFun)
	local seqAction = CCSequence:create(array)
	
	sprite:runAction(seqAction)
end

--node 添加动画的node
--name:动作图片名称(带数字下标和.png)
function GameUtil:createFadeAction(node, name, size)
	local sprite = createScale9SpriteWithFrameNameAndSize(RES(name), size)
	node:addChild(sprite)
	VisibleRect:relativePosition(sprite, node, LAYOUT_CENTER)
	
	sprite:setOpacity(50)
	local array = CCArray:create()
	local fadeIn = CCFadeIn:create(0.5)
	local fadeOut = CCFadeOut:create(0.5)
	local removeSelf = function ()
		sprite:removeFromParentAndCleanup(true)
	end
	local removeFun = CCCallFunc:create(removeSelf)
	array:addObject(fadeIn)
	array:addObject(fadeOut)
	array:addObject(removeFun)
	local action = CCSequence:create(array)
	sprite:runAction(action)
end
--targetNode 运行动作目标对象
function GameUtil:createAndRunScaleAction(targetNode)
	local array = CCArray:create()
	local scaleSmall = CCScaleTo:create(0.2, 0.9)
	local scaleBack = CCScaleTo:create(0.2, 1.0)
	local scalebig = CCScaleTo:create(0.2, 1.1)
	array:addObject(scaleSmall)
	array:addObject(scaleBack)
	array:addObject(scalebig)
	local seqAction = CCSequence:create(array)
	local action = CCRepeatForever:create(seqAction)
	targetNode:stopAllActions()
	targetNode:runAction(action)
end

--任务动画
--parent 添加动画的node
--name:帧动画图片名称(不带数字下标和.png)
--number：图片数量
--delay:设置帧频速度
--startIndex:动画开始下表
--targetName:最后执行动作的图片文件
function GameUtil:createAnimateAndAction(parent, name, number, delay, startIndex, needDelay)
	local animateSprite = CCSprite:create()
	parent:addChild(animateSprite)
	VisibleRect:relativePosition(animateSprite, parent, LAYOUT_CENTER, ccp(0, 100))
	
	local animate = createAnimate(name, number, delay, startIndex)
		
	local fadeOut = CCFadeOut:create(0.5)
	local scaleSmall = CCScaleTo:create(0.5, 0.9)
	local subArray = CCArray:create()
	subArray:addObject(fadeOut)
	subArray:addObject(scaleSmall)
	local spawn = CCSpawn:create(subArray)
	
	local delayAction = CCDelayTime:create(0.3)
	
	local finishFunCallBack = function ()
		if animateSprite and animateSprite:getParent() then
			animateSprite:removeFromParentAndCleanup(true)
			animateSprite = nil
		end			
	end
	local finishFun = CCCallFunc:create(finishFunCallBack)
		
	local array = CCArray:create()
	if needDelay then
		array:addObject(delayAction)
	end
	array:addObject(animate)
	array:addObject(spawn)
	array:addObject(finishFun)
	
	local seqAction = CCSequence:create(array)
	animateSprite:runAction(seqAction)
end

function GameUtil:sec2str(sec)
	if (type(sec) ~= "number") or sec < 0  then
		sec = 0
	end
	if sec < 0 then
		return " "
	end
	if type(sec) ~= "number" then
		return " "
	end
	
	local day = math.floor(sec/8640--[[(24*3600)--]])	
	local hour = math.floor(sec/3600)%24
	local minute = math.floor(sec/60)%60
	local sec = sec%60	
	local str = " "
	if day > 0 then
		str = day..Config.Words[13007]
	else
		if hour > 0 then
			str = string.format("%d%s", hour, Config.Words[13640])
		elseif minute > 0 then
			str = string.format("%02d%s%02d", minute, ":", sec)
		else
			str = string.format("%02d%s", sec, Config.Words[13642])
		end
	end	
	return str
end

--获得身上装备的基础战力
function GameUtil:getEquipBaseFightValue()
	local baseFightValue = 0
	local equipList = G_getEquipMgr():getEquipList()
	for k,equip in pairs(equipList) do
		-- 同一种装备可能有不同的部位 
		for i,v in pairs(equip) do
			baseFightValue = baseFightValue + G_caculateEquipBaseFightValue(v)
		end
	end
	return baseFightValue
end
--获得身上装备的强化战力
function GameUtil:getEquipForgFightValue()
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	if heroLevel < 50 then
		return -1
	end		
	local forgFightValue = 0
	local equipList = G_getEquipMgr():getEquipList()	
	for k,equip in pairs(equipList) do
		-- 同一种装备可能有不同的部位 
		for i,v in pairs(equip) do
			forgFightValue = forgFightValue + G_caculateEquipStrenthenFightValue(v)
		end
	end
	return forgFightValue
end
--获得身上装备的洗练战力
function GameUtil:getEquipWashFightValue()
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	if heroLevel < 50 then
		return -1
	end	
	local washFightValue = 0
	local equipList = G_getEquipMgr():getEquipList()
	for k,equip in pairs(equipList) do
		-- 同一种装备可能有不同的部位 
		for i,v in pairs(equip) do
			washFightValue = washFightValue + G_caculateEquipWashFightValue(v)
		end
	end
	return washFightValue
end

--获得坐骑战力
function GameUtil:getMountFightValue()
	--是否有坐骑  40级
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	if heroLevel < 40 then
		return -1
	end

	local fightValue = 0
	local mountRefId = GameWorld.Instance:getMountManager():getCurrentUseMountId()	
	local mountRecord = G_GetMountRecordByRefId(mountRefId)
	if mountRecord and mountRecord.effectData and type(mountRecord.effectData) == "table" then
		fightValue = G_getFightValue(mountRecord.effectData)
	end
	return fightValue
end

--获得翅膀战力
function GameUtil:getWingFightValue()
	--是否有翅膀	50级 -- 或者VIP
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	local vipLevel = GameWorld.Instance:getVipManager():getVipLevel()
	if heroLevel < 50 and vipLevel == 0 then
		return -1
	end
	local wingRefId = GameWorld.Instance:getEntityManager():getHero():getWingMgr():getWingRefId()
	local efffectPD = GameWorld.Instance:getEntityManager():getHero():getWingMgr():getWingEffecData(wingRefId)
	if efffectPD and type(efffectPD) == "table" then
		fightValue = G_getFightValue(efffectPD)
	end
	return fightValue
end

--获得法宝战力
function GameUtil:getTalismanFightValue()
	--是否开启法宝系统  45级(暂不处理)
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	if heroLevel < 45 then
		return -1
	end
	return 0
end

--获得心法战力
function GameUtil:getCittaFightValue()
	--是否开启法宝系统 45级
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	if heroLevel < 45 then
		return -1
	end
	
	local  fightValue = 0
	local cittaLevel = GameWorld.Instance:getTalismanManager():getCittaLevel()
	if cittaLevel and cittaLevel > 0 then	
		local cittaRecord  = GetCittaRecordByLevel(cittaLevel)
		if cittaRecord and cittaRecord.effectData and type(cittaRecord.effectData) == "table" then
			fightValue = G_getFightValue(cittaRecord.effectData)
		end	
	end
	return fightValue
end	

--获得爵位战力
function GameUtil:getKnightFightValue()
	--是否开启爵位系统 30级
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	if heroLevel < 30 then
		return -1
	end
	local knightPt = GameWorld.Instance:getEntityManager():getHero():getKnightMgr():getKnightPT()
	local  fightValue = 0
	if knightPt and type(knightPt) == "table" then
		fightValue = G_getFightValue(knightPt)
	end					
	return fightValue
end	