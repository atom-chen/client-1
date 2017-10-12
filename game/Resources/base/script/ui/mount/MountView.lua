-- 显示坐骑详情 
require("ui.UIManager")
require("common.BaseUI")
require("ui.utils.MessageBox")
require("gameevent.GameEvent")
require("object.mount.MountDef")
require("object.mall.MallDef")
require("config.color")
require ("data.mount.mount")
MountView = MountView or BaseClass(BaseUI)

local scale = VisibleRect:SFGetScale()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

local MountSelected = 1  --记录被选择的item号
local MountNum = 0
local selList = {}
local TAGICON = 100
local width = 860
local height = 540
local cellSize = VisibleRect:getScaleSize(CCSizeMake(100,85))
local grideSize = VisibleRect:getScaleSize(CCSizeMake(100,105))

local ExpNum = 0


function MountView:__init()
--	UIManager.Instance:registerUI("MessageBox",MessageBox.create)
	self.viewName = "MountView"	
	self:initFullScreen()--init(CCSizeMake(width,height))
	self.eventType = {}	-- tableview的数据类型
	self.baojiTipsCount = 0
	self.isFirstOpen = true
	self.preLevel = -1

	self.maxJishu = table.size(GameData.Mount)
	MountNum = math.floor(self.maxJishu/4)
	local mgr = GameWorld.Instance:getMountManager()
	self.cuRefId = mgr:getCurrentUseMountId()
	if self.cuRefId ~= -1 then
		self.currentExp = mgr:getCurrentMountExp()	
		local recordItem = G_GetMountRecordByRefId(self.cuRefId)		
		local expTabel = recordItem.property	
		self.selectedCell = 1			
		local maxExp = PropertyDictionary:get_maxExp(expTabel)
		self:initVariable()	
		self:initItem()	
		self.percentage = 100*(self.currentExp/maxExp)		
		self:setProcessBar(self.percentage , maxExp )		
		self.isAutoUpGrade = false				
	end

	self.aniModeSprite = CCSprite:create()
	self:addChild(self.aniModeSprite,2) 
	VisibleRect:relativePosition(self.aniModeSprite,self.centelViewBgSprite, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X, ccp(-27, 215))	
		
end

function MountView:onEnter()
	self.needTips = true
	local mgr = GameWorld.Instance:getMountManager()
	self.cuRefId = mgr:getCurrentUseMountId()	
	self:SetMountProperty(self.cuRefId)
	self:setDetailsView(self.cuRefId)	
	self:setStarAndLevel(self.cuRefId)		
	
	local rtwMgr = GameWorld.Instance:getLevelAwardManager()	
	local isRideAward = rtwMgr:getIsRideAward()	
	if isRideAward then
		GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesRideAward()--打开新手指引
	end
end

function MountView:UpdateMountView(refId,Exp)	
	local mgr = GameWorld.Instance:getMountManager()
	if( self.cuRefId == refId  and Exp == 0) then	
	else			
		self.startIndex = tonumber(string.sub(self.cuRefId,6))
		self.endIndex = tonumber(string.sub(refId,6))	

		local function setItem()
			if(self.cuIndex < self.endIndex) then
				self.cuIndex = self.cuIndex + 1 
			end				
			self.cuRefId = "ride_" .. self.cuIndex
	
			if(self.cuIndex  ==  self.maxJishu ) then
				self.aniSpr:stopAllActions()
				self:handMaxLevel()
				local AutoImproveLabel =  createSpriteWithFrameName(RES("word_button_aotupromote.png"))	
				self.AutoImproveBtn:setTitleString(AutoImproveLabel)
			end							
			self:SetMountProperty(self.cuRefId)
			self:setDetailsView(self.cuRefId)	
			self:setStarAndLevel(self.cuRefId)	
		end		
		
		local function sendFeedRequest()
			if(self:getExpItem() >= G_GetNeedItemNum(mgr:getCurrentUseMountId()) ) then			
				mgr:requestMountFeed("item_zuoqiExp",G_GetNeedItemNum(mgr:getCurrentUseMountId()))
			else
				local AutoImproveLabel =  createSpriteWithFrameName(RES("word_button_aotupromote.png"))
				self.AutoImproveBtn:setTitleString(AutoImproveLabel)
				self.isAutoUpGrade = false
			end
		end
		
		self.endExp = Exp
		
		if(self.startIndex == self.endIndex) then			
			local curecord = G_GetMountRecordByRefId(refId)
			local maxExp = PropertyDictionary:get_maxExp(curecord.property)
			self.endMaxExp = maxExp													
			self.cuIndex = self.startIndex				
			self.percentage = 100*(self.currentExp/maxExp)	
			local function AddExp(sender)						
				if(self.percentage <= 100*(Exp/maxExp)) then				
					self.percentage = self.percentage + 1
					self.currentExp = self.percentage*maxExp/100
					if self.percentage <= 100*(Exp/maxExp) then					
						self:setProcessBar(self.percentage ,maxExp)														
					end																	
				else
					self.aniSpr:stopAllActions()				
					self.percentage = 100*Exp/maxExp		
					self:setProcessBar(self.percentage , maxExp)								
					self:setExpItem(self:getExpItem())					
					if( self.isAutoUpGrade == true  and  tonumber(string.sub(mgr:getCurrentUseMountId(),6)) < self.maxJishu ) then
						sendFeedRequest()										
					end																			
				end										
			end							
			local dt = 0.01
			local array = CCArray:create()	
			array:addObject(CCCallFuncN:create(AddExp));	
			array:addObject(CCDelayTime:create(dt));	
			local action = CCSequence:create(array)						
			local forever = CCRepeatForever:create(action) 	
			self.aniSpr:runAction(forever)
		else					
			local tableMaxExp = {}				
			for i = self.startIndex , self.endIndex  do
				local curecord = G_GetMountRecordByRefId("ride_" .. i)
				local maxExp = PropertyDictionary:get_maxExp(curecord.property)
				tableMaxExp[i] = maxExp
				self.endMaxExp = maxExp
			end							
			self.cuIndex = self.startIndex		
			self.percentage = 100*(self.currentExp/(tableMaxExp[self.startIndex]))
							
			local function UpdateExp(sender)
				local tableMaxExp = {}				
				for i = self.startIndex , self.endIndex  do
					local curecord = G_GetMountRecordByRefId("ride_" .. i)
					local maxExp = PropertyDictionary:get_maxExp(curecord.property)
					tableMaxExp[i] = maxExp
					--self.endMaxExp = maxExp
				end				
				if(self.cuIndex < self.maxJishu ) then	
					if(self.cuIndex < self.endIndex  or  self.percentage*0.01*tableMaxExp[self.endIndex] < Exp ) then
						if(self.percentage<100) then
							self.percentage = self.percentage +1
							self.currentExp = self.percentage*tableMaxExp[self.cuIndex]/100
							self:setProcessBar(self.percentage , tableMaxExp[self.cuIndex])	
						else
							self:setProcessBar(100 , tableMaxExp[self.startIndex])
							self:showLevelUp(self.cuIndex)
							setItem()
							self.percentage = 0					
						end
					else
						self.aniSpr:stopAllActions()
						self.expLabel:setString(Exp.."/".. tableMaxExp[self.endIndex])
						local percentage  = 100*(Exp/tableMaxExp[self.endIndex])					
						self:setProcessBar(percentage ,tableMaxExp[self.endIndex])					
						
						setItem()						
						--self.aniSpr:stopAllActions()	
						if( self.isAutoUpGrade == true  and  tonumber(string.sub(mgr:getCurrentUseMountId(),6)) < self.maxJishu ) then
							sendFeedRequest()
						else						
						end	
					end
				else								
				end			
			end							
			local dt = 0.01
			local array = CCArray:create()	
			array:addObject(CCCallFuncN:create(UpdateExp));	
			array:addObject(CCDelayTime:create(dt));	
			local action = CCSequence:create(array)						
			local forever = CCRepeatForever:create(action) 	
			self.aniSpr:runAction(forever)
		end			
	end		
