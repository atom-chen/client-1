require("ui.UIManager")
require("config.words")
require("ui.mail.MailTableView")
require("object.mail.MailObject")
require("gameevent.GameEvent")
MailAllView = MailAllView or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local tableSize = CCSizeMake(839*g_scale,465*g_scale)	

function MailAllView:__init(background)
	self.viewName = "MailAllView"	
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(CCSizeMake(960*0.8,640*0.7))
	self.rootNode:retain()
	self.background = background
	self:initMailAllView()		
	self:initNoticeViewData()	
end

function MailAllView:getRootNode()
	return self.rootNode
end

function MailAllView:__delete()
	self.tableView:DeleteMe()
	self.rootNode:release()
	self.tableView = nil
end

function MailAllView:initMailAllView()
	--±³¾°
	self.tableView_bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(843,473))
	self.rootNode:addChild(self.tableView_bg)
	VisibleRect:relativePosition(self.tableView_bg,self.rootNode, LAYOUT_CENTER, ccp(53, 41))
	--[[self.tableView_bg2 = createScale9SpriteWithFrameName(RES("common_BgFrameimage.png"))
	self.rootNode:addChild(self.tableView_bg2)
	VisibleRect:relativePosition(self.tableView_bg2,self.tableView_bg,LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X,ccp(0,-5))--]]

	--Î´¶ÁÓÊ¼þ	
	self.mailUnreadLabelHead = createLabelWithStringFontSizeColorAndDimension(Config.Words[8006], "Arial", FSIZE("Size2"), FCOLOR("ColorYellow5"))	
	self.rootNode:addChild(self.mailUnreadLabelHead)
	VisibleRect:relativePosition(self.mailUnreadLabelHead,self.tableView_bg,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(20,-5))
	self.mailUnreadNum = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size2"), FCOLOR("ColorYellow5"))
	self.rootNode:addChild(self.mailUnreadNum)
	self.mailUnreadNum:setAnchorPoint(ccp(0, 0.5))
	VisibleRect:relativePosition(self.mailUnreadNum,self.mailUnreadLabelHead,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(10,0))	
end

function MailAllView:initNoticeViewData()
	self:createMailTalbeView()
	self:setMailUnreadLb()
end

function MailAllView:createMailTalbeView()
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()	
	self.allMailList = mailMgr:getMailList()	
	local list = self.allMailList
	local number = table.size(list)	
	self.tableView = MailTableView.New()
	self.tableView:initTableView(self.rootNode,tableSize,list)
	local layoutP = ccp(0,-5)
	self.tableView:setTablePosition(self.tableView_bg,layoutP)
end

function MailAllView:setMailUnreadLb()
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	local unReadNum = mailMgr:getMailUnreadNum()
	local mailSum = mailMgr:getMailSum()
	local text = "0/0"
	if mailSum and unReadNum then
		text = unReadNum .. "/" .. mailSum
	end	
	self.mailUnreadNum:setString(text)	
end

function MailAllView:updateMailTable()
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	local list = mailMgr:getMailList()
	self.tableView:updateMailTable(list)
	self:setMailUnreadLb()	
end

function MailAllView:setSelectedCell(index)
	self.tableView:setSelectedCell(index)
end

function MailAllView:openContentView()
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	local list = mailMgr:getMailList()
	self.tableView:openMail(list)
end