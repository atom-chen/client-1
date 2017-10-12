--显示英雄的状态：如自动寻怪，自动寻路等
require ("common.GameEventHandler")
require ("gameevent.GameEvent")

HeroStateUIHandler = HeroStateUIHandler or BaseClass(GameEventHandler)

local const_pkProtectionLevel = 40		--PK保护等级
local const_pkProtectionInterval = 5 	--PK保护提示间隔时间

local PKProtectionType = 
{
	HeroAttackerHeroUnderProtection = 1,	--英雄作为攻击者，英雄处于新手保护期间
	HeroAttackerPlayerUnderProtection = 2,  --英雄作为攻击者，其他玩家处于新手保护期间
	PlayerAttackerHeroUnderProtection = 3,  --其他玩家作为攻击者，英雄处于新手保护期间
	PlayerAttackerPlayerUnderProtection = 4,--其他玩家作为攻击者，该玩家处于新手保护期间
}

function HeroStateUIHandler:__init()
	local manager = UIManager.Instance		
	self.heroActiveView = nil
	self.lastPKProtectionTipsTime = --上次提示PK保护的时间 
	{
		[PKProtectionType.HeroAttackerHeroUnderProtection] = 0,
		[PKProtectionType.HeroAttackerPlayerUnderProtection] = 0,
		[PKProtectionType.PlayerAttackerHeroUnderProtection] = 0,
		[PKProtectionType.PlayerAttackerPlayerUnderProtection] = 0,
	}
	
	local onEventUpdateHeroActiveState = function(state)
		local heroObj = GameWorld.Instance:getEntityManager():getHero()	
		if heroObj:getActiveState() == state then
			return
		end
		self:clearHeroActiveState()
		heroObj:setActiveState(state)
		self.heroActiveView = self:createHeroActiveNode(state)
		self.heroActiveView:retain()
		if self.heroActiveView then
			UIManager.Instance:getGameRootNode():addChild(self.heroActiveView)
			local parent = self.heroActiveView:getParent()
			if parent then
				if state == E_HeroActiveState.AutoFindRoad then
					VisibleRect:relativePosition(self.heroActiveView, parent, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 200))
				else
					VisibleRect:relativePosition(self.heroActiveView, parent, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 200))
				end					
			end				
		end
	end
	local onEventClearHeroActiveState = function(state)
		local heroObj = GameWorld.Instance:getEntityManager():getHero()	
		if heroObj:getActiveState() == state then	
			--print("clear state="..state)	
			self:clearHeroActiveState()
		end
	end
	
	local onEventPKProtection = function(attackerId, targetId, attackerLevel, targetLevel)
		self:onEventPKProtection(attackerId, targetId, attackerLevel, targetLevel)
	end

	self:Bind(GameEvent.EventUpdateHeroActiveState, onEventUpdateHeroActiveState)	
	self:Bind(GameEvent.EventClearHeroActiveState, onEventClearHeroActiveState)		
	self:Bind(GameEvent.EventPKProtection, onEventPKProtection)		
end

function HeroStateUIHandler:clearHeroActiveState()
	if self.heroActiveView then
		self.heroActiveView:stopAllActions() --停止所有的action
		self.heroActiveView:removeFromParentAndCleanup(true)
		self.heroActiveView:release()
		self.heroActiveView = nil
	end
	G_getHero():setActiveState(nil)
end

function HeroStateUIHandler:onEventPKProtection(attackerId, targetId, attackerLevel, targetLevel)
	if type(attackerId) ~= "string" or type(attackerId) ~= "string" or
	   type(attackerLevel) ~= "number" or type(targetLevel) ~= "number" then
		return
	end		
	local hero = G_getHero()
	if not hero then
		return
	end
	local heroId = hero:getId()
	if heroId == attackerId then
		if attackerLevel < const_pkProtectionLevel then
			self:showPKProtectionTips(PKProtectionType.HeroAttackerHeroUnderProtection)
		else
			local target = GameWorld.Instance:getEntityManager():getEntityObject(EntityType.EntityType_Player, targetId)
			if target and (targetLevel < const_pkProtectionLevel) then			
				self:showPKProtectionTips(PKProtectionType.HeroAttackerPlayerUnderProtection)
			end
		end 
	elseif heroId == targetId then
		local attacker = GameWorld.Instance:getEntityManager():getEntityObject(EntityType.EntityType_Player, attackerId)
		if not attacker then
			return
		end	
		if targetLevel < const_pkProtectionLevel then		
			self:showPKProtectionTips(PKProtectionType.PlayerAttackerHeroUnderProtection, PropertyDictionary:get_name(attacker:getPT()))
		elseif attackerLevel < const_pkProtectionLevel then
			self:showPKProtectionTips(PKProtectionType.PlayerAttackerPlayerUnderProtection, PropertyDictionary:get_name(attacker:getPT()))		
		end 
	end
end