end

function MountView:handMaxLevel()
	local preRefId = "ride_" .. (self.maxJishu - 1)
	local record = G_GetMountRecordByRefId(preRefId)
	local maxExp = PropertyDictionary:get_maxExp(record.property)				
	self.expLabel:setString(maxExp .. "/" .. maxExp)
	self.expProcessbar:setPercentage(100)	
	
	self.fightPowerLableHead:setVisible(false)
	self.fightPowerLable:setVisible(false)	
	self.MountExpItemLabelHead:setVisible(false)	
	self.MountExpItemLabel:setVisible(false)			
	self.ExpItemCostLabelHead:setVisible(false)	
	self.MountExpItemCostLabel:setVisible(false)	
	self.ImproveBtn:setVisible(false)
	self.AutoImproveBtn:setVisible(false) 	
end

--根据refId  初始化坐骑提升属性控件
function MountView:SetMountProperty(refId)
	self.mountList = G_GetCurrentList(refId)	
	recordItem = G_GetMountRecordByRefId(refId)	
	if( recordItem == nil ) then
		return 
	end	

	local mgr = GameWorld.Instance:getMountManager()
	local curTabel = recordItem.effectData		
	local expTabel = recordItem.property	
	local nextrecord = G_GetMountRecordByRefId(PropertyDictionary:get_rideNextRefId(recordItem.property))	
	
	self:setImprovePower(PropertyDictionary:get_fightValue(expTabel))
	self.cuRefId = refId
	self.currentExp = mgr:getCurrentMountExp()	
	
	self.step =(PropertyDictionary:get_maxExp(expTabel) -  mgr:getCurrentMountExp())*0.1
	--设置战斗力提升值
	if(nextrecord)then
		self.fightPowerLable:setString(PropertyDictionary:get_fightValue(nextrecord.property ) - PropertyDictionary:get_fightValue(expTabel))		
	else
		self.fightPowerLable:setString("0")			
	end
	self.MountExpItemCostLabel:setString( G_GetNeedItemNum(mgr:getCurrentUseMountId()))                                         
	
end	 

function MountView:setStarAndLevel(refId)
	local id = tonumber(string.sub(refId,6))
	local index = self:GrideIndex(id)
	level = (id-1)%4
	self:setStar(level)
	self:setJieShu(index)
	self:setMountName(index)
	self:setExpItem(self:getExpItem())	

	self.selectedCell = index
	self.MountTable:scroll2Cell(self.selectedCell-1 , false)  --滚动到当前icon	
	self.MountTable:updateCellAtIndex(index-1)	
	
	--播放帧动画
	self.aniModeSprite:stopAllActions()
	local animationId = G_GetMountIcon(self.mountList[self.selectedCell]).."_0000"
	local animation = createAnimate(animationId, 3, 0.2 , 0)		
	local forever = CCRepeatForever:create(animation) 
	self.aniModeSprite:runAction(forever)	
		
end

function MountView:create()
	return MountView.New()
end

