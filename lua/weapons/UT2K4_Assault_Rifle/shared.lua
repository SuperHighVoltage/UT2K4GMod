game.AddAmmoType( 
{
    name        =   "Assault rounds",
    dmgtype     =   DMG_BULLET,
    tracer      =   TRACER_LINE_AND_WHIZ,
    plydmg      =   30,
    npcdmg      =   30,
    force       =   100,
    minsplash   =   10,
    maxsplash   =   100
})

game.AddAmmoType( 
{
    name        =   "M355 grenades",
    dmgtype     =   DMG_BULLET,
    tracer      =   TRACER_LINE_AND_WHIZ,
    plydmg      =   30,
    npcdmg      =   30,
    force       =   100,
    minsplash   =   10,
    maxsplash   =   100
})

// Variables that are used on both client and server
                                         
SWEP.PrintName = "UT2K4 Assault Rifle"   
SWEP.Category = "UT2K4"    
SWEP.Author             = "Highvoltage"
SWEP.Contact            = ""
SWEP.Purpose            = ""
SWEP.Instructions       = "Inexpensive and easily produced, the AR770 provides a lightweight 5.56mm combat solution that is most effective against unarmored foes. With low-to-moderate armor penetration capabilities, this rifle is best suited to a role as a light support weapon.|The optional M355 Grenade Launcher provides the punch that makes this weapon effective against heavily armored enemies.  Pick up a second assault rifle to double your fire power."

SWEP.SlotPos = 1           
SWEP.Slot = 0  
SWEP.AutoSwitchTo = true      
SWEP.AutoSwitchFrom = true    
SWEP.Weight = 5    

SWEP.SwayScale                  = 1.0                                   // The scale of the viewmodel sway
SWEP.BobScale                   = 0.3                                   // The scale of the viewmodel bob

SWEP.ViewModel          = "models/weapons/v_UT2K4_Assault_rifle.mdl"
SWEP.WorldModel         = "models/weapons/w_smg1.mdl"
 
SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

if CLIENT then
	SWEP.Icon					= {["Icon"] = surface.GetTextureID( "vgui/UT2K4/Assault_icon" ),	["Ammo"] = surface.GetTextureID( "vgui/UT2K4/Assault_ammo" ),	["x"] = 0,	["y"] = 0,	["h"] = 40, ["w"] = 80}		//surface.GetTextureID( "vgui/UT2K4/Lightning_icon" )
end

SWEP.Base = "ut2k4_baseweapon"
 
SWEP.Primary.DefaultAmmoAmmount        = 100 					// Default number of ammo in the gun
SWEP.Primary.Automatic          = true                         // Automatic/Semi Auto
SWEP.Primary.Ammo               = "Assault rounds"
SWEP.Secondary.AmmoName			= "Assault rounds"
SWEP.Primary.Delay = 1/6.88
SWEP.Primary.Sound = "UT2K4/Weapons/AssaultRifleFire.wav"  
 
//SWEP.Secondary.ClipSize         = 0                                     // Size of a clip
SWEP.Secondary.DefaultClip      = 4                           // Default number of bullets in a clip
SWEP.Secondary.Automatic        = false                         // Automatic/Semi Auto
SWEP.Secondary.Ammo             = "M355 grenades"
SWEP.Secondary.AmmoName			= ""
SWEP.Secondary.Delay = 0.91
SWEP.Secondary.Sound = "UT2K4/Weapons/AssaultRifleAltFire.wav" 

SWEP.LowAmmoNum		= 20										// How much ammo until your low on ammo
SWEP.HoldType = "ar2"  
SWEP.DeploySound = "UT2K4/Weapons/RocketLauncherSwitchTo.wav"

SWEP.ChargeTime = 0
SWEP.ChargeAmmount = 0

function SWEP:PrimaryAttack()
if ( !self:CanPrimaryAttack() ) then return end
	self:TakePrimaryAmmo( 1 )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound(Sound(self.Primary.Sound))
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )	
	
	self:ShootBullet( 7, 1, 0.01 )
	
end
 
function SWEP:SecondaryAttack()
if ( !self:CanSecondaryAttack() ) then return end
	if self.Owner:KeyPressed(IN_ATTACK2) then
		self:SetCharging(true)
		self.ChargeTime = CurTime()
	end
end

function SWEP:FireGrenade()
	self:TakeSecondaryAmmo( 1 )
	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound(Sound(self.Secondary.Sound))
	self:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )	
	
	local model = self.Owner:GetViewModel()
	local attach = model:LookupAttachment( "muzzle" );
	local at = model:GetAttachment(attach)
	local f = at.Ang:Forward()
	pos = at.Pos + self.Owner:GetViewOffset()	//if Crouching() then GetViewOffsetDucked( )	//http://wiki.garrysmod.com/?title=Player.Crouching

	local aim = self.Owner:GetAimVector()
	local side = aim:Cross(Vector(0,0,1))
	local up = side:Cross(aim)
	local pos = self.Owner:GetShootPos() +  aim * 24 + side * 8 + up * -1	--offsets the rocket so it spawns from the muzzle (hopefully)

	local Grenade = ents.Create("UT2K4_Rifle_Grenade")
	if !Grenade:IsValid() then return false end
	Grenade:SetAngles(aim:Angle())
	Grenade:SetPos(pos)
	Grenade:SetOwner(self.Owner)
	Grenade:Spawn()
	//Grenade:Activate()
	//Grenade:SetVelocity(Grenade:GetForward()*(900+ (self.Charge*5)))
			
    local bPhys = Grenade:GetPhysicsObject()
    local Force = self.Owner:GetAimVector() * (700+ self:GetChargePercent()*5)
    bPhys:ApplyForceCenter(Force)
	bPhys:AddAngleVelocity( Vector(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000)) )
