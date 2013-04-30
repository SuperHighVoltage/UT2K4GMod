game.AddAmmoType( 
{
    name        =   "Lightning core",
    dmgtype     =   DMG_BULLET,
    tracer      =   TRACER_LINE_AND_WHIZ,
    plydmg      =   30,
    npcdmg      =   30,
    force       =   100,
    minsplash   =   10,
    maxsplash   =   100
})
sound.Add( 
{
    name = "UT2K4_LightningGun.Fire",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 80,
    pitchstart = 95,
    pitchend = 110,
    sound = "UT2K4/Weapons/LightningGunFire.wav"
} )
sound.Add( 
{
    name = "UT2K4_LightningGun.ChargeUp",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 80,
    pitchstart = 95,
    pitchend = 110,
    sound = "UT2K4/Weapons/LightningGunChargeUp.wav"
} )

// Variables that are used on both client and server
                                         
SWEP.PrintName = "UT2K4 Lightning gun"   
SWEP.Category = "UT2K4"    
SWEP.Author             = "Highvoltage"
SWEP.Contact            = ""
SWEP.Purpose            = ""
SWEP.Instructions       = "The Lightning Gun is a high-power energy rifle capable of ablating even the heaviest carapace armor. Acquisition of a target at long range requires a steady hand, but the anti-jitter effect of the optical system reduces the weapon's learning curve significantly. Once the target has been acquired, the operator depresses the trigger, painting a proton 'patch' on the target. Milliseconds later the rifle emits a high voltage arc of electricity, which seeks out the charge differential and annihilates the target."

SWEP.SlotPos = 2           
SWEP.Slot = 4  
SWEP.AutoSwitchTo = true      
SWEP.AutoSwitchFrom = true    
SWEP.Weight = 5    

SWEP.ViewModel          = "models/weapons/v_ut2k4_sniper.mdl"
SWEP.WorldModel         = "models/weapons/w_ut2k4_sniper.mdl"
 
SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

if CLIENT then
	SWEP.Icon					= {["Icon"] = surface.GetTextureID( "vgui/UT2K4/Lightning_icon" ),	["Ammo"] = surface.GetTextureID( "vgui/UT2K4/Lightning_ammo" ),	["x"] = 0,	["y"] = 0,	["h"] = 20, ["w"] = 80}		//surface.GetTextureID( "vgui/UT2K4/Lightning_icon" )
end

SWEP.Base = "ut2k4_baseweapon"
 
SWEP.Primary.DefaultAmmoAmmount        = 32 					// Default number of ammo in the gun
SWEP.Primary.Automatic          = true                         // Automatic/Semi Auto
SWEP.Primary.Ammo               = "Lightning core"
SWEP.Primary.AmmoName		= "Lightning core"		
SWEP.Primary.Delay = 1.64 
SWEP.Primary.Sound = "UT2K4_LightningGun.Fire"  

SWEP.LowAmmoNum		= 4										// How much ammo until your low on ammo
SWEP.HoldType = "shotgun"  
SWEP.HoldTypeZoomed = "ar2"  
SWEP.DeploySound = "UT2K4/Weapons/LightningGunSwitchTo.wav"

SWEP.dropped = false

function SWEP:Reload()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )	// Sets when you can shoot next
	timer.Simple( self.Primary.Delay-1.1, function()
		if self.dropped == false then
			self:SendWeaponAnim( ACT_VM_RELOAD )
			self:EmitSound("UT2K4_LightningGun.ChargeUp")
		end 
	end)
end

--[[ Shoot lightning bolt ]]--
function SWEP:PrimaryAttack()
if ( !self:CanPrimaryAttack() ) then return end
	self:TakePrimaryAmmo( 1 )
	self:FireLighting()
end
 
function SWEP:SecondaryAttack()
	local Zooming = self:GetZooming()
	
	if self.Owner:KeyPressed(IN_ATTACK2) then
		Zooming = !Zooming
		self:SetZooming(Zooming)
	end
end

