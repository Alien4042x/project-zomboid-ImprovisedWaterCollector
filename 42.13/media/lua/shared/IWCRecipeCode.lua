IWCRecipeCode = IWCRecipeCode or {}

local BIN_SPRITES = {
    recycle = { ["trashcontainers_01_16"] = true },
    green   = { ["trashcontainers_01_17"] = true },
    gray    = { ["trashcontainers_01_18"] = true, ["trashcontainers_01_19"] = true },
    round   = { ["trashcontainers_01_20"] = true },
    public  = { ["trashcontainers_01_21"] = true },
}

-- All known bin fullTypes — used to reject *other* bin variants in OnTest
-- so e.g. a round bin doesn't satisfy the recycle recipe.
local ALL_BIN_TYPES = {
    ["Base.Mov_RecycleBin"]            = true,
    ["Base.Mov_GreenGarbageBin"]       = true,
    ["Base.Mov_GrayGarbageBin"]        = true,
    ["Base.Mov_BinRound"]              = true,
    ["Base.Mov_PublicGarbageBin"]      = true,
    ["Base.trashcontainers_01_16"]     = true,
    ["Base.trashcontainers_01_18"]     = true,
    ["Base.trashcontainers_01_19"]     = true,
    ["Base.trashcontainers_01_20"]     = true,
    ["Base.trashcontainers_01_21"]     = true,
}

local function getMoveableSprite(item)
    local s
    if item.getWorldSprite then s = item:getWorldSprite() end
    if (not s or s == "") and item.getSpriteName then s = item:getSpriteName() end
    if (not s or s == "") and item.getModData then
        local md = item:getModData()
        if md then s = md.spriteName or md.worldSprite or md.pickUpSprite end
    end
    return s
end

local function makeChecker(binKey, ...)
    local validTypes = {}
    for i = 1, select('#', ...) do
        validTypes[select(i, ...)] = true
    end
    return function(item)
        if not item then return false end
        local t = item:getFullType()
        if validTypes[t] then return true end
        if t == "Base.Moveable" then
            local sprite = getMoveableSprite(item)
            return sprite ~= nil and BIN_SPRITES[binKey][sprite] == true
        end
        -- Different bin variant — reject so e.g. a round bin doesn't
        -- satisfy the recycle recipe.
        if ALL_BIN_TYPES[t] then return false end
        -- Everything else (rope, garbage bag, blowtorch, ...) passes
        -- through; the per-slot input list does the actual filtering.
        return true
    end
end

IWCRecipeCode.isRecycleBinIngredient = makeChecker("recycle",
    "Base.Mov_RecycleBin", "Base.trashcontainers_01_16")
IWCRecipeCode.isGreenBinIngredient = makeChecker("green",
    "Base.Mov_GreenGarbageBin", "Base.trashcontainers_01_17")
IWCRecipeCode.isGrayBinIngredient = makeChecker("gray",
    "Base.Mov_GrayGarbageBin", "Base.trashcontainers_01_18", "Base.trashcontainers_01_19")
IWCRecipeCode.isRoundBinIngredient = makeChecker("round",
    "Base.Mov_BinRound", "Base.trashcontainers_01_20")
IWCRecipeCode.isPublicBinIngredient = makeChecker("public",
    "Base.Mov_PublicGarbageBin", "Base.trashcontainers_01_21")
