require("ui.UIManager")
require("config.words")
require("ui.mail.MailTableView")
MailNoticeView = MailNoticeView or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local tableSize = CCSizeMake(839*g_scale,465*g_scale)	

function MailNoticeView:__init(background)
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(CCSizeMake(960*0.8,640*0.7))
	self.rootNode:retain()
	self.background = background
	self:initMailNoticeView()
	self:initNoticeViewData()	
end

function MailNoticeView:__delete()
	self.tableView:DeleteMe()
	self.tableView = nil
	self.rootNode:release()
end

function MailNoticeView:getRootNode()
	return self.rootNode
end

function MailNoticeView:initMailNoticeView()
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
	self.mailUnreadNum = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size2")*g_scale, FCOLOR("ColorYellow5"))
	self.rootNode:addChild(self.mailUnreadNum)
	self.mailUnreadNum:setAnchorPoint(ccp(0, 0.5))
	VisibleRect:relativePosition(self.mailUnreadNum,self.mailUnreadLabelHead,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(10,0))
end

function MailNoticeView:initNoticeViewData()
	self:createMailTalbeView()
	self:setMailUnreadLb()
end

function MailNoticeView:createMailTalbeView()
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()			
	local list = mailMgr:getMailListByType(1)
	local number = table.size(list)	
	self.tableView = MailTableView.New()
	self.tableView:initTableView(self.rootNode,tableSize,list)
	local layoutP = ccp(0,-5)
	self.tableView:setTablePosition(self.tableView_bg,layoutP)
end

function MailNoticeView:setMailUnreadLb()
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	local text = "0/0"
	local unReadNum = mailMgr:getNoticeMailUnreadNum()
	local mailSum = mailMgr:getNoticeMailNum()
	if unReadNum and mailSum then
		text = unReadNum .. "/" .. mailSum
	end		
	self.mailUnreadNum:setString(text)	
end

function MailNoticeView:updateMailTable()
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	local list = mailMgr:getMailListByType(1)
	self.tableView:updateMailTable(list)
	self:setMailUnreadLb()	
end

function MailNoticeView:setSelectedCell(index)
	self.tableView:setSelectedCell(index)
end

function MailNoticeView:openContentView()
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	local list = mailMgr:getMailListByType(1)
	self.tableView:openMail(list)
end