--设置坐骑名字 
function MountView:setMountName(index)
	--坐骑名标签
	if( self.MountNameSprite ==nil ) then
		self.MountNameSprite = createSpriteWithFrameName(RES("ride_Name_".. index ..".png"))	
		VisibleRect:relativePosition(self.MountNameSprite, self.nameBg, LAYOUT_CENTER)
		self:addChild(self.MountNameSprite)						
	else	
		if( self.MountNameSprite:getParent() ~= nil ) then
			self.MountNameSprite:removeFromParentAndCleanup(true)
		end
		self.MountNameSprite = createSpriteWithFrameName(RES("ride_Name_".. index ..".png"))			
		VisibleRect:relativePosition(self.MountNameSprite, self.nameBg, LAYOUT_CENTER)
		self:addChild(self.MountNameSprite)
	end
end

--设置经验丹数量 传入数量
function MountView:setExpItem(ItemNum)
	self.MountExpItemLabel:setString(ItemNum)	
end

--设置坐骑阶数  传入数字即可（1，2，3，4，5）
function MountView:setJieShu(index)
	self.MountJieShuLabel:setString(Config.Words[1029 + index ])
end

--设置战斗力提升值  传入数字
function MountView:setImprovePower(impStr)
	self.MountPowerImproveLabel:setString(impStr)
end

--设置进度条
function MountView:setProcessBar(curentpercent,MaxExp)
	if(self.cuRefId ~= "ride_" .. self.maxJishu) then
		self.expProcessbar:setPercentage(curentpercent)
		self.expLabel:setString((curentpercent*MaxExp*0.01) .."/".. MaxExp)
	else
		self:handMaxLevel()					
	end
end

function  MountView:setStar(Num)
	if( Num == 0 ) then	
		self.Star1:setVisible(false)
		self.Star2:setVisible(false)
		self.Star3:setVisible(false)
	elseif(Num == 1 ) then	
		self.Star1:setVisible(true)
		self.Star2:setVisible(false)
		self.Star3:setVisible(false)
	elseif( Num == 2 ) then
		self.Star1:setVisible(true)
		self.Star2:setVisible(true)
		self.Star3:setVisible(false)				
	elseif(Num ==3) then
		self.Star1:setVisible(true)
		self.Star2:setVisible(true)
		self.Star3:setVisible(true)
	else
	end					
end

function MountView:getRootNode()
	return self.rootNode
end

--播放动画  参数：动画ID
function MountView:PlayAnimation(animationId)
	
end

function MountView:DecreaseItemNum(label,decNum)
	label:setString(tonumber(label:getString())-decNum)		
end

function MountView:ClearItemNum(label)
	label:setString("0")
end	
------------------------私有接口---------------------------------

function MountView:initVariable()
	--tableview数据源的类型
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3
	self.cellFrame = createScale9SpriteWithFrameName(RES("mall_goodsframe_selected.png"))
	self.aniSpr = CCSprite:create()
	self:addChild(self.aniSpr)
	self.cellFrame:retain()	
	self.clickFlag = true	
end

function MountView:createItem(index)	
	local item = CCNode:create()
	item:setContentSize(grideSize)
	--背景
	local cellBg = createScale9SpriteWithFrameName(RES("mall_goodsframe.png"))		
	VisibleRect:relativePosition(cellBg,item,LAYOUT_CENTER)
	item:addChild(cellBg)
	if index < 9  then
		local line = createScale9SpriteWithFrameName(RES("left_line.png"))
		VisibleRect:relativePosition(line,item,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)
		item:addChild(line)	
	end	
	
	local iconName = "ride_" .. index+1
	local icon = createSpriteWithFileName(ICON(iconName))
	if self.cuRefId == nil then	
		UIControl:SpriteSetGray(icon)
		UIControl:SpriteSetGray(cellBg)
	elseif index + 1 > self:GrideIndex(tonumber(string.sub(self.cuRefId,6)))  then
		UIControl:SpriteSetGray(icon) --未开启设置为黑白
		UIControl:SpriteSetGray(cellBg)
	else
		UIControl:SpriteSetColor(icon)
		UIControl:SpriteSetColor(cellBg)
	end		
	cellBg:addChild(icon)
	VisibleRect:relativePosition(icon,cellBg,LAYOUT_CENTER)
	return item
end	

