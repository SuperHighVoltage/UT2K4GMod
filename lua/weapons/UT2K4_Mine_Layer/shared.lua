game.AddAmmoType( 
{
    name        =   "Spider Mine",
    dmgtype     =   DMG_BULLET,
    tracer      =   TRACER_LINE_AND_WHIZ,
    plydmg      =   30,
    npcdmg      =   30,
    force       =   100,
    minsplash   =   10,
    maxsplash   =   100
})
// Variables that are used on both client and server
                                         
SWEP.PrintName = "UT2K4 Mine Layer"   
SWEP.Category = "UT2K4"    
SWEP.Author             = "Highvoltage"
SWEP.Contact            = ""
SWEP.Purpose            = ""
SWEP.Instructions       = ""

SWEP.SlotPos = 1           
SWEP.Slot = 3  
SWEP.AutoSwitchTo = true      
SWEP.AutoSwitchFrom = true    
SWEP.Weight = 50    

//SWEP.SwayScale                  = 1.0                                   // The scale of the viewmodel sway
//SWEP.BobScale                   = 0.3                                   // The scale of the viewmodel bob
 
SWEP.ViewModel          = "models/weapons/v_ut2k4_mine_layer.mdl"
SWEP.WorldModel         = "models/weapons/w_ut2k4_grenade_launcher.mdl"
 
SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

if CLIENT then
	SWEP.Icon					= {["Icon"] = surface.GetTextureID( "vgui/UT2K4/Mine_icon" ),	["Ammo"] = surface.GetTextureID( "vgui/UT2K4/Mine_ammo" ),	["x"] = 0,	["y"] = 0,	["h"] = 40, ["w"] = 80}		//surface.GetTextureID( "vgui/UT2K4/Lightning_icon" )
end

SWEP.Base = "ut2k4_baseweapon"
 
SWEP.Primary.DefaultAmmoAmmount        = 100 					// Default number of ammo in the gun
SWEP.Primary.Automatic          = false                         // Automatic/Semi Auto
SWEP.Primary.Ammo               = "Spider Mine"
SWEP.Primary.AmmoName		= "Spider Mine"		
SWEP.Primary.Delay = 1
SWEP.Primary.Sound = "UT2K4/Weapons/AssaultRifleFire.wav"  
 
SWEP.Secondary.Automatic        = false                         // Automatic/Semi Auto
SWEP.Secondary.Delay = 0.1
SWEP.Secondary.Sound = "" 

SWEP.LowAmmoNum		= 4										// How much ammo until your low on ammo
SWEP.HoldType = "shotgun"  
SWEP.DeploySound = "UT2K4/Weapons/RocketLauncherSwitchTo.wav"

//function SWEP:Initialize()
//	self:SetNWInt("numMines", 0)
//	self:SetNWBool("Targeting", false)
//end
function SWEP:SetupDataTables()

	self:InstallDataTable();
	self:NetworkVar( "Int", 0, "NumMines" );
	self:NetworkVar( "Bool", 1, "Targeting" );
	
	self:NetworkVar( "Int", 2, "NumAmmo" );
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() or self:GetNumMines() > 7) then return end
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

	if !SERVER then return end
				local ent = ents.Create("UT2K4_SpiderMineProj")
				ent:SetPos(self.Owner:GetShootPos())
				ent:SetAngles(Angle(0,0,0))
				ent:SetOwner(self.Owner)
				ent:Spawn()
				ent:SetVelocity(self.Owner:GetAimVector() * 1000)

	self.Owner.Mines = self.Owner.Mines or {}
	table.insert(self.Owner.Mines,ent)
	print( table.HasValue(self.Owner.Mines,ent))
//	self:SetNWInt("numMines", table.Count(self.Owner.Mines))
	self:SetNumMines(table.Count(self.Owner.Mines))
	
	self:Reload()
end

function SWEP:SecondaryAttack()
--[[	if !SERVER then return end
	self.Owner.Mines = self.Owner.Mines or {}
	for k, v in pairs(self.Owner.Mines) do
		if v:IsValid() then
			v:SetEnemy(pos)
		end
	end
	self.Owner.Mines = {}
	self:SetNWInt("numMines", 0)]]--
end

function SWEP:Reload()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )	// Sets when you can shoot next
	timer.Simple( self.Primary.Delay-0.5, function()
		if self.dropped == false then
			self:SendWeaponAnim( ACT_VM_RELOAD )		-- I forgot the reload animation when I ported the model, will be fixed soon
			self:EmitSound("UT2K4/Weapons/SwitchToFlakCannon.wav")
		end 
	end)
end

local LastThink = 0
function SWEP:Think()
	self.Owner.Mines = self.Owner.Mines or {}
	if self.Owner:KeyPressed(IN_ATTACK2) then
//		self:SetNWBool("Targeting", true)
		self:SetTargeting(true)
//		local tr = util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector()*999999, self.Owner )
	//	for k, v in pairs(self.Owner.Mines) do
