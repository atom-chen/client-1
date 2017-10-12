require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.achievement.subView")
AchieveTabView = AchieveTabView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local oldKey = 0
function AchieveTabView:__init(node)
	self.achieveSubView = 
	{	
		[1] = { name = "achi_enteringArena.png",--[[初入江湖--]] new = subView.New,instance = nil},
		[2] = { name = "achi_fightingDevil.png",--[[降妖除魔--]] new = subView.New,instance = nil},
		[3] = { name = "achi_killBoss.png",--[[击杀BOSS--]] new = subView.New,instance = nil},
		[4] = { name = "achi_upgradeMounts.png",--[[升级坐骑--]] new = subView.New,instance = nil},
		[5] = { name = "achi_officialPromotion.png",--[[官职提升--]] new = subView.New,instance = nil},
		--[6] = { name = "achi_heartDiscipline.png",--[[心法修炼--]] new = subView.New,instance = nil},
		[6] = { name = "achi_earningMedals.png",--[[获得勋章--]] new = subView.New,instance = nil},

	}
	self.text = {}	
	self.newImage = {}
	self.clearImage = {}
	self.parentNode = node
	self:AchieveInitTabView()
	self.currentView = self.achieveSubView[1]
	self.haveCompleted = {}
	for i=1,6 do
		self.haveCompleted[i] = false
	end
	
end
function AchieveTabView:__delete()
	for keys,values in ipairs(self.achieveSubView) do
		if(self.achieveSubView[keys].instance)then
			self.achieveSubView[keys].instance:DeleteMe()
		end
	end
	self.text = {}
	self.newImage =	 {}
	self.clearImage = {}
	self.haveCompleted = {}
end

function AchieveTabView:onEnter()
	self:setCurrentView()
	self:setTabViewImage()
end

function AchieveTabView:onExit()
	oldKey = 0
	for keys , values in ipairs(self.achieveSubView) do
		if self.achieveSubView[keys].instance ~= nil then
			local cell,selectCellIndex = self.achieveSubView[keys].instance.tableView:getTableCellAndSelectCellIndex()
			if cell then
				cell: removeAllChildrenWithCleanup(true)	
			end
			if selectCellIndex then
				selectCellIndex = -1	
			end		
		end
	end
end

function AchieveTabView:AchieveInitTabView(node)
	local btnArray = CCArray:create()	
		
	local function createBtn(keys, values)
			local btn = createButtonWithFramename(RES("btn_2_normal.png"), RES("btn_2_select.png"))										
			self.text[keys] = createScale9SpriteWithFrameName(RES(values.name))			
			self.newImage[keys] = createScale9SpriteWithFrameName(RES("achi_new.png"))	
			self.clearImage [keys] = createScale9SpriteWithFrameName(RES("achi_clear.png"))	
			btn:addChild(self.text[keys])
			btn:addChild(self.newImage[keys])
			btn:addChild(self.clearImage[keys])
			VisibleRect:relativePosition(self.text[keys], btn, LAYOUT_CENTER,ccp(0,0))
			VisibleRect:relativePosition(self.newImage[keys], btn, LAYOUT_CENTER,ccp(10,-20))
			VisibleRect:relativePosition(self.clearImage[keys], btn, LAYOUT_CENTER,ccp(0,-20))
			self.newImage[keys] : setVisible(false)
			self.clearImage[keys] : setVisible(false)
			btnArray:addObject(btn)
			local onTabPress = function()			
				if oldKey ~= keys then
					self:showSubView(keys)
					oldKey = keys
				end
				
			end	
			btn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
		end
		
	for keys,values in ipairs(self.achieveSubView) do
		createBtn(keys, values)
	end
	self.tagView = createTabView(btnArray,-3*g_scale,tab_horizontal)
	if self.parentNode then
		self.parentNode: addChild(self.tagView)
		VisibleRect:relativePosition(self.tagView,self.parentNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(0,-0))
	end
end

function AchieveTabView:setCurrentView()
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()	
	local showPage ,showCellIndex = achievementMgr:getShowPageAndCell()		
	self:showSubView(showPage)
	self.tagView:setSelIndex(showPage-1)	
end		


function AchieveTabView:createSubView(keys)
	local view =  self.achieveSubView[keys].new(keys) 	 	-- 创建实例	
	self.achieveSubView[keys].instance = view 	  	-- 将实例保存在instance字段
	local lnode = view:getRootNode()
	lnode:setVisible(false)						
