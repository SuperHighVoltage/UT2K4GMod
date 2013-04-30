 AddCSLuaFile("cl_init.lua")
 AddCSLuaFile("shared.lua")

 include("shared.lua")
   
function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_ut2k4_assault_grenade.mdl")
//	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
//	self.Entity:SetSolid(SOLID_VPHYSICS)
   
	// Don't use the model's physics - create a sphere instead
	self.Entity:PhysicsInitSphere( 4, "metal_bouncy" )
   
	// Wake the physics object up. It's time to have fun!
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
			phys:Wake()
	end
   
	// Set collision bounds exactly
	self.Entity:SetCollisionBounds( Vector( -4, -4, -4 ), Vector( 4, 4, 4 ) )
//        ent:Activate()
		
	self.time = CurTime()+2
	return true
end
function ENT:Think()
	if self.time < CurTime() then
		self:Splode()
	end
	
	self.Entity:NextThink(CurTime())
	return true
end

function ENT:Splode()
	local Boom = ents.Create("env_explosion")
	Boom:SetPos(self:GetPos())
	Boom:SetOwner(self.Owner)
	Boom:SetKeyValue( "iMagnitude", "40" )
	Boom:SetOwner(self.Entity:GetOwner())	
	Boom:Spawn()
	Boom:Fire("Explode",0,0)

	self.Entity:Remove()
end
ENT.bounces = 1
function ENT:PhysicsCollide( data, physobj )
   self.bounces = self.bounces + .3
	if data.HitEntity:IsPlayer() or data.HitEntity:IsNPC() or data.HitEntity:IsVehicle() then
		self:Splode()
	else	   
		// Play sound on bounce
		if (data.Speed > 80 && data.DeltaTime > 0.2 ) then
				self.Entity:EmitSound( "Rubber.BulletImpact" )
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