//lua_run_cl MsgN(LocalPlayer():GetActiveWeapon():LowAmmo())
//lua_run_cl MsgN(LocalPlayer():GetActiveWeapon():Ammo1())

// Variables that are used on both client and server
 
SWEP.IsUT2K4Wep = true		//Just leave this alone
  
SWEP.Author					= ""
SWEP.Contact            	= ""
SWEP.Purpose            	= ""
SWEP.Instructions      	 	= ""
 
SWEP.ViewModelFOV       	= 50
SWEP.ViewModelFlip      	= false
SWEP.ViewModel          	= "models/weapons/v_pistol.mdl"
SWEP.WorldModel         	= "models/weapons/w_357.mdl"
SWEP.AnimPrefix         	= "python"
 
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.HoldType = "zombie"   

if CLIENT then
	SWEP.Icon					= {["Icon"] = surface.GetTextureID( "vgui/UT2K4/Lightning_icon" ),	["Ammo"] = surface.GetTextureID( "vgui/UT2K4/Lightning_ammo" ),	["x"] = 0,	["y"] = 0,	["h"] = 20, ["w"] = 80}		//surface.GetTextureID( "vgui/UT2K4/Lightning_icon" )
end

SWEP.FiresUnderwater = true

SWEP.Primary.ClipSize		= 0                     		// Size of a clip
SWEP.Primary.DefaultClip	= 0                            // Default number of bullets in a clip
SWEP.Primary.Automatic		= true                    		// Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"
SWEP.Primary.AmmoName		= "AMMOOO!!"							//The name of the ammo to show on the HUD
SWEP.Primary.Delay = 1 
SWEP.Primary.Sound 			= "UT2K4_RocketLauncher.Fire"  
 
SWEP.Secondary.ClipSize	= -1                      		// Size of a clip
SWEP.Secondary.DefaultClip	= 0                           	// Default number of bullets in a clip
SWEP.Secondary.Automatic	= true                         	// Automatic/Semi Auto
SWEP.Secondary.Ammo			= ""
SWEP.Secondary.AmmoName		= "SECONDARY AMMOOO!!"
SWEP.Secondary.Delay 		= 2
SWEP.Secondary.Sound		= "UT2K4_RocketLauncher.AltFire" 

SWEP.LowAmmoNum				= 8								// How much ammo until your low on ammo
 
SWEP.DeploySound 			= "UT2K4/Weapons/RocketLauncherSwitchTo.wav"
//SWEP.Reload.Sound 		= "UT2K4/Weapons/RocketLauncherLoad.wav"

//SWEP.Reload.Delay 		= .5	//time before the weapon reloads
//SWEP.Reload.Speed 		= .4	//length of reload (animation)
SWEP.ammoInGun = 0

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
//	if CLIENT then
//		language.Add(self.Primary.Ammo.."_ammo",self.Primary.AmmoName)
//		if self.Secondary.Ammo != self.Primary.Ammo and self.Secondary.Ammo != "none" then
//			language.Add(self.Secondary.Ammo.."_ammo",self.Secondary.AmmoName) 
//		end
//	end
end
 
function SWEP:PrimaryAttack()
	self:ShootEffects()	//plays animations, sets delay, takes ammo
	self.Weapon:EmitSound(Sound(self.Primary.Sound))
	self:TakePrimaryAmmo( 1 )
	self:ShootBullet( 3, 1, 0.2 )
--[[	
		weapon fire code
]]--	
end
 
function SWEP:SecondaryAttack()
 
end


function SWEP:Holster( wep )
        return true
end
 
function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:EmitSound(Sound(self.DeploySound))
        return true
end
 
function SWEP:ShootEffects() //delay until
	
	MsgN("The SWEP "..tostring(self.Weapon).." is still using ShootEffects()")
 
    self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay)		//doesn't let you fire again until the weapons done reloading
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay)	
	
	--[[	
	if self.Owner:GetAmmoCount( self.Primary.Ammo) == 0 then
		self.Owner:SetActiveWeapon(table.Random(self.Owner:GetWeapons()))	//switch to a random weapon
	else

		timer.Simple( self.Reload.Delay, function()
			if self.Owner then
				self.Weapon:DefaultReload( ACT_VM_RELOAD );
				self.Weapon:EmitSound(Sound(self.Reload.Sound))
			end 
		end)
		
	end]]--
end

