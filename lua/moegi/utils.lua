local M = {}

local function hex_to_rgb(hex)
  local hex_type = '[abcdef0-9][abcdef0-9]'
  local pat = '^#(' .. hex_type .. ')(' .. hex_type .. ')(' .. hex_type .. ')$'
  hex = string.lower(hex)

  assert(string.find(hex, pat) ~= nil, 'hex_to_rgb: invalid hex: ' .. tostring(hex))

  local red, green, blue = string.match(hex, pat)
  return { tonumber(red, 16), tonumber(green, 16), tonumber(blue, 16) }
end

function M.mix(fg, bg, alpha)
  bg = hex_to_rgb(bg)
  fg = hex_to_rgb(fg)

  local function blend(i)
    local ret = alpha * fg[i] + (1 - alpha) * bg[i]
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format('#%02X%02X%02X', blend(1), blend(2), blend(3))
end

function M.shade(color, value, base)
  if vim.o.background == 'light' then
    base = base or '#000000'
  else
    base = base or '#ffffff'
  end

  return M.mix(color, base, math.abs(value))
end

local function normalize_base(color)
  if type(color) ~= 'string' then
    return '#000000'
  end

  if color == 'NONE' then
    return '#000000'
  end

  local hex = color:match('^#%x%x%x%x%x%x$')
  if hex then
    return '#' .. hex:upper()
  end

  local base = color:match('^#([%x]+)%x%x$')
  if base and (#base == 6 or #base == 3) then
    if #base == 3 then
      local r, g, b = base:sub(1, 1), base:sub(2, 2), base:sub(3, 3)
      base = r .. r .. g .. g .. b .. b
    end
    return '#' .. base:sub(1, 6):upper()
  end

  return '#000000'
end

function M.normalize_color(color, fallback)
  if type(color) ~= 'string' then
    return color
  end

  if color == 'NONE' then
    return color
  end

  local hex = color:match('^#%x%x%x%x%x%x$')
  if hex then
    return '#' .. hex:upper()
  end

  local base, alpha = color:match('^#(%x%x%x%x%x%x)(%x%x)$')
  if not base then
    return color
  end

  local alpha_value = tonumber(alpha, 16) or 0
  if alpha_value <= 0 then
    return normalize_base(fallback)
  end

  if alpha_value >= 255 then
    return '#' .. base:upper()
  end

  local blend_alpha = alpha_value / 255
  local fg = '#' .. base:upper()
  local bg = normalize_base(fallback)

  return M.mix(fg, bg, blend_alpha)
end

function M.deep_copy(tbl)
  if type(tbl) ~= 'table' then
    return tbl
  end

  local result = {}
  for key, value in pairs(tbl) do
    result[key] = M.deep_copy(value)
  end

  return result
end

return M
