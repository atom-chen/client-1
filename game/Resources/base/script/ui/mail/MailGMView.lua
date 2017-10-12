require("ui.UIManager")
require("config.words")
require("ui.mail.MailTableView")
MailGMView = MailGMView or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local tableSize = CCSizeMake(839*g_scale,465*g_scale)	

function MailGMView:__init(background)
	self.viewName = "MailGMView"
	self.rootNode = CCNode:create()	
	self.rootNode :  setContentSize(CCSizeMake(960*0.8,640*0.7))
	self.rootNode:retain()
	self.background = background
	self:initMailGMView()	
	self:initNoticeViewData()	
end

function MailGMView:__delete()
	self.tableView:DeleteMe()
	self.tableView = nil
	self.rootNode:release()
end

function MailGMView:getRootNode()
	return self.rootNode
end

function MailGMView:initMailGMView()
	--±³¾°
	self.tableView_bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(843,473))
	self.rootNode:addChild(self.tableView_bg)
	VisibleRect:relativePosition(self.tableView_bg,self.rootNode, LAYOUT_CENTER, ccp(53, 41))	

	--Î´¶ÁÓÊ¼þ	
	self.mailUnreadLabelHead = createLabelWithStringFontSizeColorAndDimension(Config.Words[8006], "Arial", FSIZE("Size2"), FCOLOR("ColorYellow5"))
	self.rootNode:addChild(self.mailUnreadLabelHead)
	VisibleRect:relativePosition(self.mailUnreadLabelHead,self.tableView_bg,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(20,-5))
	self.mailUnreadNum = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size2"), FCOLOR("ColorYellow5"))
	self.rootNode:addChild(self.mailUnreadNum)
	self.mailUnreadNum:setAnchorPoint(ccp(0, 0.5))
	VisibleRect:relativePosition(self.mailUnreadNum,self.mailUnreadLabelHead,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(10,0))	
end

function MailGMView:initNoticeViewData()
	self:createMailTalbeView()
	self:setMailUnreadLb()
end

function MailGMView:createMailTalbeView()
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()			
	local list = mailMgr:getMailListByType(2)
	local number = table.size(list)	
	self.tableView = MailTableView.New()
	self.tableView:initTableView(self.rootNode,tableSize,list)
	local layoutP = ccp(0,-5)
	self.tableView:setTablePosition(self.tableView_bg,layoutP)
end

function MailGMView:setMailUnreadLb()
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	local mailSum = mailMgr:getGMMailNum()
	local unReadNum = mailMgr:getGMMailUnreadNum()
	local text = "0/0"
	if mailSum and unReadNum then
		text = unReadNum .. "/" .. mailSum
	end		
	self.mailUnreadNum:setString(text)
end

function MailGMView:updateMailTable()
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	local list = mailMgr:getMailListByType(2)
	self.tableView:updateMailTable(list)
	self:setMailUnreadLb()	
end

function MailGMView:setSelectedCell(index)
	self.tableView:setSelectedCell(index)
end

function MailGMView:openContentView()
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	local list = mailMgr:getMailListByType(2)
	self.tableView:openMail(list)
end