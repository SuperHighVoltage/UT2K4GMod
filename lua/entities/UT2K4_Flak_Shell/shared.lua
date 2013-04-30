ENT.Type = "anim"
//ENT.Base = "base_gmodentity"

ENT.PrintName		= "UT2K4 Flak shell"
ENT.Author			= "HighVoltage"
ENT.Information		= "Flak shell from a UT2K4 flak cannon"
ENT.Category		= "UT2K4"

ENT.Spawnable = false
ENT.AdminSpawnable = false


function ENT:OnRemove()
	self.Entity:StopSound("Missile.Ignite")
end