
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
  
--[[
/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
       
end
 
function ENT:OnRemove()
    if SERVER then
		self.Swivel:Remove()
		self.Gun:Remove()
		self:Remove()
    end
end]]--