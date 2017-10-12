require("common.baseclass")
require("common.BaseObj")

NearbyPlayer = NearbyPlayer or BaseClass(BaseObj)

function NearbyPlayer:__init()
	self.pkModel = 3
end

function NearbyPlayer:__delete()
	--[[if self.cell then
		self.cell:release()
	end	--]]
end
--player����
function NearbyPlayer:setPlayerName(name)
	if string.isLegal(name) then
		self.playerName = name
	end		
end

function NearbyPlayer:getPlayerName()
	return self.playerName
end
--player serverId
function NearbyPlayer:setPlayerServerId(serverId)
	if string.isLegal(serverId) then
		self.playerServerId = serverId
	end		
end

function NearbyPlayer:getPlayerServerId()
	return self.playerServerId
end
--player�ȼ�
function NearbyPlayer:setPlayerLevel(level)
	if level and level >= 0 then
		self.playerLevel = level
	end		
end

function NearbyPlayer:getPlayerLevel()
	return self.playerLevel
end
--playerְҵ
function NearbyPlayer:setPlayerProfessionId(professionId)
	if professionId and professionId >= 0 then
		self.playerProfession = professionId
	end		
end

function NearbyPlayer:getPlayerProfessionId()
	return self.playerProfession
end
--player��hero����
function NearbyPlayer:setDistance(distance)
	self.distance = distance
end

function NearbyPlayer:getDistance()
	return self.distance
end

--״̬
function NearbyPlayer:setState(state)
	self.state = state
end

function NearbyPlayer:getState()
	return self.state
end

--PKģʽ

function NearbyPlayer:setPkModel(model)
	self.pkModel = model
end

function NearbyPlayer:getPkModel()
	return self.pkModel
end

----��������
function NearbyPlayer:setUnionName(union)
	if string.isLegal(union) then
		self.unionName = union
	end		
end

function NearbyPlayer:getUnionName()
	return self.unionName
end

function NearbyPlayer:setNameColor(color)
	if color then
		self.nameColor = color
	end		
end

function NearbyPlayer:getNameColor()
	return self.nameColor
end
--cell
--[[function NearbyPlayer:setCell(cell)
	self.cell = cell
	self.cell:retain()
end

function NearbyPlayer:getCell()
	return self.cell
end--]]

