AddCSLuaFile()

sound.Add( 
{
 name = "UT2K4.SpiderMineWalk",
 channel = CHAN_STATIC,												-- Debug numbers:
 volume = 1.0,														-- 0	Enemy status
 soundlevel = 80,													-- 1	Jumping
 pitchstart = 95,													-- 2	Try to chase
 pitchend = 110,													-- 3	Start moving
 sound = {	"UT2K4/Weapons/MineLayer/SpiderMineWalk01.wav",			-- 4	Stuck
			"UT2K4/Weapons/MineLayer/SpiderMineWalk02.wav",			-- 5	Done chasing
			"UT2K4/Weapons/MineLayer/SpiderMineWalk03.wav"} 		-- 6
} )																	-- 7
																	-- 8
ENT.Base 			= "base_nextbot"								-- 9
ENT.Spawnable		= true											-- 10
																	-- 11
function ENT:Initialize()

	self:SetModel( "models/weapons/ut2k4_parasite_mine.mdl" );
//	self:SetSkin(math.random(0,1))
	self:SetHealth(10)
	
	self.loco:SetDeathDropHeight(500)	//default 200
	self.loco:SetAcceleration(900)		//default 400
	self.loco:SetDeceleration(900)		//default 400
	self.loco:SetStepHeight(18)			//default 18
	self.loco:SetJumpHeight(70)			//default 58
	
	self.IsJumping = false
	self.Closed = false
	self.IdleSearchTime = nil
//	self:SetCollisionGroup(COLLISION_GROUP_NPC)
	
	local wav = Sound("UT2K4.SpiderMineWalk")
	self.WalkSound = CreateSound(self, wav )
		
	self.LoseTargetDist = 1000
	self.SearchRadius = 400
end

function ENT:AnglesCheck()		-- Set angles to match to ground
	local tracedata = {}
	tracedata.start = self:GetPos()+Vector(0,0,10)
	tracedata.endpos = self:GetPos()-Vector(0,0,10)
	tracedata.filter = self
	debugoverlay.Line( tracedata.start, tracedata.endpos, 0.05, Color(0,255,0), true)
	local trace = util.TraceLine(tracedata)
	debugoverlay.Cross(trace.HitPos, 7, 0.05, Color(0,0,255), true)
	debugoverlay.Text( trace.HitPos, tostring(trace.Fraction), 0.05 )
	
	DebugInfo(6,tostring(self:GetAngles()).." Self angles")
	DebugInfo(7,tostring(trace.HitNormal:Angle()).." Trace angle")
	local NewAngle = Angle(trace.HitNormal:Angle().p-270, self:GetAngles().y, trace.HitNormal:Angle().r)
	DebugInfo(8,tostring(NewAngle).." New angle")
//	self:SetAngles(NewAngle)
end

function ENT:BehaveUpdate( fInterval )
//MsgN("BehaveUpdate")
	if  self:GetOwner() and  self:GetOwner():IsPlayer() and !self:GetOwner():Alive() then
		self:Splode()
	end
	if ( !self.BehaveThread ) then return end
	
