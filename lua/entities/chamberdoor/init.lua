AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	//Setup entity
	self:SetModel("models/hunter/tubes/tube2x2x2d.mdl")
	self:SetMaterial("phoenix_storms/window")
	self:SetRenderMode(RENDERMODE_NONE)
	self:SetUseType(SIMPLE_USE)
	self:SetColor(Color(255,255,255,120))
end

//Forward the call to the main code
function ENT:Use(cause, caller)
	self:GetParent():Use(cause, caller, USE_ON, 0)
end

function ENT:ChangeDoorState()
	//Switch mode and apply closing/opening visuals
	local isOpen = self:GetSolid() == SOLID_NONE
	self:PhysicsInit(isOpen and SOLID_VPHYSICS or SOLID_NONE)
	self:SetRenderMode(isOpen and RENDERMODE_TRANSALPHA or RENDERMODE_NONE)
	
	//Play the open/close sound
	sound.Play("buttons/og_switch_press_01.wav", self:GetPos(), 100, 100, 1)

	return isOpen
end

function ENT:Think()
end