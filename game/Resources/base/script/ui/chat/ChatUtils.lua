ChatUtils = ChatUtils or BaseClass()


-- Generic for iterator.
--
-- Arguments:
--     s ... The utf8 string.
--     i ... Last byte of the previous codepoint.
--
-- Returns:
--     k ... Number of the *last* byte of the codepoint.
--     c ... The utf8 codepoint (character).
--     n ... Width/number of bytes of the codepoint.
local function iter(s, i)
	if i >= #s then return end
	local b, nbytes = s:byte(i+1,i+1), 1

	-- determine width of the codepoint by counting the number of set bits in the first byte
	-- warning: there is no validation of the following bytes!
	if     b >= 0xc0 and b <= 0xdf then nbytes = 2 -- 1100 0000 to 1101 1111
	elseif b >= 0xe0 and b <= 0xef then nbytes = 3 -- 1110 0000 to 1110 1111
	elseif b >= 0xf0 and b <= 0xf7 then nbytes = 4 -- 1111 0000 to 1111 0111
	elseif b >= 0xf8 and b <= 0xfb then nbytes = 5 -- 1111 1000 to 1111 1011
	elseif b >= 0xfc and b <= 0xfd then nbytes = 6 -- 1111 1100 to 1111 1101
	elseif b <  0x00 or  b >  0x7f then error(("Invalid codepoint: 0x%02x"):format(b))
	end
	return i+nbytes, s:sub(i+1,i+nbytes), nbytes
end

-- Shortcut to the generic for iterator.
--
-- Usage:
--    for k, c, n in chars(s) do
--        ...
--    end
--
--    Meaning of k, c, and n is the same as in iter(s, i).
local function chars(s)
	return iter, s, 0
end

-- Get length in characters of an utf8 string.
--
-- Arguments:
--     s ... The utf8 string.
--
-- Returns:
--     n ... Number of utf8 characters in s.
local function len(s)
	-- assumes sane utf8 string: count the number of bytes that is *not* 10xxxxxx
	local _, c = s:gsub('[^\128-\191]', '')
	return c
end

