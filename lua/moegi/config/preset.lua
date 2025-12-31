local palettes = require('moegi.palettes')

local presets = {}

for name, palette in pairs(palettes) do
  local preset = {}
  for key, value in pairs(palette) do
    preset[key] = value
  end

  presets[name] = preset
end

return presets
