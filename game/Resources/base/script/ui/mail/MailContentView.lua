require("ui.UIManager")
require("common.BaseUI")
require("config.words")
MailContentView = MailContentView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

function MailContentView:__init()
	self.viewName = "MailContentView"
	self.bIsClickReSell = false
	self.itemList = {}	
	self:init(CCSizeMake(874,564))	
	local mailNode = createSpriteWithFrameName(RES("mail_titleimg.png"))
	self:setFormImage(mailNode)
	local titleNode = createSpriteWithFrameName(RES("word_mail.png"))
	self:setFormTitle(titleNode, TitleAlign.Left)
	self:initMailContentView()			
end

function MailContentView:__delete()
	self:clearItemList()
end

function MailContentView:clearItemList()
	for key,v in pairs(self.itemList) do
		if v and v.DeleteMe then
			v:DeleteMe()
		end
	end
end

function MailContentView:onEnter(arg)
	self:removeRewardView()
	self.mailObj = arg	--邮件对象
	self:showPickupRemainSec(false)
	if self.mailObj then
		self:updateMailData()
		if self.mailObj:getMailType() == MailType.AuctionDelay then
			local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()		
			mailMgr:requestPickupRemainSec(self.mailObj:getMailId())
		end
	end
end

function MailContentView:onExit()
	self:removeRewardView()
	self:showPickupRemainSec(false)
end

--955
function MailContentView:showPickupRemainSec(bShow, id, sec)
	bShow = (bShow and (type(sec) == "number" and sec > 0 and self.mailObj and (id == self.mailObj:getMailId())))
	if bShow then		
		if self.pickupRemainLabel == nil then
			self.pickupRemainLabel = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size3"), FCOLOR("ColorYellow2"))
			self:addChild(self.pickupRemainLabel)	
		end				
		self.pickRemainSec = sec
		
		if self.pickRemainSch == nil then				
			local onTimeout = function()
				self:updateRemainSec(1)
			end
			self.pickRemainSch = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 1, false)						
		end	
		self:updateRemainSec(0)
	else
		if self.pickRemainSch then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.pickRemainSch)	
			self.pickRemainSch = nil
		end
		if self.pickupRemainLabel then
			self.pickupRemainLabel:removeFromParentAndCleanup(true)
			self.pickupRemainLabel = nil
		end			
	end
end

function MailContentView:updateRemainSec(time)
	if type(self.pickRemainSec) == "number" and self.pickRemainSec > 0 then
		self.pickRemainSec = self.pickRemainSec - time
		if self.pickRemainSec <= 0 then
			self:showPickupRemainSec(false)
		elseif self.pickupRemainLabel then
			local text = GameUtil:sec2str(self.pickRemainSec)..Config.Words[25330]
			if string.isLegal(text) then
				self.pickupRemainLabel:setString(text)
				VisibleRect:relativePosition(self.pickupRemainLabel, self.contentBg2, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-35, 20))	
			end					
		end
	else
		self:showPickupRemainSec(false)
	end
end

