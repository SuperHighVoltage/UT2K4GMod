    function EFFECT:Init(data)
    
        local vOrig = data:GetOrigin()
    
        self.Emitter = ParticleEmitter(vOrig)
    
        for i=1,8 do
        
            local flash = self.Emitter:Add("effects/blueflare1", vOrig)
            
            if flash then    
                flash:SetColor(150, 100, 255)
                flash:SetVelocity(VectorRand():GetNormal()*math.random(0, 20))
                flash:SetRoll(math.Rand(0, 360))
                flash:SetDieTime(0.5)
                flash:SetStartSize(30)
                flash:SetStartAlpha(255)
                flash:SetEndSize(0)
                flash:SetEndAlpha(0)
            end
        
        end
        
        self.Emitter:Finish()
        
    end
    
    function EFFECT:Think()
        return false
    end
    
    function EFFECT:Render()
    end