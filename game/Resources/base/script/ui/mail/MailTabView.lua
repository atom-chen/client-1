require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.mail.MailAllView")
require("ui.mail.MailNoticeView")
require("ui.mail.MailActivityView")
require("ui.mail.MailGMView")
MailTabView = MailTabView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

UIMailType = {
	NoticeMailType = 1,	
	ActivityMailType = 2,	
	GMMailType = 3,
	AllMailType = 4,
}	

local MailSubViews = 
{	
	[UIMailType.NoticeMailType] 	= { name = Config.Words[8002],--[[公告--]] new = MailNoticeView.New,instance = nil},
	[UIMailType.ActivityMailType] 	= { name = Config.Words[8001],--[[活动--]] new = MailActivityView.New,instance = nil},	
	[UIMailType.GMMailType] 		= { name = Config.Words[8013],--[[GM--]] new = MailGMView.New,instance = nil},
	[UIMailType.AllMailType] 		= { name = Config.Words[8000],--[[全部--]] new = MailAllView.New,instance = nil},
} 

function MailTabView:__init(background)
	self.text = {}
	self:MailInitTabView(background)
	self.currentView = MailSubViews[UIMailType.AllMailType]
	self:showSubView(UIMailType.AllMailType,background)
	
end

function MailTabView:__delete()
	for keys,v in ipairs(MailSubViews) do
		MailSubViews[keys].instance:DeleteMe()
		MailSubViews[keys].instance = nil
	end
	self.text = {}
end

function  MailTabView:MailInitTabView(background)
	self.rootNode : setContentSize(CCSizeMake(960*0.8,640*0.9))
	local btnArray = CCArray:create()		
	for keys,values in ipairs(MailSubViews) do
		function createBtn(keys) 			
			self:createSubView(keys,background) --创建对应的子界面
			local btn = createButtonWithFramename(RES("tab_2_normal.png"), RES("tab_2_select.png"))										
			self.text[keys] = createLabelWithStringFontSizeColorAndDimension(MailSubViews[keys].name, "Arial", FSIZE("Size4"), FCOLOR("White1"), CCSizeMake(22*g_scale, 0))
			
			btn:addChild(self.text[keys])
			VisibleRect:relativePosition(self.text[keys], btn, LAYOUT_CENTER,ccp(0,-4))
			btnArray:addObject(btn)
			local onTabPress = function()			
				self:showSubView(keys,background)
				MailSubViews[keys].instance:setSelectedCell(1)
				self:updateTableView(keys)
			end	
			btn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
		end
		createBtn(keys)
	end
	self.tagView = createTabView(btnArray,10*g_scale,tab_vertical)
	background: addChild(self.tagView, 1)
	VisibleRect:relativePosition(self.tagView,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(-24,-77))	
end
function MailTabView:initCurrentView()
	self.tagView : setSelIndex(3)
end

function MailTabView:createSubView(keys,background)
	local view =  MailSubViews[keys].new(background)  	-- 创建实例
	if MailSubViews[keys].instance then
		MailSubViews[keys].instance = nil
	end
	MailSubViews[keys].instance = view 	  	-- 将实例保存在instance字段
	local node = view:getRootNode()	
	node:setVisible(false)						
end

function MailTabView:showSubView(keys,background)
	if (self.currentView.instance ~= nil) then
		local oldNode = self.currentView.instance:getRootNode()
		--oldNode:setVisible(false)
		background : removeChild(oldNode,true)
	end		
	local newNode = MailSubViews[keys].instance:getRootNode()
	local parentNode = newNode:getParent()
	if(parentNode ~= self.rootNode) then
		background : addChild(newNode)
	end
	newNode:setVisible(true)
	self.currentView = MailSubViews[keys]
	VisibleRect:relativePosition(newNode, self.tagView, LAYOUT_RIGHT_OUTSIDE+LAYOUT_TOP_INSIDE, ccp(-16, -31))	
end

function MailTabView:updateTableView(key)
	if MailSubViews[UIMailType.AllMailType].instance then
		MailSubViews[UIMailType.AllMailType].instance:updateMailTable()
	end
	if MailSubViews[key].instance then
		MailSubViews[key].instance:updateMailTable()
	end
end

function MailTabView:updateAllTableView()
	for keys,v in ipairs(MailSubViews) do
		if MailSubViews[keys].instance then
			MailSubViews[keys].instance:updateMailTable()
		end				
	end	
end

function MailTabView:setSelectedCell2top()
	MailSubViews[1].instance:setSelectedCell(1)
end

function MailTabView:openMailContentView()
	--[[if MailSubViews[self.currentView].instance then
		MailSubViews[self.currentView].instance:openContentView()
	end--]]
	self.currentView.instance:openContentView()
end
