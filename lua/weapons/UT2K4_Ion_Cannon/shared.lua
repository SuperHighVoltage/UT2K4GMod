game.AddAmmoType( 
{
    name        =   "Ion cores",
    dmgtype     =   DMG_BULLET,
    tracer      =   TRACER_LINE_AND_WHIZ,
    plydmg      =   30,
    npcdmg      =   30,
    force       =   100,
    minsplash   =   10,
    maxsplash   =   100
})

// Variables that are used on both client and server
                                         
SWEP.PrintName = "UT2K4 Ion Cannon"   
SWEP.Category = "UT2K4"    
SWEP.Author             = "Highvoltage"
SWEP.Contact            = ""
SWEP.Purpose            = ""
SWEP.Instructions       = ""

SWEP.SlotPos = 0           
SWEP.Slot = 1  
SWEP.AutoSwitchTo = true      
SWEP.AutoSwitchFrom = true    
SWEP.Weight = 5    

SWEP.ViewModel          = "models/weapons/v_smg1.mdl"
SWEP.WorldModel         = "models/weapons/w_smg1.mdl"
 
SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

if CLIENT then
	SWEP.Icon					= "f"
end

SWEP.Base = "ut2k4_baseweapon"
 
SWEP.Primary.DefaultAmmoAmmount        = 300 					// Default number of ammo in the gun
SWEP.Primary.Automatic          = true                         // Automatic/Semi Auto
SWEP.Primary.Ammo               = "ar2"
SWEP.Primary.AmmoName		= "=Ion cores"					//The name of the ammo to show on the HUD
SWEP.Primary.Delay = 0.1
SWEP.Primary.Sound = "UT2K4/Weapons/ShockRifleFire.wav"  
 
SWEP.Secondary.Automatic        = true                         // Automatic/Semi Auto
SWEP.Secondary.Delay = 0.15
SWEP.Secondary.Sound = "UT2K4/Weapons/ShockRifleAltFire.wav" 

SWEP.LowAmmoNum		= 50										// How much ammo until your low on ammo
SWEP.HoldType = "shotgun"  
SWEP.HoldTypeZoomed = "ar2"  
SWEP.DeploySound = "UT2K4/Weapons/SwitchToShockRifle.wav"

SWEP.FCT = 1.5	--How long till fully charged

SWEP.ZoomOn = false
SWEP.cl_ZoomOn = false
SWEP.cl_DrawScope = false
SWEP.showCharge = true
SWEP.Zoom = 50

function SWEP:Initialize()
	self:SetNWInt("Zoom", 50)
	self:SetNWBool("ZoomOn", false)
	self:SetWeaponHoldType( self.HoldType )
	self.Chargesound = CreateSound(self, Sound("UT2K4/Weapons/IonCannonCharge.wav") )
end

function SWEP:PrimaryAttack()--[[
//if ( !self:CanPrimaryAttack() ) then return end
	self:ShootEffects()	//plays animations, sets delay, takes ammo
	self.Weapon:EmitSound(Sound(self.Primary.Sound))
	
	if !self.ChargeTime then
		self.ChargeTime = CurTime()
	else]]--
end
 
function SWEP:SecondaryAttack()--[[
if ( !self:CanPrimaryAttack() ) then return end
	self:ShootEffects()	//plays animations, sets delay, takes ammo
	self.Weapon:EmitSound(Sound(self.Secondary.Sound))
]]--
end

function SWEP:Holster( wep )
	timer.Destroy("Reloadanim")
self:SetNWInt("Zoom", 50)
self:SetNWBool("ZoomOn", false)
    return true
end

local ChargePercent = 0
local ChargeStart = false
local beep = true

function SWEP:Think()

	if self.Owner:KeyPressed(IN_ATTACK) then
		ChargeStart = CurTime()
		beep = true
		//self.Weapon:EmitSound(Sound("UT2K4/Weapons/IonCannonCharge.wav"))
		self.Chargesound:Play()
		MsgN("sound 1")
	end

	if self.Owner:KeyDown(IN_ATTACK) then
		if ChargeStart then
			local ChargeAmmount = CurTime() - ChargeStart
			ChargePercent = math.Clamp((ChargeAmmount / self.FCT)*100,0,100)
			if ChargeAmmount >= self.FCT-1 and beep == true then
				//self.Weapon:StopSound(Sound("UT2K4/Weapons/IonCannonCharge.wav"))
				
				self.Weapon:EmitSound(Sound("UT2K4/Weapons/IonCannonTargeting.wav"))
				MsgN("sound 2")
				beep = false
			end			
			if ChargeAmmount >= self.FCT then
				self:CreateBeam()
				self.Chargesound:Stop()
				self.Weapon:StopSound(Sound("UT2K4/Weapons/IonCannonTargeting.wav"))
				self.Weapon:EmitSound(Sound("UT2K4/Weapons/IonCannonTargetAquired.wav"))
				MsgN("sound 3")
				ChargeStart = false
				ChargePercent = 0
			end
			self:SetNWInt("ChargePercent", ChargePercent)
		end
	end

	if self.Owner:KeyReleased(IN_ATTACK) then	
		ChargeStart = false
		ChargePercent = 0
		self:SetNWInt("ChargePercent", ChargePercent)
		//self.Weapon:StopSound(Sound("UT2K4/Weapons/IonCannonCharge.wav"))
		self.Chargesound:Stop()
	end

	
	local Zoom = self:GetNWInt("Zoom")
	local ZoomOn = self:GetNWBool("ZoomOn")
	
	if self.Owner:KeyPressed(IN_ATTACK2) then
		if ZoomOn == false then
			self:SetNWBool("ZoomOn", true)
		else
			self:SetNWBool("ZoomOn", false)
		end
	end

	if self.Owner:KeyDown(IN_ATTACK2) then
		if ZoomOn == true then
			if (Zoom > 10) then
				self:SetNWInt("Zoom", Zoom - 1 )
				if ( SERVER ) then	
					self.Owner:DrawViewModel(false)	
					self.Owner:SetFOV( Zoom, 0 )	
				end
			end
		end
	end

	if self.Owner:KeyReleased(IN_ATTACK2) then	
		if ZoomOn == false then
			self:SetNWInt("Zoom", 50)	
			if ( SERVER ) then	
				self.Owner:DrawViewModel(true)	
				self.Owner:SetFOV( 0, 0.5 )	
				self.Owner:RestartGesture( ACT_SIGNAL_HALT )	//http://wiki.garrysmod.com/?title=Enumeration_List#ACT
			end		
		end
	end
	
	if self:GetNWBool("ZoomOn") == true then
		self:SetWeaponHoldType( self.HoldTypeZoomed )
	else
		self:SetWeaponHoldType( self.HoldType )
	end
