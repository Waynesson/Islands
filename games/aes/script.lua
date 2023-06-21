-- Var
getgenv().Config = {}

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

-- Func
function CallClient(arg)
    task.spawn(function()
        ReplicatedStorage.Remotes.Client:FireServer(arg)
    end)    
end

function Teleport(Part)
    local Char = Player.Character
    local Hum = Char:FindFirstChild("HumanoidRootPart")
    
    if Char and Hum then
        Hum.CFrame = Part
    end
end

function GetMagnitude(Pos)
    if Player.Character and Pos then
        return Player:DistanceFromCharacter(Pos)
    end
    return math.huge
end

function GetArea()
    local tbl = {}

    for i, v in pairs(workspace.__WORKSPACE.Areas:GetChildren()) do
        table.insert(tbl, v.Name)
    end
    return tbl
end

function GetNearest()
    local Near, Dist = nil, math.huge

    for i, v in pairs(workspace.__WORKSPACE.Mobs:GetChildren()) do
        for i2, v2 in pairs(v:GetChildren()) do
            local Part = v2:FindFirstChild("HumanoidRootPart")
            local Mag = GetMagnitude(Part.Position)

            if Mag < Dist then
                Near = v2
                Dist = Mag
            end
        end
    end
    return Near
end

function GetNearestArea()
    local Near, Dist = nil, math.huge

    for i, v in pairs(workspace.__WORKSPACE.Areas:GetChildren()) do
        local Mag = GetMagnitude(v.Point.Position)

        if Mag < Dist then
            Dist = Mag
            Near = v
        end
    end
    return Near
end

function GetNearestEgg()
    local Near, Dist = nil, math.huge

    for i, v in pairs(workspace.__WORKSPACE.FightersPoint:GetChildren()) do
        local Mag = GetMagnitude(v.CF.Position)

        if Mag < Dist then
            Dist = Mag
            Near = v
        end
    end
    return Near
end

function GetStrongestFighter()
    local Fighters = require(ReplicatedStorage.Modules.Fighters)
    local Strongest, StrongestFighter = 0, nil
    local MyFighters = {}

    for i, v in pairs(Player.PlayerGui.UI.CenterFrame.Avatars.Frame:GetChildren()) do
        if v:FindFirstChild("Frame") and v.Frame.Locked.Visible == false then
            table.insert(MyFighters, v.Name)
        end
    end

    for i, v in pairs(Fighters) do
        if table.find(MyFighters, i) and v.Power > Strongest then
            Strongest = v.Power
            StrongestFighter = i
        end
    end
    return StrongestFighter
end

function AutoPunch()
    task.spawn(function()
        while task.wait() do
            if not Config.AutoPunch then return end
            local Area = GetNearestArea()
            local Mag = GetMagnitude(Area.Point.Position)

            if Mag < 20 then
                CallClient({"PowerTrain", Area})
            else
                CallClient({"PowerTrain"})
            end
        end     
    end)
end

function KillAura()
    task.spawn(function()
        while task.wait() do
            if not Config.KillAura then return end
            local Mob = GetNearest()
            local Mag = GetMagnitude(Mob.HumanoidRootPart.Position)
        
            if Mag < 20 then
                CallClient({"AttackMob", GetNearest()}) 
            end
        end     
    end)
end

function AutoCollect()
    task.spawn(function()
        while task.wait(.1) do
            if not Config.AutoCollect then return end
            for i, v in pairs(workspace.__DROPS:GetChildren()) do
                v.CanCollide = false
                v.CFrame = Player.Character.HumanoidRootPart.CFrame
            end
        end
    end)
end

function AutoOpenEgg()
    task.spawn(function()
        while task.wait() do
            if not Config.AutoOpenEgg then return end
            local Egg = GetNearestEgg()

            Teleport(Egg.CF.CFrame * CFrame.new(0, 10, 0))
            CallClient({"BuyTier", Egg, "E", {}})
        end
    end)
end

function AutoEquipAvatar()
    task.spawn(function()
        while task.wait() do
            if not Config.AutoEquipAvatar then return end
            local Fighter = GetStrongestFighter()

            if not Player.PlayerGui.UI.CenterFrame.Avatars.Frame[Fighter].Frame.Equipped.Visible then
                CallClient({"CharacterChange", Fighter})
                task.wait(1)
            end
        end
    end)
end

function DeletePets()
    for i, v in pairs(Player.PlayerGui.UI.CenterFrame.Backpack.Frame:GetChildren()) do
        if v:IsA("ImageLabel") then
            if not v.Frame.Equipped.Visible then
                CallClient({"EquipFighter", "Delete", {[v.Name] = true}})
            end
        end
    end
end

function RankUp()
    local Frame = Player.PlayerGui.UI.CenterFrame["Rank Up"].Frame
    local CoinReq = Frame.CostCoins.UID.Text:split(" ")[1]
    local PowerReq = Frame.CostPower.UID.Text:split(" ")[1]

    StarterGui:SetCore("ChatMakeSystemMessage", {Text = CoinReq .. " Coins | " .. PowerReq .. " Power"})

    CallClient({"RankUp"})
end

-- lib
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/uzu01/public/main/ui/uwuware"))()
local w = library:CreateWindow("Anime Evolution | Uzu")

local MainFolder = w:AddFolder("Main")
local TeleFolder = w:AddFolder("Teleport")
local MiscFolder = w:AddFolder("Misc")

MainFolder:AddToggle({text = "Auto Punch", callback = function(v)
    Config.AutoPunch = v

    AutoPunch()
end})

MainFolder:AddToggle({text = "Kill Aura", callback = function(v)
    Config.KillAura = v

    KillAura()
end})

MainFolder:AddToggle({text = "Auto Collect Coins", callback = function(v)
    Config.AutoCollect = v

    AutoCollect()
end})

MainFolder:AddToggle({text = "Auto Open Egg", callback = function(v)
    Config.AutoOpenEgg = v

    AutoOpenEgg()
end})

MainFolder:AddToggle({text = "Auto Equip Avatar", callback = function(v)
    Config.AutoEquipAvatar = v

    AutoEquipAvatar()
end})

MainFolder:AddButton({text = "Delete Pets", callback = function()
    DeletePets()
end})

MainFolder:AddButton({text = "Rank Up", callback = function()
    RankUp()
end})

TeleFolder:AddList({text = "Select Area", values = GetArea(), callback = function(v)
    Teleport(workspace.__WORKSPACE.Areas[v].Point.CFrame)
end})

MiscFolder:AddBind({text = "Toggle GUI", key = "LeftControl", callback = function() 
    library:Close()
end})

library:Init()
