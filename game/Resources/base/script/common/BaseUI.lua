require("common.baseclass")

BaseUI = BaseUI or BaseClass()
local scale = VisibleRect:SFGetScale()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

local UIZOrder = 
{
	TopLeftNode = 100,
	Bg = -1,
}

TitleAlign = {
	Left = 1,
	Center = 2
}

ClosebtnType = {
	Close = 1,
	Back = 2,
}

local formImagePos = ccp(0, 0)
local formMenuHeight = 48
local formSpace = 21

function BaseUI:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setTouchEnabled(true)	
	self.rootNode:setContentSize(visibleSize)
	self.rootNode:retain()
	
	self.contentNode = CCNode:create()
	self.contentNode:setContentSize(visibleSize)
	self.contentNode:retain()
	self.rootNode:addChild(self.contentNode, 2)
	
	self.formTitle = nil
	self.formImage = nil
	
	self.viewName = ""
	self.topLeftNode = nil
	self.btnClose = nil
	self:registerScriptTouchHandler()
end

function BaseUI:__delete()
	if self.contentNode then
		self.contentNode:release()
		self.contentNode = nil
	end
	if self.rootNode then
		self.rootNode:release()
		self.rootNode = nil
	end
end

function BaseUI:registerScriptTouchHandler()
	local function ccTouchHandler(eventType, x,y)
		return self:touchHandler(eventType, x, y)
	end
	self.rootNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.View, true)
end

function BaseUI:touchHandler(eventType, x, y)
	if self.rootNode:isVisible() and self.rootNode:getParent() then
		local parent = self.rootNode:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = self.rootNode:boundingBox()
		if rect:containsPoint(point) then
			return 1
		else
			return 0
		end
	else
		return 0
	end
end	

-- 等同于CCNode的addChild
function BaseUI:addChild(node, zorder, tag)
	if node then
		if type(zorder) == "number" then
			self.contentNode:addChild(node, zorder)
		else
			self.contentNode:addChild(node)
		end
		
		if type(tag) == "number" then
			node:setTag(tag)
		end
	end
end

function BaseUI:removeChild(node)
	if (node) then
		self.contentNode:removeChild(node, true)
		node = nil
	end
end

function BaseUI:getRootNode()
	return self.rootNode
end

function BaseUI:getContentNode()
	return self.contentNode
end

function BaseUI:SetSize(size)
	self.rootNode:setContentSize(size)
	local size = CCSizeMake(viewSize.width-42, viewSize.height-69)
	self.contentNode:setContentSize(size)	
	
	VisibleRect:relativePosition(self.contentNode, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X, ccp(0, -48))
	self.viewSize = CCSizeMake(size.width-42, size.height-69)
	self:updateContentNode()
	VisibleRect:relativePosition(self.titleBg,self.background,LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE,ccp(0,-6), false)
	VisibleRect:relativePosition(self.btnClose,self.background,LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(-12,-12))
end

-- 把窗口居中
function BaseUI:makeMeCenter()
	local posX = (visibleSize.width - self.rootNode:getContentSize().width)/2
	local posY = (visibleSize.height - self.rootNode:getContentSize().height)/2
	
	self.rootNode:setPosition(posX, posY)
end

-- 设置左上角图标
function BaseUI:setFormImage(imageNode, offset)
	if imageNode then
		if self.formImage then
			self.formImage:removeFromParentAndCleanup(true)	
		end
		
		self.formImage = imageNode
		--[[if not  self.imageBg then
			self.imageBg = createSpriteWithFrameName(RES("common_lefttop_bg.png"))
			self.rootNode:addChild(self.imageBg,2)
			VisibleRect:relativePosition(self.imageBg, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(-25, 30))
		end]]
		self.imageBg = createSpriteWithFrameName(RES("common_lefttop_bg.png"))
		self.rootNode:addChild(self.imageBg,300)
		VisibleRect:relativePosition(self.imageBg, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(-25, 30))
		self.rootNode:addChild(imageNode,300)
		if offset then 
			VisibleRect:relativePosition(imageNode, self.imageBg, LAYOUT_CENTER, offset)
		else			
			VisibleRect:relativePosition(imageNode, self.imageBg, LAYOUT_CENTER)
		end
	end
end

