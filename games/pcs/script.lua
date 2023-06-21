-- Var
getgenv().Config = {}

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Pets

-- Func
function Teleport(Part)
    return Player.Character and Player.Character:PivotTo(Part)
end

function GetPets()
    local tbl, pets = {}, {}

    for i, v in pairs(workspace.PlayerPets:GetChildren()) do
        table.insert(pets, v.Name)
    end
    
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Inventory") and type(v.Inventory) == "table" and rawget(v.Inventory, "Pets") then
            for i2, v2 in pairs(v.Inventory.Pets) do
                if table.find(pets, i2) then
                    table.insert(tbl, i2)
                end
            end
        end
    end
    return tbl
end

function GetBulb(Number)
	for i, v in pairs(workspace:GetChildren()) do
	    if v.Name == "Bulb" and v:GetAttribute("BulbType") == "Hard" and v:GetAttribute("BulbNum") == Number then
	    	return v
	    end
    end
    return nil
end

function GetNearestCoin()
    local Near, Dist = nil, math.huge

    for i, v in pairs(workspace.Cases:GetChildren()) do
        local Mag = Player.Character and Player:DistanceFromCharacter(v:GetPivot().p)

		-- Prioritize Chest
		-- if v:FindFirstChild("Top") then
		-- 	return v
		-- end
		
        if Mag and Mag < Dist and not v:FindFirstChild("Shield") then
            Dist = Mag
            Near = v
        end
    end
    return Near
end

function Attack(Pet, Coin, Number)
    ReplicatedStorage.RemoteEvent:FireServer("Cases Selected", {
        [Pet] = {
            ["CaseHash"] = Coin,
            ["Order"] = 1
        }
    })

    ReplicatedStorage.RemoteEvent:FireServer("Damage Cases", {
        [Coin] = {
            [Pet] = {
                ["Current"] = "69F"
            }
        }
    })
end

function GetEasyChest()
    for i, v in pairs(workspace.Cases:GetChildren()) do
        if v:FindFirstChild("Shield") and v.Shield.Shield.Frame.Desc.Text == "Turn on all 9 Lightbulbs to break the Shield!" then
            return v
        end
    end
    return nil
end

function AutoFarmCoins()
    while task.wait() and Config.AutoFarmCoins do
    	local Coin = GetNearestCoin()
    	
        if Coin and not Coin:FindFirstChild("Top") and Config.Method == "Multi" then
            local CoinTable = {} 
            
            -- Prioritize Gems
            -- for i, v in pairs(workspace.Cases:GetChildren()) do
            --     if #CoinTable < #Pets and v:FindFirstChild("Meshes/Gem1") then
            --         table.insert(CoinTable, v.Name) 
            --     end
            -- end

            for i, v in pairs(workspace.Cases:GetChildren()) do
                if #CoinTable < #Pets and Player.Character and Player:DistanceFromCharacter(v:GetPivot().p) < 300 then
                    table.insert(CoinTable, v.Name) 
                end
            end
        
        	if #CoinTable >= #Pets then
	            for i2, v2 in pairs(CoinTable) do
	                Attack(Pets[i2], v2, 1)
	            end
            end
            task.wait(.7)
        else
            if Coin then
                for i, v in pairs(Pets) do
                    Attack(v, Coin.Name, i)
                end
                task.wait(.7)
            end
        end
    end
end

function AutoGrabCoins()
    while task.wait() and Config.AutoGrabCoins do
        for i, v in pairs(workspace.ItemGrabs:GetChildren()) do
            if Player.Character then
                v:PivotTo(Player.Character:GetPivot())
            end
        end
    end
end

function AutoSolveEasyPuzzle()
	while task.wait() and Config.AutoSolveEasyPuzzle do
        local Coin = GetEasyChest()
        
        if Coin and Coin:FindFirstChild("Shield") then
            for i = 1, 99 do
                local tbl = {}
                for v in tostring(i):gmatch("%S") do
                    tbl[v] = true
                end
                ReplicatedStorage.RemoteEvent:FireServer("Solve Bulb Puzzle", "Easy", Coin.Name, tbl)
            end
            task.wait(1)
        end
	end	
end

function AutoSolveHardPuzzle()
    while task.wait() and Config.AutoSolveHardPuzzle do
        for i = 1, 25 do
            local Bulb = GetBulb(i)
            if Bulb and Bulb:FindFirstChild("LightPart") and Bulb.LightPart.Color ~= Color3.fromRGB(253, 234, 141) and i + 6 <= 25 then
                fireclickdetector(GetBulb(i + 6).Bulb.ClickDetector)
                break
            end
        end
    end
end

-- Lib
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/uzu01/public/main/ui/uwuware"))()
local w = library:CreateWindow("Pet Capsules | Uzu")

local MainFolder = w:AddFolder("Main")
local MiscFolder = w:AddFolder("Misc")

MainFolder:AddToggle({text = "Auto Farm Coins", callback = function(v)
    Config.AutoFarmCoins = v

    Pets = GetPets()
    AutoFarmCoins()
end})

MainFolder:AddToggle({text = "Auto Grab Coins", callback = function(v)
    Config.AutoGrabCoins = v
    
    AutoGrabCoins()
end})

MainFolder:AddList({text = "Select Method", values = {"Nearest", "Multi"}, callback = function(v)
    Config.Method = v
end})

MainFolder:AddToggle({text = "Auto Solve Easy Puzzle", callback = function(v)
    Config.AutoSolveEasyPuzzle = v
    
    AutoSolveEasyPuzzle()
end})

MainFolder:AddToggle({text = "Auto Solve Hard Puzzle", callback = function(v)
    Config.AutoSolveHardPuzzle = v
    
    AutoSolveHardPuzzle()
end})

MiscFolder:AddBind({text = "Toggle GUI", key = "LeftControl", callback = function() 
    library:Close()
end})

library:Init()
