 
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include( "shared.lua" )
include( "ai_translations.lua" )
 
SWEP.Weight                             = 5                     // Decides whether we should switch from/to this
SWEP.AutoSwitchTo               = true          // Auto switch to if we pick it up
SWEP.AutoSwitchFrom             = true          // Auto switch from if you pick up a better weapon
 
local ActIndex = {
	[ "pistol" ] 		= ACT_HL2MP_IDLE_PISTOL,
	[ "smg" ] 			= ACT_HL2MP_IDLE_SMG1,
	[ "grenade" ] 		= ACT_HL2MP_IDLE_GRENADE,
	[ "ar2" ] 			= ACT_HL2MP_IDLE_AR2,
	[ "shotgun" ] 		= ACT_HL2MP_IDLE_SHOTGUN,
	[ "rpg" ]	 		= ACT_HL2MP_IDLE_RPG,
	[ "physgun" ] 		= ACT_HL2MP_IDLE_PHYSGUN,
	[ "crossbow" ] 		= ACT_HL2MP_IDLE_CROSSBOW,
	[ "melee" ] 		= ACT_HL2MP_IDLE_MELEE,
	[ "slam" ] 			= ACT_HL2MP_IDLE_SLAM,
	[ "normal" ]		= ACT_HL2MP_IDLE,
	[ "fist" ]			= ACT_HL2MP_IDLE_FIST,
	[ "melee2" ]		= ACT_HL2MP_IDLE_MELEE2,
	[ "passive" ]		= ACT_HL2MP_IDLE_PASSIVE,
	[ "knife" ]			= ACT_HL2MP_IDLE_KNIFE,
	[ "duel" ]			= ACT_HL2MP_IDLE_DUEL,
	[ "camera" ]		= ACT_HL2MP_IDLE_CAMERA,
	[ "revolver" ]		= ACT_HL2MP_IDLE_REVOLVER,

	[ "magic" ] 		= ACT_HL2MP_IDLE_MAGIC,
	[ "zombie" ]		= ACT_HL2MP_IDLE_ZOMBIE,
	[ "suitcase" ]		= ACT_HL2MP_IDLE_SUITCASE,
	[ "melee_angry" ] 	= ACT_HL2MP_IDLE_MELEE_ANGRY,
	[ "angry" ] 		= ACT_HL2MP_IDLE_ANGRY,
	[ "scared" ]  		= ACT_HL2MP_IDLE_SCARED,

}


