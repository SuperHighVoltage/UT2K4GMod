EFFECT.Mat1 = Material("trails/laser")
EFFECT.Mat2 = Material("sprites/tp_beam001")
EFFECT.Mat3 = Material("trails/electric")
EFFECT.Mat4 = Material("sprites/physgbeamb")
EFFECT.Ring1 = Material("sprites/UT2K4/IonFlare1")
EFFECT.Ring2 = Material("sprites/UT2K4/IonFlare2")
EFFECT.Ring3 = Material("sprites/UT2K4/IonFlare3")

function EFFECT:Init(data)

	self.Ent = data:GetEntity()
	self.Pos = data:GetOrigin()
	self.Radius = data:GetRadius()
	self.StartPos1 = data:GetStart()
	self.StartPos2 = nil
	self.StartPos3 = nil
	self.modelgrow = true
	
	Tr1 = util.QuickTrace( self.Pos, Vector(0,0.35,0.8)*5000,self.Ent )
	Tr2 = util.QuickTrace( self.Pos, Vector(0,-0.35,0.8)*5000,self.Ent )

	if Tr1.HitSky or !Tr1.Hit then
		self.StartPos2 = Tr1.HitPos
	end
	if Tr2.HitSky or !Tr2.Hit then
		self.StartPos3 = Tr2.HitPos
	end
	self.EndPos1 = self.StartPos1
	self.EndPos2 = self.StartPos2
	self.EndPos3 = self.StartPos3
	
	self.StartTime = CurTime()
//	self.Time = CurTime() - self.StartTime
	self.shake = true
	
	self.Sphere1 = ClientsideModel("models/HighVoltage/UT2K4/Effects/ion_sphere.mdl",RENDERGROUP_OPAQUE)
	self.Sphere1:SetPos(self.Pos)
	
	self.Sphere2 = ClientsideModel("models/HighVoltage/UT2K4/Effects/ion_ring.mdl",RENDERGROUP_OPAQUE)
	self.Sphere2:SetPos(self.Pos)
end

function EFFECT:Think()
--[[
	if self.FadeTime && CurTime() > self.FadeTime then
		self.Alpha = Lerp(13 * self.FadeSpeed * FrameTime(), self.Alpha, 0)
		self.Shrink = Lerp(2 * self.FadeSpeed * FrameTime(), self.Shrink, 0)
	end]]--
	local Time = CurTime() - self.StartTime
	if Time <= 1 then
		self.EndPos1 = LerpVector( Time, self.StartPos1, self.Pos )
	else
		self.EndPos1 = self.Pos
	end
	if Time <= 1 and self.StartPos2 then
		self.EndPos2 = LerpVector( Time, self.StartPos2 , self.Pos )
	else
		self.EndPos2 = self.Pos
	end
	if Time <= 1 and self.StartPos3 then
		self.EndPos3 = LerpVector( Time, self.StartPos3 , self.Pos )
	else
		self.EndPos3 = self.Pos
	end
	
	if Time >= 1 and self.shake == true then
		util.ScreenShake( self.Pos, 5, 5, 2, self.Radius*1.01 )
		self.shake = false
	end
	
	-- start scaling medel effects
	if Time >= 1.7 then
		local size = Matrix()
		local num = Lerp( (Time-1.7)/1.5, 1 , 800 )
		size:Scale( Vector( num,num,Lerp( (Time-1.7)/1.5, 1 , 500 ) ) )
		self.Sphere1:EnableMatrix( "RenderMultiply", size )
		//self.Sphere1:SetModelScale(20, 1.5)
		local size2 = Matrix()
		local num2 = Lerp( (Time-1.7)/1.2, 1 , 700 )
		size2:Scale( Vector( num2,num2,1 ) )
		self.Sphere2:EnableMatrix( "RenderMultiply", size2 )
	end
	
	-- start fading ring effect
	if Time >= 2.5 then
		self.Sphere2:SetColor(Color(255,255,255,Lerp(Time-2.5,255,0)))//not working
		self.Sphere2:SetColor(Color(255,255,255,50))
	end
	
	
	if Time >= 3 then
		self.Sphere1:SetColor(Color(255,255,255,Lerp((Time-3)*5,255,0)))
	end

	if Time >= 3.2 then
		if self.Sphere1 then
			self.Sphere1:Remove()
		end
		if self.Sphere2 then
			self.Sphere2:Remove()
		end
		return false
	end
	
	return true
	
end

function EFFECT:Render()
//	if self.Width && self.Alpha then
//		self.Width = math.Max(self.Width - 0.5, 0)
	local Time = CurTime() - self.StartTime
	
	---------- Beams ----------
	if Time <= 2.5 then
		local alpha1 = 255
		local alpha2 = 100
		if Time >= 1.5  then
			alpha1 = Lerp((Time-1.5),255,0)
			alpha1 = Lerp((Time-1.5),100,0)
		end	
		local endPos = self.Pos
		render.SetMaterial(self.Mat4)
		render.DrawBeam(endPos, self.StartPos1, 200, 1, 0, Color(170, 50, 200, 100))
		render.SetMaterial(self.Mat4)
		render.DrawBeam(self.EndPos1, self.StartPos1, 25, 1, 0, Color(165, 50, 200, alpha1))
		render.SetMaterial( self.Ring2 )
		render.DrawSprite( self.EndPos1, 300, 300, Color(165, 50, 200, 255) )
		if self.StartPos2 then
			render.SetMaterial(self.Mat4)
			render.DrawBeam(endPos, self.StartPos2, 200, 1, 0, Color(165, 50, 200, 100))
			render.SetMaterial(self.Mat4)
			render.DrawBeam(self.EndPos2, self.StartPos2, 25, 1, 0, Color(165, 50, 200, alpha1))
			render.SetMaterial( self.Ring2 )
			render.DrawSprite( self.EndPos2, 300, 300, Color(165, 50, 200, 255) )
		end
		if self.StartPos3 then
			render.SetMaterial(self.Mat4)
			render.DrawBeam(endPos, self.StartPos3, 200, 1, 0, Color(165, 50, 200, 100))
			render.SetMaterial(self.Mat4)
			render.DrawBeam(self.EndPos3, self.StartPos3, 25, 1, 0, Color(165, 50, 200, alpha1))
			render.SetMaterial( self.Ring2 )
			render.DrawSprite( self.EndPos3, 300, 300, Color(165, 50, 200, 255) )
		end
	end
	
---------- Center flare ----------
	if Time >= 1 and Time <= 1.5 then
		local size = Lerp((Time-1)*2,0,1800)
		render.SetMaterial( self.Ring1 )
		render.DrawSprite( self.Pos, size, size, Color(165, 50, 200, 255) )
	end	
	if Time >= 1.5 and Time <= 1.75 then
		local size = Lerp((Time-1.5)*3,1800,0)
		render.SetMaterial( self.Ring1 )
		render.DrawSprite( self.Pos, size, size, Color(165, 50, 200, 255) )
	end	
	if Time >= 1.70 and Time <= 3.20 and false then
		local size = (Time-1.70)*700//Lerp((Time-1.20)/1.5,0,2000)
		render.SetMaterial( self.Ring3 )
		render.DrawSprite( self.Pos, size, size, Color(165, 50, 200, 255) )
		
//		self.Sphere1Mat:Scale( Vector( size, size, size ) ) 
//		self.Sphere1:EnableMatrix( "RenderMultiply", self.Sphere1Mat );
	end	
end
