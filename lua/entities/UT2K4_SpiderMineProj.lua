AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName		= "UT2K4 Flak shell"
ENT.Author			= "HighVoltage"
ENT.Information		= "Flak shell from a UT2K4 flak cannon"
ENT.Category		= "UT2K4"

ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
	self:SetModel( "models/weapons/ut2k4_parasite_mine.mdl" );
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetGravity( 1 )
	self:SetSolid(SOLID_VPHYSICS)
	self:SetAnimation(ACT_GET_UP_CROUCH)
	return true
end

function ENT:PhysicsCollide(colData,collider)
	DebugInfo(1,"HitPos "..tostring(colData.HitPos))
	DebugInfo(2,"HitEntity "..tostring(colData.HitEntity))
	DebugInfo(3,"OurOldVelocity "..tostring(colData.OurOldVelocity))
	DebugInfo(4,"DeltaTime "..tostring(colData.DeltaTime))
	DebugInfo(5,"Speed "..tostring(colData.Speed))
	DebugInfo(6,"HitNormal "..tostring(colData.HitNormal))
	self:Remove()
end
function ENT:Touch(ent)
//	DebugInfo(1,"Ent "..tostring(ent))
	if ent:GetClass() == "UT2K4_SpiderMine" then
		self:SetVelocity(self:GetVelocity()*Vector(1,1,-1))
		return end
	print(self:GetVelocity( ))
	local tracedata = {}
	tracedata.start = self:GetPos()
	tracedata.endpos = self:GetPos()-Vector(0,0,10)
	tracedata.filter = self
	debugoverlay.Line( tracedata.start, tracedata.endpos, 10, Color(0,255,0), true)
	local trace = util.TraceLine(tracedata)
//	DebugInfo(2,"HitWorld "..tostring(trace.HitWorld))
//	DebugInfo(3,"Fraction "..tostring(trace.Fraction))
//	DebugInfo(4,"Hit "..tostring(trace.Hit))
//	DebugInfo(5,"HitNormal "..tostring(trace.HitNormal))
//	DebugInfo(6,"HitNormal Angle "..tostring(trace.HitNormal:Angle( )))
	debugoverlay.Text( tracedata.start, tostring(trace.HitNormal).." | "..tostring(trace.HitNormal:Angle( )), 10 )
//	DebugInfo(7,"HitPos "..tostring(trace.HitPos))
//	DebugInfo(8,"MatType "..tostring(trace.MatType))
//	DebugInfo(9,"HitTexture "..tostring(trace.HitTexture))
	debugoverlay.Cross(trace.HitPos, 5, 10, Color(0,0,255), true)
	local ang = trace.HitNormal:Angle( ).p - 270 
	if trace.Hit and ang < 54 then
		local Spider = ents.Create("UT2K4_SpiderMine")
		Spider:SetPos(self:GetPos())
		Spider:SetAngles(Angle(0,0,0))
		Spider:SetOwner(self:GetOwner())
		Spider:Spawn()
		Spider:SetSkin(self:GetSkin())
		self:ReplaceMine( self, Spider )
		self:Remove()
		DebugInfo(9,"Landing good")
	else
		self:Splode()
		DebugInfo(9,"Invalid landing, detonating")
	end	
end

function ENT:ReplaceMine( old, new )

	local ActionTaken = false

	if ( self.Owner.Mines ) then

		for key, ent in pairs( self.Owner.Mines ) do
			if ( ent == old ) then
				self.Owner.Mines[ key ] = new
				ActionTaken = true
			end
		end

	end

	return ActionTaken

end

function ENT:SetEnemy(ent)
	
end

function ENT:Splode()
if SERVER then
	local Boom = ents.Create("env_explosion")
	Boom:SetPos(self:GetPos())
	Boom:SetKeyValue( "iMagnitude", "90" )
//	Boom:SetOwner(self.Entity:GetOwner())
	Boom:SetOwner(self:GetOwner())	
	Boom:Spawn()
	Boom:Fire("Explode",0,0)
	Boom:Fire("Kill",0,0)
	
	if self.WalkSound then
		self.WalkSound:Stop()
		self.WalkSound = nil
	end
end	
	self:Remove()
end

function ENT:Think()
	if  self:GetOwner() and  self:GetOwner():IsPlayer() and !self:GetOwner():Alive() then
		self:Splode()
	end
end

local time = CurTime()
function ENT:Thiwnk()
//	DebugInfo(1,"Ent "..tostring(ent))
	if CurTime() > time + 1 then
		time = CurTime()
		
		local tracedata = {}
		tracedata.start = Vector(0,0,0)
		tracedata.endpos = tracedata.start-Vector(0,0,60)
		tracedata.filter = self
		debugoverlay.Line( tracedata.start, tracedata.endpos, 1, Color(0,255,0), true)
		local trace = util.TraceLine(tracedata)
		DebugInfo(2,"HitWorld "..tostring(trace.HitWorld))
		DebugInfo(3,"Fraction "..tostring(trace.Fraction))
		DebugInfo(4,"Hit "..tostring(trace.Hit))
		DebugInfo(5,"HitNormal "..tostring(trace.HitNormal))
		DebugInfo(6,"HitNormal Angle "..tostring(trace.HitNormal:Angle( )))
		debugoverlay.Text( tracedata.start, tostring(trace.HitNormal).." | "..tostring(trace.HitNormal:Angle( )), 1 )
		DebugInfo(7,"HitPos "..tostring(trace.HitPos))
		DebugInfo(8,"MatType "..tostring(trace.MatType))
		DebugInfo(9,"HitTexture "..tostring(trace.HitTexture))
		debugoverlay.Cross(trace.HitPos, 5, 1, Color(0,0,255), true)
		local ang = trace.HitNormal:Angle( ).p - 270 
		if trace.Hit and ang < 54 then
			debugoverlay.Text( trace.HitPos, "Good ".. ang, 1 )
		else
			debugoverlay.Text( trace.HitPos, "Bad", 1 )
		end	
		
	end
end