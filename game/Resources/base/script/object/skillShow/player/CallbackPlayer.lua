require "object.skillShow.player.AnimatePlayer"

CallbackPlayer = CallbackPlayer or BaseClass(AnimatePlayer)

function CallbackPlayer:__init(callback)
	self.name = "CallbackPlayer"
	self.callback = callback
end

function CallbackPlayer:__delete()
	
end

function CallbackPlayer:doPlay()
	if self.callback then
		self.callback()
	end		
	self.state = AnimatePlayerState.AnimatePlayerStateFinish
end

function CallbackPlayer:doStop()

end