//	self:CollisionCheck()
//	self:AnglesCheck()
	
	if self.loco:IsClimbingOrJumping( ) then
		DebugInfo(1,"Jumping "..CurTime())
	end	

	if GetConVarNumber( "ai_disabled") == 0 then	
		//debugoverlay.Sphere( self:GetPos(), 120, .05, Color(200,0,0), false )
		//debugoverlay.Sphere( self:GetPos(), 50, .05, Color(0,0,200), false )
		if (!self.IsJumping) then	// If not already jumping check to see if we will jump at an enemy
			local ent = ents.FindInSphere( self:GetPos(), 120 )
			for k,v in pairs( ent ) do
				if self:IsEnemy(v) then//(v:IsPlayer() and v:Alive() and self:GetOwner() != v and GetConVarNumber( "ai_ignoreplayers") == 0) or v:IsNPC() or ( v:IsVehicle() and v:GetDriver():IsPlayer() and self:GetOwner() != v ) then
					//jump at the player
					//local angle = ( v:LocalToWorld(v:OBBCenter()) - self:GetPos()):Angle()
					//self:SetVelocity( angle:Forward()*1000 )
					self.loco:FaceTowards( v:GetPos() )
					self.loco:Jump( )
					self.IsJumping = true
				end
			end	
		else	// If close to a enemy explode at them
			local ent = ents.FindInSphere( self:GetPos(), 50 )
			for k,v in pairs( ent ) do
				if self:IsEnemy(v) then//(v:IsPlayer() and v:Alive() and self:GetOwner() != v and GetConVarNumber( "ai_ignoreplayers") == 0) or v:IsNPC() or ( v:IsVehicle() and v:GetDriver():IsPlayer() and self:GetOwner() != v ) then
					self:Splode()
				end
			end	
		end
		
		if IsValid(self.Enemy) then
			if self.Enemy != NULL and self.Enemy and IsEntity(self.Enemy) and self.Enemy:GetClass() == "sent_ball" then
				if self:GetPos():Distance(self.Enemy:GetPos()) < 50 then
					local ang = ( self.Enemy:GetPos() - self:GetPos()):Angle()

					local vec = ang:Forward()
					local vec2 = ang:Right()*math.random()
					self.Enemy:GetPhysicsObject():SetVelocity( (vec+vec2)*500 )
				end
			end
		end
	end
	
	if self.WalkSound then	
		if self.loco:IsAttemptingToMove() then
			self.WalkSound:Play()
		else
			self.WalkSound:Stop()
		end
	end

	local ok, message = coroutine.resume( self.BehaveThread )
	if ( ok == false ) then

		self.BehaveThread = nil
		Msg( self, "error: ", message, "\n" );

	end

end

function ENT:RunBehaviour()

	while ( true ) do
		
		if ( !self:GetEnemy() ) then	// If there is no enemy
--[[		
			if !self.IdleSearchTime then
				self.IdleSearchTime = CurTime() + math.Rand(10,15)
				print(team.GetAllTeams( ))
			elseif self.IdleSearchTime < CurTime() then				-- If there is no enemy for some time
				DebugInfo(1,"No enemy for a while: Wandering")
				self.Closed = false
				self:StartActivity( ACT_GET_UP_CROUCH )				-- Open up
				coroutine.wait(1)
				if self:FindEnemy() then							-- Search for enemy just in case
					DebugInfo(0,"Found enemy")
				else
					self:StartActivity( ACT_WALK )                  -- If there is still no enemy        
					self.loco:SetDesiredSpeed( 100 )                        
					self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 200 ) -- walk to a random place within about 200 units (yielding)
					if self:FindEnemy() then						-- Search for enemy again
						DebugInfo(0,"Found enemy")
					else
						self:StartActivity( ACT_GET_DOWN_CROUCH )	-- No enemy, so close back down
						DebugInfo(0,"Still no enemy: closing down")
						coroutine.wait(1)
						self.Closed = true	
					end
				end		
				self.IdleSearchTime = nil
			end
			--]]--
			
//			if !self.Closed then			// close down if not already
//				self:StartActivity( ACT_GET_DOWN_CROUCH )
//				DebugInfo(0,"No enemy: closing down")
//				coroutine.wait(1)
//				self.Closed = true
//			end
			if self:FindEnemy() then	// search for enemy, if successfull open up
				DebugInfo(0,"Found enemy")
			else						// if it failed wait a second and search again
				coroutine.wait(0.1)
				DebugInfo(0,"No enemy: searching")
			end
			
		elseif self:GetEnemy() then 	// if there is an enemy, chase it
		
			self:StartActivity( ACT_RUN )				-- run anim
			self.loco:SetDesiredSpeed( 400 )			-- run speed	
			local opts = {	lookahead = 13000,
							tolerance = 20,
							draw = false,
							maxage = 1,
							repath = 0.1	}
			//self:MoveToPos( pos, opts )					-- move to position (yielding)
			//self:ChaseTarget( opts )
			self:Chase( opts )

