require("ui.login.SelectRoleView.ShowSelectRole")
require("object.res.ResManager")
local const_btnZ = 50
local const_fogZ = 49
SelectRoleView = SelectRoleView or BaseClass(LoginBaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
function SelectRoleView:__init()
	self.viewName = "SelectRoleView"
	self.scale = VisibleRect:SFGetScale()
	self:initBackGround()
	--self:initRole()--初始化人物
	self:initFogBg()
	self:initPlayGame()--初始化进入游戏按钮
	self:initCrateRoleBtn()--初始化创建选择角色按钮
	self:initComeBackBtn()--初始化返回按钮
	--self:initRemoveRoleBtn()--初始化删除人物角色按钮
	self:changeBtnState()--改变按钮选择状态
end

function SelectRoleView:__delete()
	self:deleteRole()
end

function SelectRoleView:deleteRole()
	if self.showSelectRole then
		self.showSelectRole:getRootNode():removeFromParentAndCleanup(true)
		self.showSelectRole:DeleteMe()
		self.showSelectRole = nil
	end	
end

function SelectRoleView:create()
	return SelectRoleView.New()
end

function SelectRoleView:onEnter()
	--self.showSelectRole:showScrollView()
	self:initRole()--初始化人物
	self.showSelectRole:changeBtnState()
	
	if self.unFirstEnter then
		self:playAgainAction()
	end
	self.unFirstEnter = true
end

function SelectRoleView:onExit()
	
end


function SelectRoleView:EventVisiableBtnfunc(bVisiable)
	if bVisiable then
		self:setPlayGameBtnVisible(true)
		self:setPlayCrateRoleVisible(false)
		self:setPlayRemoveRoleVisible(true)
	else
		self:setPlayGameBtnVisible(false)
		self:setPlayCrateRoleVisible(true)
		self:setPlayRemoveRoleVisible(false)
	end
end

function SelectRoleView:EventDeleteRolefunc(heroId)
	self.showSelectRole:RemoveRole()--收到服务器消息执行
	UIManager.Instance:hideLoadingHUD()
end

function SelectRoleView:EventEnterGame()
	self:enterGame()
end

function SelectRoleView:EventCreateRole()
	self:createRole()
end

function SelectRoleView:changeBtnState()
	if self.showSelectRole then
		self.showSelectRole:changeBtnState()
	end
end

function SelectRoleView:initBackGround()
	--背景图
	self.bg = CCSprite:create("loginUi/login/selectRoleBg.jpg")
	G_setBigScale(self.bg)
	self.rootNode:addChild(self.bg)
	VisibleRect:relativePosition(self.bg, self.rootNode, LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)
	
	--粒子系统
	local particleSystemQuad = CCParticleSystemQuad:create("particleSystem/UpPoint.plist")
	particleSystemQuad:setPositionType(kCCPositionTypeRelative)
	self.rootNode:addChild(particleSystemQuad)
	VisibleRect:relativePosition(particleSystemQuad,self.rootNode,LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE,ccp(0,-10))
	
	--山
	local mountain = createScale9SpriteWithFrameName(RES("role_mountain1.png"))
	self.rootNode:addChild(mountain)
	VisibleRect:relativePosition(mountain,self.rootNode,LAYOUT_CENTER + LAYOUT_BOTTOM_INSIDE,ccp(0,0))
	
	self:moveBackGroundAction()
end

function SelectRoleView:moveBackGroundAction()
	if self.bg then
		local actionTime = 40
		local moveWidth = (self.bg:getContentSize().width - visibleSize.width)/2
		local moveByLeft1 = CCMoveBy:create(actionTime,ccp(-moveWidth,0))--往左移
		local moveByRight = CCMoveBy:create(actionTime*2,ccp(moveWidth*2,0))--往右移
		local moveByLeft2 = CCMoveBy:create(actionTime,ccp(-moveWidth,0))--往左移
		
		local actionArray = CCArray:create()
		actionArray:addObject(moveByLeft1)
		actionArray:addObject(moveByRight)
		actionArray:addObject(moveByLeft2)
		local repeatForever = CCRepeatForever:create(CCSequence:create(actionArray))
		self.bg:runAction(repeatForever)
	end
end

function SelectRoleView:initRole()
	self:deleteRole()	
	
	self.showSelectRole = ShowSelectRole.New(self)
	self:addChild(self.showSelectRole:getRootNode())
	VisibleRect:relativePosition(self.showSelectRole:getRootNode(),self.rootNode,LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE,ccp(0,70))
	
end

function SelectRoleView:initFogBg()
	--雾层
	local fog4 = CCSprite:create("loginUi/login/role_fog1.png")
	fog4:setScaleX(5)
	fog4:setScaleY(3)
	self.rootNode:addChild(fog4)
	VisibleRect:relativePosition(fog4,self.rootNode,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(-350,-100))
	
	local fog3 = CCSprite:create("loginUi/login/role_fog1.png")
	fog3:setScaleX(4)
	fog3:setScaleY(2)
	fog3:setRotation(85)
	self.rootNode:addChild(fog3)
	VisibleRect:relativePosition(fog3,self.rootNode,LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(200,0))
	
	
	
	--黑底
	local blackBg = createScale9SpriteWithFrameName(RES("login_squares_roleBlackTransit.png"))
	blackBg:setContentSize(CCSizeMake(visibleSize.width,99))
	self.rootNode:addChild(blackBg)
	VisibleRect:relativePosition(blackBg,self.rootNode,LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE)
	
	self:playFogAction()
end

function SelectRoleView:playFogAction()
	
	self.FogActionList = {
	[1] = {name = "loginUi/login/role_fog1.png" , startPosX = -visibleSize.width/2, movetime = 10 },
	[2] = {name = "loginUi/login/role_fog1.png" , startPosX = -visibleSize.width, movetime = 13 },
	[3] = {name = "loginUi/login/role_fog1.png" , startPosX = 0, movetime = 15 },
	[4] = {name = "loginUi/login/role_fog1.png" , startPosX = visibleSize.width/2, movetime = 18}
	}
	
	self.fogList = {}
	for i,v in pairs(self.FogActionList) do
		local fog = CCSprite:create(v.name)
		fog:setScale(2)
		self.rootNode:addChild(fog,const_fogZ)
		VisibleRect:relativePosition(fog,self.rootNode,LAYOUT_RIGHT_OUTSIDE+LAYOUT_BOTTOM_INSIDE,ccp(v.startPosX,0))
		table.insert(self.fogList,fog)
	end
	
	self:playAgainAction()
end

function SelectRoleView:playAgainAction()
	local size = table.size(self.fogList)
	if size~=0 then
		for i,v in pairs(self.fogList) do
			local moveByLeft = CCMoveBy:create(self.FogActionList[i].movetime,ccp(-visibleSize.width*2,0))
			local function finishFogCallback()
				VisibleRect:relativePosition(v,self.rootNode,LAYOUT_RIGHT_OUTSIDE+LAYOUT_BOTTOM_INSIDE,ccp(0,0))
			end
			local callbackAction = CCCallFunc:create(finishFogCallback)
			local actionArray = CCArray:create()
			actionArray:addObject(moveByLeft)
			actionArray:addObject(callbackAction)
			local repeatForever = CCRepeatForever:create(CCSequence:create(actionArray))
			v:stopAllActions()
			v:runAction(repeatForever)
		end
	end
end

function SelectRoleView:initPlayGame()
	--开始按钮
	self.enterGameBtn = createButtonWithFramename(RES("role_RoleBtn.png"))
	if self.enterGameBtn then
		self.enterGameBtn:setScale(self.scale)
		self:addChild(self.enterGameBtn,const_btnZ)
		VisibleRect:relativePosition(self.enterGameBtn, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, CCPointMake(-20,20))
		
		--开始按钮粒子系统
		--local particleSystemQuad = CCParticleSystemQuad:create("particleSystem/fire.plist")
		--particleSystemQuad:setPositionType(kCCPositionTypeRelative)
		--self.enterGameBtn:addChild(particleSystemQuad)
		--VisibleRect:relativePosition(particleSystemQuad,self.enterGameBtn,LAYOUT_CENTER,ccp(7,-30))
		
		--帧动画
		--[[
		local animate = createAnimate("fire",11,0.125)
		local sprite = CCSprite:create()
		local forever = CCRepeatForever:create(animate)
		sprite:runAction(forever)
		self.enterGameBtn:addChild(sprite)
		VisibleRect:relativePosition(sprite, self.enterGameBtn, LAYOUT_CENTER, ccp(0,10))
		--]]
		
		--字
		local font = createScale9SpriteWithFrameName(RES("role_startBtn.png"))
		self.enterGameBtn:addChild(font)
		VisibleRect:relativePosition(font,self.enterGameBtn,LAYOUT_CENTER,ccp(0,-10))
		
		--按键监控
		local startGameFunction = function ()
			self:enterGame()
		end
		self.enterGameBtn:addTargetWithActionForControlEvents(startGameFunction,CCControlEventTouchUpInside)
	else
		CCLuaLog("createButtonWithFramename(RES(role_RoleBtn.png)) Failed")
	end	
end

function SelectRoleView:enterGame()
	--  获取角色等级
	local level = 0
	local LoginManager = LoginWorld.Instance:getLoginManager()
	local heroObj = LoginManager:getLoginHeroObj(self.showSelectRole:getClickHeroIndex())
	if heroObj then
		level = heroObj:getLevel()
	end
	
	if SFLoginManager:getInstance():getPlatform() ~= "win32" and not ResManager.Instance:hasLevelRes(level) then
		ResManager.Instance:setLevel(level)
		ResManager.Instance:downloadExtend(false, DownloadKey.extendAndPatch)
	else
		local characterId = self.showSelectRole:getClickHeroId()
		--进入游戏
		local size = CCDirector:sharedDirector():getVisibleSize()
		LoginWorld.Instance:getLoginManager():requestCharactorLogin(characterId, size.width, size.height)
		UIManager.Instance:showLoadingSence(10)
		self:close()
	end
end

function SelectRoleView:createRole()
	self:onExit()
	GlobalEventSystem:Fire(GameEvent.EVENT_CREATE_ROLE_UI)
end

function SelectRoleView:initCrateRoleBtn()
	--创建角色按钮
	self.enterCrateRole = createButtonWithFramename(RES("role_RoleBtn.png"))
	self.enterCrateRole:setScale(self.scale)
	self:addChild(self.enterCrateRole,const_btnZ)
	VisibleRect:relativePosition(self.enterCrateRole, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, CCPointMake(-20,20))
	
	--开始按钮粒子系统
	--local particleSystemQuad = CCParticleSystemQuad:create("particleSystem/fire.plist")
	--particleSystemQuad:setPositionType(kCCPositionTypeRelative)
	--self.enterCrateRole:addChild(particleSystemQuad)
	--VisibleRect:relativePosition(particleSystemQuad,self.enterCrateRole,LAYOUT_CENTER,ccp(7,-30))
	
	--帧动画
	--[[
	local animate = createAnimate("fire",11,0.125)
	local sprite = CCSprite:create()
	local forever = CCRepeatForever:create(animate)
	sprite:runAction(forever)
	self.enterCrateRole:addChild(sprite)
	VisibleRect:relativePosition(sprite, self.enterCrateRole, LAYOUT_CENTER, ccp(0,10))
	--]]
	
	--字
	local font = createScale9SpriteWithFrameName(RES("role_createRoleBtn.png"))
	self.enterCrateRole:addChild(font)
	VisibleRect:relativePosition(font,self.enterCrateRole,LAYOUT_CENTER,ccp(0,-10))
	
	--按键监控
	local crateRoleFunction = function ()
		LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.CreateRoleStart)
		self:createRole()
	end
	self.enterCrateRole:addTargetWithActionForControlEvents(crateRoleFunction,CCControlEventTouchDown)
