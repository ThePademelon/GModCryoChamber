include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	//Setup light
	self.freezelight = DynamicLight(LocalPlayer():EntIndex())
	self.freezelight.pos = self:GetPos()
	self.freezelight.r = 0
	self.freezelight.g = 100
	self.freezelight.b = 255
	self.freezelight.brightness = -10
	self.freezelight.Decay = 1
	self.freezelight.Size = 750
end

function ENT:Think()
	//Keep light up-to-date
	self.freezelight.brightness = self:GetFreezeStatus() and 2 or -10
	self.freezelight.pos = self:GetPos()
	self.freezelight.DieTime = CurTime() + 1
end