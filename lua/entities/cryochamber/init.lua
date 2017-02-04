AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

//CONSOLE REGISTRATION

concommand.Add("cryochamber", function(thePlayer, theCommand, args, argString)
	if(argString == "" || args[1] == "help") then
		//Nothing inputted, return help screen
		print("+-----------------------------------------------------------------------------------+")
		print("|                                 CryoChamber Help                                  |")
		print("+--------------------+--------------------------------------------------------------+")
		print("|      COMMAND       |                            EFFECT                            |")
		print("+--------------------+--------------------------------------------------------------+")
		print("| freezeall          | Sets all chambers to freeze mode                             |")
		print("| unfreezeall        | Sets all chambers to unfreeze mode                           |")
		print("| help               | Shows this help text, yes the one you are reading right now  |")
		print("| whatsfrozen        | Lists all entities that are currently frozen by a chamber    |")
		print("+--------------------+--------------------------------------------------------------+")
	elseif(args[1] == "freezeall" || args[1] == "unfreezeall") then
		//This command is admin only
		if(thePlayer:IsSuperAdmin() || thePlayer:IsAdmin()) then
			//Freeze all command, find all chambers and set the freeze status
			for count, ent in pairs(ents.GetAll()) do
				if(ent:GetClass() == "cryochamber") then
					ent:SetFreezeStatus(args[1] == "freezeall")
				end
			end
			print("Successfully updated all chambers")
		else
			print("You do not have access to this command")
		end
	elseif(args[1] == "whatsfrozen") then
		for count, ent in pairs(ents.GetAll()) do
			if(ent:GetClass() == "cryochamber") then
				PrintTable(ent.frozenItems)
			end
		end
	else
		//Something not expected
		print("Unrecognised command, type 'cryochamber help' for available commands")
	end
end)

//COLOR CONSTANTS

freezeColor = Color(0, 100, 120, 255)
defaultColor = Color(255, 255, 255, 255)

//HOOKS

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
	self.door:SetAngles(Angle(0, 180, 0))
	constraint.Weld(self, self.door, 0, 0, 0, true, false)
	self.door:SetParent(self)
	
	//Add top and bottom
	self.roof = ents.Create("chambertopper")
	self.roof:Spawn()
	self.roof:SetPos(self:GetPos() + Vector(0,0,46))
	constraint.Weld(self, self.roof, 0, 0, 0, true, false)
	self.roof:SetParent(self)
	self.floor = ents.Create("chambertopper")
	self.floor:Spawn()
	self.floor:SetPos(self:GetPos() + Vector(0,0,-46))
	constraint.Weld(self, self.floor, 0, 0, 0, true, false)
	self.floor:SetParent(self)
		
	//Stuff for ensuring safe disposal
	self.disposed = false
	self.frozenItems = {}
	
	//WAKE ME UP INSIDE
	self:GetPhysicsObject():Wake()
end

function ENT:Use(cause, caller)
	//Close or open the door
	self.door:ChangeDoorState()
end

function ENT:OnRemove()
	//Make sure nothing is stuck frozen
	self:SetFreezeStatus(false)
	self.disposed = true
	
	//Clean table for entitys that no longer exist
	for count, value in pairs(self.frozenItems) do
		if(!IsValid(value)) then
			self.frozenItems[count] = nil
		end
	end
	
	self:Think()
	
	//Make sure the rest of the object is disposed
	if(IsValid(self.door)) then self.door:Remove() end
	if(IsValid(self.roof)) then self.roof:Remove() end
	if(IsValid(self.floor)) then self.floor:Remove() end
end

