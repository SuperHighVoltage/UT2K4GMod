
ENT.Type                = "anim"
ENT.Base                = "base_anim"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

// Defaulting this to OFF. This will automatically save bandwidth
// on stuff that is already out there, but might break a few things
// that are out there. I'm choosing to break those things because
// there are a lot less of them that are actually using the animtime

ENT.AutomaticFrameAdvance = false

ENT.Radius = 1000

/*---------------------------------------------------------
   Name: Initialize 
---------------------------------------------------------*/
function ENT:Initialize()
 
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self.SpawnTime = CurTime()
	
	local Boom = EffectData()	//smoke trail
		Boom:SetEntity(self)
		Boom:SetOrigin(self:GetPos())
		Boom:SetRadius(self.Radius) --Radius
		Boom:SetStart(self.StartPos or self:GetPos()+Vector( 0, 0, 5000 ))

	util.Effect("UT2K4_IonExplosion", Boom)

end
 
function ENT:Think()
	if CurTime() - self.SpawnTime >= 1 then
//		self:EmitSound(Sound("UT2K4/Weapons/IonCannonBlast.wav"))
		sound.Play("UT2K4/Weapons/IonCannonBlast.wav",self:GetPos(),110,100)
		local victims = ents.FindInSphere(self:GetPos(),self.Radius)
		for k, ent in pairs(victims) do
		//MsgN(tostring(ent).."'s health: "..ent:Health())
			ent:SetVelocity(((ent:GetPos()-self:GetPos()):GetNormalized()*1000))
		
			if ent:IsPlayer() or ent:IsNPC() or ent:Health() != 0 then
				local damagepercent = 100-(ent:GetPos():Distance(self:GetPos())/self.Radius)
				//MsgN(damagepercent)
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(self)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamage(100-(((ent:GetPos():Distance(self:GetPos()))/self.Radius)*100))
				dmginfo:SetDamageType(DMG_ENERGYBEAM)
				dmginfo:SetDamagePosition(ent:GetPos())
				dmginfo:SetDamageForce((ent:GetPos()-self:GetPos()):GetNormalized()*1000)
				ent:TakeDamageInfo(dmginfo)
			end
		end
		self:Remove()
	end


        // Note: If you're overriding the next think time you need to return true
        self:NextThink(CurTime())
        return true
end

function ENT:OnRemove()
end