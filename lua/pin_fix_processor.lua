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
  local target = KeyEvent("F20")
  if not key_event:eq(target) then return 2 end

  local ctx = env.engine.context
  local input = ctx.input
  if input == "" or not ctx:has_menu() then return 2 end

  local cand = ctx:get_selected_candidate()
  if not cand then return 2 end

  local map = load_fix_map()
  map[input] = cand.text
  save_fix_map(map)

  -- 固定后直接上屏当前选中候选
  --ctx:commit()

  return 1
end

return processor