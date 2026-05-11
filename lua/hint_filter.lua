-- 读取 hint.txt，返回 {候选词 = 提示} 的映射表
local function load_hint_map()
  local map = {}
  local path = rime_api.get_user_data_dir() .. "\\hint.txt"
  local file = io.open(path, "r")
  if not file then return map end
  for line in file:lines() do
    line = line:match("^%s*(.-)%s*$")     -- 去掉首尾空格
    if line ~= "" and not line:match("^#") then
      local word, hint = line:match("^([^\t]+)\t(.+)$")
      if not word then
        word, hint = line:match("^([^%s]+)%s+(.+)$")  -- 兼容空格分隔
      end
      if word and hint then
        map[word] = hint
      end
    end
  end
  file:close()
  return map
end

local function filter(translation, env)
  local ctx = env.engine.context
  -- 仅当输入长度为 2 时才处理
  if #ctx.input ~= 2 then
    -- 不处理，直接透传
    for cand in translation:iter() do
      yield(cand)
    end
    return
  end

  local hint_map = load_hint_map()
  local index = 0
  for cand in translation:iter() do
    index = index + 1
    if index >= 2 then
      local hint = hint_map[cand.text]
      if hint then
        -- 追加提示，保留原注释
        local new_comment = cand.comment ~= "" and (cand.comment .. " " .. hint) or hint
        yield(ShadowCandidate(cand, cand.type, cand.text, new_comment, true))
      else
        yield(cand)
      end
    else
      -- 第一个候选原样输出
      yield(cand)
    end
  end
end

return filter