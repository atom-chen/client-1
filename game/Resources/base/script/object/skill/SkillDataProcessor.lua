require("common.baseclass")
require("utils.PropertyDictionaryReader")

SkillDataProcessor = SkillDataProcessor or BaseClass()

function SkillDataProcessor:__init()
	
end

--�������ݣ� ���ؼ��ܵ������ͼ��ܵ�����
--����propertyTable[1].refid = "skill_B001"
------propertyTable[1].level = 7
------propertyTable[1].index = 4
function SkillDataProcessor:UnpackData(reader)
	local propertyTable = {}
	--��������	
	local skillCount = reader:ReadShort()
	for i=1, skillCount do 
		local sizes = reader:ReadInt()
		propertyTable[i] = getPropertyTable(reader)		
	end
	return skillCount, propertyTable
end