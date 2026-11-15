-- Adds loading="lazy" to every raw-HTML <iframe> so off-screen slide viewers
-- don't all start at once, and gives whole-slide-viewer iframes that lack a
-- title an accessible name in the page language. Existing values are kept.
-- Self-check: filters/test-wsi-iframes.sh

local is_tr = false

local function fix_iframes(html)
  return (html:gsub('<iframe(.-)>', function(attrs)
    if not attrs:find('loading=', 1, true) then
      attrs = ' loading="lazy"' .. attrs
    end
    -- Quarto's {{< video >}} shortcode emits title="" when none is given.
    attrs = attrs:gsub('title=""', 'title="Video"')
    if not attrs:find('title=', 1, true) then
      local path = attrs:match('images%.patolojiatlasi%.com/([^"\']+)%.html')
      if path then
        local label = is_tr and 'Sanal mikroskop' or 'Whole-slide viewer'
        attrs = ' title="' .. label .. ' — ' .. path:gsub('/', ' / ') .. '"' .. attrs
      end
    end
    return '<iframe' .. attrs .. '>'
  end))
end

local function raw(el)
  if el.format == 'html' and el.text:find('<iframe', 1, true) then
    el.text = fix_iframes(el.text)
    return el
  end
end

return {
  { Meta = function(meta)
      is_tr = pandoc.utils.stringify(meta.lang or ''):lower():match('^tr') ~= nil
    end },
  { RawBlock = raw, RawInline = raw },
}
