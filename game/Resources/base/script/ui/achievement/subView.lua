--成就界面子页
require("ui.UIManager")
require("config.words")
require("ui.achievement.AchieveTableView")
subView = subView or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

local subViewInfo = 
{
	[1]	=	{name = "NoviceView",index = 1},
	[2]	=	{name = "KillSubsView",index = 2},
	[3]	=	{name = "KillBossView",index = 3},
	[4]	=	{name = "MountUpView",index = 4},
	[5]	=	{name = "KnightUpView",index = 5},
	[6]	=	{name = "HeartUpView",index = 6},
}
function subView:__init(keys)
	self.rootNode = CCNode:create()
	self.rootNode : setContentSize(CCSizeMake(873*g_scale,419*g_scale))
	self.sList = {}
	self.rewardList = {}
	self.rewardNumList = {}
	self.IconList = {}	
	self.nameLbList = {}
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()		
	self.sList = achievementMgr:getStaticContainerByType(keys)	
	self.listSize = table.size(self.sList)
	self:initStaticView()
	self:initTableView(keys)
	self:initScrollView()
	self:initInfoInRightBg()	
end

function subView:__delete()
	self.scrollNode : release()
	self.tableView:DeleteMe()
	self.sList = nil
	self.rewardList = nil
	self.rewardNumList = nil
	self.IconList = nil	
	self.nameLbList = nil
end

function subView:initStaticView()
	self.allBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(831,390))
	self.rootNode:addChild(self.allBg)
	VisibleRect:relativePosition(self.allBg,self.rootNode,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE)
	self.leftBg = createScale9SpriteWithFrameNameAndSize(RES("squares_formBg2.png"), CCSizeMake(288*g_scale,379*g_scale))	
	self.rootNode : addChild(self.leftBg)	
	VisibleRect:relativePosition(self.leftBg,self.allBg,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(5,-7))
	self.rightBg = createScale9SpriteWithFrameNameAndSize(RES("squares_formBg2.png"), CCSizeMake(523*g_scale,379*g_scale))	
	self.kraftBg = CCSprite:create()
	local viewNodeBgRight = CCSprite:create("ui/ui_img/common/kraft_bg.pvr")
	local viewNodeBgLeft = CCSprite:create("ui/ui_img/common/kraft_bg.pvr")
	viewNodeBgLeft:setFlipX(true)
	self.kraftBg:setContentSize(CCSizeMake(viewNodeBgRight:getContentSize().width*2,viewNodeBgRight:getContentSize().height))
	self.kraftBg:addChild(viewNodeBgLeft)
	self.kraftBg:addChild(viewNodeBgRight)
	VisibleRect:relativePosition(viewNodeBgLeft,self.kraftBg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))
	VisibleRect:relativePosition(viewNodeBgRight,self.kraftBg,LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))	
	self.kraftBg : setScaleX(1.0070*0.60)
	self.kraftBg : setScaleY(1.0273*0.76)	
	
	self.kraftRole = CCSprite:create("ui/ui_img/common/common_kraftRole.pvr")
	self.rootNode : addChild(self.rightBg)
	self.rootNode : addChild(self.kraftBg)
	self.rootNode : addChild(self.kraftRole)
	VisibleRect:relativePosition(self.rightBg,self.allBg,LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-5,-7))
	VisibleRect:relativePosition(self.kraftBg,self.rightBg,LAYOUT_CENTER,ccp(0,2))
	VisibleRect:relativePosition(self.kraftRole,self.kraftBg,LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE)
	for i = 1,3 do
		self.IconList[i] = CCNode:create()
		self.nameLbList[i] = CCNode:create()		
		self.IconList[i] : setContentSize(CCSizeMake(85*g_scale,85*g_scale))
		self.nameLbList[i] : setContentSize(CCSizeMake(85*g_scale,16*g_scale))
		self.rootNode : addChild(self.IconList[i],50)
		self.rootNode : addChild(self.nameLbList[i])
		VisibleRect:relativePosition(self.IconList[i],self.rightBg,LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp((i-1)*110+33,103))
		VisibleRect:relativePosition(self.nameLbList[i],self.IconList[i],LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE,ccp(0,-3))		
	end 
end

function subView:initTableView(keys)
	self.tableView = AchieveTableView.New()
	--self.tableView : initTableView(self.rootNode,self.sList,self.listSize,keys)	
	self.tableView : initTableView(self.rootNode,self.sList,keys)	
	local layoutP = ccp(3,-2)
	self.tableView:setTablePosition(self.leftBg,layoutP)
	self.tableView : scrollTocell(1)
end

function subView:createScrollView(viewSize)
	local scrollView = createScrollViewWithSize(viewSize)
	scrollView:setDirection(2)
	return scrollView
end	

function subView:initScrollView()
	self.scrollBg = CCNode:create()
	self.scrollBg:setContentSize(CCSizeMake(514*g_scale,120*g_scale))
	self.rootNode : addChild(self.scrollBg)
	VisibleRect:relativePosition(self.scrollBg,self.rightBg,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(10,0))
	local line = createScale9SpriteWithFrameName(RES("npc_dividLine.png"))
	self.scrollBg : addChild(line)
	VisibleRect:relativePosition(line,self.scrollBg,LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(0,10))
	--scrollView节点
	self.viewSize = CCSizeMake(400*g_scale,100*g_scale)
	self.scrollNode = CCNode:create()
	self.scrollNode:retain()
	--滚动
	self.scrollView = self:createScrollView(self.viewSize)
	self.rootNode:addChild(self.scrollView) 		
	VisibleRect:relativePosition(self.scrollView, self.scrollBg, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(10,0))		
	
