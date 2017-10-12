
MainPKHit = MainPKHit or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()

function MainPKHit:__init()
	self.rootNode = CCLayer:create()	
	self.rootNode:setContentSize(visibleSize)
	self.scale = VisibleRect:SFGetScale()
	self.PKHitMgr = GameWorld.Instance:getEntityManager():getHero():getPKHitMgr()
	
	self.spriteList = {}
	
	self:crateView()
end

function MainPKHit:__delete()
	
end

function MainPKHit:getRootNode()
	return self.rootNode
end

function MainPKHit:crateView()
	local spriteinfoList = {
		[1] = {name = "top",width = visibleSize.width,layout = LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE,rot = 0    },
		[2] = {name = "left",width = visibleSize.height,layout = LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,rot = 90   },
		[3] = {name = "down",width = visibleSize.width,layout = LAYOUT_CENTER+LAYOUT_TOP_INSIDE,rot = 180   },
		[4] = {name = "right",width = visibleSize.height,layout = LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE ,rot = 270  },
	}
	local spritehight = 56	
	for i,v in pairs(spriteinfoList) do
		self.spriteList[i] = createScale9SpriteWithFrameNameAndSize(RES("PKHit.png"),CCSizeMake(v.width, spritehight)) 
		self.spriteList[i]:setOpacity(0)
		self.spriteList[i]:setRotation(v.rot)
		self.rootNode:addChild(self.spriteList[i])
		VisibleRect:relativePosition(self.spriteList[i],self.rootNode,v.layout)
	end
end

function MainPKHit:createActions()
	local retAction = nil
	local time = 2
	local cont = 3
			
	local actionArray = CCArray:create()
	local fadeIn = CCFadeIn:create(time/cont/2)
	local fadeOut = CCFadeOut:create(time/cont/2)		
	
	actionArray:addObject(fadeIn)
	actionArray:addObject(fadeOut)		
	
	local sequence = CCSequence:create(actionArray)
	
	retAction = CCRepeat:create(sequence, cont)		
	
	return retAction
end

function MainPKHit:playActions()
	if table.size(self.spriteList)>0 then
		for i,v in pairs(self.spriteList) do
			local action = self:createActions()
			v:runAction(action)
		end
	end
end
