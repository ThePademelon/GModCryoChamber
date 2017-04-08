ENT.Type = "anim"
ENT.PrintName = "Cryogenics Chamber"
ENT.Category = "Fun + Games"
ENT.Author = "Laura"
ENT.Contact = "The Pademelon on Steam"
ENT.Purpose = "To freeze"
ENT.Instructions = "Press E to freeze contents. Make sure you have a friend to unfreeze you if you freeze yourself."
ENT.Spawnable = true
ENT.AdminOnly = true

//Make this entity a WireMod entity if WireMod is installed
if(WireLib) then
	ENT.Base = "base_wire_entity"
else
	ENT.Base = "base_entity"
end

function ENT:SetupDataTables()
	self.FreezeStatusNetworkVarString = "FreezeStatus"
	self:NetworkVar("Bool", 0, self.FreezeStatusNetworkVarString)
end
