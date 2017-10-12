require("common.baseclass")
SelfControlManager = SelfControlManager or BaseClass()
SelfControlSate = {
	
}
function SelfControlManager:__init()
	self.callBackList = {}
	self.count = 0
end

function SelfControlManager:__delete()
	
end

function SelfControlManager:register(funcP,argsP)
	local callBlack = {args = argsP,func = funcP}
	self.count = self.count +1
	self.callBackList[self.count]  = callBlack
	return self.count
end

function SelfControlManager:unRegister(index)
	self.callBackList[index] = nil
end

function SelfControlSate:runAllCallBackWith()
	for k,v in pairs(self.callBackList) do
		if v.func then
			if v.args then
				v.func(v.args)
			else
				v.func()
			end
		end
	end
end

