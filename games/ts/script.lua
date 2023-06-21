getgenv().Config = {
    SelectedEgg = "Forest Egg |",
    TotalPet = 5
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Modules = ReplicatedStorage.Modules
local Eggs = require(Modules.Information.Eggs).Eggs
local Zones = require(Modules.Information.Zones)
local Network = require(Modules.Utils.Network)
local Abbreviation = require(Modules.Utils.Abbreviation)

if game.PlaceVersion < 62 then Player:Kick("/n create a private server the script doesnt support place version: " .. game.PlaceVersion) end

function Teleport(Part)
    Player.Character.HumanoidRootPart.CFrame = Part
end

function GetEggs()
    local tbl1, tbl2 = {}, {}

    for i, v in pairs(Eggs) do
        if i:match("Robux") then continue end
        table.insert(tbl1, {Name = i, Price = v.Price})
    end

    table.sort(tbl1, function(a,b)
        return a.Price < b.Price
    end)

    for i, v in pairs(tbl1) do
        table.insert(tbl2, v.Name .. " | " .. Abbreviation:Abbreviate(v.Price))
    end
    return tbl2
end

function GetZones()
    local tbl1, tbl2 = {}, {}

    for i, v in pairs(Zones.GeneralInfo) do
        if i:match("Main") then continue end
        table.insert(tbl1, {Order = v.Order, Name = i})
    end

    table.sort(tbl1, function(a,b)
        return a.Order < b.Order
    end)
    
    for i, v in pairs(tbl1) do
        table.insert(tbl2, v.Name)
    end 
    return tbl2
end

function GetMaxRebirth()
    local ScreenGui = Player.PlayerGui.ScreenGui
    local RebirthCost = ScreenGui.Menus.Rebirths.Menu.Holder[1].Cost.Text:split(" Taps")[1]
    local MyClicks = ScreenGui.Currencies.Currency1.Amount.Text
    
    return Abbreviation:UnAbbreviate(MyClicks) / Abbreviation:UnAbbreviate(RebirthCost)
end

function GetPets()
    local PlayerController = require(Player.PlayerScripts.Client.ClientManager.PlayerController)
    local tbl = {}

    for i, v in pairs(PlayerController.Object.Data.PetsInfo.PetStorage) do
        if not tbl[v.Tier] then
            tbl[v.Tier] = {}
        end
    
        if not tbl[v.Tier][v.Name] then
            tbl[v.Tier][v.Name] = {}
        end
        table.insert(tbl[v.Tier][v.Name], v.UUID)
    end 
    return tbl
end

function UpgradePet(Type, RemoteName)
    local Pets = GetPets()

    for i, v in pairs(Pets) do
        if i == Type then
            for i2, v2 in pairs(v) do
                if #v2 >= Config.TotalPet then
                    local str, tbl1, tbl2 = "", {}, {}

                    for i3, v3 in pairs(v2) do
                        if #tbl1 < Config.TotalPet then
                            table.insert(tbl1, v3)
                            str = v3
                        end
                    end
                    
                    for i3, v3 in pairs(tbl1) do
                        tbl2[v3] = true
                    end

                    Network:FireServer(RemoteName, str, tbl2)
                end
            end     
        end
    end
end

function AutoClick()
    task.spawn(function()
        while task.wait() do
            if not Config.AutoClick then return end
            Network:FireServer("ClickDetect")
        end
    end)
end

function AutoHatch()
    task.spawn(function()
        while task.wait() do
            if not Config.AutoHatch then return end
            local Egg = Config.SelectedEgg:split(" |")[1]

            Network:FireServer("OpenCapsules", Egg, 3)
        end
    end)
end

function AutoRebirth()
    task.spawn(function()
        while task.wait(.3) do
            if not Config.AutoRebirth then return end
            local Num = GetMaxRebirth()

            Network:FireServer("Rebirth", Num)
        end
    end)
end

function AutoShiny()
    task.spawn(function()
        while task.wait(.3) do
            if not Config.AutoShiny then return end
            UpgradePet(1, "ShinyCrafting")
        end
    end)
end

function AutoRainbow()
    task.spawn(function()
        while task.wait(.3) do
            if not Config.AutoRainbow then return end
            UpgradePet(2, "RainbowCrafting")
        end
    end)
end

local uwuware = loadstring(game:HttpGet("https://raw.githubusercontent.com/uzu01/public/main/ui/uwuware"))()
local w = uwuware:CreateWindow("Tapper Simulator")

local MainFolder = w:AddFolder("Main")
local PetsFolder = w:AddFolder("Pets")
local TeleFolder = w:AddFolder("Teleports")
local MiscFolder = w:AddFolder("Misc")

MainFolder:AddToggle({text = "Auto Click", state = Config.AutoClick, callback = function(v)
    Config.AutoClick = v

    AutoClick()
end})

MainFolder:AddToggle({text = "Auto Rebirth", state = Config.AutoRebirth, callback = function(v)
    Config.AutoRebirth = v

    AutoRebirth()
end})

PetsFolder:AddToggle({text = "Auto Hatch", state = Config.AutoHatch, callback = function(v)
    Config.AutoHatch = v

    AutoHatch()
end})

PetsFolder:AddList({text = "Select Egg", values = GetEggs(), callback = function(v)
    Config.SelectedEgg = v
end})

PetsFolder:AddBox({text = "Total Pet To Use", value = Config.TotalPet, function(v)
    Config.TotalPet = tonumber(v)
end})

PetsFolder:AddToggle({text = "Auto Shiny", state = Config.AutoShiny, callback = function(v)
    Config.AutoShiny = v

    AutoShiny()
end})

PetsFolder:AddToggle({text = "Auto Rainbow", state = Config.AutoRainbow, callback = function(v)
    Config.AutoRainbow = v

    AutoRainbow()
end})

TeleFolder:AddList({text = "Select Island", values = GetZones(), callback = function(v)
    --Network:FireServer("LocationChanged", v)
    Teleport(workspace.GameAssets.Portals.Spawns[v].CFrame)
end})

MiscFolder:AddBind({text = "Toggle GUI", key = "LeftControl", callback = function() 
    uwuware:Close()
end})

uwuware:Init()
