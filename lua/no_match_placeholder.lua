-- no_match_placeholder.lua

local PH = "\226\150\161"  -- "□" U+25A1 UTF-8 bytes

local function filter(translation, env)
    local has = false
    for cand in translation:iter() do
        has = true
        yield(cand)
    end
    if not has then
        local input = env.engine.context.input or ""
        if input ~= "" then
            yield(Candidate("fixed", 0, #input, PH, ""))
        end
    end
end

return filter
