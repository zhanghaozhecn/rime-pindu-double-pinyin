-- key_extra.lua — 按键附加功能（以词定字）
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
