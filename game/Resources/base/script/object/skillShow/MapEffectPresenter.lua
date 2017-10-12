--[[
������ʾ�����ء����ٳ����ϵ���Ч
]]

require("common.baseclass")
require("object.skillShow.SkillShowDef")

MapEffectPresenter = MapEffectPresenter or BaseClass()

function MapEffectPresenter:__init()
	self.bShowMapEffect = true
	self.effectList = {}
	self.currentEffectCount = 0
end

function MapEffectPresenter:__delete()

end

-- ��鲥�ŵ����������Ƿ������ʾһ���µ���Ч
function MapEffectPresenter:canShowEffect(effectKey)
	if not self.effectList[effectKey] then
		return true
	else
		return not (self.currentEffectCount >= SkillShowDef.MaxMapAnimateCount) and not (self.effectList[effectKey] >= SkillShowDef.MaxMapUniqueCount)
	end
end

-- ��ʾ��ͼ��Ч
function MapEffectPresenter:showMapEffect(effectKey, effectObject)
	if not effectKey or not effectObject then
		CCLuaLog("Warning!MapEffectPresenter:showMapEffect wrong param")
		return false
	end
	
	if self.bShowMapEffect == false then
		return false
	end
	
	if self.currentEffectCount >= SkillShowDef.MaxMapAnimateCount then
		-- ����ȫ�ֵ������
		return false
	end
	
	local count = self.effectList[effectKey]
	if not count then
		count = 0
	end
	
	if count >= SkillShowDef.MaxMapUniqueCount then
		-- �����˵��������������
		return false
	end
	
	count = count + 1
	self.effectList[effectKey] = count
	
	effectObject:enterMap()
	return true
end

-- �Ƴ���ͼ��Ч
function MapEffectPresenter:removeMapEffect(effectKey, effectObject)
	if not effectKey or not effectObject then
		CCLuaLog("Warning!MapEffectPresenter:removeMapEffect wrong param")
		return
	end
	
	self.currentEffectCount = self.currentEffectCount - 1
	if self.currentEffectCount < 0 then	
		self.currentEffectCount = 0
	end
	
	local count = self.effectList[effectKey]
	if count then
		count = count - 1
		if count < 0 then
			count = 0
		end
	end
	
	self.effectList[effectKey] = count
	effectObject:leaveMap()
end

-- �Ƿ�Ҫ��ʾ��ͼ��Ч
function MapEffectPresenter:setIsShowMapEffect(bShow)
	if bShow then
		self.bShowMapEffect = bShow
	end
end