-- overflow_select.lua — 数字键超出候选数时选择最后一个候选
-- RIME 选择键: 1-9 和 0（0=第10候选）

local function processor(key, env)
    if key:release() then return 2 end

    -- 解析数字键 0-9，0=第10候选
    local rep = key:repr()
    local n = tonumber(rep)
    if n == 0 then n = 10 end
    if not n then
        local kc = key.keycode
        if kc == 0x30 then n = 10          -- 0 键
        elseif kc >= 0x31 and kc <= 0x39 then n = kc - 0x30  -- 1-9
        end
    end
    if not n or n < 1 or n > 10 then return 2 end

    local ctx = env.engine.context
    if not ctx:has_menu() then return 2 end

    local seg = ctx.composition:back()
    if not seg or not seg.menu then return 2 end

    local count = seg.menu:candidate_count()
    if count > 0 and n > count then
        local last = count == 10 and "0" or tostring(count)
        env.engine:process_key(KeyEvent(last))
        return 1  -- kAccepted
    end

    return 2
end

return processor