//Overrides the default spawning behaviour
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
	//If something is missing from the chamber, it should delete itself
	if(!(IsValid(self) && IsValid(self.door) && IsValid(self.roof) && IsValid(self.floor))) then
		self:Remove()
	end
	
	//enumerate ents
	local freezeStatus = self:GetFreezeStatus()
	local theTable = {}
	for count,value in pairs(self.disposed and self.frozenItems or ents.GetAll()) do
		local isExcluded = value == self.roof || value == self.floor || value == self.door || value == self
		if(self:IsInChamber(value) && !isExcluded || self.disposed) then
			//Freeze items depending on their type
			if(value:IsRagdoll()) then
				self:DoFreezeRagdoll(value, freezeStatus)
			elseif(value:IsPlayer()) then
				self:DoFreezePlayer(value, freezeStatus)
			elseif(value:IsNPC()) then
				self:DoFreezeNPC(value, freezeStatus)
			elseif(value.Base == "base_nextbot") then
				self:DoFreezeNextBot(value, freezeStatus)
			else
				self:DoFreezeEnt(value, freezeStatus)
			end
			
			//Keep track of what's frozen
			table.insert(theTable, value)
		end
	end
	
	//Apply frozenItems table updates
	for count, value in pairs(theTable) do
		local hasValue = table.HasValue(self.frozenItems, value)
		if(freezeStatus) then
			if(!hasValue) then
				table.insert(self.frozenItems, value)
			end
		else
			if(hasValue) then
				table.RemoveByValue(self.frozenItems, value)
			end
		end
	end
	
	//Make the frosty smoke
	if(freezeStatus) then
		local data = EffectData()
		data:SetOrigin(self:GetPos() + Vector(0,0,42))
		util.Effect("Frost", data)
	end
end

//METHODS

function ENT:DoFreezePlayer(thePlayer, isFreeze)
		thePlayer:Freeze(isFreeze)
		thePlayer:SetMoveType(isFreeze and MOVETYPE_NONE or MOVETYPE_WALK)
		thePlayer:SetColor(isFreeze and freezeColor or defaultColor)
		self:AttachMoveChild(thePlayer, isFreeze)
end

function ENT:DoFreezeRagdoll(ragdoll, isFreeze)
		if(isFreeze) then
			local bonesCount = ragdoll:GetPhysicsObjectCount()
			for bone = 1, bonesCount - 1 do
				//Weld limb to chamber
				constraint.Weld(self, ragdoll, 0, bone, 0)
			
				//Weld to self
				constraint.Weld(ragdoll, ragdoll, 0, bone, 0)
			end
		else
			//Unweld the ragdoll
			constraint.RemoveAll(ragdoll)
		end
		
		ragdoll:SetColor(isFreeze and freezeColor or defaultColor)
end

function ENT:DoFreezeNPC(npc, isFreeze)
	//Shut the npc up, popsicles don't talk.
	if(isFreeze) then npc:SentenceStop() end
	
	//Tell the npc to idle or just act normal
	npc:SetCondition(isFreeze and 67 or 68)
	
	npc:SetColor(isFreeze and freezeColor or defaultColor)
	self:AttachMoveChild(npc, isFreeze)
end

function ENT:DoFreezeNextBot(nextbot, isFreeze)
	//Freeze the nextbot with flags since Lock and Freeze don't work on NextBots
	if(!nextbot:IsFlagSet(FL_FROZEN) && isFreeze) then
		nextbot:AddFlags(FL_FROZEN)
	elseif(nextbot:IsFlagSet(FL_FROZEN) && !isFreeze) then
		nextbot:RemoveFlags(FL_FROZEN)
	end
	
	//The PUSH movetype causes issues with parenting so remove it first before parenting
	nextbot:SetMoveType(isFreeze and MOVETYPE_NONE or MOVETYPE_PUSH)
	self:AttachMoveChild(nextbot, isFreeze)
	
	//Set the color to that frosty blue
	nextbot:SetColor(isFreeze and freezeColor or defaultColor)
end

function ENT:DoFreezeEnt(entity, isFreeze)
		//Disable or enable movement
		local physObj = entity:GetPhysicsObject()
		if(IsValid(physObj)) then
			physObj:EnableMotion(!isFreeze)
			if(!isFreeze) then
				physObj:Wake()
			end
		end
		
		//Don't unparent or parent an item that already has a parent unless it's the chamber
		local parent = entity:GetParent()
		local hasParent = IsValid(parent)
		if(!hasParent || hasParent && parent == self) then self:AttachMoveChild(entity, isFreeze) end
		
		entity:SetColor(isFreeze and freezeColor or defaultColor)
end

function ENT:AttachMoveChild(entity, isAttach)
	local parent = isAttach and self or nil
	if(IsValid(entity:GetParent()) == !isAttach) then
		entity:SetParent(parent)
	end
end

function ENT:IsInChamber(entity)
	//Get the corners of the chamber
	local topCorner = self:OBBMaxs() + self:GetPos()
	local bottomCorner = self:OBBMins() + self:GetPos()

	//Check to see if the entity is within the box, I think this method only works with the corners in the right order so check both ways
	return entity:GetPos():WithinAABox(bottomCorner, topCorner) || entity:GetPos():WithinAABox(topCorner, bottomCorner)
end