require("actionEvent.ActionEventDef")
require("config.words")
require"data.knight.knight"	
KnightMgr = KnightMgr or BaseClass()

function KnightMgr:__init()
	self.checkFlag = true
end

function KnightMgr:clear()
	self.checkFlag = true
	self.flag = nil
end

function KnightMgr:requestSalaryFlag()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_CanGetReward)
	simulator:sendTcpActionEventInLua(writer)
end

function KnightMgr:requestGetSalary()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_GetSalaryEvent)
	simulator:sendTcpActionEventInLua(writer)	
end

function KnightMgr:requestUpGrade()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_UpGradeEvent)
	simulator:sendTcpActionEventInLua(writer)	
end

function KnightMgr:getHeadIcon(knight)
	if knight and knight ~= 0 then
		local iconName = "common_knight"..knight..".png"
		local headIcon = createSpriteWithFrameName(RES(iconName))
		G_setScale(headIcon)
		return headIcon
	end
end	

function KnightMgr:setSalaryFlag(flag)
	if flag then 
		self.flag = flag
	end
end
function KnightMgr:getSalaryFlag()
	if self.flag then
		return self.flag
	end
end

function KnightMgr:showGetKnightBox()
	local hero = G_getHero()
	local curLevel = PropertyDictionary:get_knight(hero:getPT())
	local refId = "knight_"..curLevel
	local iicon 
	local iiconName
	
	local staticData = GameData.Knight[refId]
	if (staticData ~= nil) then
		iicon = staticData.property.iconId
		iiconName = staticData.property.name
	end
	local description = Config.Words[6017]
	local getKnightView = UIManager.Instance:showPromptBox("GetKnightView",1,false)
	getKnightView:setTitleWords("word_button_promoteknight.png")--替换图片
	getKnightView:setIcon(iicon)
	getKnightView:setIconWord(iiconName)
	getKnightView:setDescrition(description)
	local function clickButton()
		if getKnightView then
			getKnightView:hideArrow()
			getKnightView:close()
			--开启爵位解锁指引
			GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesOpenKnight()
		end
	end
	getKnightView:setBtn("word_button_sure.png",clickButton)
	getKnightView:showArrow()
end

function KnightMgr:checkKnightGet(newPD)
	if type(newPD) ~= "table" then
		CCLuaLog("ArgError:KnightMgr:checkKnightGet")
		return
	end
	if self.checkFlag == true then
		local curLevel = PropertyDictionary:get_knight(newPD)
		if curLevel > 1 then
			self.checkFlag = false
			return
		end
		if curLevel ~= 0 then
			self:showGetKnightBox()
			self.checkFlag = false
		end
	end
end

function KnightMgr:getKnightPT()
	local hero = G_getHero()
	local curLevel = PropertyDictionary:get_knight(hero:getPT())
	local refId = "knight_"..curLevel
	local staticData = GameData.Knight[refId]
	if staticData and staticData.property then
		return  staticData.property
	end
end
