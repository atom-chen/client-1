-- 存放一些可全局使用的方法
require ("config.LoginWords")
require ("config.color")
require ("config.image")

RES = nil	--使用图片，传入图片名称，返回图片的SpriteFrame
FSIZE = nil  	--使用字体大小，传入字体大小配置(在color里的配置)，返回字体大小。
FCOLOR = nil 	--使用字体颜色，传入字体大小配置(在color里的配置)，返回字体颜色对象ccc3
ART_TEXT = nil 	--使用美术字的fnt文件名，返回fnt文件的路径
ICON = nil 		--使用图标，传入RefId，返回图标路径

ModeType =
{
eGenderMale = 1,
eGenderFemale = 2,

eModelMale_0 = 1000,
eModelMale_1= 1006,
eModelMale_2 = 1008,
eModelMale_3 = 1010,

eModelFemale_0 = 1001,
eModelFemale_1 = 1007,
eModelFemale_2 = 1009,
eModelFemale_3 = 1011,

ePlayerProfessionWarior = 1,
ePlayerProfessionMagic = 2,
ePlayerProfessionWarlock = 3,
}

ServerListCode = {
	Waiting = -1,	-- 等待数据
	Success = 0,
	NetworkError = 1,
	FormatError = 2
}

function TransToProfessionAndGender(profession,gender)
	if not profession or not gender then
		return nil
	end
	
	if profession==ModeType.ePlayerProfessionWarior and gender == ModeType.eGenderMale then
		return ModeType.ePlayerWariorMale
	elseif profession==ModeType.ePlayerProfessionWarior and gender == ModeType.eGenderFemale then
		return ModeType.ePlayerWariorFemale
	elseif profession==ModeType.ePlayerProfessionMagic and gender == ModeType.eGenderMale then
		return ModeType.ePlayerMagicMale
	elseif profession==ModeType.ePlayerProfessionMagic and gender == ModeType.eGenderFemale then
		return ModeType.ePlayerMagicFemale
	elseif profession==ModeType.ePlayerProfessionWarlock and gender == ModeType.eGenderMale then
		return ModeType.ePlayerWarlockMale
	elseif profession==ModeType.ePlayerProfessionWarlock and gender == ModeType.eGenderFemale then
		return ModeType.ePlayerWarlockFemale
	end
	
	return ModeType.ePlayerNULL
end


MapKind = {
	city = 0,
	dangerousArea = 1,
	ativityArea = 2,
	instanceArea = 3,
	newVillage = 4,--新手村
}

--UI显示的选项
E_ShowOption =
{
eRejectOther = 1, 	--显示在中间，隐藏其他窗口
eMove2Left	 = 3,  	--从中间移动到左侧，不影响其他窗口
eMove2Right	 = 4,  	--从中间移动到右侧，不影响其他窗口
eMiddle	 = 5,		--显示在中间，不影响其他窗口
eLeft	 = 6,  		--显示在左边，不影响其他窗口
eRight	 = 7,  		--显示在右边，不影响其他窗口
}
	

E_ViewPos =
{
eLeft 	= 1,
eMiddle = 2,
eRight 	= 3,
}


E_ProfessionType =
{
eZhanShi = 1,
eFaShi = 2,
eDaoShi = 3,
eCommon = 10
}




E_OffsetView = 
{
eWidth = 6,
eHeight = 6
}

E_DirectionMode = 
{
	Horizontal	= 1,
	Vertical	= 2
}


E_TipsType = {
	system = 1,
	gain = 2,
	other = 3,
}
Setting_checkStatus = {
	TRUE = 1,
	FALSE = 2,
}

Vip_Level = {
	NOTVIP = 0,
	VIP_TONG = 1,
	VIP_YING = 2,
	VIP_JIN = 3,
}	



function createArrow(direction,callbackfunc)
	local newArrow = NewGuidelinesView.New()
	if direction then
		newArrow:setDirection(direction)
	end
	if callbackfunc then
		newArrow:setCallBlackFunc(callbackfunc)
	end
		
	return newArrow 
end

--[[
btns	 :	按键list。不指定则显示默认两个按键：确定和取消，对应的id为2和1。
按键list格式例如下：
btns =
{
{text = "马上升级",		id = 0},
{text = "1小时后提醒",	id = 1},
{text = "跳过此版本",	id = 2}
}
closeBtFlag: 是否显示关闭按钮
btnType  :按钮样式
	ID_OKAndCANCEL = 0,  确定和取消
	ID_OK = 2,	确定
	ID_CANCEL = 1,	取消
	ID_CANCELAndOK = 3, 取消和确定
	ID_KNOW = 4,	我知道了
--]]

