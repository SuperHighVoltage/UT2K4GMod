game.AddAmmoType( 
{
    name        =   "Rocket pack",
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
SWEP.Primary.Ammo               = "Rocket pack"
SWEP.Primary.Delay = 1.22
SWEP.Primary.Sound = "UT2K4/Weapons/AssaultRifleFire.wav"  
SWEP.Secondary.Sound = "UT2K4/Weapons/AssaultRifleFire.wav"  
SWEP.ReloadDelay = 1.16

SWEP.LowAmmoNum		= 8										// How much ammo until your low on ammo
SWEP.HoldType = "rpg"     
SWEP.DeploySound = "UT2K4/Weapons/RocketLauncherSwitchTo.wav"

SWEP.Rockets = 1
SWEP.LoadingTime = 0
SWEP.dropped = false
SWEP.spin = false
SWEP.Target = nil
SWEP.Targeting = nil
SWEP.TargetTime = 0
SWEP.TargetThinkTime = 0
SWEP.Shoot = false

function Info(msg,pos)
	pos = pos or HUD_PRINTCENTER
//	Entity(1):PrintMessage( pos, msg )
end

function SWEP:Reload()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )	// Sets when you can shoot next
	self:SetNextSecondaryFire( CurTime() + self.ReloadDelay )	// Sets when you can reload next
	timer.Simple( self.ReloadDelay-.7, function()
		if self.dropped == false then
			self:SendWeaponAnim( ACT_VM_RELOAD )
			self:EmitSound("UT2K4/Weapons/RocketLauncherLoad.wav",60,100)
			self.Rockets = self.Rockets + 1
			Info(self.Rockets.." loaded")
		end 
	end)
end

--[[ Shoot single rocket ]]--
function SWEP:PrimaryAttack()
if ( !self:CanPrimaryAttack() ) then return end
	self:TakePrimaryAmmo( 1 )
	self:FireRocket()
end
 
--[[ Load barrel with rockets ]]--
function SWEP:SecondaryAttack()
if !self:CanPrimaryAttack() and self.Shoot == false then return end
	self:TakePrimaryAmmo( 1 )
	if self.Rockets == 3 then
		self:FireRocket()
	else
		self:Reload()
	end
end

--[[ Fire the rocket(s) ]]--
function SWEP:FireRocket()
	if CLIENT then return end
	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound(Sound(self.Primary.Sound))
	if self.spin == true then							-- if the rockets are to be launched in a spiral motion (todo: make rockets launch in a spiral motion)
		Info("You spin me right round",HUD_PRINTTALK)
	end
	self.spin = false
	Info("Shot "..self.Rockets.." rockets")
	Entity(1):PrintMessage( HUD_PRINTCENTER, "Shot "..self.Rockets.." rockets" )
	------------------------------------
		local aim = self.Owner:GetAimVector()
		local side = aim:Cross(Vector(0,0,1))
		local up = side:Cross(aim)
		local pos = self.Owner:GetShootPos() +  aim * 24 + side * 8 + up * -1	--offsets the rocket so it spawns from the muzzle (hopefully)
	
		local rocket = ents.Create("UT2K4_Rocketproj")
		if !rocket:IsValid() then return false end
		rocket:SetAngles(aim:Angle())
		rocket:SetPos(pos )
		rocket:SetOwner(self.Owner)
		rocket:Spawn()
		rocket:Activate()
		rocket:SetVelocity(rocket:GetForward()*1000)
		if self.Target and self.Target:IsValid() then
			rocket:Target(self.Target)
		end	
	
--[[	garbage for now
		local rocket = ents.Create("UT2K4_Rocketmultiproj")
		if !rocket:IsValid() then return false end
		rocket:SetPos(pos )
		rocket:SetOwner(self.Owner)
		rocket:Spawn()
		rocket:Activate()
		rocket:SetLocalAngularVelocity(Angle(0,0,300))
		rocket:SetAngles(aim:Angle())
		rocket:SetVelocity(rocket:GetForward()*1000)
		if self.Target and self.Target:IsValid() then
			rocket:Target(self.Target)
		end--]]--
	----------------------------------------
	
	self.Rockets = 0
	self:Reload()
end

function SWEP:Think()
	if self.Owner:KeyDown(IN_ATTACK2) then
		if self.Owner:KeyPressed(IN_ATTACK) then
			self.spin = true
		end
	end
	if self.TargetThinkTime < CurTime() then
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos()+(self.Owner:GetAimVector()*999999)
	tracedata.filter = self.Owner
	tracedata.mins = Vector(-4,-4,-4)
	tracedata.maxs = Vector(4,4,4)
	local trace = util.TraceHull(tracedata)
		if trace.HitWorld then 
			trace = nil 
			self.TargetTime = self.TargetTime - 2
			if self.TargetTime < 0 then
				self.Target = nil
				self.Targeting = nil
				self.TargetTime = 0
			end
		else
			if trace.Entity then	// If an entity was found
				if trace.Entity == self.Targeting then	// If the entity is the same as one we found before
					self.TargetTime = self.TargetTime + 1	// add to the number of times it was found
					if self.TargetTime > 6 then			// if found enough make it out target
						self.TargetTime = 6
						self.Target = trace.Entity
					end
				else									// If the entity is not the same as one we found before
					self.Targeting = trace.Entity		// save this entity
					self.TargetTime = 0					// reset the count
				end
			end
		end
		if self.Target then
			self:SetFoundTarget(true)
		else
			self:SetFoundTarget(false)
		end
		self.TargetThinkTime = CurTime() + 0.1
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "FoundTarget" );
end

local UT2K4_CrossHairSize = 50
function SWEP:DrawHUD()
	local haveTarget = self:GetFoundTarget()
	if haveTarget then
		surface.SetDrawColor( Color(255,0,0) );
		surface.SetTexture( surface.GetTextureID("vgui/UT2K4/Crosshairs/Cannon") );
		surface.DrawTexturedRect( (ScrW()/2) - (UT2K4_CrossHairSize/2), (ScrH()/2) - (UT2K4_CrossHairSize/2), UT2K4_CrossHairSize, UT2K4_CrossHairSize );	
	end
--[[	
//	Info(tostring(math.floor(Vector(0,0,0):Distance(self.Owner:GetVelocity())/100)),HUD_PRINTTALK)
	local num = GetConVar( "wheel_friction" ):GetInt()//math.floor(Vector(0,0,0):Distance(self.Owner:GetVelocity())/100)
	local diameter = GetConVar( "wheel_forcelimit" ):GetInt()/100
	local size = GetConVar( "wheel_torque" ):GetInt()/100
	for i = 1, num do
		local angle = 3.14159 * 2 / num * i
		local y = math.sin( angle ) * diameter
		local x = math.cos( angle ) * diameter
		surface.SetDrawColor( Color(255,0,0) );
		surface.SetTexture( surface.GetTextureID("vgui/UT2K4/Crosshairs/Cannon") );
		surface.DrawTexturedRect( (ScrW()/2) - (size/2) - x, (ScrH()/2) - (size/2) - y, size, size );	
			surface.SetFont("TargetID")
			surface.SetTextColor( 255, 0, 0, 255 )
			surface.SetTextPos( (ScrW()/2) - (size/2) - x, (ScrH()/2) - (size/2) - y )  
			surface.DrawText( i )
	end]]--
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
	MsgN("Dropped Rocket launcher")
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