game.AddAmmoType( 
{
    name        =   "ASticky grenade",
    dmgtype     =   DMG_BULLET,
    tracer      =   TRACER_LINE_AND_WHIZ,
    plydmg      =   30,
    npcdmg      =   30,
    force       =   100,
    minsplash   =   10,
    maxsplash   =   100
})
MsgN("Clientside/serverside test")
// Variables that are used on both client and server
                                         
SWEP.PrintName = "UT2K4 Grenade Launcher"   
SWEP.Category = "UT2K4"    
SWEP.Author             = "Highvoltage"
SWEP.Contact            = ""
SWEP.Purpose            = ""
SWEP.Instructions       = "The MGG Grenade Launcher fires magnetic sticky grenades, which will attach to enemy players and vehicles."

SWEP.SlotPos = 1           
SWEP.Slot = 3  
SWEP.AutoSwitchTo = true      
SWEP.AutoSwitchFrom = true    
SWEP.Weight = 50    

//SWEP.SwayScale                  = 1.0                                   // The scale of the viewmodel sway
//SWEP.BobScale                   = 0.3                                   // The scale of the viewmodel bob
 
SWEP.ViewModel          = "models/weapons/v_ut2k4_grenade_launcher.mdl"
SWEP.WorldModel         = "models/weapons/w_ut2k4_grenade_launcher.mdl"
 
SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

if CLIENT then
	SWEP.Icon					= {["Icon"] = surface.GetTextureID( "vgui/UT2K4/Grenade_icon" ),	["Ammo"] = surface.GetTextureID( "vgui/UT2K4/Grenade_ammo" ),	["x"] = 0,	["y"] = 0,	["h"] = 40, ["w"] = 80}		//surface.GetTextureID( "vgui/UT2K4/Lightning_icon" )
end

SWEP.Base = "ut2k4_baseweapon"
 
SWEP.Primary.DefaultAmmoAmmount        = 100 					// Default number of ammo in the gun
SWEP.Primary.Automatic          = false                         // Automatic/Semi Auto
SWEP.Primary.Ammo               = "ASticky grenade"
SWEP.Primary.AmmoName		= "Grenades"		
SWEP.Primary.Delay = 1.7
SWEP.Primary.Sound = "UT2K4/Weapons/AssaultRifleFire.wav"  
 
SWEP.Secondary.Automatic        = false                         // Automatic/Semi Auto
SWEP.Secondary.Delay = 0.1
SWEP.Secondary.Sound = "" 

SWEP.LowAmmoNum		= 4										// How much ammo until your low on ammo
SWEP.HoldType = "crossbow"  
SWEP.DeploySound = "UT2K4/Weapons/RocketLauncherSwitchTo.wav"

//function SWEP:Initialize()
//	self:SetNWInt("numGrenades", 0)
//end

function SWEP:SetupDataTables()

	self:InstallDataTable();
	self:NetworkVar( "Int", 0, "NumGrenades" );
	self:NetworkVar( "Int", 1, "NumAmmo" );
	
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() or self:GetNumGrenades() > 7) then return end
    self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay)	
	self.Owner:MuzzleFlash()
	self.Weapon:EmitSound(Sound(self.Primary.Sound))
	self:TakePrimaryAmmo( 1 )
		
	local aim = self.Owner:GetAimVector()
	local side = aim:Cross(Vector(0,0,1))
	local up = side:Cross(aim)
	local pos = self.Owner:GetShootPos() +  aim * 24 + side * 8 + up * -1	--offsets the rocket so it spawns from the muzzle (hopefully)