function MountView:initItem()
	self:setFormImage( createSpriteWithFrameName(RES("main_mounts.png")))
	self:setFormTitle( createSpriteWithFrameName(RES("word_window_ride.png")),TitleAlign.Left)		

	self.centelViewBgSprite =  createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),self:getContentNode():getContentSize())
	self:addChild(self.centelViewBgSprite)	
	VisibleRect:relativePosition(self.centelViewBgSprite, self:getContentNode(), LAYOUT_CENTER)

	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")		
		self.selectedCell  = cell:getIndex()+1								
		self.MountTable:updateCellAtIndex(self.selectedCell-1)	

		rideList = self.mountList			
		recordItem = G_GetMountRecordByRefId( rideList[self.selectedCell] )	
		local id = tonumber(string.sub(rideList[self.selectedCell],6))
		local index = self:GrideIndex(id)
		level = (id-1)%4
		
		self:setStar(level)
		self:setJieShu(index)
		self:setMountName(index)				
		self:setImprovePower(PropertyDictionary:get_fightValue(recordItem.property))		
		--todo
		self.aniModeSprite:stopAllActions()		
		local animationId = G_GetMountIcon(rideList[self.selectedCell]).."_0000"
		local animation = createAnimate(animationId, 3, 0.2 , 0)		
		local forever = CCRepeatForever:create(animation) 
		self.aniModeSprite:runAction(forever)									
	end	
	function dataHandler(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(grideSize))
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(grideSize))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)		
			if tableCell == nil then
				tableCell = SFTableViewCell:create()
				tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
				local item = self:createItem(index)
				tableCell:addChild(item)
				data:setCell(tableCell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
				local item = self:createItem(index)				
				tableCell:addChild(item)
				data:setCell(tableCell)
			end
			tableCell:setIndex(index)										
			if self.selectedCell == index+1 then	
				if(self.cellFrame : getParent() == nil) then
					tableCell:addChild(self.cellFrame)				
					VisibleRect:relativePosition(self.cellFrame,tableCell,LAYOUT_CENTER)
				else 
					self.cellFrame : removeFromParentAndCleanup(true)
					tableCell:addChild(self.cellFrame)					
					VisibleRect:relativePosition(self.cellFrame,tableCell,LAYOUT_CENTER)
				end							
			end																						
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			data:setIndex(MountNum)
			return 1
		end
	end			

	--创建tableview
	if(self.MountTable)then
		self.MountTable:removeFromParentAndCleanup(true)		
	end	
	--tableViewBg	
	local tableViewBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), CCSizeMake(132, 452))
	self:addChild(tableViewBg)
	VisibleRect:relativePosition(tableViewBg, self.centelViewBgSprite, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE, ccp(13, 14))
	--preview
	local previewBg = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"), CCSizeMake(133, 33))
	tableViewBg:addChild(previewBg)
	VisibleRect:relativePosition(previewBg, tableViewBg, LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE)
	local previewLable = createSpriteWithFrameName(RES("word_label_imagepreview.png"))
	tableViewBg:addChild(previewLable)
	VisibleRect:relativePosition(previewLable, previewBg, LAYOUT_CENTER)
	
	self.MountTable = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(130, 410)))
	self.MountTable:reloadData()
	self.MountTable:setTableViewHandler(tableDelegate)
	self.MountTable:scroll2Cell(0, false)  --回滚到第一个cell
	tableViewBg:addChild(self.MountTable)		

	VisibleRect:relativePosition(self.MountTable, tableViewBg, LAYOUT_CENTER, ccp(15, -10))
			
	local mount_bg = CCSprite:create("ui/ui_img/common/wingBg.pvr")		
	self:addChild(mount_bg)
	VisibleRect:relativePosition(mount_bg, self.centelViewBgSprite,LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-13, 14))	
			
	--战斗力			
	local powerSpriteBg = createScale9SpriteWithFrameName(RES("ride_fade_sprite.png"))
	powerSpriteBg:setScaleX(1.5)	
	powerSpriteBg:setOpacity(150)
	self:addChild(powerSpriteBg)
	VisibleRect:relativePosition(powerSpriteBg,self.centelViewBgSprite,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(-40,-30))
	
	local powerSprite = createScale9SpriteWithFrameName(RES("ride_power.png"))
	self:addChild(powerSprite)
	VisibleRect:relativePosition(powerSprite,powerSpriteBg,LAYOUT_CENTER)
	
	self.MountPowerImproveLabel = createAtlasNumber(Config.AtlasImg.FightNumber,"")
	self.MountPowerImproveLabel:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(self.MountPowerImproveLabel,powerSprite,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(-90,2))
	self:addChild(self.MountPowerImproveLabel)
	
	local function createStar(x,y)	
		local starBg = createScale9SpriteWithFrameName(RES("common_star.png"))		
		self:addChild(starBg)
		VisibleRect:relativePosition(starBg,self.centelViewBgSprite,LAYOUT_CENTER_X +LAYOUT_TOP_INSIDE,ccp(x,y))
		starBg:setScale(0.84)
		local Star = createScale9SpriteWithFrameName(RES("common_star.png"))	
		Star:setAnchorPoint(ccp(0,0))
		starBg:addChild(Star)
		starBg:setColor(ccc3(50,50,50))
		return Star
	end				

	self.Star1 = createStar(-80,-100)
	self.Star2 = createStar(-30,-100)
	self.Star3 = createStar(20,-100)
	
	--进度条		
	local processBg = createScale9SpriteWithFrameNameAndSize(RES("mountProgressBottom.png"),CCSizeMake(227, 16))	
	self:addChild(processBg)
	VisibleRect:relativePosition(processBg, self.centelViewBgSprite, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X, ccp(-35, 105))	
	--左右两端
	local processLeftHand = createSpriteWithFrameName(RES("mountProgressTop.png"))
	local processRightHand  = createSpriteWithFrameName(RES("mountProgressTop.png"))
	processRightHand:setFlipX(true)
	self:addChild(processLeftHand, 10)
	self:addChild(processRightHand, 11)
	VisibleRect:relativePosition(processLeftHand, processBg, LAYOUT_CENTER_Y+LAYOUT_LEFT_OUTSIDE)
	VisibleRect:relativePosition(processRightHand, processBg, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
	
	local expProcessbarSprite = createSpriteWithFrameName(RES("mountProgressMid.png"))	
    self.expProcessbar =  CCProgressTimer:create(expProcessbarSprite)
	self.expProcessbar:setType(kCCProgressTimerTypeBar)
	self.expProcessbar:setScaleX(76)
	self.expProcessbar:setMidpoint(ccp(0, 0.5))
	self.expProcessbar:setBarChangeRate(ccp(1,0))	
	VisibleRect:relativePosition(self.expProcessbar, processBg, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE)
	self:addChild(self.expProcessbar, 1)	
	--玻璃罩
	local grassCover = createScale9SpriteWithFrameNameAndSize(RES("common_barTopLayer.png"), CCSizeMake(235,22))
	self:addChild(grassCover, 2)
	VisibleRect:relativePosition(grassCover, processBg, LAYOUT_CENTER)
	--经验条标签	
	self.expLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size1")*scale, FCOLOR("ColorWhite1"))
	VisibleRect:relativePosition(self.expLabel,self.expProcessbar,LAYOUT_CENTER)
	self:addChild(self.expLabel, 5)

	--坐骑阶数标签
	self.MountJieShuLabel = createStyleTextLable("","Stairs")	--创建美术数字标签	
	self.MountJieShuLabel:setAnchorPoint(ccp(0, 1))		
	VisibleRect:relativePosition(self.MountJieShuLabel, self.centelViewBgSprite, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(245,-58))
	self:addChild(self.MountJieShuLabel, 1)
	mountGradeLabel1 = createStyleTextLable(Config.Words[1025],"Stairs")	--创建美术数字标签
	mountGradeLabel1:setAnchorPoint(ccp(0, 1))			
	VisibleRect:relativePosition(mountGradeLabel1,self.MountJieShuLabel, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(9,-18))
	self:addChild(mountGradeLabel1, 1)	
	self.MountJieShuLabel:setScale(1.1)
	mountGradeLabel1:setScale(1.1)
			
	--坐骑经验丹标签
	self.MountExpItemLabelHead = createLabelWithStringFontSizeColorAndDimension(Config.Words[1013], "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
	self:addChild(self.MountExpItemLabelHead)	
	VisibleRect:relativePosition(self.MountExpItemLabelHead,self.centelViewBgSprite, LAYOUT_BOTTOM_INSIDE  + LAYOUT_LEFT_INSIDE,ccp(170, 63))

	self.MountExpItemLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorWhite2"))
	self.MountExpItemLabel:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(self.MountExpItemLabel,self.MountExpItemLabelHead,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(10,0) )
	self:addChild(self.MountExpItemLabel)		
	--每次消耗
	self.ExpItemCostLabelHead = createLabelWithStringFontSizeColorAndDimension(Config.Words[1016], "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
	VisibleRect:relativePosition(self.ExpItemCostLabelHead,self.MountExpItemLabelHead,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_CENTER_X,ccp(0,-5))
	self:addChild(self.ExpItemCostLabelHead)		
	self.MountExpItemCostLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorWhite2"))
	self.MountExpItemCostLabel:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(self.MountExpItemCostLabel,self.ExpItemCostLabelHead,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(10,0) )
	self:addChild(self.MountExpItemCostLabel)			

	self:initDetailsView()
	--战斗力提升	
	self.fightPowerLableHead = createScale9SpriteWithFrameName(RES("talisman_fightingPromote.png"))
	VisibleRect:relativePosition(self.fightPowerLableHead,self.downScrollView, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(10,-5))
	self:addChild(self.fightPowerLableHead)			
	self.fightPowerLable = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow1"))
	self.fightPowerLable:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(self.fightPowerLable,self.fightPowerLableHead,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(10,0))
	self:addChild(self.fightPowerLable)
			
	--开始提升按钮/自动提升按钮
	self.ImproveBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.AutoImproveBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.ImproveLabel = createSpriteWithFrameName(RES("word_button_promotedonce.png"))
	local AutoImproveLabel = createSpriteWithFrameName(RES("word_button_aotupromote.png"))
	
	self:addChild(self.ImproveBtn)
	self:addChild(self.AutoImproveBtn)

	VisibleRect:relativePosition(self.ImproveBtn,mount_bg,  LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(-390,15))
	VisibleRect:relativePosition(self.AutoImproveBtn,mount_bg,  LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(-230,15))
	
	self.ImproveBtn:setTitleString(self.ImproveLabel)
	self.AutoImproveBtn:setTitleString(AutoImproveLabel)	
	
	local mgr = GameWorld.Instance:getMountManager()	
	local ImproveBtnFunc = function()
		--undo
		--self.aniSpr:stopAllActions()												
		needNum =  G_GetNeedItemNum(mgr:getCurrentUseMountId())
		if(self:getExpItem() >= needNum ) then	
			if ( tonumber(string.sub(mgr:getCurrentUseMountId(),6)) < self.maxJishu ) then
				mgr:requestMountFeed("item_zuoqiExp",needNum)
			else
				--已满级
				UIManager.Instance:showSystemTips(Config.Words[1041])
			end
			self.needTips = true
		else
			local mObj = G_IsCanBuyInShop("item_zuoqiExp")
			if(mObj ~=  nil) then
				GlobalEventSystem:Fire(GameEvent.EventBuyItem,mObj,needNum - self:getExpItem() )
			else
				if self.needTips then	
					UIManager.Instance:showSystemTips(Config.Words[1026])
					self.needTips = false
				end
			end
		end		
	end
	local AutoImproveBtnFunc = function()
		self:clickAutoImproveBtn()
		--self.aniSpr:stopAllActions()		
		needNum =  G_GetNeedItemNum(mgr:getCurrentUseMountId())
		if(self:getExpItem() >= needNum ) then
			if( tonumber(string.sub(mgr:getCurrentUseMountId(),6)) < self.maxJishu ) then
				if(self.isAutoUpGrade == true) then
					local AutoImproveLabel = createSpriteWithFrameName(RES("word_button_aotupromote.png"))
					self.AutoImproveBtn:setTitleString(AutoImproveLabel)
					self.isAutoUpGrade = false
					if self.endExp and self.endMaxExp then
						self.expLabel:setString(self.endExp  .."/".. self.endMaxExp)	
						local percentage  = 100*(self.endExp/self.endMaxExp)					
						self:setProcessBar(percentage ,self.endMaxExp)		
					end	
					return
				else
					local AutoImproveLabel =  createSpriteWithFrameName(RES("word_button_cancel.png"))
					self.AutoImproveBtn:setTitleString(AutoImproveLabel)
					local mgr = GameWorld.Instance:getMountManager()			
					needNum =  G_GetNeedItemNum(mgr:getCurrentUseMountId())
					mgr:requestMountFeed("item_zuoqiExp",needNum)
					self.isAutoUpGrade = true
				end
				self.needTips = true
			else
				UIManager.Instance:showSystemTips(Config.Words[1041])
			end
		else
			local mObj = G_IsCanBuyInShop("item_zuoqiExp")
			if(mObj ~=  nil) then
				GlobalEventSystem:Fire(GameEvent.EventBuyItem,mObj,needNum - self:getExpItem())
			else
				if self.needTips then	
					UIManager.Instance:showSystemTips(Config.Words[1026])
					self.needTips = false
				end
			end
		end		
	end
	self.ImproveBtn:addTargetWithActionForControlEvents(ImproveBtnFunc,CCControlEventTouchDown)
	
	self.AutoImproveBtn:addTargetWithActionForControlEvents(AutoImproveBtnFunc,CCControlEventTouchDown)	
	self.nameBg = createSpriteWithFrameName(RES("frontNameBg.png"))
	self:addChild(self.nameBg)
	VisibleRect:relativePosition(self.nameBg, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(170,-55))	
	
	
	--坐骑升级奖励入口	
	self.awardBt = createButtonWithFramename(RES("activityBox.png"))
	local icon = createSpriteWithFrameName(RES("main_activityUpGradeAward.png"))--ICON("item_gift_1"))
	local text = createSpriteWithFrameName(RES("main_activityUpGradeAward_word.png"))	
	self.awardBt:addChild(icon)
	VisibleRect:relativePosition(icon, self.awardBt, LAYOUT_CENTER)
	self.awardBt:addChild(text)
	VisibleRect:relativePosition(text, self.awardBt, LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(0, -8))
	VisibleRect:relativePosition(self.awardBt,self.centelViewBgSprite,LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE ,ccp(-230,-50))
	self:addChild(self.awardBt)
	local openAwardFunc = function()
		self:clickAwardBtn()
		GlobalEventSystem:Fire(GameEvent.EventOpenRTWLevelAwardView,1)
	end
	self.awardBt:addTargetWithActionForControlEvents(openAwardFunc,CCControlEventTouchDown)
	
	local upGradeTextLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[1062], "Arial", FSIZE("Size3"), FCOLOR("ColorWhite2"), CCSizeMake(110, 0))
	self:addChild(upGradeTextLabel)
	VisibleRect:relativePosition(upGradeTextLabel, self.awardBt, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -8))
