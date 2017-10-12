SoundManager = SoundManager or BaseClass()

function SoundManager:__init()
	self.playingMusicFile = nil
	self.musicVoice = 1
	self.effectVoice = 1	
	self:preLoadEffect()
end	

function SoundManager:clear()
	self.playingMusicFile = nil
	self.musicVoice = 1
	self.effectVoice = 1	
	self:unLoadEffect()
end	

function SoundManager:__delete()
	self:unLoadEffect()
end 

function SoundManager:playEffect(musicfile)
	if self.effectVoice > 0 then	
		local effectId = SimpleAudioEngine:sharedEngine():playEffect(musicfile,false)	
		return effectId			
	end
end	

function SoundManager:setBackgroundMusicFile(fileName)
	self.playingMusicFile = fileName
end

function SoundManager:playBackgroundMusic(musicfile)
	if not musicfile then
		return
	end
	
	self.playingMusicFile = musicfile
	
	if self.musicVoice > 0 then	
		SimpleAudioEngine:sharedEngine():playBackgroundMusic(musicfile,true)
	end
end	

function SoundManager:stopEffect(effectId)
	SimpleAudioEngine:sharedEngine():stopEffect(effectId)
end	

function SoundManager:stopBackgroundMusic()
	SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)
end		

function SoundManager:setBackgroundMusicVolume(musicVoice)
	SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(musicVoice)
	self.musicVoice = musicVoice	
	if musicVoice <= 0 then
		self:stopBackgroundMusic()
	elseif  musicVoice > 0 then
		self:playBackgroundMusic(self.playingMusicFile)		
	end			
end			

function SoundManager:setEffectsVolume(effectVoice)
	SimpleAudioEngine:sharedEngine():setEffectsVolume(effectVoice)
	self.effectVoice = effectVoice
end		

function SoundManager:preLoadEffect()
	SimpleAudioEngine:sharedEngine():preloadEffect("music/mandie.mp3")	
	SimpleAudioEngine:sharedEngine():preloadEffect("music/manbeat.mp3")	
	SimpleAudioEngine:sharedEngine():preloadEffect("music/levelup.mp3")		
	SimpleAudioEngine:sharedEngine():preloadEffect("music/womanbeat.mp3")	
	SimpleAudioEngine:sharedEngine():preloadEffect("music/womandie.mp3")		
end

function SoundManager:unLoadEffect()
	SimpleAudioEngine:sharedEngine():unloadEffect("music/mandie.mp3")	
	SimpleAudioEngine:sharedEngine():unloadEffect("music/manbeat.mp3")	
	SimpleAudioEngine:sharedEngine():unloadEffect("music/levelup.mp3")		
	SimpleAudioEngine:sharedEngine():unloadEffect("music/womanbeat.mp3")	
	SimpleAudioEngine:sharedEngine():unloadEffect("music/womandie.mp3")		
end

