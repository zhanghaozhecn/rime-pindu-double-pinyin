-- word_length_split.lua — pdsp_3plus 标记决定保留二字词还是三字以上词

local function filter(translation, env)
    local want_3plus = _G.pdsp_3plus
    _G.pdsp_3plus = false

    local all = {}
    for cand in translation:iter() do table.insert(all, cand) end

    for _, c in ipairs(all) do
        local is_short = (#c.text <= 6)
        if want_3plus then
            if not is_short then yield(c) end
        else
            if is_short then yield(c) end
        end
    end
end

return filter
