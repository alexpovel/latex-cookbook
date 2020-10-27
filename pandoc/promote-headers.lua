-- From https://stackoverflow.com/a/56005271/11477374:
-- Automatically get "Document Title" from Markdown top-level heading by promoting all
-- headings one level up (for Markdown, # becomes %, ## becomes # etc.).
-- See also:
-- https://github.com/jgm/pandoc/issues/5615

local title

-- Promote all headers by one level. Set title from level 1 headers,
-- unless it has been set before.
function promote_header (header)

  if header.level >= 2 then
    header.level = header.level - 1
    return header
  end

  if not title then
    title = header.content
    return {}
  end

  local msg = '[WARNING] title already set; discarding header "%s"\n'
  io.stderr:write(msg:format(pandoc.utils.stringify(header)))
  return {}
end

return {
  {Meta = function (meta) title = meta.title end}, -- init title
  {Header = promote_header},
  {Meta = function (meta) meta.title = title; return meta end}, -- set title
}
