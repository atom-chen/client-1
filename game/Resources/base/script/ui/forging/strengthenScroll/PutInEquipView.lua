-- 背包界面（游戏主界面点击背包时进入）
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.ItemView")
require("GameDef")

PutInEquipView = PutInEquipView or BaseClass(BaseUI) 

local const_scale = VisibleRect:SFGetScale()
local const_size_no_scale = CCSizeMake(297, 210)
local const_size = VisibleRect:getScaleSize(const_size_no_scale)
local const_bg_size = VisibleRect:getScaleSize(CCSizeMake(const_size_no_scale.width - 20, 360))


function PutInEquipView:create()
	return PutInEquipView.New()
end

function PutInEquipView:__init()
	self:initWithBg(const_size_no_scale, RES("squares_bg1.png"), false, false)		
	self.viewName = "PutInEquipView"
	
	local bg1 = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(254, 141))
	self:addChild(bg1)
	VisibleRect:relativePosition(bg1, self:getContentNode(), LAYOUT_CENTER)
	
	self.btn  = createButtonWithFramename(RES("bagBatch_itemBg.png"),RES("bagBatch_itemBg.png"),VisibleRect:getScaleSize(CCSizeMake(70, 70)))	
	local onClick = function()
		if (self.equip) then
			self:setEquip(nil)
			GlobalEventSystem:Fire(GameEvent.EventOpenEquipShowView, E_ShowOption.eRight, self.qianghuajuan)
			GlobalEventSystem:Fire(GameEvent.EventHideStrengthenScrollPreview)
		end
	end
	self.btn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
	self:addChild(self.btn)		
	VisibleRect:relativePosition(self.btn, self:getContentNode(), LAYOUT_CENTER, ccp(0, 0))	
	
	self.itemView = ItemView.New()
	self:addChild(self.itemView:getRootNode())		
	VisibleRect:relativePosition(self.itemView:getRootNode(), self:getContentNode(), LAYOUT_CENTER, ccp(0, 0))	
	self.itemView:showBg(false)	
		
	local title = createSpriteWithFrameName(RES("word_tip_inputEquip.png"))
	self:setFormTitle(title, TitleAlign.Center)		
end	

function PutInEquipView:onEnter(arg)
	if arg == nil then
		return
	end
	self.qianghuajuan = arg.qianghuajuan
	self:setEquip(arg.itemObj)		
end	

function PutInEquipView:setEquip(equip)
	self.equip = equip
	self.itemView:setItem(self.equip)
end

function PutInEquipView:onExit()
end
		
function PutInEquipView:getEquip()
	return self.equip
end

function PutInEquipView:__delete()
	if (self.itemView) then
		self.itemView:DeleteMe()
	end
end	