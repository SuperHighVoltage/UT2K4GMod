 AddCSLuaFile("cl_init.lua")
 AddCSLuaFile("shared.lua")

 include("shared.lua")
 
 function ENT:Shoot_Flak(num)
/*
	local aim = self.Owner:GetAimVector()
	local side = aim:Cross(Vector(0,0,1))
	local up = side:Cross(aim)
//	local pos = self.Owner:GetShootPos() -- +  aim * 24 + side * 8 + up * -1	--offsets so it spawns from the muzzle (hopefully)
	
	local model = self.Owner:GetViewModel()
	local attach = model:LookupAttachment( "muzzle" );
	local at = model:GetAttachment(attach)
	//local f = at.Ang:Up()*-1
	local f = at.Ang:Forward()
	pos = at.Pos + self.Owner:GetViewOffset()
*/
	for i=1,num do 
		local rnd1 = math.random(-360,360)
		local rnd2 = math.random(-360,360)
		local rnd3 = math.random(-360,360)
		local rndAng = Angle(rnd1, rnd2, rnd3)		//spread the flechettes
		local angle = (rndAng)
		
		f = angle:Forward()
		
		UT.SpawnProjectile(UT_PROJECTILE_FLECHETTE,self:GetPos(),f*700,self.Entity:GetOwner())

	end
end 
  
function ENT:Initialize()
	util.PrecacheSound("UT2K4/Weapons/RocketLauncherProjectile.wav")
	self.Entity:SetModel("models/weapons/w_ut2k4_flak_shell.mdl")
	self.Entity:SetMoveType(MOVETYPE_FLYGRAVITY)
	self.Entity:SetGravity( 1 )
	self.Entity:SetSolid(SOLID_VPHYSICS)
	//self.Entity:EmitSound( "UT2K4_RocketLauncher.Projectile" )
	
	local entSpriteEye = ents.Create("env_smoketrail")
//	entSpriteEye:SetKeyValue("smokesprite", "particles/smokey")
	entSpriteEye:SetKeyValue("startsize", "5") 
	entSpriteEye:SetKeyValue("endsize", "7") 
	entSpriteEye:SetKeyValue("spawnradius", "0") 
	entSpriteEye:SetKeyValue("spawnrate", "70") 	
	entSpriteEye:SetKeyValue("lifetime", "1") 
	entSpriteEye:SetKeyValue("maxspeed", "3") 
	entSpriteEye:SetKeyValue("minspeed", "0") 
//	entSpriteEye:SetKeyValue("opacity", "0.75") 		
	entSpriteEye:SetParent(self)
	entSpriteEye:Fire("SetParentAttachment", "0", 0)
	entSpriteEye:Spawn()
	entSpriteEye:Activate()
	self.entSpriteEye = entSpriteEye
	self:DeleteOnRemove(entSpriteEye)
//	entSpriteEye:Fire("ShowSprite", "", 0)	
	
	return true
end

function ENT:Think()
	self.Entity:NextThink(CurTime())
	return true
end

function ENT:Touch()
	local Boom = ents.Create("env_explosion")
	Boom:SetPos(self:GetPos())
	Boom:SetOwner(self.Owner)
	Boom:SetKeyValue( "iMagnitude", "30" )
	Boom:SetOwner(self.Entity:GetOwner())	
	Boom:Spawn()
	Boom:Fire("Explode",0,0)
	
	if(SERVER) then
		self:Shoot_Flak( 6 )	//shoot 6 flechettes
	end	
/*
if(SERVER) then	
	for i=1,6 do 
		local rnd1 = math.random(-360,360)
		local rnd2 = math.random(-360,360)
		local rnd3 = math.random(-360,360)
		local rndAng = Angle(rnd1, rnd2, rnd3)		//spread the flechettes
		local angle = (rndAng)
		
		f = angle:Forward()
		--local flak = ents.Create("UT2K4_Flak")
		--if !flak:IsValid() then return false end
		--flak:SetAngles(angle)
		--flak:SetPos(pos)
		--flak:Spawn()
		--flak:Activate()
		--flak:SetDamageOwner(self.Owner)
		--flak:GetPhysicsObject():SetVelocity(f*6000)
		UT.SpawnProjectile(UT_PROJECTILE_FLECHETTE,self:GetPos(),f*700,self.Entity:GetOwner())
	end
end*/
	self.Entity:Remove()
end
