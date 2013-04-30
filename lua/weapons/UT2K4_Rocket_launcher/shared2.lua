game.AddAmmoType( 
{
    name        =   "Rocket",
    dmgtype     =   DMG_BULLET,
    tracer      =   TRACER_LINE_AND_WHIZ,
    plydmg      =   30,
    npcdmg      =   30,
    force       =   100,
    minsplash   =   10,
    maxsplash   =   100
})

// Variables that are used on both client and server
                                         
SWEP.PrintName = "UT2K4 Rocket launcher"   
SWEP.Category = "UT2K4"    
SWEP.Author             = "Highvoltage"
SWEP.Contact            = ""
SWEP.Purpose            = ""
SWEP.Instructions       = ""

SWEP.SlotPos = 2           
SWEP.Slot = 3  
SWEP.AutoSwitchTo = true      
SWEP.AutoSwitchFrom = true    
SWEP.Weight = 5    
 
SWEP.ViewModel          = "models/weapons/v_ut2k4_rocket_launcher.mdl"
SWEP.WorldModel         = "models/weapons/w_ut2k4_rocket_launcher.mdl"
 
SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

if CLIENT then
	SWEP.Icon					= {["Icon"] = surface.GetTextureID( "vgui/UT2K4/Rocket_icon" ),	["Ammo"] = surface.GetTextureID( "vgui/UT2K4/Rocket_ammo" ),	["x"] = 0,	["y"] = 0,	["h"] = 20, ["w"] = 80}		//surface.GetTextureID( "vgui/UT2K4/Lightning_icon" )
end

SWEP.Base = "ut2k4_baseweapon"
 
SWEP.Primary.DefaultAmmoAmmount        = 40 					// Default number of ammo in the gun
SWEP.Primary.Automatic          = true                         // Automatic/Semi Auto
SWEP.Primary.Ammo               = "Rocket"
SWEP.Primary.Delay = 1
SWEP.Primary.Sound = "UT2K4/Weapons/AssaultRifleFire.wav"  
SWEP.Secondary.Sound = "UT2K4/Weapons/AssaultRifleFire.wav"  

SWEP.LowAmmoNum		= 8										// How much ammo until your low on ammo
SWEP.HoldType = "rpg"     
SWEP.DeploySound = "UT2K4/Weapons/RocketLauncherSwitchTo.wav"

SWEP.Rockets = 1
SWEP.LoadingTime = 0
SWEP.dropped = false
// Handles the firing of the rockets
function SWEP:Fire_Rocket(posOff,angOff,target)			//example use: fire_Rocket( Vector( -10, 0, 0 ), Angle(0, -3, 0) )		fires a rocket offset 10 left and rotated 3 left
	local aim = self.Owner:GetAimVector()
	local side = aim:Cross(Vector(0,0,1))
	local up = side:Cross(aim)
	local pos = self.Owner:GetShootPos() +  aim * 24 + side * 8 + up * -1	--offsets the rocket so it spawns from the muzzle (hopefully)

	if target and type(target) == "number" then
		local rocket = ents.Create("UT2K4_Rocketproj")
		if !rocket:IsValid() then return false end
		rocket:SetAngles(aim:Angle())
		rocket:SetPos(pos + (aim:Angle():Right()*-3) + (aim:Angle():Up()*-3))
		rocket:SetOwner(self.Owner)
		rocket:Spawn()
		rocket:Activate()
		rocket:SetVelocity(rocket:GetForward()*1000)
		if target >= 2 then
			local rocket = ents.Create("UT2K4_Rocketproj")
			if !rocket:IsValid() then return false end
			rocket:SetAngles(aim:Angle())
			rocket:SetPos(pos + (aim:Angle():Right()*3) + (aim:Angle():Up()*-3))
			rocket:SetOwner(self.Owner)
			rocket:Spawn()
			rocket:Activate()
			rocket:SetVelocity(rocket:GetForward()*1000)
		end
		if target == 3 then
			local rocket = ents.Create("UT2K4_Rocketproj")
			if !rocket:IsValid() then return false end
			rocket:SetAngles(aim:Angle())
			rocket:SetPos(pos)
			rocket:SetOwner(self.Owner)
			rocket:Spawn()
			rocket:Activate()
			rocket:SetVelocity(rocket:GetForward()*1000)
		end
	else
		local rocket = ents.Create("UT2K4_Rocketproj")
		if !rocket:IsValid() then return false end
		rocket:SetAngles(aim:Angle() + angOff)
		rocket:SetPos(pos + posOff)
		rocket:SetOwner(self.Owner)
		rocket:Spawn()
		rocket:Activate()
		rocket:SetVelocity(rocket:GetForward()*1000)
		if target and target:IsValid() then
			rocket:Target(target)
		end
	end
	
	self:ShootEffects()
