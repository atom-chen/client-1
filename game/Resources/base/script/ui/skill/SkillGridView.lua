require "common.baseclass"
require "ui.skill.SkillItem"
require "ui.utils.GridView"

SkillGridView = SkillGridView or BaseClass()

local viewSize = VisibleRect:getScaleSize(CCSizeMake(335, 455))
local marginHor = 10  --技能间水平方向上的间隔
local marginVer = 0  --技能间垂直方向上的间隔
local itemsPerPage = 9 --scrollview中一页9个item
local itemsPerLine = 3 --每一行3个item
local itemsPerRow = 3 
local gridSize = CCSizeMake(95, 145)

function SkillGridView:__init()
	self.skills = {}
	self:createRootNode()	
	self:loadSkillItems()
	self:createPageIndicator()  --指示器
	self:createGridView()
end

function SkillGridView:__delete()
	self.gridBoxs = {}	
	if self.pageIndicateView then
		self.pageIndicateView:DeleteMe()
		self.pageIndicateView = nil
	end				
	if self.rootNode then 
		self.rootNode:release()
		self.rootNode = nil
	end	
	if self.skills then 
		for index, obj in pairs(self.skills) do 
			if obj then 
				obj:DeleteMe()
			end
		end
		self.skills = nil
	end		
end

function SkillGridView:createRootNode()
	self.curSel = 1		
	self.skillMgr = GameWorld.Instance:getSkillMgr()	
	--rootnode
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(viewSize)
	self.rootNode:retain()
	
	--背景
	self.scrollBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), viewSize)	
	self.rootNode:addChild(self.scrollBg)		
	VisibleRect:relativePosition(self.scrollBg, self.rootNode, LAYOUT_CENTER)	
	
	local frame = createScale9SpriteWithFrameNameAndSize(RES("suqares_mallItemUnselect.png"), viewSize)
	self.rootNode:addChild(frame)
	VisibleRect:relativePosition(frame, self.scrollBg, LAYOUT_CENTER)
end		

function SkillGridView:getRootNode()
	return self.rootNode
end

--断线重连的时候重新加载，否则会有问题
function SkillGridView:reload()
	self:reloadSkillItems()	
	local totalPage = self:CalcSkillPageCnt()
	self.pageIndicateView:setPageCount(totalPage, 1)
	self.gridView:setGrids(self.skills, gridSize)		
	self.gridView:reloadAll()	
	self.gridView:setPageIndex(1, true)		
end

function SkillGridView:reloadSkillItems()
	if self.skills then 
		for index, obj in pairs(self.skills) do 
			if obj then 
				obj:DeleteMe()
			end
		end
		self.skills = nil
	end	
	
	self:loadSkillItems()
end

function SkillGridView:loadSkillItems()
	self.skills = {}
	local uiIndex = self.skillMgr:getUiIndex()	
	for k, v in pairs(uiIndex) do 
		local obj = self.skillMgr:getSkillObjectByRefId(v)
		if obj then 
			local item = SkillItem.New()
			item:setSkillIconAndLearnLv(obj)
			item:setSkillName(obj)
			self.skills[k] = item
		end
	end
end

function SkillGridView:createGridView()
	self.gridView = GridView.New()
	self.gridView:setSpacing(marginHor, marginVer)
	self.gridView:setPageOption(itemsPerLine, itemsPerRow)
	self.gridView:setGrids(self.skills, gridSize)
	self.gridView:setTouchNotify(self, self.handleTouchItem)
	self.gridView:setPageChangedNotify(self.pageIndicateView, self.pageIndicateView.setIndex)
	self.rootNode:addChild(self.gridView:getRootNode())	
	self.gridView:reloadAll()	
	VisibleRect:relativePosition(self.gridView:getRootNode(), self.rootNode, LAYOUT_CENTER, ccp(0, 12))
end


--页数指示器
function SkillGridView:createPageIndicator()
	local totalPage = self:CalcSkillPageCnt()
	self.pageIndicateView = createPageIndicateView(totalPage, 1)	
	self.rootNode:addChild(self.pageIndicateView:getRootNode())
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self.rootNode, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 55))	
end	

--计算技能的页数
function SkillGridView:CalcSkillPageCnt()
	local totalItem = table.size(self.skillMgr:getUiIndex())
	local totalPage = math.modf(totalItem / itemsPerPage) + 1
	return totalPage
end

function SkillGridView.handleTouchItem(self, index, itemView)
	if index and itemView then 
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"SkillView")
		if self.curSel == index then 
			return
		end			
		self:setSelectFrame(itemView)
		self.curSel = index		
		--更新技能详细信息
		local selectObj = self.skillMgr:getSkillObjectById(index)
		if selectObj then
			GlobalEventSystem:Fire(GameEvent.EventShowSkillDetailInfo, selectObj)
		end
	end		
