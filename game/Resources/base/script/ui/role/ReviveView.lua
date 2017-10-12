--[[
复活界面
]]

require("common.BaseUI")
require("actionEvent.ActionEventDef")
ReviveView = ReviveView or BaseClass(BaseUI)

AttackerType = {
	monster = 1,
	player = 2,
}

function ReviveView:__init()
	self.viewSize = VisibleRect:getScaleSize(CCSizeMake(484, 330))
	self:init(self.viewSize)
	self:setVisiableCloseBtn(false)
	
	self.countdownSchedulerId = -1
	self.countdowntimer = 9
	self.revivePrice = 300000
	self.showPlayerTipCount = 0
	
	self:createView()	
end

function ReviveView:__delete()
	self:hideCountdownLabel()	
	self:clearScheduler()
	
	if self.playerTips then
		self.playerTips:getRootNode():removeFromParentAndCleanup(true)
		self.playerTips:DeleteMe()
		self.playerTips = nil
	end
end

function ReviveView:createView()
	local bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(446, 164))
	self:addChild(bg)
	VisibleRect:relativePosition(bg, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE,ccp(0,0))
	
	-- 回城复活
	local clickBtnFree = function ()
		self:clickBtnFree()
	end
	
	local btnFree = createButtonWithFramename(RES("btn_1_select.png"))
	self:addChild(btnFree)
	btnFree:addTargetWithActionForControlEvents(clickBtnFree, CCControlEventTouchDown)
	
	
	-- 原地复活，消耗元宝
	local clickBtnMoney = function ()
		self:clickBtnMoney()
	end
	
	self.btnMoney = createButtonWithFramename(RES("btn_1_disable.png"))
	self:addChild(self.btnMoney)
	self.btnMoney:addTargetWithActionForControlEvents(clickBtnMoney, CCControlEventTouchDown)	
	
	-- 线
	local spriteLine = createSpriteWithFrameName(RES("knight_line.png"))
	spriteLine:setScaleX(4)
	self:addChild(spriteLine)
	
	-- 标题
	local title = createSpriteWithFrameName(RES("word_window_youdied.png"))	
	self:addChild(title)
	
	
	-- TODO: 以后要改成美术字
	local labelBtnFree = createSpriteWithFrameName(RES("word_button_backrevive.png")) 
	btnFree:setTitleString(labelBtnFree)
	
	local labelBtnMoney = createSpriteWithFrameName(RES("word_button_standingrevive.png")) 
	self.btnMoney:setTitleString(labelBtnMoney)
		
	local labelMoney = createLabelWithStringFontSizeColorAndDimension(self.revivePrice..Config.Words[21001],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	self:addChild(labelMoney)	
	
	-- 设置位置
	VisibleRect:relativePosition(title,self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_OUTSIDE, ccp(0, 5))	
	
	VisibleRect:relativePosition(spriteLine, bg, LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X, ccp(0, -55))	
		
	VisibleRect:relativePosition(btnFree, bg, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(30, -30))
	VisibleRect:relativePosition(self.btnMoney, bg, LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(-30, -30))

	VisibleRect:relativePosition(labelMoney, self.btnMoney, LAYOUT_TOP_OUTSIDE + LAYOUT_CENTER_X )		
end

--bEnableMoney: 是否使能原地复活
function ReviveView:setInfo(info, bEnableMoney)
	if table.size(info)>0 then		
		local attackerType = info.killerType
		local attacktimeWord = self:showDateTime(info.deadTime)	
		local itemList = self:sort(info.itemList)
		local attacker = nil	
		local attacktime = nil		
		local killerLevel = info.killerLevel
		local killerOccupa = ""
		if info.killerOccupa == 1 then
			killerOccupa = Config.Words[5028]
		elseif info.killerOccupa == 2 then
			killerOccupa = Config.Words[5029]
		elseif info.killerOccupa == 3 then
			killerOccupa = Config.Words[5030]
		end
		local killerFightPower = info.killerFightPower
		local attackerTypeWord = self:getAttackerTypeWord(attackerType)
		if info.killerName then		
			--攻击者
			local killerInfoStr = string.format(Config.Words[862],killerLevel,killerOccupa,killerFightPower)			
			local attackerNameRichWord = string.wrapRich( Config.Words[3154]..self:getAttackerNameRichWord(info.killerName)..Config.Words[3149],Config.FontColor["ColorGreen1"],FSIZE("Size3")	)	
			local attackerWord = string.wrapRich(Config.Words[859]..attackerNameRichWord,Config.FontColor["ColorRed1"],FSIZE("Size3"))
			local descStr = attackerWord
			if attackerType == 2 then
				descStr = string.wrapRich(attackerWord..killerInfoStr,Config.FontColor["ColorYellow1"],FSIZE("Size3"))
			end
			local attacker = createRichLabel(CCSizeMake(420,10))	
			attacker:appendFormatText(descStr)			
			self:addChild(attacker)

			VisibleRect:relativePosition(attacker, self:getContentNode(),LAYOUT_LEFT_INSIDE + LAYOUT_TOP_OUTSIDE ,ccp(15, -103+75))
		end
		
		if attacktimeWord then
			--被攻击时间
			attacktime = createLabelWithStringFontSizeColorAndDimension(Config.Words[860]..attacktimeWord,"Arial",FSIZE("Size3"),FCOLOR("ColorRed1"))
			self:addChild(attacktime)
			VisibleRect:relativePosition(attacktime,  self:getContentNode(),LAYOUT_LEFT_INSIDE + LAYOUT_TOP_OUTSIDE ,ccp(15, -103+50))
		end
		
		
		local itemWord = createLabelWithStringFontSizeColorAndDimension(Config.Words[861],"Arial",FSIZE("Size3"),FCOLOR("ColorRed1"))
		self:addChild(itemWord)
		VisibleRect:relativePosition(itemWord, self:getContentNode(),LAYOUT_LEFT_INSIDE + LAYOUT_TOP_OUTSIDE ,ccp(15, -103+25))
				
		self:showItemList(itemList)
		if bEnableMoney == nil then
			bEnableMoney = true
		end
		if bEnableMoney then
			self:showCountdownLabel()
			self:createScheduler()	
		end
		self.enableMoney = bEnableMoney
	end
end	

function ReviveView:sort(item)
	if table.size(item)>0 then	
		local function sortAsc(a, b)
			local itemRefIdA = a.itemRefId
			local itemRefIdB = b.itemRefId
			local itemcountA =  a.itemcount
			local itemcountB =  b.itemcount
			
	
			local qualityA = G_getQualityByRefId(itemRefIdA)
			local qualityB = G_getQualityByRefId(itemRefIdB)
			local kindA = G_getItemKindByRefId(itemRefIdA)
			local kindB = G_getItemKindByRefId(itemRefIdB)		
			if qualityA > qualityB then--品质高的优先
				return true	
			elseif qualityA == qualityB then--品质高的优先
				if kindA >	kindB then	
					return true	
				elseif kindA == kindB then
					if itemcountA>itemcountB then--数量多的优先
						return true
					else
						return false
					end
				else
					return false
				end
			else
				return false
			end
		end
		
		table.sort(item, sortAsc)
		return item
	end
end

function ReviveView:showItemList(itemList)
	local height = 100
	if 	table.size(itemList) > 4 then
		height = table.size(itemList)*25
	end
	local scrollViewSize = CCSizeMake(340,height)
	local container = CCNode:create()
	container:setContentSize(scrollViewSize)

	if table.size(itemList)>0 then
		local firstPosX =0
		local firstPosY =0
		local offsetPosY = 23
		for i,v in pairs(itemList) do								
			local itemName =  G_getStaticPropsName(v.itemRefId)	
			local qualityColor = G_getQualityFColorByRefId(v.itemRefId)
			
			local itemNameWord = createLabelWithStringFontSizeColorAndDimension(itemName,"Arial",FSIZE("Size3"),FCOLOR(qualityColor))
			container:addChild(itemNameWord)
			VisibleRect:relativePosition(itemNameWord, container,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(firstPosX,firstPosY-offsetPosY*(i-1)))
		
			local itemCountWord = createLabelWithStringFontSizeColorAndDimension("x"..v.itemcount,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
			container:addChild(itemCountWord)			
			VisibleRect:relativePosition(itemCountWord, container,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE,ccp(firstPosX+70,firstPosY-offsetPosY*(i-1)))			
		end
	else
		local noitem = createLabelWithStringFontSizeColorAndDimension(Config.Words[5007],"Arial",FSIZE("Size3"),FCOLOR("ColorRed1"))
		container:addChild(noitem)
		VisibleRect:relativePosition(noitem, container,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE ,ccp(0, 0))		
	end	
		
	self.scrollView = createScrollViewWithSize(CCSizeMake(340,100))
	self.scrollView:setDirection(2)	
	self.scrollView:setContainer(container)
	self.scrollView:setContentOffset(ccp(0, 100-height))
	self:addChild(self.scrollView)
	VisibleRect:relativePosition(self.scrollView, self:getContentNode(), LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE, ccp(0, -57))	
	
	
end

function ReviveView:clickRichLabel(arg)
	if tonumber(arg)==AttackerType.player then		
	end	
end	

function ReviveView:showCountdownLabel()
	if not self.countdownLabel then
		self.countdownLabel = createLabelWithStringFontSizeColorAndDimension("("..self.countdowntimer.."s)","Arial", FSIZE("Size3"), FCOLOR("ColorRed1"))
		self:addChild(self.countdownLabel)
		VisibleRect:relativePosition(self.countdownLabel, self.btnMoney, LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_OUTSIDE,ccp(15,3))
	else
		self.countdownLabel:setString("("..self.countdowntimer.."s)")
		self.countdownLabel:setVisible(true)
	end
end

function ReviveView:hideCountdownLabel()
	if self.countdownLabel then
		self.countdownLabel:setVisible(false)
	end
	
	if self.btnMoney then
		local unclicksprite = createScale9SpriteWithFrameName(RES("btn_1_select.png"))
		self.btnMoney:setBackgroundSpriteForState(unclicksprite,CCControlStateNormal)
	end
end

function ReviveView:createScheduler()
	if self.countdownSchedulerId == -1 then
		if self.countdownFunction == nil then
			self.countdownFunction = function ()
				self:doSchedulerTimer()
			end
		end				
		self.countdownSchedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.countdownFunction, 1, false)
	end	
end

function ReviveView:clearScheduler()
	if self.countdownSchedulerId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.countdownSchedulerId)
		self.countdownSchedulerId = -1	
	end
