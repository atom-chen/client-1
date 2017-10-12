require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.mail.MailTabView")

MailView = MailView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

function MailView:__init()
	self.viewName = "MailView"
	self:initFullScreen()
	self.MailTabView = MailTabView.New(self.background)	
	local mailNode = createSpriteWithFrameName(RES("mail_titleimg.png"))
	self:setFormImage(mailNode)
	local titleNode = createSpriteWithFrameName(RES("word_mail.png"))
	self:setFormTitle(titleNode, TitleAlign.Left)
end

function MailView:__delete()
	self.MailTabView:DeleteMe()
	self.MailTabView = nil
end

function MailView:create()
	return MailView.New()
end

function MailView:onEnter(arg)
	if arg ~= UIMailType.AllMailType then  --重新打开（不是返回）
		self.MailTabView:initCurrentView()
		self.MailTabView:showSubView(UIMailType.AllMailType ,self.background)		
		self:setSelectedCell2top()		
		self:updateTableView(UIMailType.AllMailType)					
	end
end

function MailView:onExit()

end

function MailView:updateCurrentView()
end

function MailView:updateTableView(key)
	self.MailTabView:updateTableView(key)
end

function MailView:setSelectedCell2top()
	self.MailTabView:setSelectedCell2top()
end

function MailView:onCloseBtnClick()
	--UIManager.Instance:setDeleteOnExit("MailView",true)
end

function MailView:openContentView()
	self.MailTabView:openMailContentView()
end

