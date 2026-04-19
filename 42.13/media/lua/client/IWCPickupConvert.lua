-- Convert generic Moveables.trashcontainers_01_X items into their specific
-- Base.Mov_* counterparts so the CraftRecipe inputs match.

local SPRITE_TO_ITEM = {
    ["trashcontainers_01_16"] = "Base.Mov_RecycleBin",
    ["trashcontainers_01_17"] = "Base.Mov_GreenGarbageBin",
    ["trashcontainers_01_18"] = "Base.Mov_GrayGarbageBin",
    ["trashcontainers_01_19"] = "Base.Mov_GrayGarbageBin",
    ["trashcontainers_01_20"] = "Base.Mov_BinRound",
    ["trashcontainers_01_21"] = "Base.Mov_PublicGarbageBin",
}

local TICK = 60 -- frames between scans
local counter = 0

local function convertInventory(inv)
    if not inv then return end
    local items = inv:getItems()
    if not items then return end
    local toRemove = {}
    local toAdd = {}
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it then
            local t = it:getFullType() or ""
            if string.find(t, "Moveables.trashcontainers_01_", 1, true) == 1 then
                local sprite = t:match("Moveables%.(.+)$")
                local target = SPRITE_TO_ITEM[sprite]
                if target then
                    table.insert(toRemove, it)
                    table.insert(toAdd, target)
                end
            end
        end
    end
    for _, it in ipairs(toRemove) do inv:Remove(it) end
    for _, id in ipairs(toAdd) do inv:AddItem(id) end
end

local function onUpdate(player)
    counter = counter + 1
    if counter < TICK then return end
    counter = 0
    if not player then return end
    convertInventory(player:getInventory())
end

Events.OnPlayerUpdate.Add(onUpdate)
