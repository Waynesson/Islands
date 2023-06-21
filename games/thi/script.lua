getgenv().Config = {
    SelectedBlocks = {"Weak Sand"},
    SelectedChests = {"Common Chest"},
    SelectedOres = {"Copper"},
    SelectedCollections = {"Life Key"},
    SelectedIsland = "Main Island",
    SelectedEgg = "Basic Egg | 100",
    SellAt = 10,
}

local Sett = {
    CanSell = false,
    CanRebirth = false,
    BuyingIsland = false,
    HasCollection = false,
    IsFarmingChest = false,
}

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local IslandInfo = require(ReplicatedStorage.Modules.IslandInfo)
local Location = require(game.ReplicatedStorage.Modules.Location)
local PetItems = require(ReplicatedStorage.Modules.PetItems)
local SpecialEventInfo = require(ReplicatedStorage.Modules.SpecialEventInfo)
local GameItems = require(game.ReplicatedStorage.Modules.GameItems)
local Shorten = loadstring(game:HttpGet("https://raw.githubusercontent.com/uzu01/public/main/util/shorten.lua"))()

local BlacklistedBlocks = {}
local CanDoRebirth = true
local CanCount = true
local CanCount2 = true
local CanCount3 = true
local Count = 0
local Count2 = 0
local Count3 = 0

local PosTable = {
    ["-X"] = Vector3.new(-1, 0, 0),
    ["-Y"] = Vector3.new(0, -1, 0),
    ["-Z"] = Vector3.new(0, 0, -1),
    ["X"] = Vector3.new(1, 0, 0),
    ["Y"] = Vector3.new(0, 1, 0),
    ["Z"] = Vector3.new(0, 0, 1),
}

local IslandPos = {
    ["Main Island"] = CFrame.new(693.7, 63.5, 630),
    ["Stranded Island"] = CFrame.new(782.5, 119.5, -871.7),
    ["Jungle Island"] = CFrame.new(2254.86, 64, -864),
    ["Frozen Island"] = CFrame.new(700.8, 72.5, 2119.5),
    ["Pirate Island"] = CFrame.new(2189.75, 59.5, 2138.2),
    ["Volcano Island"] = CFrame.new(2190.1, 59.5, 634.97),
}

local FolderName = "Kai"
local FileName = "THI - " .. Player.UserId .. ".json"

function Save()
    if writefile then
        if not isfolder(FolderName) then
            makefolder(FolderName)
        end
        writefile(FolderName .. "\\" .. FileName, HttpService:JSONEncode(Config))
    end
end

function Load()
    if readfile and isfile(FolderName .. "\\" .. FileName) then
        getgenv().Config = HttpService:JSONDecode(readfile(FolderName .. "\\" .. FileName))
    end
end

function Teleport(Part)
    local Character = Player.Character

    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = Part
    end
end

function CanFarm(Block)
    local Sign = workspace.AreaItems[Config.SelectedIsland]:FindFirstChild("Sign")
    
    if table.find(BlacklistedBlocks, Block.CFrame) then
        return false
    end

    if Sign and Sign:FindFirstChild("SignPart") then
        local Time = Sign.SignPart.SurfaceGui.BlockCount.Text:split(":")
        local Min = tonumber(Time[1])
        local Sec = tonumber(Time[2])
        local RaycastParams = RaycastParams.new()
    
        if Min == 0 and Sec < 5 or Config.CanRebirth or Config.CanSell then
            Teleport(IslandPos[Config.SelectedIsland])
            return false
        end

        RaycastParams.FilterDescendantsInstances = {Block:GetChildren(), Player.Character:GetDescendants()}
        RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
        for i3, v3 in pairs(PosTable) do
            local Result = workspace:Raycast(Block.Position, v3 * 4, RaycastParams)
    
            if not Result then
                return true
            end
        end
    end
    return false
end

function CanFarm2()
    if Sett.CanSell or Sett.CanRebirth or Sett.BuyingIsland or Sett.HasCollection then
        return false
    end
    return true
end 

