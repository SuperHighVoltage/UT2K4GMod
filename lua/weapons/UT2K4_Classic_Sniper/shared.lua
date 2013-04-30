game.AddAmmoType( 
{
    name        =   "Sniper rounds",
    dmgtype     =   DMG_BULLET,
    tracer      =   TRACER_LINE_AND_WHIZ,
    plydmg      =   60,
    npcdmg      =   60,
    force       =   300,
    minsplash   =   10,
    maxsplash   =   100
})

// Variables that are used on both client and server
                                         
SWEP.PrintName = "UT2K4 Sniper Rifle"   
SWEP.Category = "UT2K4"    
SWEP.Author             = "Highvoltage"
SWEP.Contact            = ""
SWEP.Purpose            = ""
SWEP.Instructions       = "This high muzzle velocity sniper rifle with a 10X scope is a lethal weapon at any range, especially if you can land a head shot."

SWEP.SlotPos = 0           
SWEP.Slot = 4  
SWEP.AutoSwitchTo = true      
SWEP.AutoSwitchFrom = true    
SWEP.Weight = 5    

SWEP.ViewModel          = "models/weapons/v_ut2k4_sniper_rifle.mdl"
SWEP.WorldModel         = "models/weapons/w_ut2k4_sniper_rifle.mdl"
 
SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

if CLIENT then
	SWEP.Icon					= {["Icon"] = surface.GetTextureID( "vgui/UT2K4/Lightning_icon" ),	["Ammo"] = surface.GetTextureID( "vgui/UT2K4/Lightning_ammo" ),	["x"] = 0,	["y"] = 0,	["h"] = 20, ["w"] = 80}		//surface.GetTextureID( "vgui/UT2K4/Lightning_icon" )
end

SWEP.Base = "ut2k4_baseweapon"
 
SWEP.Primary.DefaultAmmoAmmount        = 15 					// Default number of ammo in the gun
SWEP.Primary.Automatic          = true                         // Automatic/Semi Auto
SWEP.Primary.Ammo               = "Sniper rounds"
SWEP.Primary.AmmoName		= "Sniper rounds"		
SWEP.Primary.Delay = 1.21
SWEP.Primary.Sound = "UT2K4/Weapons/ClassicSniperShot.wav"  

SWEP.LowAmmoNum		= 4										// How much ammo until your low on ammo
SWEP.HoldType = "shotgun"  
SWEP.HoldTypeZoomed = "ar2"  
SWEP.DeploySound = "UT2K4/Weapons/ClassicSniper_load.wav"

SWEP.dropped = false

function SWEP:Reload()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )	// Sets when you can shoot next
	timer.Simple( self.Primary.Delay-.9, function()
		if self.dropped == false then
			self:EmitSound("UT2K4/Weapons/ClassicSniper_load.wav")
		end 
	end)
end

--[[ Shoot lightning bolt ]]--
function SWEP:PrimaryAttack()
if ( !self:CanPrimaryAttack() ) then return end
	self:TakePrimaryAmmo( 1 )
	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound(Sound(self.Primary.Sound))
	

	local bullet = {}

	bullet.Num 	= 1
	bullet.Src 	= self.Owner:GetShootPos() -- Source
	bullet.Dir 	= self.Owner:GetAimVector() -- Dir of bullet
	bullet.Spread 	= Vector( 0, 0, 0 )	 -- Aim Cone
	bullet.Tracer	= 1 -- Show a tracer on every x bullets 
	bullet.Force	= 1 -- Amount of force to give to phys objects
	bullet.Damage	= 60
	bullet.AmmoType = "Sniper rounds"
	
	self.Owner:FireBullets( bullet )
	
	self:ShootEffects()
	
	self:Reload()
end
 
function SWEP:SecondaryAttack()
	local Zooming = self:GetZooming()
	
	if self.Owner:KeyPressed(IN_ATTACK2) then
		Zooming = !Zooming
		self:SetZooming(Zooming)
	end
end

