--打折出售
require("object.activity.DiscountSellStaticData")
DiscountSellMgr = DiscountSellMgr or BaseClass()

function DiscountSellMgr:__init()
	self.frist = true
	self.severLeftTime = 0
	self.leftTime = 0
	self.discountSellList = {}
end

function DiscountSellMgr:__delete()
	self:clear()
end

function DiscountSellMgr:clear()
	self.severLeftTime = 0
	self.leftTime = 0
	self.discountSellList = {}
end

function DiscountSellMgr:isStart()
	return (self.startFlag==1)
end

function DiscountSellMgr:setStartFlag(startFlag)
	self.startFlag = startFlag
end

function DiscountSellMgr:setTheFirst()
	self.frist = false
end

function DiscountSellMgr:getTheFirst()
	return self.frist
end

function DiscountSellMgr:setSeverLeftTime(time)
	if not time then
		return
	end
	self.severLeftTime = time
	self.leftTime = math.floor(time/1000)
end

function DiscountSellMgr:getSeverLeftTime()
	return self.severLeftTime
end

function DiscountSellMgr:setLeftTime(time)
	self.leftTime = time
end

function DiscountSellMgr:getLeftTime()
	return self.leftTime
end	

function DiscountSellMgr:setDiscountSellList(list)
	self.discountSellList = list
end

function DiscountSellMgr:getDiscountSellList()
	return self.discountSellList
end

function DiscountSellMgr:setSellListLimitNum(index,number)
	if not index or not number then
		return
	end
	
	if self.discountSellList[index] then
		self.discountSellList[index]["leftNumber"] = number
	end
end

function DiscountSellMgr:setSellListPersonLimitNum(index,number)
	if not index or not number then
		return
	end
	
	if self.discountSellList[index] then
		self.discountSellList[index]["personLeftNumber"] = number
	end
end

function DiscountSellMgr:updateView()
	local theFirst = self:getTheFirst()
	if theFirst==true then
		self:setTheFirst()	
	else
		local view = UIManager.Instance:getViewByName("DiscountSellView")
		if self.leftTime and self.leftTime~=0  then		
			if view then
				view:doUpdateAllDataBySever()
			end
		else
			local isShow = UIManager.Instance:isShowing("DiscountSellView")
			if view and isShow==true then			
				view:updateSeverTimeOut()
			else
				UIManager.Instance:showSystemTips(Config.Words[17106])
			end	
		end	
	end
end

function DiscountSellMgr:OpenDiscountSellView()
	if self.leftTime and self.leftTime~=0 then
		GlobalEventSystem:Fire(GameEvent.EventOpenDiscountSellView)
	else
		self:requestGetDiscountSellList()
	end
end

--请求折扣列表
function DiscountSellMgr:requestGetDiscountSellList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Discount_GetShopList)	
	simulator:sendTcpActionEventInLua(writer)
end
