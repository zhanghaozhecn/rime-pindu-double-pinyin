local function processor(key, env)
    local ctx = env.engine.context
    if not ctx:is_composing() or ctx:has_menu() then
        return 2 -- noop: 不做处理，让系统继续
    end

    local repr = key:repr()

    -- 定义需要拦截的按键（除小写字母外的所有可打印字符键）
    local intercept_keys = {
        -- 空格和回车
        ["space"] = true,
        ["Return"] = false,
        -- 标点符号
        ["comma"] = true,        -- ,
        ["period"] = true,       -- .
        ["slash"] = true,        -- /
        ["semicolon"] = true,    -- ;
        ["quote"] = true,        -- '
        ["bracketleft"] = true,  -- [
        ["bracketright"] = true, -- ]
        ["backslash"] = true,    -- \
        ["grave"] = true,        -- `
        ["minus"] = true,        -- -
        ["equal"] = true,        -- =
        ["Shift+comma"] = true,  -- <
        ["greater"] = true,      -- >
        ["question"] = true,     -- ?
        ["colon"] = true,        -- :
        ["quotedbl"] = true,     -- "
        ["braceleft"] = true,    -- {
        ["braceright"] = true,   -- }
        ["bar"] = true,          -- |
        ["asciitilde"] = true,   -- ~
        ["underscore"] = true,   -- _
        ["plus"] = true,         -- +
        -- 数字键
        ["0"] = true,
        ["1"] = true,
        ["2"] = true,
        ["3"] = true,
        ["4"] = true,
        ["5"] = true,
        ["6"] = true,
        ["7"] = true,
        ["8"] = true,
        ["9"] = true,
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
