require("common.baseclass")
require("utils.PropertyDictionaryReader")

SkillDataProcessor = SkillDataProcessor or BaseClass()

function SkillDataProcessor:__init()
	
end

--解析数据， 返回技能的数量和技能的属性
--例如propertyTable[1].refid = "skill_B001"
------propertyTable[1].level = 7
------propertyTable[1].index = 4
function SkillDataProcessor:UnpackData(reader)
	local propertyTable = {}
	--技能数量	
	local skillCount = reader:ReadShort()
	for i=1, skillCount do 
		local sizes = reader:ReadInt()
		propertyTable[i] = getPropertyTable(reader)		
	end
	return skillCount, propertyTable
end