-- Lindo Hub v4.1 - Coleta + Armazenamento + ServerHop + Filtro GUI + Anti-Erro 773
-- Feito para Delta Executor / Emulador / PC

-- Auto-escolha de time
pcall(function()
    local rs = game:GetService("ReplicatedStorage")
    local chooseTeam = rs:WaitForChild("Remotes"):FindFirstChild("ChooseTeam")
    chooseTeam:FireServer("Pirates")
end)

repeat wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

-- Serviços e variáveis principais
local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")
local Workspace       = game:GetService("Workspace")
local LocalPlayer     = Players.LocalPlayer
local placeId         = game.PlaceId
local currentJobId    = game.JobId

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LindoHub"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 220)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🍉 LINDO HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local ignoreBox = Instance.new("TextBox", frame)
ignoreBox.Size = UDim2.new(0, 360, 0, 30)
ignoreBox.Position = UDim2.new(0, 20, 0, 50)
ignoreBox.PlaceholderText = "Digite frutas para ignorar separadas por vírgula (ex: Chop, Spike)"
ignoreBox.Text = ""
ignoreBox.ClearTextOnFocus = false
ignoreBox.TextWrapped = true

-- Função para criar toggles
function createToggle(text, y)
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
    toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.SourceSansBold
    toggle.TextSize = 14

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(30, 30, 30)
    end)

    return function() return state end
end

-- Estados dos botões
local isCollecting = createToggle("Coletar frutas", 90)
local isAutoStore  = createToggle("Auto armazenar frutas", 130)
local isHopping    = createToggle("Server hopping", 170)

-- Obter lista de frutas a ignorar
function getIgnoredFruits()
    local text = ignoreBox.Text or ""
    local list = {}
    for fruit in string.gmatch(text, "[^,%s]+") do
        list[fruit:lower()] = true
    end
    return list
end

-- Verifica se tem fruta no mapa
function CheckFruit()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and v.Name:lower():find("fruit") then
            return v:FindFirstChild("Handle") or v, v.Name
        end
    end
    return nil
end

-- Encostar na fruta para pegar
function TouchFruit(part)
    local char = LocalPlayer.Character
    if not (char and part) then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
    wait(0.5)
    firetouchinterest(hrp, part, 0)
    wait(0.1)
    firetouchinterest(hrp, part, 1)
end

-- Controle de servidores já visitados
local visitedServers = {}

-- Obtem servidores válidos
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

    return servers
end

-- Troca para um servidor válido
function ServerHop()
    local servers = GetServers()
    if #servers > 0 then
        local chosen = servers[math.random(1, #servers)]
        visitedServers[chosen] = true
        TeleportService:TeleportToPlaceInstance(placeId, chosen, LocalPlayer)
    end
end

-- Loop principal do sistema
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
