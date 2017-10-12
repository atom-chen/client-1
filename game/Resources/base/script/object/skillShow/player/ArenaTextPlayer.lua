--[[
飘字效果
]]

require "object.skillShow.player.AnimatePlayer"
require "config.color"
require "config.words"

local const_lableNodeTag = 20140603

ArenaTextPlayer = ArenaTextPlayer or BaseClass(AnimatePlayer)

function ArenaTextPlayer:__init()
	self.text = ""
	self.style = 0
	self.lableNode = nil

	self.name = "ArenaTextPlayer"
	self.attackId = ""
	self.attackType = ""	
end

function ArenaTextPlayer:__delete()
	self:clean()
end

--设置飘字动画的目标
function ArenaTextPlayer:setPlayerData(render, text,dir,updateCallback)
	self.text = text
	self.dir = dir
	self.render = render
	self.updateCallback = updateCallback	
end

function ArenaTextPlayer:clean()
	self.state = AnimatePlayerState.AnimatePlayerStateFinish
end

function ArenaTextPlayer:doPlay()
	if self.render == nil then
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
		return
	end
	
	self.render.renderSprite:removeChildByTag(const_lableNodeTag, true)
	local textFinishCallback = function ()
		self.lableNode:setVisible(false)
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
	
	local updateHPCallback = function()
		self.updateCallback(self.text)
	end
		
	local atlasName = Config.AtlasImg.FightHpRed
	self.lableNode = createAtlasNumber(atlasName, self.text)	
	self.lableNode:setTag(const_lableNodeTag)
	self.lableNode:setScaleY(-1)
	self.lableNode:setAnchorPoint(ccp(0.5, 0.5))
	if self.dir and self.dir < 0 then
		self.lableNode:setScaleX(-1)		
	end

	self.render:addChild(self.lableNode)
	self.lableNode:setPosition(ccp(0, -100))
	
	-- 创建飘字的action
	local action = self:createActions()
	local actionArray = CCArray:create()
	actionArray:addObject(action)
	actionArray:addObject(CCCallFunc:create(updateHPCallback))
	actionArray:addObject(CCCallFunc:create(textFinishCallback))
	self.lableNode:runAction(CCSequence:create(actionArray))
end

function ArenaTextPlayer:doStop()
	
end

function ArenaTextPlayer:createActions()
	local retAction = nil	
	local scaleAction = CCScaleBy:create(0.1, 3)
	local moveAction = CCMoveBy:create(0.2, ccp(0, -100))
	
	--local spawnAction = CCSpawn:createWithTwoActions(scaleAction, moveAction)
	--local delayAction = CCDelayTime:create(0.05)
	local actionArray = CCArray:create()
	--actionArray:addObject(spawnAction)
	actionArray:addObject(scaleAction)
	--actionArray:addObject(delayAction)
	actionArray:addObject(moveAction)
	retAction = CCSequence:create(actionArray)
	
	return retAction
end



