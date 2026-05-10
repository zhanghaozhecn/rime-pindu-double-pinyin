local function load_fix_map()
  local map = {}
  local file = io.open(rime_api.get_user_data_dir() .. "\\pin_fix.txt", "r")
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

local function translator(input, segment, env)
  local map = load_fix_map()
  local word = map[input]
  if word then
    local cand = Candidate("fixed", segment.start, segment._end, word, "⛯")
    cand.quality = 99999
    yield(cand)
  end
end

return translator