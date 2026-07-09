-- pin_fix_processor.lua — Ctrl+数字固顶/取消
-- 普通4码模式写入 pin_fix.txt，长词模式写入 pin_fix_3plus.txt

local function get_fix_file()
  local name = "pin_fix.txt"
  if _G.pdsp_3plus_active then
    name = "pin_fix_3plus.txt"
  end
  return rime_api.get_user_data_dir() .. "\\" .. name
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

  -- Ctrl+数字（Tab 由 key_binder 映射为 Control+1）
  if not key_event:ctrl() then return 2 end
  local kc = key_event.keycode
  local n = nil
  if kc == 0x30 then n = 10
  elseif kc >= 0x31 and kc <= 0x39 then n = kc - 0x30
  else return 2 end

  local ctx = env.engine.context
  local input = ctx.input
  if input == "" or not ctx:has_menu() then return 2 end

  local seg = ctx.composition:back()
  if not seg then return 2 end
  local old_idx = seg.selected_index
  seg.selected_index = n - 1
  local cand = ctx:get_selected_candidate()
  seg.selected_index = old_idx

  if not cand then return 2 end

  local map = load_fix_map()
  if map[input] == cand.text then
    map[input] = nil   -- 已固顶 → 取消
  else
    map[input] = cand.text
  end
  save_fix_map(map)

  return 1
end

return processor
