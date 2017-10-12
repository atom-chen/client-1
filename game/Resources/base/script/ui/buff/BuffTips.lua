
BuffTips = BuffTips or BaseClass()

local viewSize = CCSizeMake(160, 150)
local scrollViewOffset = 35
local scrollViewSize = CCSizeMake(viewSize.width, viewSize.height-scrollViewOffset-5-30)

function BuffTips:__init()
	self:init()
end

function BuffTips:__delete()
	self:stopCountDown()
	self.rootNode:release()
end

function BuffTips:init()
	self:createRootNode()
	self:createScrollView()
	self:createBuffName()
	self:createBuffDescription()
end

function BuffTips:createRootNode()
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(viewSize)
	self.rootNode:retain()
	
	local bg = createScale9SpriteWithFrameNameAndSize(RES("squares_formBg2.png"), viewSize)
	self.rootNode:addChild(bg)
	VisibleRect:relativePosition(bg, self.rootNode, LAYOUT_CENTER)
end

function BuffTips:createBuffName()
	self.buffName = createLabelWithStringFontSizeColorAndDimension("","Arial", FSIZE("Size2"), FCOLOR("ColorWhite2"))
	self.rootNode:addChild(self.buffName)
	VisibleRect:relativePosition(self.buffName, self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(5, -3))
end

function BuffTips:createBuffDescription()
	self.buffDesctiption = createLabelWithStringFontSizeColorAndDimension("","Arial", FSIZE("Size2"), FCOLOR("ColorWhite2"), CCSizeMake(viewSize.width-10, 0))
	self.scrollNode:addChild(self.buffDesctiption)
	VisibleRect:relativePosition(self.buffDesctiption, self.scrollNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(5, -20))
	
	self.leftTimeLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size2"), FCOLOR("ColorWhite2"), CCSizeMake(viewSize.width, 0))
	self.rootNode:addChild(self.leftTimeLabel)
	VisibleRect:relativePosition(self.leftTimeLabel, self.rootNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X, ccp(0, 3))
end

function BuffTips:createScrollView()
	--容器
	self.scrollNode = CCNode:create()
	self.scrollNode:setContentSize(scrollViewSize)		
	
	--ScrollView
	self.scrollView = createScrollViewWithSize(scrollViewSize)
	self.scrollView:setDirection(kSFScrollViewDirectionVertical)
	self.scrollView:setPageEnable(false)
	self.scrollView:setContainer(self.scrollNode)
	VisibleRect:relativePosition(self.scrollView, self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(3, -scrollViewOffset))
	self.rootNode:addChild(self.scrollView)		
end
-----------------------public---------------------
function BuffTips:getRootNode()
	return self.rootNode
end

function BuffTips:setBuffName(buff)
	local name = PropertyDictionary:get_name(buff:getStaticData())
	self.buffName:setString(name)
	self:repositionBuffName()
end	

function BuffTips:setDescription(buff)
	local desc = PropertyDictionary:get_description(buff:getStaticData())
	self.buffDesctiption:setString(desc)
	local tmpLabel = createLabelWithStringFontSizeColorAndDimension(desc, "Arial", FSIZE("Size2"), FCOLOR("ColorWhite2"))
	local tmpSize = tmpLabel:getContentSize()	
	local height = (tmpSize.width/scrollViewSize.width+3)*FSIZE("Size2")
	local offset =  height - scrollViewSize.height
	if offset>0 then 
		self.scrollNode:setContentSize(CCSizeMake(scrollViewSize.width, height))			
		self.scrollView:updateInset()		
		self.scrollView:setContentOffset(ccp(0, -offset), false)
	end				
	if time then 
		self.leftTimeLabel:setString(time)		
	end
	self:repositionBuffDescription()
end	

function BuffTips:show(buff, precent)	
	self:setBuffName(buff)
	self:setDescription(buff)
	local buffRefId = PropertyDictionary:get_buffRefId(buff:getPT())
	if buffRefId == "buff_item_8" or buffRefId == "buff_item_9" or buffRefId == "buff_item_10" then 
		--如果是魔血时，会请求服务器剩余用量
		local buffMgr = GameWorld.Instance:getBuffMgr()
		buffMgr:requestMoxueshiAmount()
	else
		self:showRemainingTime(buff, precent)
	end
		
end

--以时分秒形式返回
function BuffTips:calculateTime(time)
	local cnt = time
	local hour = math.modf(cnt / (60*60))
	hour = string.format("%02d", hour)
	cnt = cnt - hour * (60*60)
	local min = math.modf(cnt / 60)
	min = string.format("%02d", min)
	cnt = cnt - min * 60
	local sec = cnt
	sec = string.format("%02d", sec)
	return hour, min, sec
end

function BuffTips:showMoxueshiAmount(amount)
	self.leftTimeLabel:setString(Config.Words[956] .. amount)
end

function BuffTips:showRemainingTime(buff, precent)
	local pt = buff:getPT()
	if pt.duration then 		
		local durning = pt["duration"]/1000
		if durning and precent then 		
			self.remainingTime = durning * ((100-precent)/100)			
			self:setTime(self.remainingTime)
			self:startCountDown()
		end
	end
end

function BuffTips:showAmount(buff)
	local effectData = buff:getEffectData()
	if effectData.totalValue then
		local totalValue = effectData["totalValue"]
		
	end
end

function BuffTips:setTime(time)
	local hour, min, sec = self:calculateTime(time)
	local timeStr = Config.Words[955]..hour .. Config.Words[952] .. min .. Config.Words[953] .. sec .. Config.Words[954]
	self.leftTimeLabel:setString(timeStr)
	VisibleRect:relativePosition(self.leftTimeLabel, self.rootNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X, ccp(0, 3))
end

function BuffTips:setBuffId(id)
	self.id = id
end

function BuffTips:getBuffId()
	return self.id
end

function BuffTips:stopCountDown()
	if self.schedulerId then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil		
	end
end

function BuffTips:doCountDown()
	if self.remainingTime > 0 then 
		self.remainingTime = self.remainingTime-1
		self:setTime(self.remainingTime)
	else
		self:stopCountDown()
	end
end

function BuffTips:startCountDown()
	if self.schedulerId then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil		
	end
	local tick = function ()
		self:doCountDown()
	end
	self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1, false)
end

-----------------------private------------------
function BuffTips:repositionBuffName()
	VisibleRect:relativePosition(self.buffName, self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(5, -3))
end

function BuffTips:repositionBuffDescription()
	VisibleRect:relativePosition(self.buffDesctiption, self.scrollNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(5, -20))	
end	
