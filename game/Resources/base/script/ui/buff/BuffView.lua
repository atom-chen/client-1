require "ui.buff.BuffTips"
require "utils.GameUtil"

BuffView = BuffView or BaseClass()

local boxSize = CCSizeMake(29, 29)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local scale = VisibleRect:SFGetScale()
local rootNodeSize = CCSizeMake(295*scale, boxSize.height)
local maxCount = 4 --最多显示4个
local horOffset = 10  --buff水平间隔

local InfoType = {
BuffObject = 1, 
BuffNode = 2,
}

function BuffView:__init()
	self.count = 0	
	self.buffMgr	 = GameWorld.Instance:getBuffMgr()
	self:init()
end

function BuffView:__delete()
	
end

function BuffView:init()
	self.buffArray = {}	
	self:createRootNode()	
end

function BuffView:getRootNode()
	return self.rootNode
end

function BuffView:createRootNode()
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(rootNodeSize)
end

function BuffView:reposition()
	for i=1, maxCount do 
		local info = self.buffArray[i]
		if info then 
			local x = (i-1)*(boxSize.width+horOffset)				
			local btn = info[InfoType.BuffNode]
			btn:setVisible(true)				
			VisibleRect:relativePosition(btn, self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(x, 0))					
		end
	end		
end


----------------------public--------------

function BuffView:addBuff(buffObject)
	local isPositiveBuff = PropertyDictionary:get_isPositiveBuff(buffObject:getStaticData())
	if 2 == isPositiveBuff or 3 == isPositiveBuff then 	 --隐身术和魔法盾不添加到buff列表上，应该添加到英雄身上	
		return 
	end
	local iconId = self:getIconIdByObject(buffObject)	
	if iconId ==nil or iconId == "" then 	
		return
	end			
	
	local buffBtn = createButtonWithFilename(ICON(iconId))	
	if buffBtn == nil then	
		return
	end
	local buffInfo = {}
	buffInfo[InfoType.BuffObject] = buffObject
	buffInfo[InfoType.BuffNode] = buffBtn	
	self:addObject(buffInfo)	
	if self.count > maxCount then
		buffBtn:setVisible(false)		
	end
	self.rootNode:addChild(buffBtn)
			
	local pt = buffObject:getPT()
	local cdProgressTimer = nil
	if pt.duration and pt.duration ~= -1 and pt.absoluteDuration then 
		if pt.buffRefId ~= "buff_item_8" and pt.buffRefId ~= "buff_item_9" and pt.buffRefId ~= "buff_item_10" then
			cdProgressTimer = self:createCDProgressTimer(iconId)		
			local passPrecentage = (pt["absoluteDuration"]-pt["duration"])/pt["absoluteDuration"]*100
			cdProgressTimer:setPercentage(passPrecentage)
			cdProgressTimer:setTag(99)				
			buffBtn:addChild(cdProgressTimer)
			VisibleRect:relativePosition(cdProgressTimer, buffBtn, LAYOUT_CENTER)		
			local buffCDTime = pt["duration"] / 1000	
			local progressTo = CCProgressTo:create(buffCDTime, 100)
			local delayAction = CCDelayTime:create(5.0) --转完cd 5秒后强制移除
			local progressTimerCB = function ()
				if buffBtn:getParent() then 
					self:removeObject(buffObject)
				end
			end
			local ccfunc = CCCallFuncN:create(progressTimerCB)
			local array = CCArray:create()	
			array:addObject(progressTo)
			array:addObject(delayAction)
			array:addObject(ccfunc)
			
			local sequence = CCSequence:create(array)
			cdProgressTimer:runAction(sequence)		
		end
	end
	if self.count < maxCount then
		GameUtil:createFadeAction(buffBtn,"common_fade.png", CCSizeMake(30, 30))
	end
	
	local buffCallback = function ()	
		local tipsId = ""			
		if self.tips then
			tipsId = self.tips:getBuffId()				
			self:deleteTips()				
		end
		local id = self:getBuffId(buffObject)
		if tipsId ~= id then 
			self:showTips(buffObject, buffBtn, cdProgressTimer)
		end
	end
	buffBtn:addTargetWithActionForControlEvents(buffCallback, CCControlEventTouchDown)	
end


