require("data.userName.maleName")
require("data.userName.femaleName")
require("data.userName.familyName")
require("data.KeywordFilter")
eButtonModelRoleBoyZhanShiTag 	= 100
eButtonModelRoleBoyFaShiTag 	= 101
eButtonModelRoleBoyDaoShiTag 	= 102

eButtonModelRoleGirlTag = 200
eButtonCreateRoleRandomTag = 300
eButtonCreateRoleBoyTag  = 400

local sSysmbol ={ 
[1] = "\239\188\140",
[2] = "\227\128\130",
[3] = "\227\128\129",
[4] = "\226\128\152",
[5] = "\226\128\153",
[6] = "\239\188\155",
[7] = "\227\128\144",
[8] = "\227\128\145",
[9] = "\239\188\129",
[10] = "\239\191\165",
[11] = "\226\128\166",
[12] = "\239\188\136",
[13] = "\239\188\137",
[14] = "\239\189\155",
[15] = "\239\189\157",
[16] = "\239\188\154",
[17] = "\226\128\156",
[18] = "\226\128\157",
[19] = "\227\128\138",
[20] = "\227\128\139",
[21] = "\239\188\159",
[22] = "\194\183",
}

CreateNewRoleView = CreateNewRoleView or BaseClass(LoginBaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

local viewSize = CCSizeMake(455,564)

function CreateNewRoleView:__init()
	self.viewName = "CreateNewRoleView"
	self.scale = VisibleRect:SFGetScale()
	
	self.CilckProfessionGender = nil--选中职业性别项
	self.ProfessionGenderBtnBg = {}--职业性别项按钮底图保存
	self.ProfessionGenderBtn = {}--职业性别项按钮保存
	self.menuLayer = {}
	
	self:initData()--初始化数据
	self:initBackGround()--初始化背景
	self:initProfessionGender()--初始化职业性别选择
	self:initEditName()--初始化创建名称
	self:initPlayGame()--初始化进入游戏按钮
	self:initComeBack()--初始化返回按钮
	--self:showRoleModel()
end

function CreateNewRoleView:__delete()
	
end

function CreateNewRoleView:create()
	return CreateNewRoleView.New()
end

function CreateNewRoleView:initData()
	self.ProfessionGender_Table =
	{
	[1] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderMale ,tClickImage= "login_main_headManWarior.png", tPos = ccp(100,-30),tOffset = ccp(120,-152),Offset = ccp(-1,-5)},
	[2] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderFemale ,tClickImage= "login_main_headFemanWarior.png",Offset = ccp(6,2)},
	[3] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderMale ,tClickImage= "login_main_headManMagic.png",Offset = ccp(0,-6)},
	[4] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderFemale ,tClickImage= "login_main_headFemanMagic.png",Offset = ccp(1,-3)},
	[5] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderMale ,tClickImage= "login_main_headManDaoshi.png",Offset = ccp(0,5)},
	[6] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderFemale ,tClickImage= "login_main_headFemanDaoshi.png",Offset = ccp(0,5)}
	}
	
	self.ProfessionGenderModel_Table =
	{
	[1] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderMale , tImage = "role_modelManWarior.png",tProfessionImg = "role_fontWarior.png",tDescriptionImg = "role_wariorIntroduction.png"},
	[2] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderFemale , tImage = "role_modelFemanWarior.png",tProfessionImg = "role_fontWarior.png",tDescriptionImg = "role_wariorIntroduction.png"},
	[3] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderMale , tImage = "role_modelManMagic.png",tProfessionImg = "role_fontMagic.png",tDescriptionImg = "role_magicIntroduction.png"},
	[4] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderFemale , tImage = "role_modelFemanMagic.png",tProfessionImg = "role_fontMagic.png",tDescriptionImg = "role_magicIntroduction.png"},
	[5] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderMale , tImage = "role_modelManDaoshi.png",tProfessionImg = "role_fontDaoshi.png",tDescriptionImg = "role_daoshiIntroduction.png"},
	[6] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderFemale , tImage = "role_modelFemanDaoshi.png",tProfessionImg = "role_fontDaoshi.png",tDescriptionImg = "role_daoshiIntroduction.png"}
	}
end

