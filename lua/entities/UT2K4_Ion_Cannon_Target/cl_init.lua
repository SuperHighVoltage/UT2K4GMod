include('shared.lua')
 
ENT.Spawnable                   = false
ENT.AdminSpawnable              = false
ENT.RenderGroup                 = RENDERGROUP_OPAQUE
 
/*---------------------------------------------------------
   Overridden because I want to show the name of the
   player that spawned it..
---------------------------------------------------------*/
//function ENT:GetOverlayText()
 
 //       return self:GetPlayerName()    
       
//end

local Laser = Material( "cable/redlaser" )
function ENT:Draw()
	//self:DrawModel()
	render.SetMaterial( Laser )
	render.DrawBeam( self:GetPos(), self:LocalToWorld( Vector( self.Radius, 0, 0 ) ), 5, 1, 1, Color( 255, 255, 255, 255 ) )
	render.DrawBeam( self:GetPos(), self:LocalToWorld( Vector( -self.Radius, 0, 0 ) ), 5, 1, 1, Color( 255, 255, 255, 255 ) )
	render.DrawBeam( self:GetPos(), self:LocalToWorld( Vector( 0, self.Radius, 0 ) ), 5, 1, 1, Color( 255, 255, 255, 255 ) )
	render.DrawBeam( self:GetPos(), self:LocalToWorld( Vector( 0, -self.Radius, 0 ) ), 5, 1, 1, Color( 255, 255, 255, 255 ) )
	
//	render.DrawBeam( self:GetPos(), self:LocalToWorld( Vector( 0, 0, self.Radius ) ), 5, 1, 1, Color( 255, 255, 255, 255 ) )
//	render.DrawBeam( self:GetPos(), self:LocalToWorld( Vector( 0, 0, -self.Radius ) ), 5, 1, 1, Color( 255, 255, 255, 255 ) )
end

function ENT:Initialize()
	self.SpawnTime = CurTime()
end

function ENT:Think()

//self:SetModelScale((CurTime() - self.SpawnTime)*120)

        // Note: If you're overriding the next think time you need to return true
        self:NextThink(CurTime())
        return true
end