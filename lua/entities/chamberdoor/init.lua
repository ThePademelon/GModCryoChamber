AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	//Setup entity
	self:SetModel("models/chamberdoor/chamberdoor.mdl")
	self:SetRenderMode(RENDERMODE_NONE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetColor(Color(255,255,255,120))
	
	//If this was made without a chamber assigned then destroy it
	if(!IsValid(self.chamber)) then
		self:Remove()
	end
end

//Forward the call to the main code
function ENT:Use(cause, caller, mode, value)
	self.chamber:Use(cause, caller, mode, value)
end

function ENT:DoorTransition()	
	//Play the open/close sound
	sound.Play("buttons/og_switch_press_01.wav", self:GetPos(), 100, 100, 1)
	
	//TODO: Open close animation?
end

function ENT:Think()
	self:SetRenderMode(self:GetFreezeStatus() and RENDERMODE_TRANSALPHA or RENDERMODE_NONE)
	self:SetSolid(self:GetFreezeStatus() and SOLID_VPHYSICS or SOLID_NONE)
end

//Get freeze status from chamber
function ENT:GetFreezeStatus()
	return self.chamber:GetFreezeStatus()
end