function CreateNewRoleView:initBackGround()
	--背景图
	self.bg = CCSprite:create("loginUi/login/selectRoleBg.jpg")
	G_setBigScale(self.bg)
	self.rootNode:addChild(self.bg)
	VisibleRect:relativePosition(self.bg, self.rootNode, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE)
	
	--粒子系统
	local particleSystemQuad = CCParticleSystemQuad:create("particleSystem/UpPoint.plist")
	particleSystemQuad:setPositionType(kCCPositionTypeRelative)
	self.rootNode:addChild(particleSystemQuad)
	VisibleRect:relativePosition(particleSystemQuad,self.rootNode,LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE,ccp(46,-10))
	
	--山
	local mountain = createScale9SpriteWithFrameName(RES("role_mountain1.png"))
	self.rootNode:addChild(mountain)
	VisibleRect:relativePosition(mountain,self.rootNode,LAYOUT_CENTER + LAYOUT_BOTTOM_INSIDE,ccp(0,0))
	
	self:moveBackGroundAction()
end

function CreateNewRoleView:moveBackGroundAction()
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

function CreateNewRoleView:playFogAction()
	
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
		self.rootNode:addChild(fog,1)
		VisibleRect:relativePosition(fog,self.rootNode,LAYOUT_RIGHT_OUTSIDE+LAYOUT_BOTTOM_INSIDE,ccp(v.startPosX,0))
		table.insert(self.fogList,fog)
	end
	
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
			v:runAction(repeatForever)
		end
	end
end

function CreateNewRoleView:initProfessionGender()
	self:playFogAction()	
	
	--选择背景框
	local title = createSpriteWithFrameName(RES("role_font.png"))
	self.frame = LoginBaseUI.New()
	self.frame:createVipFrame(CCSizeMake(390,545),title)
	self.rootNode:addChild(self.frame:getRootNode())
	VisibleRect:relativePosition(self.frame:getRootNode(),self.rootNode,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(0,0))			
	
	--职业名称
	local zhanshiLabel =  createSpriteWithFrameName(RES("role_fontWarior.png"))
	zhanshiLabel:setScale(self.scale*0.8)
	self.frame:getRootNode():addChild(zhanshiLabel)
	VisibleRect:relativePosition(zhanshiLabel,self.frame:getRootNode(),LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE ,ccp(60,-98))
	
	local fashiLabel =  createSpriteWithFrameName(RES("role_fontMagic.png"))
	fashiLabel:setScale(self.scale*0.8)
	self.frame:getRootNode():addChild(fashiLabel)
	VisibleRect:relativePosition(fashiLabel,zhanshiLabel,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_CENTER ,ccp(0,-90))
	
	local daoshiLabel =  createSpriteWithFrameName(RES("role_fontDaoshi.png"))
	daoshiLabel:setScale(self.scale*0.8)
	self.frame:getRootNode():addChild(daoshiLabel)
	VisibleRect:relativePosition(daoshiLabel,fashiLabel,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_CENTER ,ccp(0,-90))
	
	--线
	local line1 =  createSpriteWithFrameName(RES("role_line.png"))
	self.frame:getRootNode():addChild(line1)
	VisibleRect:relativePosition(line1,self.frame:getRootNode(),LAYOUT_TOP_INSIDE + LAYOUT_CENTER ,ccp(0,-192))
	
	local line2 =  createSpriteWithFrameName(RES("role_line.png"))
	self.frame:getRootNode():addChild(line2)
	VisibleRect:relativePosition(line2,line1,LAYOUT_TOP_INSIDE + LAYOUT_CENTER ,ccp(0,-157))
	
	--创建按钮
	local professionGenderSize = table.size(self.ProfessionGender_Table)
	for i=1, professionGenderSize do	
		self:cretaeProfessionGenderBtn(i)
	end
	
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
	blackBg:setContentSize(CCSizeMake(visibleSize.width,97))
	self.rootNode:addChild(blackBg)
	VisibleRect:relativePosition(blackBg,self.rootNode,LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE)
	
	self:ClickBtn(1)
end