//			if !self:GetEnemy() then
//				if !self.Closed then			// close down if not already
//					self:StartActivity( ACT_GET_DOWN_CROUCH )
//					DebugInfo(0,"No enemy: closing down")
//					coroutine.wait(1)
//					self.Closed = true
//				end
//			end

		else	// if some reason all else fails, walk somewhere random
			
        self:StartActivity( ACT_WALK )                            -- walk anims
        self.loco:SetDesiredSpeed( 100 )                        -- walk speeds
        self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 200 ) -- walk to a random place within about 200 units (yielding)
			
		end
		
		coroutine.yield()
		
	end


end

function ENT:ChaseTarget( options)		// Follow a target
	DebugInfo(2,"ChaseTarget "..CurTime())
	local options = options or {}
	local path = Path("Chase")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)

	path:Compute(self, self:GetEnemy():GetPos())

	while self:GetEnemy() do
		DebugInfo(3,"Located target: Chasing"..CurTime())
		path:Compute(self, self:GetEnemy():GetPos())
		if ( options.draw ) then path:Draw() end
		path:Chase(self, self:GetEnemy())
		
		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			DebugInfo(4,"Stuck "..CurTime())
			self:HandleStuck();
			return "stuck"
		end

		coroutine.yield()
	end

	DebugInfo(5,"return "..CurTime())
	return "ok"
end //if type(self:GetEnemy()) == "Entity" then

function ENT:Chase( options )
	DebugInfo(2,"MoveToPos "..CurTime())
	local options = options or {}

	local path = Path( "Follow" )	-- Define the path for the bot to follow
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 40 )
	if IsEntity(self:GetEnemy()) then
		path:Compute( self, self:GetEnemy():GetPos() )		-- Calculate the path for the bot
	elseif isvector(self:GetEnemy()) then
	local a = self:GetEnemy()
		path:Compute( self, Vector(a.x,a.y,a.z) )
	end

	while ( self:GetEnemy() ) do		
		DebugInfo(3,"Path is valid "..CurTime())
		if IsEntity(self:GetEnemy()) then
			path:Compute( self, self:GetEnemy():GetPos() )		-- Calculate the path for the bot
		elseif isvector(self:GetEnemy()) then
			local a = self:GetEnemy()
			path:Compute( self, Vector(a.x,a.y,a.z) )
		else
			return "dunno"
		end
		path:Update( self )		-- "Move the bot along the path"
		if ( options.draw ) then path:Draw() end

		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			DebugInfo(4,"Stuck "..CurTime())
			self:HandleStuck();
			return "stuck"
		end
		coroutine.yield()
	end
	DebugInfo(5,"return "..CurTime())
	return "ok"

end

function ENT:MoveToPos( pos, options )
	DebugInfo(2,"MoveToPos "..CurTime())
	local options = options or {}

	local path = Path( "Follow" )	-- Define the path for the bot to follow
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 40 )
	path:Compute( self, pos )		-- Calculate the path for the bot

	if ( !path:IsValid() ) then return "failed" end	

	-- A path will become invalid when its at its end pos or close enough (path:SetGoalTolerance)
	-- So this will be looped until it gets to its goal
	while ( path:IsValid() ) do		
		DebugInfo(3,"Path is valid "..CurTime())
		
		if self:FindEnemy() then
			DebugInfo(0,"Found enemy")
			return "ok"
		end
				
		path:Update( self )		-- "Move the bot along the path"

		-- Draw the path (only visible on listen servers or single player)
		if ( options.draw ) then
			path:Draw()
		end

		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			DebugInfo(4,"Stuck "..CurTime())
			self:HandleStuck();

			return "stuck"

		end

		--
		-- If they set maxage on options then make sure the path is younger than it
		--
		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end

		--
		-- If they set repath then rebuild the path every x seconds
		--
		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
		end

		coroutine.yield()

	end
	DebugInfo(5,"return "..CurTime())
	return "ok"

end

function ENT:FindEnemy()
	if GetConVarNumber( "ai_disabled") == 1 then return false end
