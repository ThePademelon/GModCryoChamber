AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	//Setup entity
	self:SetModel("models/hunter/tubes/tube2x2x2b.mdl")
	self:SetMaterial("models/gibs/metalgibs/metal_gibs")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	//Add door
	self.door = ents.Create("chamberdoor")
	self.door:Spawn()
	self.door:SetPos(self:GetPos())
	self.door:SetParent(self)
	self.door:SetAngles(Angle(0, 180, 0))
	
	//Add top and bottom
	self.roof = ents.Create("chambertopper")
	self.roof:Spawn()
	self.roof:SetPos(self:GetPos() + Vector(0,0,46))
	self.roof:SetParent(self)
	self.floor = ents.Create("chambertopper")
	self.floor:Spawn()
	self.floor:SetPos(self:GetPos() + Vector(0,0,-46))
	self.floor:SetParent(self)
	
	//Prep light status transmission
	util.AddNetworkString("LightStatus")
	
	//WAKE ME UP INSIDE
	self:GetPhysicsObject():Wake()
end

function ENT:Use(cause, caller)
	//Get the corners of the chamber
	local topCorner = self:OBBMaxs() + self:GetPos()
	local bottomCorner = self:OBBMins() + self:GetPos()

	//enumerate players
	for count,value in pairs(player.GetAll()) do
		local isInChamber = value:GetPos():WithinAABox(bottomCorner, topCorner) || value:GetPos():WithinAABox(topCorner, bottomCorner)
		if(isInChamber) then
			self:DoFreeze(value, !value:IsFrozen())
		end
	end
	
	//enumerate ents
	for count,value in pairs(ents.GetAll()) do
		local isInChamber = value:GetPos():WithinAABox(bottomCorner, topCorner) || value:GetPos():WithinAABox(topCorner, bottomCorner)
		local isExcluded = value == self.roof || value == self.floor || value == self.door || value == self
		
		if(isInChamber && !isExcluded) then
			local physObj = value:GetPhysicsObject()
			if(IsValid(physObj)) then self:DoFreeze(value, physObj:IsMoveable()) end
		end
	end
	
	//Close or open the door
	self.state = self.door:ChangeDoorState()
	
	//Send the current light status
	net.Start("LightStatus")
	net.WriteBool(self.state)
	net.Broadcast()
end

function ENT:DoFreeze(object, isFreeze)
	local physObj = object:GetPhysicsObject()

	//Logic for players
	if(object:IsPlayer()) then
		object:Freeze(isFreeze)
		object:SetMoveType(isFreeze and MOVETYPE_NONE or MOVETYPE_WALK)
	//Logic for physics objects
	elseif(IsValid(physObj)) then
		physObj:EnableMotion(!isFreeze)
		if(!isFreeze) then
			physObj:Wake()
		end
	end
	
	//Logic for NPCs
	if(object:IsNPC()) then
		if(isFreeze) then object:SentenceStop() end
		object:SetCondition(isFreeze and 67 or 68)
	end
		
	//Shared Logic
	object:SetColor(isFreeze and Color(0, 100, 120, 255) or Color(255, 255, 255, 255))
	object:SetParent(isFreeze and self or nil)
end

function ENT:OnRemove()
	//Make sure nothing is stuck frozen
	for count,value in pairs(self:GetChildren()) do
		self:DoFreeze(value, false)
	end
	
	//Make sure the rest of the object is disposed
	if(IsValid(self.door)) then self.door:Remove() end
	if(IsValid(self.roof)) then self.roof:Remove() end
	if(IsValid(self.floor)) then self.floor:Remove() end
end

function ENT:SpawnFunction(spawnPlayer, traceTable, objectClass)
	if(traceTable.Hit) then
		local ent = ents.Create(objectClass)
		ent:SetPos(traceTable.HitPos + traceTable.HitNormal * 100)
		ent:Spawn()
		ent:Activate()
		return ent
	end
end

function ENT:Think()
	if(!(IsValid(self) && IsValid(self.door) && IsValid(self.roof) && IsValid(self.floor))) then
		self:Remove()
	end
	
	//Make the frosty smoke
	if(self.state) then
		local data = EffectData()
		data:SetOrigin(self:GetPos() + Vector(0,0,42))
		util.Effect("Frost", data)
	end
end