function BuffView:subBuff(buffObject)
	local isPositiveBuff = PropertyDictionary:get_isPositiveBuff(buffObject:getStaticData())
	if 2 == isPositiveBuff or 3 == isPositiveBuff then 		
		return 
	end
	
	self:removeObject(buffObject)		
end

function BuffView:deleteTips()
	if self.tips then
		self.tips:getRootNode():removeFromParentAndCleanup(false)
		self.tips = nil
	end
end

function BuffView:showMoxueshiAmount(moxueshiObj)
	if self.tips and moxueshiObj then 
		local pt = moxueshiObj:getPT()
		if pt.buffRefId and pt.index then 
			local moxueshiCode = pt.buffRefId .. pt.index
			local tipsCode = self.tips:getBuffId()
			if tipsCode == moxueshiCode and pt.amount then
				self.tips:showMoxueshiAmount(pt.amount)
			end
		end
	end
end

---------------private---------------
function BuffView:getIconIdByObject(buffObject)
	local iconId = PropertyDictionary:get_iconId(buffObject:getStaticData())	
	return iconId
end



function BuffView:showTips(buffObject, buffBtn, cdProgressTimer)
	if self.tips then
		self.tips:getRootNode():removeFromParentAndCleanup(false)
		self.tips = nil
	end		
	local code = self:getBuffId(buffObject)
			
	--local proTimer = buffBtn:getChildByTag(99) -- 得到progresstimer			
	local precent = nil
	if cdProgressTimer and cdProgressTimer.getPercentage then 
		precent = cdProgressTimer:getPercentage()			
	end	
	
	self.tips = BuffTips.New()	
	self.tips:setBuffId(code)
	self.tips:show(buffObject, precent)	
	buffObject:DeleteMe()	
	
	buffBtn:getParent():addChild(self.tips:getRootNode())
	local x, y = buffBtn:getPosition()
	local size = self.tips:getRootNode():getContentSize()
	if x>size.width then 
		VisibleRect:relativePosition(self.tips:getRootNode(), buffBtn, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER_X, ccp(0, 0))
	else
		VisibleRect:relativePosition(self.tips:getRootNode(), buffBtn, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE, ccp(0, 0))
	end
end	

--唯一标示buff的id=  refId+index
function BuffView:getBuffId(buffObject)
	if buffObject == nil then 
		return
	end
	local retVal = ""
	local pt = buffObject:getPT()
	local index = pt["index"]
	local buffRefId = PropertyDictionary:get_buffRefId(pt)
	if index and buffRefId then 
		retVal= buffRefId .. index
	end
	return retVal
end


function BuffView:updateBuffView(buffObject, action)
	if action == BuffAction.AddBuff then 
		self:addBuff(buffObject)
	elseif action == BuffAction.SubBuff then 
		self:subBuff(buffObject)
	end
	self:reposition()
end


function BuffView:addObject(obj)
	self.count = self.count+1
	self.buffArray[self.count] = obj	
end

function BuffView:removeObject(delObj)
	local delCode = self:getBuffId(delObj)
	local delIndex = -1
	--找到要删除的索引
	for k, buffInfo in pairs(self.buffArray) do 
		local obj = buffInfo[InfoType.BuffObject]
		local code = self:getBuffId(obj)
		if code == delCode then 
			delIndex = k
			break
		end
	end
	--要删除对象后面的位置往前移
	if delIndex ~= -1 then 
		local btn = self.buffArray[delIndex][InfoType.BuffNode]
		if btn then 
			if self.tips then 
				local tipsId = self.tips:getBuffId()
				if tipsId == delCode then 
					self:deleteTips()
				end
			end
			btn:removeFromParentAndCleanup(true)			
		end
		if table.size(self.buffArray) ~= 1 and delIndex~=table.size(self.buffArray) then 
			for i=delIndex, (table.size(self.buffArray)-1) do 
				self.buffArray[i] = self.buffArray[i+1]
			end
		end
		self.buffArray[table.size(self.buffArray)] = nil
		self.count = self.count -1
		delObj:DeleteMe()
	end	
end

--cd
function BuffView:createCDProgressTimer(buffName)
	local sprite = createSpriteWithFileName(ICON(buffName))
	sprite:setColor(ccc3(125,125,125))
	local cdProgressTimer = CCProgressTimer:create(sprite)	
	cdProgressTimer:setType(kCCProgressTimerTypeRadial)	
	cdProgressTimer:setPercentage(100)			
	return cdProgressTimer
end