end

function MountView:getExpItem()
	local bgmgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()	
	return bgmgr:getItemNumByRefId("item_zuoqiExp")
	
end

function MountView:showBaoji(times)
	local label = nil
	if times == 2 then 
		label = createSpriteWithFrameName(RES("mount_baoji_exp_2.png"))
	else
		label = createSpriteWithFrameName(RES("mount_baoji_exp_3.png"))
	end
	--local label =  createStyleTextLable(times .. Config.Words[1057],"RideExpTips")-- createLabelWithStringFontSizeColorAndDimension(Config.Words[1056] .. times .. Config.Words[1057] , "Arial", FSIZE("Size4"),FCOLOR("ColorYellow3"))
	VisibleRect:relativePosition(label,self:getContentNode(),LAYOUT_CENTER,ccp(-50,0))
	label:setTag(10)
	self:addChild(label,3)
	self.baojiTipsCount = self.baojiTipsCount + 1	
	local removeSelf = function(sender)
		if label then
			label:removeFromParentAndCleanup(true)
			self.baojiTipsCount = self.baojiTipsCount - 1		
		end
	end
	
	local moveTo = CCMoveTo:create(0.5,CCPoint(visibleSize.width*0.4,visibleSize.height*0.6))
	local array = CCArray:create()	
	array:addObject(moveTo);
	array:addObject(CCCallFuncN:create(removeSelf))
	local sequence = CCSequence:create(array)	
	label:runAction(sequence)			
		
