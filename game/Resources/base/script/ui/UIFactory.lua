local Control_None ="None"
local Control_Sprite ="Sprite"
local Control_Label	 = "Label"
local Control_RichLabel	= "RichLabel"
local Control_ScrollView ="ScrollView"
local Control_TableView	 = "TableView"
local Control_Scale9Sprite = "Scale9Sprite"
local Control_TabView = "TabView"
local Control_Button = "Button"
local Control_RadioButton = "RadioButton"
local Control_CheckButton = "CheckButton"
local Control_EditBox = "EditBox"
local Control_TabViewControl  = "TabViewControl "

local factoryManager = SFControlFactoryManager:shareCCControlFactoryMgr()

function createSpriteWithFrameName(frameName)
	local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
	local frame = frameCache:spriteFrameByName(frameName)
	
	local sprite
	if frame then
		sprite = CCSprite:createWithSpriteFrame(frame)
	else
		print("createSpriteWithFrameName frame nil. frameName"..frameName)
	end
	return sprite
end

function createSpriteWithFileName(fileName)
	local sprite = CCSprite:create(fileName)
	return sprite
end

function createRichLabelWithRichText(richText)
	local richLabel = createObject(Control_RichLabel)
	richLabel =  tolua.cast(richLabel,"SFRichBox")
	richLabel:appendFormatText(richText)
	return richLabel
end

--[[
创建Label的时候，
dimension 不填，则显示一行文字
dimension(x,y) 的y指定为0时，Label会根据x自动分配高度
注意：dimension(x,y)的x、y都赋值且过大，文字位置则会默认以左下角对齐
--]]
function createLabelWithStringFontSizeColorAndDimension(input,font,size,color,dimension)
	local label 	
	if dimension then
		label = SFLabel:create(input, font, size, color)
		label:setDimensions(dimension)
	else
		label = SFLabel:create(input, font, size, color)
	end		
	return label
end
--[[
author: Zhan
用layoutConfig去创建label
layoutConfig格式{size = "Size2",color = "ColorOrange2",font = Config.fontName.fontName1 }
--]]
function createLabelWithConfig(layoutConfig,name,dimension)
	return createLabelWithStringFontSizeColorAndDimension(name,layoutConfig.font,FSIZE(layoutConfig.size),FCOLOR(layoutConfig.color),dimension)
end

--[[
创建一个EditBox
size:  			不能为0
bgFrameName:	背景图片的frameName, 不能为nil
]]
function createEditBoxWithSizeAndBackground(size, bgFrameName)
	if size:equals(CCSizeMake(0, 0)) == false and bgFrameName then	
		local background = createScale9SpriteWithFrameNameAndSize(bgFrameName, size)
		local eidtBox = CCEditBox:create(size, background)
		return eidtBox
	end
	print("createEditBoxWithSizeAndBackground failed. not(size:equals(CCSizeMake(0, 0)) == false and bgFrameName)")
	return nil
end

function createScale9SpriteWithFrameNameAndSize(spriteFrameName, cSize)
	local size = G_CCSizeMake(cSize)
	local scale9Sprite =  createScale9SpriteWithFrameName(spriteFrameName)
	if scale9Sprite then
		scale9Sprite:setPreferredSize(size)
	end	
	return scale9Sprite
end	

function createScale9SpriteWithFrameName(spriteFrameName, rectInsets)
	if spriteFrameName == "" then
		return nil
	end		
	
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteFrameName);
	if frame == nil then
		return nil
	end
	
	local scale9Sprite
	if rectInsets then
		rectInsets.origin.x = frame:getRect().origin.x + rectInsets.origin.x
		rectInsets.origin.y = frame:getRect().origin.y + rectInsets.origin.y
		scale9Sprite = CCScale9Sprite:createWithSpriteFrame(frame, rectInsets);					
	else
		scale9Sprite = CCScale9Sprite:createWithSpriteFrame(frame);		
	end

	return scale9Sprite
end

function createScale9SpriteWithFileName(fileName, rectInsets)
	if fileName == "" then
		return nil
	end		
	
	local scale9Sprite		
	if rectInsets then
		scale9Sprite = CCScale9Sprite:create(fileName, rectInsets);					
	else
		scale9Sprite = CCScale9Sprite:create(fileName);		
	end				
	return scale9Sprite
