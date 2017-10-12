require("common.baseclass")

TipsManager = TipsManager or BaseClass()

function TipsManager:__init()
	self.tipsList = {}	
	self.tipCount = 0
	self.showFlag = true	
end	

function TipsManager:clear()
	self.tipsList = {}	
	self.tipCount = 0
	self.showFlag = true
end

-------------------------系统提示---------------------------------------------

function TipsManager:insertTips(tips)
	if tips == nil then
		CCLuaLog("ArgError:TipsManager:insertTips")
		return
	end
	self.tips = tips
	GlobalEventSystem:Fire(GameEvent.EventTipsInsert, tips.type)
end	

function TipsManager:getCurrentTips()
	return self.tips
end	

function TipsManager:removeTips()
	self.tips = nil
end	

function TipsManager:setTipsShowFlag(bShow)
	self.showFlag = bShow
end
function TipsManager:getTipsShowFlag()
	return self.showFlag
end
function TipsManager:insertUnShowTipsList(str)
	if str == nil then
		CCLuaLog("ArgError:TipsManager:insertUnShowTipsList")
		return
	end
	table.insert(self.tipsList,str)
end
function TipsManager:getUnShowTipsList()
	return self.tipsList
end
function TipsManager:cleanUnShowTipsList()
	self.tipsList = {}
end


------------------------------------------走马灯-----------------------------------


function TipsManager:getFontColorByType(specialEffectsType)
	if specialEffectsType == 0 then
		return FCOLOR("ColorWhite2")	
	elseif specialEffectsType == 1 then
		return FCOLOR("ColorRed2")	
	elseif specialEffectsType == 2 then
		return FCOLOR("ColorGreen2")	
	elseif specialEffectsType == 3 then
		return FCOLOR("ColorYellow1")	
	end
end

function TipsManager:setSystemMarqueeMessage(msg)
	self.systemMarquee = msg
end	

function TipsManager:getSystemMarqueeMessage()
	return self.systemMarquee
end
function TipsManager:getFontColorByTypeForRichLabel(specialEffectsType)
	if specialEffectsType == 0 then
		return Config.FontColor["ColorWhite2"]			
	elseif specialEffectsType == 1 then
		return Config.FontColor["ColorRed2"]		
	elseif specialEffectsType == 2 then
		return Config.FontColor["ColorGreen2"]	
	elseif specialEffectsType == 3 then
		return Config.FontColor["ColorYellow1"]	
	end
end

function TipsManager:getSystemMarqueeMessage()
	return self.systemMarquee
end
function TipsManager:setSystemMarqueeFontColor(fontColor)
	self.fontColor = fontColor
end
function TipsManager:getSystemMarqueeFontColor()
	return self.fontColor
end