function CanCollect()
    if Sett.CanSell or Sett.CanRebirth or Sett.BuyingIsland then
        return false
    end
    return true
end

function GetMostExpensiveTool(Island)
    local Tool, Price = nil, 0
    
    for i, v in pairs(IslandInfo.UpgradeShopItems[Island].Tools) do
        if v.CoinsPrice > Price then
            Price = v.CoinsPrice
            Tool = i
        end
    end
    return Tool
end


function GetEggs()
    local tbl1, tbl2 = {}, {}

    for i, v in pairs(PetItems.Eggs) do
        if v.GemsPrice then
            table.insert(tbl1, {Name = i, Price = v.GemsPrice, Curr = " Gems"})
        elseif v.TurkeyPrice then
            table.insert(tbl1, {Name = i, Price = v.TurkeyPrice, Curr = " Turk"})
        end
    end

    table.sort(tbl1, function(a,b)
        return a.Price < b.Price
    end)

    for i, v in pairs(tbl1) do
        table.insert(tbl2, v.Name .. " | " .. Shorten(v.Price) .. v.Curr)
    end

    return tbl2
end

function GetData(Data)  
    return require(Player.PlayerScripts.GUIScript.ClientDataManager).Data[Data]
end

function GetChests()
    local tbl = {}

    for i, v in pairs(IslandInfo.ChestSpawnInfo) do
        table.insert(tbl, "- " .. i .. " -")
        table.insert(tbl, "")
        for i2, v2 in pairs(v) do
            table.insert(tbl, i2)
        end 
        table.insert(tbl, "")
    end
    
    for i, v in pairs(SpecialEventInfo.SpecialEvents) do
        table.insert(tbl, "- " .. i .. " -")
        table.insert(tbl, "")
        for i2, v2 in pairs(v.Chests) do
            table.insert(tbl, i2)
        end
        table.insert(tbl, "")
    end
    return tbl
end

function GetOres()
    local tbl = {}

    for i, v in pairs(IslandInfo.MaterialBlockSpawnInfo) do
        table.insert(tbl, "- " .. i .. " -")
        table.insert(tbl, "")
        for i2, v2 in pairs(v) do
            table.insert(tbl, i2)
        end 
        table.insert(tbl, "")
    end
    return tbl
end

function GetIslands()
    local tbl = {}

    for i, v in pairs(workspace.BlockTerrain:GetChildren()) do
        table.insert(tbl, v.Name)
    end
    return tbl
end

function GetChest()
    for i, v in pairs(workspace.BlockTerrain[Config.SelectedIsland]:GetChildren()) do
        for i2, v2 in pairs(v:GetChildren()) do
            if table.find(Config.SelectedChests, v2.Name) and CanFarm(v2) then
                return v2
            end
        end
    end
    return false
end

function GetOre()
    for i, v in pairs(workspace.BlockTerrain[Config.SelectedIsland]:GetChildren()) do
        for i2, v2 in pairs(v:GetChildren()) do
            if table.find(Config.SelectedOres, v2.Name) and CanFarm(v2) then
                return v2
            end
        end
    end
    return false
end

function GetCollection()    
    for i, v in pairs(workspace.BlockTerrain[Config.SelectedIsland]:GetChildren()) do
        for i2, v2 in pairs(v:GetChildren()) do
            if v2.Name == "???" and CanFarm(v2) then
                return v2
            end
        end
    end
    return false
end

function MineUnder()
    local Island, c, d, e, Block = Location.GetIslandAndBlockBeneath(1,Player)

    if Island and Block then
        task.spawn(function()
            ReplicatedStorage.Events.TerrainToolRequest:InvokeServer(Island, Block.Position, Block.Position)
        end)
    end
end

function AutoMineUnder()
    while task.wait() and Config.AutoMineUnder do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Hum = Player.Character.HumanoidRootPart
            local Pos1 = IslandPos[Config.SelectedIsland]
            local Pos2 = CFrame.new(Pos1.X, Hum.CFrame.Y, Pos1.Z)
    
            if Pos2 ~= Hum.CFrame and CanFarm2() then
                Teleport(Pos2)
            end
    
            MineUnder() 
        end
    end