function SWEP:Think()
	local ZoomAmmount = self:GetZoomAmmount()
	local Zooming = self:GetZooming()

	if self.Owner:KeyDown(IN_ATTACK2) then
		if Zooming == true then
			if (ZoomAmmount > 10) then
				ZoomAmmount = ZoomAmmount-1
				self:SetZoomAmmount(ZoomAmmount)
				if ( SERVER ) then	
					self.Owner:DrawViewModel(false)	
					self.Owner:SetFOV( ZoomAmmount, 0 )	
				end
			end
		end
	end

	if self.Owner:KeyReleased(IN_ATTACK2) then	
		if Zooming == false then
			self:SetZoomAmmount(60)
			if ( SERVER ) then	
				self.Owner:DrawViewModel(true)	
				self.Owner:SetFOV( 0, 0.5 )	
			end		
		end
	end
	if Zooming == true then		//if zoomed
		self:SetWeaponHoldType( self.HoldTypeZoomed )
	else
		self:SetWeaponHoldType( self.HoldType )
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "ZoomAmmount" );
	self:NetworkVar( "Bool", 0, "Zooming" );
end

local UT2K4_CrossHairSize = 50
function SWEP:DrawHUD()
	local ZoomAmmount = self:GetZoomAmmount()
	local Zooming = self:GetZooming()
	local ZoomTex = surface.GetTextureID( "vgui/UT2K4/Lightning_Scope" );
	local ShowCharge = false
	if Zooming == true then
		surface.SetTexture( ZoomTex );	
		surface.SetDrawColor( 255, 255, 255, 255 );
		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() );	
	end		
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

function SWEP:OnDrop()			//Called when the weapon has been dropped. 
	self.dropped = true
	MsgN("Dropped Lightning Gun")
end


--[[Weapon info from UT2K4
//Rocket Launcher info
The Trident Tri-barrel Rocket Launcher is extremely popular among competitors who enjoy more bang for their buck.
The rotating rear loading barrel design allows for both single- and multi-warhead launches, letting you place up to three dumb fire rockets on target.
The warheads are designed to deliver maximum concussive force to the target and surrounding area upon detonation.

//Shock Rifle info
The ASMD Shock Rifle has changed little since its incorporation into the Tournaments. The ASMD sports two firing modes capable of acting in concert to neutralize opponents in a devastating shockwave.

This combination attack is achieved when the weapon operator utilizes the secondary fire mode to deliver a charge of seeded plasma to the target.
Once the slow-moving plasma charge is within range of the target, the weapon operator may fire the photon beam into the plasma core, releasing the explosive energy of the anti-photons contained within the plasma's EM field.

//Minigun info
The Schultz-Metzger T23-A 23mm rotary cannon is capable of firing both high-velocity caseless ammunition and cased rounds. With an unloaded weight of only 8 kilograms, the T23 is portable and maneuverable, easily worn across the back when employing the optional carrying strap.
The T23-A is the rotary cannon of choice for the discerning soldier.

//Flak cannon info
Trident Defensive Technologies Series 7 Flechette Cannon has been taken to the next step in evolution with the production of the Mk3 "Negotiator". The ionized flechettes are capable of delivering second and third-degree burns to organic tissue, cauterizing the wound instantly.
Payload delivery is achieved via one of two methods: ionized flechettes launched in a spread pattern directly from the barrel; or via fragmentation grenades that explode on impact, radiating flechettes in all directions.

//Biorifle info
The GES BioRifle continues to be one of the most controversial weapons in the Tournament. Loved by some, loathed by others, the BioRifle has long been the subject of debate over its usefulness.

Some Tournament purists argue that it is the equivalent of a cowardly minefield. Others argue that it enhances the tactical capabilities of defensive combatants.
Despite the debate, the weapon provides rapid-fire wide-area coverage in primary firing mode, and a single-fire variable payload secondary firing mode. In layman's terms, this equates to being able to pepper an area with small globs of Biosludge, or launch one large glob at the target.

//Sheild gun info
The Kemphler DD280 Riot Control Device has the ability to resist and reflect incoming projectiles and energy beams. The plasma wave inflicts massive damage, rupturing tissue, pulverizing organs, and flooding the bloodstream with dangerous gas bubbles.

This weapon may be intended for combat at close range, but when wielded properly should be considered as dangerous as any other armament in your arsenal.

//Lightning Gun info
The Lightning Gun is a high-power energy rifle capable of ablating even the heaviest carapace armor. Acquisition of a target at long range requires a steady hand, but the anti-jitter effect of the optical system reduces the weapon's learning curve significantly. Once the target has been acquired, the operator depresses the trigger, painting a proton 'patch' on the target. Milliseconds later the rifle emits a high voltage arc of electricity, which seeks out the charge differential and annihilates the target.
--]]