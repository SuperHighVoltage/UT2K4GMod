game.AddAmmoType( 
{
    name        =   "Shock core",
    dmgtype     =   DMG_BULLET,
    tracer      =   TRACER_LINE_AND_WHIZ,
    plydmg      =   30,
    npcdmg      =   30,
    force       =   100,
    minsplash   =   10,
    maxsplash   =   100
})

// Variables that are used on both client and server
                               
SWEP.PrintName = "UT2K4 Shock Rifle"   
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
 
SWEP.Primary.DefaultAmmoAmmount        = 100 					// Default number of ammo in the gun
SWEP.Primary.Automatic          = true                         // Automatic/Semi Auto
SWEP.Primary.Ammo               = "Shock core"
SWEP.Primary.AmmoName		= "Shock cores"		
SWEP.Primary.Delay = 0.64
SWEP.Primary.Sound = "UT2K4/Weapons/ShockRifleFire.wav"  
 
SWEP.Secondary.Automatic        = true                         // Automatic/Semi Auto
SWEP.Secondary.Delay = 0.55
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
				if SERVER then
					local dmginfo = DamageInfo()
					dmginfo:SetAttacker(self.Owner)
					dmginfo:SetInflictor(self.Weapon)
					dmginfo:SetDamage(45)
					dmginfo:SetDamageType(DMG_ENERGYBEAM)
					dmginfo:SetDamagePosition(tr.HitPos)
					dmginfo:SetDamageForce(vecSub*2000)
					tr.Entity:TakeDamageInfo(dmginfo)
				end
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

function SWEP:CreateCore()

	if IsValid(self.Owner) && IsValid(self.Weapon) then

		if (SERVER) then
		
			local ent = ents.Create("ut2k4_shockcore")
			if !ent then return end
			ent.Owner = self.Owner
			ent.Inflictor = self.Weapon
			ent:SetOwner(self.Owner)
			local eyeang = self.Owner:GetAimVector():Angle()
			local right = eyeang:Right()
			local up = eyeang:Up()
			ent:SetPos(self.Owner:GetShootPos()+right*4+up)
			ent:SetAngles(self.Owner:GetAngles())
			ent:SetPhysicsAttacker(self.Owner)
			ent:Spawn()
				
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then                
				phys:SetVelocity(self.Owner:GetAimVector()*1000)
			end
			    MsgN("am i server")
			
		end
		
		if !IsFirstTimePredicted() then return end
		
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			local fx = EffectData()
			fx:SetEntity(self.Weapon)
			util.Effect("ut2k4_shockcoremuzzle", fx)    
		end

	end

end

function SWEP:PrimaryAttack()
if ( !self:CanPrimaryAttack() ) then return end
    self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay)		//doesn't let you fire again until the weapons done reloading
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay)	
	
	self.Weapon:EmitSound(Sound(self.Primary.Sound))
	self:TakePrimaryAmmo( 1 )
	

    self:CreateBeam()

    if (self.Owner:IsNPC()) then return end
    
 //   if ((SinglePlayer() && SERVER) || CLIENT) then
        self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
 //   end

end
 
function SWEP:SecondaryAttack()
if ( !self:CanPrimaryAttack() ) then return end
    self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self.Weapon:EmitSound(Sound(self.Secondary.Sound))
	self:TakePrimaryAmmo( 1 )
	
	
    self:CreateCore()
    
    if (self.Owner:IsNPC()) then return end
    
//    if ((SinglePlayer() && SERVER) || CLIENT) then
        self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
//    end
	
end
function SWEP:DrawHUD()
	self.ammocount = self:Ammo1()
end
local AmmoDisplay = {};
function SWEP:CustomAmmoDisplay()
	if !UT2K4.HUD then	
		AmmoDisplay.Draw = true;
		AmmoDisplay.PrimaryClip = self.ammocount or 0; 	//self:GetNumAmmo()
		AmmoDisplay.PrimaryAmmo = -1;
		AmmoDisplay.SecondaryClip = -1;
		AmmoDisplay.SecondaryAmmo = -1;
		return AmmoDisplay;
	end	
end