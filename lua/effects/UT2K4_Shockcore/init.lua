function EFFECT:Init(data)
	self.LastFlash = CurTime()
	if !IsValid(data:GetEntity()) then return end
	self.Ent = data:GetEntity()
	self.Emitter = ParticleEmitter(self.Ent:GetPos())
	if IsValid(self.Ent) then
		self:SetParent(self.Ent)
	end
end


function EFFECT:Think()
	
	if !IsValid(self.Ent) || (IsValid(self.Ent) && self.Ent.Hit) then return false end

	if IsValid(self.Ent) && !self.Ent.Hit && self.LastFlash < CurTime() then

		for i=1,3 do

			local corona = self.Emitter:Add("effects/rollerglow", self.Ent:GetPos())
			
			if corona then
				corona:SetColor(225, 40, 80)
				corona:SetRoll(math.Rand(0, 360))
				corona:SetVelocity(VectorRand():GetNormal()*math.random(0, 20))
				corona:SetRoll(math.Rand(0, 360))
				corona:SetRollDelta(math.Rand(-2, 2))
				corona:SetDieTime(0.01)
				corona:SetStartSize(55)
				corona:SetStartAlpha(150)
				corona:SetEndAlpha(150)
				corona:SetEndSize(55)
			end
			
//			local rot = self.Emitter:Add("effects/ar2_altfire1", self.Ent:GetPos())	--effects/ar2_altfire1 causes crashing??? effects/flashlight001 effects/fluttercore  particle/particle_ring_wave particle/particle_sphere
			
			if rot then
				rot:SetColor(125, 75, 170)
				rot:SetRoll(math.Rand(0, 360))
				rot:SetVelocity(VectorRand():GetNormal()*math.random(0, 20))
				rot:SetRoll(math.Rand(0, 360))
				rot:SetRollDelta(math.Rand(-2, 2))
				rot:SetDieTime(0.01)
				rot:SetStartSize(25)
				rot:SetStartAlpha(150)
				rot:SetEndAlpha(150)
				rot:SetEndSize(25)
			end

			local glow = self.Emitter:Add("particle/Particle_Glow_05", self.Ent:GetPos())
			
			if glow then
				glow:SetColor(210, 200, 255)
				glow:SetRoll(math.Rand(0, 360))
				glow:SetVelocity(VectorRand():GetNormal()*math.random(0, 20))
				glow:SetRoll(math.Rand(0, 360))
				glow:SetRollDelta(math.Rand(-2, 2))
				glow:SetDieTime(0.01)
				glow:SetStartSize(45)
				glow:SetStartAlpha(200)
				glow:SetEndAlpha(255)
				glow:SetEndSize(45)
			end
			
			local glow_add = self.Emitter:Add("particle/Particle_Glow_05_AddNoFog", self.Ent:GetPos())
			
			if glow_add then
				glow_add:SetColor(210, 170, 255)
				glow_add:SetRoll(math.Rand(0, 360))
				glow_add:SetVelocity(VectorRand():GetNormal()*math.random(0, 20))
				glow_add:SetRoll(math.Rand(0, 360))
				glow_add:SetRollDelta(math.Rand(-2, 2))
				glow_add:SetDieTime(0.01)
				glow_add:SetStartSize(50)
				glow_add:SetStartAlpha(255)
				glow_add:SetEndAlpha(255)
				glow_add:SetEndSize(50)
			end

		end
		
		self.LastPuff = CurTime() + 0.03
		
	end
	
	self.Emitter:Finish()    
	return true
	
end

function EFFECT:Render()
end