end

local ZoomTex 
if CLIENT then
ZoomTex = surface.GetTextureID( "vgui/UT2K4/Lightning_Scope" );
end
function SWEP:DrawHUD()
	local ChargePercent2 = self:GetNWInt("ChargePercent")
	local ZoomOn = self:GetNWBool("ZoomOn")
	
	if ZoomOn == true then
		surface.SetTexture( ZoomTex );	
		surface.SetDrawColor( 255, 255, 255, 255 );
		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() );	

	end	
	if ChargePercent2 != 0 then
		
		local red, green, blue, hight = 0

		if ChargePercent2 != 100 then	//2.5 is how long till next fire
			red = ChargePercent2*2.55		//*100		//changes the color of the box from blue to pink as time goes by
			green = 0
			blue = 255
			hight = ChargePercent2*((ScrH()/2)/100)
//			self.showCharge = true		//show bar cause its charging
		else		//once ready to fire turn green
			red = 0
			green = 255
			blue = 0
			hight = (ScrH()/2)	
		end
		
		surface.SetDrawColor( Color (red, green, blue, 255) );
		surface.SetTexture( surface.GetTextureID( "vgui/white" ) );								
		surface.DrawTexturedRect( ScrW()-70,(ScrH()/4)+((ScrH()/2)-hight) , 20, hight);
	end	
surface.SetTextColor( 200, 200, 200, 255 )
surface.SetTextPos( 100, 200 ) 
surface.DrawText( ""..tostring(self.Owner:GetAimVector()) )
end

function SWEP:ViewModelDrawn()
	local lolmat = Material("trails/laser.vmt")
	local lolmat2 = Material("sprites/redglow1.vmt")
local ChargePercent2 = self:GetNWInt("ChargePercent")
	
	local tr = util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector()*999999, self.Owner )
	local tr2 = util.QuickTrace( self.Owner:EyePos(), self.Owner:GetAimVector()*0.01, self.Owner )
	local posang = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")) ------------------------------------------------------
	render.SetMaterial( lolmat )
if ChargePercent2 then
	render.DrawBeam(posang.Pos+self.Owner:GetAimVector()*3,tr.HitPos,5+(ChargePercent/10),0,0,Color(255,ChargePercent,0))
else
	render.DrawBeam(posang.Pos+self.Owner:GetAimVector()*3,tr.HitPos,1.15,0,0,Color(255,0,0))
end
	render.SetMaterial( lolmat2 )
	render.DrawSprite( tr.HitPos, 15, 15, Color(255,255,255,255))
end

function SWEP:CreateBeam()
	if IsValid(self.Owner) && IsValid(self.Weapon) and SERVER then
		local tracedata = {}
		tracedata.start = self.Owner:GetShootPos()
		tracedata.endpos = self.Owner:GetShootPos()+(self.Owner:GetAimVector()*999999)
		tracedata.filter = self.Owner
		local tr = util.TraceLine(tracedata)
		
		if ( !tr.Hit ) then return end
		tr2 = util.QuickTrace( tr.HitPos, Vector(0,0,1)*9999)
		
		if ( tr2.HitSky or !tr2.Hit ) then 
			local SpawnPos = tr.HitPos
			local ent = ents.Create( "ut2k4_ion_cannon_target" )
			ent.StartPos = tr2.HitPos
			ent:SetPos( SpawnPos )
			ent:Spawn()
			ent:Activate()
		end
	end
--[[
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

					local vecSub = tr.HitPos-self.Owner:GetShootPos()
					vecSub:Normalize()
					local phys = tr.Entity:GetPhysicsObject()    
					
					if IsValid(phys) then
						phys:ApplyForceOffset(vecSub*10000,tr.HitPos)
					else
						tr.Entity:SetVelocity(vecSub*10000)
					end
					
					local dmginfo = DamageInfo()
					dmginfo:SetAttacker(self.Owner)
					dmginfo:SetInflictor(self.Weapon)
					dmginfo:SetDamage(10)
					dmginfo:SetDamageType(DMG_DISSOLVE)
					dmginfo:SetDamagePosition(tr.HitPos)
					dmginfo:SetDamageForce(vecSub*10000)
					tr.Entity:TakeDamageInfo(dmginfo)
				
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
--]]--
end
