require("common.baseclass")
require("common.BaseObj")

ItemObject = ItemObject or BaseClass(BaseObj)

function ItemObject:__init()
	self.auctionPrice = 0
end

-- ��ȡGridId
function ItemObject:getGridId()
	return self.gridId
end

-- ����GridId
function ItemObject:setGridId(id)
	self.gridId = id
end		

function ItemObject:setSource(source)
	self.source = source
end		

function ItemObject:getSource()
	return self.source
end		


-- ��ȡ����
function ItemObject:getType()
	return G_getItemTypeByRefId(self.refId)
end

-- ���þ�̬����
function ItemObject:setStaticData(data)
	self.staticData = data
end	

function ItemObject:getAreaOfBody(staticData)
	return PropertyDictionary:get_areaOfBody(staticData.property)
end

-- ��ȡ��̬���ݣ���Ӧ��GameData.ItemDrug, GameData.ItemEgg��
function ItemObject:getStaticData()
	if not self.staticData then
		self.staticData = G_getStaticDataByRefId(self.refId)
	end		
	return self.staticData	
end	

function ItemObject:getNumber()
	return PropertyDictionary:get_number(self:getPT())
end

function ItemObject:getContentStaticData()
	return G_getContentStaticDataByRefId(self.refId)
end

-- ���������ֵ䣬���滻֮ǰ��
function ItemObject:setWashPT(propertyTable)
	self.washPT = propertyTable	
end

function ItemObject:updateWashPT(pt)
	for k, v in pairs(pt) do
		self.washPT[k] = v
	end
end

-- ��ȡ�����ֵ�	
function ItemObject:getWashPT()
	return self.washPT	
end	

function ItemObject:setPosId(pos)
	self.posId = pos
end

function ItemObject:getPosId()
	return self.posId
end

function ItemObject:setAuctionPrice(price)
	self.auctionPrice = price
end	

function ItemObject:getAuctionPrice()
	return self.auctionPrice
end
