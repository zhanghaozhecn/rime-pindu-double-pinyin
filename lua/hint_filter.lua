-- hint_filter.lua — 2 码字候选提示第三码形码（数据来自 hint.txt）

local function load_hint_map()
    local map = {}
    local path = rime_api.get_user_data_dir() .. "\\hint.txt"
    local file = io.open(path, "r")
    if not file then return map end
    for line in file:lines() do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" and not line:match("^#") then
            local word, hint = line:match("^([^\t]+)\t(.+)$")
            if word and hint then map[word] = hint end
        end
    end
    file:close()
    return map
end

local function filter(translation, env)
    if #env.engine.context.input ~= 2 then
        for cand in translation:iter() do yield(cand) end
        return
    end
    local hint_map = load_hint_map()
    local idx = 0
    for cand in translation:iter() do
        idx = idx + 1
        if idx >= 2 then
            local hint = hint_map[cand.text]
            if hint then
                local c = cand.comment ~= "" and (cand.comment .. " " .. hint) or hint
                yield(ShadowCandidate(cand, cand.type, cand.text, c, true))
            else
                yield(cand)
            end
        else
            yield(cand)
        end
    end
end

return filter
