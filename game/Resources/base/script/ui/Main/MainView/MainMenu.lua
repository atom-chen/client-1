--[[
主界面主菜单
--]]
require("config.MainMenuConfig")
require("ui.utils.MainMenuOpenCondition")
require("ui.utils.UIControl")
MainMenu = MainMenu or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()

function MainMenu:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(visibleSize)		
	self.scale = VisibleRect:SFGetScale()

	self.batchNode = nil
	self.btns = {}
	self.btnsname = {}
	self.menuLayer = {}
	self.enableBtn = true
	self:showView()
end

function MainMenu:__delete()
	self.openCondition:DeleteMe()
	self.openCondition = nil
	self.btns = {}
	self.menuLayer = {}
	self.btnsname = {}
	
	--[[CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(MainMenu_Btn.Btn_wing), 0)
	CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(MainMenu_Btn.Btn_mount), 0)
	CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(MainMenu_Btn.Btn_talisman), 0)--]]	
end

function MainMenu:getRootNode()
	return self.rootNode
end	

function MainMenu:showView()
	local offectX = 8	
	local offectY = 0
	self.openCondition = MainMenuOpenCondition.New() 
	
	--创建主菜单
	for j,v in ipairs(Config.MainMenu) do 
		self.menuLayer[j] = CCLayer:create()
		self.menuLayer[j]:setContentSize(CCSizeMake(86,103))
		self.rootNode:addChild(self.menuLayer[j] )	
		self.menuLayer[j]:setScale(self.scale)
		self.menuLayer[j]:setTouchEnabled(true)
		VisibleRect:relativePosition(self.menuLayer[j] , self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE, v.relativePosition)
		
		self.btns[j] = createSpriteWithFrameName(RES(v.icon))
		self.btns[j]:setScale(self.scale)	
		if self.batchNode == nil then
			self.batchNode = SFSpriteBatchNode:createWithTexture(self.btns[j]:getTexture()) 
		end
		self.batchNode:addChild(self.btns[j])		
		--self.rootNode:addChild(self.btns[j])						
		VisibleRect:relativePosition(self.btns[j] , self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE, v.relativePosition)
		
		if v.name then
			self.btnsname[j] = createSpriteWithFrameName(RES(v.name))	
			self.btns[j]:setScale(self.scale)		
			--self.btns[j]:addChild(self.btnsname[j])	
			self.batchNode:addChild(self.btnsname[j])					
			VisibleRect:relativePosition(self.btnsname[j] , self.btns[j], LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER,ccp(0,-5))	
		end	
				
		v.clickfunc = self:clickBtn(j)	--点击响应
		self:registerMainMenuTouchHandler(self.menuLayer[j] , j, v.clickfunc)
		v.condition = self.openCondition:isBtnOpen(j)		--是否开启
		self:setMenuBtnOpenOrclose(j,v.condition, false)			
	end	
	self.batchNode:setZOrder(-1)
	self.rootNode:addChild(self.batchNode)		
	--Debug	
	local platForm = CCUserDefault:sharedUserDefault():getStringForKey("PlatForm")
	--local qdKey = SFLoginManager:getInstance():getQDKey()
	if platForm == "WIN32" --[[or qdKey == "develop"--]] then
		local Btn_debug = createButtonWithFramename(RES("btn_2_normal.png"), RES("btn_2_select.png"))
		local btnLabel = createLabelWithStringFontSizeColorAndDimension("Debug", "Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))
		Btn_debug : addChild(btnLabel)
		VisibleRect:relativePosition(btnLabel,Btn_debug,LAYOUT_CENTER)
		Btn_debug:setScale(self.scale)
		self.rootNode:addChild(Btn_debug)
		VisibleRect:relativePosition(Btn_debug, self.btns[MainMenu_Btn.Btn_role],  LAYOUT_CENTER + LAYOUT_TOP_OUTSIDE, CCPointMake(0, 10))
		local Btn_debugfunc = function ()	
			if (self.enableBtn == false) then
				return
			end
		GlobalEventSystem:Fire(GameEvent.EventOpenDebugView)		
		end
		Btn_debug:addTargetWithActionForControlEvents(Btn_debugfunc,CCControlEventTouchDown)
	end	
	
end

function MainMenu:setViewHide()
	local deleteMyself = function ()
		self.rootNode:setVisible(false)
	end
	local ccfunc = CCCallFuncN:create(deleteMyself)
	local actionArray = CCArray:create()
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(0,-visibleSize.height/3))	
	actionArray:addObject(moveBy)	
	actionArray:addObject(ccfunc)
	local sequence = CCSequence:create(actionArray)	
	self.rootNode:runAction(sequence)
