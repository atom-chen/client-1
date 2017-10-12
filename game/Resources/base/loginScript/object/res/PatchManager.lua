require "common.BaseObj"

PatchManager = PatchManager or BaseClass(BaseObj)

function PatchManager:__init()
	PatchManager.Instance = self
	self.callback = nil	
end

function PatchManager:__delete()

end

function PatchManager:stop()

end

function PatchManager:startPatch(pathList,path)
	if pathList then
		self.pathList = pathList
		for k,v in pairs(pathList) do
			SFPackageManager:Instance():mergePackage(v)
		end			
		if self.callback then
			local patchDelegate = SFPackgePatchLuaDelegate:new()
			patchDelegate:setLuaHandler(self.callback)
			patchDelegate:autorelease()
			SFPackageManager:Instance():setPackageDelegateProtocl(patchDelegate)
		end
		SFPackageManager:Instance():startMerge()
		LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.ResMergerStart)
	end
end

function PatchManager:registerCallBack(func)
	self.callback = func
end

function PatchManager:unregisterCallBack()
	self.callback = nil
end	

function PatchManager:complete(func)
	LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.ResMergerFinish)
	SFPackageManager:Instance():completePackage()
	ResManager.Instance:removePatch(self.pathList,func)
	ResManager.Instance:clearPatchList()	
	ResManager.Instance:loadZpk()
end