end

function AutoChest()
    while task.wait(.1) and Config.AutoChest do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Chest = GetChest()
            local Hum = Player.Character.HumanoidRootPart

            if not Chest and CanFarm2() then
                local Pos1 = IslandPos[Config.SelectedIsland]
                local Pos2 = CFrame.new(Pos1.X, Hum.CFrame.Y, Pos1.Z)

                if Pos2 ~= Hum.CFrame then
                    Teleport(Pos2)
                end

                MineUnder()
            end     

            if Chest and CanFarm(Chest) and CanFarm2() then
                repeat task.wait()
                    local Pos = Chest.CFrame
                    Sett.IsFarmingChest = true
                    Teleport(Pos)

                    task.spawn(function()
                        ReplicatedStorage.Events.TerrainToolRequest:InvokeServer(Chest.Parent.Parent.Name, Pos.p, Pos.p)
                    end)
                until not Chest.Parent or not CanFarm(Chest) or not Config.AutoChest or not CanFarm2()
                Teleport(IslandPos[Config.SelectedIsland])
            end

            for i, v in pairs(workspace.ParticleHolder.DropHolder:GetChildren()) do
                v.CFrame = Hum.CFrame
            end
            Sett.IsFarmingChest = false
        end
    end
end

function AutoOre()
    while task.wait(.1) and Config.AutoOre do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Ore = GetOre()
            local Hum = Player.Character.HumanoidRootPart

            if not Ore and CanFarm2() then
                local Pos1 = IslandPos[Config.SelectedIsland]
                local Pos2 = CFrame.new(Pos1.X, Hum.CFrame.Y, Pos1.Z)

                if Pos2 ~= Hum.CFrame then
                    Teleport(Pos2)
                end

                MineUnder()
            end     

            if Ore and CanFarm(Ore) and CanFarm2() then
                repeat task.wait()
                    local Pos = Ore.CFrame
                    Teleport(Pos)

                    task.spawn(function()
                        ReplicatedStorage.Events.TerrainToolRequest:InvokeServer(Ore.Parent.Parent.Name, Pos.p, Pos.p)

                        if CanCount then
                            CanCount = false

                            task.wait(1)
                            Count += 1

                            if Count > 9 then	
                                local Result = ReplicatedStorage.Events.TerrainToolRequest:InvokeServer(Ore.Parent.Parent.Name, Pos.p, Pos.p)

                                if not Result[1] then
                                    table.insert(BlacklistedBlocks, Ore.CFrame)
                                end
                                Count = 0
                            end	
                            CanCount = true
                        end
                    end)
                until not Ore.Parent or not CanFarm(Ore) or not Config.AutoOre or not CanFarm2()
                Teleport(IslandPos[Config.SelectedIsland])
            end

            for i, v in pairs(workspace.ParticleHolder.DropHolder:GetChildren()) do
                v.CFrame = Hum.CFrame
            end
        end
    end
end

function AutoCollection()
    while task.wait(.1) and Config.AutoCollection do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Collection = GetCollection()

            if Collection and CanFarm(Collection) and CanCollect() then
                Sett.HasCollection = true

                repeat task.wait()
                    local Pos = Collection.CFrame
                    Teleport(Pos)

                    task.spawn(function()
                        ReplicatedStorage.Events.TerrainToolRequest:InvokeServer(Collection.Parent.Parent.Name, Pos.p, Pos.p)

                        if CanCount3 then
                            CanCount3 = false

                            task.wait(1)
                            Count3 += 1

                            if Count3 > 9 then	
                                local Result = ReplicatedStorage.Events.TerrainToolRequest:InvokeServer(Collection.Parent.Parent.Name, Pos.p, Pos.p)

                                if not Result[1] then
                                    table.insert(BlacklistedBlocks, Collection.CFrame)
                                end
                                Count3 = 0
                            end	
                            CanCount3 = true
                        end
                    end)
                until not Collection.Parent or not CanFarm(Collection) or not Config.AutoCollection or not CanCollect()
                Teleport(IslandPos[Config.SelectedIsland])
            end
            Sett.HasCollection = false
        end
    end
