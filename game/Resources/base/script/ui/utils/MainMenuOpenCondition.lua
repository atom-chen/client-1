--主菜单开启条件
require("common.baseclass")
MainMenuOpenCondition = MainMenuOpenCondition or BaseClass()

function MainMenuOpenCondition:__init()
	
end	

function MainMenuOpenCondition:__delete()
	
end

function MainMenuOpenCondition:isBtnOpen(MainMenuBtn)
	if MainMenuBtn == MainMenu_Btn.Btn_role then
		return self:isRoleOpen()
	elseif MainMenuBtn == MainMenu_Btn.Btn_bag then
		return self:isBagOpen()
	elseif MainMenuBtn == MainMenu_Btn.Btn_skill then
		return self:isSkillOpen()	
	elseif MainMenuBtn == MainMenu_Btn.Btn_task then
		return self:isTaskOpen()
	elseif MainMenuBtn == MainMenu_Btn.Btn_faction then
		return self:isFactionOpen()
	elseif MainMenuBtn == MainMenu_Btn.Btn_talisman then
		return self:isTalismanOpen()
	elseif MainMenuBtn == MainMenu_Btn.Btn_mount then
		return self:isMountOpen()
	elseif MainMenuBtn == MainMenu_Btn.Btn_wing then
		return self:isWingOpen()
	elseif MainMenuBtn == MainMenu_Btn.Btn_forge then
		return self:isForgeOpen()
	elseif MainMenuBtn == MainMenu_Btn.Btn_achieve then
		return self:isAchieveOpen()
	elseif MainMenuBtn == MainMenu_Btn.Btn_setting then
		return self:isSettingOpen()
	elseif MainMenuBtn == MainMenu_Btn.Btn_shop then
		return self:isShopOpen()
	elseif MainMenuBtn == MainMenu_Btn.Btn_auction then
		return self:isAuctionOpen()
	end		
end

function MainMenuOpenCondition:isRoleOpen()
	return true
end	

function MainMenuOpenCondition:isBagOpen()
	return true
end	

function MainMenuOpenCondition:isSkillOpen()
	return true
end	

function MainMenuOpenCondition:isTaskOpen()
	return true
end	

function MainMenuOpenCondition:isFactionOpen()
	return true
end	

function MainMenuOpenCondition:isTalismanOpen()
	return true
end	

function MainMenuOpenCondition:isMountOpen()
	return false
end	

function MainMenuOpenCondition:isWingOpen()
	return false
end	

function MainMenuOpenCondition:isForgeOpen()
	return false
end	

function MainMenuOpenCondition:isAchieveOpen()
	return true
end	

function MainMenuOpenCondition:isSettingOpen()
	return true
end	

function MainMenuOpenCondition:isShopOpen()
	return true
end	

function MainMenuOpenCondition:isAuctionOpen()
	return true
end	

