require("data.newGuidelines.newGuidelines")

NewGuidelinesStaticData = NewGuidelinesStaticData or  BaseClass()

function NewGuidelinesStaticData:getNewGuidelines(questId)--��ȡ����ָ��Key
	local data = GameData.NewGuidelines[questId]
	if data then
		return true
	else
		return false
	end
end

function NewGuidelinesStaticData:getNewGuidelinesIndex(questId,step)--��ȡ����ָ������
	local data = GameData.NewGuidelines[questId]
	if data then
		return data[step]
	end
end