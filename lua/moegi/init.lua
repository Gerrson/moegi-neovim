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

  highlight('Normal', { fg = palette.foreground, bg = bg })
  highlight('NormalNC', { fg = palette.foreground, bg = bg })
  highlight('LineNr', { fg = palette.gutter, bg = bg })
  highlight('CursorLineNr', { fg = palette.gutterActive, bg = bg })
  highlight('Cursor', { fg = palette.background, bg = palette.cursor })
  highlight('CursorLine', { bg = palette.line })
  highlight('CursorColumn', { bg = palette.line })
  highlight('ColorColumn', { bg = palette.commentBg })
  highlight('Visual', { bg = palette.selection })
  highlight('Search', { bg = palette.match, fg = palette.background })
  highlight('IncSearch', { bg = palette.match, fg = palette.background })
  highlight('MatchParen', { fg = palette.accent, bg = bg, bold = true })

  highlight('Pmenu', { fg = palette.foreground, bg = palette.menu })
  highlight('PmenuSel', { fg = palette.foreground, bg = palette.menuSelection })
  highlight('PmenuSbar', { bg = utils.shade(palette.menu, 0.15, palette.background) })
  highlight('PmenuThumb', { bg = utils.shade(palette.menuSelection, 0.2, palette.background) })
  highlight('FloatBorder', { fg = palette.border, bg = palette.menu })
  highlight('NormalFloat', { fg = palette.foreground, bg = palette.menu })

  highlight('Whitespace', { fg = palette.comment })
  highlight('NonText', { fg = palette.comment })
  highlight('Comment', { fg = palette.comment, italic = options.italics.comments })
  highlight('Todo', { fg = palette.accent, bold = true })

  highlight('Identifier', { fg = palette.foreground })
  highlight('Function', { fg = palette.func, italic = options.italics.functions })
  highlight('Statement', { fg = palette.keyword, italic = options.italics.keywords })
  highlight('Keyword', { fg = palette.keyword, italic = options.italics.keywords })
  highlight('Operator', { fg = palette.operator })
  highlight('Type', { fg = palette.type })
  highlight('Constant', { fg = palette.constant })
  highlight('Number', { fg = palette.number })
  highlight('String', { fg = palette.string, italic = options.italics.strings })
  highlight('Character', { fg = palette.string })
  highlight('Boolean', { fg = palette.number })

  highlight('Error', { fg = palette.error })
  highlight('ErrorMsg', { fg = palette.error })
  highlight('WarningMsg', { fg = palette.warning })
  highlight('DiagnosticError', { fg = palette.error })
  highlight('DiagnosticWarn', { fg = palette.warning })
  highlight('DiagnosticInfo', { fg = palette.info })
  highlight('DiagnosticHint', { fg = palette.accent })
  highlight('DiagnosticUnderlineError', { sp = palette.error, undercurl = true })
  highlight('DiagnosticUnderlineWarn', { sp = palette.warning, undercurl = true })
  highlight('DiagnosticUnderlineInfo', { sp = palette.info, undercurl = true })
  highlight('DiagnosticUnderlineHint', { sp = palette.accent, undercurl = true })

  highlight('DiffAdd', { fg = palette.string, bg = bg })
  highlight('DiffChange', { fg = palette.keyword, bg = bg })
  highlight('DiffDelete', { fg = palette.error, bg = bg })
  highlight('DiffText', { fg = palette.warning, bg = bg })

  highlight('StatusLine', { fg = palette.foreground, bg = bg })
  highlight('StatusLineNC', { fg = palette.gutter, bg = bg })
  highlight('WinSeparator', { fg = palette.border, bg = bg })
  highlight('VertSplit', { fg = palette.border, bg = bg })
  highlight('TabLine', { fg = palette.gutter, bg = bg })
  highlight('TabLineSel', { fg = palette.foreground, bg = palette.line })

  highlight('GitSignsAdd', { fg = palette.string })
  highlight('GitSignsChange', { fg = palette.warning })
  highlight('GitSignsDelete', { fg = palette.error })

  highlight('@comment', { fg = palette.comment, italic = options.italics.comments })
  highlight('@variable', { fg = palette.variable, italic = options.italics.variables })
  highlight('@function', { fg = palette.func, italic = options.italics.functions })
  highlight('@parameter', { fg = palette.variable, italic = options.italics.variables })
  highlight('@type', { fg = palette.type })
  highlight('@constant', { fg = palette.constant })
  highlight('@number', { fg = palette.number })
  highlight('@string', { fg = palette.string })
  highlight('@keyword', { fg = palette.keyword, italic = options.italics.keywords })
  highlight('@operator', { fg = palette.operator })
  highlight('@tag', { fg = palette.keyword })
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
