require("common.baseclass")

ChatObject = ChatObject or BaseClass()

function ChatObject:__init()
	self.vipLevel = 0
end		

function ChatObject:setType(objectType)
	self.type = objectType
end

function ChatObject:getType()
	return self.type
end

function ChatObject:setSenderName(senderName)
	self.senderName = senderName
end

function ChatObject:getSenderName()
	return self.senderName
end

function ChatObject:setSenderId(senderId)
	self.senderId = senderId
end

function ChatObject:getSenderId()
	return self.senderId
end

function ChatObject:getReceiverName()
	return self.receiverName
end

function ChatObject:setReceiverName(name)
	self.receiverName = name
end

function ChatObject:setReceiverId(id)
	self.receiverId = id
end

function ChatObject:getReceiverId()
	return self.receiverId
end	

function ChatObject:setContent(content)
	self.content = content
end

function ChatObject:getContent()
	return self.content
end

function ChatObject:getGender()
	return self.gender
end

function ChatObject:setGender(gender)
	self.gender = gender
end	

function ChatObject:getReceiverGender()
	return self.receiverGender
end

function ChatObject:setReceiverGender(gender)
	self.receiverGender = gender
end

function ChatObject:setSocietySystemMsg(bType)
	self.bSocietySystemMsg = bType
end

function ChatObject:isSocietySystemMsg()
	return self.bSocietySystemMsg
end

----------一下使物品展示或者公告消息--
function ChatObject:setHyperLinkFlag(bool)
	self.hyperLinkFlag = bool
end

function ChatObject:isContainHyperLink()
	return self.hyperLinkFlag
end

function ChatObject:getPlayerName()
	return self.playerName
end

function ChatObject:setPlayerName(name)
	self.playerName = name
end

function ChatObject:getPlayerId()
	return self.playerId
end

function ChatObject:setPlayerId(id)
	self.playerId = id
end
function ChatObject:getSceneName()
	return self.sceneName
end

function ChatObject:setSceneName(sceneName)
	self.sceneName = sceneName
end

function ChatObject:getSceneId()
	return self.sceneId
end

function ChatObject:setVipLevel(vipLevel)
	self.vipLevel = vipLevel
end

function ChatObject:getVipLevel()
	return self.vipLevel
end

function ChatObject:setReceiverVipLevel(vipLevel)
	self.recvVipLevel = vipLevel
end

function ChatObject:getReceiverVipLevel()
	return self.recvVipLevel
end


function ChatObject:setSceneId(sceneId)
	self.sceneId = sceneId
end

function ChatObject:setGoodsName(goodsName)
	self.goodsName  = goodsName
end

function ChatObject:getGoodsName()
	return self.goodsName
end

function ChatObject:setGoodsId(goodsId)
	self.goodsId  = goodsId
end

function ChatObject:getGoodsId()
	return self.goodsId
end

function ChatObject:setSysMsg(sysMsg)
	self.sysMsgTable = sysMsg
end

function ChatObject:getSysMsg()
	return self.sysMsgTable
end

function ChatObject:setSubType(ttype)
	self.subType = ttype
end

function ChatObject:getSubType()
	return self.subType
end