end
--[[
function SelectRoleView:initRemoveRoleBtn()
	--删除角色按钮
	self.enterRemoveRole = createButtonWithFramename(RES("role_removeRole.png"))
	self.enterRemoveRole:setScale(self.scale)
	self:addChild(self.enterRemoveRole,const_btnZ)
	VisibleRect:relativePosition(self.enterRemoveRole, self.rootNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE, CCPointMake(20, 20))
	local removeRoleFunction = function ()
		self:RemoveRole()--删除角色
	end
	self.enterRemoveRole:addTargetWithActionForControlEvents(removeRoleFunction,CCControlEventTouchDown)
end--]]

function SelectRoleView:initComeBackBtn()
	--返回按钮
	local m_btnBack = createButtonWithFramename(RES("login_btn_back.png"))
	m_btnBack:setScale(self.scale)
	self.rootNode:addChild(m_btnBack)
	VisibleRect:relativePosition(m_btnBack, self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE, CCPointMake(-25, -15))
	local backFunction = function ()
		self:onExit()
		--首先断开与服务器的连接
		LoginWorld.Instance:getLoginManager():getConnectionService():slientDisConnect()
		local manager =UIManager.Instance
		manager:showUI("AllServerView")
	end
	m_btnBack:addTargetWithActionForControlEvents(backFunction,CCControlEventTouchDown)
