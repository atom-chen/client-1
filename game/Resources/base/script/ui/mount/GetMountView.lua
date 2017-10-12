-- 显示坐骑详情 
require("ui.UIManager")
require("common.BaseUI")
require("gameevent.GameEvent")
require("config.color")

local grideSize = VisibleRect:getScaleSize(CCSizeMake(85,85))
GetMountView = GetMountView or BaseClass(BaseUI)

local width = 400
local height = 300
local scale = VisibleRect:SFGetScale()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

function GetMountView:__init()
	self.viewName = "GetMountView"	
	self:init(CCSizeMake(width,height))
	self:setVisiableCloseBtn(false)
	local titleLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[1029], "Arial", FSIZE("Size4")*scale, FCOLOR("ColorYellow3"))
	VisibleRect:relativePosition(titleLabel,self.background,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE,ccp(0,-30))	
	self.background:addChild(titleLabel)
	--坐骑Icon格子
	local gridBg = createScale9SpriteWithFrameNameAndSize(RES("talisman_bg.png"),grideSize)
	VisibleRect:relativePosition(gridBg,self.background,LAYOUT_CENTER,ccp(0,30))	
	self.background:addChild(gridBg)
	--坐骑Icon 
	local gridItem = createSpriteWithFileName(ICON("ride_1"))
	VisibleRect:relativePosition(gridItem,self.background,LAYOUT_CENTER,ccp(0,30))	
	self.background:addChild(gridItem)
	--描述文本
	local descLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[1040], "Arial", FSIZE("Size2")*scale, FCOLOR("ColorWhite1"))
	VisibleRect:relativePosition(descLabel,gridBg,LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE,ccp(0,-20))	
	self.background:addChild(descLabel)
		
	--确定按钮
	local btCommit = createButtonWithFramename(RES("btn_1_select_select.png.png"), RES("btn_1_select_select.png.png"))	
	VisibleRect:relativePosition(btCommit,self.background,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE,ccp(0,-220))
	local text = createLabelWithStringFontSizeColorAndDimension(Config.Words[10134], "Arial", FSIZE("Size2")* scale, FCOLOR("ColorWhite1"))			
	btCommit:setTitleString(text)
	btCommit:setScale(scale)		
	self.background:addChild(btCommit)
	local Btn_Clickfunc = function ()
		--发送请求
		local mgr = GameWorld.Instance:getMountManager()
		mgr:requestGetMountAward()
		--关闭窗口
		self:close()	
	end
	btCommit:addTargetWithActionForControlEvents(Btn_Clickfunc,CCControlEventTouchDown)
	
end	

function GetMountView:create()
	return GetMountView.New()
end

function GetMountView:getRootNode()
	return self.rootNode
end

function GetMountView:initItem()

end

function GetMountView:__delete()
	
end
