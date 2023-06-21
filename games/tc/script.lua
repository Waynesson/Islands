getgenv().Config = {
    SelectedEgg = "Basic | 250"
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Knit = require(ReplicatedStorage.Packages.Knit)
local Short = require(ReplicatedStorage.Shared.Short)
local OrbService = Knit.GetService("OrbService")
local TreeService = Knit.GetService("TreeService")
local EggService = Knit.GetService("EggService")

function GetEggs()
    local tbl1, tbl2 = {}, {}

    for i, v in pairs(require(game.ReplicatedStorage.Shared.List.Eggs).Eggs) do
        if i:match("Robux") then continue end
        table.insert(tbl1, {Cost = v.Cost, Name = i})
    end

    table.sort(tbl1, function(a,b)
        return a.Cost < b.Cost
    end)

    for i, v in pairs(tbl1) do
        table.insert(tbl2, v.Name .. " | " .. Short.short("", v.Cost))
    end
    return tbl2
end

function GetNearestTree()
    local Near, Dist = nil, math.huge
    local Hum = Player.Character.HumanoidRootPart

    for i, v in pairs(workspace.Scripts.Trees:GetChildren()) do
        for i2, v2 in pairs(v:GetChildren()) do
            for i3, v3 in pairs(v2.Storage:GetChildren()) do
                local Part = v3:GetPivot().p
                local Mag = (Part - Hum.Position).Magnitude

                if Mag < Dist then
                    Dist = Mag
                    Near = v3.Name
                end
            end
        end
    end
    return Near
end

function AutoChopTrees()
    while task.wait() and Config.AutoChopTrees do
        local Tree = GetNearestTree()

        if Tree then
            TreeService.Damage:Fire(Tree)
        end
    end
end

function AutoCollectOrbs()
    while task.wait() and Config.AutoCollectOrbs do
        local OrbTable = {}

        for i, v in pairs(workspace.Scripts.Orbs.Storage:GetChildren()) do
            table.insert(OrbTable, v.Name) 
        end 

        OrbService.CollectOrbs:Fire(OrbTable)
    end
end

function AutoHatchEgg()
    while task.wait() and Config.AutoHatchEgg do
        local Egg = Config.SelectedEgg:split(" |")[1]

        task.spawn(function()
            EggService:Unbox(Egg, "triple")
        end)
    end
end

local uwuware = loadstring(game:HttpGet("https://raw.githubusercontent.com/uzu01/public/main/ui/uwuware"))()
local w = uwuware:CreateWindow("Timber Champion")

local MainFolder = w:AddFolder("Main")
local PetsFolder = w:AddFolder("Pets")
local MiscFolder = w:AddFolder("Misc")

MainFolder:AddToggle({text = "Auto Chop Trees", state = Config.AutoChopTrees, callback = function(v)
    Config.AutoChopTrees = v

    task.spawn(AutoChopTrees)
end})

MainFolder:AddToggle({text = "Auto Collect Orbs", state = Config.AutoCollectOrbs, callback = function(v)
    Config.AutoCollectOrbs = v

    task.spawn(AutoCollectOrbs)
end})

MainFolder:AddButton({text = "Delete Orbs", callback = function()
    for i, v in pairs(workspace.Scripts.Orbs.Storage:GetChildren()) do
        v:Destroy()
    end
end})

PetsFolder:AddToggle({text = "Auto Hatch Egg", state = Config.AutoHatchEgg, callback = function(v)
    Config.AutoHatchEgg = v

    task.spawn(AutoHatchEgg)
end})

PetsFolder:AddList({text = "Select Egg", values = GetEggs(), callback = function(v)
    Config.SelectedEgg = v
end})

MiscFolder:AddBind({text = "Toggle GUI", key = "LeftControl", callback = function() 
    uwuware:Close()
end})

uwuware:Init()
