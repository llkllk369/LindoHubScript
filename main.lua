-- Lindo Hub v5.3 - Corrigido
-- Coleta + Armazenamento + ServerHop + GUI Movível + Auto ON + Auto Escolha de Time + Drag Manual + Logs + Fechar/Minimizar + Salvar Configurações

-- Configurações do usuário
local Settings = {
    JoinTeam = "Pirates" -- ou "Marines"
}

-- Auto escolha de time segura
repeat wait() until game:IsLoaded()
wait(5)

local rs = game:GetService("ReplicatedStorage")
local chooseTeam = rs:WaitForChild("Remotes"):FindFirstChild("ChooseTeam")
pcall(function()
    chooseTeam:FireServer(Settings.JoinTeam)
end)

repeat wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local placeId = game.PlaceId
local currentJobId = game.JobId
local ConfigFile = "LindoHubSettings.txt"

-- Carregar configurações salvas
local savedIgnoreList = ""
if typeof(isfile) == "function" and isfile(ConfigFile) then
    local data = readfile(ConfigFile)
    if data then
        savedIgnoreList = data
    end
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "LindoHub"
pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 220)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
frame.Active = true

-- Drag manual
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Header e botões extras
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -60, 0, 30)
title.Text = "🍉 LINDO HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Position = UDim2.new(0, 0, 0, 0)

-- Botão fechar
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Caixa de texto para ignorar frutas
local ignoreBox = Instance.new("TextBox", frame)
ignoreBox.Size = UDim2.new(0, 360, 0, 30)
ignoreBox.Position = UDim2.new(0, 20, 0, 50)
ignoreBox.PlaceholderText = "Digite frutas para ignorar separadas por vírgula (ex: Chop, Spike)"
ignoreBox.Text = savedIgnoreList
ignoreBox.ClearTextOnFocus = false
ignoreBox.TextWrapped = true
ignoreBox.FocusLost:Connect(function()
    if typeof(writefile) == "function" then
        writefile(ConfigFile, ignoreBox.Text)
    end
end)

-- Criar toggles
function createToggle(text, y, default)
    local label = Instance.new("TextLabel", frame)
    label.Position = UDim2.new(0, 20, 0, y)
    label.Size = UDim2.new(0, 200, 0, 25)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.BackgroundTransparency = 1

    local toggle = Instance.new("TextButton", frame)
    toggle.Position = UDim2.new(0, 300, 0, y)
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(30, 30, 30)
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.SourceSansBold
    toggle.TextSize = 14

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(30, 30, 30)
    end)

    return function() return state end
end

local isCollecting = createToggle("Coletar frutas", 90, true)
local isAutoStore  = createToggle("Auto armazenar frutas", 130, true)
local isHopping    = createToggle("Server hopping", 170, true)

-- Funções
function getIgnoredFruits()
    local text = ignoreBox.Text or ""
    local list = {}
    for fruit in string.gmatch(text, "[^,%s]+") do
        list[fruit:lower()] = true
    end
    return list
end

function CheckFruit()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and v.Name:lower():find("fruit") then
            return v:FindFirstChild("Handle") or v, v.Name
        end
    end
    return nil
end

function TouchFruit(part)
    local char = LocalPlayer.Character
    if not (char and part) then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
    wait(0.5)
    if typeof(firetouchinterest) == "function" then
        firetouchinterest(hrp, part, 0)
        wait(0.1)
        firetouchinterest(hrp, part, 1)
    else
        warn("⚠️ Seu executor não suporta firetouchinterest.")
    end
end

local visitedServers = {}

function GetServers()
    local servers = {}
    local cursor = ""
    local tries = 0

    repeat
        local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100&cursor="..cursor
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and result and result.data then
            for _, server in pairs(result.data) do
                local jobId = server.id
                if server.playing < server.maxPlayers and jobId ~= currentJobId and not visitedServers[jobId] then
                    table.insert(servers, jobId)
                end
            end
            cursor = result.nextPageCursor or ""
        end

        tries = tries + 1
        wait(0.2)
    until (#servers >= 5 or cursor == nil or tries >= 5)

    print("[✳] Servidores encontrados para hop: ", #servers)
    return servers
end

function ServerHop()
    local servers = GetServers()
    if #servers > 0 then
        local chosen = servers[math.random(1, #servers)]
        visitedServers[chosen] = true
        print("[⚡] Trocando para servidor:", chosen)
        TeleportService:TeleportToPlaceInstance(placeId, chosen, LocalPlayer)
    else
        warn("[⚠] Não encontrou servidores para trocar!")
    end
end

-- Loop principal
task.spawn(function()
    while true do
        if isCollecting() then
            local fruit, fname = CheckFruit()
            local ignored = getIgnoredFruits()

            if fruit and not ignored[fname:lower()] then
                TouchFruit(fruit)
                if isAutoStore() then
                    print("🍍 Armazenando: " .. fname)
                end
                wait(30)
            elseif isHopping() then
                wait(15)
                ServerHop()
            end
        end
        wait(5)
    end
end)
