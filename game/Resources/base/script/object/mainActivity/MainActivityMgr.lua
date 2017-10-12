require("common.baseclass")

MainActivityMgr = MainActivityMgr or BaseClass()

function MainActivityMgr:__init()
	
end

function MainActivityMgr:clear()
	if self.btnList then
		self.btnList = {}
	end
	if self.conList then
		self.conList = {}
	end
end

function MainActivityMgr:setBtnList(pos,icon,callBack,conditionType,conditionValue,arg,ani)
	if(conditionType == nil)then
		self:addBtnList(pos,icon,callBack,nil,nil,arg,ani)
	elseif conditionType == "level" then
		local g_hero = GameWorld.Instance:getEntityManager():getHero()	
		self.curLevel = PropertyDictionary:get_level(g_hero:getPT())
		if conditionValue<=self.curLevel then
			self:addBtnList(pos,icon,callBack,nil,nil,arg,ani)
		else
			self:addConditionList(conditionValue,pos,icon,callBack)
		end
	elseif conditionType == "function" then
		self:addBtnList(pos,icon,callBack,conditionType,conditionValue,arg,ani)
	end
end

function MainActivityMgr:addBtnList(pos,icon,callBack,condition,conditionFunc,arg,ani)
	if not self.btnList then
		self.btnList = {}
	end
	self.btnList[pos] = {icon=icon,callBack=callBack,conditionFunc=conditionFunc,arg=arg,ani=ani}
end

function MainActivityMgr:removeBtnList(pos)
	if self.btnList then
		local listSize = table.size(self.btnList)
		for i,v in ipairs(self.btnList) do
			if i == pos then
				for j=i+1,listSize do
					self.btnList[j] = self.btnList[j-1]	
				end
				self.btnList[listSize] = nil
			end
		end
	end
end


function MainActivityMgr:clearBtnList()
	if self.btnList then
		self.btnList = nil
	end
end
function MainActivityMgr:getBtnList()
	local listSize = table.size(self.btnList)
	if(listSize > 0) then
		return self.btnList
	end
end
function MainActivityMgr:addConditionList(conditionValue,pos,icon,callBack)
	if self.conList then
		local conListSize = table.size(self.conList)
		local v = {}
		v.conditionValue = conditionValue
		v.pos = pos
		v.icon = icon
		v.callBack =callBack	
		self.conList[conListSize+1] = v
	else
		self.conList = {}
		local v = {}
		v.conditionValue = conditionValue
		v.pos = pos
		v.icon = icon
		v.callBack =callBack						
		self.conList[1] = v
	end
end	
function MainActivityMgr:removeConditionList(pos)
	if self.conList then
		for i,v in pairs(self.conList) do
			if pos == v.pos then
				self.conList[i] = nil
				break
			end
		end
	end
end
function MainActivityMgr:getConditonLIst()
	local listSize = table.size(self.conList)
	if(listSize > 0) then
		return self.conList
	end
end

function MainActivityMgr:setRebackTime(rebackTime)
	if self.timeList then
		local size = table.size(self.timeList)
		self.timeList[size+1] = rebackTime
	else 
		self.timeList = {}
		self.timeList[1] = rebackTime
	end
end

function MainActivityMgr:getRebackTime()
	if self.timeList then
		
	end
end
