-- 研究体观点句过滤器：编号段落（（一）（二）……开头）的段首句
-- （从段首到第一个句号/问号/叹号）标记为 LeadSentence 字符样式（楷体）。
-- 总论段与无编号段落不处理。样本依据：算力金属（段首观点句楷体、事实句仿宋）。
local function starts_with_num(s)
  return s:match('^%s*%（[一二三四五六七八九十]+）') ~= nil
end

function Para(el)
  local text = pandoc.utils.stringify(el.content)
  if not starts_with_num(text) then return nil end
  local first = text:find('[。！？]')
  if not first or first == #text then return nil end

  local lead_inlines = {}
  local rest_inlines = {}
  local done = false
  for _, inl in ipairs(el.content) do
    if done then
      table.insert(rest_inlines, inl)
    else
      local s = pandoc.utils.stringify(inl)
      local idx = s:find('[。！？]')
      if idx and inl.t == 'Str' then
        table.insert(lead_inlines, pandoc.Str(s:sub(1, idx)))
        if idx < #s then
          table.insert(rest_inlines, pandoc.Str(s:sub(idx + 1)))
        end
        done = true
      elseif idx then
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