function CreateNewRoleView:cretaeProfessionGenderBtn(index)
	function getBtnPos(index)
		local posX = 0
		local posY = 0
		if self.ProfessionGender_Table[index].tGender == ModeType.eGenderMale then
			posX = self.ProfessionGender_Table[1].tPos.x
			posY = self.ProfessionGender_Table[1].tPos.y + self.ProfessionGender_Table[1].tOffset.y * (math.floor((index/2)))-18
		elseif self.ProfessionGender_Table[index].tGender == ModeType.eGenderFemale then
			posX = self.ProfessionGender_Table[1].tPos.x + self.ProfessionGender_Table[1].tOffset.x
			posY = self.ProfessionGender_Table[1].tPos.y + self.ProfessionGender_Table[1].tOffset.y * (math.floor((index/2)-1))-18
		end
		
		return ccp(posX,posY)
	end
	
	self.ProfessionGenderBtnBg[index] = createSpriteWithFrameName(RES("login_ins_clickFrame.png"))
	self.frame:getRootNode():addChild(self.ProfessionGenderBtnBg[index])
	VisibleRect:relativePosition(self.ProfessionGenderBtnBg[index],self.frame:getRootNode(),LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,getBtnPos(index))
	
	self.ProfessionGenderBtn[index] = createSpriteWithFrameName(RES(self.ProfessionGender_Table[index].tClickImage))
	self.ProfessionGenderBtnBg[index]:addChild(self.ProfessionGenderBtn[index])		
	VisibleRect:relativePosition(self.ProfessionGenderBtn[index],self.ProfessionGenderBtnBg[index], LAYOUT_CENTER,ccp(self.ProfessionGender_Table[index].Offset.x,-4+self.ProfessionGender_Table[index].Offset.y))
	
	
	self.menuLayer[index] = CCLayer:create()	
	self.menuLayer[index]:setContentSize(self.ProfessionGenderBtnBg[index]:getContentSize())	
	self.ProfessionGenderBtnBg[index]:addChild(self.menuLayer[index])		
	self.menuLayer[index]:setTouchEnabled(true)
	VisibleRect:relativePosition(self.menuLayer[index] , self.ProfessionGenderBtnBg[index], LAYOUT_CENTER)
	local btnProfessionGenderfunc = function ()
		self:ClickBtn(index)
	end
	self:registerAttackTouchHandler(self.menuLayer[index] , index, btnProfessionGenderfunc)	
end

function CreateNewRoleView:ClickBtn(index)
	local genderIndex = 0
	if self.CilckProfessionGender then
		genderIndex = self.ProfessionGender_Table[self.CilckProfessionGender].tGender
	end
	self.CilckProfessionGender = index
	local newGenderIndex = self.ProfessionGender_Table[self.CilckProfessionGender].tGender
	if genderIndex ~= newGenderIndex then
		--随机名字
		if self.pRoleNameEdit and self.randomName == self.pRoleNameEdit:getText() then
			local randomName = self:getRandomString()
			self.pRoleNameEdit:setText(randomName)
			self.randomName = randomName
		end
	end
	local function removeAllBtnClick  ()
		local professionGenderSize = table.size(self.ProfessionGender_Table)
		for i=1, professionGenderSize do
			UIControl:SpriteSetGray(self.ProfessionGenderBtn[i])
			UIControl:SpriteSetGray(self.ProfessionGenderBtnBg[i])			
		end
	end
	removeAllBtnClick()
	UIControl:SpriteSetColor(self.ProfessionGenderBtn[index])	
	UIControl:SpriteSetColor(self.ProfessionGenderBtnBg[index])	
	
	self:showRoleModel()
end

function CreateNewRoleView:getMoedelSpriteName(index)
	local nameImg = self.ProfessionGenderModel_Table[index].tImage
	local frontImg = self.ProfessionGenderModel_Table[index].tProfessionImg
	local descriptionImg = self.ProfessionGenderModel_Table[index].tDescriptionImg
	return nameImg,frontImg,descriptionImg
end

function CreateNewRoleView:showRoleModel()
	local nameImg,frontImg,descriptionImg = self:getMoedelSpriteName(self.CilckProfessionGender)
	if self.roleModel then
		--人物模型		
		local tempmodel =  createSpriteWithFrameName(RES(nameImg))
		local frame1 = tempmodel:displayFrame()
		self.roleModel:setDisplayFrame(frame1)
		
		--职业名称
		local frameCache2 = CCSpriteFrameCache:sharedSpriteFrameCache()
		local frame2 = frameCache2:spriteFrameByName(RES(frontImg))
		self.professionName:setDisplayFrame(frame2)
		
		--描述
		local frameCache3 = CCSpriteFrameCache:sharedSpriteFrameCache()
		local frame3 = frameCache3:spriteFrameByName(RES(descriptionImg))
		self.description:setDisplayFrame(frame3)
		VisibleRect:relativePosition(self.description,self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-50, -40))
	else
		--人物模型
		self.roleModel = createSpriteWithFrameName(RES(nameImg))
		self.roleModel:setScale(self.scale)
		self.rootNode:addChild(self.roleModel)
		VisibleRect:relativePosition(self.roleModel,self.rootNode, LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE,ccp(0, 30))
		
		--职业名称
		local professionNameBg = createSpriteWithFrameName(RES("role_fontBg.png"))
		professionNameBg:setScale(self.scale)
		self.rootNode:addChild(professionNameBg)
		VisibleRect:relativePosition(professionNameBg,self.roleModel, LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(150, 0))
		
		self.professionName = createSpriteWithFrameName(RES(frontImg))
		self.professionName:setScale(self.scale)
		professionNameBg:addChild(self.professionName)
		VisibleRect:relativePosition(self.professionName,professionNameBg, LAYOUT_CENTER,ccp(0, 0))
		
		--描述
		self.description = createSpriteWithFrameName(RES(descriptionImg))
		self.description:setScale(self.scale)
		self.rootNode:addChild(self.description)
		VisibleRect:relativePosition(self.description,self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-50, -40))
	end
