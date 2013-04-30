AddCSLuaFile("UT2k4_Projectiles.lua")

UT = {}
UT.Gravity = 800
UT.ActiveProjectiles = {}
UT.LastSim = 0

UT_PROJECTILE_FLECHETTE = 0

function DPrint(s)
	local a = "SERVER: "
	if(CLIENT) then a = "CLIENT: " end
--	Msg(a .. s .. "\n")
end

function VStr(v)
	return v.x .. ", " .. v.y .. ", " .. v.z
end

function Trajectory()
	return {base=Vector(),delta=Vector(),time=CurTime(),Evaluate=UT.EvaluateTrajectory,gravity=true}
end

function UT.SimulateProjectiles() --This is where the magic happens
	--DPrint("SIM")
	if(SERVER) then UT.SyncProjectiles() end --Send any new projectiles or any that have changed
	
	local time = CurTime()
	for k,p in pairs(UT.ActiveProjectiles) do --So I was thinkin:
		local pos = p.tr:Evaluate(time) --Where am I?
		
		pos = UT.ResolveCollision(p,pos) --If I collide what's my new position?
		
		if(CLIENT and not p.remove) then UT.RenderProjectile(p,pos,time) end --What do I look like?

		p.last.x = pos.x --Never forget where I've been.
		p.last.y = pos.y
		p.last.z = pos.z

		if(time - p.start > p.lifetime) then p.remove = true end --Will I dream?
	end
	
	UT.LastSim = time
	
	local n = #UT.ActiveProjectiles
	for i=1, n do 
		local p = UT.ActiveProjectiles[i]
		if(p and p.remove) then table.remove(UT.ActiveProjectiles,i) end --Guess not. :(
	end
end

function UT.SpawnProjectile(type,pos,vel,owner)
	local p = {}
	p.start = CurTime()
	p.type = type
	p.tr = Trajectory()
	p.tr.time = p.start
	p.tr.base = pos
	p.tr.delta = vel
	p.lifetime = 1
	p.relevant = true
	p.last = Vector(p.tr.base.x,p.tr.base.y,p.tr.base.z)
	p.owner = owner
	p.filter = true
	table.insert(UT.ActiveProjectiles, p)
	DPrint("Created Projectile At: " .. VStr(pos))
	return p
end

if(SERVER) then
	
	local function CC_TestProjectile(p,c,a)
		local pos = p:GetShootPos()
		local ang = p:GetAimVector()
		
		for i=1,7 do
			pos = pos + Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)) * 5
			UT.SpawnProjectile(UT_PROJECTILE_FLECHETTE,pos,ang*1000,p)
		end
	end
	concommand.Add("UTProjectileTest",CC_TestProjectile)
	hook.Add("Think", "UT2K4_Projectiles", UT.SimulateProjectiles)
	
	function UT.ApplyDamage(p,trace)
		local dmginfo = DamageInfo()
		dmginfo:SetDamage( 4 )		-------------------------------------------------------------changed from 10
		dmginfo:SetDamageType( DMG_BUCKSHOT )
		dmginfo:SetAttacker(p.owner)
		dmginfo:SetInflictor(p.owner)

		if(trace.Entity) then
			local pos = p.tr.base
			trace.Entity:DispatchTraceAttack(dmginfo,pos,pos)
		end
	end
	
	function UT.SendProjectile(key,p)
		umsg.Short( key )
		umsg.Vector( p.tr.base )
		umsg.Vector( p.tr.delta )
		umsg.Float( p.tr.time )
		umsg.Char( p.type )
	end
	
	function UT.SyncProjectiles()
		--DPrint("SYNC")
		local count = 0
 		for k,p in pairs(UT.ActiveProjectiles) do
			if(p.relevant) then 
				count = count + 1
			end
		end

		--Maximum 7 projectiles to update at one time to stay within the 255 byte limit
		--Don't worry, if it doesn't get sent this time, it'll get sent in the next frame
		
		if(count > 7) then count = 7 end 
		if(count > 0) then
			umsg.Start( "ProjectileStatus" )
			umsg.Short( count )
			
			DPrint("SEND " .. count .. " projectiles.")
			
			for k,p in pairs(UT.ActiveProjectiles) do
				if(p.relevant and count > 0) then 
					UT.SendProjectile(k,p)
					count = count - 1
					p.relevant = false
				end
			end
			
			umsg.End()
		end
	end
	
