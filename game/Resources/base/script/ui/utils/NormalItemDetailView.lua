-- 显示背包的详情
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.ItemView")
require("object.bag.BagDef")
require("ui.utils.BaseItemDetailView")

NormalItemDetailView = NormalItemDetailView or BaseClass(BaseItemDetailView)

local const_scale = VisibleRect:SFGetScale()

function NormalItemDetailView:create()
	return NormalItemDetailView.New()
end

function NormalItemDetailView:__init()
	self.viewName = "NormalItemDetailView"
end		
	
-- 显示item的各种属性
function NormalItemDetailView:onUpdataItem(item)
	self:showItemDes()		
end	

--------------以下为私有接口-------------------

function NormalItemDetailView:showItemDes()
	local des 
	local viewSize = self:getScrollViewSize()	
	if (self.item == nil or self.item:getStaticData() == nil) then
		des = "-1"
	else
		des = PropertyDictionary:get_description(self.item:getStaticData().property)
	end
	
	if (des == "") then
		des = " "
	end
	
	local desLabel = createLabelWithStringFontSizeColorAndDimension(des, "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorWhite2"), CCSizeMake(viewSize.width-10, 0))--设置高为0，让其自动调节	
	
	local scrollNode = CCNode:create()			
	local size = CCSizeMake(desLabel:getContentSize().width, desLabel:getContentSize().height)
	if (size.height < viewSize.height) then
		size.height = viewSize.height
	end
	scrollNode:setContentSize(size)
	scrollNode:addChild(desLabel)
	VisibleRect:relativePosition(desLabel, scrollNode, LAYOUT_CENTER,ccp(10,0))		
	
	self:setScrollNode(scrollNode)
end	

function NormalItemDetailView:getUseBtnNode()
	--[E_ItemDetailBtnType.eUse]			= 	{text =  "word_button_use.png", 	onClick = self.useItem,	  	obj = nil},	
	local useBtnNode = self.btnArray[E_ItemDetailBtnType.eUse].obj
	if useBtnNode then
		return useBtnNode
	end
end							