end

function MainMenu:setViewShow()
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(0,visibleSize.height/3))	
	self.rootNode:setVisible(true)
	self.rootNode:runAction(moveBy)	
end

function MainMenu:clickBtn(Btn)
	--角色		
	local Btn_rolefunc = function ()	
		if (Config.MainMenu[MainMenu_Btn.Btn_role].condition == false) then		
			return
		end
		local player = {playerObj=nil,playerType =0}	--0:玩家自己的信息
		GlobalEventSystem:Fire(GameEvent.EventHideAllUI)
		GlobalEventSystem:Fire(GameEvent.EventOpenRoleView, E_ShowOption.eMove2Left,player) 
		GlobalEventSystem:Fire(GameEvent.EVENT_OpenDetailProperty, E_ShowOption.eMove2Right,player)
		self:clickBagBtn(MainMenu_Btn.Btn_role)
	end
		
	--背包				
	local Btn_bagfunc = function ()	
		if (Config.MainMenu[MainMenu_Btn.Btn_bag].condition == false) then		
			return
		end
		GlobalEventSystem:Fire(GameEvent.EventOpenBag, nil, {contentType = E_BagContentType.All, delayLoadingInterval = 0.05})
		self:clickBagBtn(MainMenu_Btn.Btn_bag)
	end		
	
	--技能	
	local Btn_skillfunc = function ()	
		if (Config.MainMenu[MainMenu_Btn.Btn_skill].condition == false) then		
			return
		end
		GlobalEventSystem:Fire(GameEvent.EventOpenSkillView)
		self:clickBagBtn(MainMenu_Btn.Btn_skill)
	end		

	--任务	
	--local Btn_taskfunc = function ()	
	--	if (Config.MainMenu[MainMenu_Btn.Btn_task].condition == false) then		
	--		return
	--	end
	--	GlobalEventSystem:Fire(GameEvent.EVENT_Quest_UI)
	--end
	
	--公会			
	local Btn_factionfunc = function ()	
		if (Config.MainMenu[MainMenu_Btn.Btn_faction].condition == false) then		
			return
		end
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
		factionMgr:requestFactionList("2","1")	
		UIManager.Instance:showLoadingHUD(10,self.rootNode)	
		
	end		
	
	--法宝	
	local Btn_artifactfunc = function ()	
		if (Config.MainMenu[MainMenu_Btn.Btn_talisman].condition == false) then		
			UIManager.Instance:showSystemTips(Config.MainMenu[MainMenu_Btn.Btn_talisman].tips)
			return
		end
		GlobalEventSystem:Fire(GameEvent.EventTalismanViewOpen)
		self:clickBagBtn(MainMenu_Btn.Btn_talisman)
	end		
		
	--坐骑		
	local Btn_mountfunc = function (eventType)	
		if (Config.MainMenu[MainMenu_Btn.Btn_mount].condition == false) then	
			UIManager.Instance:showSystemTips(Config.MainMenu[MainMenu_Btn.Btn_mount].tips )	
			return
		end
		GlobalEventSystem:Fire(GameEvent.EventMountWindowOpen)
		self:clickBagBtn(MainMenu_Btn.Btn_mount)
	end
	
	--翅膀	
	local Btn_wingfunc = function ()	
		if (Config.MainMenu[MainMenu_Btn.Btn_wing].condition == false) then		
			UIManager.Instance:showSystemTips(Config.MainMenu[MainMenu_Btn.Btn_wing].tips )	
			return
		end
		GlobalEventSystem:Fire(GameEvent.EventOpenWingView)	
		self:clickBagBtn(MainMenu_Btn.Btn_wing)
	end		
	
	--锻造		
	local Btn_forgefunc = function ()	
		if (Config.MainMenu[MainMenu_Btn.Btn_forge].condition == false) then	
			UIManager.Instance:showSystemTips(Config.MainMenu[MainMenu_Btn.Btn_forge].tips )		
			return
		end
		GlobalEventSystem:Fire(GameEvent.EventOpenForgingView)
	end

	--成就	
	local Btn_achievefunc = function ()	
		if (Config.MainMenu[MainMenu_Btn.Btn_achieve].condition == false) then		
			return
		end
		
		GlobalEventSystem:Fire(GameEvent.EventOpenAchieveView)			
	end	
	
	--设置	
	local Btn_setting = function ()	
		if (Config.MainMenu[MainMenu_Btn.Btn_setting].condition == false) then		
			return
		end
		GlobalEventSystem:Fire(GameEvent.EventShowSettingView)
		self:clickBagBtn(MainMenu_Btn.Btn_setting)			
	end	
	
	--商场
	local Btn_shop = function ()	
		if (Config.MainMenu[MainMenu_Btn.Btn_shop].condition == false) then		
			return
		end
		GlobalEventSystem:Fire(GameEvent.EventOpenMallView)			
	end	
	
	local Btn_auction = function ()	
		if (Config.MainMenu[MainMenu_Btn.Btn_auction].condition == false) then		
			return
		end
