-- hint_filter.lua — 通用候选注释（类似 RIME dict comment 列）
-- 数据文件 hint.txt，TSV 格式：字词\t编码\t注释
--   编码为空 → 该字词的任意编码都显示此注释
--   编码非空 → 仅当输入编码匹配时显示

local function load_hint_map()
    local map = {}  -- {word: {code: comment}}，key "" 为通配
    local path = rime_api.get_user_data_dir() .. "\\hint.txt"
    local file = io.open(path, "r")
    if not file then return map end
    for line in file:lines() do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" and not line:match("^#") then
            local parts = {}
            for p in line:gmatch("[^\t]+") do table.insert(parts, p) end
            local word, code, comment
            if #parts == 2 then
                -- 兼容旧格式：字词\t注释（编码为空=通配）
                word, comment = parts[1], parts[2]
                code = ""
            elseif #parts >= 3 then
                word, code, comment = parts[1], parts[2], parts[3]
            end
            if word and comment then
                if not map[word] then map[word] = {} end
                map[word][code] = comment
            end
        end
    end
    file:close()
    return map
end

local function filter(translation, env)
    local hint_map = load_hint_map()
    local input = env.engine.context.input

    for cand in translation:iter() do
        local entries = hint_map[cand.text]
        if entries then
            -- 优先精确匹配编码，其次通配（编码为空）
            local comment = entries[input] or entries[""]
            if comment then
                local c = cand.comment ~= "" and (cand.comment .. " " .. comment) or comment
                yield(ShadowCandidate(cand, cand.type, cand.text, c, true))
            else
                yield(cand)
            end
        else
            yield(cand)
        end
    end
end

return filter