function showMsgBox(msg,btnType)
	if not msg then
		return
	end
	
	local msgBox = nil
	if not msgBox then
		msgBox = MessageBox.New()
		msgBox:setSwallowAllTouch(true)
	else
		UIManager.Instance:hideDialog(msgBox:getRootNode())
	end
	if not btnType then
		btnType = E_MSG_BT_ID.ID_OK
	end
	msgBox:setMsg(msg)
	msgBox:setBtnTpye(btnType)
	msgBox:layout()
	UIManager.Instance:showDialog(msgBox:getRootNode(),1)
		
	return msgBox
end	

--[[
container: 大的node，装载nodes里面的所有ndoe
nodes: 一个table,放显示的node
spacing: 各个node之间的间隔
direction: 水平/垂直
viewSize: 可视区域大小
adjust: 是否要自动调整。当计算出的高度小于viewSize高度时，如果为true则自动调整。宽度也同理
--]]
function G_layoutContainerNode(container, nodes, spacing, direction, viewSize, adjust)
	local count = table.size(nodes)
	
	if (container == nil or nodes == nil or count < 1) then
		return nil
	end
	if (spacing == nil) then
		spacing = 0
	end
	if (direction == nil) then
		direction = E_DirectionMode.Vertical
	end

	local size
	local node1 = nodes[1]
	if (viewSize) then
		size = CCSizeMake(viewSize.width, viewSize.height)
	else
		size = CCSizeMake(node1:getContentSize().width, node1:getContentSize().height)
	end
	
	if (direction == E_DirectionMode.Vertical) then
		size.height = 0
		for k, v in ipairs(nodes) do
			size.height = size.height + v:getContentSize().height	
		end				
		size.height = (count - 1) * spacing + size.height
	else
		size.width = 0
		for k, v in ipairs(nodes) do
			size.width = size.width + v:getContentSize().width	
		end	
		size.width = (count - 1) * spacing + size.width
	end
	
	if (viewSize and adjust == true) then
		if (direction == E_DirectionMode.Vertical) then
			if (size.height < viewSize.height) then
				size.height = viewSize.height
			end
		else
			if (size.width < viewSize.width) then
				size.width = viewSize.width
			end
		end	
	end		
		
	container:setContentSize(size)
	local previousNode = container
	for k, v in ipairs(nodes) do
		container:addChild(v)
		if (direction == E_DirectionMode.Vertical) then
			if (k == 1) then
				VisibleRect:relativePosition(v, container, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE)
			else
				VisibleRect:relativePosition(v, previousNode, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -spacing))
			end
		else
			if (k == 1) then
				VisibleRect:relativePosition(v, container, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE)
			else
				VisibleRect:relativePosition(v, previousNode, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(spacing, 0))
			end
		end
		previousNode = v
	end
	return container
end

function G_getBagMgr()
	local obj = GameWorld.Instance:getEntityManager():getHero()	
	if (obj == nil) then
		return nil
	end
	return obj:getBagMgr()
end

function G_getEquipMgr()
	local obj = GameWorld.Instance:getEntityManager():getHero()
	if (obj == nil) then
		return nil
	end	
	return obj:getEquipMgr()
end

function G_getForgingMgr()
	local obj = GameWorld.Instance:getEntityManager():getHero()
	if (obj == nil) then
		return nil
	end	
	return obj:getForgingMgr()
end

function G_getHero()
	local obj = GameWorld.Instance:getEntityManager():getHero()	
	return obj
end

function G_setScale(node)
	if (node) then
		node:setScale(VisibleRect:SFGetScale())
	end
end

function G_getKightNameById(id)
	local name = string.format("knight_%d", id)
	local data = GameData.Knight[name]
	if (data == nil) then
		return "-"
	end
	return PropertyDictionary:get_name(data.property)
end

-- 根据性别ID返回性别名称
function G_getSexNameById(id)
	if (id == 1) then
		return "男"
	elseif (id == 2) then
		return "女"
	else
		return ""
		--		error("getSexNameById(id) error: 看起来问题很严重哦~~还不知道给你返回什么性别呢")
	end
end	
	
--测试用，保存英雄数据
local configFile = "script/test/TestData.lua"
function G_writeHeroData(heroId, pd, pdName)
	if (os.getenv("OS") == "Windows_NT") then
		local file = io.open(configFile, "w")
		file:write("--Auto generate at "..os.date().."\n")
		file:write("--save hero info for offLine test\n")	
		file:write("const_testHeroId = ".."\""..heroId.."\"\n")			
		file:close()		
		PDOperator.generatePDCode(configFile, pd, pdName, "a")		
	end
end	

