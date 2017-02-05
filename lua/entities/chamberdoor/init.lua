AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	//Setup entity
	self:SetModel("models/hunter/tubes/tube2x2x2d.mdl")
	self:SetMaterial("phoenix_storms/window")
	self:SetRenderMode(RENDERMODE_NONE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetColor(Color(255,255,255,120))
end

//Forward the call to the main code
function ENT:Use(cause, caller)
	self:GetParent():Use(cause, caller, USE_ON, 0)
end

function ENT:ChangeDoorState()	
	//Play the open/close sound
	sound.Play("buttons/og_switch_press_01.wav", self:GetPos(), 100, 100, 1)
	
	self:SetFreezeStatus(!self:GetFreezeStatus())
end

function ENT:Think()
	self:SetRenderMode(self:GetFreezeStatus() and RENDERMODE_TRANSALPHA or RENDERMODE_NONE)
	self:SetSolid(self:GetFreezeStatus() and SOLID_VPHYSICS or SOLID_NONE)
end

//Get freeze status from chamber
function ENT:GetFreezeStatus()
	return self:GetParent():GetFreezeStatus()
end

//Forward freeze status
function ENT:SetFreezeStatus(value)
	self:GetParent():SetFreezeStatus(value)
end