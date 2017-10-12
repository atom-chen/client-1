require "common.BaseUI"
require "ui.skill.SkillDetailView"
require "ui.skill.SkillGridView"

SkillView = SkillView or BaseClass(BaseUI)

---状态
local SUCCESS = 1
local FAILURE = 0

local scale = VisibleRect:SFGetScale()
local rootNodeBgSize = CCSizeMake(852, 479)
local SubView = 
{
jichu = 1,  --基础
}

function SkillView:__init()
	self.viewName = "SkillView"	
	self:initFullScreen()	
	
	self.subViews = {
	[SubView.jichu] = {name = Config.Words[2018].."\n"..Config.Words[2024], createFun = SkillGridView.New},			
	}
	self:createRootNodeBg()
	self:createTabView()
	self:showSubView(SubView.jichu)	
	self:createDetailsNode()  --技能详细信息
	self:createStaticView() --静态界面，不会改变的	
end

function SkillView:__delete()
	
end	

function SkillView:onEnter()
	
end

function SkillView:onExit()
	
end

function SkillView:createRootNodeBg()
	self.rootNodeBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(834, 479))
	self:addChild(self.rootNodeBg)
	VisibleRect:relativePosition(self.rootNodeBg, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE)
end

function SkillView:createTabView()
	local btnArray = CCArray:create()
	for key, v in pairs(self.subViews) do  
		v.btn = createButtonWithFramename(RES("tab_2_normal.png"), RES("tab_2_select.png"))
		v.label = createLabelWithStringFontSizeColorAndDimension(v.name, "Arial",FSIZE("Size4") * scale, FCOLOR("ColorWhite1"))		
		btnArray:addObject(v.btn)
		local onTabClick = function()			
			self:showSubView(key)			
		end	
		v.btn:addTargetWithActionForControlEvents(onTabClick, CCControlEventTouchDown)						
	end
	
	self.tabView = createTabView(btnArray,10,tab_vertical)
	self:addChild(self.tabView)
	VisibleRect:relativePosition(self.tabView, self.rootNodeBg, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_OUTSIDE,ccp(0, -25))	
	
	for _, value in pairs(self.subViews) do		
		self.tabView:addChild(value.label)	
		VisibleRect:relativePosition(value.label, value.btn, LAYOUT_CENTER, ccp(2, 20))
	end
	self.tabView:setSelIndex(SubView.jichu)
	self.tabView:setVisible(false)   --瑞兴说只有一个view，不显示tabview
end


function SkillView:showSubView(viewType)
	if viewType == self.curView then 
		return
	end		
	
	if self.curView ~= nil then 
		local oldView = self.subViews[self.curView]
		if oldView.obj then 
			local objNode = oldView.obj:getRootNode()			
			objNode:setVisible(false)			
			objNode:removeFromParentAndCleanup(false)
		end
	end
	
	self.curView = viewType	
	local curView = self.subViews[self.curView]
	if curView.obj == nil then 
		curView.obj = curView.createFun()
		local curRootNode = curView.obj:getRootNode()
		curRootNode:setVisible(false)
	end
	local newNode = curView.obj:getRootNode()
	self:addChild(newNode)	
	newNode:setVisible(true)
	VisibleRect:relativePosition(newNode, self.rootNodeBg, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(12, 0))				
end


function SkillView:create()
	return SkillView.New()
end

function SkillView:createStaticView()
	--标题	
	local icon =createSpriteWithFrameName(RES("main_skill.png"))		
	self:setFormImage(icon)
	
	--标题文字	
	local skillTitle = createSpriteWithFrameName(RES("word_window_skill.png"))
	self:setFormTitle(skillTitle, TitleAlign.Left)
end


function SkillView:updateSkills()
	local skillGridView = self.subViews[SubView.jichu].obj
	if skillGridView then 
		skillGridView:updateSkills()
	end
end


--显示详细信息
function SkillView:showSkillDetails(skillObject)
	if skillObject ==nil then 
		return
	end
	self.detailView:setCurSkill(skillObject)
	self:showNameAndLevel(skillObject)
	self:showDescription(skillObject)	
	self:showUpdateInfo(skillObject)	
	--self:setBtnEnabled(skillObject)
	self:showVisibleView()
end

function SkillView:showVisibleView()
	self.detailView:showVisibleView()
end

