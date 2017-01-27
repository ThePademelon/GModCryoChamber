function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	local emitter = ParticleEmitter(Pos)
	local particle
	if particle == nil then particle = emitter:Add( "particles/smokey", Pos + Vector(   math.random(0,0),math.random(0,0),math.random(0,0) ) ) end
	
	if (particle) then
		particle:SetVelocity(Vector(math.random(0,0),math.random(0,0),math.random(0,0)))
		particle:SetLifeTime(0) 
		particle:SetDieTime(6) 
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0) 
		particle:SetEndSize(50)
		particle:SetAngles( Angle(0,0,0) )
		particle:SetAngleVelocity( Angle(0,0,0) ) 
		particle:SetRoll(math.Rand( 0, 360 ))
		particle:SetColor(100,220,255,144)
		particle:SetGravity( Vector(0,0,-4) ) 
		particle:SetAirResistance(0)  
		particle:SetCollide(true)
		particle:SetBounce(0)
	end

	emitter:Finish()	
end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end