end	


----------------------public----------------
function SkillGridView:getCurSelect()
	return self.curSel
end	

--更新
function SkillGridView:updateSkills()
	--如果是断线重连要重新加载技能
	if self.skillMgr:isReconnect() then 
		self:reload()
		self.skillMgr:setReconnect(false)
	end
	if self.skillMgr:getDefSel() then 
		self.curSel = self.skillMgr:getDefSel()
		self.skillMgr:setDefSel(nil)		
	end
	self:updateGridBox()	
	--如果选中的技能所在的页面和当前页面不一致，则滑动到技能选中的页面 @yejunhua 2014-2-18 20:29:47
	self:scroll2SkillSelectPage()		
	VisibleRect:relativePosition(self.gridView:getRootNode(), self.rootNode, LAYOUT_CENTER, ccp(0, 15))
end

--滑动到技能选中的页面
function SkillGridView:scroll2SkillSelectPage()
	local toPage = math.modf((self.curSel-1)/itemsPerPage)+1
	self.gridView:setPageIndex(toPage, true)
end

function SkillGridView:updateGridBox()
	local updateList = self.skillMgr:getUpdateList()
	for k, refId in pairs(updateList) do 	
		local index = self.skillMgr:getIndexByRefId(refId)		
		local obj = self.skillMgr:getSkillObjectById(index)
		if index and obj then 
			local item = self.skills[index]
			if item then 
				item:setSkillIconAndLearnLv(obj)
				item:setSkillName(obj)	
				if index == self.curSel then 
					self:setSelectFrame(item)
					GlobalEventSystem:Fire(GameEvent.EventShowSkillDetailInfo, obj)
				end
				local bQuickSkill = self:isQuickSkill(index)
				if bQuickSkill then
					item:setQuickMarkVisible(true)
				else
					item:setQuickMarkVisible(false)
				end
			end				
		end				
	end
	--不能边操作数据边删除，所以只能操作完数据再删除
	for k, refId in pairs(updateList) do 
		self.skillMgr:removeSkillNeedUpdate(refId)
	end					
end


--技能选中后的框
function SkillGridView:setSelectFrame(item)
	if self.selectFrame == nil then 
		self.selectFrame = createSpriteWithFrameName(RES("skill_select_bg.png"))						
		self.selectFrame:retain()				
	end			
	self.selectFrame:removeFromParentAndCleanup(true)
	item:getRootNode():addChild(self.selectFrame)
	VisibleRect:relativePosition(self.selectFrame, item:getIconBg(), LAYOUT_CENTER)				
end



function SkillGridView:setSkillSelectFrame(page, index)
	local offsetX, offsetY = self:calculateOffset(page, index)
	VisibleRect:relativePosition(self.skillSelFrame, self.scrollNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(offsetX, -offsetY))			
end

function SkillGridView:calculateOffset(page, index)
	local row = (math.modf(index/itemsPerLine))+1
	local col = math.mod(index, itemsPerLine)+1
	local offsetX = 18+(115+marginHor)*(col-1)+(viewSize.width+3)*(page-1)
	local offsetY = 18+(128+marginVer)*(row-1)
	return offsetX, offsetY
end	

function SkillGridView:createEmtyNode()
	local node = CCNode:create()
	node:setContentSize(CCSizeMake(1, 1))		
	node:retain()
	return node	
end

--判断快捷技能，要找原始(不是扩展技能)的refid
function SkillGridView:isQuickSkill(index)
	local retVal = false
	local uiIndex = self.skillMgr:getUiIndex()
	local srcRefId = uiIndex[index]
	if srcRefId then 
		local obj = self.skillMgr:getSkillObjectByRefId(srcRefId)
		if obj then
			local quickskillIndex = PropertyDictionary:get_quickSkill(obj:getPT())
			if quickskillIndex ~= -1 then 
				retVal = true
			end
		end
	end
	return retVal
end

function SkillGridView:getSkillItemNodeByIndex(index)
	if self.skills[index] then 
		return self.skills[index]:getRootNode()
	end
end

----------------------新手指引----------------------
function SkillGridView:getFirsetHandupSkillNode()
	local uiIndex = self.skillMgr:getUiIndex()	
	for index, uiSkillRefId in ipairs(uiIndex) do
		if GameData.HandUpSkill[uiSkillRefId] then
			--根据uiSkillRefId获取node	
			local gridIndex = self.skillMgr:getIndexByRefId(uiSkillRefId)			
			local item = self.skills[gridIndex]
			if item then
				return item:getRootNode()
			end					
		end
	end
end