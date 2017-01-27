AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	//Setup entity
	self:SetModel("models/hunter/tubes/circle2x2.mdl")
	self:SetMaterial("models/gibs/metalgibs/metal_gibs")
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end

//Forward the call to the main code
function ENT:Use(cause, caller)
	self:GetParent():Use(cause, caller, USE_ON, 0)
end

function ENT:Think()
end