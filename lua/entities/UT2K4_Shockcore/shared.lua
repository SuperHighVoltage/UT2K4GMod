ENT.Type = "anim"  
ENT.Base = "base_anim"
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "init.lua" )
    function ENT:Initialize()

        self.Hit = false
        self.Combo = false
        self.LastShout = CurTime()
        self.SpawnDelay = CurTime() + 0.5

        self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
        self:PhysicsInitBox(Vector(-16,-16,-16),Vector(16,16,16)) //XBox huge collision box
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
        self:SetNoDraw(true)
        self:DrawShadow(false)
        
        local phys = self:GetPhysicsObject()      
        if (phys:IsValid()) then
            phys:Wake()
            phys:EnableDrag(false)
            phys:EnableGravity(false)
            phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
            phys:AddGameFlag(FVPHYSICS_NO_PLAYER_PICKUP)
            phys:SetMass(50)
            phys:SetBuoyancyRatio(0)
        end
---[[		
		if SERVER then
			self.Fear = ents.Create("ai_sound")
			self.Fear:SetPos(self:GetPos())
			self.Fear:SetParent(self)
			self.Fear:SetKeyValue("SoundType", "8|1")
			self.Fear:SetKeyValue("Volume", "1000")
			self.Fear:SetKeyValue("Duration", "1")
			self.Fear:Spawn()
		end--]]--
        self.WhirrSound = CreateSound(self, "weapons/physcannon/energy_sing_loop4.wav")
        self.WhirrSound:Play()

        //self:Fire("kill", 1, 10)
		
	local fx = EffectData()
	fx:SetEntity(self)
	util.Effect("ut2k4_shockcore",fx,true)
		
    end
    
    function ENT:Think()

        if self.LastShout < CurTime() then
            if IsValid(self.Fear) then
                self.Fear:Fire("EmitAISound")
            end
            self.LastShout = CurTime() + 0.1
        end
    
        if self.Hit then
    
            local dmg
            local radius
        
            if !self.Combo then    
                dmg = 55
                radius = 40    
                local fx = EffectData()
                fx:SetOrigin(self:GetPos())
                util.Effect("ut2k4_shockcoreimpact",fx)
            else    
                dmg = 215
                radius = 200
                sound.Play("UT2K4/Weapons/ShockComboFire.wav",self:GetPos(),110,100)
                
                local fx = EffectData()
                fx:SetOrigin(self:GetPos())
                util.Effect("ut2k4_shockcombo",fx)
            end

            sound.Play("UT2K4/Weapons/ShockRifleExplosion.wav",self:GetPos(),110,100)    
            util.ScreenShake(self:GetPos(), radius/2, radius/2, 1, radius)
            
            if IsValid(self.Owner) then
            
                local dmginfo = DamageInfo()
            
                if self.Combo then
                    dmginfo:SetDamageType(DMG_DISSOLVE)
                else
                    dmginfo:SetDamageType(DMG_ENERGYBEAM)
                end
                
                if IsValid(self.Inflictor) then
                    dmginfo:SetInflictor(self.Inflictor)
                else
                    dmginfo:SetInflictor(self)
                end
                
                if IsValid(self.Owner) then
                    dmginfo:SetAttacker(self.Owner)
                else
                    dmginfo:SetAttacker(self)
                end
                
                dmginfo:SetDamage(dmg)
               // dmginfo:SetDamageForce(self:GetVelocity():Normalize()*2500)
                
                local victims = ents.FindInSphere(self:GetPos(),radius)
                
                for _,v in pairs(victims) do    
                
                    if IsValid(v) && (v != self) && !IsValid(v:GetParent()) then
                        
                        if self.DamagePos then
                            dmginfo:SetDamagePosition(self.DamagePos)
                        end

                        v:TakeDamageInfo(dmginfo)
                        
                    end
                end
                
            end
            
            self:Remove()
            
        end
        
        self:NextThink(CurTime())
        return true
        
    end
    
    function ENT:OnRemove()
        if self.WhirrSound then self.WhirrSound:Stop() end
        if IsValid(self.Fear) then self.Fear:Fire("kill") end
    end
    
    function ENT:PhysicsCollide(data,phys)
        local trace = {}
        trace.start = self:GetPos()
        trace.endpos = data.HitPos
        trace.filter = self
        trace.mask = MASK_SHOT
        trace.mins = self:OBBMins()
        trace.maxs = self:OBBMaxs()
        local tr = util.TraceHull(trace)

        if self:IsValid() && !self.Hit then
            if tr.Hit && tr.HitSky then self:Remove() end
            local Pos1 = tr.HitPos + tr.HitNormal * 2
            local Pos2 = tr.HitPos - tr.HitNormal * 2
            util.Decal("scorch", Pos1, Pos2) //This doesn't actually work
            self:SetMoveType(MOVETYPE_NONE)
            self:SetCollisionGroup(COLLISION_GROUP_NONE)
            self.DamagePos = data.HitPos
            self.Hit = true
        end
    end
    
    local function DamageHook(ent, dmginfo)
		local attacker = dmginfo:GetAttacker()
		local inflictor = dmginfo:GetInflictor()
        if ent:GetClass() == "ut2k4_shockcore" && dmginfo:GetDamageType() == DMG_ENERGYBEAM then
            ent.Owner = attacker
            ent.Inflictor = inflictor
            ent.Hit = true
            ent.Combo = true
        end
    end
    hook.Add("EntityTakeDamage","ShockCoreDamage",DamageHook)
    
    local function DenyCoreMoving(ply, ent)
        if ent:GetClass() == "ut2k4_shockcore" then return false end //go away sam
    end
    hook.Add("PhysgunPickup", "DenyCorePhysGunning", DenyCoreMoving)
    
//end