require "common.baseclass"
require "ui.skill.SkillItem"
require "ui.utils.GridView"

SkillGridView = SkillGridView or BaseClass()

local viewSize = VisibleRect:getScaleSize(CCSizeMake(335, 455))
local marginHor = 10  --���ܼ�ˮƽ�����ϵļ��
local marginVer = 0  --���ܼ䴹ֱ�����ϵļ��
local itemsPerPage = 9 --scrollview��һҳ9��item
local itemsPerLine = 3 --ÿһ��3��item
local itemsPerRow = 3 
local gridSize = CCSizeMake(95, 145)

function SkillGridView:__init()
	self.skills = {}
	self:createRootNode()	
	self:loadSkillItems()
	self:createPageIndicator()  --ָʾ��
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
	
	--����
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

--����������ʱ�����¼��أ������������
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


--ҳ��ָʾ��
function SkillGridView:createPageIndicator()
	local totalPage = self:CalcSkillPageCnt()
	self.pageIndicateView = createPageIndicateView(totalPage, 1)	
	self.rootNode:addChild(self.pageIndicateView:getRootNode())
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self.rootNode, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 55))	
end	

--���㼼�ܵ�ҳ��
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
		--���¼�����ϸ��Ϣ
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

--����
function SkillGridView:updateSkills()
	--����Ƕ�������Ҫ���¼��ؼ���
	if self.skillMgr:isReconnect() then 
		self:reload()
		self.skillMgr:setReconnect(false)
	end
	if self.skillMgr:getDefSel() then 
		self.curSel = self.skillMgr:getDefSel()
		self.skillMgr:setDefSel(nil)		
	end
	self:updateGridBox()	
	--���ѡ�еļ������ڵ�ҳ��͵�ǰҳ�治һ�£��򻬶�������ѡ�е�ҳ�� @yejunhua 2014-2-18 20:29:47
	self:scroll2SkillSelectPage()		
	VisibleRect:relativePosition(self.gridView:getRootNode(), self.rootNode, LAYOUT_CENTER, ccp(0, 15))
end

--����������ѡ�е�ҳ��
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
	--���ܱ߲������ݱ�ɾ��������ֻ�ܲ�����������ɾ��
	for k, refId in pairs(updateList) do 
		self.skillMgr:removeSkillNeedUpdate(refId)
	end					
end


--����ѡ�к�Ŀ�
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

--�жϿ�ݼ��ܣ�Ҫ��ԭʼ(������չ����)��refid
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

----------------------����ָ��----------------------
function SkillGridView:getFirsetHandupSkillNode()
	local uiIndex = self.skillMgr:getUiIndex()	
	for index, uiSkillRefId in ipairs(uiIndex) do
		if GameData.HandUpSkill[uiSkillRefId] then
			--����uiSkillRefId��ȡnode	
			local gridIndex = self.skillMgr:getIndexByRefId(uiSkillRefId)			
			local item = self.skills[gridIndex]
			if item then
				return item:getRootNode()
			end					
		end
	end
end