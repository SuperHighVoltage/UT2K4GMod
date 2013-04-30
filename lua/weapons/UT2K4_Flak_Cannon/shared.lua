game.AddAmmoType( 
{
    name        =   "Flak shell",
    dmgtype     =   DMG_BULLET,
    tracer      =   TRACER_LINE_AND_WHIZ,
    plydmg      =   30,
    npcdmg      =   30,
    force       =   100,
    minsplash   =   10,
    maxsplash   =   100
})

// Variables that are used on both client and server
                                         
SWEP.PrintName = "UT2K4 Flak Cannon"      
SWEP.Category = "UT2K4"    
SWEP.Author             = "Highvoltage"
SWEP.Contact            = ""
SWEP.Purpose            = "Trident Defensive Technologies Series 7 Flechette Cannon has been taken to the next step in evolution with the production of the Mk3 'Negotiator'. The ionized flechettes are capable of delivering second and third-degree burns to organic tissue, cauterizing the wound instantly.\nPayload delivery is achieved via one of two methods: ionized flechettes launched in a spread pattern directly from the barrel; or via fragmentation grenades that explode on impact, radiating flechettes in all directions."
SWEP.Instructions       = ""

SWEP.SlotPos = 0           
SWEP.Slot = 3  
SWEP.AutoSwitchTo = true      
SWEP.AutoSwitchFrom = true    
SWEP.Weight = 5    

SWEP.ViewModel = "models/weapons/v_ut2k4_Flak_Cannon.mdl"
SWEP.WorldModel = "models/weapons/w_ut2k4_Flak_Cannon.mdl"
 
SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

if CLIENT then
	SWEP.Icon					= {["Icon"] = surface.GetTextureID( "vgui/UT2K4/Flak_icon" ),	["Ammo"] = surface.GetTextureID( "vgui/UT2K4/Flak_ammo" ),	["x"] = 0,	["y"] = 0,	["h"] = 20, ["w"] = 80}		//surface.GetTextureID( "vgui/UT2K4/Lightning_icon" )
end

SWEP.Base = "ut2k4_baseweapon"
 
SWEP.Primary.DefaultAmmoAmmount        = 35 					// Default number of ammo in the gun
SWEP.Primary.Automatic          = true                         // Automatic/Semi Auto
SWEP.Primary.Ammo               = "Flak shell"
SWEP.Primary.AmmoName		= "Flak shells"					//The name of the ammo to show on the HUD
SWEP.Primary.Delay = 0.5
SWEP.Primary.Sound = "UT2K4/Weapons/FlakCannonFire.wav"  
 
SWEP.Secondary.Automatic        = true                         // Automatic/Semi Auto
SWEP.Secondary.Delay = 0.7
SWEP.Secondary.Sound = "UT2K4/Weapons/FlakCannonAltFire.wav" 

SWEP.LowAmmoNum		= 5										// How much ammo until your low on ammo
SWEP.HoldType = "shotgun"  
SWEP.DeploySound = "UT2K4/Weapons/RocketLauncherSwitchTo.wav"

function SWEP:Shoot_Flak(num)

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

	for i=1,num do 
		local rnd1 = math.random(-3,3)
		local rnd2 = math.random(-3,3)
		local rnd3 = math.random(-3,3)
		local rndAng = Angle(rnd1, rnd2, rnd3)		//spread the flechettes
		local angle = (aim:Angle() + rndAng)
		
		f = angle:Forward()

		UT.SpawnProjectile(UT_PROJECTILE_FLECHETTE,pos,f*2500,self.Owner)
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

	if(SERVER) then
		self:Shoot_Flak( 6 )	//shoot 6 flechettes
	end
end
 
function SWEP:SecondaryAttack()
if ( !self:CanPrimaryAttack() ) then return end
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )	
	self.Weapon:EmitSound(Sound(self.Secondary.Sound))	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self:TakePrimaryAmmo( 1 )

	local aim = self.Owner:GetAimVector()
	local side = aim:Cross(Vector(0,0,1))
	local up = side:Cross(aim)
	
	local model = self.Owner:GetViewModel()
	local attach = model:LookupAttachment( "muzzle" );
	local at = model:GetAttachment(attach)
	local f = at.Ang:Up()*-1
	pos = at.Pos + self.Owner:GetViewOffset()
	

    local shell = ents.Create("UT2K4_Flak_shell")
	if !shell:IsValid() then return false end
	shell:SetAngles(aim:Angle())//at.Ang
	shell:SetPos(pos)
	shell:SetOwner(self.Owner)
	shell:Spawn()
	shell:Activate()
	shell:SetVelocity(shell:GetForward()*900)
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