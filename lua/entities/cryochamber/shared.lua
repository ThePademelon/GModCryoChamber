ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Cryogenics Chamber"
ENT.Category = "Fun + Games"
ENT.Author = "Laura"
ENT.Contact = "The Pademelon on Steam"
ENT.Purpose = "To freeze"
ENT.Instructions = "Press E to freeze contents. Make sure you have a friend to unfreeze you if you freeze yourself."
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "FreezeStatus")
end