end

function SWEP:Think()
if CLIENT then return end
	local Charging = self:GetCharging()
	
//	if self.Owner:KeyPressed(IN_ATTACK2) then
//		Charging = !Charging
//		self:SetZooming(Charging)
//	end

	if self.Owner:KeyDown(IN_ATTACK2) then
		if Charging == true and self.ChargeAmmount < self.Secondary.Delay then
			self.ChargeAmmount = (CurTime()-self.ChargeTime)
			if self.ChargeAmmount > self.Secondary.Delay then self.ChargeAmmount = self.Secondary.Delay end
			self:SetChargePercent((self.ChargeAmmount/self.Secondary.Delay)*100)
		end
	end

	if self.Owner:KeyReleased(IN_ATTACK2) then	
		if Charging == true then
			self:FireGrenade()
			self.ChargeAmmount = 0
			self:SetChargePercent(0)
			self:SetCharging(False)
		end
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "ChargePercent" );
	self:NetworkVar( "Bool", 0, "Charging" );
end

//	local barTex 		= surface.GetTextureID( "vgui/UT2K4/HUD_bar1" );		//little rounded boxes
//	local chargeBar 		= surface.GetTextureID( "vgui/UT2K4/Power_Bar" );	//charge bar
local white = Material( "vgui/white" )
function SWEP:DrawHUD()
//	draw.SimpleTextOutlined( (900+ (self.Charge*5)), "HUDNumber5", 60, 20, Color(235, 235, 235, 255), 0, 0, 1, Color(25,25,25,255))	
	if UT2K4.HUD then
		local barTex 		= surface.GetTextureID( "vgui/UT2K4/HUD_bar1" );		//little rounded boxes
		local chargeBar 	= surface.GetTextureID( "vgui/UT2K4/Power_Bar" );		//charge bar
		local ChargePercent = self:GetChargePercent()
		
		local HUD_R 		= GetConVar( "UT2K4_HUD_R" ):GetInt()
		local HUD_G 		= GetConVar( "UT2K4_HUD_G" ):GetInt()	
		local HUD_B 		= GetConVar( "UT2K4_HUD_B" ):GetInt()	
		local HUD_A 		= GetConVar( "UT2K4_HUD_A" ):GetInt()	
		
		local GrenadeTex 	= surface.GetTextureID( "vgui/UT2K4/Grenade" );	
		surface.SetTexture( GrenadeTex );	
		for i=1,self.Owner:GetAmmoCount(self.Secondary.Ammo) do 
			local wide = i%4
			if wide == 0 then wide = 4 end
			local tall = (i-(wide))/4		
			surface.DrawTexturedRect( ScrW()-5-(32*wide), ScrH()-135-(32*tall) , 32, 32 );		
		end 
		
		surface.SetDrawColor( Color (HUD_R, HUD_G, HUD_B, HUD_A) );
		surface.SetTexture( barTex );									//		   bottom pading    ammo box        padding          
		surface.DrawTexturedRect( ScrW()-ScreenScale(65)-ScreenScale(2.5), ScrH()-ScreenScale(2.5)-ScreenScale(25)-ScreenScale(2.5)-35 , ScreenScale(65), 35 );
		if ChargePercent == 100 then
			HUD_A = math.abs(math.sin(CurTime()*15))*255 
		end
		surface.SetDrawColor( Color (HUD_R, HUD_G, HUD_B, HUD_A) );
		surface.SetTexture( chargeBar );			
		surface.DrawTexturedRectUV( ScrW()-ScreenScale(65), ScrH()-ScreenScale(2.5)-ScreenScale(25)-35 , ScreenScale(ChargePercent*0.6) , 26, 0, 0,ChargePercent/100,1 )
	else
		local charge = self:GetChargePercent()*2
		surface.SetDrawColor( Color (255, 255-charge, 0, 255) );
		surface.SetMaterial( white );								
		surface.DrawTexturedRect( ScrW()-charge, ScrH()-20, charge, 20);
		draw.SimpleTextOutlined( charge/2 , "Default", ScrW()-40, ScrH()-20, Color(235, 235, 235, 255), 0, 0, 1, Color(25,25,25,255))	
	end
	self.ammocount = self:Ammo1()
	self.ammocount2 = self:Ammo2()
end
local AmmoDisplay = {};
function SWEP:CustomAmmoDisplay()
	if !UT2K4.HUD then	
		AmmoDisplay.Draw = true;
		AmmoDisplay.PrimaryClip = self.ammocount or 0; 
		AmmoDisplay.PrimaryAmmo = self.ammocount2 or 0;
		AmmoDisplay.SecondaryClip = -1;
		AmmoDisplay.SecondaryAmmo = -1;
		return AmmoDisplay;
	end	
end