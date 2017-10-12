--[[���ݶ���Ļ���
���������ݶ���̳У���ItemObject(��Ʒ����)��EntityObject��ʵ�����
-]]

require("common.baseclass")

BaseObj = BaseObj or BaseClass()

function BaseObj:__init()
	self.table = {}
end

function BaseObj:__delete()
	
end

-- ���������ֵ䣬���滻֮ǰ��
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

-- ��ȡ�����ֵ�	
function BaseObj:getPT()
	return self.table	
end	

-- ��ȡid
function BaseObj:getId()
	return self.id 
end

-- ����id
function BaseObj:setId(id)
	self.id = id
end

-- ��ȡ����id
function BaseObj:getRefId()
	return self.refId 
end

-- ��������id
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