-- Get substring, same semantics as string.sub(s,i,j).
--
-- Arguments:
--     s ... The utf8 string.
--     i ... Starting position, may be negative.
--     j ... (optional) Ending position, may be negative.
--
-- Returns:
--     t ... The substring.
local function sub(s, i, j)
	local l = len(s)
	j = j or l
	if i < 0 then i = l + i + 1 end
	if j < 0 then j = l + j + 1 end
	if j < i then return '' end

	local k, t = 1, {}
	for _, c in chars(s) do
		if k >= i then t[#t+1] = c end
		if k >= j then break end
		k = k + 1
	end
	return table.concat(t)
end

-- Split utf8 string in two substrings
--
-- Arguments:
--     s ... The utf8 string.
--     i ... The position to split, may be negative.
--
-- Returns:
--     left  ... Substring before i.
--     right ... Substring after i.
local function split(s, i)
	local l = len(s)
	if i < 0 then i = l + i + 1 end

	local k, pos = 1, 0
	for byte in chars(s) do
		if k > i then break end
		pos, k = byte, k + 1
	end
	return s:sub(1, pos), s:sub(pos+1, -1)
end

-- Reverses order of characters in an utf8 string.
--
-- Arguments:
--     s ... The utf8 string.
--
-- Returns:
--     t ... The revered string.
local function reverse(s)
	local t = {}
	for _, c in chars(s) do
		table.insert(t, 1, c)
	end
	return table.concat(t)
end

-- Convert a Unicode code point to a UTF-8 byte sequence
-- Logic stolen from this page:
-- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
--
-- Arguments:
--     Number representing the Unicode code point (e.g. 0x265c).
--
-- Returns:
--     UTF-8 encoded string of the given character.
--     Numbers out of range produce a blank string.
local function encode(code)
	if code < 0 then
		error('Code point must not be negative.')
	elseif code <= 0x7f then
		return string.char(code)
	elseif code <= 0x7ff then
		local c1 = code / 64 + 192
		local c2 = code % 64 + 128
		return string.char(c1, c2)
	elseif code <= 0xffff then
		local c1 = code / 4096 + 224
		local c2 = code % 4096 / 64 + 128
		local c3 = code % 64 + 128
		return string.char(c1, c2, c3)
	elseif code <= 0x10ffff then
		local c1 = code / 262144 + 240
		local c2 = code % 262144 / 4096 + 128
		local c3 = code % 4096 / 64 + 128
		local c4 = code % 64 + 128
		return string.char(c1, c2, c3, c4)
	end
	return ''
end

function ChatUtils:__init(chatMgr)
	ChatUtils.Instance = self
	self.chatMgr = chatMgr
end


function ChatUtils:trim (s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

--获取聊天类型的文本 如[当前][公会]
function ChatUtils:getChatTypeText(objectType)
	local text = ""
	local words = ""
	
	local typeColor = ChatColor[objectType]
	if objectType == ChatObjectTypes.World then
		words = Config.Words[401]
	elseif objectType == ChatObjectTypes.Current then
		words = Config.Words[402]
	elseif objectType == ChatObjectTypes.Society then
		words = Config.Words[403]
	elseif objectType == ChatObjectTypes.Private then
		words = Config.Words[404]
	elseif  objectType == ChatObjectTypes.System then
		words = Config.Words[405]
	elseif objectType == ChatObjectTypes.Horn then
		words = Config.Words[411]
	end
	if typeColor then
		text = string.wrapRich(words, typeColor)
	end
	return text
end

--是否加入公会
function ChatUtils:isJoinSociety(bShowTips)
	local result = false
	if PropertyDictionary:get_unionName(G_getHero():getPT()) == "" then
		if bShowTips then
			UIManager.Instance:showSystemTips(Config.Words[450])
		end
		result = false
	else
		result = true
	end
	return result
end

--获取当前时间
function ChatUtils:getFormatTime(time)
	if time <= 0 then
		return
	end
	local myTime = time/1000
	local tab = os.date("*t", myTime)
	local timeFormate = string.format("%02d", tab.hour) .. ":" .. string.format("%02d", tab.min) .. ":" .. string.format("%02d", tab.sec)
	local alignment = "right"
	local str = "<alignment ".."type='"..alignment.."'>"..timeFormate.."</alignment>"
	return str
end


--展示物品详情
function ChatUtils:showItemDetails(item)
	if (item) then
		local arg = ItemDetailArg.New()
		arg:setItem(item)
		
		if (item:getType() == ItemType.eItemEquip) then
			arg:setBtnArray({})
			if PropertyDictionary:get_fightValue(item:getPT()) == 0 then
				local pt = {}	
				pt["fightValue"] = 0
				item:updatePT(pt)						
				local fightValue = G_getEquipFightValue(item:getRefId())
				if fightValue then
					item:updatePT({fightValue = fightValue})	
				end						
			end
			GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
		else
			arg:setBtnArray({})
			GlobalEventSystem:Fire(GameEvent.EventOpenNormalItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
		end
		arg:DeleteMe()
	end
end

--展示装备
function ChatUtils:showEquipItemDetails(equipObj)
	if equipObj then
		local arg = ItemDetailArg.New()
		arg:setItem(equipObj)
		arg:setIsShowFpTips(false)
		arg:setBtnArray({})
		GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMiddle, arg)
		arg:DeleteMe()
	end
end

--@line=="true" 发送者名字显示下划线
function ChatUtils:constructRichStringById(id, line)
	local text = ""
	local object = self.chatMgr:getObjectById(id)
	if object == nil then
		return ""
	end
	local objectType = object:getType()
	local senderName = object:getSenderName()
	local senderId = object:getSenderId()
	local content = object:getContent()	
	local gender = object:getGender()
	local vipLevel = object:getVipLevel()
	
	local vipSpriteName = self:getVipName(vipLevel, id)	
	
	local typeText = self:getChatTypeText(objectType)
	--系统的公会消息单独处理，要显示[系统]而不是[公会]
	if objectType == ChatObjectTypes.Society and object:isSocietySystemMsg()==true then
		typeText = self:getChatTypeText(ChatObjectTypes.System)
	end
	
	local nameText = ""
	if senderName ~= nil then
		nameText = self:getSenderNameText(senderName, tostring(id), gender, line)
		nameText = vipSpriteName ..  nameText
	end
	if object:isContainHyperLink() == true then  --content含有超链接
		local playerName = object:getPlayerName()
		local sceneName = object:getSceneName()
		local goodsName = object:getGoodsName()
		local bossName = nil
		local linkName = nil
		local pName, sName, gName ,bName ,lName
		--系统消息可能存在多个玩家名， 场景
		if objectType == ChatObjectTypes.System then
			local playerCnt, sceneCnt, goodsCnt ,bossCnt ,linkCnt= 1, 1, 1 ,1, 1
			local sysMsgTable = object:getSysMsg()
			playerCnt = table.size(sysMsgTable.playerInfo)
			sceneCnt = table.size(sysMsgTable.sceneInfo)
			goodsCnt = table.size(sysMsgTable.goodsInfo)
			bossCnt = table.size(sysMsgTable.bossInfo)
			linkCnt = table.size(sysMsgTable.linkInfo)
			for i=1, playerCnt do
				if sysMsgTable.playerInfo[i].playerName then
					playerName = self:replaceBrackets(sysMsgTable.playerInfo[i].playerName)
					local genderColor = Config.FontColor["ColorBlue2"]
					if sysMsgTable.playerInfo[i].gender then
						if tonumber(sysMsgTable.playerInfo[i].gender) == 2 then
							genderColor = Config.FontColor["ColorPink1"]
						end
					end
					pName = string.wrapHyperLinkRich(playerName, genderColor, nil, "p".."id="..tostring(sysMsgTable.playerInfo[i].id).."name="..sysMsgTable.playerInfo[i].playerName, "true")
					content = string.gsub(content, playerName, pName)
				end
			end
			for i=1, sceneCnt do
				if sysMsgTable.sceneInfo[i].sceneName then
					sceneName = self:replaceBrackets(sysMsgTable.sceneInfo[i].sceneName)
					sName = string.wrapHyperLinkRich(sceneName, Config.FontColor["ColorYellow2"], nil, "s".."id="..tostring(sysMsgTable.sceneInfo[i].id).."name="..sysMsgTable.sceneInfo[i].sceneName, "true")
					content = string.gsub(content, sceneName, sName)
				end
			end
			for i=1, goodsCnt do
				if sysMsgTable.goodsInfo[i].goodsName then
					goodsName = self:replaceBrackets(sysMsgTable.goodsInfo[i].goodsName)
					gName = string.wrapHyperLinkRich(goodsName, Config.FontColor["ColorPurple1"], nil, "g".."id="..tostring(sysMsgTable.goodsInfo[i].id).."name="..sysMsgTable.goodsInfo[i].goodsName, "true")
					content = string.gsub(content, goodsName, gName)
				end
			end
			for i=1, bossCnt do
				if sysMsgTable.bossInfo[i].bossName then
					bossName = self:replaceBrackets(sysMsgTable.bossInfo[i].bossName)
					bName = string.wrapHyperLinkRich(bossName, Config.FontColor["ColorRed1"], nil, "m".."id="..tostring(sysMsgTable.bossInfo[i].id).."name="..sysMsgTable.bossInfo[i].bossName, "true")
					content = string.gsub(content, bossName, bName)
				end
			end
			for i=1, linkCnt do
				if sysMsgTable.linkInfo[i].linkName then
					linkName = self:replaceBrackets(sysMsgTable.linkInfo[i].linkName)
					lName = string.wrapHyperLinkRich(linkName, Config.FontColor["ColorGreen1"], nil, "l".."id="..tostring(sysMsgTable.linkInfo[i].id).."name="..sysMsgTable.linkInfo[i].linkName, "true")
					content = string.gsub(content, linkName, lName)
				end
			end
		elseif objectType == ChatObjectTypes.Society and object:getSubType() and object:getSubType() == ChatObjectTypes.SytSociety then
			if playerName ~= nil then
				playerName = self:replaceBrackets(playerName)				
				pName = string.wrapHyperLinkRich(playerName, Config.FontColor["ColorBlue2"], nil, "p".."id="..tostring(object:getPlayerId()).."name="..object:getPlayerName(), "true")
				content = string.gsub(content, playerName, pName)
			end				
		else
			if playerName ~= nil then
				playerName = self:replaceBrackets(playerName)
				pName = string.wrapHyperLinkRich(playerName, Config.FontColor["ColorBlue2"], nil, "p"..tostring(id), "true")
				content = string.gsub(content, playerName, pName)
			end
			if sceneName ~= nil then
				sceneName = self:replaceBrackets(sceneName)
				sName = string.wrapHyperLinkRich(sceneName, Config.FontColor["ColorYellow2"], nil, "s"..tostring(id), "true")
				content = string.gsub(content, sceneName, sName)
			end
			if goodsName ~= nil then
				goodsName = self:replaceBrackets(goodsName)
				gName = string.wrapHyperLinkRich(goodsName, Config.FontColor["ColorPurple1"], nil, "g"..tostring(id), "true")
				content = string.gsub(content, goodsName, gName)
			end
		end
	end
	
	text = typeText .. nameText .. content .. "\n"
	if objectType == ChatObjectTypes.Private then	
		local recvName = object:getReceiverName()
		local myName = self.chatMgr:getHeroName()
		if senderName == myName then 
			local recvGender = object:getReceiverGender()
			nameText = self:getSenderNameText(recvName, tostring(id), recvGender, line)
			local recvVipName = self:getVipName(object:getReceiverVipLevel(), id)
			if nameText then
				text = typeText.. Config.Words[407] .. recvVipName..nameText .. content .. "\n"
			end
		end									
	end
	return text
end

function ChatUtils:getVipName(vipLevel, id)
	if vipLevel > 0 then
		local vipfileName
		if vipLevel == 1 then
			vipfileName = "copperVipChat.png"
		elseif vipLevel == 2 then
			vipfileName = "sliverVipChat.png"
		elseif vipLevel == 3 then
			vipfileName = "goldVipChat.png"
		end
		local vipSpriteName = string.wrapHyperImgLinkRich(RES(vipfileName), nil, nil, "v".. tonumber(id))
		return vipSpriteName
	end
	return ""
end

--获取发送者的名称
function ChatUtils:getSenderNameText(name, senderId, gender, line)
	local color = ""
	if name and senderId and gender then	
		if gender == 1 then   --男
			color = Config.FontColor["ColorBlue1"]
		else   --女
			color = Config.FontColor["ColorPink1"]
		end			
		if line == "true" then
			name = string.wrapHyperLinkRich(name, color, FSIZE("Size4"), "n"..senderId, "true")
		else
			name = string.wrapRich(name, color, FSIZE("Size4"))
		end
		if name then
			name = name..Config.Words[406]
		end
		return name
	end
end

--用单引号替换括号
function ChatUtils:replaceBrackets(str)
	local ret = ""
	str = string.gsub(str, "%(", "'")
	ret = string.gsub(str, "%)", "'")
	return ret
end

--检测是否与自己聊天
function ChatUtils:checkChat2Myself(id)
	local myselfName = self.chatMgr:getHeroName()
	local object = self.chatMgr:getObjectById(tonumber(id))
	if object then
		local senderName = object:getSenderName()
		if senderName == myselfName then
			return true
		end
	end
	
	return false
end

function ChatUtils:addHyperLinkMark(msg)
	local retVal = "{__{"..msg.."}__}" --加上这两个字符串，区分是否有物品解析
	return retVal
end

function ChatUtils:isContainMark(content)
	local head = string.sub(content, 1, 4)
	local tail = string.sub(content, -4, -1)
	if head == "{__{" and tail == "}__}" then
		return true
	end
	return false
end

function ChatUtils:getRealContent(content)
	local retVal = string.sub(content, 5, -5)
	return retVal
end


function ChatUtils:msgParser(chatObject, str)
	local sysMsgTable = {playerInfo={}, sceneInfo={}, goodsInfo={} , bossInfo = {} ,linkInfo = {}}
	local playerCnt, sceneCnt, goodsCnt , bossCnt ,linkCnt= 0, 0, 0 , 0 , 0
	local str1 = str
	self.cnt = 1  --这个变量防止一直在循环退不出来
	repeat
		self.cnt = self.cnt + 1
		if self.cnt > 50 then
			break
		end
		local name, id, ttype, gender
		local str2 = str1
		str1, name, id, ttype, gender = self:parseString(str1)
		if str1 ~= str2 then
			if chatObject then
				chatObject:setHyperLinkFlag(true)
				if name and id and ttype then
					if chatObject:getType() == ChatObjectTypes.System then --系统消息要特殊处理一下，因为可以存在多个玩家名
						if ttype == "p" then
							playerCnt = playerCnt + 1
							sysMsgTable.playerInfo[playerCnt] = {}
							sysMsgTable.playerInfo[playerCnt].playerName = name
							sysMsgTable.playerInfo[playerCnt].id = id
							sysMsgTable.playerInfo[playerCnt].gender = gender
						elseif ttype == "s" then
							sceneCnt = sceneCnt + 1
							sysMsgTable.sceneInfo[sceneCnt] = {}
							sysMsgTable.sceneInfo[sceneCnt].sceneName = name
							sysMsgTable.sceneInfo[sceneCnt].id = id
						elseif ttype == "g" then
							goodsCnt = goodsCnt + 1
							sysMsgTable.goodsInfo[goodsCnt] = {}
							sysMsgTable.goodsInfo[goodsCnt].goodsName = name
							sysMsgTable.goodsInfo[goodsCnt].id = id
						elseif ttype == "m" then
							bossCnt = bossCnt + 1
							sysMsgTable.bossInfo[bossCnt] = {}
							sysMsgTable.bossInfo[bossCnt].bossName = name
							sysMsgTable.bossInfo[bossCnt].id = id
						elseif ttype == "l" then
							linkCnt = linkCnt + 1
							sysMsgTable.linkInfo[linkCnt] = {}
							sysMsgTable.linkInfo[linkCnt].linkName = name
							sysMsgTable.linkInfo[linkCnt].id = id
						end
					else
						if ttype == "p" then --玩家
							chatObject:setPlayerName(name)
							chatObject:setPlayerId(id)
						elseif ttype == "s" then  --场景
							chatObject:setSceneName(name)
							chatObject:setSceneId(id)
						elseif ttype == "g" then   --物品
							chatObject:setGoodsName(name)
							chatObject:setGoodsId(id)
						end
					end
				end
			end
		else
			break
		end
	until string.match(str1,"{.-}") == nil
	if chatObject:getType() == ChatObjectTypes.System then
		chatObject:setSysMsg(sysMsgTable)
	end
	return str1
end

function ChatUtils:parseString(str)
	local object = string.match(str,"{.-}")
	local tmpStr = ""
	local ttype = ""
	local name = ""
	local id = ""
	local gender = 1
	--{p=23446gtg,<7d661dbc-0220-4f27-9e00-f92df52b4806>,<x=1>}鸿运当头，在{s=
	if object ~= nil then
		tmpStr  = string.match(object, "{.-=")
		if tmpStr then
			ttype = string.sub(tmpStr, 2, 2)
		end
		tmpStr = string.match(object, "=.-<")
		if tmpStr then
			name =  string.sub(tmpStr, 2, -2)
		end
		tmpStr = string.match(object, "<.->")
		if tmpStr then
			id = string.sub(tmpStr, 2, -2)
		end
		tmpStr = string.gsub(object, "<.->", "", 1)
		tmpStr = string.match(tmpStr, "<.->")
		if tmpStr then
			gender = string.sub(tmpStr, 2, -2)
		end
		if name~="" then
			local strStart, strEnd = string.find(str, "{.-}")		
			head = string.sub(str, 1, strStart-1) 	
			tail = string.sub(str, strEnd+1, -1)			
			str = head.. name .. tail			
		end
		return str,name,id, ttype, gender
	end
	return str
end

--todo 性能不高有空优化，用的是Levenshtein distance
--有兴趣的可以看看 addby zhanxianbo
function ChatUtils:getSimilarity(str1,str2)
	local lens1 = 0
	local lens2 = 0
	if str1 then
		lens1 = len(str1)		
	end
	
	if str2 then
		lens2 = len(str2)
	end
	
	if lens1 == 0 or lens2 == 0 then
		return 0
	end
	local list1 = {}
	for k,c,n in chars(str1) do
		table.insert(list1,c)		
	end
	
	local list2 = {}
	for k,c,n in chars(str2) do
		table.insert(list2,c)	
	end
	
	local result = {}
	for r=1,lens1+1 do
		result[r] = {}			
	end
	
	for r=1,lens1+1 do
		for c=1,lens2+1 do
			result[r][c] = 0
		end
	end
	
	for r=1,lens1+1 do
		result[r][1] = r-1			
	end
	
	for c=1,lens2+1 do
		result[1][c] = c-1		
	end
	
	local temp 
	for r=2,lens1+1 do
		for c=2,lens2+1 do		
			local str1Char = list1[r-1]			
			local str2Char = list2[c-1]
			if string.byte(str1Char) == string.byte(str2Char) then
				temp = 0
			else
				temp = 1
			end
			result[r][c] = math.min(result[r-1][c-1]+temp, result[r][c-1]+1, result[r-1][c]+1)
		end
	end
	local similarity = 1 - result[lens1+1][lens2+1] / math.max(lens1, lens2)
	return similarity
end