end

function subView:initInfoInRightBg()
	self.rewardBg = createSpriteWithFrameName(RES("quest_reward.png"))	
	self.rootNode:addChild(self.rewardBg)	
	VisibleRect:relativePosition(self.rewardBg, self.IconList[1], LAYOUT_LEFT_INSIDE+LAYOUT_TOP_OUTSIDE,ccp(3,5))	
	self.receiveBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local btnWd = createScale9SpriteWithFrameName(RES("word_button_receive.png"))
	G_setScale(btnWd)
	self.rootNode : addChild(self.receiveBtn)
	self.receiveBtn:setTitleString(btnWd)	
	VisibleRect:relativePosition(self.receiveBtn,self.rightBg,LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-15,18))
	local getReward = function()
		local achieveMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()
		local requestFlag = achieveMgr:getRequestFlag()
		if requestFlag then
			--achieveMgr:setRequestFlag(false)
			if self.selIndex then
				achieveMgr:requestAchievementGetReward(self.selIndex)
				local manager =UIManager.Instance
				manager:showLoadingHUD(10,self.rootNode)
				--self.receiveBtn:setVisible(false)
			end	
		end		
	end
	self.receiveBtn:addTargetWithActionForControlEvents(getReward,CCControlEventTouchDown)	
	self.receiveBtn : setVisible(false)
end

function subView:setBtnVisible(tag)
	if(tag == "open") then
		self.receiveBtn : setVisible(true)
	elseif(tag == "close") then
		self.receiveBtn : setVisible(false)
	end
end		
	
function subView:refreshScrollView(cellIndex) 
		for i = 1,3 do
			self.IconList[i] : removeAllChildrenWithCleanup(true)			
			self.nameLbList[i] : removeAllChildrenWithCleanup(true)
		end
		self.rewardList = {}
		self.positionIndex = 1
		if(self.sList) then
			--更新成就描述
			local text = self.sList[cellIndex].property.achieveDescribe
			local achiInfo = createLabelWithStringFontSizeColorAndDimension(text,"Arial",  FSIZE("Size3"),FCOLOR("black1"),CCSizeMake(self.viewSize.width-10, 0))
			self.scrollNode : removeAllChildrenWithCleanup(true)
			local size = achiInfo:getContentSize()
			if (achiInfo:getContentSize().height < self.viewSize.height) then
				size.height = self.viewSize.height
			end	
			self.scrollNode:setContentSize(size)
			self.scrollNode:addChild(achiInfo)
			VisibleRect:relativePosition(achiInfo, self.scrollNode, LAYOUT_CENTER)
			
			self.scrollView:setContainer(self.scrollNode)
			local offset = size.height-self.viewSize.height
			self.scrollView:setContentOffset(ccp(0,-offset),false)
			--更新成就奖励
			self.rewardList = self.sList[cellIndex].achieveReward
			for i,v in pairs(self.rewardList) do
				self:setReward(i,v)
			end
		end	
end	

function subView:setReward(itemName,itemNum)
	local rewardBg = createSpriteWithFrameName(RES("bagBatch_itemBg.png"))
	if(type(itemNum) ~= "number") then	
		local reward = G_createItemBoxByRefId(itemNum,nil,nil,-1)
		self.IconList[self.positionIndex] : addChild(rewardBg)
		rewardBg:addChild(reward)
		VisibleRect:relativePosition(rewardBg,self.IconList[self.positionIndex],LAYOUT_CENTER)
		VisibleRect:relativePosition(reward,rewardBg,LAYOUT_CENTER)					
		local itemObj = ItemObject.New()
		itemObj:setRefId(itemNum)
		itemObj:setStaticData(G_getStaticDataByRefId(itemObj:getRefId()))	
		local color = G_getColorByItem(itemObj)
		itemObj:DeleteMe()
		local rewardNameLb = createLabelWithStringFontSizeColorAndDimension(--[[rewardName..--]]"x1" , "Arial",  FSIZE("Size3"), color)
		self.nameLbList[self.positionIndex] : addChild(rewardNameLb)
		VisibleRect:relativePosition(rewardNameLb,self.nameLbList[self.positionIndex] ,LAYOUT_CENTER)
	else		
		local reward = G_createUnPropsItemBox(itemName)
		self.IconList[self.positionIndex] : addChild(rewardBg)
		rewardBg:addChild(reward)
		VisibleRect:relativePosition(rewardBg,self.IconList[self.positionIndex],LAYOUT_CENTER)
		VisibleRect:relativePosition(reward,rewardBg,LAYOUT_CENTER)		
		--名称 数字
		--local rewardName = GameData.UnPropsItem[itemName].property.name
		local rewardNameLb = createLabelWithStringFontSizeColorAndDimension(--[[rewardName..--]]"+"..itemNum , "Arial",  FSIZE("Size3"), FCOLOR("ColorYellow1"))			
		self.nameLbList[self.positionIndex] : addChild(rewardNameLb)	
		VisibleRect:relativePosition(rewardNameLb,self.nameLbList[self.positionIndex] ,LAYOUT_CENTER)
	end
	self.positionIndex = self.positionIndex + 1
end

function subView:setSelIndex(index)
	if index then
		self.selIndex = index
	end	
end

function subView:getRootNode()
	return self.rootNode
end