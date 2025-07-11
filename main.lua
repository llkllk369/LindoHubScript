-- Lindo Hub v3.0 - Coleta Frutas + Server Hop
-- Delta Executor / Emulador compatível / Loop infinito com coleta

-- Auto-escolha de time (Piratas)
pcall(function()
    local rs = game:GetService("ReplicatedStorage")
    local chooseTeam = rs:WaitForChild("Remotes"):FindFirstChild("ChooseTeam")
    if chooseTeam then
        chooseTeam:FireServer("Pirates") -- Mude para "Marines" se quiser
    end
end)

-- Aguarda jogador e personagem
repeat wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

-- Serviços
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local placeId = game.PlaceId
local currentJobId = game.JobId

-- GUI Informativa
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LindoHub"

local info = Instance.new("TextLabel", gui)
info.Text = "🍉 Lindo Hub v3.0 carregado..."
info.Size = UDim2.new(0, 260, 0, 25)
info.Position = UDim2.new(0, 10, 0, 10)
info.BackgroundColor3 = Color3.fromRGB(25,25,25)
info.TextColor3 = Color3.fromRGB(255,255,255)
info.Font = Enum.Font.SourceSansBold
info.TextSize = 16
info.BorderSizePixel = 0

-- Verifica frutas disponíveis
function CheckFruit()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and v.Name:lower():find("fruit") then
            return v:FindFirstChild("Handle") or v
        end
    end
    return nil
end

-- Simula toque do personagem com a fruta para armazenar
function TouchFruit(fruitPart)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    if fruitPart and hrp then
        -- Move até a fruta
        hrp.CFrame = CFrame.new(fruitPart.Position + Vector3.new(0, 3, 0))
        wait(0.5)
        -- Simula o contato físico
        firetouchinterest(hrp, fruitPart, 0)
        wait(0.2)
        firetouchinterest(hrp, fruitPart, 1)
    end
end

-- Busca servidores válidos
function GetServers()
    local servers = {}
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= currentJobId then
                table.insert(servers, server.id)
            end
        end
    end
    return servers
end

-- Troca de servidor
function ServerHop()
    local servers = GetServers()
    if #servers > 0 then
        local chosen = servers[math.random(1, #servers)]
        info.Text = "🔁 Trocando de servidor..."
        wait(1)
        TeleportService:TeleportToPlaceInstance(placeId, chosen, player)
    else
        info.Text = "⚠️ Nenhum servidor disponível"
    end
end

-- Loop principal
while true do
    local fruit = CheckFruit()
    if fruit then
        info.Text = "🍇 Fruta encontrada: " .. fruit.Parent.Name
        TouchFruit(fruit)
        info.Text = "✅ Fruta armazenada!"
        wait(60) -- Espera 1 min antes de buscar de novo
    else
        info.Text = "❌ Nenhuma fruta. Mudando de servidor..."
        wait(15)
        ServerHop()
    end
end