end

function MountView:showLevelUp(index)	
	local level = ( index - 1 )%4
	local aniSprite = CCSprite:create()	
	aniSprite:setTag(11)
	local removeSelf = function(sender)
		if aniSprite then
			aniSprite:removeFromParentAndCleanup(true)		
		end
	end							
	if level ~= 3  then			
		local animation = createAnimate("star",4,0.15)
		local array = CCArray:create()	
		array:addObject(animation);
		array:addObject(CCCallFuncN:create(removeSelf))
		local sequence = CCSequence:create(array)			
		
		if level == 0 then				
			self.Star1:addChild(aniSprite)
			VisibleRect:relativePosition(aniSprite,self.Star1,LAYOUT_CENTER)										
		elseif level == 1 then
			self.Star2:addChild(aniSprite)						
			VisibleRect:relativePosition(aniSprite,self.Star2,LAYOUT_CENTER)
		elseif level == 2 then 
			self.Star3:addChild(aniSprite)				
			VisibleRect:relativePosition(aniSprite,self.Star3,LAYOUT_CENTER)						
		end						
		aniSprite:runAction(sequence)
	else
		local mgr = GameWorld.Instance:getMountManager()
		mgr:requestMountRide(0)	
	end						
end		

function MountView:GrideIndex(level)
	if(level == nil  ) then
		return 1
	end
	for i =1,10 do
		if(level<= (4*i)) then
			return  i
		end
	end	
	return 1
end