//	debugoverlay.Sphere( self:GetPos(), self.SearchRadius, 1.1, Color(0,100,0), false )
	local ent = ents.FindInSphere( self:GetPos(), self.SearchRadius )
	for k,v in pairs( ent ) do
		if self:IsEnemy(v) then
			if (v:IsPlayer() and v:Alive()) and GetConVarNumber( "ai_ignoreplayers") == 0 then
				self:SetEnemy(v)
				return true
			elseif v:IsNPC() then
				v:AddEntityRelationship(self, D_HT, 999 )
				self:SetEnemy(v)
				return true
			elseif v:IsVehicle() and v:GetDriver() and v:GetDriver():IsPlayer()  and GetConVarNumber( "ai_ignoreplayers") == 0 then
				self:SetEnemy(v:GetDriver())
				return true
			end
		else			-- if not a enemy
			if v:GetClass() == "sent_ball" then	-- lets play ball
				self:SetEnemy(v)
				return true
			end
		end
	end	
	return false
end

function ENT:Open()		-- If closed open up
	if self.Closed then
		self:StartActivity( ACT_GET_UP_CROUCH )
		coroutine.wait(self:SequenceDuration())
		self.Closed = false
	end
end
function ENT:Close()	-- Vice versa
	if !self.Closed then
		self:StartActivity( ACT_GET_DOWN_CROUCH )
		coroutine.wait(self:SequenceDuration())
		self.Closed = true
	end
end

function ENT:IsEnemy(ent)
	if self:GetOwner() != nil then
		if self:GetOwner() == ent then		-- owner
			return false
		elseif ent:IsNPC() and ent:Disposition( self:GetOwner() ) == D_HT then	-- enemy npc
			return true
		elseif ent:IsPlayer() then //and ent:Team() != self:GetOwner():Team() then	-- non team member
			return true
		elseif ent:IsVehicle() and ent:GetDriver() and ent:GetDriver():IsPlayer() and ent:GetDriver():Team() != self:GetOwner():Team() then		--non team member vehicle
			return true
		end
		return false
	else
		return true		-- If there is no owner everything is an enemy
	end
end

function ENT:SetEnemy(ent)
	self.Enemy = ent
end

function ENT:GetEnemy()
	if isvector(self.Enemy) then
		self:Open()
		return self.Enemy
	elseif IsValid(self.Enemy) and self.Enemy and self.Enemy != NULL and self.Enemy != nil and self.Enemy:IsValid() and GetConVarNumber( "ai_disabled") == 0 then	//if self.Enemy is real
		//if the enemy isn't too far, dead, or not visible let us know
		if self:GetPos():Distance(self.Enemy:GetPos()) > self.LoseTargetDist then
			if !self:FindEnemy() then	--if the enemy is lost search to find another
				self.Enemy = nil
				self:Close()
				return false
			end
		elseif ( self.Enemy:IsPlayer() and !self.Enemy:Alive() ) or (self.Enemy:IsPlayer() and GetConVarNumber( "ai_ignoreplayers") == 1) then
			if !self:FindEnemy() then
				self.Enemy = nil
				self:Close()
				return false
			end
		end	
		self:Open()
		return self.Enemy
	else
		if !self:FindEnemy() then
			self.Enemy = nil
			self:Close()
			return false
		end
	end
end



function ENT:HandleStuck()
	--
	-- Clear the stuck status
	--
	self.loco:Jump( )		-- sort of works
	self.loco:ClearStuck();
	
end

function ENT:OnLandOnGround()

	self.IsJumping = false
	
	self:StartActivity( ACT_RUN )
	
end

function ENT:OnInjured( damageinfo )

	MsgN( "OnInjured" )
//	if damageinfo:GetAttacker():GetClass() == self:GetClass() then
//		damageinfo:SetDamage(0)
//	end

end

function ENT:OnKilled( damageinfo )
	MsgN( "OnKilled"..tostring(self) )
	MsgN( "OnKilled"..tostring(damageinfo:GetAttacker()) )
	if damageinfo:GetAttacker() != self then
		self:Splode()
	end
	self:BecomeRagdoll( damageinfo )

end