end

function AutoSell()
    while task.wait() and Config.AutoSell do
        local Backpack = GetData("BackpackHolding")

        if Backpack >= Config.SellAt then
            local Part = workspace.AreaItems[Config.SelectedIsland].Sell
            local OldPos = Player.Character.HumanoidRootPart.CFrame

            Sett.CanSell = true; task.wait(.3)
            Teleport(Part.CFrame); task.wait(.3)
            Teleport(OldPos); task.wait(.3)
            Sett.CanSell = false
        end
    end
end

function AutoRebirth()
    while task.wait() and Config.AutoRebirth do
        local MyCoins, MyTools, MyRebirths = GetData("Coins"), GetData("ToolsOwned"), GetData("Rebirths")
        local RebirthCost = GameItems.RebirthInfo.GetRebirthCost(MyRebirths)
        local RebirthArea = GameItems.RebirthInfo.GetRebirthArea(MyRebirths)
        local Area = workspace.AreaItems[RebirthArea.IslandName]:FindFirstChild("Rebirth")
        local RequiredTool = GetMostExpensiveTool(RebirthArea.IslandName)
                
        if MyCoins >= RebirthCost and MyTools[RequiredTool] and CanDoRebirth and table.find(GetData("AreasUnlocked"), RebirthArea.IslandName) then             
            CanDoRebirth = false    
            
            if Area then
                Teleport(Area.CFrame)
            else
                Options.SelectedIsland:SetValue(RebirthArea.IslandName)
            end

            Sett.CanRebirth = true
            ReplicatedStorage.Events.UIAction:FireServer("Rebirth")
            task.wait(5)

            if GetData("Rebirths") == MyRebirths + 1 then
                Options.SelectedIsland:SetValue("Main Island")
            end
            CanDoRebirth = true
        end
        Sett.CanRebirth = false
    end
end

function AutoBuyTools()
    while task.wait(.5) and Config.AutoBuyTools do
        local Tool, Island, Lowest = nil, nil, math.huge
        local MyTools, MyCoins, AreasUnlocked = GetData("ToolsOwned"), GetData("Coins"), GetData("AreasUnlocked")

        for i, v in pairs(IslandInfo.UpgradeShopItems) do
            for i2, v2 in pairs(v.Tools) do
                if not MyTools[i2] and MyCoins >= v2.CoinsPrice and v2.CoinsPrice < Lowest then
                    Lowest = v2.CoinsPrice
                    Tool = i2
                    Island = i
                end
            end
        end
    
        if Tool and Island and table.find(AreasUnlocked, Island) and not Sett.CanRebirth then
            ReplicatedStorage.Events.UIAction:FireServer("PurchaseUpgradeShopItem", "Tools", Tool, Island)    
        end
    end
end

function AutoBuyBackpacks()
    while task.wait(.5) and Config.AutoBuyBackpacks do
        local Backpack, Island, Lowest = nil, nil, math.huge
        local MyBackpacks, MyCoins, AreasUnlocked = GetData("BackpacksOwned"), GetData("Coins"), GetData("AreasUnlocked")

        for i, v in pairs(IslandInfo.UpgradeShopItems) do
            for i2, v2 in pairs(v.Backpacks) do
                if not MyBackpacks[i2] and v2.CoinsPrice and MyCoins >= v2.CoinsPrice and v2.CoinsPrice < Lowest then
                    Lowest = v2.CoinsPrice
                    Backpack = i2
                    Island = i
                end
            end
        end
    
        if Backpack and Island and table.find(AreasUnlocked, Island) and not Sett.CanRebirth then
            ReplicatedStorage.Events.UIAction:FireServer("PurchaseUpgradeShopItem", "Backpacks", Backpack, Island)    
        end
    end
end

