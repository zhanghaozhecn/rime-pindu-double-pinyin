-- two_char_first.lua — 二字词优先
-- 如果首位候选是三字以上词，找最近的二字词提升到首位。
-- 如果没有二字词，保持原顺序不变。

-- 判断文本字节数是否 ≤ 6（即 ≤ 2 个中文字符）
local function is_two_char(s)
    return #s <= 6
end

local function filter(translation, env)
    local all = {}
    for cand in translation:iter() do table.insert(all, cand) end
    if #all < 2 then for _, c in ipairs(all) do yield(c) end; return end

    local first = all[1]
    if is_two_char(first.text) then
        -- 首位已是二字词或单字，无需调整
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
        -- 提升这个二字词到首位
        local promoted = all[two_idx]
        yield(ShadowCandidate(promoted, promoted.type, promoted.text, promoted.comment, true))
        for i, c in ipairs(all) do
            if i ~= two_idx then yield(c) end
        end
    else
        -- 没有二字词，保持原顺序
        for _, c in ipairs(all) do yield(c) end
    end
end

return filter