end

function createScrollViewWithSize(size)
	local scrollView = SFScrollView:create(size)
	return scrollView
end

--[[
 const char* normal,
const char* select, 
CCObject* target, 
SEL_CallFuncO action
]]
function createCheckButton(normal, selected, target, action)
	local checkButton =  SFCheckBox:create();
	checkButton:initControl(normal, selected, action);
	return checkButton
end

--[[
	need to implement
]]
function createRadioButton()
	local radioButton = SFBaseControl:create()	
	return radioButton
end

--创建9宫格按钮
--按钮点击弹起时回调消息为CCControlEventTouchDown
function createButton(normalscale9sprite,selectedscale9sprite,btnsize)
	local size = normalscale9sprite:getContentSize()
	if btnsize then
		size = btnsize
	end
	local button = CCControlButton:create(normalscale9sprite)
	button:setPreferredSize(size)
	button:setAdjustBackgroundImage(false)
	local scale = VisibleRect:SFGetScale()
	button:setScale(scale)		
	if selectedscale9sprite then	
		button:setBackgroundSpriteForState(selectedscale9sprite,CCControlStateSelected)
	end
	return button
end

--从pilst中读取图片创建按钮
function createButtonWithFramename(normalFrameName, selectedFrameName,btnsize)
	if not normalFrameName then
		print("create Button Error:normalFrameName is nil "..normalFrameName)
		return nil
	end	
	
	local normalsprite,selectedsprite
	normalsprite = createScale9SpriteWithFrameName(normalFrameName)
	
	if not normalsprite then
		print("create Button Error:normalsprite is nil "..normalFrameName)
		return nil
	end	
	
	if selectedFrameName then
		selectedsprite = createScale9SpriteWithFrameName(selectedFrameName)
	end
	
	local button = createButton(normalsprite,selectedsprite,btnsize)
	return button
end

--从路径中读取图片创建按钮
function createButtonWithFilename(normalFileName,selectedFileName,btnsize)
	if not normalFileName then
		print("create Button Error:normalFileName is nil "..normalFileName)
		return nil
	end	
	
	local normalsprite,selectedsprite
	normalsprite = createScale9SpriteWithFileName(normalFileName)	
	
	if not normalsprite then
		print("create Button Error:normalsprite is nil")
		return nil
	end	
	
	if selectedFileName then
		selectedsprite = createScale9SpriteWithFileName(selectedFileName)
	end
	
	local button = createButton(normalsprite,selectedsprite,btnsize)
	return button
end

function createTabView(controls, margin, mode)
	local tabView = SFTabView:create(controls, margin, mode)
	return tabView
end

--[[
	SFTableViewDataSource* dataSource, CCSize size
]]
function createTableView(dataHandler, size)
	local tabelView = SFTableView:create(nil, size)	
	tabelView:setDataHandler(dataHandler);
	return tabelView
end

function createGridBox(column,gridSize,count,margin)
	local gridBox = SFBagGridBox:create(column, gridSize, RES("bagBatch_iocnLock.png"))
	gridBox:addGrid(count)
	gridBox:setAllMargin(margin)
	gridBox:setContentSize(gridBox:getSize())
	return gridBox
end

function createJoyRock(radius, joyName, joyBgName, isFollow)
	--[[
	"UI_Mainctrl$ctrl2"
	"UI_Mainctrl$ctrl1"
	]]
	local bg = createSpriteWithFrameName(joyBgName)
	local joy = createSpriteWithFrameName(joyName)
	local joyRocker = SFJoyRocker:JoyRockerWithCenter(radius, joy, bg, isFollow)
	joyRocker:setOpacity(255*0.5)
	return joyRocker				
end

function createBaseActorView(modeId)
	local actorView = BaseActorView:create(modeId)
	return actorView
end	

function createProgressBar(bgImage, barImage, size)
	local bgSprite = createScale9SpriteWithFrameNameAndSize(bgImage, size)
	local barSprite = createScale9SpriteWithFrameNameAndSize(barImage, size)
	
	local obj = SFProgressBar:create(barSprite, size)
	obj:setBackground(bgSprite)		
	return obj
end


function createRichLabel(size)
	local richLabelNode = SFRichLabel:create()
	if size then
		richLabelNode:setDimensions(size)
	end
	return richLabelNode;