end

function CreateNewRoleView:setHeroName()
	local roleName = ""
	repeat 	
		roleName = self:getRandomString()			
	until (not self:isKeyWord(roleName))
	
	self.pRoleNameEdit:setText(roleName)
	self.randomName = roleName
end


function CreateNewRoleView:initEditName()
	--输入框
	self.pRoleNameEdit = createEditBoxWithSizeAndBackground(CCSizeMake(200.0,45.0),RES("login_squares_roleNameBg.png"))
	self.pRoleNameEdit:setScale(self.scale)
	self.rootNode:addChild(self.pRoleNameEdit)
	
	self:setHeroName()
	VisibleRect:relativePosition(self.pRoleNameEdit, self.rootNode,LAYOUT_CENTER + LAYOUT_BOTTOM_INSIDE,ccp(0,20))
	
	--随即名字按钮
	local m_btnChangeName = createButtonWithFramename(RES("role_dice.png"))	
	self.rootNode:addChild(m_btnChangeName)
	m_btnChangeName:setTag(eButtonCreateRoleRandomTag)
	local changeNameFunction = function ()		
		self:setHeroName()
	end
	m_btnChangeName:addTargetWithActionForControlEvents(changeNameFunction,CCControlEventTouchDown)
	VisibleRect:relativePosition(m_btnChangeName, self.pRoleNameEdit, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(10.0, 0.0))
end

function CreateNewRoleView:getRandomString()	
	--GmaeData的数据进入游戏的时候会被清掉，每次读取都要require,不能移到文件开头
	require("data.userName.maleName")
	require("data.userName.femaleName")
	require("data.userName.familyName")
	local familyName = ""
	local name = ""
	local familyNameList = GameData.familyName
	if familyNameList then
		local familyNameListSize = table.size(familyNameList)
		familyName = familyNameList[math.random(1,familyNameListSize)]
	end
	local genderIndex = self.ProfessionGender_Table[self.CilckProfessionGender].tGender
	if genderIndex == ModeType.eGenderMale then
		local maleNameList = GameData.maleName
		local maleNameListSize = table.size(maleNameList)
		name = maleNameList[math.random(1,maleNameListSize)]
	elseif genderIndex == ModeType.eGenderFemale then
		local femaleNameList = GameData.femaleName
		local femaleNameListSize = table.size(femaleNameList)
		name = femaleNameList[math.random(1,femaleNameListSize)]
	end
	temp = familyName..name
	return temp
end

function CreateNewRoleView:isKeyWord(name)
	for k,v in pairs(GameData.Keyword) do
		if string.find(name, v) then
			return true
		end
	end
	return false
end

