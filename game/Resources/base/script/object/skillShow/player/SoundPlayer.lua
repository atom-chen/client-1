--[[
播放一个音效
]]

require "object.skillShow.player.AnimatePlayer"

SoundPlayer = SoundPlayer or BaseClass(AnimatePlayer)

function SoundPlayer:__init()
	self.name = "SoundPlayer"
	self.soundName = ""
end

function SoundPlayer:__delete()

end

function SoundPlayer:setSoundName(name)
	self.soundName = name
end

function SoundPlayer:doPlay()
	if self.soundName and self.soundName ~= "" then
		local soundMgr = GameWorld.Instance:getSoundMgr()
		soundMgr:playEffect("music/"..self.soundName..".mp3")
	end
	
	self.state = AnimatePlayerState.AnimatePlayerStateFinish
end