require("common.baseclass")
require("common.BaseObj")

ArenaObject = ArenaObject or BaseClass(BaseObj)

function ArenaObject:__init()
	self.heroInfoArea = {
		rank = nil,
		victoryCnt = nil,
		leftChallengeCnt = nil
	}
	self.prizeArea = {
		rewardRank = nil,
		gold = nil,
		exploit = nil,
		leftTime = nil
	}
	self.noticeBoardArea = {
		noticeType = 2,
		[1] = {playerName = nil},
		[2] = {playerAName = nil, playerBName = nil},
		[3] = {playerName = nil, raiseRank = nil}
	}
	self.challengeTargetArea = {
		member = {
--[[		[1] = {id = 1,profession = 1, rank = 33, name = "他", level = 31, fighting = 12000},
			[2] = {id = 1,profession = 2, rank = 32, name = "六字不能更长", level = 33, fighting = 14100},
			[3] = {id = 1,profession = 3, rank = 31, name = "六字长", level = 33, fighting = 15020},
			[4] = {id = 1,profession = 4, rank = 30, name = "六字不能", level = 33, fighting = 13020},
			[5] = {id = 1,profession = 5, rank = 29, name = "六字更长", level = 33, fighting = 13000}--]]
		},
		cdTime = nil
	}
	self.fightingRecordArea = {	
		record = {
--[[		[1] = {isActive = 0, targetName = "他", fightingResult = 1, rankChange = -2},
			[2] = {isActive = 1, targetName = "六字不能更长", fightingResult = 0, rankChange = -1},
			[3] = {isActive = 0, targetName = "六字长", fightingResult = 1, rankChange = 0},
			[4] = {isActive = 1, targetName = "六字不能", fightingResult = 0, rankChange = 1},
			[5] = {isActive = 0, targetName = "六字更长", fightingResult = 1, rankChange = 2}--]]
		}
	}
	self.ladderRankList = {
--[[		[1] = {rank = nil, nickName = nil, profesion = nil, level = nil, fighting = nil, guild = nil, trend = nil},
		[2] = {rank = nil, nickName = nil, profesion = nil, level = nil, fighting = nil, guild = nil, trend = nil},
		[50] = {rank = nil, nickName = nil, profesion = nil, level = nil, fighting = nil, guild = nil, trend = nil},--]]
	}		
end	

function ArenaObject:getLeftChallengeCnt()
	return self.heroInfoArea.leftChallengeCnt
end

function ArenaObject:__delete()
	
end
