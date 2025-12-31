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