--[[ Fire the lightning bolt ]]--
function SWEP:FireLighting()
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound(Sound(self.Primary.Sound))
	
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos()+(self.Owner:GetAimVector()*999999)
	tracedata.filter = self.Owner
	tracedata.mins = Vector(-2,-2,-2)
	tracedata.maxs = Vector(2,2,2)
	local trace = util.TraceHull(tracedata)
	
	if trace.Entity and trace.Entity != nil then	
		if IsValid(trace.Entity) then	//( SERVER ) and 
			local fx = EffectData()
			fx:SetEntity(trace.Entity)
			fx:SetDamageType(DMG_SHOCK)
			fx:SetMagnitude(1)
			util.Effect("ut2k4_overlay", fx, true) 
			
			if trace.Entity:GetClass() == "npc_rollermine" then	
				trace.Entity:Fire("powerdown", "", 0)		//boom!
			end
			if trace.Entity:GetClass() == "npc_turret_floor" then			
				trace.Entity:Fire("selfdestruct", "", 0)	//boom again!
			end
			if trace.Entity:GetClass() == "npc_strider"	then
				local strider = trace.Entity
				//strider:Fire("EnableAggressiveBehavior", "", 0)	//piss it off
				strider:AddEntityRelationship(self.Owner, D_HT, 999 )
				
				strider.AnnoyedCount = strider.AnnoyedCount or 0
				strider.AnnoyedCount = strider.AnnoyedCount + 1
				if strider.AnnoyedCount > 5 then	//You really pissed it off now
					strider:Fire("setcannontarget", self.Owner, 0)
				end
			end

			local vecSub = self.Owner:GetAimVector()
			local phys = trace.Entity:GetPhysicsObject()    
			if IsValid(phys) then
				phys:ApplyForceOffset(vecSub*10000,trace.HitPos)
				//phys:ApplyForceCenter(vecSub*2000)
			else
				trace.Entity:SetVelocity(vecSub*2000)
			end
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(self.Owner)
			dmginfo:SetInflictor(self.Weapon)
			dmginfo:SetDamage(70)
			dmginfo:SetDamageType(DMG_SHOCK)
			dmginfo:SetDamagePosition(trace.HitPos)
			dmginfo:SetDamageForce(vecSub*2000)
			trace.Entity:TakeDamageInfo(dmginfo)	// The crash happens when the NPC is killed 
		end	
	end
	
	if trace.HitWorld then	
		local Pos1 = trace.HitPos + trace.HitNormal * 8
		local Pos2 = trace.HitPos - trace.HitNormal * 8
		util.Decal("fadingscorch", Pos1, Pos2)
	end	

	local vm = self.Owner:GetViewModel()
	if IsValid(vm) and IsValid(self.Weapon) then
		local fx = EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(trace.HitPos)
		util.Effect("ut2k4_lightning_bolt", fx )    
	end	

	self:Reload()
end

function SWEP:Think()
	local ZoomAmmount = self:GetZoomAmmount()
	local Zooming = self:GetZooming()
	
//	if self.Owner:KeyPressed(IN_ATTACK2) then
//		Zooming = !Zooming
//		self:SetZooming(Zooming)
//		Info("Are you zooming? ".. tostring(self:GetZooming()),HUD_PRINTTALK)
//	end

	if self.Owner:KeyDown(IN_ATTACK2) then
		if Zooming == true then
		MsgN(ZoomAmmount )
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
			self:SetZoomAmmount(50)
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
local ZoomTex = Material( "vgui/UT2K4/Lightning_Scope" )
local white = Material( "vgui/white" )
function SWEP:DrawHUD()
	local ZoomAmmount = self:GetZoomAmmount()
	local Zooming = self:GetZooming()
//	local ZoomTex = surface.GetTextureID( "vgui/UT2K4/Lightning_Scope" );
	local ShowCharge = false
	--[[
			surface.SetFont("TargetID")
			surface.SetTextColor( 255, 0, 0, 255 )
			surface.SetTextPos( 0, 0 )  
			surface.DrawText( self:GetNextPrimaryFire() )
			surface.SetTextPos( 0, 15 )  
			surface.DrawText( CurTime() )			
			surface.SetTextPos( 0, 30 )  
			surface.DrawText( self:GetNextPrimaryFire()-CurTime() )
			surface.SetTextPos( 0, 45 )  
			surface.DrawText( self:GetNextPrimaryFire()-(self.Primary.Delay-1)-CurTime() )
	]]--
	if Zooming == true then
		surface.SetMaterial( ZoomTex );	
		surface.SetDrawColor( 255, 255, 255, 255 );
		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() );	

		local time = self:GetNextPrimaryFire()-(self.Primary.Delay-1)-CurTime()
		if time < 0 then
			local red, green, blue, hight = 0
			time = math.abs(time)
			if time < 1.5 then	//2.5 is how long till next fire
				red = time*170		//*100		//changes the color of the box from blue to pink as time goes by
				green = 0
				blue = 255
				hight = time*((ScrH()/2)/1.5)
			else		//once ready to fire turn green
				red = 0
				green = 255
				blue = 0
				hight = (ScrH()/2)	
			end
			surface.SetDrawColor( Color (red, green, blue, 255) );
			surface.SetMaterial( white );								
			surface.DrawTexturedRect( ScrW()-70,(ScrH()/4)+((ScrH()/2)-hight) , 20, hight);
		end
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