else

	local laserMat = Material( "trails/laser" )
	local material = Material( "sprites/light_glow02_add" )
	local orange = Color(255,200,0,255)
	local delta = Vector()
	
	function UT.RenderProjectile(p,pos,time)
		local prev = p.tr:Evaluate(time-.1)
		render.SetMaterial( material )
		render.DrawSprite( pos, 16, 16, orange)
		
		render.SetMaterial( laserMat )
		render.DrawBeam( prev, pos, 15, 0, 1, orange )
	end

	hook.Add("PostDrawOpaqueRenderables", "UT2K4_Projectiles", UT.SimulateProjectiles)
	
	function ReadProjectile(data)
		local key = data:ReadShort()
		local base = data:ReadVector()
		local delta = data:ReadVector()
		local time = data:ReadFloat()
		local type = data:ReadChar()
		local p = UT.ActiveProjectiles[key] or UT.SpawnProjectile(type,base,delta)
		p.tr.base = base
		p.tr.delta = delta
		p.tr.time = time
		p.type = type
	end
	
	local function ProjectileStatus(data)
		local count = data:ReadShort()
		for i=1, count do
			ReadProjectile(data)
		end
	end
	usermessage.Hook( "ProjectileStatus", ProjectileStatus )
	
	function UT.ApplyDamage(p,trace) end
end

function UT.OnHit(p,trace)
	if(p.type == UT_PROJECTILE_FLECHETTE) then
		if(trace.HitNonWorld) then
			UT.ApplyDamage(p,trace)
			UT.RemoveProjectile(p)
		else
			p.tr.delta = UT.ReflectVector(p.tr.delta,trace.HitNormal)
		end
	else
		UT.ApplyDamage(p,trace)
		UT.RemoveProjectile(p)
	end
end

function UT.RemoveProjectile(p)
	p.remove = true
	p.relevant = false
	p.tr.delta.x = 0
	p.tr.delta.y = 0
	p.tr.delta.z = 0
end

function UT.ResolveCollision(p,pos)
	local trace = {}
	trace.start = p.last
	trace.endpos = pos
	
	trace = util.TraceLine(trace)
	if trace.Hit then
		if(CLIENT and trace.Entity == LocalPlayer() and p.filter) then return pos end
		if(SERVER and trace.Entity == p.owner and p.filter) then return pos end
		p.filter = false
		p.tr.base = trace.HitPos
		p.tr.time = CurTime()
		p.relevant = true
		
		UT.OnHit(p,trace)
		
		return p.tr.base
	else
		return pos
	end
end

function UT.ReflectVector(v,normal)
	local len = v:Length()
	v.x = v.x / len
	v.y = v.y / len
	v.z = v.z / len
	
	local dot = v:DotProduct( normal );
	local ref = Vector()
	
	--Creating objects is expensive and makes the simulation choppy, so we do the math straight out.
	ref.x = (v.x + normal.x * -2*dot) * len * .9
	ref.y = (v.y + normal.y * -2*dot) * len * .9
	ref.z = (v.z + normal.z * -2*dot) * len * .9
	
	DPrint("N: " .. VStr(ref))
	
	return ref
end

function UT.EvaluateTrajectory(tr,time)
	local dt = (time - tr.time)
	local v = Vector()
	v.x = tr.base.x + tr.delta.x * dt
	v.y = tr.base.y + tr.delta.y * dt
	v.z = tr.base.z + tr.delta.z * dt
	if(tr.gravity) then v.z = v.z - 0.5 * UT.Gravity * dt * dt end
	return v
end