EFFECT.Mat1 = Material("trails/laser")
EFFECT.Mat2 = Material("sprites/tp_beam001")
EFFECT.Mat3 = Material("trails/electric")
EFFECT.Mat4 = Material("sprites/physgbeamb")
EFFECT.Ring1 = Material("effects/splashwake1")
EFFECT.Ring3 = Material("sprites/blueglow2")

function EFFECT:Init(data)

	self.Weapon = data:GetEntity()
	self.Owner = self.Weapon.Owner
	self.Normal = data:GetNormal()
	
	
	if self.Normal then
		self.NormalAng = data:GetNormal():Angle() + Angle(0.01, 0.01, 0.01)
	end
	
	if !IsValid(self.Owner) || (self.Owner && !self.Owner:GetActiveWeapon()) then
		return false
	end
	
	local vm = self.Owner:GetViewModel()

	if IsValid(GetViewEntity()) && (self.Owner == GetViewEntity()) && IsValid(vm) then
		self.StartPos = vm:GetAttachment(vm:LookupAttachment("muzzle")).Pos
	elseif IsValid(GetViewEntity()) && self.Owner != GetViewEntity() && self.Weapon then
		self.StartPos = self.Weapon:GetAttachment(self.Weapon:LookupAttachment("muzzle")).Pos
	elseif IsValid(vm) then
		self.StartPos = vm:GetAttachment(vm:LookupAttachment("muzzle")).Pos+self.Owner:GetAimVector():Angle():Right()*36-self.Owner:GetAimVector():Angle():Up()*36
	end

	self.EndPos = data:GetOrigin()
	self.Dir = self.EndPos-self.StartPos
	
	self.Width = 3
	self.Shrink = 20
	
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	self.FadeDelay = 0.3
	self.FadeTime = CurTime() + self.FadeDelay
	self.DieTime = CurTime() + 1.5
	
	self.Alpha = 255
	self.FadeSpeed = 0.5
	
	self.Emitter = ParticleEmitter(self.StartPos)
	
	for i=1,8 do
	
		local muzz = self.Emitter:Add("effects/combinemuzzle2_dark", self.StartPos)
		
		if muzz then
			muzz:SetColor(150, 100, 255)
			muzz:SetRoll(math.Rand(0, 360))
			muzz:SetDieTime(self.FadeDelay + self.FadeSpeed)
			muzz:SetStartSize(15)
			muzz:SetStartAlpha(255)
			muzz:SetEndSize(0)
			muzz:SetEndAlpha(100)
		end
	
	end
	
	for i=1,8 do
	
		local impact = self.Emitter:Add("effects/blueflare1", self.EndPos)
		
		if impact then    
			impact:SetColor(150, 100, 255)
			impact:SetRoll(math.Rand(0, 360))
			impact:SetDieTime(self.FadeDelay + self.FadeSpeed)
			impact:SetStartSize(10)
			impact:SetStartAlpha(255)
			impact:SetEndSize(0)
			impact:SetEndAlpha(200)
			impact:SetAngles(self.NormalAng)
		end
	
	end
	
	self.Emitter:Finish()
	
end

function EFFECT:Think()

	if self.FadeTime && CurTime() > self.FadeTime then
		self.Alpha = Lerp(13 * self.FadeSpeed * FrameTime(), self.Alpha, 0)
		self.Shrink = Lerp(2 * self.FadeSpeed * FrameTime(), self.Shrink, 0)
	end

	if self.DieTime && CurTime() > self.DieTime then
		return false
	end
	
	return true
	
end

function EFFECT:Render()
	if self.Width && self.Alpha then
		self.Width = math.Max(self.Width - 0.5, 0)
		local endPos = self.EndPos
		render.SetMaterial(self.Mat1)
		render.DrawBeam(endPos, self.StartPos, self.Shrink + (self.Width * 10), 1, 0, Color(170, 50, 200, self.Alpha))
		render.SetMaterial(self.Mat2)
		render.DrawBeam(endPos, self.StartPos, self.Shrink * 1.25 + (self.Width * 10), 1, 0, Color(165, 50, 200, self.Alpha))
		render.SetMaterial(self.Mat3)
		render.DrawBeam(endPos, self.StartPos, self.Shrink * 1.5 + (self.Width * 10), 1, 0, Color(165, 50, 200, self.Alpha))
		render.SetMaterial(self.Mat4)
		render.DrawBeam(endPos, self.StartPos, self.Shrink/7 + (self.Width * 10) , 1, 0, Color(200, 150, 200, self.Alpha))
		render.SetMaterial(self.Ring1)
		render.DrawQuadEasy(self:GetPos(), self.NormalAng:Forward(), 50, 50, Color(165, 150, 200, self.Alpha))
		render.SetMaterial(self.Ring3)
		render.DrawQuadEasy(self:GetPos(), self.NormalAng:Forward(), 50, 50, Color(170, 100, 200, self.Alpha))
	end
end
