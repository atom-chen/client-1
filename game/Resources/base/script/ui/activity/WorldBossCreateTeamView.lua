require("common.BaseUI")
require("config.words")
WorldBossCreateTeamView = WorldBossCreateTeamView or BaseClass(BaseUI)

local levelLimitDescrible = {
[1] = 40,
[2] = 45,
[3] = 50,
[4] = 55,
[5] = 60,
[6] = 70,
[7] = 80,
}

local viewSize = CCSizeMake(680,445)
function WorldBossCreateTeamView:__init()
	self.viewName = "WorldBossCreateTeamView"
	self:init(viewSize)
	local titleImage = createSpriteWithFrameName(RES("word_button_groupsetting.png"))
	self:setFormTitle(titleImage,TitleAlign.Center)		
	self.checkBtn = {}
	self:initStaticView()	
end	

function WorldBossCreateTeamView:initStaticView()
	self.bodyBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(viewSize.width-42,310))--CCSizeMake(831,479))	
	self:addChild(self.bodyBg)
	VisibleRect:relativePosition(self.bodyBg,self:getContentNode(),LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,0))	
	
	local teamLevelLimitLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[25511],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"))
	self:addChild(teamLevelLimitLable)
	VisibleRect:relativePosition(teamLevelLimitLable, self.bodyBg, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(10,-10))				
	self:initCheckBtn()	
	--分隔线
	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"),CCSizeMake(viewSize.width-100,2))
	self:addChild(line)
	VisibleRect:relativePosition(line, self.bodyBg, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(10, -135))
	local teamRuleLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[25514],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"))
	self:addChild(teamRuleLable)
	VisibleRect:relativePosition(teamRuleLable, line, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(0,-5))			
	
	local ruleLable1 = createLabelWithStringFontSizeColorAndDimension("        "..Config.Words[25512],"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"),CCSizeMake(viewSize.width-70,0))
	self:addChild(ruleLable1)
	VisibleRect:relativePosition(ruleLable1, teamRuleLable, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(0,-5))			
	
	local ruleLable2 = createLabelWithStringFontSizeColorAndDimension("        "..Config.Words[25513],"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"),CCSizeMake(viewSize.width-70,0))
	self:addChild(ruleLable2)
	VisibleRect:relativePosition(ruleLable2, ruleLable1, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(0,-5))			
	
	self.createTeamBt = createButtonWithFramename(RES("btn_1_select.png"))
	self.createTeamBt:setTitleString(createSpriteWithFrameName(RES("word_button_creategroup.png")))	
	self:addChild(self.createTeamBt)
	VisibleRect:relativePosition(self.createTeamBt,self.bodyBg,LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))	
	local onCreateTeamBtPress = function()
		local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()	
		if self.checkType then
			if teamMgr:getMyTeamId() then
				teamMgr:requestModifyTeam(self.checkType)
			else
				teamMgr:requestCreateTeam(self.checkType)
			end
		end
	end
	self.createTeamBt:addTargetWithActionForControlEvents(onCreateTeamBtPress, CCControlEventTouchDown)				
	--一个创建队伍按钮  	
end	

function WorldBossCreateTeamView:initCheckBtn()
	--7个可勾选按钮
	for i = 1,7 do
		local checkFunc = function()		
			for j=1,7 do
				self.checkBtn[j]:setSelect(false)
			end
			self.checkBtn[i]:setSelect(true)
			self.checkType = i
		end
		self.checkBtn[i] = createCheckButton(RES("common_selectBox.png"), RES("common_selectIcon.png"), nil, checkFunc)
		self.checkBtn[i]:setTouchAreaDelta(0, 40, 0, 0)
		local levelLimitCheckLab = createAtlasNumber(Config.AtlasImg.AuctionNum, levelLimitDescrible[i])
		self:addChild(self.checkBtn[i])
		self:addChild(levelLimitCheckLab)
		VisibleRect:relativePosition(self.checkBtn[i],self:getContentNode(),LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(30 + 90*( i-1),-90))
		VisibleRect:relativePosition(levelLimitCheckLab,self.checkBtn[i],LAYOUT_TOP_OUTSIDE+LAYOUT_CENTER,ccp(0,5))		
	end	
	self.checkBtn[1]:setSelect(true)
	self.checkType = 1
end

function WorldBossCreateTeamView:create()
	return WorldBossCreateTeamView.New()
end	

function WorldBossCreateTeamView:setCheckIndex(arg)
	for j=1,7 do
		self.checkBtn[j]:setSelect(false)
	end					
	self.checkBtn[arg]:setSelect(true)
	self.checkType = arg
end	


function WorldBossCreateTeamView:onEnter(arg)
	if arg  then	
		self.createTeamBt:setTitleString(createSpriteWithFrameName(RES("word_button_sure.png")))		
		for i = 1 , 7 do
			if levelLimitDescrible[i] == arg then
				self:setCheckIndex(i)
			end
		end
	end
end	


function WorldBossCreateTeamView:__delete()

end	
