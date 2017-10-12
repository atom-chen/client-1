require ("GameDef")

ItemDetailArg = ItemDetailArg or BaseClass()

function ItemDetailArg:__init()
--	self.btns = {E_ItemDetailBtnType.eShow, E_ItemDetailBtnType.eSell, E_ItemDetailBtnType.eUse,E_ItemDetailBtnType.eBuy,}
	self.btns = {}
	self.data = nil
	self.titleTips = ""
	self.viewName = ""
	self.isShowFpTips = true
	self.priceType = E_EquipShowPriceType.sellPrice
	self.isShowCloseBtn = true
	self.isShowAuctionPrice = false
	self.isShowAuctionNumber = false
end	

function ItemDetailArg:setBtnArray(btns)
	self.btns = btns
end	

function ItemDetailArg:getBtnArray()
	return self.btns
end	

function ItemDetailArg:setItem(data)
	self.data = data
end

function ItemDetailArg:getItem()
	return self.data
end	

function ItemDetailArg:setTitleTips(data)
	self.titleTips = data
end

function ItemDetailArg:getTitleTips()
	return self.titleTips
end

function ItemDetailArg:getViewName()
	return self.viewName
end

function ItemDetailArg:setViewName(name)
	self.viewName = name
end

function ItemDetailArg:getViewName()
	return self.viewName
end

function ItemDetailArg:setIsShowFpTips(bShow)
	self.isShowFpTips = bShow
end

function ItemDetailArg:getIsShowFpTips()
	return self.isShowFpTips
end

function ItemDetailArg:setShowPriceType(tyype)
	self.priceType = tyype
end

function ItemDetailArg:getShowPriceType(tyype)
	return self.priceType
end

function ItemDetailArg:getIsShowCloseBtn()
	return self.isShowCloseBtn
end

function ItemDetailArg:setIsShowCloseBtn(bShow)
	self.isShowCloseBtn = bShow
end

function ItemDetailArg:getIsShowSwitchEquipBtn()
	return self.isShowSwitchEquipBtn
end

function ItemDetailArg:setIsShowCloseBtn(bShow)
	self.isShowSwitchEquipBtn = bShow
end

function ItemDetailArg:getIsShowAuctionPrice()
	return self.isShowAuctionPrice
end

function ItemDetailArg:setIsShowAuctionPrice(bShow)
	self.isShowAuctionPrice = bShow
end

function ItemDetailArg:getIsShowAuctionNumber()
	return self.isShowAuctionNumber
end

function ItemDetailArg:setIsShowAuctionNumber(bShow)
	self.isShowAuctionNumber = bShow
end
