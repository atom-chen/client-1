require("data.activity.discount")
DiscountSellStaticData = DiscountSellStaticData or  BaseClass()


function DiscountSellStaticData:getItemId(id)--获取道具Refid
	local data = GameData.Discount["discount_item"]
	if data then
		if data["configData"] then	
			if data["configData"][id] then
				if data["configData"][id]["discountData"] then
					return data["configData"][id]["discountData"]["itemId"]
				end
			end		
		end
	end
end

function DiscountSellStaticData:getgetOriginalsalePriceType(id)--获取原价价格类型
	local data = GameData.Discount["discount_item"]
	if data then
		if data["configData"] then	
			if data["configData"][id] then
				if data["configData"][id]["discountData"] then
					return data["configData"][id]["discountData"]["OriginalsaleCurrency"]
				end
			end		
		end
	end
end

function DiscountSellStaticData:getOriginalsalePrice(id)--获取原价价格
	local data = GameData.Discount["discount_item"]
	if data then
		if data["configData"] then	
			if data["configData"][id] then
				if data["configData"][id]["discountData"] then
					return data["configData"][id]["discountData"]["OriginalsalePrice"]
				end
			end		
		end
	end
end

function DiscountSellStaticData:getSalePriceType(id)--获取现价价格类型
	local data = GameData.Discount["discount_item"]
	if data then
		if data["configData"] then	
			if data["configData"][id] then
				if data["configData"][id]["discountData"] then
					return data["configData"][id]["discountData"]["saleCurrency"]
				end
			end		
		end
	end
end

function DiscountSellStaticData:getSalePrice(id)--获取现价价格
	local data = GameData.Discount["discount_item"]
	if data then
		if data["configData"] then	
			if data["configData"][id] then
				if data["configData"][id]["discountData"] then
					return data["configData"][id]["discountData"]["salePrice"]
				end
			end		
		end
	end
end

function DiscountSellStaticData:getItemLimitNum(id)--全服限购数量
	local data = GameData.Discount["discount_item"]
	if data then
		if data["configData"] then	
			if data["configData"][id] then
				if data["configData"][id]["discountData"] then
					return data["configData"][id]["discountData"]["itemLimitNum"]
				end
			end		
		end
	end
end

function DiscountSellStaticData:getItemPersonLimitNum(id)--个人限购数量
	local data = GameData.Discount["discount_item"]
	if data then
		if data["configData"] then	
			if data["configData"][id] then
				if data["configData"][id]["discountData"] then
					if data["configData"][id]["discountData"] then
						return data["configData"][id]["discountData"]["privateLimitNum"]
					end	
				end						
			end		
		end
	end
end