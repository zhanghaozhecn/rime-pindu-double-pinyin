local function processor(key, env)
    local ctx = env.engine.context
    if not ctx:is_composing() or ctx:has_menu() then
        return 2 -- noop: 不做处理，让系统继续
    end

    local repr = key:repr()
    local intercept_keys = {
        -- 空格与回车（你的原始逻辑：空格拦截，回车不拦截）
        ["space"] = true,
        ["Return"] = false,

        -- ========== 无修饰键（常规按下）==========
        -- 数字键
        ["0"] = true, ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true,
        ["5"] = true, ["6"] = true, ["7"] = true, ["8"] = true, ["9"] = true,

        -- 标点符号（直接按键）
        ["comma"] = true,        -- ,
        ["period"] = true,       -- .
        ["slash"] = true,        -- /
        ["semicolon"] = true,    -- ;
        ["apostrophe"] = true,   -- '
        ["bracketleft"] = true,  -- [
        ["bracketright"] = true, -- ]
        ["backslash"] = true,    -- \
        ["grave"] = true,        -- `
        ["minus"] = true,        -- -
        ["equal"] = true,        -- =

        -- ========== Shift + 数字键产生的符号 ==========
        ["exclam"] = true,        -- Shift+1 → !
        ["at"] = true,            -- Shift+2 → @
        ["numbersign"] = true,    -- Shift+3 → #
        ["dollar"] = true,        -- Shift+4 → $
        ["percent"] = true,       -- Shift+5 → %
        ["asciicircum"] = true,   -- Shift+6 → ^
        ["ampersand"] = true,     -- Shift+7 → &
        ["asterisk"] = true,      -- Shift+8 → *
        ["parenleft"] = true,     -- Shift+9 → (
        ["parenright"] = true,    -- Shift+0 → )

        -- ========== Shift + 标点键产生的符号（单独按键形态）==========
        ["less"] = true,          -- Shift+, → <
        ["greater"] = true,       -- Shift+. → >
        ["question"] = true,      -- Shift+/ → ?
        ["colon"] = true,         -- Shift+; → :
        ["quotedbl"] = true,      -- Shift+' → "
        ["braceleft"] = true,     -- Shift+[ → {
        ["braceright"] = true,    -- Shift+] → }
        ["bar"] = true,           -- Shift+\ → |
        ["asciitilde"] = true,    -- Shift+` → ~
        ["underscore"] = true,    -- Shift+- → _
        ["plus"] = true,          -- Shift+= → +

        -- ========== 带 Shift+ 前缀的 repr（以防修饰键未剥离）==========
        -- 数字排 Shift 组合
        ["Shift+exclam"] = true,
        ["Shift+at"] = true,
        ["Shift+numbersign"] = true,
        ["Shift+dollar"] = true,
        ["Shift+percent"] = true,
        ["Shift+asciicircum"] = true,
        ["Shift+ampersand"] = true,
        ["Shift+asterisk"] = true,
        ["Shift+parenleft"] = true,
        ["Shift+parenright"] = true,

        -- 标点排 Shift 组合
        ["Shift+less"] = true,          -- <
        ["Shift+greater"] = true,       -- >
        ["Shift+question"] = true,      -- ?
        ["Shift+colon"] = true,         -- :
        ["Shift+quotedbl"] = true,      -- "
        ["Shift+braceleft"] = true,     -- {
        ["Shift+braceright"] = true,    -- }
        ["Shift+bar"] = true,           -- |
        ["Shift+asciitilde"] = true,    -- ~
        ["Shift+underscore"] = true,    -- _
        ["Shift+plus"] = true,          -- +

        -- 有些键盘可能发送 Shift+ 数字本身（极少见），也一并拦截
        ["Shift+0"] = true, ["Shift+1"] = true, ["Shift+2"] = true,
        ["Shift+3"] = true, ["Shift+4"] = true, ["Shift+5"] = true,
        ["Shift+6"] = true, ["Shift+7"] = true, ["Shift+8"] = true, ["Shift+9"] = true,
    }

    -- 判断：如果在拦截列表中，清空编码并吞掉
    if intercept_keys[repr] then
        ctx:clear()
        return 1
    end

    -- 其他按键（功能键如 Tab, BackSpace, 方向键等）也放行
    return 2
end

return { func = processor }
