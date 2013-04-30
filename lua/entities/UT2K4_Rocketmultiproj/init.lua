 AddCSLuaFile("cl_init.lua")
 AddCSLuaFile("shared.lua")

 include("shared.lua")
 
  ENT.Target = nil
  ENT.rocket = {}
  
function ENT:Initialize()

	self.Entity:SetModel("models/weapons/w_ut2k4_rocketproj.mdl")
	self.Entity:SetMoveType(MOVETYPE_FLY)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	local num = 3
	for i = 0, num do
		local angle = 3.14159 * 2 / num * i
		local y = math.sin( angle ) * 8
		local x = math.cos( angle ) * 8
		
		self.rocket[i] = ents.Create("UT2K4_Rocketproj")
		if !self.rocket[i]:IsValid() then return false end
		self.rocket[i]:SetAngles(self:GetAngles())
		self.rocket[i]:SetPos(self:GetPos() + Vector(0,x,y) )
		self.rocket[i]:SetOwner(self.Owner)
		self.rocket[i]:Spawn() 
		self.rocket[i]:Activate()
		self.rocket[i]:SetParent(self)
	end
	
	return true
end

function ENT:Target(ent)
	if ent then
		self.target = ent
	end
end

function ENT:Think()
	
	if self.target and self.target:IsValid() then
	local angle = LerpAngle(0.05, self.Entity:GetAngles(), ( self.target:LocalToWorld(self.target:OBBCenter()) - self.Entity:GetPos()):Angle())
		self.Entity:SetAngles( angle)//( self.target:LocalToWorld(self.target:OBBCenter()) - self.Entity:GetPos()):Angle() )
		self.Entity:SetLocalVelocity(self.Entity:GetForward()*800)
	end

	self.Entity:NextThink(CurTime())
	return true
end

function ENT:Touch()
	local num = 3
	for i = 0, num do
		if !self.rocket[i] == nil and !self.rocket[i] == NULL and self.rocket[i]:IsValid() then
			self.rocket[i]:Remove()
		end
	end
	self.Entity:Remove()
end