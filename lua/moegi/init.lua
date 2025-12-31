local config = require('moegi.config')
local palettes = require('moegi.palettes')
local utils = require('moegi.utils')

local M = {}

local function extend(target, override)
  if type(override) ~= 'table' then
    return override
  end

  local result = {}
  for key, value in pairs(target or {}) do
    result[key] = utils.deep_copy(value)
  end

  for key, value in pairs(override) do
    if type(value) == 'table' and type(result[key]) == 'table' then
      result[key] = extend(result[key], value)
    else
      result[key] = utils.deep_copy(value)
    end
  end

  return result
end

local function set_terminal_colors(palette)
  if not palette.ansi then
    return
  end

  vim.g.terminal_color_0 = palette.ansi.black
  vim.g.terminal_color_1 = palette.ansi.red
  vim.g.terminal_color_2 = palette.ansi.green
  vim.g.terminal_color_3 = palette.ansi.yellow
  vim.g.terminal_color_4 = palette.ansi.blue
  vim.g.terminal_color_5 = palette.ansi.magenta
  vim.g.terminal_color_6 = palette.ansi.cyan
  vim.g.terminal_color_7 = palette.ansi.white
  vim.g.terminal_color_8 = palette.ansi.brightBlack
  vim.g.terminal_color_9 = palette.ansi.brightRed
  vim.g.terminal_color_10 = palette.ansi.brightGreen
  vim.g.terminal_color_11 = palette.ansi.brightYellow
  vim.g.terminal_color_12 = palette.ansi.brightBlue
  vim.g.terminal_color_13 = palette.ansi.brightMagenta
  vim.g.terminal_color_14 = palette.ansi.brightCyan
  vim.g.terminal_color_15 = palette.ansi.brightWhite

  vim.g.terminal_color_background = palette.background
  vim.g.terminal_color_foreground = palette.foreground
end

local function highlight(group, values)
  vim.api.nvim_set_hl(0, group, values)
end

