-- �ɸ�����Ҫ����״�����о���
--Juchao@20140317:
--[[
�÷�(��ʾһ��ͼ��ԲȦ����)��
local clipper = ClippingSprite.New()
clipper():getRootNode():addChild(child)
clipper():drawCircle()
--]]
ClippingSprite = ClippingSprite or BaseClass()

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()

function ClippingSprite:__init()
	self.rootNode = CCClippingNode:create()
	self.rootNode:retain()
	
	self.drawNode = CCDrawNode:create()
	self.rootNode:setStencil(self.drawNode)		
    self.rootNode:setPosition(ccp(const_visibleSize.width / 2, const_visibleSize.height / 2))	
end		

function ClippingSprite:__delete()
	self.rootNode:release()	
end	

function ClippingSprite:clear()
	self.drawNode:clear()
end

function ClippingSprite:getRootNode()
	return self.rootNode
end

function ClippingSprite:getDrawNode()
	return self.drawNode
end

function ClippingSprite:clear()
	self.drawNode:clear()
end

function ClippingSprite:moveDrawNodeTo(pos)
	self.drawNode:setPosition(pos)
end

function ClippingSprite:isInverted()
	return self.rootNode:isInverted()
end

--�����Ƿ���ʾ���в���֮��Ĳ��֡�Ĭ��Ϊfalse������ʾ���еĲ���
function ClippingSprite:setInverted(bInverted)
	self.rootNode:setInverted(bInverted)
end		

--��һ��Բ
function ClippingSprite:drawCircle(radius)
	local green 	= ccc4f(0, 1, 0, 1)	
	local nCount	= 100;				--Բ����ʵ���Կ����������,����100������ģ��Բ��
	local coef 		= 2 * ((3.14159265358979323846)/nCount);--����ÿ�������ڶ��������ĵļн�

	local arr = CCPointArray:create(100)
	for i = 1, 100 do
		local rads = i * coef;--����
		arr:addControlPoint(ccp(radius * math.cos(rads), radius * math.sin(rads)))
	end		
	self.drawNode:setContentSize(CCSizeMake(radius * 2, radius * 2))
	self.drawNode:drawPolygonWithArray(arr, green, 0, green) --������������)
end

--��һ�������
--pointArray: CCPointArray���ͣ����øö���εĸ�������
--fillColor: ccColor4F���ͣ�������ɫ
--borderWidth: float���ͣ���Ե�Ŀ��
--borderColor: ccColor4F���ͣ���Ե�Ŀ��
function ClippingSprite:drawPolygon(pointArray, fillColor, borderWidth, borderColor)
	self.drawNode:drawPolygonWithArray(pointArray, fillColor, borderWidth, borderColor) --������������
end