end	

function AchieveTabView:showSubView(keys)
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()		
	if (self.currentView.instance ~= nil) then
		local oldNode = self.currentView.instance:getRootNode()
		if oldNode and oldNode.setVisible then
			oldNode:setVisible(false)
		end
	end				
	if(self.achieveSubView[keys].instance == nil) then
		self:createSubView(keys) --创建对应的子界面
	end
	local newNode = self.achieveSubView[keys].instance:getRootNode()		
	VisibleRect:relativePosition(newNode, self.tagView, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,0))
	self.achieveSubView[keys].instance.receiveBtn : setVisible(false)
	local id = achievementMgr:getFirstCompletedWithoutRewardedAchievementIdByPage(keys)	
	if id then			
		achievementMgr:openBtn()		
	else
		id = 1
		achievementMgr:closeBtn()
	end	
	self:setTableViewSelected(keys,id)	
	local parentNode = newNode:getParent()
	if(parentNode == nil) then
		self.parentNode : addChild(newNode)
	end
	if newNode and newNode.setVisible then
		newNode:setVisible(true)
	end
	self.currentView = self.achieveSubView[keys]
	self.currentKey = keys
	achievementMgr : fireCompleteList(keys)
end	

function AchieveTabView:setTableViewSelected(keys,id)
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()	
	self.achieveSubView[keys].instance.tableView.selectedCell = id
	self.achieveSubView[keys].instance.tableView:scrollTocell(id)
	achievementMgr:fireRefreshEvent(keys,id)
	local selAchiId = self.achieveSubView[keys].instance.sList[id].refId	
	achievementMgr:fireSelIndex(selAchiId)
end

function AchieveTabView:turnNextPage()
	if(self.currentKey<6) then	
		self:showSubView(self.currentKey+1)
		local curIndex =self.tagView : getSelIndex()
		self.tagView : setSelIndex(curIndex+1)
	end
end
function AchieveTabView:turnFontPage()
	if(self.currentKey>1) then
		self:showSubView(self.currentKey-1)
		local curIndex =self.tagView : getSelIndex()
		self.tagView : setSelIndex(curIndex-1)
	end
end

function AchieveTabView:enterSubView(tag)
	for i,v in pairs(self.achieveSubView) do
		if(v.instance) then
			v.instance:setBtnVisible(tag)
		end
	end
end

function AchieveTabView:refreshSubScroll(key,cellIndex)
	if(self.achieveSubView[key].instance) then
		self.achieveSubView[key].instance:refreshScrollView(cellIndex) 
	end
end
function AchieveTabView:refreshTableView(vType)
	if(self.achieveSubView[vType].instance) then
		self.achieveSubView[vType].instance.tableView:refreshCompletedList(vType)
	end	
end

function AchieveTabView:setSelIndex(index)
	for i,v in pairs(self.achieveSubView) do
		if(v.instance) then
			v.instance:setSelIndex(index)
		end
	end
end

function AchieveTabView:setTabViewImage()
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()	
	for i=1,6 do
		local newFlag = achievementMgr:hasNewAchieveByPage(i)
		local clearFlag = achievementMgr:hasClearAchieveByPage(i)
		if(newFlag == true) then
			self.newImage[i] : setVisible(true)
		end
		if(clearFlag == true) then
			self.clearImage[i] : setVisible(true)
		end
	end	
end


function AchieveTabView:checkNewImage(achieveType)
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()
	local hasNewAchievement = achievementMgr:hasNewAchieveByPage(achieveType)	
	if hasNewAchievement == true then
		self.newImage[achieveType] : setVisible(true)
	else
		self.newImage[achieveType] : setVisible(false)
	end			
end

function AchieveTabView:checkClearImage(achieveType)
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()
	local hasClearAchievement = achievementMgr:hasClearAchieveByPage(achieveType)	
	if hasClearAchievement == true then
		self.clearImage[achieveType] : setVisible(true)
	else
		self.clearImage[achieveType] : setVisible(false)
	end
	
end

function AchieveTabView:hideAllReciveBtn()
	for i,v in pairs(self.achieveSubView) do
		if self.achieveSubView[i].instance then
			self.achieveSubView[i].instance.receiveBtn:setVisible(false)
		end
	end
end
function AchieveTabView:hideNewImage()
	for i = 1,6 do
		if self.newImage and self.newImage[i] then
			self.newImage[i]:setVisible(false)
		end
	end
end