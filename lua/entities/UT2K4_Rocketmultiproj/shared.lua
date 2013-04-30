ENT.Type = "anim"
//ENT.Base = "base_gmodentity"

ENT.PrintName		= "UT2K4 Rocketpro"
ENT.Author			= "HighVoltage"
ENT.Information		= "Rocket from a UT2K4 rocket launcher"
ENT.Category		= "UT2K4"

ENT.Spawnable = false
ENT.AdminSpawnable = false


function ENT:OnRemove()
	self.Entity:StopSound("Missile.Ignite")
end


	