end

function ReviveView:doSchedulerTimer()
	self.countdowntimer = self.countdowntimer - 1
	
	if self.countdownLabel then	
		self.countdownLabel:setString("("..self.countdowntimer.."s)")
	end	
	
	if self.countdowntimer<=0 then
		self:hideCountdownLabel()	
		self:clearScheduler()
	end
end

function ReviveView:showDateTime(systemTime)
	if systemTime then
		local temTime = math.floor(systemTime/1000)
		local time = os.date("%Y"..Config.Words[13621].."%m"..Config.Words[13622].."%d"..Config.Words[13623].."%H"..Config.Words[13640].."%M"..Config.Words[13641].."%S"..Config.Words[13642], temTime) 		
		return time
	end	
end

function ReviveView:getAttackerNameRichWord(attackerName)
	local word = string.wrapRich(attackerName,Config.FontColor["ColorGreen1"],FSIZE("Size3"))
	return word
end
			
function ReviveView:getAttackerTypeWord(ttpye)
	local attackerTypeWord = ""

	if ttpye==AttackerType.player then
		attackerTypeWord = Config.Words[16011]
	elseif ttpye==AttackerType.monster then
		attackerTypeWord = Config.Words[7001]
	end			

	return attackerTypeWord
end

function ReviveView:clickBtnMoney()
	if not self.enableMoney then
		UIManager.Instance:showSystemTips(Config.Words[18010])
	elseif self.countdowntimer>0 then
		UIManager.Instance:showSystemTips(self.countdowntimer..Config.Words[15032])	
	else
		local hero = GameWorld.Instance:getEntityManager():getHero()	
		local goldNum = PropertyDictionary:get_gold(hero:getPT()) 
		if goldNum and goldNum < self.revivePrice then
			local msg = {}
			table.insert(msg,{word = Config.Words[15017], color = Config.FontColor["ColorRed1"]})
			UIManager.Instance:showSystemTips(msg)
		elseif goldNum and goldNum >= self.revivePrice then
			local simulator = SFGameSimulator:sharedGameSimulator()
			local writer = simulator:getBinaryWriter(ActionEvents.C2G_Player_Revive)
			writer:WriteChar(1)
			simulator:sendTcpActionEventInLua(writer)
		end		
	end
end

function ReviveView:clickBtnFree()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Player_Revive)
	writer:WriteChar(0)
	simulator:sendTcpActionEventInLua(writer)
	
	--GlobalEventSystem:Fire(GameEvent.EventReviveViewShow, false)
end

function ReviveView:touchHandler(eventType, x, y)
	-- 死亡以后不允许点其他东西		
	return 1	
end