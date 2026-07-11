-- no_match_clear.lua — 编码无候选时拦截上屏键（数字/空格/符号），清屏
-- 位置：必须在 speller 之后，否则 has_menu() 检测不到匹配结果
-- 同时存 stripped 和 Shift+ 形式：不同系统 RIME 对修饰键剥离行为不同

local K = {
    space=true, Return=false,
    ["0"]=true,["1"]=true,["2"]=true,["3"]=true,["4"]=true,
    ["5"]=true,["6"]=true,["7"]=true,["8"]=true,["9"]=true,
    comma=true, period=true, slash=true, semicolon=true,
    apostrophe=true, bracketleft=true, bracketright=true,
    backslash=true, grave=true, minus=true, equal=true,
    exclam=true, at=true, numbersign=true, dollar=true,
    percent=true, asciicircum=true, ampersand=true, asterisk=true,
    parenleft=true, parenright=true,
    less=true, greater=true, question=true, colon=true,
    quotedbl=true, braceleft=true, braceright=true,
    bar=true, asciitilde=true, underscore=true, plus=true,
    -- 兼容未剥离 Shift 的系统
    ["Shift+exclam"]=true,["Shift+at"]=true,["Shift+numbersign"]=true,
    ["Shift+dollar"]=true,["Shift+percent"]=true,["Shift+asciicircum"]=true,
    ["Shift+ampersand"]=true,["Shift+asterisk"]=true,
    ["Shift+parenleft"]=true,["Shift+parenright"]=true,
    ["Shift+less"]=true,["Shift+greater"]=true,["Shift+question"]=true,
    ["Shift+colon"]=true,["Shift+quotedbl"]=true,
    ["Shift+braceleft"]=true,["Shift+braceright"]=true,
    ["Shift+bar"]=true,["Shift+asciitilde"]=true,
    ["Shift+underscore"]=true,["Shift+plus"]=true,
    ["Shift+0"]=true,["Shift+1"]=true,["Shift+2"]=true,
    ["Shift+3"]=true,["Shift+4"]=true,["Shift+5"]=true,
    ["Shift+6"]=true,["Shift+7"]=true,["Shift+8"]=true,["Shift+9"]=true,
}

local function processor(key, env)
    if key:release() then return 2 end
    local ctx = env.engine.context
    if not ctx:is_composing() or ctx:has_menu() then return 2 end
    if K[key:repr()] then
        ctx:clear()
        return 1
    end
    return 2
end

return { func = processor }