//			if v:IsValid() then
//				v:SetEnemy(tr.HitPos)
//			end
//		end
	end

	if self.Owner:KeyDown(IN_ATTACK2) then
		local tr = util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector()*999999, self.Owner )
		for k, v in pairs(self.Owner.Mines) do
			if v:IsValid() then
				v:SetEnemy(tr.HitPos)
			else
				table.remove(self.Owner.Mines,k)
				//self:SetNWInt("numMines", table.Count(self.Owner.Mines))
				self:SetNumMines(table.Count(self.Owner.Mines))
			end
		end		
		
	end

	if self.Owner:KeyReleased(IN_ATTACK2) then	
		//self:SetNWBool("Targeting", false)
		self:SetTargeting(false)
		for k, v in pairs(self.Owner.Mines) do
			if v:IsValid() then
				v:SetEnemy(nil)
			end
		end
	end
	if CurTime() > LastThink then
		self:SetNumAmmo(self.Owner:GetAmmoCount(self.Primary.Ammo))
		for k, v in pairs(self.Owner.Mines) do
			if !v:IsValid() then
				table.remove(self.Owner.Mines,k)
				//self:SetNWInt("numMines", table.Count(self.Owner.Mines))
				self:SetNumMines(table.Count(self.Owner.Mines))
			end
		end		
		LastThink= CurTime()+.1
	end
end

if CLIENT then

	function SWEP:ViewModelDrawn()
		local Targeting = self:GetTargeting()//self:GetNWBool("Targeting")
		if Targeting then
			local lolmat = Material("trails/laser.vmt")
	//		local lolmat2 = Material("sprites/redglow1.vmt")
			local tr = util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector()*999999, self.Owner )
			local posang = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")) 
			render.SetMaterial( lolmat )
			render.DrawBeam(posang.Pos+self.Owner:GetAimVector()*3,tr.HitPos,5,0,0,Color(255,0,0))
	//		render.SetMaterial( lolmat2 )
	//		render.DrawSprite( tr.HitPos, 15, 15, Color(255,255,255,255))
		end
	end
	
	function SWEP:DrawWorldModel()
		self:DrawModel()
		local Targeting = self:GetTargeting()//self:GetNWBool("Targeting")
		if Targeting then
			local lolmat = Material("trails/laser.vmt")
	//		local lolmat2 = Material("sprites/redglow1.vmt")
			local tr = util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector()*999999, self.Owner )
			local posang = self:GetAttachment(self:LookupAttachment("muzzle"))
			render.SetMaterial( lolmat )
			render.DrawBeam(posang.Pos+self.Owner:GetAimVector()*3,tr.HitPos,5,0,0,Color(255,0,0))
	//		render.SetMaterial( lolmat2 )
	//		render.DrawSprite( tr.HitPos, 15, 15, Color(255,255,255,255))
		end
	end
--[[
	function SWEP:DrawHUD()		
		//if UT2K4.HUD then
			local HUD_A 		= 255 //GetConVar( "UT2K4_HUD_A" ):GetInt() 	
			local HUD_col 		= Color (255, 255, 255, HUD_A or 255)	//color of the HUD	
			local GrenadeTex 	= surface.GetTextureID( "vgui/UT2K4/SpiderMine" );	
			surface.SetDrawColor( HUD_col );
			surface.SetTexture( GrenadeTex );	
			for i=1,self:GetNWInt("numMines") do 
				local wide = i%4
				if wide == 0 then wide = 4 end
				local tall = (i-(wide))/4		
				surface.DrawTexturedRect( ScrW()-ScreenScale(7)-(32*wide), ScrH()-ScreenScale(45)-(32*tall) , 32, 32 );		
			end 
		//end
	end

	local AmmoDisplay = {};
	function SWEP:CustomAmmoDisplay()
		if !UT2K4.HUD then
			local mines = self:GetNWInt("numMines")
			AmmoDisplay.Draw = true;
			AmmoDisplay.PrimaryClip = mines;
			AmmoDisplay.PrimaryAmmo = -1;
			AmmoDisplay.SecondaryClip = MySelf:GetAmmoCount(actwep:GetPrimaryAmmoType());
			AmmoDisplay.SecondaryAmmo = -1;

			return AmmoDisplay;
		end
	end--]]--
	-------[[
	local GrenadeTex 	= surface.GetTextureID( "vgui/UT2K4/SpiderMine" );	
	function SWEP:DrawHUD()	
		if UT2K4.HUD then
			local HUD_A 		= GetConVar( "UT2K4_HUD_A" ):GetInt()		
			local HUD_col 		= Color (255, 255, 255, HUD_A)	//color of the HUD	
			surface.SetDrawColor( HUD_col );
			surface.SetTexture( GrenadeTex );	
			for i=1,self:GetNumMines() do 
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
			AmmoDisplay.PrimaryAmmo = self:GetNumMines();
			AmmoDisplay.SecondaryClip = -1;
			AmmoDisplay.SecondaryAmmo = -1;
			return AmmoDisplay;
		end	
	end--]]--
--[[
	function SWEP:DrawHUD()	
		MsgN("HUD "..tostring(IsEntity(self)))	-- HUD true
		MsgN("HUD "..self.Owner:GetAmmoCount(self.Primary.Ammo)) -- HUD 100
	end

	function SWEP:CustomAmmoDisplay()
		MsgN("Ammo "..tostring(IsEntity(self))) -- Ammo false
		MsgN("Ammo "..self.Owner:GetAmmoCount(self.Primary.Ammo)) 
		-- [ERROR] addons/ut2k4_weapons/lua/weapons/ut2k4_mine_layer/shared.lua:251: attempt to index field 'Owner' (a nil value)
		--    1. unknown - addons/ut2k4_weapons/lua/weapons/ut2k4_mine_layer/shared.lua:251
	end--]]--
end