--		showMsgBox(Config.Words[468])
		GlobalEventSystem:Fire(GameEvent.EventOpenAuctionView)			
	end	
	
	if Btn == MainMenu_Btn.Btn_role then
		
		return Btn_rolefunc
	elseif Btn == MainMenu_Btn.Btn_bag then
		return Btn_bagfunc
	elseif Btn == MainMenu_Btn.Btn_skill then
		return Btn_skillfunc
	--elseif Btn == MainMenu_Btn.Btn_task then
		--return Btn_taskfunc
	elseif Btn == MainMenu_Btn.Btn_faction then
		return Btn_factionfunc
	elseif Btn == MainMenu_Btn.Btn_talisman then
		return Btn_artifactfunc
	elseif Btn == MainMenu_Btn.Btn_mount then
		return Btn_mountfunc
	elseif Btn == MainMenu_Btn.Btn_wing then
		return Btn_wingfunc
	elseif Btn == MainMenu_Btn.Btn_forge then
		return Btn_forgefunc
	elseif Btn == MainMenu_Btn.Btn_achieve then
		return Btn_achievefunc
	elseif Btn == MainMenu_Btn.Btn_setting then
		return Btn_setting
	elseif Btn == MainMenu_Btn.Btn_shop then
		return Btn_shop
	elseif Btn == MainMenu_Btn.Btn_auction then
		return Btn_auction
	end				
end
--[[--关闭动画
function MainMenu:removeAnimateByBtnId(btnId)
	if self.btns[btnId]:getChildByTag(btnId) then
		self.btns[btnId]:removeChildByTag(btnId, true)
		CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(btnId), 1)
	end
end--]]
--停止动画
function MainMenu:stopMenuAction(btnId)
	if self.btns[btnId] then
		self.btns[btnId]:stopAllActions()
		CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(btnId), 1)
	end
end

--禁用启用按钮点击
function MainMenu:setMenuBtnstatus(MenuBtn,bEnable)
	Config.MainMenu[MenuBtn].condition = bEnable
	if bEnable == true then
		UIControl:SpriteSetColor(self.btns[MenuBtn],self.btnsname[MenuBtn])	
	elseif bEnable == false then
		UIControl:SpriteSetGray(self.btns[MenuBtn],self.btnsname[MenuBtn])	
	end	
end

--禁用启用所有按钮点击
function MainMenu:setAllBtnStatus(bEnable)
	for j,v in ipairs(self.btns) do
		Config.MainMenu[j].condition = bEnable
		if bEnable == true then
			UIControl:SpriteSetColor(self.btns[j],self.btnsname[j])	
		elseif bEnable == false then
			UIControl:SpriteSetGray(self.btns[j],self.btnsname[j])	
		end			
	end
end



