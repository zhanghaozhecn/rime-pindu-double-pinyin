-- pin_fix_processor.lua — 09876 固顶 1-5 候选并上屏
-- 0→候选1  9→候选2  8→候选3  7→候选4  6→候选5
-- 固顶词写入 pin_fix.txt（幂等：已固顶再按只重复固顶，不取消）
-- 取消固顶 = 手动编辑 pin_fix.txt（2026-11-08 改版：按键固顶同时上屏，
-- 原有"再按取消"逻辑与上屏冲突——按 0 提交固顶词本身会误触取消——故移除）

local function get_fix_file()
  return rime_api.get_user_data_dir() .. "\\pin_fix.txt"
end

local function load_fix_map()
  local map = {}
  local file = io.open(get_fix_file(), "r")
  if not file then return map end
  for line in file:lines() do
    line = line:match("^%s*(.-)%s*$")
    if line ~= "" and not line:match("^#") then
      local code, word = line:match("^(.-)\t(.+)$")
      if not code then
        code, word = line:match("^(.-)%s+(.+)$")
      end
      if code and word and not map[code] then
        map[code] = word
      end
    end
  end
  file:close()
  return map
end

local function save_fix_map(map)
  local file = io.open(get_fix_file(), "w")
  if not file then return end
  for code, word in pairs(map) do
    file:write(code .. "\t" .. word .. "\n")
  end
  file:close()
end

local function processor(key_event, env)
  if key_event:release() then return 2 end

  -- 0→1, 9→2, 8→3, 7→4, 6→5
  local rep = key_event:repr()
  local PIN_MAP = {["0"]=1, ["9"]=2, ["8"]=3, ["7"]=4, ["6"]=5}
  local n = PIN_MAP[rep]
  if not n then return 2 end

  local ctx = env.engine.context
  if not ctx:has_menu() then return 2 end

  local seg = ctx.composition:back()
  if not seg then return 2 end

  -- 高亮第 n 个候选（highlight 内部把索引夹到实际候选数范围；返回 false
  -- 只是"高亮未变化"，非失败——按 0 时候选 1 本就高亮，属最常见情形）
  ctx:highlight(n - 1)
  local cand = ctx:get_selected_candidate()

  if not cand then return 2 end

  local input = ctx.input
  if input == "" then return 2 end

  local map = load_fix_map()
  map[input] = cand.text   -- 一律固顶（幂等）
  save_fix_map(map)

  -- 固顶同时上屏所选候选（2026-11-08 改版）。注意 Context 没有 commit_text
  -- 方法（那是 Engine 的，2026-11-08 实测调用抛错被吞=固顶成功但不上屏），
  -- 上屏必须走标准确认路径 confirm_current_selection：用户词学习、
  -- commit_history、llm_processor 取码与正常数字选重完全一致
  ctx:confirm_current_selection()

  return 1
end

return processor
