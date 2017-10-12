UIControl = UIControl or BaseClass()

function UIControl:SpriteSetGray(sprite,name)	--Ö»Ö§³ÖCCSprite
	if sprite then
		sprite:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey("ShaderPositionTextureGray"))
	end
	if name then
		name:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey("ShaderPositionTextureGray"))
	end	
end

function UIControl:SpriteSetColor(sprite,name)
	if sprite then
		sprite:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey("ShaderPositionTextureColor"))		
	end	
	if name then
		name:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey("ShaderPositionTextureColor"))
	end
end
