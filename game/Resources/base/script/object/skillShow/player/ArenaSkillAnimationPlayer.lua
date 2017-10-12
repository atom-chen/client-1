
require "object.skillShow.player.AnimatePlayer"

ArenaSkillAnimationPlayer = ArenaSkillAnimationPlayer or BaseClass(AnimatePlayer)

function ArenaSkillAnimationPlayer:create()
	local player = ArenaSkillAnimationPlayer.New()		
	return player
end

function ArenaSkillAnimationPlayer:__init(render)
	self.modelId = 0		-- ����ģ��id
	self.renderSprite = nil	-- �����Ķ���
	self.render = render	
	self.offset = ccp(0, 0)
	self.name = "ArenaSkillAnimationPlayer"
	self.direction = 0
	self.animateSpeed = 1.5
	self.scale = 1
end

function ArenaSkillAnimationPlayer:__delete()
	self:onAnimateCallback(0, 2)
end

function ArenaSkillAnimationPlayer:setModleId(modelId)
	self.modelId = modelId
end

function ArenaSkillAnimationPlayer:setDir(dir)
	self.direction = dir
end			

function ArenaSkillAnimationPlayer:doPlay()
	local animateCallback = function (actionId, movementType)
		self:onAnimateCallback(actionId, movementType)
	end
	
	if self.render ~= nil then
		local scaleX = -1
		local actionId = self.direction
		if actionId > 4 then
			actionId = 8- actionId
			scaleX = -1
		end
		
		self.renderSprite = SFRenderSprite:createRenderSprite(self.modelId, actionId, "res/skill/")
		self.renderSprite:setScaleX(scaleX*self.scale)
		self.renderSprite:setScaleY(-1*self.scale)
		self.renderSprite:retain()
		self.render:addChild(self.renderSprite)
		self.renderSprite:setScriptHandler(animateCallback)
		self.renderSprite:playByIndexLua(0)
		
		if self.animateSpeed > 0 then
			self.renderSprite:setAnimationSpeed(self.animateSpeed)
		end
		
		--����offset
		if self.offset then
			self.renderSprite:setPosition(self.offset)
		end
	else
		-- û���ҵ���Ӧ��character, ���ö���Ϊ���
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
end

function ArenaSkillAnimationPlayer:onAnimateCallback(actionId, movementType)
	if 2 == movementType then	
		if self.render ~= nil and self.renderSprite then
			--Juchao@20140523: ��Ҫ����self.render����Ϊself.render���ܱ��ͷŵ��ˡ�
--			self.render:removeChild(self.renderSprite,true) 
			self.renderSprite:removeFromParentAndCleanup(true)
		end
		if self.renderSprite then
			if self.render ~= nil then
				self.render:removeChild(self.renderSprite,true)
			end
		
			self.renderSprite:release()	
			self.renderSprite = nil		
		end

		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
end