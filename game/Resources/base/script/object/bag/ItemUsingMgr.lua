--  ʹ����Ʒ
require("common.baseclass")
require("object.bag.BagDef")

ItemUsingMgr = ItemUsingMgr or BaseClass()

function ItemUsingMgr:__init()
end	

--[[
ʹ����Ʒ������װ��Ϊ���� ��������ͨ��Ʒ��Ϊʹ��
	itemObj: ��Ҫʹ�õ���Ʒ
	count  : ʹ������
--]]
function ItemUsingMgr:useItem(itemObj, count)
end

--[[
��������������
	ret : false/true
	des	: ����ʹ�õ�ԭ��
--]]
function ItemUsingMgr:checkCanUse(itemObj)
	
end

--[[
��������������
	ret : false/true
	des	: ���ܳ��۵�ԭ��
--]]
function ItemUsingMgr:checkCanSell(itemObj)
	
end	