function ENT:Splode()
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
	self:Remove()
end

function ENT:OnRemove( damageinfo )
	MsgN( "OnRemove" )
end

function ENT:CollisionCheck()

	local start = self:GetPos() + (self:GetUp() * 20)
	
	local tracedata = {}
	tracedata.start = start
	tracedata.endpos = start + (self:GetForward() * 15)
	tracedata.filter = self
	tracedata.mins = Vector(self:GetRight() * -10, 0, self:GetUp() * -2)
	tracedata.maxs = Vector(self:GetRight() * 10, 0, self:GetUp() * 2)

	debugoverlay.Line( tracedata.start, tracedata.endpos, 0.1, Color(255,0,0), true )

	debugoverlay.Sphere( tracedata.start + Vector(self:GetRight() * -10, 0, self:GetUp() * -2), 10, .05, Color(200,200,0), false )
	
	debugoverlay.Line( tracedata.start + Vector(self:GetRight() * -10, 0, self:GetUp() * -2), tracedata.start + Vector(self:GetRight() * 10, 0, self:GetUp() * -2), 0.1, Color(0,255,0), true)
	debugoverlay.Line( tracedata.start + Vector(self:GetRight() * -10, 0, self:GetUp() * 2), tracedata.start + Vector(self:GetRight() * 10, 0, self:GetUp() * 2), 0.1, Color(0,255,0), true)

	debugoverlay.Line( tracedata.endpos + Vector(self:GetRight() * -10, 0, self:GetUp() * -2), tracedata.endpos + Vector(self:GetRight() * 10, 0, self:GetUp() * -2), 0.1, Color(0,255,0), true)
	debugoverlay.Line( tracedata.endpos + Vector(self:GetRight() * -10, 0, self:GetUp() * 2), tracedata.endpos + Vector(self:GetRight() * 10, 0, self:GetUp() * 2), 0.1, Color(0,255,0), true)

	local trace = util.TraceHull( tracedata )
	if trace.Hit then
		debugoverlay.Cross(trace.HitPos, 3, 0.1, Color(0,0,255), true)
	end
end

--
-- List the NPC as spawnable
--
list.Set( "NPC", "UT2K4_SpiderMine", 	{	Name = "UT2K4 Spider Mine", 
										Class = "UT2K4_SpiderMine",
										Category = "UT2K4"	
									})
									
									
