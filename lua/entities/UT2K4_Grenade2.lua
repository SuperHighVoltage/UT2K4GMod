AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName		= "UT2K4 Grenade"
ENT.Author			= "HighVoltage"
ENT.Information		= "Grenade from the grenade launcher"
ENT.Category		= "UT2K4"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.bounces = 1

function ENT:Initialize()
	self:SetModel("models/weapons/w_ut2k4_launcher_grenade.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMaterial( "gmod_bouncy" )
	end
	
	return true
end

function ENT:PhysicsCollide( data, physobj )
   self.bounces = self.bounces + .3
//	if !data.HitEntity:IsWorld() then
	if data.HitEntity:IsPlayer() or data.HitEntity:IsNPC() or data.HitEntity:IsVehicle() then
//MsgN(data.HitEntity:GetMaterialType())-----------------------------------------
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetParent(data.HitEntity)
//		phys = data.HitEntity:GetPhysicsObject()
//		MsgN(phys)
//		MsgN(data.HitObject)
	else	   
		// Play sound on bounce
		if (data.Speed > 80 && data.DeltaTime > 0.2 ) then
				self:EmitSound( "Rubber.BulletImpact" )
		end
		if data.DeltaTime < 0.2 then
			
		end
		// Bounce like a crazy bitch
		local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
		local NewVelocity = physobj:GetVelocity()

		local speed = NewVelocity:Length() * 2
		NewVelocity:Normalize()
	   
		LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
	   
		local TargetVelocity = (NewVelocity * LastSpeed * (0.7/self.bounces) ) + Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1))
	   
		physobj:SetVelocity( TargetVelocity )
		physobj:AddAngleVelocity( -1 * physobj:GetAngleVelocity( ) + Vector(math.random(-speed,speed),math.random(-speed,speed),math.random(-speed,speed)) )
		if data.Speed  < 10 then
			physobj:SetVelocity( Vector(0,0,0) )
			physobj:AddAngleVelocity( -1 * physobj:GetAngleVelocity( ) )
		end
	end
   
end

function ENT:Splode()
	local Boom = ents.Create("env_explosion")
	Boom:SetPos(self:GetPos())
	Boom:SetKeyValue( "iMagnitude", "90" )
//	Boom:SetOwner(self.Entity:GetOwner())
	Boom:SetOwner(self:GetOwner())	
	Boom:Spawn()
	Boom:Fire("Explode",0,0)
	Boom:Fire("Kill",0,0)
	
	self:Remove()
end

function ENT:Think()
	if  self:GetOwner() and  self:GetOwner():IsPlayer() and !self:GetOwner():Alive() then
		self:Splode()
	end
end