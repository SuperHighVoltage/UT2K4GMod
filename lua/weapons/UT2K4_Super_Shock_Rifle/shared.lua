// Variables that are used on both client and server
                               
SWEP.PrintName = "UT2K4 Super Shock Rifle"   
SWEP.Category = "UT2K4"    
SWEP.Author             = "JusticeInACan"
SWEP.Contact            = ""
SWEP.Purpose            = ""
SWEP.Instructions       = "The ASMD Shock Rifle has changed little since its incorporation into the Tournaments. The ASMD sports two firing modes capable of acting in concert to neutralize opponents in a devastating shockwave.||This combination attack is achieved when the weapon operator utilizes the secondary fire mode to deliver a charge of seeded plasma to the target.|Once the slow-moving plasma charge is within range of the target, the weapon operator may fire the photon beam into the plasma core, releasing the explosive energy of the anti-photons contained within the plasma's EM field."

SWEP.SlotPos = 0           
SWEP.Slot = 2  
SWEP.AutoSwitchTo = true      
SWEP.AutoSwitchFrom = true    
SWEP.Weight = 50    

//SWEP.SwayScale                  = 1.0                                   // The scale of the viewmodel sway
//SWEP.BobScale                   = 0.3                                   // The scale of the viewmodel bob
 
SWEP.ViewModel          = "models/weapons/v_ut2k4_shock_rifle.mdl"
SWEP.WorldModel         = "models/weapons/w_ut2k4_shock_rifle.mdl"
 
SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

if CLIENT then
	SWEP.Icon	= {
		["Icon"] = surface.GetTextureID( "vgui/UT2K4/Shock_icon" ),	
		["Ammo"] = surface.GetTextureID( "vgui/UT2K4/Shock_ammo" ),	
		["x"] = 0,	
		["y"] = 0,	
		["h"] = 20, 
		["w"] = 80
	}
end

SWEP.Base = "ut2k4_baseweapon"
 
SWEP.Primary.DefaultAmmoAmmount        = 0 					// Default number of ammo in the gun
SWEP.Primary.Automatic          = true                         // Automatic/Semi Auto
SWEP.Primary.Ammo               = "none"
SWEP.Primary.AmmoName		= ""		
SWEP.Primary.Delay = 0.64
SWEP.Primary.Sound = "UT2K4/Weapons/ShockRifleFire.wav"  
 
SWEP.Secondary.Automatic        = true                         // Automatic/Semi Auto
SWEP.Secondary.Delay = 0.64
SWEP.Secondary.Sound = "UT2K4/Weapons/ShockRifleAltFire.wav" 

SWEP.LowAmmoNum		= 6										// How much ammo until your low on ammo
SWEP.HoldType = "shotgun"  
SWEP.DeploySound = "UT2K4/Weapons/SwitchToShockRifle.wav"

function SWEP:CreateBeam()

	if IsValid(self.Owner) && IsValid(self.Weapon) then
		
		local tracedata = {}
		tracedata.start = self.Owner:GetShootPos()
		tracedata.endpos = self.Owner:GetShootPos()+(self.Owner:GetAimVector()*999999)
		tracedata.filter = self.Owner
		tracedata.mins = Vector(-2,-2,-2)
		tracedata.maxs = Vector(2,2,2)
		local tr = util.TraceHull(tracedata)
		
		if tr.Hit then
		
			if IsValid(tr.Entity) then
			
//				if SERVER then
				
				local vecSub = self.Owner:GetAimVector()
				local phys = tr.Entity:GetPhysicsObject()    
				if IsValid(phys) then
					phys:ApplyForceOffset(vecSub*10000,tr.HitPos)
					//phys:ApplyForceCenter(vecSub*2000)
				else
					tr.Entity:SetVelocity(vecSub*2000)
				end
				//if SERVER then
					local dmginfo = DamageInfo()
					dmginfo:SetAttacker(self.Owner)
					dmginfo:SetInflictor(self.Weapon)
					dmginfo:SetDamage(4500)
					dmginfo:SetDamageType(DMG_ENERGYBEAM)
					dmginfo:SetDamagePosition(tr.HitPos)
					dmginfo:SetDamageForce(vecSub*2000)
					tr.Entity:TakeDamageInfo(dmginfo)
				//end
//				end

				if tr.Entity:GetClass() == "ut2k4_shockcore" then
					self.Owner:RemoveAmmo(4, self.Primary.Ammo) //I don't remember if this was how it worked in the game or not
				end
				
			end
			
			if SERVER then
				sound.Play("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav",tr.HitPos,90,120)
			end
			
			local Pos1 = tr.HitPos + tr.HitNormal * 8
			local Pos2 = tr.HitPos - tr.HitNormal * 8
			util.Decal("fadingscorch", Pos1, Pos2)
			
			if !IsFirstTimePredicted() then return end
			
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				local fx = EffectData()
				fx:SetEntity(self.Weapon)
				fx:SetOrigin(tr.HitPos)
				fx:SetNormal(tr.HitNormal)
				util.Effect("ut2k4_shockbeam", fx, true)    
			end
			
		end

	end

end

function SWEP:PrimaryAttack()
//if ( !self:CanPrimaryAttack() ) then return end
    self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay)		//doesn't let you fire again until the weapons done reloading
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay)	
	
	self.Weapon:EmitSound(Sound(self.Primary.Sound))

    self:CreateBeam()

    if (self.Owner:IsNPC()) then return end
    
 //   if ((SinglePlayer() && SERVER) || CLIENT) then
        self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
 //   end

end
 
function SWEP:SecondaryAttack()
		self:PrimaryAttack()
end