--设置背景适宽最大缩放
function G_setBigScale(bg)	
	local w_scale, h_scale = 1, 1	
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleHeight = visibleSize.height
	local visibleWidth = visibleSize.width
	local bgHeight= bg:getContentSize().height
	local bgWidth = bg:getContentSize().width			
	if visibleHeight>bgHeight then
		h_scale = visibleHeight/bgHeight								
	end	
	if visibleWidth>bgWidth then 
		w_scale = visibleWidth/bgWidth
	end
	if h_scale > w_scale then 
		bg:setScale(h_scale)
	else
		bg:setScale(w_scale)
	end
			
end				

--查找非法符号（待完成）
--@字符串若包含有非法符号则返回为nil，否则返回原字符串
function G_specialWord(str)
	local illegalChar = "~!@#$%^&*()_+,./;'\\[]{}:|? ><\""		
	local illegalCharSize = string.len(illegalChar)
	local strSize = string.len(str)
	for i=1,strSize do
		local word = string.sub(str,i,i)
		for j=1,illegalCharSize do
			local  illegalCharWord = string.sub(illegalChar,j,j)
			if word==illegalCharWord then
				return nil
			end
		end
	end
	return str
end

function G_getCharacterLevelData(heroPt)
	if heroPt and table.size(heroPt) ~= 0 then	
		local professionId = PropertyDictionary:get_professionId(heroPt)		
		local professionName = ""
		local characterLevelData = GameData.CharacterLevelData
		for i,v in pairs(characterLevelData) do
			local numId = v.numId
			if professionId == numId then
				professionRefId = v.refId
				break
			end			
		end
		local professionLevelData = characterLevelData[professionRefId].levelData
		return professionLevelData
	end		
end

function G_getMaxExp(heroPt)
	if heroPt and table.size(heroPt) ~= 0 then	
		local professionLevelData = G_getCharacterLevelData(heroPt)
		local level = PropertyDictionary:get_level(heroPt)
		local maxExp = professionLevelData[level].property.maxExp
		return maxExp
	end
--	return PropertyDictionary:get_maxExp(heroPt)
end

function G_getMaxHp(heroPt)
--[[	if heroPt and table.size(heroPt) ~= 0 then	
		local professionLevelData =  G_getCharacterLevelData(heroPt)
		local level = PropertyDictionary:get_level(heroPt)
		local maxHP = professionLevelData[level].property.maxHP
		return maxHP
	end	--]]
	return PropertyDictionary:get_maxHP(heroPt)
end

function G_getMaxMP(heroPt)
--[[	if heroPt and table.size(heroPt) ~= 0 then	
		local professionLevelData =  G_getCharacterLevelData(heroPt)
		local level = PropertyDictionary:get_level(heroPt)
		local maxMP = professionLevelData[level].property.maxMP
		return maxMP
	end	--]]
	return PropertyDictionary:get_maxMP(heroPt)
end

--查找敏感字符
--@敏感字符会被替换为**
--@敏感字符库在data/KeywordFilter.lua中
function G_keyWorldFilter(str)
	local function getMatchKeyWord(str1,str2)
		local isFind = string.find(str2,str1)
		return isFind
	end
	
	local function replaceString(key,str)
		local replaceStr = "**"
		local isFind = getMatchKeyWord(key,str)
		if isFind then
			str = string.gsub(str,key,replaceStr)
		end
		return str
	end
	
	local function getMatchKeyTerm(str1,str2)
		local sign = "|"
		local signLen = string.len(sign)
		local tempStr = str1
		local startIndex = 1
		local EndIndex = 1
		while startIndex do
			startIndex,EndIndex = string.find(tempStr,sign)
			if startIndex~=nil and EndIndex~=nil then
				local key = string.sub(tempStr,1,EndIndex-signLen)
				str2 = replaceString(key,str2)
				
				local strlen = string.len(tempStr)
				local newStr =  string.sub(tempStr,EndIndex+signLen,strlen)
				tempStr = newStr
				local dfdf = 0
			else
				str2 = replaceString(tempStr,str2)
			end
		end
		return 	str2
	end
	
	local bIsChange = false
	for i,v in pairs(GameData.Keyword) do
		--比较KeyWord
		local keyWord = v.keyWord
		if getMatchKeyWord(keyWord,str)~=nil then
			--keyTerm
			local keyTerm = v.keyTerm
			str,bIsChange = getMatchKeyTerm(keyTerm,str)
		end
	end
	return str,bIsChange
end

function G_CCSizeMake(size)
	if size then
		local CSzie = CCSizeMake(size.width,size.height)
		return CSzie
	else
		CCLuaLog("Error: G_CCSizeMake size is nil")
	end	
end	