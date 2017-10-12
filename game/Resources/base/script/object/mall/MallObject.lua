require("common.baseclass")
require("common.BaseObj")
require("data.mall.mall")
MallObject = MallObject or BaseClass(BaseObj)
				
function MallObject:__init()
	self.coinPrice = 0
	self.ironMedal = 0
	self.sliverMedal= 0 
	self.copperMedal = 0 
	self.goldMedal = 0 
	self.coupon=0
	self.coupon1 = 0
	self.coupon2 = 0
	self.bindedGold = 0
	self.unbindedGold = 0
	self.priceTypeList = {}			
	
	
end

function MallObject:getMaxNumByRefId(refId)
	local item = GameData.Mall[refId]
	if item then
		local property = item.property
		if property then
			local maxNum = property.itemLimitNum
			if maxNum then
				return maxNum
			end				
		end
	end
	return 0
end

function MallObject:setRefId(refId)
	self.RefId = refId
end
function MallObject:getRefId()
	return  self.RefId
end
--��Ʒ����
function MallObject:getItemName()
	return self.itemName
end
function MallObject:setItemName(name)
	self.itemName = name
end	
--��Ʒ���� ��0=��ͨ 1=���� 2=��Ʒ 3=���ۣ�
function MallObject:getItemSellType()
	return self.itemSellType
end
function MallObject:setItemSellType(itemSellType)
	self.itemSellType = itemSellType 
end
--Ԫ���۸�
function MallObject:getUnBindedGold()
	return self.unbindedGold
end
function MallObject:setUnBindedGold(unbindedGold)
	self.unbindedGold = unbindedGold
	self.priceTypeList["unbindedGold"] = unbindedGold	
	
end
--��Ԫ���۸�
function MallObject:getBindedGold()
	return self.bindedGold
end
function MallObject:setBindedGold(bindedGold)
	self.bindedGold = bindedGold 
	self.priceTypeList["bindedGold"] = bindedGold			
end
--����Ԫ���۸�
function MallObject:getUnBindOriginalPrice()
	return self.unbindOriginalPrice
end
function MallObject:setUnBindOriginalPrice(unbindOriginalPrice)
	self.unbindOriginalPrice = unbindOriginalPrice
	self.priceTypeList["unbindOriginalPrice"] = unbindOriginalPrice		
end
--���۰�Ԫ���۸�
function MallObject:setBindOriginalPrice(bindOriginalPrice)
	self.bindOriginalPrice	= bindOriginalPrice
	self.priceTypeList["bindOriginalPrice"] = bindOriginalPrice		
end
function MallObject:getBindOriginalPrice()
	return self.bindOriginalPrice	
end
--�޹�����
function MallObject:setItemLimitType(itemLimitType)
	self.itemLimitType = itemLimitType
end
function MallObject:getItemLimitType()
		return self.itemLimitType
end
--�޹�����
function MallObject:setItemLimitNum(itemLimitNum)
	self.itemLimitNum = itemLimitNum
end
function MallObject:getItemLimitNum()
	return self.itemLimitNum
end
--ʣ������
function MallObject:getItemPerDay()
	return self.perDayNum
end
function MallObject:setItemPerDay(perDayNum)
	self.perDayNum = perDayNum
end	
--�޹�ʱ��
function MallObject:getStoreLimitTime()
	return self.storeLimitTime
end
function MallObject:setStoreLimitTime(storeLimitTime)
	self.storeLimitTime = storeLimitTime
end

--�޹�ʱ��
function MallObject:getStoreLimitTime()
	return self.storeLimitTime
end
function MallObject:setStoreLimitTime(storeLimitTime)
	self.storeLimitTime = storeLimitTime
end

--�̵�����
function MallObject:getStoreType()
	return self.StoreType
end
function MallObject:setStoreType(StoreType)
	self.StoreType = StoreType
end	
--��ƷID  --������ȡ��Ʒ����
function MallObject:getItemId()
	return self.ItemId
end
function MallObject:setItemId(ItemId)
	self.ItemId = ItemId
end

function MallObject:setCoinPrice(price)
	self.coinPrice = price
	self.priceTypeList["gold"] = price			
end

function MallObject:getCoinPrice()
	return self.coinPrice
end

function MallObject:setGoldMedal(num)
	self.goldMedal = num
	self.priceTypeList["item_goldMedal"] = num			
end

function MallObject:setSliverMedal(num)
	self.sliverMedal = num
	self.priceTypeList["item_silverMedal"] = num		
end

function MallObject:setCopperMedal(num)
	self.copperMedal = num
	self.priceTypeList["item_copperMedal"] = num		
end

function MallObject:setIronMedal(num)
	self.ironMedal = num
	self.priceTypeList["item_ironMedal"] = num		
end

function MallObject:getGoldMedal()
	return self.goldMedal
end

function MallObject:getSliverMedal()
	return self.sliverMedal
end

function MallObject:getCopperMedal()
	return self.copperMedal
end

function MallObject:getIronMedal()
	return self.ironMedal
end


function MallObject:setNumber(Number)
	self.Number = Number
end

function MallObject:getNumber()
	return self.Number
end

function MallObject:setPrice(priceData)
	for k,v in pairs(priceData) do
		if v.refId=="gold" then
			self:setCoinPrice(v.number)	
		elseif v.refId == "item_ironMedal" then
			self:setIronMedal(v.number)
		elseif v.refId == "item_silverMedal" then
			self:setSliverMedal(v.number)
		elseif v.refId == "item_copperMedal" then
			self:setCopperMedal(v.number)
		elseif v.refId == "item_goldMedal" then
			self:setGoldMedal(v.number)
		elseif v.refId == "item_coupon" then
			self:setCoupon1(v.number)
		elseif v.refId == "item_coupon_2" then
			self:setCoupon2(v.number)
		elseif v.refId == "bindedGold" then
			self:setBindedGold(v.number)
		elseif v.refId == "unbindedGold" then
			self:setUnBindedGold(v.number)
		end																		
	end		
end
	
function MallObject:setObjPriceType(typeList)
	self.priceTypeList = typeList
end

function MallObject:getObjPriceType()
	return self.priceTypeList
end

function MallObject:setCoupon1(coupon1)
	self.coupon1 = coupon1
	self.priceTypeList["item_coupon"] = coupon1		
end

function MallObject:setCoupon2(coupon2)
	self.coupon2 = coupon2
	self.priceTypeList["item_coupon_2"] = coupon2	
end

function MallObject:getCoupon()
	return self.coupon	
end

function MallObject:__delete()
	
end