--按钮功能开启/禁用
function MainMenu:setMenuBtnOpenOrclose(MenuBtn,bEnable, canOpen)
	Config.MainMenu[MenuBtn].condition = bEnable	
	if bEnable == true then		
		if self.btns[MenuBtn] then
			UIControl:SpriteSetColor(self.btns[MenuBtn],self.btnsname[MenuBtn])						
			self.rootNode:removeChildByTag(MenuBtn, true)			
			
			if MenuBtn==MainMenu_Btn.Btn_mount or MenuBtn==MainMenu_Btn.Btn_wing or MenuBtn==MainMenu_Btn.Btn_talisman or MenuBtn == MainMenu_Btn.Btn_forge then
				if canOpen then
					CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(MenuBtn+100), 1)
				else
					CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(MenuBtn+100), 0)
				end							
				--[[local a = CCUserDefault:sharedUserDefault():getIntegerForKey(tostring(MenuBtn))		
				local b = CCUserDefault:sharedUserDefault():getIntegerForKey(tostring(MenuBtn+100)) 	
				print("btn=",tostring(MenuBtn))
				print("a=",a)
				print("b=",b)--]]
				if CCUserDefault:sharedUserDefault():getIntegerForKey(tostring(MenuBtn))~=1 and CCUserDefault:sharedUserDefault():getIntegerForKey(tostring(MenuBtn+100))==1 then
					require("utils.GameUtil")				
					GameUtil:createAndRunScaleAction(self.btns[MenuBtn])					
				end
			end			
		end										
	end
	if bEnable == false then
		--设置为灰度图		
		UIControl:SpriteSetGray(self.btns[MenuBtn],self.btnsname[MenuBtn])			
		local lockIcon = createSpriteWithFrameName(RES("bagBatch_small_lock.png"))
		--UIControl:SpriteSetGray(lockIcon)
		local textLabel = createLabelWithStringFontSizeColorAndDimension("Lv" .. Config.MainMenu[MenuBtn].openlevel,"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))
		lockIcon:addChild(textLabel)	
		lockIcon:setTag(MenuBtn)			
		self.rootNode:addChild(lockIcon)
		VisibleRect:relativePosition(textLabel,lockIcon, LAYOUT_CENTER)			
		VisibleRect:relativePosition(lockIcon,self.btns[MenuBtn], LAYOUT_CENTER)				
	end
end

function MainMenu:registerMainMenuTouchHandler(node, argIndex, callBackFunc)
	local function ccTouchHandler(eventType, x, y)		
		return self:touchHandlerabc(node, eventType, x, y, argIndex, callBackFunc)
	end
	node:registerScriptTouchHandler(ccTouchHandler, false, UIPriority.Control, true)
end

function MainMenu:touchHandlerabc(node, eventType, x, y, argIndex, callBackFunc)
	if node:isVisible() and node:getParent() then
		local parent = node:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = node:boundingBox()
		if rect:containsPoint(point) then
			--if Config.MainMenu[argIndex].condition then
				if eventType == "began" then				
					self:ccTouchBegan(argIndex)
				elseif eventType == "ended" then					
					callBackFunc(argIndex)					
					self:ccTouchEnded(argIndex)	
				end								
				return 1
			--[[else								
				return 1
			end	--]]
		else
			if eventType == "ended" then
				self:ccTouchEnded(argIndex)	
			end						
		end				
	else		
		return 0
	end
end

function MainMenu:ccTouchBegan(argIndex)
	local scaleTo = CCScaleTo:create(0.05,0.95)
	self.btns[argIndex]:runAction(scaleTo)
end	

function MainMenu:ccTouchEnded(argIndex)
	local scaleTo = CCScaleTo:create(0.05,1)
	self.btns[argIndex]:runAction(scaleTo)
end

function MainMenu:getMenuNode(argIndex)
	return self.menuLayer[argIndex]
end

-----------------------------------------------------------
--新手指引
function MainMenu:getBagBtn()
	local btn = self.btns[MainMenu_Btn.Btn_bag]
	return btn
end

function MainMenu:getRoleBtn()
	local btn = self.btns[MainMenu_Btn.Btn_role]
	return btn
end

function MainMenu:getMountBtn()
	local btn = self.btns[MainMenu_Btn.Btn_mount]
	return btn
end

function MainMenu:getWingBtn()
	local btn = self.btns[MainMenu_Btn.Btn_wing]
	return btn
end

function MainMenu:getTalismanBtn()
	local btn = self.btns[MainMenu_Btn.Btn_talisman]
	return btn
end

function MainMenu:getSettingBtn()
	local btn = self.btns[MainMenu_Btn.Btn_setting]
	return btn
end

function MainMenu:getSkillBtn()
	local btn = self.btns[MainMenu_Btn.Btn_skill]
	return btn
end

function MainMenu:clickBagBtn(menu)
	if menu==MainMenu_Btn.Btn_role or
		menu==MainMenu_Btn.Btn_mount or
		menu==MainMenu_Btn.Btn_wing or
		menu==MainMenu_Btn.Btn_bag or
		menu==MainMenu_Btn.Btn_setting or
		menu==MainMenu_Btn.Btn_skill or
		menu==MainMenu_Btn.Btn_talisman then
		
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"MainMenu",menu)	
	end	
end
-----------------------------------------------------------