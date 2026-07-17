-- key_extra.lua — 按键附加功能（数字溢出 + 以词定字）
-- 在 pdsp.schema.yaml 的 processors 中引用：- lua_processor@*key_extra

-- UTF-8 首/尾字符提取
local function utf8_first(text)
    return string.match(text, "^([\1-\127\194-\253][\128-\191]*)")
end
local function utf8_last(text)
    return string.match(text, "([\1-\127\194-\253][\128-\191]*)$")
end

local function processor(key, env)
    if key:release() then return 2 end

    local ctx = env.engine.context
    local rep = key:repr()

    -- ── 数字溢出：超出候选数时选择最后一个候选 ──
    local n = tonumber(rep)
    if n == 0 then n = 10 end
    if not n then
        local kc = key.keycode
        if kc == 0x30 then n = 10
        elseif kc >= 0x31 and kc <= 0x39 then n = kc - 0x30
        end
    end
    if n and n >= 1 and n <= 10 then
        if not ctx:has_menu() then return 2 end
        local seg = ctx.composition:back()
        if not seg or not seg.menu then return 2 end
        local count = seg.menu:candidate_count()
        if count == 0 then return 2 end
        if n > count then
            local last = count == 10 and "0" or tostring(count)
            env.engine:process_key(KeyEvent(last))
            return 1
        end
    end

    -- ── 以词定字：- 首字，= 末字 ──
    if ctx:has_menu() and (rep == "minus" or rep == "equal") then
        local cand = ctx:get_selected_candidate()
        if cand and cand.text and #cand.text > 0 then
            local char = nil
            if rep == "minus" then
                char = utf8_first(cand.text)
            else
                char = utf8_last(cand.text)
            end
            if char then
                env.engine:commit_text(char)
                ctx:clear()
                return 1
            end
        end
    end

    return 2  -- kNoop
end

return processor
