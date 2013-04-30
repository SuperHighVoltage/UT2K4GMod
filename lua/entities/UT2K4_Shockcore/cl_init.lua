include( "shared.lua" )
MsgN("am i client?")
function ENT:Draw()
	self:DrawModel()    
end
--[[
function ENT:Initialize()
	local fx = EffectData()
	fx:SetEntity(self)
	util.Effect("ut2k4_shockcore",fx,true)

end]]--
