function EFFECT:Init(data)
	self.LastFlash = CurTime()
	if !IsValid(data:GetEntity()) then return end
	self.Ent = data:GetEntity()
	self.Radius = data:GetRadius()
	self.Emitter = ParticleEmitter(self.Ent:GetPos())
	if IsValid(self.Ent) then
		self:SetParent(self.Ent)
	end
end

function EFFECT:Think()

	if !IsValid(self.Ent) || (IsValid(self.Ent) && self.Ent.Hit) then return false end

	if IsValid(self.Ent) && !self.Ent.Hit && self.LastFlash < CurTime() then

//		for i=1,3 do

			local particle = self.Emitter:Add( "particles/smokey", self.Ent:GetPos() )
			if particle then
				particle:SetVelocity(Vector(0,0,5))
				particle:SetDieTime( 1 )
				particle:SetStartAlpha( 127 )
				particle:SetStartSize( self.Radius )
				particle:SetEndAlpha( 1 )
				particle:SetEndSize( self.Radius + 10 )
				particle:SetRoll( math.Rand( 360, 480 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( 255, 255, 255 )
				particle:VelocityDecay( false )
			end
			
//		end
		
		self.LastFlash = CurTime() + 0.005
		
	end
	
	self.Emitter:Finish()    

	return true
	
end

function EFFECT:Render()
end