function MountView:createNodeItem(node,headName,height, color, showTip)
	local Head = createLabelWithStringFontSizeColorAndDimension(headName, "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
	VisibleRect:relativePosition(Head,node,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(20,-5 - height))
	node:addChild(Head)		
		
	local valueNode = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorWhite2"))
	valueNode:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(valueNode, Head, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(10,0))
	if color then
		valueNode:setColor(color)
	end
	if showTip then
		local tip = createSpriteWithFrameName(RES("bagBatch_up_tip.png"))
		node:addChild(tip)
		VisibleRect:relativePosition(tip, Head, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(105, 0))
	end
	node:addChild(valueNode)	
	return valueNode
end

function MountView:createDetailsView(refId)
	local scrollView = createScrollViewWithSize(CCSizeMake(187,160))
	local scrollViewDown = createScrollViewWithSize(CCSizeMake(187,160))	
	local nodeup = CCNode:create()
	nodeup:setContentSize(CCSizeMake(187,160))
	local height = 0	
	self.PAPK = self:createNodeItem(nodeup,Config.Words[1017],height)
	height = height + 27	
	self.MAPK = self:createNodeItem(nodeup,Config.Words[1018],height)
	height = height + 27		
	self.TaoAPK = self:createNodeItem(nodeup,Config.Words[1019],height)
	height = height	+ 27	
	self.PDef = self:createNodeItem(nodeup,Config.Words[1020],height)
	height = height	+ 27		
	self.MDef = self:createNodeItem(nodeup,Config.Words[1021],height)
	height = height + 27	
	self.Speed = self:createNodeItem(nodeup,Config.Words[1022],height)			
	local nodedown = CCNode:create()
	nodedown:setContentSize(CCSizeMake(187,160))	
	height = 0	
	local color = FCOLOR("ColorGreen1")
	local showTip = true
	self.downPAPK = self:createNodeItem(nodedown,Config.Words[1017],height, color, showTip)
	height = height + 27	
	self.downMAPK = self:createNodeItem(nodedown,Config.Words[1018],height, color, showTip)
	height = height + 27		
	self.downTaoAPK = self:createNodeItem(nodedown,Config.Words[1019],height, color, showTip)
	height = height	+ 27	
	self.downPDef = self:createNodeItem(nodedown,Config.Words[1020],height, color, showTip)
	height = height	+ 27		
	self.downMDef = self:createNodeItem(nodedown,Config.Words[1021],height, color, showTip)
	height = height + 27	
	self.downSpeed = self:createNodeItem(nodedown,Config.Words[1022],height, color, showTip)			

	scrollView:setContainer(nodeup)	
	scrollView:setDirection(2)
	scrollViewDown:setContainer(nodedown)		
	scrollViewDown:setDirection(2)		
	return scrollView,scrollViewDown
end


function MountView:initDetailsView()
		
	if(self.uptitleBg)then
		self.uptitleBg:removeFromParentAndCleanup(true)		
	end

	local detailViewBg = createScale9SpriteWithFrameNameAndSize(RES("editBox_bg.png"), CCSizeMake(192, 422))
	self:addChild(detailViewBg)
	VisibleRect:relativePosition(detailViewBg, self:getContentNode(),  LAYOUT_BOTTOM_INSIDE +LAYOUT_RIGHT_INSIDE, ccp(-21, 28))
	
	self.uptitleBg = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"),CCSizeMake(183,33))
	VisibleRect:relativePosition(self.uptitleBg,detailViewBg,LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE,ccp(0,-5))	
	self:addChild(self.uptitleBg)	
	--小标题	
	if(self.ImproveDescLabel)then
		self.ImproveDescLabel:removeFromParentAndCleanup(true)		
	end
	self.ImproveDescLabel = createScale9SpriteWithFrameName(RES("talisman_curStepsProperty.png"))
	VisibleRect:relativePosition(self.ImproveDescLabel,self.uptitleBg,LAYOUT_CENTER)
	self:addChild(self.ImproveDescLabel)		
	if(self.topScrollView)then
		self.topScrollView:removeFromParentAndCleanup(true)		
	end		
	if(self.downScrollView)then
		self.downScrollView:removeFromParentAndCleanup(true)		
	end		
	
	self.topScrollView,self.downScrollView = self:createDetailsView(self.cuRefId)
	VisibleRect:relativePosition(self.topScrollView,self.uptitleBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE)
	self:addChild(self.topScrollView)	
	if(self.downtitleBg)then
		self.downtitleBg:removeFromParentAndCleanup(true)		
	end	
	self.downtitleBg = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"),CCSizeMake(183,33))
	VisibleRect:relativePosition(self.downtitleBg, detailViewBg, LAYOUT_CENTER)	
	self:addChild(self.downtitleBg)
	
	--小标题	
	if(self.NextDescLabel)then
		self.NextDescLabel:removeFromParentAndCleanup(true)		
	end
	self.NextDescLabel =  createScale9SpriteWithFrameName(RES("talisman_nextLevelProperty.png"))
	VisibleRect:relativePosition(self.NextDescLabel,self.downtitleBg,LAYOUT_CENTER)
	self:addChild(self.NextDescLabel)	
	
	VisibleRect:relativePosition(self.downScrollView,self.downtitleBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE)
	self:addChild(self.downScrollView)		
end

function MountView:setDetailsView(refId)
	if( refId ~= nil ) then
		local index = tonumber(string.sub(refId,6))	
		if(index~= nil and index <=self.maxJishu) then
			local record = G_GetMountRecordByRefId(refId)
			local effectTable = record.effectData
			local tempTable = record.tmpEffectData						
			self.PAPK:setString(PropertyDictionary:get_minPAtk(effectTable) .." - " .. PropertyDictionary:get_maxPAtk(effectTable))		--物攻									
			self.MAPK:setString(PropertyDictionary:get_minMAtk(effectTable) .. " - " .. PropertyDictionary:get_maxMAtk(effectTable))	--魔攻										
			self.TaoAPK:setString(PropertyDictionary:get_minTao(effectTable) .. " - " .. PropertyDictionary:get_maxTao(effectTable))	--道攻									
			self.PDef:setString(PropertyDictionary:get_minPDef(effectTable) .. " - " .. PropertyDictionary:get_maxPDef(effectTable))	--物防						
			self.MDef:setString(PropertyDictionary:get_minMDef(effectTable) .. " - " .. PropertyDictionary:get_maxMDef(effectTable))	--魔防								
			self.Speed:setString(PropertyDictionary:get_moveSpeedPer(tempTable) .. "%")		--移速							
			if(index < self.maxJishu) then
				local recordd = G_GetMountRecordByRefId("ride_" .. (index +1))
				local effectTabled = recordd.effectData
				local tempTabled = recordd.tmpEffectData							
				self.downPAPK:setString(PropertyDictionary:get_minPAtk(effectTabled) .." - " .. PropertyDictionary:get_maxPAtk(effectTabled))	--物攻																
				self.downMAPK:setString(PropertyDictionary:get_minMAtk(effectTabled) .. " - " .. PropertyDictionary:get_maxMAtk(effectTabled))	--魔攻											
				self.downTaoAPK:setString(PropertyDictionary:get_minTao(effectTabled) .. " - " .. PropertyDictionary:get_maxTao(effectTabled))--道攻					
				self.downPDef:setString(PropertyDictionary:get_minPDef(effectTabled) .. " - " .. PropertyDictionary:get_maxPDef(effectTabled))	--物防							
				self.downMDef:setString(PropertyDictionary:get_minMDef(effectTabled) .. " - " .. PropertyDictionary:get_maxMDef(effectTabled))	--魔防									
				self.downSpeed:setString(PropertyDictionary:get_moveSpeedPer(tempTabled) .. "%")	--移速						
			else
				if(self.downScrollView) then
					self.downScrollView:setContainer(tipsNode)
					self.downScrollView:removeFromParentAndCleanup(true)
					self.downScrollView = nil
				
					if not self.tipsNode then
						local FullLevelDescLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[717], "Arial", FSIZE("Size2")*scale, FCOLOR("ColorWhite2"),CCSizeMake(180,200))				
						self.tipsNode= CCNode:create()
						self.tipsNode:setContentSize(CCSizeMake(187,220))
						VisibleRect:relativePosition(FullLevelDescLabel,self.tipsNode,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(5,120))					
						self.tipsNode:addChild(FullLevelDescLabel)
						self:addChild(self.tipsNode)
						VisibleRect:relativePosition(self.tipsNode,self.downtitleBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE)
					end
					
				end	
			end	
		end	
	end		
