require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require ("data.code")

ArenaActionHandler = ArenaActionHandler or BaseClass(ActionEventHandler)

function ArenaActionHandler:__init()
	local handlerCanReceive = function(reader)
		reader = tolua.cast(reader,"iBinaryReader")
		local canReceive = StreamDataAdapter:ReadChar(reader)
		GlobalEventSystem:Fire(GameEvent.EventHandleCanReceive,canReceive)
	end
	
	local handlerShowArenaView = function(reader)
 		local ArenaMgr = GameWorld.Instance:getArenaMgr()
		local arenaObject = ArenaMgr:getArenaObject()
		reader = tolua.cast(reader,"iBinaryReader")	
		-- 公告栏信息
		local noticeType = StreamDataAdapter:ReadChar(reader)
		if noticeType == 1 then
			arenaObject.noticeBoardArea[noticeType].playerName = StreamDataAdapter:ReadStr(reader)
		elseif noticeType == 2 then
			arenaObject.noticeBoardArea[noticeType].playerAName = StreamDataAdapter:ReadStr(reader)
			arenaObject.noticeBoardArea[noticeType].playerBName = StreamDataAdapter:ReadStr(reader)
		elseif noticeType == 3 then
			arenaObject.noticeBoardArea[noticeType].playerName = StreamDataAdapter:ReadStr(reader)
			arenaObject.noticeBoardArea[noticeType].raiseRank = StreamDataAdapter:ReadInt(reader)
		end
		arenaObject.noticeBoardArea.noticeType = noticeType
		-- 挑战目标
		local challengeTargetCount = StreamDataAdapter:ReadChar(reader)
		arenaObject.challengeTargetArea.member = {}
		for i = 1,challengeTargetCount do
			arenaObject.challengeTargetArea.member[i] = {}
			arenaObject.challengeTargetArea.member[i].profession = StreamDataAdapter:ReadChar(reader)
			arenaObject.challengeTargetArea.member[i].gender = StreamDataAdapter:ReadChar(reader)
			arenaObject.challengeTargetArea.member[i].rank = StreamDataAdapter:ReadInt(reader)
			arenaObject.challengeTargetArea.member[i].name = StreamDataAdapter:ReadStr(reader)
			arenaObject.challengeTargetArea.member[i].level = StreamDataAdapter:ReadShort(reader) --int->short
			arenaObject.challengeTargetArea.member[i].fighting = StreamDataAdapter:ReadInt(reader)
		end
		-- 战斗记录
		local fightingRecordCount = StreamDataAdapter:ReadChar(reader)  --int->byte
		arenaObject.fightingRecordArea.record = {}
		for i = 1,fightingRecordCount do
			arenaObject.fightingRecordArea.record[i] = {}
			arenaObject.fightingRecordArea.record[i].isAction = StreamDataAdapter:ReadChar(reader)
			arenaObject.fightingRecordArea.record[i].targetName = StreamDataAdapter:ReadStr(reader)
			arenaObject.fightingRecordArea.record[i].fightingResult = StreamDataAdapter:ReadChar(reader)
			arenaObject.fightingRecordArea.record[i].rankChange = StreamDataAdapter:ReadInt(reader)
		end		
		-- 人物信息
		arenaObject.heroInfoArea.rank = StreamDataAdapter:ReadInt(reader)
		arenaObject.heroInfoArea.victoryCnt = StreamDataAdapter:ReadShort(reader)--int->short
		arenaObject.heroInfoArea.leftChallengeCnt = StreamDataAdapter:ReadShort(reader)--int->short
		-- 领取剩余时间
		arenaObject.prizeArea.rewardRank = StreamDataAdapter:ReadInt(reader)
		arenaObject.prizeArea.leftTime = StreamDataAdapter:ReadInt(reader)
		arenaObject.prizeArea.gold = StreamDataAdapter:ReadInt(reader)
		arenaObject.prizeArea.exploit = StreamDataAdapter:ReadInt(reader)
		-- 挑战剩余时间
		arenaObject.challengeTargetArea.cdTime = StreamDataAdapter:ReadInt(reader)
		
		local strongerMgr = GameWorld.Instance:getStrongerMgr()
		if strongerMgr:canOpenVewByStronger() then--我要变强中会请求数据但不立即打开界面
			GlobalEventSystem:Fire(GameEvent.EventShowArenaView)
		end			
		
		GameWorld.Instance:getStrongerMgr():setReady(StrongerChannel.Arena)
	end
	
	local handlerUpadateNotice = function(reader)
		local ArenaMgr = GameWorld.Instance:getArenaMgr()
		local arenaObject = ArenaMgr:getArenaObject()
		reader = tolua.cast(reader,"iBinaryReader")	
		
		local noticeType = StreamDataAdapter:ReadChar(reader)
		if noticeType == 1 then
			arenaObject.noticeBoardArea[noticeType].playerName = StreamDataAdapter:ReadStr(reader)
		elseif noticeType == 2 then
			arenaObject.noticeBoardArea[noticeType].playerAName = StreamDataAdapter:ReadStr(reader)
			arenaObject.noticeBoardArea[noticeType].playerBName = StreamDataAdapter:ReadStr(reader)
		elseif noticeType == 3 then
			arenaObject.noticeBoardArea[noticeType].playerName = StreamDataAdapter:ReadStr(reader)
			arenaObject.noticeBoardArea[noticeType].raiseRank = StreamDataAdapter:ReadInt(reader)
		end
		arenaObject.noticeBoardArea.noticeType = noticeType
		GlobalEventSystem:Fire(GameEvent.EventUpdateNoticeBoardArea)
	end
	
	local handlerUpadateChallengeTarget = function(reader)
		local ArenaMgr = GameWorld.Instance:getArenaMgr()
		local arenaObject = ArenaMgr:getArenaObject()
		reader = tolua.cast(reader,"iBinaryReader")	
		arenaObject.challengeTargetArea.member = {}
		local count = StreamDataAdapter:ReadChar(reader) --short->byte
		for i = 1,count do		
			arenaObject.challengeTargetArea.member[i] = {}
			arenaObject.challengeTargetArea.member[i].profession = StreamDataAdapter:ReadChar(reader)
			arenaObject.challengeTargetArea.member[i].gender = StreamDataAdapter:ReadChar(reader)
			arenaObject.challengeTargetArea.member[i].rank = StreamDataAdapter:ReadInt(reader)
			arenaObject.challengeTargetArea.member[i].name = StreamDataAdapter:ReadStr(reader)
			arenaObject.challengeTargetArea.member[i].level = StreamDataAdapter:ReadShort(reader)  --int->short
			arenaObject.challengeTargetArea.member[i].fighting = StreamDataAdapter:ReadInt(reader)
			--print("arenaObject.challengeTargetArea.member[i].rank ".. i .."  :" .. arenaObject.challengeTargetArea.member[i].rank)
		end
		GlobalEventSystem:Fire(GameEvent.EventUpdateChallengeTargetArea)
	end
	
	local handlerUpadateFightRecord = function(reader)	
		reader = tolua.cast(reader,"iBinaryReader")	
		local isAction = StreamDataAdapter:ReadChar(reader)
		local targetName = StreamDataAdapter:ReadStr(reader)
		local fightingResult = StreamDataAdapter:ReadChar(reader)
		local rankChange = StreamDataAdapter:ReadInt(reader)
		
		local temprecord = {
			isAction = isAction,
			targetName = targetName,
			fightingResult = fightingResult,
			rankChange = rankChange,
		}
			
		local ArenaMgr = GameWorld.Instance:getArenaMgr()
		local arenaObject = ArenaMgr:getArenaObject()	
		if arenaObject then		
			table.insert(arenaObject.fightingRecordArea.record,1,temprecord)
			local recordCount = table.getn(arenaObject.fightingRecordArea.record)
			if recordCount>5 then
				for i = 6,recordCount do
					table.remove(arenaObject.fightingRecordArea.record,i)
				end
			end
			GlobalEventSystem:Fire(GameEvent.EventUpdateFightingRecordArea)
		end
	end
	
	local handlerUpadateHeroInfo = function(reader)
		local ArenaMgr = GameWorld.Instance:getArenaMgr()
		local arenaObject = ArenaMgr:getArenaObject()
		reader = tolua.cast(reader,"iBinaryReader")
		
		arenaObject.heroInfoArea.rank = StreamDataAdapter:ReadInt(reader)
		arenaObject.heroInfoArea.victoryCnt = StreamDataAdapter:ReadShort(reader)
		arenaObject.heroInfoArea.leftChallengeCnt = StreamDataAdapter:ReadShort(reader)			
		GlobalEventSystem:Fire(GameEvent.EventUpdateHeroInfoArea)
		--print("arenaObject.heroInfoArea.rank " .. arenaObject.heroInfoArea.rank)
	end
	
	local handlerReceiveRewardTime = function(reader)
		local ArenaMgr = GameWorld.Instance:getArenaMgr()
		local arenaObject = ArenaMgr:getArenaObject()
		reader = tolua.cast(reader,"iBinaryReader")
		
		arenaObject.prizeArea.rewardRank = StreamDataAdapter:ReadInt(reader)
		arenaObject.prizeArea.leftTime = StreamDataAdapter:ReadInt(reader)
		arenaObject.prizeArea.gold = StreamDataAdapter:ReadInt(reader)
		arenaObject.prizeArea.exploit = StreamDataAdapter:ReadInt(reader)
		GlobalEventSystem:Fire(GameEvent.EventUpdateReceiveRewardTime)
	end

	local handlerChallengeCDTime = function(reader)
		local ArenaMgr = GameWorld.Instance:getArenaMgr()
		local arenaObject = ArenaMgr:getArenaObject()
		reader = tolua.cast(reader,"iBinaryReader")
		
		arenaObject.challengeTargetArea.cdTime = StreamDataAdapter:ReadInt(reader)
		GlobalEventSystem:Fire(GameEvent.EventUpdateChallengeCDTime)
	end	
	
	local handlerChallenge = function(reader)
		local ArenaMgr = GameWorld.Instance:getArenaMgr()
		local arenaObject = ArenaMgr:getArenaObject()
		reader = tolua.cast(reader,"iBinaryReader")
		local fightArg = {}
		fightArg.fightingResult = StreamDataAdapter:ReadChar(reader)
		fightArg.gold = StreamDataAdapter:ReadInt(reader)
		fightArg.exploit = StreamDataAdapter:ReadInt(reader)
		fightArg.heroFighting = StreamDataAdapter:ReadInt(reader)
		fightArg.otherHeroFighting = StreamDataAdapter:ReadInt(reader)
		local dataLenght = StreamDataAdapter:ReadInt(reader)
		if dataLenght then
			fightArg.otherHeroPT = getPropertyTable(reader)			
		end
		GlobalEventSystem:Fire(GameEvent.EventFighting,fightArg)
	end	
	
	local handlerLadder = function(reader)
		local ArenaMgr = GameWorld.Instance:getArenaMgr()
		local arenaObject = ArenaMgr:getArenaObject()
		reader = tolua.cast(reader,"iBinaryReader")
		
		local ladderMemberNum = StreamDataAdapter:ReadChar(reader)	--short->byte
		for i = 1,ladderMemberNum do		
			arenaObject.ladderRankList[i] = {}			
			arenaObject.ladderRankList[i].rank = StreamDataAdapter:ReadChar(reader)--int->byte
			arenaObject.ladderRankList[i].gender = StreamDataAdapter:ReadChar(reader)
			arenaObject.ladderRankList[i].nickName = StreamDataAdapter:ReadStr(reader)
			arenaObject.ladderRankList[i].profesion = StreamDataAdapter:ReadChar(reader)
			arenaObject.ladderRankList[i].level = StreamDataAdapter:ReadShort(reader) --int ->short
			arenaObject.ladderRankList[i].fighting = StreamDataAdapter:ReadInt(reader)
			arenaObject.ladderRankList[i].guild = StreamDataAdapter:ReadStr(reader)
			arenaObject.ladderRankList[i].trend = StreamDataAdapter:ReadChar(reader)
		end
		GlobalEventSystem:Fire(GameEvent.EventShowLadderView)
	end
	
	self:Bind(ActionEvents.G2C_Arena_CanReceive,handlerCanReceive)	
	self:Bind(ActionEvents.G2C_Arena_ShowArenaView,handlerShowArenaView)	
	self:Bind(ActionEvents.G2C_Arena_UpadateNotice,handlerUpadateNotice)	
	self:Bind(ActionEvents.G2C_Arena_UpadateChallengeTarget,handlerUpadateChallengeTarget)
	self:Bind(ActionEvents.G2C_Arena_UpadateFightRecord,handlerUpadateFightRecord)	
	self:Bind(ActionEvents.G2C_Arena_UpadateHeroInfo,handlerUpadateHeroInfo)
	self:Bind(ActionEvents.G2C_Arena_UpdateReceiveRewardTime,handlerReceiveRewardTime)	
	self:Bind(ActionEvents.G2C_Arena_UpdateChallengeCDTime,handlerChallengeCDTime)
	self:Bind(ActionEvents.G2C_Arena_Challenge,handlerChallenge)
	self:Bind(ActionEvents.G2C_Ladder_Select,handlerLadder)
	
end	

function ArenaActionHandler:__delete()
	
end	