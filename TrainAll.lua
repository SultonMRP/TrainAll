--[[	TrainAll
	by SDPhantom
	3.3.5a port (Vanilla / TBC / WotLK trainer UI)	]]
--------------------------------------------------------------------------

local function MoneyString(copper)
	copper = tonumber(copper) or 0;
	local gold = math.floor(copper / 10000);
	local silver = math.floor((copper % 10000) / 100);
	local cop = copper % 100;
	if gold > 0 then
		return ("%d|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t %d|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t %d|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"):format(gold, silver, cop);
	elseif silver > 0 then
		return ("%d|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t %d|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"):format(silver, cop);
	end
	return ("%d|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"):format(cop);
end

local function GetServiceType(index)
	local _, _, serviceType = GetTrainerServiceInfo(index);
	return serviceType;
end

local function CountAvailable()
	local sum, total = 0, 0;
	for i = 1, GetNumTrainerServices() or 0 do
		if GetServiceType(i) == "available" then
			sum = sum + 1;
			total = total + (GetTrainerServiceCost(i) or 0);
		end
	end
	return sum, total;
end

local function TrainAll()
	for i = GetNumTrainerServices() or 0, 1, -1 do
		if GetServiceType(i) == "available" then
			BuyTrainerService(i);
		end
	end
end

local initialized;

local function OnLoad()
	local btn = ClassTrainerTrainButton;
	if initialized or not btn then
		return;
	end
	initialized = true;

	btn:SetText("Train/all");

	local originalClick = btn:GetScript("OnClick");
	btn:SetScript("OnClick", function(self, ...)
		if IsShiftKeyDown() then
			TrainAll();
			return;
		end
		if originalClick then
			this = self;
			originalClick(self, ...);
		end
	end);

	local originalEnter = btn:GetScript("OnEnter");
	btn:SetScript("OnEnter", function(self, ...)
		if originalEnter then
			this = self;
			originalEnter(self, ...);
		end
		local sum, total = CountAvailable();
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
		GameTooltip:ClearLines();
		GameTooltip:AddLine("Train/all");
		GameTooltip:AddLine("Click to train the selected skill.", 1, 1, 1);
		if sum > 0 then
			GameTooltip:AddLine(("Shift-click to train all %d available for %s"):format(sum, MoneyString(total)), 1, 1, 1);
		else
			GameTooltip:AddLine("No skills available to train.", 1, 1, 1);
		end
		GameTooltip:Show();
	end);

	local originalLeave = btn:GetScript("OnLeave");
	btn:SetScript("OnLeave", function(self, ...)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide();
		end
		if originalLeave then
			this = self;
			originalLeave(self, ...);
		end
	end);
end

if IsAddOnLoaded("Blizzard_TrainerUI") then
	OnLoad();
else
	local loader = CreateFrame("Frame");
	loader:RegisterEvent("ADDON_LOADED");
	loader:SetScript("OnEvent", function(self, _, name)
		if name == "Blizzard_TrainerUI" then
			OnLoad();
			self:UnregisterEvent("ADDON_LOADED");
		end
	end);
end