function AutoBuyIslands()
    while task.wait(.5) and Config.AutoBuyIslands do
        local AreasUnlocked, MyCoins, MyTools = GetData("AreasUnlocked"), GetData("Coins"), GetData("ToolsOwned")

        for i, v in pairs(IslandInfo.OtherInfo) do
            if not table.find(AreasUnlocked,i) and MyCoins >= v.UnlockCost.Coins and MyTools[v.ToolNeededToUnlock] then
                Sett.BuyingIsland = true
                ReplicatedStorage.Events.UIAction:FireServer("UnlockIsland", i)
                task.wait(5)

                if table.find(GetData("AreasUnlocked"), i) then
                    Options.SelectedIsland:SetValue(i)
                end
            end
        end
        Sett.BuyingIsland = false
    end
end

function AutoOpenEgg()
    while task.wait() and Config.AutoOpenEgg do
        local Egg = Config.SelectedEgg:split(" |")[1]

        ReplicatedStorage.Events.RequestEggHatch:FireServer(Egg, 3)
    end
end

function NoClip()
   local Char = Player.Character

   if Char then
      for i, v in pairs(Char:GetDescendants()) do
         if v:IsA("BasePart") then
            v.CanCollide = false
         end
      end
   end
end

if THIR then THIR:Disconnect() end
getgenv().THIR = RunService.Stepped:Connect(function()
    if Sett.IsFarmingChest then
       NoClip()
    end

    local Gui = Player.PlayerGui:FindFirstChild("Gui")
    local Notif = Gui and Gui:FindFirstChild("BackpackFull")

    if Notif and Notif.Visible then
        Notif.Visible = false
    end
end)

for i, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "ScreenGui" then
        v:Destroy()
    end
end

task.wait(.3)
Load()

local Linoria = loadstring(game:HttpGet("https://raw.githubusercontent.com/uzu01/public/main/ui/linoria"))()
local Window = Linoria:CreateWindow({Title = "Treasure Hunt Islands | Uzu", Center = true, AutoShow = true})

local MainTab = Window:AddTab("Main")

local FarmingBox = MainTab:AddLeftTabbox()
local ShopBox = MainTab:AddLeftTabbox()
local EggBox = MainTab:AddLeftTabbox()
local SettingsBox = MainTab:AddRightTabbox()
local MiscBox = MainTab:AddRightTabbox()

local FarmingTab = FarmingBox:AddTab("Farming")
local ShopTab = ShopBox:AddTab("Shop")
local EggTab = EggBox:AddTab("Egg")
local SettingsTab = SettingsBox:AddTab("Settings")
local MiscTab = MiscBox:AddTab("Misc")

FarmingTab:AddToggle("AutoMineUnder", {Text = "Auto Mine (Under)", Default = Config.AutoMineUnder})
FarmingTab:AddToggle("AutoChest", {Text = "Auto Chest", Default = Config.AutoChest})
FarmingTab:AddToggle("AutoOre", {Text = "Auto Ore", Default = Config.AutoOre})
FarmingTab:AddToggle("AutoCollection", {Text = "Auto Collect `???`", Default = Config.AutoCollection})
FarmingTab:AddToggle("AutoSell", {Text = "Auto Sell", Default = Config.AutoSell})
FarmingTab:AddToggle("AutoRebirth", {Text = "Auto Rebirth", Default = Config.AutoRebirth})
ShopTab:AddToggle("AutoBuyTools", {Text = "Auto Buy Tools", Default = Config.AutoBuyTools})
ShopTab:AddToggle("AutoBuyBackpacks", {Text = "Auto Buy Backpacks", Default = Config.AutoBuyBackpacks})
ShopTab:AddToggle("AutoBuyIslands", {Text = "Auto Buy Islands", Default = Config.AutoBuyIslands})
EggTab:AddToggle("AutoOpenEgg", {Text = "Auto Open Egg", Default = Config.AutoOpenEgg})
SettingsTab:AddDropdown("SelectedIsland", {Values = GetIslands(), Default = Config.SelectedIsland, Multi = false, Text = "Selected Island"})
SettingsTab:AddDropdown("SelectedChests", {Values = GetChests(), Default = Config.SelectedChests, Multi = true, Text = "Selected Chests"})
SettingsTab:AddDropdown("SelectedOres", {Values = GetOres(), Default = Config.SelectedOres, Multi = true, Text = "Selected Ores"})
SettingsTab:AddDropdown("SelectedEgg", {Values = GetEggs(), Default = Config.SelectedEgg, Multi = false, Text = "Selected Egg"})
SettingsTab:AddInput("SellAt", {Default = Config.SellAt, Numeric = true, Finished = true, Text = "Sell At", Placeholder = Config.SellAt})
MiscTab:AddLabel("Keybind"):AddKeyPicker("Keybind", { Default = "LeftControl", NoUI = true, Text = "Keybind"}) 
MiscTab:AddButton("Discord", function() setclipboard(Discord or "No Discord Link Found") end)

