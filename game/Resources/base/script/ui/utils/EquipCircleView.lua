--装备界面
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("GameDef")
require("object.equip.EquipDef")
require("ui.utils.BodyAreaView")
require("object.bag.ItemDetailArg")

EquipCircleView = EquipCircleView or BaseClass()

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_size = VisibleRect:getScaleSize(CCSizeMake(372, 437))
local const_scale = VisibleRect:SFGetScale()

function EquipCircleView:__init()	
	self.rootNode = CCNode:create()		
	self.rootNode:retain()		
	self.rootNode:setContentSize(const_size)	
	self:creataBodyAreas()	
end	

function EquipCircleView:__delete()
	self.rootNode:release()
	for index, value in ipairs(G_getEquipMgr():getHeroEquipInfo()) do	
		--local name = value.name
		for index, grid in pairs(value.grids) do
			if (grid.view) then
				grid.view:DeleteMe()
			end
			grid = nil
		end
	end
	
	if (self.heroModelView) then
		self.heroModelView:DeleteMe()
		self.heroModelView = nil
	end
end

function EquipCircleView:getRootNode()
	return self.rootNode
end

--------以下为私有方法--------
function EquipCircleView:creataBodyAreas()
	if (table.size(G_getEquipMgr():getHeroEquipInfo()) < 1) then
		return
	end
	
	--local name = G_getEquipMgr():getHeroEquipInfo()[E_BodyAreaId.eWeapon].name
	local grid = G_getEquipMgr():getHeroEquipInfo()[E_BodyAreaId.eWeapon].grids[0]
	local image = G_getEquipMgr():getHeroEquipInfo()[E_BodyAreaId.eWeapon].image
	while true do
		grid.view = BodyAreaView.New()
		--grid.view:setName(name)
		grid.view:setNameImage(image)
		grid.view:setClickNotify(self, self.handleBodyAreaClick)
		self.rootNode:addChild(grid.view:getRootNode())		
		
		if (grid.pre) then
			local preGrid = G_getEquipMgr():getHeroEquipInfo()[(grid.pre[1])].grids[(grid.pre[2])]
			VisibleRect:relativePosition(grid.view:getRootNode(), preGrid.view:getRootNode(), grid.layout, grid.offset)
		else
			VisibleRect:relativePosition(grid.view:getRootNode(), self.rootNode, grid.layout, grid.offset)
		end
		
		if (grid.nnext == nil) then
			break
		else
			local nextGrid = G_getEquipMgr():getHeroEquipInfo()[(grid.nnext[1])].grids[(grid.nnext[2])]
			--name = G_getEquipMgr():getHeroEquipInfo()[(grid.nnext[1])].name
			image = G_getEquipMgr():getHeroEquipInfo()[(grid.nnext[1])].image
			grid = nextGrid
		end
	end
end			

function EquipCircleView:setClickNotify(aarg, ffunc)
	self.notify = {arg = aarg, func = ffunc}
end	

function EquipCircleView:handleBodyAreaClick(view) 
	if not view then
		return
	end
	if (self.notify) then
		self.notify.func(self.notify.arg, view)
	end		
end	

function EquipCircleView:updateOneBodyAreaView(bodyAreaId, pos, equipObj)
	local view = G_getEquipMgr():getHeroEquipInfo()[bodyAreaId].grids[pos]
	if view then
		view = view.view
		view:setData(equipObj)
	end
end

function EquipCircleView:updateBodyAreaView(list)
	if not list then
		return
	end
	for bodyAreaId, value in ipairs(G_getEquipMgr():getHeroEquipInfo()) do			--清除所有部位的装备
		--local name = value.name
		for index, grid in pairs(value.grids) do
			if (grid.view) then
				grid.view:setData(nil)
				grid.view:showAddIcon(false)				
			end
		end
	end
	
	if not list then
		return
	end
	for bodyAreaId, value in pairs(list) do					--显示装备
		for i, v in pairs(value) do
			local bodyArea = G_getEquipMgr():getHeroEquipInfo()[v:getBodyAreaId()]
			if ((bodyArea ~= nil) and (bodyArea.num > v:getPosId())) then
				bodyArea.grids[v:getPosId()].view:setData(v)
			end
		end
	end
	
	self:updateAddIcon()
end	

--Juchao@20140211：延迟一点再更新，提高性能
function EquipCircleView:updateAddIcon()
	local removeSchId = function()
		if self.delayAddIconSchId then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayAddIconSchId)
		end
		self.delayAddIconSchId = nil
	end
	removeSchId()

	local onTimeout = function()
		if self.delayAddIconSchId == nil then
			return
		end
		self:doUpdateAddIcon()		
		removeSchId()
	end
	self.delayAddIconSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 0.5, false);		
end

function EquipCircleView:doUpdateAddIcon()
	local bagMgr = G_getBagMgr()	
	local isHero = self:getIsHero()	
	for bodyAreaId, value in ipairs(G_getEquipMgr():getHeroEquipInfo()) do
		for index, grid in pairs(value.grids) do
			if not grid.view:getData() and isHero then									
				--没有装备的部位，如果背包里有相关装备，则显示+标记								
				if bagMgr:hasEquipInBodyArea(bodyAreaId)  then
					grid.view:showAddIcon(true)
				else
					grid.view:showAddIcon(false)
				end
			else
				grid.view:showAddIcon(false)
			end
		end
	end
end

--判断是不是玩家
function EquipCircleView:setIsHero(bIsHero)
	self.isHero = bIsHero
end

function EquipCircleView:getIsHero()
	return self.isHero
end