function SWEP:ShootBullet( damage, num_bullets, aimcone )
       
        local bullet = {}
        bullet.Num              = num_bullets
        bullet.Src              = self.Owner:GetShootPos()	// Source
        bullet.Dir              = self.Owner:GetAimVector()	// Dir of bullet
        bullet.Spread   = Vector( aimcone, aimcone, 0 )		// Aim Cone
        bullet.Tracer   = 5									// Show a tracer on every x bullets
        bullet.Force    = 1									// Amount of force to give to phys objects
        bullet.Damage   = damage
        bullet.AmmoType = self.Primary.Ammo
       
        self.Owner:FireBullets( bullet )
		
end

/*---------------------------------------------------------
   Name: SWEP:TakePrimaryAmmo(   )
   Desc: My custom function to remove ammo because there are no clips in these weapons
---------------------------------------------------------*/
function SWEP:TakePrimaryAmmo( num )
--[[	   old Take ammo code   
        // Doesn't use clips
       if ( self.Weapon:Clip1() <= 0 ) then
       
                if ( self:Ammo1() <= 0 ) then return end
               
                self.Owner:RemoveAmmo( num, self.Weapon:GetPrimaryAmmoType() )
       
			return 
		end
       
        self.Weapon:SetClip1( self.Weapon:Clip1() - num )  
]]--	
if !self.Owner:IsNPC() then
		self.Owner:RemoveAmmo( num, self.Primary.Ammo )
//		self.Owner:SetAmmo( self.Owner:GetAmmoCount(self.Primary.Ammo) - num, self.Primary.Ammo )
end
self.ammoInGun = self.Owner:GetAmmoCount(self.Primary.Ammo)
end
 
 
/*---------------------------------------------------------
   Name: SWEP:TakeSecondaryAmmo(   )
   Desc: My custom function to remove ammo because there are no clips in these weapons
---------------------------------------------------------*/
function SWEP:TakeSecondaryAmmo( num )	//most weapons use primary ammo for secondary fire anyways
--[[      
        // Doesn't use clips
        if ( self.Weapon:Clip2() <= 0 ) then
       
                if ( self:Ammo2() <= 0 ) then return end
               
                self.Owner:RemoveAmmo( num, self.Weapon:GetSecondaryAmmoType() )
       
        return end
       
        self.Weapon:SetClip2( self.Weapon:Clip2() - num )      
--]]	
if !self.Owner:IsNPC() then
		self.Owner:RemoveAmmo( num, self.Secondary.Ammo )
//		self.Owner:SetAmmo( self.Owner:GetAmmoCount(self.Secondary.Ammo) - num, self.Secondary.Ammo )
end
end


/*---------------------------------------------------------
   Name: SWEP:CanPrimaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()
 if self.Owner:IsNPC() then return true end
        if (self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then		//if there is no ammo
				//self.Weapon:EmitSound( "Weapon_Pistol.Empty" )
                self:SetNextPrimaryFire( CurTime() + 0.2 )
				
                if ( self.Owner:GetAmmoCount(self.Secondary.Ammo )) then
					//no ammo at all so switch weapon
				end
                return false
               
        end
 
        return true
 
end
 
 
/*---------------------------------------------------------
   Name: SWEP:CanSecondaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------*/
function SWEP:CanSecondaryAttack()
	if self.Owner:IsNPC() then return true end
        if ( self.Owner:GetAmmoCount(self.Secondary.Ammo) <= 0) then
       
                //self.Weapon:EmitSound( "Weapon_Pistol.Empty" )
                self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 )		
				
                if ( self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 ) then
					//no ammo at all so switch weapon
				end
                return false
               
        end
 
        return true
 
end
 
function SWEP:LowAmmo()

	if self.Owner:GetAmmoCount(self.Primary.Ammo) <= self.LowAmmoNum then
		return true
	end
	
	return false
end
 
 
/*---------------------------------------------------------
   Name: Ammo1
   Desc: Returns how much of ammo1 the player has
---------------------------------------------------------*/
function SWEP:Ammo1()
        return self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() )
end
 
 
/*---------------------------------------------------------
   Name: Ammo2
   Desc: Returns how much of ammo2 the player has
---------------------------------------------------------*/
function SWEP:Ammo2()
        return self.Owner:GetAmmoCount( self.Weapon:GetSecondaryAmmoType() )
end
 
/*---------------------------------------------------------
   Name: SetDeploySpeed
   Desc: Sets the weapon deploy speed.
                 This value needs to match on client and server.
---------------------------------------------------------*/
function SWEP:SetDeploySpeed( speed )
        self.m_WeaponDeploySpeed = tonumber( speed )
end