 AddCSLuaFile("cl_init.lua")
 AddCSLuaFile("shared.lua")

 include("shared.lua")
 
  ENT.target = nil
  
function ENT:Initialize()
	util.PrecacheSound("UT2K4/Weapons/RocketLauncherProjectile.wav")
	self.Entity:SetModel("models/weapons/w_ut2k4_rocketproj.mdl")
	self.Entity:SetMoveType(MOVETYPE_FLY)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	//self.Entity:EmitSound( "UT2K4_RocketLauncher.Projectile" )
	
	
	local entSpriteEye = ents.Create("env_sprite")
	entSpriteEye:SetKeyValue("model", "effects/blueflare1.vmt")	//Find something else
	entSpriteEye:SetKeyValue("rendermode", "5") 
	entSpriteEye:SetKeyValue("rendercolor", "224 154 63") 
	entSpriteEye:SetKeyValue("scale", "0.4") 
	entSpriteEye:SetParent(self)
	entSpriteEye:Fire("SetParentAttachment", "0", 0)
	entSpriteEye:Spawn()
	entSpriteEye:Activate()
	self.entSpriteEye = entSpriteEye
	self:DeleteOnRemove(entSpriteEye)
	entSpriteEye:Fire("ShowSprite", "", 0)	
	
	local Smoke = EffectData()	//smoke trail
		Smoke:SetEntity(self)
		Smoke:SetRadius(3) --Radius
	util.Effect("UT2K4_Rocketproj_Smoke", Smoke)
	
	return true
end

function ENT:Target(ent)
	if ent then
		self.target = ent
	end
end

function ENT:Think()--[[
	local Smoke = EffectData()	//smoke trail
		Smoke:SetEntity(self)
		Smoke:SetRadius(3) --Radius
	util.Effect("UT2K4_Rocketproj_Smoke", Smoke)
	
		local Smoke2 = EffectData()	//smoke trail
		Smoke2:SetOrigin(self.Entity:GetPos() - self.Entity:GetForward() * 5)
		Smoke2:SetRadius(3) --Radius
		Smoke2:SetMagnitude(1) --Die Time
	util.Effect("UT2K4_Rocketproj_Smoke", Smoke2)]]--
	
	if self.target and self.target:IsValid() then
		local angle = LerpAngle(0.05, self.Entity:GetAngles(), ( self.target:LocalToWorld(self.target:OBBCenter()) - self.Entity:GetPos()):Angle())
		self.Entity:SetAngles( angle)//( self.target:LocalToWorld(self.target:OBBCenter()) - self.Entity:GetPos()):Angle() )
		self.Entity:SetLocalVelocity(self.Entity:GetForward()*800)
	end
	
--[[	if ( Show_Health == true ) then
		local entSpriteEye = ents.Create("env_sprite")
		entSpriteEye:SetKeyValue("model", "effects/blueflare1.vmt")	//Find something else
		entSpriteEye:SetKeyValue("rendermode", "5") 
	//	entSpriteEye:SetKeyValue("rendercolor", "0 0 0") 
		entSpriteEye:SetKeyValue("scale", "0.4") 
		entSpriteEye:SetParent(self)
		entSpriteEye:Fire("SetParentAttachment", "0", 0)
		entSpriteEye:Spawn()
		entSpriteEye:Activate()
		self.entSpriteEye = entSpriteEye
		self:DeleteOnRemove(entSpriteEye)
		entSpriteEye:Fire("ShowSprite", "", 0)	
	end --]]
	self.Entity:NextThink(CurTime())
	return true
end

function ENT:Touch()
	local Boom = ents.Create("env_explosion")
	Boom:SetPos(self:GetPos())
	Boom:SetOwner(self.Entity:GetOwner())
	Boom:SetKeyValue( "iMagnitude", "90" )
//	Boom:SetOwner(self)	
	Boom:Spawn()
	Boom:Fire("Explode",0,0)
	Boom:Fire("Kill",0,0)
	
	self.Entity:Remove()
end