function MailContentView:initMailContentView()
	local size = self:getContentNode():getContentSize()
	self.contentBg2 = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(size.width, 420))
	self:addChild(self.contentBg2)
	VisibleRect:relativePosition(self.contentBg2,self:getContentNode(),LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X,ccp(0,-70))
	--邮件类型背景
	local TitleLabelBg = createScale9SpriteWithFrameName(RES("chat_Channel.png"))				
	self:addChild(TitleLabelBg)
	VisibleRect:relativePosition(TitleLabelBg,self:getContentNode(),LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,-7))
	self.TitleLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorWhite2"))
	self:addChild(self.TitleLabel)
	VisibleRect:relativePosition(self.TitleLabel,TitleLabelBg,LAYOUT_CENTER)
	
	--标题内容
	self.titleContentLabelBg = createScale9SpriteWithFrameNameAndSize(RES("commom_editFrame.png"),CCSizeMake(540,40))			
	self:addChild(self.titleContentLabelBg)
	VisibleRect:relativePosition(self.titleContentLabelBg,TitleLabelBg,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(10,0))
	self.titleContentLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorWhite2"))
	self:addChild(self.titleContentLabel)
	self.titleContentLabel:setAnchorPoint(ccp(0, 0.5))
	VisibleRect:relativePosition(self.titleContentLabel,self.titleContentLabelBg,LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(10, 0))
	
	--返回按钮
	local returnBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))	
	self:addChild(returnBtn)
	VisibleRect:relativePosition(returnBtn,self.titleContentLabelBg,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(14,0))	
	self.returnBtnLb = createSpriteWithFrameName(RES("word_button_return.png"))
	returnBtn:addChild(self.returnBtnLb)
	VisibleRect:relativePosition(self.returnBtnLb,returnBtn,LAYOUT_CENTER)
	local returnBtnFunc = function()
		GlobalEventSystem:Fire(GameEvent.EventReturnMailView, MailType.AllMailType)
	end
	returnBtn:addTargetWithActionForControlEvents(returnBtnFunc,CCControlEventTouchDown)
	
	--发送给玩家Name
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local heroName = PropertyDictionary:get_name(hero:getPT())
	local toText = createLabelWithStringFontSizeColorAndDimension("To", "Arial", FSIZE("Size3"), FCOLOR("ColorWhite2"))
	self:addChild(toText)
	VisibleRect:relativePosition(toText, self.contentBg2, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(33, -20))
	local heroText = createLabelWithStringFontSizeColorAndDimension(heroName, "Arial", FSIZE("Size3"), FCOLOR("ColorBlue1"))
	self:addChild(heroText)
	VisibleRect:relativePosition(heroText, toText,  LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(10, 0))
	
	self:setLine(1)	
	
	local itemTopLine = createScale9SpriteWithFrameNameAndSize(RES("knight_line.png"), CCSizeMake(size.width, 2))	
	self:addChild(itemTopLine)
	VisibleRect:relativePosition(itemTopLine, self:getContentNode(), LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE, ccp(0, 165))			
end	

function MailContentView:updateMailData()
	local mailType
	if self.mailObj:getMailType() == MailType.Activity then
		mailType = Config.Words[8001]
	elseif self.mailObj:getMailType() == MailType.Notice then
		mailType = Config.Words[8002]	
	elseif self.mailObj:getMailType() == MailType.GM2Client then 
		mailType = Config.Words[8013]	
	elseif self.mailObj:getMailType() == MailType.Client2GM then 
		mailType = Config.Words[8013]	
	elseif self.mailObj:getMailType() == MailType.AuctionNormal then 
		mailType = Config.Words[8014]
	elseif self.mailObj:getMailType() == MailType.AuctionCancel then 
		mailType = Config.Words[8014]	
	elseif self.mailObj:getMailType() == MailType.AuctionDelay then 
		mailType = Config.Words[8014]					
	elseif self.mailObj:getMailType() == MailType.AuctionTimeout then 				
		mailType = Config.Words[8014]	
	end
	if mailType ==nil then
		return nil
	end
	self:setTitleType(mailType)
	self:setTitleContent(self.mailObj:getTitleContent())
	local content = self.mailObj:getMailContent()	
	self:setContent(content)	
	self:setMailDate(self.mailObj:getMailDate())	
	self:setRewardMark()
	--奖励道具
	if self.mailObj:isHaveReward() == 1 then
		self:createRewardLabel()				
		self:showPickupBtn(true)	
		if (not table.isEmpty(self.mailObj:getItemList())) then
			self:showItemList()
		else
			self:showReward()	
		end
	else
		self:showPickupBtn(false)
	end
	
	if self.mailObj:getMailType() == MailType.AuctionCancel or self.mailObj:getMailType() == MailType.AuctionTimeout then 	
		self:showReSellBtn(true)					
	else
		self:showReSellBtn(false)
	end		
end

function MailContentView:showPickupBtn(bShow)
	if (not self.pickuBtnLb) and bShow then
		self.pcickupBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))	
		self:addChild(self.pcickupBtn)
		VisibleRect:relativePosition(self.pcickupBtn,self.contentBg2, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-25,51))	
		self.pickuBtnLb = createSpriteWithFrameName(RES("word_button_pickup.png"))
		self.pcickupBtn:addChild(self.pickuBtnLb)
		VisibleRect:relativePosition(self.pickuBtnLb,self.pcickupBtn,LAYOUT_CENTER)
		local onPickupbtnFun = function()	
			if self.mailObj then
				local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()		
				UIManager.Instance:showLoadingHUD(3)
				mailMgr:requestMailPickup(self.mailObj:getMailId())	
				self:clearClickReSell()
			end					
		end
		self.pcickupBtn:addTargetWithActionForControlEvents(onPickupbtnFun,CCControlEventTouchDown)			
	end
	if self.pickuBtnLb then
		self.pcickupBtn:setVisible(bShow and (self.mailObj:getMailState() ~= 1))
	end
