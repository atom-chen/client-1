require("data.activity.discount")
DiscountSellStaticData = DiscountSellStaticData or  BaseClass()


function DiscountSellStaticData:getItemId(id)--��ȡ����Refid
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

function DiscountSellStaticData:getgetOriginalsalePriceType(id)--��ȡԭ�ۼ۸�����
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

function DiscountSellStaticData:getOriginalsalePrice(id)--��ȡԭ�ۼ۸�
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

function DiscountSellStaticData:getSalePriceType(id)--��ȡ�ּۼ۸�����
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

function DiscountSellStaticData:getSalePrice(id)--��ȡ�ּۼ۸�
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

function DiscountSellStaticData:getItemLimitNum(id)--ȫ���޹�����
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

function DiscountSellStaticData:getItemPersonLimitNum(id)--�����޹�����
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