--英雄未达到技能学习等级， 不能使用技能秘药
--没学会的技能不能设置成快捷技能
function SkillView:setBtnEnabled(skillObject)
	if skillObject ==nil then 
		return
	end
	local bEnabled = false	
	local curLevel = PropertyDictionary:get_level(skillObject:getPT())
	local maxLevel = table.size(skillObject:getSkillLevelTable())
	local refId = PropertyDictionary:get_skillRefId(skillObject:getPT())
	local heroLv = PropertyDictionary:get_level(G_getHero():getPT())	
	local curExp = PropertyDictionary:get_skillExp(skillObject:getPT())
	local needExp = PropertyDictionary:get_skillUpperExp(skillObject:getSkillLevelPropertyTable(curLevel))	
		
	if curLevel ~= maxLevel and refId ~= const_skill_pugong then 
		local quickDrug = G_getBagMgr():getItemNumByRefId("item_jinengExp")	
		local skillLearnLv = PropertyDictionary:get_skillLearnLevel(skillObject:getSkillLevelPropertyTable(curLevel))	
		if curExp < needExp and skillObject:isLearn() and quickDrug > 0 then 
			bEnabled = true
		end			
	end		
	self.detailView:setUpgradeEnabled(bEnabled)
		
	bEnabled = false
	if refId ~= const_skill_pugong then
		local firstSkillLearnLv = PropertyDictionary:get_skillLearnLevel(skillObject:getStaticData())		
		local skillType = PropertyDictionary:get_skillType(skillObject:getStaticData())
		if  skillType ~= 0 and skillType ~= 1 then
			if skillObject:isLearn() then 
				bEnabled = true
			end	
		end						
	end
	self.detailView:setSettingEnabled(bEnabled)
end	

function SkillView:showUpdateInfo(skillObject)
	if skillObject ==nil then 
		return
	end
	--升级所需熟练度	
	local curSkillRefId = PropertyDictionary:get_skillRefId(skillObject:getPT())
	local needProText = "0"
	local realizeLv = " "
	if curSkillRefId ~= const_skill_pugong then
		local lvTable = skillObject:getPT()
		if lvTable ~= nil then
			local curLevel = PropertyDictionary:get_level(lvTable)
			
			needProText = PropertyDictionary:get_skillUpperExp(skillObject:getSkillLevelPropertyTable(curLevel))
			realizeLv = PropertyDictionary:get_skillLearnLevel(skillObject:getSkillLevelPropertyTable(curLevel))
			realizeLv = tostring(realizeLv)..Config.Words[2014]  				
		end
	end
	--当前成熟度	
	local curProText = PropertyDictionary:get_skillExp(skillObject:getPT())
	--速成药	
	local quickDrug = G_getBagMgr():getItemNumByRefId("item_jinengExp")	
	
	self.detailView:setUpdateInfo(needProText, curProText, quickDrug, realizeLv)
end


function SkillView:showNameAndLevel(skillObject)
	if skillObject ==nil then 
		return
	end
	local skillName = nil
	--技能名
	local staticTable = skillObject:getStaticData()
	if staticTable ~= nil then
		skillName = PropertyDictionary:get_name(staticTable)
	end
	--技能等级	
	local curLevel, maxLevel = skillObject:geCurAndMaxLevel()	
	self.detailView:setSkillNameAndLevel(skillName, curLevel, maxLevel)	
end

function SkillView:showDescription(skillObject)
	if skillObject ==nil then 
		return
	end
	--技能描述
	local curLevel, maxLevel = skillObject:geCurAndMaxLevel()
	local nextLevel = (curLevel+1)>maxLevel and maxLevel or (curLevel+1)
	local curSkillDesc = skillObject:getDescByLevel(curLevel)
	local nextSkillDesc = skillObject:getDescByLevel(nextLevel)
	
	self.detailView:setDetailDescritpion(curLevel, maxLevel, curSkillDesc, nextSkillDesc)
end


function SkillView:createDetailsNode()
	self.detailView = SkillDetailView.New()
	self:addChild(self.detailView:getRootNode())
	local skillGridView = self.subViews[SubView.jichu].obj
	if skillGridView then 
		VisibleRect:relativePosition(self.detailView:getRootNode(), skillGridView:getRootNode(), LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE, ccp(10, 0))
	end
end	



function SkillView:getCurSel()
	local skillGridView = self.subViews[SubView.jichu].obj
	if skillGridView then 
		return skillGridView:getCurSelect()
	end
end

----------------------新手指引----------------------
function SkillView:getQuickSettingBtn()
	local quickSettingBtn = self.detailView:getQuickSettingBtn()
	return quickSettingBtn
end

function SkillView:getFirsetHandupSkillNode()
	local skillGridView = self.subViews[SubView.jichu].obj
	if skillGridView then 
		local firsetHandupSkillNode = skillGridView:getFirsetHandupSkillNode()
		return firsetHandupSkillNode
	end
end


