
function EFFECT:Init(data)
	self.ent = data:GetEntity()
	self.ent.Overlay = self		//used to check if the entity has this effect applyed to it
	self.dmgType = data:GetDamageType()
	self.mat = self:Dmg2Mat(self.dmgType)	//data:GetMaterial() doesn't exist :(
	self.delay = CurTime() + data:GetMagnitude()
	if IsValid(self.ent) then
		self.model = ClientsideModel( self.ent:GetModel(), RENDERGROUP_OPAQUE)
		self.model:SetMaterial(self.mat)
		self.model:SetParent(self.ent)
		self.model:AddEffects(EF_BONEMERGE)
	end
	hook.Add( "CreateClientsideRagdoll", self, self.NPCRagdollCheck )
end

function EFFECT:Think()
	if IsValid(self.ent) and self.ent:IsPlayer() and !self.ent:Alive() and IsValid( self.ent:GetRagdollEntity() ) then
		self.ent = self.ent:GetRagdollEntity()
		self.model:SetParent(self.ent)
		self.model:AddEffects(EF_BONEMERGE)
	end
	if CurTime() > self.delay or !IsValid(self.ent) then
		if IsValid(self.model) then
			self.model:Remove()
			self.model = nil
		end
		self.ent.Overlay = nil
		return false
	end
	return true
end 

function EFFECT:Dmg2Mat(dmg)
	local mat = "sprites/UT2K4/Invis_overlay"
	if dmg == DMG_SHOCK then
		mat = "sprites/UT2K4/Lightning_Energy"
	elseif dmg == DMG_PLASMA then
		mat = "sprites/UT2K4/Link_Energy"
	elseif dmg == DMG_ENERGYBEAM then
		mat = "sprites/UT2K4/Lightning_Energy"
	elseif dmg == DMG_BULLET then
		mat = "sprites/UT2K4/Damage_Overlay"
	elseif dmg == DMG_BUCKSHOT then
		mat = "sprites/UT2K4/Damage_Overlay"
	elseif dmg == DMG_BLAST then
		mat = "sprites/UT2K4/Invis_overlay"
	elseif dmg == DMG_RADIATION then
		mat = "sprites/UT2K4/Bio_Damage"
	end
	return mat
end

function EFFECT:SetMaterial(mat)
	self.mat = mat
	self.model:SetMaterial(self.mat)	
end

function EFFECT:Render()
end

function EFFECT:NPCRagdollCheck(npc,ragdoll)
	DebugInfo(1,"client ragdoll made")
	if self.ent == npc then
		DebugInfo(2,"ent is npc")
		self.ent = ragdoll
		self.model:SetParent(self.ent)
		self.model:AddEffects(EF_BONEMERGE)
	end
end








