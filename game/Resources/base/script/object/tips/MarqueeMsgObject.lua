require("common.baseclass")
require ("common.BaseObj")

MarqueeMsgObject = MarqueeMsgObject or BaseClass(BaseObj)

function MarqueeMsgObject:__init()
	self.marquee = {}	
	self.marqueeCount = 0
end	

function MarqueeMsgObject:__delete()
	
end

function MarqueeMsgObject:insertMarqueeMessage(msg)
	self:addMarqueeCount()
	if type(msg) == "string" then
		msg = string.gsub(msg, "\n", "")
		table.insert(self.marquee,msg)
	elseif type(msg) == "table" then
		for i,v in ipairs(msg) do
			v = string.gsub(v, "\n", "")
			table.insert(self.marquee,v)
		end
	end
end

function MarqueeMsgObject:getFirstMarqueeMessage()
	if table.size(self.marquee) > 0 then
		local msg = self.marquee[1]
		table.remove(self.marquee,1)
		return msg
	end
end

function MarqueeMsgObject:IsMarqueeQueenEmpty()
	if table.size(self.marquee) > 0 then
		return false
	else
		return true
	end
end

function MarqueeMsgObject:addMarqueeCount()
	self.marqueeCount = self.marqueeCount + 1				
end
function MarqueeMsgObject:minusMarqueeCount()
	self.marqueeCount = self.marqueeCount - 1	
	if self.marqueeCount < 0 then
		self.marqueeCount = 0
	end			
end
function MarqueeMsgObject:isMarqueeCountZero()
	if self.marqueeCount == 0 then
		return true
	else
		return false
	end								
end

function MarqueeMsgObject:getMarqueeCount()
	return self.marqueeCount		
end