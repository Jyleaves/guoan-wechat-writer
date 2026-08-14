-- 研究体观点句过滤器：编号段落（（一）（二）……开头）的段首句
-- （从段首到第一个句号/问号/叹号，含句号）标记为 LeadSentence 字符样式（楷体）。
-- 总论段与无编号段落不处理。样本依据：算力金属（段首观点句楷体、事实句仿宋）。
--
-- 重要：本文件按 lua 字节串语义编写（pandoc 内嵌 lua 为字节模式）：
-- string.find/sub/# 均按字节。切割必须按整字符的字节长度对齐；
-- 禁止把多字节字符放进字符类 [。！？]——字节模式会把多字节字符展开成
-- 单字节集合，导致误匹配其他汉字的字节（曾造成"（"被拦腰切断、输出 U+FFFD 方框）。

local PUNCTS = { '。', '！', '？' }
local NUM_CHARS = { '一', '二', '三', '四', '五', '六', '七', '八', '九', '十' }

local function starts_with_num(s)
  s = s:gsub('^%s+', '')
  local open_len = #'（'
  local close_len = #'）'
  for _, n in ipairs(NUM_CHARS) do
    local nlen = #n
    if s:sub(1, open_len) == '（' and s:sub(open_len + 1, open_len + nlen) == n
        and s:sub(open_len + nlen + 1, open_len + nlen + close_len) == '）' then
      return true
    end
  end
  return false
end

local function first_sentence_end(s)
  local best = nil
  for _, p in ipairs(PUNCTS) do
    local i = s:find(p, 1, true)
    if i and (not best or i < best) then
      best = i + #p - 1
    end
  end
  return best
end

function Para(el)
  if not starts_with_num(pandoc.utils.stringify(el.content)) then return nil end

  local lead_inlines = {}
  local rest_inlines = {}
  local done = false
  for _, inl in ipairs(el.content) do
    if done then
      table.insert(rest_inlines, inl)
    else
      local s = pandoc.utils.stringify(inl)
      local endpos = first_sentence_end(s)
      if endpos and inl.t == 'Str' then
        table.insert(lead_inlines, pandoc.Str(s:sub(1, endpos)))
        if endpos < #s then
          table.insert(rest_inlines, pandoc.Str(s:sub(endpos + 1)))
        end
        done = true
      elseif endpos then
        table.insert(lead_inlines, inl)
        done = true
      else
        table.insert(lead_inlines, inl)
      end
    end
  end
  if #rest_inlines == 0 then return nil end

  local lead = pandoc.Span(lead_inlines, { ['custom-style'] = 'LeadSentence' })
  el.content = { lead }
  for _, inl in ipairs(rest_inlines) do
    table.insert(el.content, inl)
  end
  return el
end