end

function MailContentView:setLine(number)
	local size = self:getContentNode():getContentSize()
	for key=1, number do
		local line = createScale9SpriteWithFrameNameAndSize(RES("knight_line.png"), CCSizeMake(size.width, 2))
		self:addChild(line)
		VisibleRect:relativePosition(line, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(0, -key*44-76))
	end
end

function MailContentView:setTitleType(titleTypeStr)
	if not string.isLegal(titleTypeStr) then
		titleTypeStr = " "
		return
	end
	if self.mailObj:getMailType() == 0 then
		self.TitleLabel:setColor(FCOLOR("ColorYellow1"))		
	elseif self.mailObj:getMailType() == 1 then
		self.TitleLabel:setColor(FCOLOR("ColorRed2"))	
	elseif self.mailObj:getMailType() ==2 then
		self.TitleLabel:setColor(FCOLOR("ColorGreen1"))	
	else	
		
	end
	
	if string.isLegal(titleTypeStr) then
		self.TitleLabel:setString(titleTypeStr)		
	end
	
end

function MailContentView:setTitleContent(titleContentStr)
	if not string.isLegal(titleContentStr) then
		self.titleContentLabel:setString(" ")		
		return
	end
	if self.mailObj:getMailType() == 0 then
		self.titleContentLabel:setColor(FCOLOR("ColorYellow2"))		
	elseif self.mailObj:getMailType() == 1 then
		self.titleContentLabel:setColor(FCOLOR("ColorRed1"))
	elseif 	self.mailObj:getMailType() == 2 then
		self.titleContentLabel:setColor(FCOLOR("ColorGreen2"))
	else
	
	end	
	self.titleContentLabel:setString(titleContentStr)	
end

function MailContentView:setMailDate(date)
	if not date or not string.isLegal(date) then
		date = " "
	end
	self.dateLb:setString(date)
end

function MailContentView:setContent(content)
	if not string.isLegal(content) then
		content = ""
	end
	local viewSize
	local relativePoint 
	if self.mailObj:isHaveReward() == 1 then
		viewSize = CCSizeMake(737,185)
		relativePoint = ccp(-154,150)
	else
		viewSize = CCSizeMake(737,360)
		relativePoint = ccp(-154,15)
	end			

	--scrollView节点	
	if (self.scrollView) then
		self:getContentNode():removeChild(self.scrollView, true)
	end
	self.scrollView = createScrollViewWithSize(viewSize)
	self.scrollView:setDirection(2)
	self:addChild(self.scrollView)
	VisibleRect:relativePosition(self.scrollView, self.contentBg2, LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X,ccp(0,-80))		
	
	--内容
	self.contentLb = createLabelWithStringFontSizeColorAndDimension(content,"Arial",FSIZE("Size4")*g_scale,FCOLOR("ColorWhite2"),CCSizeMake(720,0))	
	local contentSize = self.contentLb:getContentSize()		
	self.scrollNode = CCNode:create()
	self.scrollNode:setContentSize(contentSize)
	self.contentLb:setAnchorPoint(ccp(0,0))	
	self.scrollNode:addChild(self.contentLb)
	self.scrollNodes = {}	
	table.insert(self.scrollNodes,self.scrollNode)
	local container= CCNode:create()
	G_layoutContainerNode(container,self.scrollNodes,0,E_DirectionMode.Vertical,viewSize,true)
	self.scrollView:setContainer(container)
	self.scrollView:updateInset()
	self.scrollView:setContentOffset(ccp(0,-container:getContentSize().height + viewSize.height), false)
			
	--时间
	if (self.dateLb) then
		self:getContentNode():removeChild(self.dateLb, true)
	end
	self.dateLb = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size3")*g_scale,FCOLOR("ColorYellow7"))
	self:addChild(self.dateLb)		
	VisibleRect:relativePosition(self.dateLb, self.contentBg2, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, relativePoint)		
		
	--发件人签名
	if (self.senderNameLb) then
		self:getContentNode():removeChild(self.senderNameLb, true)
	end
	self.senderNameLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[8010],"Arial",FSIZE("Size3")*g_scale,FCOLOR("ColorYellow7"))
	self:addChild(self.senderNameLb)
	VisibleRect:relativePosition(self.senderNameLb,self.dateLb,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(55,0))
