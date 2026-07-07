-- length_split_key.lua — 词长分离按键触发
-- 4 码后按触发键切换为三字以上词模式，首次切换，再次提交首选+输出
-- 1-3码不拦截，由后续 processor 按原功能处理

local function processor(key, env)
    if key:release() then return 2 end

    local ctx = env.engine.context
    local input = ctx.input or ""
    -- 输入被清空时重置标记
    if #input < 4 then _G.pdsp_3plus_active = false end

    local rep = key:repr()
    if rep ~= "semicolon" and rep ~= ";" then return 2 end
    if #input ~= 4 then return 2 end
    if not ctx:is_composing() then return 2 end

    if _G.pdsp_3plus_active then
        _G.pdsp_3plus_active = false
        env.engine:process_key(KeyEvent("space"))
        env.engine:commit_text("；")
        return 1
    end

    _G.pdsp_3plus = true
    _G.pdsp_3plus_active = true
    ctx.input = ""
    ctx.input = input
    return 1
end

return processor
