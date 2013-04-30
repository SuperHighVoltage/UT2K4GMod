// Variables that are used on both client and server
                                         
SWEP.PrintName = "UT2K4 MiniGun"   
SWEP.Category = "UT2K4"    
SWEP.Author             = "Highvoltage"
SWEP.Contact            = ""
SWEP.Purpose            = ""
SWEP.Instructions       = "Inexpensive and easily produced, the AR770 provides a lightweight 5.56mm combat solution that is most effective against unarmored foes. With low-to-moderate armor penetration capabilities, this rifle is best suited to a role as a light support weapon.|The optional M355 Grenade Launcher provides the punch that makes this weapon effective against heavily armored enemies.  Pick up a second assault rifle to double your fire power."

SWEP.SlotPos = 4           
SWEP.Slot = 2  
SWEP.AutoSwitchTo = true      
SWEP.AutoSwitchFrom = true    
SWEP.Weight = 5    

SWEP.SwayScale                  = 1.0                                   // The scale of the viewmodel sway
SWEP.BobScale                   = 0.3                                   // The scale of the viewmodel bob

SWEP.ViewModel          = "models/weapons/v_ut2k4_minigun.mdl"
SWEP.WorldModel         = "models/weapons/w_minigun.mdl"
 
SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

SWEP.Base = "ut2k4_baseweapon"

if CLIENT then
	SWEP.Icon					= {["Icon"] = surface.GetTextureID( "vgui/UT2K4/Mini_icon" ),	["Ammo"] = surface.GetTextureID( "vgui/UT2K4/Mini_ammo" ),	["x"] = 0,	["y"] = 0,	["h"] = 20, ["w"] = 80}		//surface.GetTextureID( "vgui/UT2K4/Lightning_icon" )
end
 
SWEP.Primary.DefaultAmmoAmmount        = 300 					// Default number of ammo in the gun
SWEP.Primary.Automatic          = true                         // Automatic/Semi Auto
SWEP.Primary.Ammo               = "StriderMinigun"
SWEP.Primary.AmmoName		= "MiniGun rounds"					//The name of the ammo to show on the HUD
SWEP.Primary.Delay = 0.057
SWEP.Primary.Sound = "UT2K4/Weapons/MinigunFire.wav" 
 
SWEP.Secondary.Automatic        = true                         // Automatic/Semi Auto
SWEP.Secondary.Delay = 0.068
SWEP.Secondary.Sound = "UT2K4/Weapons/MinigunAltFire.wav" 

SWEP.LowAmmoNum		= 50										// How much ammo until your low on ammo
SWEP.HoldType = "shotgun"  
SWEP.DeploySound = "UT2K4/Weapons/SwitchToMiniGun.wav"

SWEP.Charge = 0

SWEP.LastSoundTime = 0
SWEP.LastSoundTime2 = 0

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	if CLIENT then
		language.Add(self.Primary.Ammo.."_ammo",self.Primary.AmmoName)
		if self.Secondary.Ammo != self.Primary.Ammo and self.Secondary.Ammo != "none" then
			language.Add(self.Secondary.Ammo.."_ammo",self.Secondary.AmmoName) 
		end
	end
	self.Primary.Sound = CreateSound(self, Sound(self.Primary.Sound) )
end

function SWEP:PrimaryAttack()
if ( !self:CanPrimaryAttack() ) then return end
	if self.LastSoundTime+1.1 < CurTime() then
		//self.Weapon:EmitSound(Sound(self.Primary.Sound))
		if !self.Primary.Sound:IsPlaying() then
			self.Primary.Sound:Play()
		end
		self.LastSoundTime = CurTime()
		self:TakePrimaryAmmo( 1 )
	end
	self:ShootEffects()	//plays animations, sets delay, takes ammo
//	self:TakePrimaryAmmo( 1 )
	self:ShootBullet( 3, 1, 0.01 )
end
 
function SWEP:SecondaryAttack()
if ( !self:CanPrimaryAttack() ) then return end
	if self.LastSoundTime2+1.01 < CurTime() then
		self.Primary.Sound:Stop()
		self.Weapon:EmitSound(Sound(self.Secondary.Sound))
		self.LastSoundTime2 = CurTime()
		self:TakePrimaryAmmo( 1 )
	end
	self:ShootEffects()	//plays animations, sets delay, takes ammo
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay)	
//	self:TakePrimaryAmmo( 1 )
	self:ShootBullet( 6, 1, 0.05 )
end

--[[
function SWEP:ViewModelDrawn()
	local lolmat = Material("trails/laser.vmt")
	local lolmat2 = Material("sprites/redglow1.vmt")
	
	local tr = util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector()*999999, self.Owner )
	local tr2 = util.QuickTrace( self.Owner:EyePos(), self.Owner:GetAimVector()*0.01, self.Owner )
	local posang = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")) ------------------------------------------------------
	render.SetMaterial( lolmat )
	render.DrawBeam(posang.Pos+self.Owner:GetAimVector()*3,tr.HitPos,1.15,0,0,Color(255,0,0))
	render.SetMaterial( lolmat2 )
	render.DrawSprite( tr.HitPos, 15, 15, Color(255,255,255,255))
end]]--


