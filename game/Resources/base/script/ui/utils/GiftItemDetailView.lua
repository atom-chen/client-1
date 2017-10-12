require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.ItemView")
require("object.bag.BagDef")
require("ui.utils.BaseItemDetailView")

GiftItemDetailView = GiftItemDetailView or BaseClass(BaseItemDetailView)

local const_scale = VisibleRect:SFGetScale()

function GiftItemDetailView:create()
	return GiftItemDetailView.New()
end

function GiftItemDetailView:__init()
	self.viewName = "GiftItemDetailView"
	self.itemViewList = {}
end		
	
-- 显示item的各种属性
function GiftItemDetailView:onUpdataItem(item)
	self:showItemDes()		
end	

--------------以下为私有接口-------------------

function GiftItemDetailView:showItemDes()
	for k,v in pairs(self.itemViewList) do
		v:DeleteMe()
		self.itemViewList[k]=nil
	end
	
	local content = self.item:getContentStaticData()
	local size = CCSizeMake(300,200)
	local scrollNode = CCNode:create()
	scrollNode:setContentSize(size)
	local num = 1	
	
	for k,v in pairs(content) do
		local itemObj = ItemObject.New()
		itemObj:setStaticData(G_getStaticDataByRefId(v.itemRefId))
		itemObj:setRefId(v.itemRefId)
		itemObj:setPT(v)
		self.itemViewList[num] = ItemView.New()
		self.itemViewList[num]:setItem(itemObj)
		self.itemViewList[num]:showText(true)
		local icon = self.itemViewList[num]:getRootNode()
		scrollNode:addChild(icon)
		local yOffset = math.modf((num-1)/3)
		local xOffset = math.mod((num-1),3)
		VisibleRect:relativePosition(icon, scrollNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(19+xOffset*90,-10-(yOffset*90)))
		num = num + 1
		itemObj:DeleteMe()
	end
	self:setScrollNode(scrollNode)
end								