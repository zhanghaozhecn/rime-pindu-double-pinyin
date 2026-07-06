-- pin_fix_filter.lua — 方案自带固顶词优先
-- 读 pin_fix.txt → 固顶词移到首位，comment 追加 ⛯
-- 三字以上词模式（pdsp_3plus_active）下不触发固顶

local function load_fix_map()
    local map = {}
    local file = io.open(rime_api.get_user_data_dir() .. "\\pin_fix.txt", "r")
    if not file then return map end
    for line in file:lines() do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" and not line:match("^#") then
            local code, word = line:match("^(.-)\t(.+)$")
            if not code then
                code, word = line:match("^(.-)%s+(.+)$")
            end
            if code and word and not map[code] then
                map[code] = word
            end
        end
    end
    file:close()
    return map
end

local function filter(translation, env)
    -- 三字以上词模式下不触发固顶
    if _G.pdsp_3plus_active then
        for cand in translation:iter() do yield(cand) end
        return
    end

    local all = {}
    for cand in translation:iter() do table.insert(all, cand) end

    local ctx = env.engine.context
    local input = ctx.input or ""
    local fix_map = load_fix_map()
    local fix_word = fix_map[input]

    if not fix_word then
        for _, c in ipairs(all) do yield(c) end
        return
    end

    -- 在候选列表中找固顶词
    local fix_cand = nil
    for _, c in ipairs(all) do
        if c.text == fix_word and c.type ~= "fixed" then
            fix_cand = c
            break
        end
    end
    if not fix_cand then
        local seg = ctx.composition:back()
        if seg then
            fix_cand = Candidate("fixed", seg.start, seg._end, fix_word, "")
        end
    end
    if not fix_cand then
        for _, c in ipairs(all) do yield(c) end
        return
    end

    -- 追加 ⛯，不管已有 comment 是什么
    local fixed_cand = ShadowCandidate(fix_cand, "fixed", fix_cand.text,
                                        fix_cand.comment .. "⛯", true)

    yield(fixed_cand)
    for _, c in ipairs(all) do
        if c ~= fix_cand then yield(c) end
    end
end

return filter
