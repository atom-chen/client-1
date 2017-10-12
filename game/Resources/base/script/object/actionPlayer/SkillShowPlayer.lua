--[[
����һ������
]]

require("object.actionPlayer.BaseActionPlayer")

SkillShowPlayer = SkillShowPlayer or BaseClass(BaseActionPlayer)

function SkillShowPlayer:__init()
	self.des = "SkillShowPlayer"
	self.skillShowData = nil
	self.animateSpeed = 1
end

function SkillShowPlayer:__delete()
	self.skillShowData = nil
end

function SkillShowPlayer:setSkillShowData(data)
	self.skillShowData = data
end

function SkillShowPlayer:doPlay()
	if (self.skillShowData == nil) then
		error("SkillShowPlayer:doPlay failed. self.skillShowData is empty")
		return
	end
	
	-- ȥ��λ����Ϣ, ����Ҫ��ȥ�ı����λ��
	self.skillShowData["targetX"] = nil
	self.skillShowData["targetY"] = nil
	
	SkillShowManager:handleSkillUse(self.skillShowData)
	self:setState(E_ActionPlayerState.Finished)
end