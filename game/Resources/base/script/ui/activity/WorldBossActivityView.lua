require("common.BaseUI")
require("config.words")
require("ui.activity.WorldBossActivityInfoView")
require("ui.activity.WorldBossTeamListView")
WorldBossActivityView = WorldBossActivityView or BaseClass(BaseUI)

function WorldBossActivityView:__init()
	self.viewName = "WorldBossActivityView"			
	self:initFullScreen()	
	local titleImage = createSpriteWithFrameName(RES("teamBoss_word.png"))
	self:setFormTitle(titleImage,TitleAlign.Center)		
	self.viewTable = {
		[2] = {create = WorldBossActivityInfoView.New,viewName = "worldBossActivityInfoView",instance = nil},
		[1] = {create = WorldBossTeamListView.New,viewName = "worldBossTeamListView",instance = nil},
	}
	self.selectView = nil
	self:createTabView()
	selectIndex = 1
	self.tagView:setSelIndex(2)
	self.viewTable[1].instance = self.viewTable[1].create()
	self.viewTable[2].instance = self.viewTable[2].create()	
	self:addChild(self.viewTable[1].instance:getRootNode())		
	
	VisibleRect:relativePosition(self.viewTable[1].instance:getRootNode(),self:getContentNode(),LAYOUT_CENTER+LAYOUT_TOP_INSIDE)		
	self:addChild(self.viewTable[2].instance:getRootNode())	
	VisibleRect:relativePosition(self.viewTable[2].instance:getRootNode(),self:getContentNode(),LAYOUT_CENTER+LAYOUT_TOP_INSIDE)					
	self.viewTable[1].instance:getRootNode():setVisible(false)
	self.viewTable[2].instance:getRootNode():setVisible(false)	
end	

function WorldBossActivityView:createTabView()
	local createContent = {	
	Config.Words[25502],
	Config.Words[25501],
	}
	local btnArray = CCArray:create()
	for key,value in ipairs(createContent) do
		local button = createButtonWithFramename(RES("tab_2_normal.png"), RES("tab_2_select.png"))		
		local label = createLabelWithStringFontSizeColorAndDimension(value, "Arial", FSIZE("Size2"), FCOLOR("ColorWhite1"),CCSizeMake(16,0))		
		button:setTitleString(label)
		btnArray:addObject(button)
		local onTabPress = function()
			if key == 1 then
				local mgr = GameWorld.Instance:getWorldBossActivityMgr()
				if  mgr:IsAtWorldBossScene()  then  -- 活动地宫才能打开组队列表界面		
					local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
					teamMgr:requestBossTeamList()		
					--self.viewTable[1].instance:updateTeamListView()
				else	--
					UIManager.Instance:showSystemTips(Config.Words[25527])	
					--self.tagView:setSelIndex(1)	
					return 
				end
			end
			self:showView(key)
		end
		button:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)		
	end
	self.tagView = createTabView(btnArray, 10, tab_vertical)
	local contentNode = self:getContentNode()
	contentNode:addChild(self.tagView)
	VisibleRect:relativePosition(self.tagView,contentNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_OUTSIDE,ccp(-15,-13))
end

function WorldBossActivityView:showView(index)	
	if index == 1 then
		self.viewTable[1].instance:setTitleText()
	else
		self.viewTable[2].instance:update()
	end	

	if self.selectView then		
		self.selectView.instance:getRootNode():setVisible(false)
		self.selectView = self.viewTable[index]	
		self.selectView.instance:getRootNode():setVisible(true)
	else			
		self.selectView = self.viewTable[index]
		self.selectView.instance:getRootNode():setVisible(true)
	end
end

function WorldBossActivityView:updateTeamListView()
	if self.viewTable[1].instance:getRootNode():isVisible() then
		self.viewTable[1].instance:updateTeamListView()
	end
end

function WorldBossActivityView:onEnter(arg)
	if arg then
		self:showView(arg)
		self.tagView:setSelIndex(arg-1)
	else
		self:showView(2)
		self.tagView:setSelIndex(1)
	end
end	

function WorldBossActivityView:__delete()

end	

function WorldBossActivityView:create()
	return WorldBossActivityView.New()
end	
