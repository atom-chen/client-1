require("object.npc.NpcDef")
require("object.castleWar.CastleWarDef")
require("ui.UIManager")
require("data.castleWar.castleWar")
require("data.npc.npc")
require("ui.Npc.NpcBaseView")
NpcCastleWarView = NpcCastleWarView or BaseClass(NpcBaseView)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_size = CCSizeMake(400 * const_scale, 540 * const_scale)

function NpcCastleWarView:__init()
	self.viewName = "NpcCastleWarView"	
	self.pageCache = {}
	self.btns = 
	{
		{name = "apply_warfare.png", click = self.onApply},				--申请攻城战
		{name = "view_Guild.png", click = self.onCheckFactionList},	--查看攻城公会
		{name = "recv_huangcheng_gifts.png", click = self.onGetGift},			--查看攻城公会
		{name = "enter_Imperial_instance.png", click = self.onEnterInstance},		--进入王城副本
	}
	
	self:init(const_size)	
	self:createViewBg()	
	self:createDescription()
	self:initBtns()
end	

function NpcCastleWarView:__delete()

end

function NpcCastleWarView:onExit()
	
end

function NpcCastleWarView:onEnter(npcRefId)
	if self.npcRefId ~= npcRefId then
		self.npcRefId = npcRefId	
		self:showHeadIcon()
	end
end


function NpcCastleWarView:createDescription()
	local text = GameData.Npc["npc_10"]["property"]["description"]	
	text = "    "..text
	self:setNpcText(text)	
end

function NpcCastleWarView:showHeadIcon()
	if GameData.Npc[self.npcRefId] == nil then 
		return
	end
	
	self:setNpcAvatar(self.npcRefId)
	self:setNpcName(self.npcRefId)			
end

function NpcCastleWarView:initBtns(name, data)
	local parentNode1 = CCNode:create()
	local parentNode2 = CCNode:create()
	local nodes1 ={}
	local nodes2 = {}				
	for k, v in ipairs(self.btns) do
		local button = createButtonWithFramename(RES("btn_1_select.png"))	
		local label = createSpriteWithFrameName(RES(v.name))		
		button:setTitleString(label)
		local onClick = function()
			v.click(self)
		end
		button:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)	
		if k <= 2 then 			
			table.insert(nodes1, button)
		else
			table.insert(nodes2, button)
		end
	end
	G_layoutContainerNode(parentNode1, nodes1, 53, E_DirectionMode.Horizontal)
	G_layoutContainerNode(parentNode2, nodes2, 53, E_DirectionMode.Horizontal)
	self:addChild(parentNode1)
	self:addChild(parentNode2)
	VisibleRect:relativePosition(parentNode1, self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X, ccp(0, -257))
	VisibleRect:relativePosition(parentNode2, parentNode1, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -51))
end	

--申请攻城战
function NpcCastleWarView:onApply()	
	local ret, des = G_getCastleWarMgr():checkCanApplyCastleWar()
	if ret then				
		self:showApplyConsumeMsgBox()
	else
		UIManager.Instance:showSystemTips(des)
	end
end

function NpcCastleWarView:doApply()	
	G_getCastleWarMgr():requestJoinWar()
end

function NpcCastleWarView:showApplyConsumeMsgBox()
	
	local data = GameData.CastleWar["castleWar"]
	if not data then
		print("NpcCastleWarView:showApplyConsumeMsgBox error. no data of castleWar_1")
		return
	end
	local goldNumber = PropertyDictionary:get_gold(data.activityData.castleWar_1.property)
	local zuMaHaoJiao = 1
	local tips = string.format("%s \n\n %s * %d \n\n %s * %d \n\n %s", Config.Words[21000], Config.Words[21001], goldNumber, Config.Words[21008], zuMaHaoJiao, Config.Words[21002])		
	
	local onMsgBoxClose = function(unused, text, id)	
		if id == 2 then
			self:doApply()
		end
	end
		
	local msg = showMsgBox(tips,E_MSG_BT_ID.ID_CANCELAndOK)	
	msg:setNotify(onMsgBoxClose)
--	UIManager.Instance:showMsgBox(tips, nil, onMsgBoxClose, nil, nil, true, E_ShowOption.eMove2Right)		
--	UIManager.Instance:moveViewByName(self.viewName, E_ViewPos.eLeft, true)
end

--申请攻城战
function NpcCastleWarView:onGetGift()				
	G_getCastleWarMgr():requestGetGift()
end

--申请攻城战
function NpcCastleWarView:onCheckFactionList()				
	G_getCastleWarMgr():requestCastleWarFactionList()
end

--进入王城副本	
function NpcCastleWarView:onEnterInstance()				
	G_getCastleWarMgr():requestCastleWarInstance()
	self:close()
end