function CreateNewRoleView:initPlayGame()
	--创建按钮
	self.enterGameBtn = createButtonWithFramename(RES("role_RoleBtn.png"))
	self.enterGameBtn:setScale(self.scale)	
	self.rootNode:addChild(self.enterGameBtn)
	VisibleRect:relativePosition(self.enterGameBtn, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE,CCPointMake(-20,20))
	
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
	VisibleRect:relativePosition(sprite, self.enterGameBtn, LAYOUT_CENTER, ccp(5,10))
	--]]
	
	--字
	local font = createScale9SpriteWithFrameName(RES("role_startBtn.png"))
	self.enterGameBtn:addChild(font)
	VisibleRect:relativePosition(font,self.enterGameBtn,LAYOUT_CENTER,ccp(0,-5))
	
	--按键监控
	local startGameFunction = function ()
		if self.CilckProfessionGender then
			local sText = self.pRoleNameEdit:getText()			
			if sText then
				LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.CreateRoleFinish)
				-- 过滤关键字
				if self:isKeyWord(sText) then
					local btns ={
						{text = Config.LoginWords[10043], id = 0},
					}							
					local msg = showMsgBox(Config.LoginWords[349])
					msg:setBtns(btns)	
					return
				end
				--[[for k,v in pairs(GameData.Keyword) do
					if string.find(sText, v) then
						local btns ={
							{text = Config.LoginWords[10043], id = 0},
						}							
						local msg = showMsgBox(Config.LoginWords[349])
						msg:setBtns(btns)	
						return
					end
				end--]]
				--过滤Ascii
				if string.find(sText , "[\1-\47\58-\64\91-\96\123-\127]") then
					local btns ={
						{text = Config.LoginWords[10043], id = 0},
					}						
					local msg = showMsgBox(Config.LoginWords[349])
					msg:setBtns(btns)
					
					return
				end
				
				--过滤特殊符号								
				for k ,v in pairs(sSysmbol) do
					if string.find(sText,v) then
						local btns ={
							{text = Config.LoginWords[10043], id = 0},
						}							
						local msg = showMsgBox(Config.LoginWords[349])
						msg:setBtns(btns)
						return
					end				
				end					
				
				if string.len(sText)>=4 and string.len(sText) <= 12 then
					local professionIndex = self.ProfessionGender_Table[self.CilckProfessionGender].tProfession
					local genderIndex = self.ProfessionGender_Table[self.CilckProfessionGender].tGender
					LoginWorld.Instance:getLoginManager():requestCharactoCreate(professionIndex,genderIndex, sText)				
					UIManager.Instance:showLoadingSence(10)				
					self:setNewGuidelinesBegin()	
					--通知sdk创建了新角色					
					SFGameAnalyzer:logGameEvent(GameAnalyzeID.CreateRole, "roleName="..sText)       					
				else
					if string.len(sText)>0 and string.len(sText)< 4 then
						UIManager.Instance:showSystemTips(Config.LoginWords[310])
					elseif string.len(sText)> 12 then
						UIManager.Instance:showSystemTips(Config.LoginWords[311])
					elseif string.len(sText) == 0 then
						UIManager.Instance:showSystemTips(Config.LoginWords[347])
					end
				end					
			else
				UIManager.Instance:showSystemTips(Config.LoginWords[329])
			end
		else
			UIManager.Instance:showSystemTips(Config.LoginWords[314])
		end
	end
	self.enterGameBtn:addTargetWithActionForControlEvents(startGameFunction,CCControlEventTouchDown)
end	

function CreateNewRoleView:initComeBack()
	--返回按钮
	local m_btnBack = createButtonWithFramename(RES("login_btn_back.png"))
	m_btnBack:setScale(self.scale)	
	self.rootNode:addChild(m_btnBack)
	VisibleRect:relativePosition(m_btnBack, self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE, CCPointMake(-25, -15))
	local backFunction = function ()
		GlobalEventSystem:Fire(GameEvent.EVENT_SELECT_ROLE_UI)
	end
	m_btnBack:addTargetWithActionForControlEvents(backFunction,CCControlEventTouchDown)
end

function CreateNewRoleView:registerAttackTouchHandler(node, argIndex, callBackFunc)
	local function ccTouchHandler(eventType, x, y)		
		return self:touchHandlerabc(node, eventType, x, y, argIndex, callBackFunc)
	end
	node:registerScriptTouchHandler(ccTouchHandler, false, UIPriority.Control, true)
end

function CreateNewRoleView:touchHandlerabc(node, eventType, x, y, argIndex, callBackFunc)
	if node:isVisible() and node:getParent() then
		local parent = node:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = node:boundingBox()
		if rect:containsPoint(point) then		
				if eventType == "began" then			
					self:ccTouchBegan(argIndex)
				elseif eventType == "ended" then					
					callBackFunc(argIndex)					
					self:ccTouchEnded(argIndex)	
				end								
				return 1														
		else
			if eventType == "ended" then
				self:ccTouchEnded(argIndex)	
			end						
		end				
	else		
		return 0
	end
end

function CreateNewRoleView:ccTouchBegan(argIndex)
	local scaleTo = CCScaleTo:create(0.05,0.95)
	self.ProfessionGenderBtn[argIndex]:runAction(scaleTo)
end	

function CreateNewRoleView:ccTouchEnded(argIndex)
	local scaleTo = CCScaleTo:create(0.05,1)
	self.ProfessionGenderBtn[argIndex]:runAction(scaleTo)
end

function CreateNewRoleView:setNewGuidelinesBegin()
	local newGuidelinesMgr = LoginWorld.Instance:getLoginManager()
	newGuidelinesMgr:setIsCreateNewRole(true)
end

function CreateNewRoleView:onEnter()
	--self.pRoleNameEdit:setText("")
end