--[[	
	local Grenade = ents.Create("UT2K4_Grenade")
	if !Grenade:IsValid() then return false end
	Grenade:SetPos(pos)
	Grenade:SetOwner(self.Owner)
	Grenade:Spawn()
//	Grenade:SetVelocity(self.Owner:GetAimVector() * 1000)
		
	self.Owner.Grenades = self.Owner.Grenades or {}
	table.insert(self.Owner.Grenades,Grenade)
	self:SetNWInt("numGrenades", table.Count(self.Owner.Grenades))
	PrintTable(self.Owner.Grenades)
	
    local bPhys = Grenade:GetPhysicsObject()
    local Force = self.Owner:GetAimVector() * 1000
    bPhys:ApplyForceCenter(Force)]]--
	if !SERVER then return end
				local ent = ents.Create("UT2K4_Grenade")
				ent:SetPos(self.Owner:GetShootPos())
				ent:SetAngles(Angle(1,0,0))
				ent:SetOwner(self.Owner)
				ent:Spawn()
				ent:SetVelocity(self.Owner:GetAimVector() * 1000)
	self.Owner.Grenades = self.Owner.Grenades or {}
	table.insert(self.Owner.Grenades,ent)
	//self:SetNWInt("numGrenades", table.Count(self.Owner.Grenades))
	self:SetNumGrenades(table.Count(self.Owner.Grenades))
				
				local phys = ent:GetPhysicsObject()
				phys:SetVelocity(self.Owner:GetAimVector() * 1000)
				phys:AddAngleVelocity(Vector(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000)))
end
 
function SWEP:SecondaryAttack()
if !SERVER then return end
self.Owner.Grenades = self.Owner.Grenades or {}
	for k, v in pairs(self.Owner.Grenades) do
		if v:IsValid() then
			v:Splode()	//make all your grenades explode
		end
	end
	self.Owner.Grenades = {}
	//self:SetNWInt("numGrenades", 0)
	self:SetNumGrenades(0)
end

local LastThink = 0
function SWEP:Think()
	self.Owner.Grenades = self.Owner.Grenades or {}
	if CurTime() > LastThink then
		self:SetNumAmmo(self.Owner:GetAmmoCount(self.Primary.Ammo))
		LastThink= CurTime()+.1
	end
end
--[[
function SWEP:DrawHUD()		
	local HUD_A 		= GetConVar( "UT2K4_HUD_A" ):GetInt()		
	local HUD_col 		= Color (255, 255, 255, HUD_A)	//color of the HUD	
	local GrenadeTex 	= surface.GetTextureID( "vgui/UT2K4/Grenade" );	
	surface.SetDrawColor( HUD_col );
	surface.SetTexture( GrenadeTex );	
	for i=1,self:GetNumGrenades() do 
		local wide = i%4
		if wide == 0 then wide = 4 end
		local tall = (i-(wide))/4		
		surface.DrawTexturedRect( ScrW()-ScreenScale(7)-(32*wide), ScrH()-ScreenScale(45)-(32*tall) , 32, 32 );		
	end 
end--]]--
if CLIENT then
	local GrenadeTex 	= surface.GetTextureID( "vgui/UT2K4/SpiderMine" );	
	function SWEP:DrawHUD()	
		if UT2K4.HUD then
			local HUD_A 		= GetConVar( "UT2K4_HUD_A" ):GetInt()		
			local HUD_col 		= Color (255, 255, 255, HUD_A)	//color of the HUD	
			surface.SetDrawColor( HUD_col );
			surface.SetTexture( GrenadeTex );	
			for i=1,self:GetNumGrenades() do 
				local wide = i%4
				if wide == 0 then wide = 4 end
				local tall = (i-(wide))/4		
				surface.DrawTexturedRect( ScrW()-ScreenScale(7)-(32*wide), ScrH()-ScreenScale(45)-(32*tall) , 32, 32 );		
			end 
		end
	end

	local AmmoDisplay = {};
	function SWEP:CustomAmmoDisplay()
		if !UT2K4.HUD then	
			AmmoDisplay.Draw = true;
			AmmoDisplay.PrimaryClip = self:GetNumAmmo(); 	//self:GetNumAmmo()
			AmmoDisplay.PrimaryAmmo = self:GetNumGrenades();
			AmmoDisplay.SecondaryClip = -1;
			AmmoDisplay.SecondaryAmmo = -1;
			return AmmoDisplay;
		end	
	end
end