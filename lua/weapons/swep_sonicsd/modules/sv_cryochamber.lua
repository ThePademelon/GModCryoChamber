//When the screwdriver hits the chamber (or it's door) it opens with primary and closes with secondary click actions
function OnScrewed(driver, data)
	//Find the chamber there is one
	local chamber
	if(data.class == "cryochamber") then
		chamber = data.ent
	elseif(data.class == "chamberdoor") then
		chamber = data.ent.chamber
	end

	//If a chamber was found, trigger the freeze if it isn't already
	if(IsValid(chamber) && data.ent:GetFreezeStatus() != data.keydown2) then
		chamber:SetFreezeStatus(data.keydown2)
	end
end

//Hook into the screwdriver
SWEP:AddFunction(OnScrewed)