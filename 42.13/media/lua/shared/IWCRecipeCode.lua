IWCRecipeCode = IWCRecipeCode or {}

local function isAllowedBinSprite(spriteName)
    return spriteName == "trashcontainers_01_16"
        or spriteName == "trashcontainers_01_17"
        or spriteName == "trashcontainers_01_18"
        or spriteName == "trashcontainers_01_20"
        or spriteName == "trashcontainers_01_21"
end

function IWCRecipeCode.isAllowedCollectorIngredient(item, character)
    if not item then return false end
    local t = item:getFullType()
    if t == "Base.Mov_RecycleBin" or t == "Base.Mov_BinRound"
        or t == "Base.Mov_PublicGarbageBin" or t == "Base.Mov_GreenGarbageBin"
        or t == "Base.Mov_GrayGarbageBin" then
        return true
    end
    if t ~= "Base.Moveable" and not string.find(t, "Base.Mov_", 1, true) then
        return true
    end
    local s
    if item.getWorldSprite then s = item:getWorldSprite() end
    if (not s or s == "") and item.getSpriteName then s = item:getSpriteName() end
    return isAllowedBinSprite(s)
end
