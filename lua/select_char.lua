-- select_char.lua
-- 以词定字：- 取选中候选的首字，= 取末字
-- 无候选时透传，不影响 -= 键的正常符号输入

-- Match a single UTF-8 codepoint (1-4 bytes)
local function utf8_first(text)
    return string.match(text, "^([\1-\127\194-\253][\128-\191]*)")
end

local function utf8_last(text)
    return string.match(text, "([\1-\127\194-\253][\128-\191]*)$")
end

local function processor(key_event, env)
    local ctx = env.engine.context

    -- Only intercept when candidates are showing
    if not ctx:has_menu() then
        return 2 -- kNoop: let key pass through to punctuator
    end

    local key_repr = key_event:repr()
    local char = nil

    if key_repr == "minus" then
        local cand = ctx:get_selected_candidate()
        if cand and cand.text and #cand.text > 0 then
            char = utf8_first(cand.text)
        end
    elseif key_repr == "equal" then
        local cand = ctx:get_selected_candidate()
        if cand and cand.text and #cand.text > 0 then
            char = utf8_last(cand.text)
        end
    end

    if char then
        env.engine:commit_text(char)
        ctx:clear()
        return 1 -- kAccepted: consume key
    end

    return 2 -- kNoop
end

return processor