--[[---------------------------------------------------------
   Name: SetWeaponHoldType
   Desc: Sets up the translation table, to translate from normal 
			standing idle pose, to holding weapon pose.
-----------------------------------------------------------]]
function SWEP:SetWeaponHoldType( t )

	t = string.lower( t )
	local index = ActIndex[ t ]

	if ( index == nil ) then
		Msg( "SWEP:SetWeaponHoldType - ActIndex[ \""..t.."\" ] isn't set! (defaulting to normal)\n" )
		t = "normal"
		index = ActIndex[ t ]
	end

	self.ActivityTranslate = {}
	self.ActivityTranslate [ ACT_MP_STAND_IDLE ] 				= index
	self.ActivityTranslate [ ACT_MP_WALK ] 						= index+1
	self.ActivityTranslate [ ACT_MP_RUN ] 						= index+2
	self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] 				= index+3
	self.ActivityTranslate [ ACT_MP_CROUCHWALK ] 				= index+4
	self.ActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= index+5
	self.ActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index+5
	self.ActivityTranslate [ ACT_MP_RELOAD_STAND ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_RELOAD_CROUCH ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_JUMP ] 						= index+7
	self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 				= index+8
	self.ActivityTranslate [ ACT_MP_SWIM_IDLE ] 				= index+8
	self.ActivityTranslate [ ACT_MP_SWIM ] 						= index+9

	-- "normal" jump animation doesn't exist
	if t == "normal" then
		self.ActivityTranslate [ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM
	end

	self:SetupWeaponHoldTypeForAI( t )

end

-- Default hold pos is the pistol
SWEP:SetWeaponHoldType( "pistol" )

--[[---------------------------------------------------------
   Name: weapon:TranslateActivity( )
   Desc: Translate a player's Activity into a weapon's activity
		 So for example, ACT_HL2MP_RUN becomes ACT_HL2MP_RUN_PISTOL
		 Depending on how you want the player to be holding the weapon
-----------------------------------------------------------]]
function SWEP:TranslateActivity( act )

	if ( self.Owner:IsNPC() ) then
		if ( self.ActivityTranslateAI[ act ] ) then
			return self.ActivityTranslateAI[ act ]
		end
		return -1
	end

	if ( self.ActivityTranslate[ act ] != nil ) then
		return self.ActivityTranslate[ act ]
	end

	return -1

end
 
/*---------------------------------------------------------
   Name: OnRestore
   Desc: The game has just been reloaded. This is usually the right place
                to call the GetNetworked* functions to restore the script's values.
---------------------------------------------------------*/
function SWEP:OnRestore()
end
 
 
/*---------------------------------------------------------
   Name: AcceptInput
   Desc: Accepts input, return true to override/accept input
---------------------------------------------------------*/
function SWEP:AcceptInput( name, activator, caller, data )
        return false
end
 
 
/*---------------------------------------------------------
   Name: KeyValue
   Desc: Called when a keyvalue is added to us
---------------------------------------------------------*/
function SWEP:KeyValue( key, value )
end
 
 
/*---------------------------------------------------------
   Name: OnRemove
   Desc: Called just before entity is deleted
---------------------------------------------------------*/
function SWEP:OnRemove()
end
 
/*---------------------------------------------------------
   Name: Equip
   Desc: A player or NPC has picked the weapon up
---------------------------------------------------------*/
function SWEP:Equip( ply )
self.dropped = false
//	if ply:IsPlayer() then
//		ply:GiveAmmo(self.Primary.DefaultAmmoAmmount ,self.Primary.Ammo)	//give the player the default ammount of ammo
//		self.ammoInGun = self.Owner:GetAmmoCount(self.Primary.Ammo)			//sets the ammount of ammo to a variable
//	end
	if ply:IsPlayer() then
		if self.ammoInGun == 0 then	//if the weapon has no ammo
			ply:GiveAmmo(self.Primary.DefaultAmmoAmmount ,self.Primary.Ammo)	//give the player the default ammount of ammo
		else
			ply:GiveAmmo(self.ammoInGun,self.Primary.Ammo)					//give the player the ammount of ammo the gun had before it was dropped
		//	self.ammoInGun = self.Owner:GetAmmoCount(self.Primary.Ammo)		//sets the ammount of ammo to a variable
		end
	end
end
 
/*---------------------------------------------------------
   Name: EquipAmmo
   Desc: The player has picked up the weapon and has taken the ammo from it
                The weapon will be removed immidiately after this call.
---------------------------------------------------------*/
function SWEP:EquipAmmo( ply )
	if ply:IsPlayer() then
		if self.ammoInGun == 0 then
			ply:GiveAmmo(self.Primary.DefaultAmmoAmmount ,self.Primary.Ammo)	//give the player the default ammount of ammo
		else
			ply:GiveAmmo(self.ammoInGun,self.Primary.Ammo)					//give the player the ammount of ammo the gun had before it was dropped
		//	self.ammoInGun = self.Owner:GetAmmoCount(self.Primary.Ammo)		//sets the ammount of ammo to a variable
		end
	end
end

/*---------------------------------------------------------
   Name: OnDrop
   Desc: Weapon was dropped
---------------------------------------------------------*/
function SWEP:OnDrop()
//SWEP.Primary.DefaultClip = self.Owner:GetAmmoCount( SWEP.Primary.Ammo)
//self.Owner:SetAmmo( 0 , SWEP.Primary.Ammo )
end
 
/*---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------*/
function SWEP:ShouldDropOnDie()
        return true
end

/*---------------------------------------------------------
   Name: GetCapabilities
   Desc: For NPCs, returns what they should try to do with it.
---------------------------------------------------------*/
function SWEP:GetCapabilities()
  self.Owner:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
        return bit.bor( CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1, CAP_AIM_GUN, CAP_MOVE_SHOOT )

end
 
/*---------------------------------------------------------
   Name: NPCShoot_Secondary
   Desc: NPC tried to fire secondary attack
---------------------------------------------------------*/
function SWEP:NPCShoot_Secondary( ShootPos, ShootDir )
 
        self:SecondaryAttack()
 
end
 
/*---------------------------------------------------------
   Name: NPCShoot_Secondary
   Desc: NPC tried to fire primary attack
---------------------------------------------------------*/
function SWEP:NPCShoot_Primary( ShootPos, ShootDir )
 
        self:PrimaryAttack()
 
end
 
// These tell the NPC how to use the weapon
AccessorFunc( SWEP, "fNPCMinBurst",             "NPCMinBurst" )
AccessorFunc( SWEP, "fNPCMaxBurst",             "NPCMaxBurst" )
AccessorFunc( SWEP, "fNPCFireRate",             "NPCFireRate" )
AccessorFunc( SWEP, "fNPCMinRestTime",  "NPCMinRest" )
AccessorFunc( SWEP, "fNPCMaxRestTime",  "NPCMaxRest" )