function EFFECT:Init(data)

	self.Grow = 0
	self.GrowSpeed = 6
	self.GrowDieTime = CurTime() + 0.20
	self.GrowModelScale = vector_origin
	
	self.Shrink = 25
	self.ShrinkSpeed = 1.2
	self.ShrinkDieTime = CurTime() + 1.5
	self.ShrinkModelScale = Vector(1,1,1)        

	self.CSShrinkModel = ClientsideModel("models/dav0r/hoverball.mdl", RENDER_GROUP_VIEW_MODEL_OPAQUE)
	if IsValid(self.CSShrinkModel) then
		self.CSShrinkModel:SetPos(data:GetOrigin())
		self.CSShrinkModel:SetNoDraw(true)
	end
	
	self.CSGrowModel = ClientsideModel("models/dav0r/hoverball.mdl", RENDER_GROUP_VIEW_MODEL_OPAQUE)
	if IsValid(self.CSGrowModel) then
		self.CSGrowModel:SetPos(data:GetOrigin())
		self.CSGrowModel:SetNoDraw(true)
	end
	
	local vOrig = data:GetOrigin()
	
	self.Emitter = ParticleEmitter(vOrig)
	
	for i=1,4 do
	
		local flash = self.Emitter:Add("particle/Particle_Glow_04", vOrig)
		
		if flash then
			flash:SetColor(200, 150, 255)
			flash:SetRoll(math.Rand(0, 360))
			flash:SetDieTime(0.40)
			flash:SetStartSize(100)
			flash:SetStartAlpha(255)
			flash:SetEndSize(220)
			flash:SetEndAlpha(0)
		end
		
		local flash2 = self.Emitter:Add("particle/Particle_Glow_05_AddNoFog", vOrig)
		
		if flash2 then
			flash2:SetColor(200, 150, 255)
			flash2:SetRoll(math.Rand(0, 360))
			flash2:SetDieTime(1.5)
			flash2:SetStartSize(180)
			flash2:SetStartAlpha(255)
			flash2:SetEndSize(0)
			flash2:SetEndAlpha(100)
		end
	
	end
	
	for i=1,24 do

		local flash3 = self.Emitter:Add("effects/stunstick", vOrig)
		
		if flash3 then
			flash3:SetColor(225, 150, 255)
			flash3:SetRoll(math.Rand(0, 360))
			flash3:SetVelocity(VectorRand():GetNormal()*math.random(300, 600))
			flash3:SetRoll(math.Rand(0, 360))
			flash3:SetRollDelta(math.Rand(-2, 2))
			flash3:SetDieTime(0.15)
			flash3:SetStartSize(40)
			flash3:SetStartAlpha(255)
			flash3:SetEndSize(120)
			flash3:SetEndAlpha(0)
		end
		
	end
	
	self.Emitter:Finish()
	
end

function EFFECT:Think()

	self.Shrink = Lerp(2 * self.ShrinkSpeed * FrameTime(), self.Shrink, 0)
	self.Grow = Lerp(2 * self.GrowSpeed * FrameTime(), self.Grow, 37)
	self.ShrinkModelScale = Vector(self.Shrink,self.Shrink,self.Shrink)
	self.GrowModelScale = Vector(self.Grow,self.Grow,self.Grow)
	
	if self.GrowDieTime && CurTime() > self.GrowDieTime then
		if IsValid(self.CSGrowModel) then
			self.CSGrowModel:Remove()
		end        
	end

	if self.ShrinkDieTime && CurTime() > self.ShrinkDieTime then
		if IsValid(self.CSShrinkModel) then
			self.CSShrinkModel:Remove()
		end
		return false
	end    
	
	return true
	
end

function EFFECT:Render()

	if IsValid(self.CSShrinkModel) then
		render.SuppressEngineLighting(true)
		render.SetColorModulation(150/255, 75/255, 1)
		render.SetBlend(1)
		self.CSShrinkModel:DrawModel()
		render.SuppressEngineLighting(false)
		render.SetBlend(1)
		render.SetColorModulation(1,1,1)
		self.CSShrinkModel:SetModelScale(0,1.2)    
		self.CSShrinkModel:SetMaterial("models/alyx/emptool_glow")
	end
	
	if IsValid(self.CSGrowModel) then
		render.SuppressEngineLighting(true)
		render.SetColorModulation(100/255, 50/255, 1)
		render.SetBlend(1)
		self.CSGrowModel:DrawModel()
		render.SuppressEngineLighting(false)
		render.SetBlend(1)
		render.SetColorModulation(1,1,1)
		self.CSGrowModel:SetModelScale(0,1.2)
		self.CSGrowModel:SetMaterial("models/alyx/emptool_glow")
	end
	
end