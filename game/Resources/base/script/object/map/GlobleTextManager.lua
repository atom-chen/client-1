GlobleTextManager = GlobleTextManager or BaseClass()

function GlobleTextManager:__init()
	self.textList = {}
	self.batchNodes = {}
	self.heroBatches = {}
end

function GlobleTextManager:clear()
	local sfmap = SFMapService:instance():getShareMap()			
	if sfmap then	
		for k,v in pairs(self.batchNodes) do		
			sfmap:leaveMap(v, eRenderLayer_Effect)
		end
	end
	if self.heroBatches then
		for k,v in pairs(self.heroBatches) do		
			sfmap:leaveMap(v, eRenderLayer_Effect)
		end				
	end
end

function GlobleTextManager:enterMap()
	local sfmap = SFMapService:instance():getShareMap()			
	if sfmap then	
		for k,v in pairs(self.batchNodes) do		
			sfmap:enterMap(v, eRenderLayer_Effect)
		end
	end
	if self.heroBatches then
		for k,v in pairs(self.heroBatches) do		
			sfmap:enterMap(v, eRenderLayer_Effect)
		end					
	end
end

function GlobleTextManager:addTitle(id,text,size,x,y,color,offset)
	local array = SFSharedFontManager:sharedSFSharedFontManager():getSpriteList("",size,text)
	local count = array:count()	
	local textData = {}	
	textData.array = {}
	textData.widthSum = 0
	if offset then
	 textData.offset = offset 
	end
	local batch = nil
	local height = 0
	for i=0,count-1 do	
		local sprite = array:objectAtIndex(i)
		sprite =  tolua.cast(sprite,"CCSprite")
		local size = sprite:getContentSize()		
		sprite:setScaleY(-1)
		sprite:setAnchorPoint(ccp(0,0.5))
		if color then
			sprite:setColor(color)
		end
		if size.height > height then
			height = size.height
		end
		batch = self:getBatchNode(sprite,id)			
		batch:addChild(sprite)
		table.insert(textData.array,sprite)
		textData.widthSum = textData.widthSum+size.width+2
	end		
	local halfWidth = textData.widthSum / 2
	local sum = 0
	local xxx,yyy
	for k,sprite in pairs(textData.array) do
		xxx = x - halfWidth + sum
		yyy = y
		if offset then
			xxx = xxx + offset.x
			yyy = yyy + offset.y
		end
		sprite:setPosition(xxx,yyy)
		local size = sprite:getContentSize()	
		sum = sum + size.width
	end
	local data = self.textList[id]
	if data ~= nil then
		for k,v in pairs(data) do
			data[k] = nil
		end
	end
	self.textList[id] = textData
	return CCSizeMake(sum,height)
end

function GlobleTextManager:removeTilte(id)
	local data = self.textList[id]
	if data then		
		for k,sprite in pairs(data.array) do
			sprite:removeFromParentAndCleanup(true)
			data[k] = nil
		end
	end
	if self.textList and data then
		self.textList[id] = nil
	end		
end


function GlobleTextManager:setTiltleVisible(id,show)
	local data = self.textList[id]
	if data then		
		for k,sprite in pairs(data.array) do
			sprite:setVisible(show)
		end
	end
end

function GlobleTextManager:updatePosition(id,x,y)
	local data = self.textList[id]
	if data and type(data) == "table" then	
		local widthSum = 0
		local offset = data.offset
		if offset == nil then
			offset = ccp(0,0)
		end
		local halfWidth = data.widthSum/2
		for k,sprite in pairs(data.array) do
			local size = sprite:getContentSize()
			local xxx = x+widthSum-halfWidth+offset.x
			local yyy = y+offset.y
			sprite:setPosition(xxx,yyy)
			widthSum = widthSum +size.width
		end
	end
end

function GlobleTextManager:updateColor(id,color)
	local data = self.textList[id]
	if data then		
		for k,sprite in pairs(data.array) do
			if color then
				sprite:setColor(color)
			end				
		end
	end
end

function GlobleTextManager:adjustPosition(id,offsetX,offsetY)
	local data = self.textList[id]
	if data then
		local offset = data.offset				
		for k,sprite in pairs(data.array) do		
			if type(sprite) == "userdata" then
				local x,y = sprite:getPosition()
				if offset then
					x = x - offset.x
					y = y - offset.y
				end
				data.offset = ccp(offsetX,offsetY)
				sprite:setPosition(ccpAdd(data.offset,ccp(x,y)))
			end	
		end
	end
end

function GlobleTextManager:getBatchNode(sprite,idd)
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local heroId = nil
	if hero then
		heroId = hero:getId()
	end
	local tex = sprite:getTexture()
	local texKey = tostring(tex:getName())
	if heroId == idd then
		local heroBatch = self.heroBatches[texKey]
		if heroBatch == nil then
			heroBatch = CCSpriteBatchNode:createWithTexture(sprite:getTexture())
			local blendFunc =  ccBlendFunc()
			blendFunc.src = GL_ONE
			blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA
			heroBatch:setBlendFunc(blendFunc)
		
			heroBatch:retain()
			self.heroBatches[texKey] = heroBatch
			SFMapService:instance():getShareMap():enterMap(heroBatch, eRenderLayer_Effect)
		end
		return heroBatch
	end
	
	local batch = self.batchNodes[texKey]
	if batch == nil then
		batch = CCSpriteBatchNode:createWithTexture(tex,200)
		local blendFunc =  ccBlendFunc()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA
        batch:setBlendFunc(blendFunc)
		batch:setVisible(GameWorld.Instance:getSettingMgr():isShowPlayerName())		
		batch:retain()
		self.batchNodes[texKey] = batch		
		SFMapService:instance():getShareMap():enterMap(batch, eRenderLayer_Effect)
	end
	return batch 
end


function GlobleTextManager:hasTitle(id)
	return self.textList[id] ~= nil
end

function GlobleTextManager:setTextVisible(show)
	for k,v in pairs(self.batchNodes) do
		v:setVisible(show)
	end
end