//	local rnda = self.Primary.Recoil * -1
//	local rndb = self.Primary.Recoil * math.random(-1, 1)
	self.Weapon:EmitSound(Sound(self.Primary.Sound))
//	self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	
	self.dropped = false	//if you can shoot then the weapon isn't dropped
	self.Rockets = 0
	timer.Simple( .5, function()
		if self.dropped == false then	//but after .5 seconds it could of been dropped
			self.Rockets = 1
			self:Reload()
			self.LoadingTime = CurTime()+1
		end 
	end)
end 

function SWEP:PrimaryAttack()
if ( !self:CanPrimaryAttack() ) then return end
	self:ShootEffects()	//plays animations, sets delay
	self:TakePrimaryAmmo( 1 )

	trace = self.Owner:GetEyeTrace()
	local target2 = nil
	if trace.HitWorld then
		trace = nil
	else
		if trace.Entity then
			target2 = trace.Entity
		end
	end
	self:Fire_Rocket( Vector( 0, 0, 0 ), Angle(0, 0, 0),target2 )	//fires a rocket from its normal location and straight ahead aimed at th
//	self:Fire_Rocket( Vector( 0, 0, 0 ), Angle(0, 0, 0) )	//fires a rocket from its normal location and straight ahead

end
 
function SWEP:SecondaryAttack()
-- See below
end

function SWEP:Think()
//self.ammoInGun = self.Owner:GetAmmoCount(self.Primary.Ammo)
if CLIENT then return end
	if ( self:CanPrimaryAttack() ) then
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Rockets loaded in gun: " .. self.Rockets )
		if self.Owner:KeyPressed(IN_ATTACK2) then
			self.LoadingTime = CurTime()+1
			self.Rockets = self.Rockets + 1
			self:TakePrimaryAmmo( 1 )
			self:Reload()
		end
		if self.Owner:KeyDown(IN_ATTACK2) then	//if we are pressing alt fire
			if self.LoadingTime < CurTime() then
				if self.Rockets == 3 then	// When the 3rd rocket has finished loading
					self.Owner:PrintMessage( HUD_PRINTTALK, "Rockets fired: "..self.Rockets )
					self:Fire_Rocket( Vector( 0, 0, 0 ), Angle(0, 0, 0),3 )
					self:TakePrimaryAmmo( 1 )
					self.LoadingTime = CurTime()+1
				else
					self.Rockets = self.Rockets + 1
					self:TakePrimaryAmmo( 1 )
					self.LoadingTime = CurTime()+1
					self:Reload()
				end
			end
		end
		if self.Owner:KeyReleased(IN_ATTACK2) then	//if we let go of alt fire
//			if self.LoadingTime < CurTime() then
				self:Fire_Rocket( Vector( 0, 0, 0 ), Angle(0, 0, 0),self.Rockets )
				self.LoadingTime = CurTime()+1
				
				self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				//self:TakePrimaryAmmo( 1 )
				self.Weapon:EmitSound(Sound(self.Secondary.Sound))	
//			end
		end	
	else
		if self.Owner:KeyPressed(IN_ATTACK2) then
			self.Weapon:EmitSound( "Weapon_Pistol.Empty" )
		end
	end
end

function SWEP:Reload()
	self.Owner:PrintMessage( HUD_PRINTTALK, "Rockets loaded into gun: "..self.Rockets )
	self:SendWeaponAnim( ACT_VM_RELOAD )
	self:EmitSound("UT2K4/Weapons/RocketLauncherLoad.wav",60,100)
end

function SWEP:DrawHUD()

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

function SWEP:OnDrop()			//Called when the weapon has been dropped. 
	self.dropped = true
end
--[[
function SWEP:Equip( ply )		//Called after the weapon has been acquired for the first time
	self.ammoInGun = self.Owner:GetAmmoCount(self.Primary.Ammo)
	MsgN("ammo in gun "..self.ammoInGun..". First pickup")
end

function SWEP:EquipAmmo( ply )	//Called when the player already has this weapon when its picked up
	ply:GiveAmmo(self.ammoInGun,self.Primary.Ammo)
	MsgN("gave the player "..self.ammoInGun.." ammo")
	self.ammoInGun = 0
end]]--