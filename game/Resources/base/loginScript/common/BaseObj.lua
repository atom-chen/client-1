--[[数据对象的基类
被各个数据对象继承，如ItemObject(物品对象)，EntityObject（实体对象）
-]]

require("common.baseclass")

BaseObj = BaseObj or BaseClass()

function BaseObj:__init()
	self.table = {}
end

function BaseObj:__delete()
	
end

-- 设置属性字典，会替换之前的
function BaseObj:setPT(propertyTable)
	if type(propertyTable) == "table" then
		self.table = propertyTable
	end			
end

function BaseObj:updatePT(pt)
	if type(pt) ~= "table" then
		return
	end
	if type(self.table) ~= "table" then
		self.table = {}
	end
	for k, v in pairs(pt) do
		self.table[k] = v
	end
end

-- 获取属性字典	
function BaseObj:getPT()
	return self.table	
end	

-- 获取id
function BaseObj:getId()
	return self.id 
end

-- 设置id
function BaseObj:setId(id)
	self.id = id
end

-- 获取引用id
function BaseObj:getRefId()
	return self.refId 
end

-- 设置引用id
function BaseObj:setRefId(refId)
	self.refId = refId
end	

function BaseObj:getProperty(propertyName)
	if type(propertyName) == "string" then
		return self.table[propertyName]
	end
end

function BaseObj:setProperty(propertyName, value)
	if type(propertyName) == "string" then
		self.table[propertyName] = value
	end
end