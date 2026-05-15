-- !strict
local Perlin = {}
local Grass = script.Grass

local MapSize = 1000
local TerrainParts = workspace.TerrainFolder
local Colors = {
    [0.8] = Color3.fromRGB(255, 255, 255),
    [0.75] = Color3.fromRGB(66, 66, 66),
    [0.7] = Color3.fromRGB(88, 88, 88),
    [0.5] = Color3.fromRGB(44, 93, 40),
    [0.3] = Color3.fromRGB(52, 111, 48),
    [0.25] = Color3.fromRGB(110, 168, 255),
    [0.10] = Color3.fromRGB(70, 130, 214),
    [0] = Color3.fromRGB(48, 89, 149),
}

local function getColor(y: number): Color3
    local closetKey = -1

    for key, color in pairs(Colors) do
        if y >= key then
            if key > closetKey then
                closetKey = key
            end
        end
    end

    return Colors[closetKey]
end

local function InverseLerp(value: number, start: number, endingValue: number): number
    return (value - start) / (endingValue - start)
end

local function SmoothNumber(baseY: number, threshold: number): number
    if baseY <= threshold then
        return 0
    else
        local larpedValue = InverseLerp(baseY, threshold, 1)
        return larpedValue * larpedValue * (3 - 2 * larpedValue)
    end
end

function Perlin.Generate(Scale: number, Frequency: number, Amplitude: number, ChunkSize: number, SmoothingFactor: number, Seed: number)
    for _, object in pairs(TerrainParts:GetChildren()) do
        object:Destroy()
    end

    local random = Random.new(Seed)
    local xOffset = random:NextNumber(-100000, 100000)
    local zOffset = random:NextNumber(-100000, 100000)

    for x = 0, MapSize do
        for z = 0, MapSize do
            local sampleX = x / Scale * Frequency + xOffset
            local sampleZ = z / Scale * Frequency + zOffset

            local baseY = math.clamp((math.noise(sampleX, sampleZ) + 0.5), 0, 1)
            local preservedBaseY = baseY

            baseY = SmoothNumber(baseY, SmoothingFactor)

            local y = baseY * Amplitude

            local blockHeight = y * 2 + 1
            local BlockCFrame = CFrame.new(x * ChunkSize, y * ChunkSize + blockHeight / 2, z * ChunkSize)

            local clone = Grass:clone()
            clone.CFrame = BlockCFrame
            clone.Color = getColor(preservedBaseY)
            clone.Size = Vector3.new(ChunkSize, blockHeight, ChunkSize)
            clone.Parent = TerrainParts
        end
        task.wait()
    end
end

return Perlin