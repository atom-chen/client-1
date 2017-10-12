require("common.baseclass")

Action = Action or BaseClass()

function Action:__init(object,selector)
	self.object = object
	self.selector = selector
end

function Action:__delete()
	self.object = nil
	self.selector = nil
end

function Action:run()
	if self.object then
		self.selector(self.object)
	else
		self.selector()
	end
end