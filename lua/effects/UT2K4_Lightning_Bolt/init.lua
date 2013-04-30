
EFFECT.Mat = Material( "sprites/UT2K4/Lightning_bolt" )
//EFFECT.Mat = Material( "effects/tool_tracer" )
EFFECT.Mat2 = Material( "sprites/UT2K4/blueflare1" )
EFFECT.Mat2b = Material( "sprites/UT2K4/EFlareB2" )
EFFECT.Mat2c = Material( "sprites/UT2K4/FlashFlare1" )
EFFECT.Matb = Material( "sprites/UT2K4/Lightning_bolt_end" )
/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

//	self.Position = data:GetStart()
//	self.WeaponEnt = data:GetEntity()
//	self.Attachment = data:GetAttachment()

	//self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
//	self.StartPos = self.Position
//	self.EndPos = data:GetOrigin()
	
	
	
	self.Weapon = data:GetEntity()
	self.Owner = self.Weapon.Owner
	
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
	
	local pos = data:GetOrigin()
	
	local off = Vector( math.random(-100,100), math.random(-100,100), math.random(-100,100) )
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = (pos + off)		//make it any random angle
	tracedata.filter = self.Owner
	self.randomTrace = util.TraceLine(tracedata)	
	
	local off2 = Vector( math.random(-100,100), math.random(-100,100), math.random(-100,100) )
	local tracedata2 = {}
	tracedata2.start = pos
	tracedata2.endpos = (pos + off2)		//make it any random angle
	tracedata2.filter = self.Owner
	self.randomTrace2 = util.TraceLine(tracedata2)
	
	local off3 = Vector( math.random(-100,100), math.random(-100,100), math.random(-100,100) )
	local tracedata3 = {}
	tracedata3.start = pos
	tracedata3.endpos = (pos + off3)		//make it any random angle
	tracedata3.filter = self.Owner
	self.randomTrace3 = util.TraceLine(tracedata3)		
	
	
	
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.Time = 1
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	self.Time = self.Time - (FrameTime() * 1.2) -- lower for slower speed 1.2 good speed
//print("self.Time = ".. self.Time.. ".  alpha should be: "..	(self.Time * 255))
	if self.Time < 0 then
		return false
	end
	return true
end

/*---------------------------------------------------------
   Draw the effect	
---------------------------------------------------------*/
function EFFECT:Render( )
	local randomTr = self.randomTrace
	local randomTr2 = self.randomTrace2
	local randomTr3 = self.randomTrace3
	self.Length = (self.StartPos - self.EndPos):Length()	
	self.Length1 = (self.EndPos - randomTr.HitPos):Length()	
	self.Length2 = (self.EndPos - randomTr2.HitPos):Length()	
	self.Length3 = (self.EndPos - randomTr3.HitPos):Length()		
	local alpha = self.Time * 255	
	
//print("alpha = ".. alpha)
	render.SetMaterial( self.Mat )
	render.DrawBeam( self.StartPos, 
					 self.EndPos,	
					 8,			
					 0,			
					 self.Length / 128,	
					 Color( 255, 255, 255, alpha ) )						 
	render.SetMaterial( self.Mat2b )
	render.DrawSprite( self.EndPos, 128, 128, Color(255,255,255,alpha))
	render.SetMaterial( self.Mat2b )
	render.DrawSprite( self.StartPos, 128, 128, Color(255,255,255,alpha))
	

//should make a random beam shoot out	
	render.SetMaterial( self.Mat )
	render.DrawBeam( self.EndPos, 
					 randomTr.HitPos,	
					 8,			
					 0,			
					 self.Length1 / 128,	
					 Color( 255, 255, 255, alpha ) )
//	render.SetMaterial( self.Matb )
	render.DrawBeam( self.EndPos, 
					 randomTr2.HitPos,	
					 8,			
					 0,			
					 self.Length2 / 128,	
					 Color( 255, 255, 255, alpha ) )
//	render.SetMaterial( self.Matb )
	render.DrawBeam( self.EndPos, 
					 randomTr3.HitPos,	
					 8,			
					 0,			
					 self.Length3 / 128,	
					 Color( 255, 255, 255, alpha ) )					 
end
