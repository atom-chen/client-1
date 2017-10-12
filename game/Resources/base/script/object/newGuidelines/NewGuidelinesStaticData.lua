require("data.newGuidelines.newGuidelines")

NewGuidelinesStaticData = NewGuidelinesStaticData or  BaseClass()

function NewGuidelinesStaticData:getNewGuidelines(questId)--获取新手指引Key
	local data = GameData.NewGuidelines[questId]
	if data then
		return true
	else
		return false
	end
end

function NewGuidelinesStaticData:getNewGuidelinesIndex(questId,step)--获取新手指引步骤
	local data = GameData.NewGuidelines[questId]
	if data then
		return data[step]
	end
end