Toggles.AutoMineUnder:OnChanged(function()
    Config.AutoMineUnder = Toggles.AutoMineUnder.Value

    Save()
    task.spawn(AutoMineUnder)
end)

Toggles.AutoChest:OnChanged(function()
    Config.AutoChest = Toggles.AutoChest.Value

    Save()
    task.spawn(AutoChest)
end)

Toggles.AutoOre:OnChanged(function()
    Config.AutoOre = Toggles.AutoOre.Value

    Save()
    task.spawn(AutoOre)
end)

Toggles.AutoCollection:OnChanged(function()
    Config.AutoCollection = Toggles.AutoCollection.Value

    Save()
    task.spawn(AutoCollection)
end)

Toggles.AutoSell:OnChanged(function()
    Config.AutoSell = Toggles.AutoSell.Value

    Save()
    task.spawn(AutoSell)
end)

Toggles.AutoRebirth:OnChanged(function()
    Config.AutoRebirth = Toggles.AutoRebirth.Value

    Save()
    task.spawn(AutoRebirth)
end)

Toggles.AutoBuyTools:OnChanged(function()
    Config.AutoBuyTools = Toggles.AutoBuyTools.Value

    Save()
    task.spawn(AutoBuyTools)
end)

Toggles.AutoBuyBackpacks:OnChanged(function()
    Config.AutoBuyBackpacks = Toggles.AutoBuyBackpacks.Value

    Save()
    task.spawn(AutoBuyBackpacks)
end)

Toggles.AutoBuyIslands:OnChanged(function()
    Config.AutoBuyIslands = Toggles.AutoBuyIslands.Value

    Save()
    task.spawn(AutoBuyIslands)
end)

Toggles.AutoOpenEgg:OnChanged(function()
    Config.AutoOpenEgg = Toggles.AutoOpenEgg.Value

    Save()
    task.spawn(AutoOpenEgg)
end)

Options.SelectedIsland:OnChanged(function()
    Config.SelectedIsland = Options.SelectedIsland.Value
    
    Save()
    Teleport(IslandPos[Config.SelectedIsland])
end)

Options.SelectedEgg:OnChanged(function()
    Config.SelectedEgg = Options.SelectedEgg.Value

    Save()
end)

Options.SellAt:OnChanged(function()
    Config.SellAt = tonumber(Options.SellAt.Value)

    Save()
end)    

Options.SelectedChests:OnChanged(function()
    Config.SelectedChests = {}

    for i, v in pairs(Options.SelectedChests.Value) do
        table.insert(Config.SelectedChests, i)
    end
    Save()
end)

Options.SelectedOres:OnChanged(function()
    Config.SelectedOres = {}

    for i, v in pairs(Options.SelectedOres.Value) do
        table.insert(Config.SelectedOres, i)
    end
    Save()
end)

Options.Keybind:OnClick(function()
    task.spawn(Linoria.Toggle)
end)

for i, v in pairs(CoreGui.RobloxPromptGui.promptOverlay:GetChildren()) do
    if v.Name == "ErrorPrompt" then
        Player:Kick("Rejoining")
        TeleportService:Teleport(game.PlaceId, Player)
    end
end

CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(v)
    if v.Name == "ErrorPrompt" then
        Player:Kick("Rejoining")
        TeleportService:Teleport(game.PlaceId, Player)
    end
end)