end
--[[
创建PageView
count： 总页数
index： 当前显示页数
--]]
function createPageIndicateView(count, index)
	local pageIndicateView = PageIndicateView:New()
	pageIndicateView:setPageCount(count, index)
	return pageIndicateView
end

--创建风格文字
--text：要显示的文字
--path：风格文字文件路径
function createStyleTextLable(text, path)
	path = ART_TEXT(path)
	if (path == nil or path == "") then
		return	
	end
	local label = CCLabelBMFont:create(text, path)
	return label
end
--[[
function creatTabViewControl()
	local TabViewControl = createObject(Control_TabViewControl)	
	TabViewControl = tolua.cast(TabViewControl,"SFTabViewControl")
	TabViewControl:initWithArray(ArrayOfctl);
	return TabViewControl
end
--]]

--创建美术数字
--name：数字对应的文件名，可在color.lua中Config.AtlasImg里参考
--number：要显示的数字，例如1546186
function createAtlasNumber(name,number)
	if name~=nil and number~=nil then			
		local fileName = ATLIMG_NAME(name)
		local itemSize = ATLIMG_SIZE(name)		
		local startCharMap = 48							
		local strNum = tostring(number)
		local labelAtlas = CCLabelAtlas:create(strNum,fileName,itemSize.width,itemSize.height,startCharMap)		
		return labelAtlas
	end	
end
	
--bgImage: 背景图，progressImage：进度条图片，thumbImage：指示箭头
function createControlSlider(bg, progress, thumb)
	local slider = CCControlSlider:create(bg, progress, thumb);
	return slider
end

--bgImage（CCScale9Sprite）: 背景图，progressImage（CCScale9Sprite）：进度条图片，thumbImage（Sprite）：指示箭头， size：尺寸
function createSFControlSlider(bg, progress, thumb, size)
	local slider = SFControlSlider:create(bg, progress, thumb,size)
	return slider
end

--创建帧动画精灵
--name:帧动画图片名称(不带数字下标和.png)
--number：图片数量(图片的下标从0开始)
--delay:设置帧频速度
--示例： local animate = createAnimate("fire",11,0.125)
function createAnimate(name,number,delay,startIndex)
	local animation = CCAnimation:create() 
	if(startIndex == nil) then
		startIndex =0
	end
	for i=startIndex,number do 
		local framename = RES(name..i..".png")				
		local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(framename)
		animation:addSpriteFrame(spriteFrame) 
	end 
	animation:setDelayPerUnit(delay)
	local animate = CCAnimate:create(animation)
	return animate	
end

--创建带长按回调的按钮
--normalImgName  按钮图片
--selectImgName  选中时的图片
--handlPressFunc 点击回调
--handleLongPressFunc     长按回调
function createLongPressButton(normalImgName,selectImgName,handlPressFunc,handleLongPressFunc)
	
	local Button = createButtonWithFramename(normalImgName,selectImgName)							
	--判断按下的时长是否大于0.5S   超过一秒算长按  
	local time 
	local countTimeSchedulerId
	local longPressSchedulerId
	local preessSchedulerId
	local countTime = function()
		time = time + 0.1
		if(time > 0.5 ) then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(countTimeSchedulerId)
			longPressSchedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(handleLongPressFunc, 0.05, false)	
		end		
	end	
	
	local autoFunc = function()	
		time = 0
		countTimeSchedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(countTime, 0.05, false)
	end							
	Button:addTargetWithActionForControlEvents(autoFunc,CCControlEventTouchDown)
	
	local stopFunc = function()
		if time <= 0.5 then	
			handlPressFunc()			
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(countTimeSchedulerId)
		else
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(longPressSchedulerId)
		end
	end
	
	Button:addTargetWithActionForControlEvents(stopFunc,CCControlEventTouchDown)
	Button:addTargetWithActionForControlEvents(stopFunc,CCControlEventTouchDragOutside)	
	Button:addTargetWithActionForControlEvents(stopFunc,CCControlEventTouchDragExit)
	Button:addTargetWithActionForControlEvents(stopFunc,CCControlEventTouchUpOutside)			
	Button:addTargetWithActionForControlEvents(stopFunc,CCControlEventTouchCancel)	
	
	return Button
end