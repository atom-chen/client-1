require("data.gameInstance.Ins_1")
require("data.gameInstance.Ins_2")
require("data.gameInstance.Ins_3")
require("data.gameInstance.Ins_4")
require("data.gameInstance.Ins_5")
require("data.gameInstance.Ins_6")
require("data.gameInstance.Ins_7")
require("data.gameInstance.Ins_pk1")
require("data.gameInstance.Ins_pk2")
require("data.gameInstance.Ins_pk3")
require("data.gameInstance.Ins_pk4")
require("data.gameInstance.Ins_pk5")

QuestInstanceRefObj = QuestInstanceRefObj or  BaseClass()

--获取副本名字
function QuestInstanceRefObj:getStaticInstanceName(ins)
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if data then
			return data["name"]
		end
	end
end

--获取任务名字
function QuestInstanceRefObj:getStaticQusetPropertyQuestName(ins,questId)
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if data then
			if data["configData"] then
				if data["configData"]["game_instance_quest"] then
					if  data["configData"]["game_instance_quest"]["configData"] then
						if  data["configData"]["game_instance_quest"]["configData"][questId] then
							if data["configData"]["game_instance_quest"]["configData"][questId] then
								return data["configData"]["game_instance_quest"]["configData"][questId]["name"]
							end														
						end
					end
				end
			end
		end
	end
end	

--副本任务属性奖励
function QuestInstanceRefObj:getStaticQusetRewardProperty(ins,questId)
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if data then
			if data["configData"] then
				if data["configData"]["game_instance_quest"] then
					if  data["configData"]["game_instance_quest"]["configData"] then
						if  data["configData"]["game_instance_quest"]["configData"][questId] then
							if data["configData"]["game_instance_quest"]["configData"][questId]["questData"] then
								if data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["rewardField"] then
									return data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["rewardField"]["propertyReward"]
								end									
							end														
						end
					end
				end
			end
		end
	end
end

--副本任务道具奖励
function QuestInstanceRefObj:getStaticQusetItemReward(ins,questId)
	if ins~="" and GameData[ins] then
		local data = GameData[ins][ins]	
		if data then
			if data["configData"] then
				if data["configData"]["game_instance_quest"] then
					if  data["configData"]["game_instance_quest"]["configData"] then
						if  data["configData"]["game_instance_quest"]["configData"][questId] then
							if data["configData"]["game_instance_quest"]["configData"][questId]["questData"] then
								if data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["rewardField"]then
									if data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["rewardField"]["itemReward"]then
										if data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["rewardField"]["itemReward"]["itemList"] then
											return data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["rewardField"]["itemReward"]["itemList"]
										end	
									end
								end								
							end														
						end
					end
				end
			end
		end
	end
end

--副本任务目标类型
function QuestInstanceRefObj:getStaticQusetOrderFieldType(ins,questId,index)
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if data then		
			if data["configData"] then
				if data["configData"]["game_instance_quest"] then
					if  data["configData"]["game_instance_quest"]["configData"] then
						if  data["configData"]["game_instance_quest"]["configData"][questId] then
							if data["configData"]["game_instance_quest"]["configData"][questId]["questData"] then
								if data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["orderField"]then
									return data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["orderField"][index]["orderType"]
								end								
							end														
						end
					end
				end
			end
		end
	end
end

--副本任务目标杀怪数量
function QuestInstanceRefObj:getStaticQusetOrderFieldKillCount(ins,questId,index)
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if data then		
			if data["configData"] then
				if data["configData"]["game_instance_quest"] then
					if  data["configData"]["game_instance_quest"]["configData"] then
						if  data["configData"]["game_instance_quest"]["configData"][questId] then
							if data["configData"]["game_instance_quest"]["configData"][questId]["questData"] then
								if data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["orderField"]then
									return data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["orderField"][index]["killCount"]
								end								
							end														
						end
					end
				end
			end
		end
	end
end

--副本任务目标怪物Id
function QuestInstanceRefObj:getStaticQusetOrderFieldMonsterRefId(ins,questId,index)
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if data then		
			if data["configData"] then
				if data["configData"]["game_instance_quest"] then
					if  data["configData"]["game_instance_quest"]["configData"] then
						if  data["configData"]["game_instance_quest"]["configData"][questId] then
							if data["configData"]["game_instance_quest"]["configData"][questId]["questData"] then
								if data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["orderField"]then
									return data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["orderField"][index]["monsterRefId"]
								end								
							end														
						end
					end
				end
			end
		end
	end
end

