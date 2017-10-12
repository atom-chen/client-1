require("common.baseclass")
require("common.BaseObj")

AuctionItemObject = AuctionItemObject or BaseClass(ItemObject)

function AuctionItemObject:__init()
	self.price = 0
	self.remainTime = 0
end

function AuctionItemObject:__delete()
end

function AuctionItemObject:setRemainTime(time)
	self.remainTime = time
end

function AuctionItemObject:getRemainSec()
	return self.remainTime
end

function AuctionItemObject:getRemainStr()
	local restSec = self.remainTime
	if (type(restSec) ~= "number") or restSec < 0  then
		restSec = 0
	end
	if restSec < 0 then
		return " "
	end
	if type(restSec) ~= "number" then
		return " "
	end
	
	local hour = math.floor(restSec/3600)%24
	
	if hour > 10 then
		str = Config.Words[25324]
	elseif hour > 1 then
		str = Config.Words[25325]
	else
		str = Config.Words[25326]
	end
	return str
end