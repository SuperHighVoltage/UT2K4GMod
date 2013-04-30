    function EFFECT:Init(data)
    
        self.Weapon = data:GetEntity()
        self.Owner = self.Weapon.Owner
        
        if !IsValid(self.Owner) || (self.Owner && !self.Owner:GetActiveWeapon()) then
            return false
        end
        
        local vm = self.Owner:GetViewModel()
        
        //Thanks Ghor
        if (self.Owner == GetViewEntity()) && IsValid(vm) then
            self.Pos = vm:GetAttachment(vm:LookupAttachment("muzzle")).Pos
        elseif self.Owner != GetViewEntity() && IsValid(self.Weapon) then
            self.Pos = self.Weapon:GetAttachment(self.Weapon:LookupAttachment("muzzle")).Pos
        elseif IsValid(vm) then
            self.Pos = vm:GetAttachment(vm:LookupAttachment("muzzle")).Pos+self.Owner:GetAimVector():Angle():Right()*36-self.Owner:GetAimVector():Angle():Up()*36
        end
        
        self.Emitter = ParticleEmitter(self.Pos)
        
        for i=1,8 do
        
            local muzz = self.Emitter:Add("effects/combinemuzzle2_dark", self.Pos)
            
            if muzz then
                muzz:SetColor(150, 100, 255)
                muzz:SetRoll(math.Rand(0, 360))
                muzz:SetDieTime(0.5)
                muzz:SetStartSize(25)
                muzz:SetStartAlpha(255)
                muzz:SetEndSize(0)
                muzz:SetEndAlpha(100)
            end
        
        end
        
        self.Emitter:Finish()

    end
    
    function EFFECT:Think()
        return false
    end
    
    function EFFECT:Render()    
    end