-- 设置标题
function BaseUI:setFormTitle(titleNode, align)
	if titleNode then
		if self.formTitle then
			self.formTitle:removeFromParentAndCleanup(true)	
			self.formTitle = nil
		end
		
		self.formTitle = titleNode
		if align > TitleAlign.Center or align < TitleAlign.Left then
			CCLuaLog("Warning!!setFormTitle use undefine align")
			align = TitleAlign.Left
		end
		
		self.rootNode:addChild(titleNode,1)
		if align == TitleAlign.Left then
			if self.formImage then
				VisibleRect:relativePosition(titleNode, self.formImage, LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
			else
				VisibleRect:relativePosition(titleNode, self.rootNode, LAYOUT_LEFT_INSIDE, ccp(21, 0))
			end
		else
			VisibleRect:relativePosition(titleNode, self.rootNode, LAYOUT_CENTER_X, ccp(0, 0))
		end
		
		-- 标题总是相对标题栏居中
		local space = (formMenuHeight - titleNode:getContentSize().height)/2 + 5
		VisibleRect:relativePosition(titleNode, self.rootNode, LAYOUT_TOP_INSIDE, ccp(0, -space))
	end
end

function BaseUI:initFullScreen()
	local fullScreenSize = CCSizeMake(874, 564)
	self:init(fullScreenSize)
	return fullScreenSize
end

function BaseUI:initHalfScreen()
	local halfScreenSize = CCSizeMake(416, 564)
	self:init(halfScreenSize)
	return halfScreenSize
end

-- 初始化，使用默认的背景图，标题栏，以及显示关闭按钮
function BaseUI:init(size, pos)
	
	local viewSize
	if size then
		viewSize = CCSizeMake(size.width*scale,size.height*scale)
	else
		viewSize = visibleSize
	end
	
	self.rootNode:setContentSize(viewSize)
	local size = CCSizeMake(viewSize.width-42, viewSize.height-69)
	self.contentNode:setContentSize(size)
	VisibleRect:relativePosition(self.contentNode, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X, ccp(0, -48))	
	
	if pos then
		self.rootNode:setPosition(pos)
	else
		self:makeMeCenter()
	end
	
	-- 背景图
	--todo
	local rect = CCRectMake(71,14,2,20)
	self:createBackground(viewSize,nil,rect)
	
	-- 关闭按钮
	self:createCloseBtn()
	
	-- reload按钮, 只有windows才会打开
	if self.enableReload and os.getenv("OS") == "Windows_NT" then
		local btnReload = createButtonWithFramename(RES("btn_close.png"), RES("btn_close.png"))
		btnReload:setColor(ccc3(0, 255, 0))
		self.rootNode:addChild(btnReload)
		VisibleRect:relativePosition(btnReload,self.btnClose,LAYOUT_LEFT_OUTSIDE+LAYOUT_CENTER_Y,ccp(-10,0))
		local reloadFunction = function ()
			self:reload()
		end
		btnReload:addTargetWithActionForControlEvents(reloadFunction,CCControlEventTouchDown)
	end
end

function BaseUI:updateContentNode()
	local size = CCSizeMake(self.rootNode:getContentSize().width-42, self.rootNode:getContentSize().height-69)
	self.contentNode:setContentSize(size)
	VisibleRect:relativePosition(self.contentNode, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X, ccp(0, -48))
end

-- 使用自定义背景进行初始化
-- size: 大小
-- bgImage: 图片
-- bShowCloseBtn: 为true时显示关闭按钮，其他则不显示按钮
function BaseUI:initWithBg(size, bgImage, bShowCloseBtn, bShowTitleBg, rrect)
	self.rootNode:setContentSize(VisibleRect:getScaleSize(size))
	self:updateContentNode()
	self:createBackground(size, bgImage, rrect)
	if (bShowCloseBtn == true) then
		self:createCloseBtn()
	end
end

function BaseUI:removeFromRootNode(node)
	if (node) then
		self.rootNode:removeChild(node, true)
		node = nil
	end
end


--delay延迟多少秒消失，默认3秒 touchArea:可点击区域默认是屏蔽整个rootNode的点击事件的
function BaseUI:showLoadingHUD(delay,func,touchArea)
	local manager =UIManager.Instance
	manager:showLoadingHUD(delay,self:getContentNode(),func,touchArea)
end

--关闭loadingHUD
function BaseUI:hideLoadingHUD()
	local manager =UIManager.Instance
	manager:hideLoadingHUD()
end

function BaseUI:createCloseBtn(layoutPoint)
	if self.btnClose then
		self:removeFromRootNode(self.btnClose)
		self.btnClose = nil
	end
	
	self.btnClose = createButtonWithFramename(RES("btn_close.png"), RES("btn_close.png"))
	if not self.btnClose then
		CCLuaLog("BaseUI:createCloseBtn error. create failed.")
		return
	end
	self.btnClose:setTouchAreaDelta(8, 8, 12, 1)
	self.btnClose:setTouchPriority(UIPriority.Control)
	self.rootNode:addChild(self.btnClose, 50)
	if not layoutPoint then
		layoutPoint = ccp(-15, -5)
	end
	local btnCloseSize = self.btnClose:getContentSize()
	VisibleRect:relativePosition(self.btnClose,self.rootNode,LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE, layoutPoint)
	local exitFunction =  function ()
		if self.onCloseBtnClick then
			if self:onCloseBtnClick() ~= false then
				self:close()
			end
		else
			self:close()
		end
	end
	self.btnClose:addTargetWithActionForControlEvents(exitFunction,CCControlEventTouchDown)
end

--隐藏关闭按钮
function BaseUI:setVisiableCloseBtn(flag)
	if self.btnClose then
		self.btnClose:setVisible(flag)
	end
end

--重写该函数
function BaseUI:getNodeByName(name)
	return nil
end

function BaseUI:createBackground(size, bgImage, rect)
	self:removeFromRootNode(self.background)
	if (bgImage == nil) then
		bgImage = RES("squares_bg1.png")
	end		
	if (rect) then
		self.background = createScale9SpriteWithFrameName(bgImage, rect)
	else
		self.background = createScale9SpriteWithFrameName(bgImage)
	end
	self.background:setPreferredSize(size)
	self.rootNode:addChild(self.background)
	VisibleRect:relativePosition(self.background,self.rootNode,LAYOUT_CENTER)
end

function BaseUI:close()
	local rootNode = self.rootNode
	UIManager.Instance:hideDialog(rootNode)
	
	local ViewName = self.viewName
	UIManager.Instance:hideUI(self.viewName)
end

--关闭按钮点击时的回调函数
function BaseUI:onCloseBtnClick()
	return true
end

function BaseUI:createVipFrame(size, title)
	local frameSize = size
	if size then
		local framewidth = size.width
		if framewidth%2==0 then
			frameSize = CCSizeMake(framewidth+1,size.height)
		end
	else
		return 
	end
	
	self.rootNode:setContentSize(frameSize)
	local viewSize = CCSizeMake(frameSize.width-39*2, frameSize.height-40)
	self.contentNode:setContentSize(viewSize)
	VisibleRect:relativePosition(self.contentNode, self.rootNode, LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(0, 2))

	self:makeMeCenter()
	
	-- 背景图
	local tmptopBg = createScale9SpriteWithFrameNameAndSize(RES("vip_fram2.png"), CCSizeMake(frameSize.width-70, 46))
	local topMidLeftFrame = createSpriteWithFrameName(RES("vip_fram3.png"))
	local topMidRightFrame = createSpriteWithFrameName(RES("vip_fram3.png"))
	topMidRightFrame:setFlipX(true)
	local topLeftFrame = createSpriteWithFrameName(RES("vip_fram1.png"))
	local topRightFrame = createSpriteWithFrameName(RES("vip_fram1.png"))
	topRightFrame:setFlipX(true)
	
	
	--下方
	local bottomScaleFrame = createScale9SpriteWithFrameNameAndSize(RES("vip_fram4.png"), CCSizeMake(frameSize.width-23*2, frameSize.height-40))
	local bottomLeftFrame = createSpriteWithFrameName(RES("vip_fram5.png"))
	local bottomRightFrame = createSpriteWithFrameName(RES("vip_fram5.png"))
	bottomRightFrame:setFlipX(true)
	
	
	self.rootNode:addChild(bottomScaleFrame)		
	self.rootNode:setContentSize(frameSize)
	self.rootNode:addChild(tmptopBg)
	self.rootNode:addChild(topLeftFrame)
	self.rootNode:addChild(topRightFrame)	
	self.rootNode:addChild(topMidLeftFrame)
	self.rootNode:addChild(topMidRightFrame)
	self.rootNode:addChild(bottomLeftFrame)
	self.rootNode:addChild(bottomRightFrame)
			
	VisibleRect:relativePosition(tmptopBg, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_CENTER,ccp(0,-7))
	VisibleRect:relativePosition(topMidLeftFrame, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_CENTER, ccp(-topMidLeftFrame:getContentSize().width/2, 0))
	VisibleRect:relativePosition(topMidRightFrame, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_CENTER, ccp(topMidRightFrame:getContentSize().width/2, 0))	
	VisibleRect:relativePosition(topLeftFrame, self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,1))	
	VisibleRect:relativePosition(topRightFrame, self.rootNode, LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,1))	
	
	VisibleRect:relativePosition(bottomScaleFrame, self.rootNode, LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)	
	VisibleRect:relativePosition(bottomLeftFrame, bottomScaleFrame, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(-18, -10))
	VisibleRect:relativePosition(bottomRightFrame, bottomScaleFrame, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(18, -10))
	
	if title then
		self.rootNode:addChild(title)
		VisibleRect:relativePosition(title, self.rootNode, LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -15))
	end		
end

function BaseUI:createVipFrameCloseBtn(btntype,func,pos)
	if btntype==ClosebtnType.Back then
		self.btnVipCloseBtn = createButtonWithFramename(RES("btn_back.png"))
	else
		self.btnVipCloseBtn = createButtonWithFramename(RES("btn_close.png"))
	end
	
	if self.btnVipCloseBtn then	
		self.rootNode:addChild(self.btnVipCloseBtn, 50)	
		
		local offsetPos = ccp(-34,-11)
		if pos then
			offsetPos = pos
		end	
		VisibleRect:relativePosition(self.btnVipCloseBtn, self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE,offsetPos)

		local exitFunction = function ()
			if func then
				func()
			else
				self:close()
			end
		end
		self.btnVipCloseBtn:addTargetWithActionForControlEvents(exitFunction,CCControlEventTouchDown)
	end
end	

function BaseUI:setViewName(name)
	self.viewName = name	
end