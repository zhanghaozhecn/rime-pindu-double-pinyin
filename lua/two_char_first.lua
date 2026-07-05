-- two_char_first.lua — 二字词优先
-- 1. 如果首位候选是三字以上词，找最近的二字词提升到首位。
-- 2. 如果没有二字词，复制首选使首选和次选相同（配合 uniquifier 前置使用）。
-- 注意：候选仅 1 个时跳过（第 12 行），此时不存在"次选"概念，
-- 且数字键溢出选末位（overflow_select）已覆盖该场景，无需额外处理。

local function is_two_char(s)
    return #s <= 6
end

local function filter(translation, env)
    local all = {}
    for cand in translation:iter() do table.insert(all, cand) end
    if #all < 2 then for _, c in ipairs(all) do yield(c) end; return end

    local first = all[1]
    if is_two_char(first.text) then
        for _, c in ipairs(all) do yield(c) end
        return
    end

    -- 首位是三字以上词，找最近的二字词
    local two_idx = nil
    for i = 2, #all do
        if is_two_char(all[i].text) then
            two_idx = i
            break
        end
    end

    if two_idx then
        local promoted = all[two_idx]
        yield(ShadowCandidate(promoted, promoted.type, promoted.text, promoted.comment, true))
        for i, c in ipairs(all) do
            if i ~= two_idx then yield(c) end
        end
    else
        -- 没有二字词（#all ≥ 2 且全是 3+ 字词）：复制首选，使首选和次选相同
        -- 若 #all = 1 则走第 12 行直接返回，overflow_select 让按 2=选末位即可
        yield(ShadowCandidate(first, first.type, first.text, first.comment, true))
        for _, c in ipairs(all) do yield(c) end
    end
end

return filter