local function apply_highlights(palette, options)
  local bg = options.transparent and 'NONE' or palette.background
  local fallback = options.transparent and palette.line or palette.background

  local function norm(color)
    return utils.normalize_color(color, fallback)
  end

  highlight('Normal', { fg = norm(palette.foreground), bg = norm(bg) })
  highlight('NormalNC', { fg = norm(palette.foreground), bg = norm(bg) })
  highlight('LineNr', { fg = norm(palette.gutter), bg = norm(bg) })
  highlight('CursorLineNr', { fg = norm(palette.gutterActive), bg = norm(bg) })
  highlight('Cursor', { fg = norm(palette.background), bg = norm(palette.cursor) })
  highlight('CursorLine', { bg = norm(palette.line) })
  highlight('CursorColumn', { bg = norm(palette.line) })
  highlight('ColorColumn', { bg = norm(palette.commentBg) })
  highlight('Visual', { bg = norm(palette.selection) })
  highlight('Search', { bg = norm(palette.match), fg = norm(palette.background) })
  highlight('IncSearch', { bg = norm(palette.match), fg = norm(palette.background) })
  highlight('MatchParen', { fg = norm(palette.accent), bg = norm(bg), bold = true })

  highlight('Pmenu', { fg = norm(palette.foreground), bg = norm(palette.menu) })
  highlight('PmenuSel', { fg = norm(palette.foreground), bg = norm(palette.menuSelection) })
  highlight('PmenuSbar', { bg = norm(utils.shade(norm(palette.menu), 0.15, palette.background)) })
  highlight('PmenuThumb', { bg = norm(utils.shade(norm(palette.menuSelection), 0.2, palette.background)) })
  highlight('FloatBorder', { fg = norm(palette.border), bg = norm(palette.menu) })
  highlight('NormalFloat', { fg = norm(palette.foreground), bg = norm(palette.menu) })

  highlight('Whitespace', { fg = norm(palette.comment) })
  highlight('NonText', { fg = norm(palette.comment) })
  highlight('Comment', { fg = norm(palette.comment), italic = options.italics.comments })
  highlight('Todo', { fg = norm(palette.accent), bold = true })

  highlight('Identifier', { fg = norm(palette.foreground) })
  highlight('Function', { fg = norm(palette.func), italic = options.italics.functions })
  highlight('Statement', { fg = norm(palette.keyword), italic = options.italics.keywords })
  highlight('Keyword', { fg = norm(palette.keyword), italic = options.italics.keywords })
  highlight('Operator', { fg = norm(palette.operator) })
  highlight('Type', { fg = norm(palette.type) })
  highlight('Constant', { fg = norm(palette.constant) })
  highlight('Number', { fg = norm(palette.number) })
  highlight('String', { fg = norm(palette.string), italic = options.italics.strings })
  highlight('Character', { fg = norm(palette.string) })
  highlight('Boolean', { fg = norm(palette.number) })

  highlight('Error', { fg = norm(palette.error) })
  highlight('ErrorMsg', { fg = norm(palette.error) })
  highlight('WarningMsg', { fg = norm(palette.warning) })
  highlight('DiagnosticError', { fg = norm(palette.error) })
  highlight('DiagnosticWarn', { fg = norm(palette.warning) })
  highlight('DiagnosticInfo', { fg = norm(palette.info) })
  highlight('DiagnosticHint', { fg = norm(palette.accent) })
  highlight('DiagnosticUnderlineError', { sp = norm(palette.error), undercurl = true })
  highlight('DiagnosticUnderlineWarn', { sp = norm(palette.warning), undercurl = true })
  highlight('DiagnosticUnderlineInfo', { sp = norm(palette.info), undercurl = true })
  highlight('DiagnosticUnderlineHint', { sp = norm(palette.accent), undercurl = true })

  highlight('DiffAdd', { fg = norm(palette.string), bg = norm(bg) })
  highlight('DiffChange', { fg = norm(palette.keyword), bg = norm(bg) })
  highlight('DiffDelete', { fg = norm(palette.error), bg = norm(bg) })
  highlight('DiffText', { fg = norm(palette.warning), bg = norm(bg) })

  local status_bg = norm(utils.shade(palette.menu, 0.12, palette.background))
  local status_fg = norm(palette.foreground)
  local inactive_bg = norm(bg)

  highlight('StatusLine', { fg = status_fg, bg = status_bg, bold = true })
  highlight('StatusLineNC', { fg = norm(palette.gutter), bg = status_bg })
  highlight('WinSeparator', { fg = norm(palette.border), bg = inactive_bg })
  highlight('VertSplit', { fg = norm(palette.border), bg = inactive_bg })
  highlight('TabLine', { fg = norm(palette.gutter), bg = inactive_bg })
  highlight('TabLineSel', { fg = status_fg, bg = norm(palette.line) })
  highlight('StatusLineTerm', { fg = status_fg, bg = norm(palette.cursor) })
  highlight('StatusLineTermNC', { fg = norm(palette.gutter), bg = norm(palette.background) })

  highlight('LualineNormal', { fg = status_fg, bg = status_bg })
  highlight('LualineInsert', { fg = norm(palette.background), bg = norm(palette.string) })
  highlight('LualineVisual', { fg = norm(palette.background), bg = norm(palette.accent) })
  highlight('LualineReplace', { fg = norm(palette.background), bg = norm(palette.warning) })
  highlight('LualineCommand', { fg = norm(palette.background), bg = norm(palette.keyword) })
  highlight('LualineTerminal', { fg = norm(palette.background), bg = norm(palette.info) })
  highlight('LualineInactive', { fg = norm(palette.gutter), bg = inactive_bg })

  highlight('HeirlineStatusLine', { fg = status_fg, bg = status_bg })
  highlight('HeirlineBufferInfo', { fg = norm(palette.constant), bg = norm(palette.line) })
  highlight('HeirlineBufferInactive', { fg = norm(palette.gutter), bg = inactive_bg })

  highlight('GitSignsAdd', { fg = norm(palette.string) })
  highlight('GitSignsChange', { fg = norm(palette.warning) })
  highlight('GitSignsDelete', { fg = norm(palette.error) })

  highlight('@comment', { fg = norm(palette.comment), italic = options.italics.comments })
  highlight('@variable', { fg = norm(palette.variable), italic = options.italics.variables })
  highlight('@function', { fg = norm(palette.func), italic = options.italics.functions })
  highlight('@parameter', { fg = norm(palette.variable), italic = options.italics.variables })
  highlight('@type', { fg = norm(palette.type) })
  highlight('@constant', { fg = norm(palette.constant) })
  highlight('@number', { fg = norm(palette.number) })
  highlight('@string', { fg = norm(palette.string) })
  highlight('@keyword', { fg = norm(palette.keyword), italic = options.italics.keywords })
  highlight('@operator', { fg = norm(palette.operator) })
  highlight('@tag', { fg = norm(palette.keyword) })
end

local function get_palette(name)
  return palettes[name] or palettes['moegi-' .. name]
end

function M.setup(options)
  config = setmetatable(config, { __index = extend(config.defaults, options or {}) })
end

function M.load(name)
  local selected = name or config.theme
  local palette = get_palette(selected)

  if not palette then
    vim.notify(('moegi: unknown theme "%s"'):format(selected), vim.log.levels.ERROR)
    return
  end

  local current = extend(palette, config.overrides)

  vim.api.nvim_command('hi clear')
  if vim.fn.exists('syntax_on') == 1 then
    vim.api.nvim_command('syntax reset')
  end

  vim.o.termguicolors = true
  vim.g.colors_name = 'moegi'

  set_terminal_colors(current)
  apply_highlights(current, config.italics)
end

return M
