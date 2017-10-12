require("GameDef")
require("ui.UIDef")
require("object.entity.GameStateMachine")	
function __G__TRACKBACK__(msg)
	
	print("error")
	CCLuaLog("----------------------------------------")
	local errMsg = "LUA ERROR: " .. tostring(msg) .. "\n"..debug.traceback()
	CCLuaLog(errMsg)
	CCLuaLog("----------------------------------------")
		
	-- 替换换行符
	local emailContent = "Platform:"..SFLoginManager:getInstance():getPlatform().."\n"
	emailContent = emailContent.."AppVersion:"..SFGameHelper:getClientVersion().."\n"
	emailContent = emailContent.."BaseVersion:"..(getPackVersion("base.zpk")).."\n"
	emailContent = emailContent.."ExtendVersion:"..(getPackVersion("extend.zpk")).."\n"
	emailContent = emailContent.."ErrorTime: "..os.date("%y/%m/%d  %X").."\n"
	local playerName = " "
	if GameWorld and GameWorld.Instance and GameWorld.Instance.getEntityManager then 
		playerName = PropertyDictionary:get_name(GameWorld.Instance:getEntityManager():getHero():getPT())
	end
	emailContent = emailContent.."PlayerName: "..playerName.."\n"
	emailContent = emailContent.."PlayerId: "..G_getHero():getId().."\n"
	
	emailContent = emailContent..errMsg
	LoginWorld.Instance:getStatisticsMgr():requestErrorLogUpload(emailContent, playerName)	
	--[[emailContent = string.gsub(emailContent, "\n", "<br>")
	
	math.randomseed(os.time())
	local mailId = math.random(1, 11)
	local sendFrom = "newbeeStudio"..mailId.."@163.com"
	
	local sendEmail = SFEasyMail:new(sendFrom, "newbeeStudio", "smtp://smtp.163.com:25", "<"..sendFrom..">")
	sendEmail:SetMailContent("lua error:"..os.date(), emailContent)
	sendEmail:AddRecipient("newbeeStudioLog@163.com")
	sendEmail:SendMail()--]]
end

local function init()
	
	GameStateMachine.New()							--全局的状态机管理器		
end

local function main()
	collectgarbage("setpause", 100) 
	collectgarbage("setstepmul", 5000)	
	math.randomseed(os.time())		
	init()
--	jit.on()--
	SceneManager.Instance:initGameScene()
end

xpcall(main, __G__TRACKBACK__)