end

function SelectRoleView:RemoveRole()
	local getChatText = function (arg,text,id)
		if id == 1 then   --否
		elseif id == 2 then   --确定
			self:checkInPut(text)
		end
	end
	UIManager.Instance:showMsgBoxWithEdit("      ", self, getChatText,nil,Config.LoginWords[327],18)
end

function SelectRoleView:checkInPut(text)
	local chilktext = string.lower(text)
	if chilktext=="ok" then
		local clickHeroId = self.showSelectRole:getClickHeroId()
		--发送删除角色的id给服务器
		LoginWorld.Instance:getLoginManager():requestCharactoRemoveRole(clickHeroId)
		UIManager.Instance:showLoadingHUD(10)
	else
		UIManager.Instance:showSystemTips(Config.LoginWords[327])
	end
end

function SelectRoleView:setPlayGameBtnVisible(bVisible)
	if self.enterGameBtn then
		self.enterGameBtn:setVisible(bVisible)
	end
end

function SelectRoleView:setPlayCrateRoleVisible(bVisible)
	if self.enterCrateRole then
		self.enterCrateRole:setVisible(bVisible)
	end
end

function SelectRoleView:setPlayRemoveRoleVisible(bVisible)
	if self.enterRemoveRole then
		self.enterRemoveRole:setVisible(bVisible)
	end
end