end

function MailContentView:createRewardLabel()
	if self.rewardLable then
		self:removeChild(self.rewardLable)
		self.rewardLable = nil
	end
	local viewSize = CCSizeMake(548*g_scale,200*g_scale)
	self.rewardLable = CCNode:create()
	self.rewardLable:setContentSize(viewSize)
	self:addChild(self.rewardLable )
	VisibleRect:relativePosition(self.rewardLable,self.contentBg2,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(40,-58))
end

function MailContentView:showReward()
	if self.mailObj == nil then
		return nil
	end		
		
	--邮件附件
	local rewardBoxoffectX = 120
	local posX = -2
	local offectIndex = 0
	local gridArray = {}	
	self:clearItemList()
	self.itemList = {}	
	local propertysum = 1
	

	--元宝	
	if self.mailObj:getMailYuanBao() >0 then	
		local yuanBaoNum = self.mailObj:getMailYuanBao()
		local itemBoxShow = G_createItemShowByItemBox("unbindedGold",yuanBaoNum)
		self.rewardLable:addChild(itemBoxShow)
		VisibleRect:relativePosition(itemBoxShow,self.rewardLable, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(posX+rewardBoxoffectX*(propertysum-1),-15))	

		propertysum = propertysum +1
	end	
	
	--绑定元宝	
	if self.mailObj:getMailBindYuanBao() >0 then
		
		local yuanBaoNum = self.mailObj:getMailBindYuanBao()
		local itemBoxShow = G_createItemShowByItemBox("bindedGold",yuanBaoNum)
		self.rewardLable:addChild(itemBoxShow)
		VisibleRect:relativePosition(itemBoxShow,self.rewardLable, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(posX+rewardBoxoffectX*(propertysum-1),-15))	
															
		propertysum = propertysum +1
	end	
	
	--金币		
	if self.mailObj:getMailGold()>0 then
		
		local GoldNum = self.mailObj:getMailGold()
		local itemBoxShow = G_createItemShowByItemBox("gold",GoldNum)
		self.rewardLable:addChild(itemBoxShow)
		VisibleRect:relativePosition(itemBoxShow,self.rewardLable, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(posX+rewardBoxoffectX*(propertysum-1),-15))	
															
		propertysum = propertysum +1
	end		
				
	local itemRewardList = self.mailObj:getMailReward()
	if itemRewardList~=nil then--物品奖励	
		if itemRewardList[1] then	
			for j,v in pairs(itemRewardList) do
				if propertysum > 5 then	--数量大于5暂定为不显示
					return
				end							
				local  itemReward = v				
				--local isBinded =  QuestRefObj:getStaticQusetItemListIsBinded(tItemList)
				self:createItem(itemReward,propertysum,posX,rewardBoxoffectX)									
				propertysum = propertysum +1
			end			
		else
			self:createItem(itemRewardList,propertysum,posX,rewardBoxoffectX)	
			propertysum = propertysum +1
		end
	end	
end

function MailContentView:isClickReSell()
	return self.bIsClickReSell
end	

function MailContentView:clearClickReSell()
	self.bIsClickReSell = false
end

function MailContentView:showReSellBtn(bShow)
	self.bIsClickReSell = false
	if self.reSellBtn == nil and bShow then
		self.reSellBtn = createButtonWithFramename(RES("btn_1_select.png"))	
		self:addChild(self.reSellBtn)
		VisibleRect:relativePosition(self.reSellBtn, self.contentBg2, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-160, 51))	