--副本任务目标时间
function QuestInstanceRefObj:getStaticQusetOrderFieldTime(ins,questId,index)
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if data then		
			if data["configData"] then
				if data["configData"]["game_instance_quest"] then
					if  data["configData"]["game_instance_quest"]["configData"] then
						if  data["configData"]["game_instance_quest"]["configData"][questId] then
							if data["configData"]["game_instance_quest"]["configData"][questId]["questData"] then
								if data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["orderField"]then
									return data["configData"]["game_instance_quest"]["configData"][questId]["questData"]["orderField"][index]["timeCount"]
								end								
							end														
						end
					end
				end
			end
		end
	end
end

--副本下一层
function QuestInstanceRefObj:getStaticQusetToNextLayerRefId(ins,sceneid)
	local nextLayer = nil
	local layerList = {}
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if data then
			if data["configData"] then
				if data["configData"]["game_instance"] then
					if data["configData"]["game_instance"]["configData"] then
						if data["configData"]["game_instance"]["configData"][ins] then
							if data["configData"]["game_instance"]["configData"][ins]["gameInstanceData"] then
								if data["configData"]["game_instance"]["configData"][ins]["gameInstanceData"]["structureDetails"] then
									layerList = data["configData"]["game_instance"]["configData"][ins]["gameInstanceData"]["structureDetails"]
								end									
							end
						end							
					end					
				end
			end
		end
	end
	
	if table.size(layerList)>0 then
		for i,v in pairs(layerList) do
			if v == sceneid  then
				return layerList[i+1]
			end
		end
	end
end
--副本进入下一层道具
function QuestInstanceRefObj:getStaticQusetToNextLayerItem(ins,sceneid)
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if data then
			if data["configData"] then
				if data["configData"]["game_instance_scene"] then
					if data["configData"]["game_instance_scene"]["configData"] then
						if data["configData"]["game_instance_scene"]["configData"][sceneid] then
							if data["configData"]["game_instance_scene"]["configData"][sceneid]["gameInstanceSceneData"] then							
								if data["configData"]["game_instance_scene"]["configData"][sceneid]["gameInstanceSceneData"]["consumptionItems"] then
									if data["configData"]["game_instance_scene"]["configData"][sceneid]["gameInstanceSceneData"]["consumptionItems"]["item"] then
										return data["configData"]["game_instance_scene"]["configData"][sceneid]["gameInstanceSceneData"]["consumptionItems"]["item"]
									end										
								end				
							end								
						end
					end
				end
			end
		end
	end
end

--副本进入下一层道具名称RefId
function QuestInstanceRefObj:getStaticQusetToNextLayerItemRefid(ins,sceneid)
	local data = QuestInstanceRefObj:getStaticQusetToNextLayerItem(ins,sceneid)
	if data then
		return data["itemRefId"]
	end
	return nil
end

--副本进入下一层道具数量
function QuestInstanceRefObj:getStaticQusetToNextLayerItemCount(ins,sceneid)
	local data = QuestInstanceRefObj:getStaticQusetToNextLayerItem(ins,sceneid)
	if data then
		return data["itemCount"]
	end
	return nil
end

--副本当前层任务列表
function QuestInstanceRefObj:getStaticQusetToQuestList(ins,sceneid)
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if data then
			if data["configData"] then
				if data["configData"]["game_instance_scene"] then
					if data["configData"]["game_instance_scene"]["configData"] then
						if data["configData"]["game_instance_scene"]["configData"][sceneid] then
							if data["configData"]["game_instance_scene"]["configData"][sceneid]["gameInstanceSceneData"] then							
								return data["configData"]["game_instance_scene"]["configData"][sceneid]["gameInstanceSceneData"]["conditionField"] 
							end
						end
					end
				end
			end
		end
	end
end


--获取副本类型
function QuestInstanceRefObj:getInstanceType(ins)
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if data then
			return data["instanceType"]
		end
	end
end

--获取副本等级
function QuestInstanceRefObj:getInstanceSuggestlevel(ins)
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if data then
			return data["suggestlevel"]
		end
	end
end

--获取副本开放等级
function QuestInstanceRefObj:getInstancelevel(ins)
	if ins~="" and GameData[ins] then	
		local data = GameData[ins][ins]
		if not data then
			return
		end
		data = data["configData"]
		if not data then
			return
		end
		data = data["game_instance"]
		if not data then
			return
		end
		data = data["configData"]
		if not data then
			return
		end
		data = data[ins]
		if not data then
			return
		end
		data = data["property"]
		if not data then
			return
		end
		
		return data["level"]
	end
end