end
	
function MountView:changeItemZuoqiExp()
	self:setExpItem(self:getExpItem())
end

function MountView:stopAutoUpgrade()
	self.isAutoUpGrade = false	
	local AutoImproveLabel =  createSpriteWithFrameName(RES("word_button_aotupromote.png"))
	self.AutoImproveBtn:setTitleString(AutoImproveLabel)
	local mgr = GameWorld.Instance:getMountManager()
	local endMountId = mgr:getCurrentUseMountId()
	self.cuIndex = tonumber(string.sub(endMountId ,6))
	local endcurrentExp = mgr:getCurrentMountExp()	
	local recordItem = G_GetMountRecordByRefId(self.cuRefId)		
	local expTabel = recordItem.property					
	local maxExp = PropertyDictionary:get_maxExp(expTabel)	
	self:UpdateMountView(endMountId,endcurrentExp)
	self.startIndex = self.startIndex or self.cuIndex
	if self.cuIndex == self.startIndex then
		self.aniSpr:stopAllActions()		
		self:setProcessBar(100*endcurrentExp/maxExp , maxExp)
		self:setExpItem(self:getExpItem())
	else		
		local curecord = G_GetMountRecordByRefId("ride_" .. self.startIndex)
		local startMaxExp = PropertyDictionary:get_maxExp(curecord.property)
		self.aniSpr:stopAllActions()	
		self:setProcessBar(100 , startMaxExp)
		self:showLevelUp(self.cuIndex)
		self:setProcessBar(100*endcurrentExp/maxExp , maxExp)				
		self.cuRefId = "ride_" .. self.cuIndex															
		self:SetMountProperty(self.cuRefId)
		self:setDetailsView(self.cuRefId)	
		self:setStarAndLevel(self.cuRefId)
	end
end

function MountView:onExit()
	self.Star1:removeChildByTag(11,true)
	self.Star2:removeChildByTag(11,true)
	self.Star3:removeChildByTag(11,true)
	
	for i = 1 ,self.baojiTipsCount do 
		self:getContentNode():removeChildByTag(10,true)		
	end

	if self.cuRefId == "ride_" .. self.maxJishu then
		self.endExp = 0
		self.endMaxExp = 0
	end
	if self.endMaxExp  then	
		self.aniSpr:stopAllActions()
		self:setProcessBar(100*self.endExp/self.endMaxExp , self.endMaxExp)
	end
	
	local AutoImproveLabel = createSpriteWithFrameName(RES("word_button_aotupromote.png"))
	self.AutoImproveBtn:setTitleString(AutoImproveLabel)
	self.isAutoUpGrade = false	
end

function MountView:__delete()
	self.cellFrame:release()
end


-----------------------------------------------------------
--新手指引
function MountView:getAutoImproveBtn()
	return self.AutoImproveBtn
end

function MountView:clickAutoImproveBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"MountView","AutoImproveBtn")
end

function MountView:getAwardBtn()
	return self.awardBt
end

function MountView:clickAwardBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"MountView","AwardBtn")
end	
-----------------------------------------------------------