--		local text = createLabelWithStringFontSizeColorAndDimension(Config.Words[8015], "Arial", FSIZE("Size4"), FCOLOR("Yellow2"))											
		local text = createSpriteWithFrameName(RES("word_Resell.png"))
		self.reSellBtn:addChild(text)
		VisibleRect:relativePosition(text, self.reSellBtn, LAYOUT_CENTER)
		
		local onClick = function()	
			if self.mailObj then
				local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()		
				UIManager.Instance:showLoadingHUD(3)
				mailMgr:requestMailPickup(self.mailObj:getMailId())	
				self.bIsClickReSell = true
			end
		end
		self.reSellBtn:addTargetWithActionForControlEvents(onClick,CCControlEventTouchDown)	
	end		
	if self.reSellBtn then
		self.reSellBtn:setVisible(bShow)
	end
end

function MailContentView:showItemList()
	if not self.mailObj then
		return
	end
	local preNode
	for k, v in pairs(self.mailObj:getItemList()) do
		local itemBoxShow = G_createItemShowByItemBox(v:getRefId(), PropertyDictionary:get_number(v:getPT()),nil,nil,nil,PropertyDictionary:get_bindStatus(v:getPT()))
		self.rewardLable:addChild(itemBoxShow)
		if not preNode then
			VisibleRect:relativePosition(itemBoxShow, self.rewardLable, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(-2, -15))			
		else
			VisibleRect:relativePosition(itemBoxShow, preNode, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(10 , 0))			
		end
		preNode = itemBoxShow
	end
end

function MailContentView:createItem(itemReward,propertysum,posX,rewardBoxoffectX)
	local itemCount = itemReward.number
	local itemRefId = itemReward.itemRefId
	local staticData = G_getStaticDataByRefId(itemRefId)
	
	if staticData then
		if itemCount == nil or itemRefId == nil or itemReward.bindStatus == nil then
			return nil
		end
		local bindStatus
		if itemReward.bindStatus == true then
			bindStatus = 1
		elseif itemReward.bindStatus == false then 
			bindStatus = 0
		else
		end		
		
		local itemObj = ItemObject.New()
		itemObj:setRefId(itemRefId)
		itemObj:setStaticData(staticData)
		itemObj:setPT({bindStatus = bindStatus})
		self.itemList[propertysum] = itemObj
		
		local itemBoxShow = G_createItemShowByItemBox(itemRefId,itemCount,nil,nil,nil,bindStatus)
		self.rewardLable:addChild(itemBoxShow)
		VisibleRect:relativePosition(itemBoxShow,self.rewardLable, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(posX+rewardBoxoffectX*(propertysum-1),-15))			
	end
end
function MailContentView:updateContentView()
	self.mailObj:setMailState(1)
	--self:updateMailData()
	
end	

function MailContentView:getMailObj()
	return self.mailObj
end

function MailContentView:removeRewardView()
	if self.contentLine then	
		self.contentLine:removeFromParentAndCleanup(true)
		self.contentLine = nil
	end
--[[	if self.pcickupBtn then	
		self.pcickupBtn:removeFromParentAndCleanup(true)
		self.pcickupBtn = nil
	end--]]
	if self.rewardLable then
		self.rewardLable:removeFromParentAndCleanup(true)
		self.rewardLable = nil
	end
	if self.rewardTitleBg then
		self.rewardTitleBg:removeFromParentAndCleanup(true)
		self.rewardTitleBg = nil
	end	
	if self.rewardFlag then
		self.rewardFlag:removeFromParentAndCleanup(true)
		self.rewardFlag = nil
	end	
end

function MailContentView:onCloseBtnClick()
	--UIManager.Instance:setDeleteOnExit("MailView",true)
	--UIManager.Instance:hideUI("MailView")
end

function MailContentView:setRewardMark()
	if self.mailObj:getMailState() == 0 and self.mailObj:isHaveReward() == 1 then
		--未读有道具				
		self.rewardFlag = createScale9SpriteWithFrameName(RES("mail_property.png"))
		self.titleContentLabelBg:addChild(self.rewardFlag)
		VisibleRect:relativePosition(self.rewardFlag,self.titleContentLabelBg,LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE,ccp(-8,0))	
	else
		if self.rewardFlag then
			self.rewardFlag:removeFromParentAndCleanup(true)
			self.rewardFlag = nil
		end
	end
end