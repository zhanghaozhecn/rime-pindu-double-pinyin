-- pairfix_key_processor.lua — 09876 上屏 + 词码对分数修正（+200）
-- 2026-11-17 用户定案：固定首选改为词码对分数表（与 pairfix 同表）。
--   0→候选1  9→候选2  8→候选3  7→候选4  6→候选5
-- 按键 = 高亮第 n 个候选、写入 `词<TAB>码<TAB>+200`、立即上屏。
-- 1-5 不拦截（正常数字选重）；+100 固定次选由用户手动编辑 llm_pairfix.tsv。
-- 旧 pin_fix_filter.lua / pin_fix_processor.lua 已作废（存档-固定首选-旧）。
-- 表格式: 词<TAB>码<TAB>[+|-]分数; +/无符号=加分, - =扣分; # 注释。
-- 写入规则: 删除该码旧的最高正分行（固定首选），删除同一词+码行，
--           保留 +100 次选、负分降噪行与注释；临时文件原子替换，首次写留 .bak。

local function get_table_file()
    return rime_api.get_user_data_dir() .. "\\llm_pairfix.tsv"
end

local DEFAULT_HEADER = table.concat({
    "# 词码对分数修正（方案特异: 拼读双拼）",
    "# 行格式: 词<TAB>码<TAB>[+|-]分数",
    "#   +200 / 200 = 加分（固定首选，09876 直接上屏并写入）",
    "#   +100 / 100 = 加分（固定次选，手动编辑本表）",
    "#   -5         = 扣分（pairfix 预置降噪）",
    "#   # 注释; 删本文件 = 机制休眠",
}, "\n") .. "\n"

local function read_all(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local s = f:read("*a")
    f:close()
    return s
end

local function backup_once(path)
    local bak = path .. ".bak-" .. os.date("%Y%m%d")
    local f = io.open(bak, "r")
    if f then f:close(); return end
    local s = read_all(path)
    if not s then return end
    local out = io.open(bak, "w")
    if out then out:write(s); out:close() end
end

local function parse_row(line)
    local w, c, sv = line:match("^(.-)\t(.-)\t(.+)$")
    if not w then
        w, c = line:match("^(.-)\t(.-)$")
        sv = nil
    end
    if not w or w == "" or not c or c == "" then return nil end
    local score = nil
    if sv then
        local t = sv:match("^([%+%-]?[%d%.]+)$")
        if t then score = tonumber(t) end
    end
    return { w = w, c = c, score = score, raw = line }
end

-- 写回：删除同码旧固定首选（最高正分行）与同词+码行，追加 +200
local function save_fix(input, word)
    local path = get_table_file()
    local text = read_all(path)
    backup_once(path)
    if not text then text = DEFAULT_HEADER end
    if text ~= "" and text:sub(-1) ~= "\n" then text = text .. "\n" end
    local lines = {}
    for line in text:gmatch("([^\n]*)\n") do
        line = line:gsub("\r$", "")
        if line ~= "" then lines[#lines + 1] = line end
    end
    -- 该码当前最高正分（旧固定首选）
    local maxpos = nil
    for _, line in ipairs(lines) do
        if line:sub(1, 1) ~= "#" then
            local r = parse_row(line)
            if r and r.c == input and r.score and r.score > 0 then
                if not maxpos or r.score > maxpos then maxpos = r.score end
            end
        end
    end
    local out = {}
    local key = word .. "\t" .. input
    for _, line in ipairs(lines) do
        if line:sub(1, 1) == "#" then
            out[#out + 1] = line
        else
            local r = parse_row(line)
            if not r then
                -- 非法行原样保留（不吞用户数据）
                out[#out + 1] = line
            else
                local same_key = (r.w .. "\t" .. r.c) == key
                local old_first = (r.c == input and r.score
                                   and r.score >= 200 and maxpos
                                   and r.score == maxpos)
                if not same_key and not old_first then
                    out[#out + 1] = line
                end
            end
        end
    end
    out[#out + 1] = word .. "\t" .. input .. "\t+200"
    local body = table.concat(out, "\n") .. "\n"
    local tmp = path .. ".tmp"
    local f = io.open(tmp, "w")
    if not f then return end
    f:write(body)
    f:close()
    os.remove(path)
    local ok = os.rename(tmp, path)
    if not ok then
        -- rename 失败兜底：直接写回（极小概率；避免表丢失）
        local g = io.open(path, "w")
        if g then g:write(body); g:close() end
        os.remove(tmp)
    end
end

local function processor(key_event, env)
    if key_event:release() then return 2 end

    -- 0→1, 9→2, 8→3, 7→4, 6→5
    local rep = key_event:repr()
    local PIN_MAP = { ["0"] = 1, ["9"] = 2, ["8"] = 3, ["7"] = 4, ["6"] = 5 }
    local n = PIN_MAP[rep]
    if not n then return 2 end

    local ctx = env.engine.context
    if not ctx:has_menu() then return 2 end
    local seg = ctx.composition:back()
    if not seg then return 2 end

    -- 高亮第 n 个候选（索引夹到实际候选数范围）
    ctx:highlight(n - 1)
    local cand = ctx:get_selected_candidate()
    if not cand then return 2 end
    local input = ctx.input
    if input == "" then return 2 end

    save_fix(input, cand.text)

    -- 上屏走标准确认路径：用户词学习、commit_history、LLM 记账与正常
    -- 数字选重完全一致（Context 没有 commit_text，必须 confirm_current_selection）
    ctx:confirm_current_selection()
    return 1
end

return processor
