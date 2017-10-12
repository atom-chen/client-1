ServerItemNode = ServerItemNode or BaseClass()

local defSize = VisibleRect:getScaleSize(CCSizeMake(285, 84))

function ServerItemNode:__init(rootNodeSize)
	self:createRootNode(rootNodeSize)
	self:createUI()
end

function ServerItemNode:__delete()
	if self.rootNode then
		self.rootNode:release()
		self.rootNode = nil
	end
end

function ServerItemNode:createRootNode(rootNodeSize)
	local size = rootNodeSize or defSize
	self.rootNode = CCNode:create()
	self.rootNode:retain()
	self.rootNode:setContentSize(size)	
	local nodeBg = createScale9SpriteWithFrameNameAndSize(RES("login_squares_serverFrame.png"), size)
	self.rootNode:addChild(nodeBg)
	VisibleRect:relativePosition(nodeBg, self.rootNode, LAYOUT_CENTER)
end

function ServerItemNode:getRootNode()
	return self.rootNode
end

function ServerItemNode:createUI()
	--self.areaLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size5"), FCOLOR("ColorWhite1"))
	self.nameLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size5"), FCOLOR("ColorWhite1"))
	self.stateLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size5"), FCOLOR("ColorWhite1"))
	
	--self.rootNode:addChild(self.areaLabel)
	self.rootNode:addChild(self.nameLabel)
	self.rootNode:addChild(self.stateLabel)
	
	--VisibleRect:relativePosition(self.areaLabel, self.rootNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(10, 0))
	VisibleRect:relativePosition(self.nameLabel, self.rootNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(10, 0))
	VisibleRect:relativePosition(self.stateLabel, self.nameLabel, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-20, -10))
end

function ServerItemNode:setServerInfo(server)
	--self:setArea(server)
	self:setName(server)
	self:setState(server)
end

function ServerItemNode:setArea(serverObj)
	if self.areaLabel and serverObj then 
		local areaText = serverObj:getServerId() or ""
		self.areaLabel:setString(areaText .. Config.LoginWords[8500])
		VisibleRect:relativePosition(self.areaLabel, self.rootNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(16, 0))
	end
end

function ServerItemNode:setName(serverObj)
	if self.nameLabel and serverObj then 
		local nameText = serverObj:getServerName() or ""
		self.nameLabel:setString(nameText)
		--VisibleRect:relativePosition(self.nameLabel, self.areaLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(13, 0))
		VisibleRect:relativePosition(self.nameLabel, self.rootNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(10, 0))
	end
end

function ServerItemNode:setState(serverObj)
	if self.rootNode and self.stateLabel and serverObj then 
		local stateText = tonumber(serverObj:getServerState())
		local pic = "server_hot.png"
		if stateText==-1 or stateText==0 or stateText==1 then 
			stateText = Config.LoginWords[8501]
			pic = "server_ash.png"
		elseif stateText==2 then 
			stateText = Config.LoginWords[8502]
			pic = "server_hot.png"
		else
			stateText = Config.LoginWords[8503]
			pic = "server_red.png"
		end
		self.stateLabel:setString(stateText)
		VisibleRect:relativePosition(self.stateLabel, self.rootNode, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(-26, 10))
		
		if self.statePic then
			self.statePic:removeFromParentAndCleanup(true)
		end			
		self.statePic = createSpriteWithFrameName(RES(pic))
		self.rootNode:addChild(self.statePic)
		VisibleRect:relativePosition(self.statePic, self.stateLabel, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -5))	
	end
end	

function ServerItemNode:update(server)
	self:setServerInfo(server)
end
