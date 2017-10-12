require("data.quest.recommendHandup")

recommendHandupRefObj = recommendHandupRefObj or  BaseClass()

function recommendHandupRefObj:getStaticScene(level)
	local data = GameData.RecommendHandup[level]
	if data then
		return data["property"]["map"]
	end
end

function recommendHandupRefObj:getStaticPos(level)
	local data = GameData.RecommendHandup[level]
	if data then
		local x = data["property"]["positionX"]
		local y = data["property"]["positionY"]
		local pos = ccp(x,y)
		return pos
	end
end