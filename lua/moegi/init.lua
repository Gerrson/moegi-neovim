local config = require('moegi.config')
local palettes = require('moegi.palettes')
local utils = require('moegi.utils')

local M = {}

-- Local aliases for speed
local api = vim.api
local opt = vim.opt
local g = vim.g

---@param target table
---@param override table
---@return table
local function extend(target, override)
    if type(override) ~= 'table' then return override or target end
    local result = utils.deep_copy(target or {})
    for k, v in pairs(override) do
        if type(v) == 'table' and type(result[k]) == 'table' then
            result[k] = extend(result[k], v)
        else
            result[k] = utils.deep_copy(v)
        end
    end
    return result
end

---@param palette table
local function set_terminal_colors(palette)
    if not palette.ansi then return end

    local colors = {
        palette.ansi.black, palette.ansi.red, palette.ansi.green, palette.ansi.yellow,
        palette.ansi.blue, palette.ansi.magenta, palette.ansi.cyan, palette.ansi.white,
        palette.ansi.brightBlack, palette.ansi.brightRed, palette.ansi.brightGreen,
        palette.ansi.brightYellow, palette.ansi.brightBlue, palette.ansi.brightMagenta,
        palette.ansi.brightCyan, palette.ansi.brightWhite
    }

    for i, color in ipairs(colors) do
        g["terminal_color_" .. (i - 1)] = color
    end

    g.terminal_color_background = palette.background
    g.terminal_color_foreground = palette.foreground
end

---@param palette table
---@param cfg table
local function apply_highlights(palette, cfg)
    local bg = cfg.transparent and 'NONE' or palette.background
    local fallback = cfg.transparent and palette.line or palette.background

    -- Local helper to avoid repeating normalization logic
    local function n(color) return utils.normalize_color(color, fallback) end

    -- Definition of highlighting groups
    local groups = {
        -- UI Core
        Normal       = { fg = n(palette.foreground), bg = n(bg) },
        NormalNC     = { fg = n(palette.foreground), bg = n(bg) },
        LineNr       = { fg = n(palette.gutter), bg = n(bg) },
        CursorLineNr = { fg = n(palette.gutterActive), bg = n(bg) },
        Cursor       = { fg = n(palette.background), bg = n(palette.cursor) },
        CursorLine   = { bg = n(palette.line) },
        Visual       = { bg = n(palette.selection) },
        Search       = { bg = n(palette.match), fg = n(palette.background) },
        MatchParen   = { fg = n(palette.accent), bg = n(bg), bold = true },
        FloatBorder  = { fg = n(palette.border), bg = n(palette.menu) },
        NormalFloat  = { fg = n(palette.foreground), bg = n(palette.menu) },

        -- Syntax
        Comment      = { fg = n(palette.comment), italic = cfg.italics.comments },
        Keyword      = { fg = n(palette.keyword), italic = cfg.italics.keywords },
        Function     = { fg = n(palette.func), italic = cfg.italics.functions },
        String       = { fg = n(palette.string), italic = cfg.italics.strings },
        Identifier   = { fg = n(palette.foreground) },
        Type         = { fg = n(palette.type) },
        Constant     = { fg = n(palette.constant) },
        Number       = { fg = n(palette.number) },
        Operator     = { fg = n(palette.operator) },

        -- Treesitter (Modern syntax)
        ["@variable"]  = { fg = n(palette.variable), italic = cfg.italics.variables },
        ["@parameter"] = { fg = n(palette.variable), italic = cfg.italics.variables },
        ["@comment"]   = { link = "Comment" },
        ["@keyword"]   = { link = "Keyword" },
        ["@function"]  = { link = "Function" },
        ["@string"]    = { link = "String" },

        -- LSP Diagnostics
        DiagnosticError = { fg = n(palette.error) },
        DiagnosticWarn  = { fg = n(palette.warning) },
        DiagnosticInfo  = { fg = n(palette.info) },
        DiagnosticHint  = { fg = n(palette.accent) },
        DiagnosticUnderlineError = { sp = n(palette.error), undercurl = true },

        -- Git
        GitSignsAdd    = { fg = n(palette.string) },
        GitSignsChange = { fg = n(palette.warning) },
        GitSignsDelete = { fg = n(palette.error) },
    }

    -- Apply all groups in a single loop
    for group, settings in pairs(groups) do
        api.nvim_set_hl(0, group, settings)
    end
end

function M.setup(options)
    config.defaults = extend(config.defaults, options or {})
end

function M.load(theme_name)
    local selected = theme_name or config.theme
    local palette = palettes[selected] or palettes['moegi-' .. selected]

    if not palette then
        api.nvim_err_writeln('moegi: unknown theme "' .. tostring(selected) .. '"')
        return
    end

    local current = extend(palette, config.overrides)

    if vim.g.colors_name then api.nvim_command('hi clear') end

    opt.termguicolors = true
    g.colors_name = 'moegi'

    set_terminal_colors(current)
    apply_highlights(current, config.defaults)
end

return M