/* old
AddCSLuaFile()

sound.Add( 
{
 name = "UT2K4.SpiderMineWalk",
 channel = CHAN_STATIC,
 volume = 1.0,
 soundlevel = 80,
 pitchstart = 95,
 pitchend = 110,
 sound = {	"UT2K4/Weapons/MineLayer/SpiderMineWalk01.wav",
			"UT2K4/Weapons/MineLayer/SpiderMineWalk02.wav",
			"UT2K4/Weapons/MineLayer/SpiderMineWalk03.wav"} 
} )

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true

function ENT:Initialize()

	self:SetModel( "models/weapons/ut2k4_parasite_mine.mdl" );
//	self:SetSkin(math.random(0,1))
	self:SetHealth(10)
	
	self.loco:SetDeathDropHeight(500)	//default 200
	self.loco:SetAcceleration(900)		//default 400
	self.loco:SetDeceleration(900)		//default 400
	self.loco:SetStepHeight(18)			//default 18
	self.loco:SetJumpHeight(70)		//default 58
	
	self.IsJumping = false
	self.IsLaunched = false
	self.Closed = false
	self:SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
	
	local wav = Sound("UT2K4.SpiderMineWalk")
	self.WalkSound = CreateSound(self, wav )
	
	self.LoseTargetDist = 10000
	self.SearchRadius = 400
	DebugInfo(11,"skin "..tostring(self:GetSkin()))	
end

function ENT:BehaveAct()	// Whats this and why is it here?
	MsgN("BehaveAct")	//??
end

--
-- Name: NEXTBOT:BehaveUpdate
-- Desc: Called to update the bot's behaviour
-- Arg1: number|interval|How long since the last update
-- Ret1:
--	
function ENT:BehaveUpdate( fInterval )
//MsgN("BehaveUpdate")
	if ( !self.BehaveThread ) then return end
	
	self:CollisionCheck()
	
	if self.loco:IsClimbingOrJumping( ) then
		DebugInfo(1,"Jumping "..CurTime())
	end	

	if GetConVarNumber( "ai_disabled") == 0 then	
		debugoverlay.Sphere( self:GetPos(), 120, .05, Color(200,0,0), false )
		debugoverlay.Sphere( self:GetPos(), 50, .05, Color(0,0,200), false )
		if (!self.IsJumping) then	// If not already jumping check to see if we will jump at an enemy
			local ent = ents.FindInSphere( self:GetPos(), 120 )
			for k,v in pairs( ent ) do
				if (v:IsPlayer() and v:Alive() and self:GetOwner() != v and GetConVarNumber( "ai_ignoreplayers") == 0) or v:IsNPC() or ( v:IsVehicle() and v:GetDriver():IsPlayer() and self:GetOwner() != v ) then
					//jump at the player
					//local angle = ( v:LocalToWorld(v:OBBCenter()) - self:GetPos()):Angle()
					//self:SetVelocity( angle:Forward()*1000 )
					self.loco:FaceTowards( v:GetPos() )
					self.loco:Jump( )
					self.IsJumping = true
				end
			end	
		else	// If close to a enemy explode at them
			local ent = ents.FindInSphere( self:GetPos(), 50 )
			for k,v in pairs( ent ) do
				if (v:IsPlayer() and v:Alive() and self:GetOwner() != v and GetConVarNumber( "ai_ignoreplayers") == 0) or v:IsNPC() or ( v:IsVehicle() and v:GetDriver():IsPlayer() and self:GetOwner() != v ) then
					self:Splode()
				end
			end	
		end
	end
	
	if self.WalkSound then	
		if self.loco:IsAttemptingToMove() then
			self.WalkSound:Play()
		else
			self.WalkSound:Stop()
		end
	end

	local ok, message = coroutine.resume( self.BehaveThread )
	if ( ok == false ) then

		self.BehaveThread = nil
		Msg( self, "error: ", message, "\n" );

	end

end

function ENT:RunBehaviour()

	while ( true ) do
		
		if self.IsLaunched then		// If being launched from weapon

			self:StartActivity( ACT_GET_UP_CROUCH )		// set according animation
			
		elseif ( !self:GetEnemy() ) then	// If there is no enemy
			if !self.Closed then			// close down if not already
				self:StartActivity( ACT_GET_DOWN_CROUCH )
				DebugInfo(0,"No enemy: closing down")
				coroutine.wait(1)
				self.Closed = true
			end
			if self:FindEnemy() then	// search for enemy, if successfull open up
			DebugInfo(0,"Found enemy")
				self.Closed = false
				self:StartActivity( ACT_GET_UP_CROUCH )
				coroutine.wait(1)
			else						// if it failed wait a second and search again
				coroutine.wait(0.1)
				DebugInfo(0,"No enemy: searching")
			end
			
		elseif self:GetEnemy() then 	// if there is an enemy, chase it
		
			pos = self:GetEnemy():GetPos()
			-- if the position is valid
			if ( pos ) then
				self:StartActivity( ACT_RUN )				-- run anim
				self.loco:SetDesiredSpeed( 400 )			-- run speed	
				local opts = {	lookahead = 1300,
								tolerance = 20,
								draw = true,
								maxage = 1,
								repath = 0.1	}
				
				//self:MoveToPos( pos, opts )													-- move to position (yielding)
				self:ChaseTarget( pos, opts )	
			else

				-- some activity to signify that we didn't find shit
				self:StartActivity( ACT_RUN )							-- walk anims
				self.loco:SetDesiredSpeed( 360 )						-- walk speeds
				self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 200 ) -- walk to a random place within about 200 units (yielding)
			end
			
//			if ( self:GetEnemy() and self:GetPos():Distance(self:GetEnemy():GetPos()) > 1000 ) or ( self:GetEnemy() and self:GetEnemy():IsPlayer() and !self:GetEnemy():Alive() ) then
//			DebugInfo(0,"Lost enemy")
//				self:SetEnemy(nil)
//			end
			if !self:GetEnemy() then
				if !self.Closed then			// close down if not already
					self:StartActivity( ACT_GET_DOWN_CROUCH )
					DebugInfo(0,"No enemy: closing down")
					coroutine.wait(1)
					self.Closed = true
				end
			end

		else	// if some reason all else fails, walk somewhere random
			
        self:StartActivity( ACT_WALK )                            -- walk anims
        self.loco:SetDesiredSpeed( 100 )                        -- walk speeds
        self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 200 ) -- walk to a random place within about 200 units (yielding)
			
		end
		
		coroutine.yield()
		
	end


end

function ENT:ChaseTarget(pos, options)		// Follow a target
	DebugInfo(2,"ChaseTarget "..CurTime())
	local options = options or {}
	local path = Path("Chase")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)

	path:Compute(self, pos)

	while self:GetEnemy() do
		DebugInfo(3,"Located target: Chasing"..CurTime())
		path:Compute(self, self:GetEnemy():GetPos())
		path:Draw()
		path:Chase(self, self:GetEnemy())
		
		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			DebugInfo(4,"Stuck "..CurTime())
			self:HandleStuck();
			return "stuck"
		end

		coroutine.yield()
	end

	DebugInfo(5,"return "..CurTime())
	return "ok"
end

function ENT:MoveToPos( pos, options )
	DebugInfo(2,"MoveToPos "..CurTime())
	local options = options or {}

	local path = Path( "Follow" )	-- Define the path for the bot to follow
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 40 )
	path:Compute( self, pos )		-- Calculate the path for the bot

	if ( !path:IsValid() ) then return "failed" end	

	-- A path will become invalid when its at its end pos or close enough (path:SetGoalTolerance)
	-- So this will be looped until it gets to its goal
	while ( path:IsValid() ) do		
		DebugInfo(3,"Path is valid "..CurTime())
		path:Update( self )		-- "Move the bot along the path"

		-- Draw the path (only visible on listen servers or single player)
		if ( options.draw ) then
			path:Draw()
		end

		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			DebugInfo(4,"Stuck "..CurTime())
			self:HandleStuck();

			return "stuck"

		end

		--
		-- If they set maxage on options then make sure the path is younger than it
		--
		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end

		--
		-- If they set repath then rebuild the path every x seconds
		--
		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
		end

		coroutine.yield()

	end
	DebugInfo(5,"return "..CurTime())
	return "ok"

end

function ENT:FindEnemy()
	if GetConVarNumber( "ai_disabled") == 1 then return false end
	debugoverlay.Sphere( self:GetPos(), self.SearchRadius, 1.1, Color(0,100,0), false )
	local ent = ents.FindInSphere( self:GetPos(), self.SearchRadius )
	for k,v in pairs( ent ) do
		if self:GetOwner() != v then
			if (v:IsPlayer() and v:Alive()) and GetConVarNumber( "ai_ignoreplayers") == 0 then
				self:SetEnemy(v)
				return true
			elseif v:IsNPC() then
				v:AddEntityRelationship(self, D_HT, 999 )
				self:SetEnemy(v)
				return true
			elseif v:IsVehicle() and v:GetDriver() and v:GetDriver():IsPlayer()  and GetConVarNumber( "ai_ignoreplayers") == 0 then
				self:SetEnemy(v:GetDriver())
				return true
			end
		end
	end	
	return false
end

function ENT:SetEnemy(ent)
	self.Enemy = ent
end

function ENT:GetEnemy()
	if self.Enemy and self.Enemy != NULL and self.Enemy:IsValid() and GetConVarNumber( "ai_disabled") == 0 then	//if self.Enemy is real
		//if the enemy isn't too far, dead, or not visible let us know
		if self:GetPos():Distance(self.Enemy:GetPos()) > self.LoseTargetDist then
			self.Enemy = nil
			return false
		elseif ( self.Enemy:IsPlayer() and !self.Enemy:Alive() ) or (self.Enemy:IsPlayer() and GetConVarNumber( "ai_ignoreplayers") == 1) then
			self.Enemy = nil
			return false
		end	

		return self.Enemy
	else
		self.Enemy = nil
		return nil
	end
end

function ENT:HandleStuck()
	--
	-- Clear the stuck status
	--
	self.loco:Jump( )
	self.loco:ClearStuck();
	
end

function ENT:OnLandOnGround()

	self.IsLaunched = nil
	self.IsJumping = false
	
	self:StartActivity( ACT_RUN )
	
end

function ENT:OnInjured( damageinfo )

	MsgN( "OnInjured" )
//	if !damageinfo:GetAttacker() == self then
//		self:Splode()
//	end

end

function ENT:OnKilled( damageinfo )
	MsgN( "OnKilled"..tostring(self) )
	MsgN( "OnKilled"..tostring(damageinfo:GetAttacker()) )
	if ( damageinfo:GetAttacker() != self ) then
		self:Splode()
	end
	self:BecomeRagdoll( damageinfo )

end

function ENT:Splode()
	local Boom = ents.Create("env_explosion")
	Boom:SetPos(self:GetPos())
	Boom:SetKeyValue( "iMagnitude", "90" )
//	Boom:SetOwner(self.Entity:GetOwner())
	Boom:SetOwner(self)	
	Boom:Spawn()
	Boom:Fire("Explode",0,0)
	Boom:Fire("Kill",0,0)
	
	if self.WalkSound then
		self.WalkSound:Stop()
		self.WalkSound = nil
	end
	self:Remove()
end

function ENT:OnRemove( damageinfo )
	MsgN( "OnRemove" )
end

function ENT:CollisionCheck()
	DebugInfo(7,"m_bWasNoclipping "..tostring(Entity(1).m_bWasNoclipping))

	local start = self:GetPos() + (self:GetUp() * 20)
	
	local tracedata = {}
	tracedata.start = start
	tracedata.endpos = start + (self:GetForward() * 15)
	tracedata.filter = self
	tracedata.mins = Vector(self:GetRight() * -10, 0, self:GetUp() * -2)
	tracedata.maxs = Vector(self:GetRight() * 10, 0, self:GetUp() * 2)

	debugoverlay.Line( tracedata.start, tracedata.endpos, 0.1, Color(255,0,0), true )

	debugoverlay.Sphere( tracedata.start + Vector(self:GetRight() * -10, 0, self:GetUp() * -2), 10, .05, Color(200,200,0), false )
	
	debugoverlay.Line( tracedata.start + Vector(self:GetRight() * -10, 0, self:GetUp() * -2), tracedata.start + Vector(self:GetRight() * 10, 0, self:GetUp() * -2), 0.1, Color(0,255,0), true)
	debugoverlay.Line( tracedata.start + Vector(self:GetRight() * -10, 0, self:GetUp() * 2), tracedata.start + Vector(self:GetRight() * 10, 0, self:GetUp() * 2), 0.1, Color(0,255,0), true)

	debugoverlay.Line( tracedata.endpos + Vector(self:GetRight() * -10, 0, self:GetUp() * -2), tracedata.endpos + Vector(self:GetRight() * 10, 0, self:GetUp() * -2), 0.1, Color(0,255,0), true)
	debugoverlay.Line( tracedata.endpos + Vector(self:GetRight() * -10, 0, self:GetUp() * 2), tracedata.endpos + Vector(self:GetRight() * 10, 0, self:GetUp() * 2), 0.1, Color(0,255,0), true)

	local trace = util.TraceHull( tracedata )
	if trace.Hit then
		debugoverlay.Cross(trace.HitPos, 3, 0.1, Color(0,0,255), true)
	end
end

--
-- List the NPC as spawnable
--
list.Set( "NPC", "UT2K4_SpiderMine", 	{	Name = "UT2K4 Spider Mine", 
										Class = "UT2K4_SpiderMine",
										Category = "UT2K4"	
									})
									
*/
