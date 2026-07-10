-- smart_backspace.lua — Ctrl+BackSpace 删除上次上屏的整个词
-- 通用功能，与方案无关。在 pdsp.schema.yaml 的 processors 中引用：
--   - lua_processor@*smart_backspace

local injecting = false  -- 防止注入的退格递归触发

local function processor(key, env)
    if key:release() then return 2 end
    if injecting then return 2 end

    local ctx = env.engine.context
    if ctx.input ~= "" then return 2 end  -- 编码区非空不处理
    if key:repr() ~= "Control+BackSpace" then return 2 end

    local ch = ctx.commit_history
    if not ch then return 2 end

    local all = ch:to_table()
    if not all or #all == 0 then return 2 end

    local last = all[#all]
    if not last or not last.text or #last.text == 0 then return 2 end

    -- 注入 N 个退格到应用，删除整个词
    injecting = true
    for _ = 1, #last.text do
        env.engine.process_key(KeyEvent("BackSpace"))
    end
    injecting = false

    return 1  -- 消费 Ctrl+BackSpace
end

return processor