function HeroStateUIHandler:showPKProtectionTips(ttype, attackerName)
	if self.lastPKProtectionTipsTime[ttype] 
	   and (os.time() - self.lastPKProtectionTipsTime[ttype] > const_pkProtectionInterval) then
		if ttype == PKProtectionType.HeroAttackerHeroUnderProtection then	--英雄作为攻击者，英雄处于新手保护期间
			UIManager.Instance:showSystemTips(Config.Words[22008])
		elseif ttype == PKProtectionType.HeroAttackerPlayerUnderProtection then  --英雄作为攻击者，其他玩家处于新手保护期间
			UIManager.Instance:showSystemTips(Config.Words[22011])
		elseif ttype == PKProtectionType.PlayerAttackerHeroUnderProtection then  --其他玩家作为攻击者，英雄处于新手保护期间
			UIManager.Instance:showSystemTips(string.format(Config.Words[22009], tostring(attackerName)))
		elseif ttype == PKProtectionType.PlayerAttackerPlayerUnderProtection then--其他玩家作为攻击者，该玩家处于新手保护期间
			UIManager.Instance:showSystemTips(string.format(Config.Words[22010], tostring(attackerName)))
		end
		self.lastPKProtectionTipsTime[ttype] = os.time()
	end
end

function HeroStateUIHandler:createHeroActiveNode(state)

	local createJumpAni =  function(picList)
		local node = CCNode:create()
		node:setContentSize(CCSizeMake(200,30))		
		local startX  =  0	
		local spriteList = {}	
		for k,v in ipairs(picList) do
			local pic = createSpriteWithFrameName(RES(v))	
			local wordWidth = pic:getContentSize().width
			node:addChild(pic)
			VisibleRect:relativePosition(pic,node,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y,ccp(startX,0))
			spriteList[k] = pic
			startX = startX + wordWidth + 3
		end	

		local aniArray = CCArray:create()	
		for k,v in ipairs(spriteList) do
			local callBlackAni = function()
				local jump = CCJumpBy:create(0.2, ccp(0,0), 10,1)
				if spriteList[k] then
					spriteList[k]:runAction(jump)
				end
			end
			aniArray:addObject(CCCallFuncN:create(callBlackAni))
			aniArray:addObject(CCDelayTime:create(0.05))	
		end
		aniArray:addObject(CCDelayTime:create(0.5))
		local action = CCSequence:create(aniArray)
		local forever = CCRepeatForever:create(action) 		
		node:runAction(forever)
		
		local mapMgr = GameWorld.Instance:getMapManager()
		local curMap = mapMgr:getCurrentMapRefId()		
		
		if state == E_HeroActiveState.AutoFindRoad and self:checkNeedShowFlyshoes(curMap) then
			local flyShoes = createButtonWithFramename(RES("map_shoes.png"))
			node:addChild(flyShoes)
			flyShoes:setTouchAreaDelta(10, 10, 10, 10)
			VisibleRect:relativePosition(flyShoes, node, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(40, 0))
			
			local getSceneIdAndTargetPoint = function ()
				
				local autoMgr = GameWorld.Instance:getAutoPathManager()
				local sceneId = autoMgr:getTargetMapId()
				local targetPoint = nil
				if not sceneId then
					sceneId = mapMgr:getCurrentMapRefId()
					targetPoint = autoMgr:getTargetPoint()
				else
					targetPoint = autoMgr:getAutoPoint()
					if not targetPoint then
						local targetRefId = autoMgr:getTargetRefId()
						if targetRefId then
							local x, y = autoMgr:findXY(targetRefId, sceneId)
							if x and y then
								targetPoint = ccp(x, y)	
							end								
						else
							local smallMapMgr = GameWorld.Instance:getSmallMapManager()
							local transferInObj = smallMapMgr:getTransferInPointBySceneId(sceneId)	
							if transferInObj then
								targetPoint = ccp(transferInObj.x, transferInObj.y)
							end
						end														
					end
				end
				return sceneId, targetPoint
			end
			
			local flyShoesFun = function ()
				local mapMgr = GameWorld.Instance:getMapManager()
				local sceneId, targetPoint = getSceneIdAndTargetPoint()				
				if targetPoint then
					local ret, reason = mapMgr:checkCanUseFlyShoes(true)
					if ret then
						mapMgr:requestTransfer(sceneId, targetPoint.x, targetPoint.y, 1)
					elseif reason ~= CanNotFlyReason.CastleWar then
						UIManager.Instance:showSystemTips(Config.Words[13021])
					end							
				end					
			end
			flyShoes:addTargetWithActionForControlEvents(flyShoesFun,CCControlEventTouchDown)
		end						
		
		return node	
	end	
	local picList = {}
	if state == E_HeroActiveState.AutoFindRoad then
		picList[1] = "common_word_yellow_zi.png"
		picList[2] = "common_word_yellow_dong.png"	
		picList[3] = "common_word_yellow_xun.png"
		picList[4] = "common_word_yellow_lu.png"
		picList[5] = "common_word_yellow_zhong.png"
		picList[6] = "common_word_yellow_dian.png"
		picList[7] = "common_word_yellow_dian.png"
		picList[8] = "common_word_yellow_dian.png"				
	elseif state == E_HeroActiveState.AutoKillMonster then
		picList[1] = "common_word_green_zi.png"
		picList[2] = "common_word_green_dong.png"	
		picList[3] = "common_word_green_da.png"
		picList[4] = "common_word_green_guai.png"
		picList[5] = "common_word_green_zhong.png"
		picList[6] = "common_word_green_dian.png"
		picList[7] = "common_word_green_dian.png"
		picList[8] = "common_word_green_dian.png"				
	end		
	return createJumpAni(picList)
end	

function HeroStateUIHandler:checkNeedShowFlyshoes(sceneId)
	local kind = G_GetSceneType(sceneId)
	if kind == 2 or kind == 3 then
		return false
	end
	return true
end

function HeroStateUIHandler:__delete()
	
end