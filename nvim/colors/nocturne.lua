-- Nocturne for Neovim. Colours come from lua/nocturne/palette.lua, which
-- nocturne/build generates from nocturne/palette.toml. The syntax mapping
-- matches Zed and the terminal: keywords iris, strings green, functions blue,
-- numbers and constants gold, types foam, comments faint.

local p = require("nocturne.palette")

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end
vim.o.background = "dark"
vim.g.colors_name = "nocturne"

--- Mix two #rrggbb colours: amount 0 gives a, 1 gives b.
local function mix(a, b, amount)
    local function channel(hex, i)
        return tonumber(hex:sub(i, i + 1), 16)
    end
    local out = {}
    for _, i in ipairs({ 2, 4, 6 }) do
        out[#out + 1] = math.floor(channel(a, i) * (1 - amount) + channel(b, i) * amount + 0.5)
    end
    return string.format("#%02x%02x%02x", out[1], out[2], out[3])
end

local c = {
    ink0 = p["ink-0"],
    ink1 = p["ink-1"],
    ink2 = p["ink-2"],
    ink3 = p["ink-3"],
    line = p.line,
    faint = p.faint,
    muted = p.muted,
    text = p.text,
    bright = p.bright,
    accent = p.accent,
    accent_dim = p["accent-dim"],
    red = p.red,
    gold = p.gold,
    green = p.green,
    blue = p.blue,
    foam = p.foam,
    iris = p.iris,
    red_bg = p["red-bg"],
    green_bg = p["green-bg"],
}
c.number = mix(c.line, c.faint, 0.45) -- line numbers: present, never loud

local groups = {
    -- Editor
    Normal = { fg = c.text, bg = c.ink1 },
    NormalNC = { fg = c.text, bg = c.ink1 },
    NormalFloat = { fg = c.text, bg = c.ink2 },
    FloatBorder = { fg = c.line, bg = c.ink2 },
    FloatTitle = { fg = c.bright, bg = c.ink2 },
    Cursor = { fg = c.ink1, bg = c.accent },
    CursorLine = { bg = c.ink2 },
    CursorColumn = { bg = c.ink2 },
    ColorColumn = { bg = c.ink2 },
    LineNr = { fg = c.number },
    CursorLineNr = { fg = c.text },
    SignColumn = { fg = c.faint },
    FoldColumn = { fg = c.faint },
    Folded = { fg = c.muted, bg = c.ink2 },
    WinSeparator = { fg = c.ink3 },
    VertSplit = { fg = c.ink3 },
    StatusLine = { fg = c.muted, bg = c.ink0 },
    StatusLineNC = { fg = c.faint, bg = c.ink0 },
    TabLine = { fg = c.faint, bg = c.ink0 },
    TabLineFill = { bg = c.ink0 },
    TabLineSel = { fg = c.bright, bg = c.ink1 },
    WinBar = { fg = c.muted },
    WinBarNC = { fg = c.faint },
    Pmenu = { fg = c.text, bg = c.ink2 },
    PmenuSel = { fg = c.bright, bg = c.ink3 },
    PmenuSbar = { bg = c.ink2 },
    PmenuThumb = { bg = c.line },
    PmenuMatch = { fg = c.accent },
    PmenuMatchSel = { fg = c.accent },
    WildMenu = { fg = c.bright, bg = c.ink3 },
    Visual = { bg = c.accent_dim },
    Search = { fg = c.bright, bg = c.accent_dim },
    IncSearch = { fg = c.ink1, bg = c.accent },
    CurSearch = { fg = c.ink1, bg = c.accent },
    Substitute = { fg = c.ink1, bg = c.gold },
    MatchParen = { fg = c.bright, bg = c.ink3 },
    NonText = { fg = c.line },
    Whitespace = { fg = c.ink3 },
    SpecialKey = { fg = c.line },
    EndOfBuffer = { fg = c.ink1 },
    Conceal = { fg = c.faint },
    Directory = { fg = c.blue },
    Title = { fg = c.bright, bold = true },
    ErrorMsg = { fg = c.red },
    WarningMsg = { fg = c.gold },
    MoreMsg = { fg = c.green },
    Question = { fg = c.green },
    ModeMsg = { fg = c.muted },
    MsgArea = { fg = c.text },
    QuickFixLine = { bg = c.ink3 },
    DiffAdd = { bg = c.green_bg },
    DiffDelete = { fg = c.red, bg = c.red_bg },
    DiffChange = { bg = c.ink2 },
    DiffText = { bg = c.ink3 },
    Added = { fg = c.green },
    Changed = { fg = c.gold },
    Removed = { fg = c.red },
    SpellBad = { sp = c.red, undercurl = true },
    SpellCap = { sp = c.gold, undercurl = true },
    SpellLocal = { sp = c.blue, undercurl = true },
    SpellRare = { sp = c.iris, undercurl = true },

    -- Syntax
    Comment = { fg = c.faint },
    Constant = { fg = c.gold },
    String = { fg = c.green },
    Character = { fg = c.green },
    Number = { fg = c.gold },
    Boolean = { fg = c.gold },
    Float = { fg = c.gold },
    Identifier = { fg = c.text },
    Function = { fg = c.blue },
    Statement = { fg = c.iris },
    Conditional = { fg = c.iris },
    Repeat = { fg = c.iris },
    Label = { fg = c.gold },
    Operator = { fg = c.muted },
    Keyword = { fg = c.iris },
    Exception = { fg = c.iris },
    PreProc = { fg = c.iris },
    Include = { fg = c.iris },
    Define = { fg = c.iris },
    Macro = { fg = c.iris },
    PreCondit = { fg = c.iris },
    Type = { fg = c.foam },
    StorageClass = { fg = c.iris },
    Structure = { fg = c.foam },
    Typedef = { fg = c.foam },
    Special = { fg = c.foam },
    SpecialChar = { fg = c.foam },
    Tag = { fg = c.blue },
    Delimiter = { fg = c.muted },
    SpecialComment = { fg = c.faint },
    Debug = { fg = c.red },
    Underlined = { underline = true },
    Error = { fg = c.red },
    Todo = { fg = c.gold, bold = true },

    -- Tree-sitter
    ["@variable"] = { fg = c.text },
    ["@variable.builtin"] = { fg = c.iris },
    ["@variable.parameter"] = { fg = c.text },
    ["@variable.member"] = { fg = c.text },
    ["@constant"] = { fg = c.gold },
    ["@constant.builtin"] = { fg = c.gold },
    ["@module"] = { fg = c.text },
    ["@label"] = { fg = c.gold },
    ["@string"] = { fg = c.green },
    ["@string.escape"] = { fg = c.foam },
    ["@string.regexp"] = { fg = c.foam },
    ["@string.special"] = { fg = c.foam },
    ["@character"] = { fg = c.green },
    ["@number"] = { fg = c.gold },
    ["@boolean"] = { fg = c.gold },
    ["@type"] = { fg = c.foam },
    ["@type.builtin"] = { fg = c.foam },
    ["@attribute"] = { fg = c.gold },
    ["@property"] = { fg = c.text },
    ["@function"] = { fg = c.blue },
    ["@function.builtin"] = { fg = c.blue },
    ["@function.call"] = { fg = c.blue },
    ["@function.method"] = { fg = c.blue },
    ["@function.method.call"] = { fg = c.blue },
    ["@constructor"] = { fg = c.foam },
    ["@operator"] = { fg = c.muted },
    ["@keyword"] = { fg = c.iris },
    ["@keyword.return"] = { fg = c.iris },
    ["@punctuation"] = { fg = c.muted },
    ["@punctuation.delimiter"] = { fg = c.faint },
    ["@punctuation.bracket"] = { fg = c.muted },
    ["@punctuation.special"] = { fg = c.iris },
    ["@comment"] = { fg = c.faint },
    ["@tag"] = { fg = c.blue },
    ["@tag.attribute"] = { fg = c.gold },
    ["@tag.delimiter"] = { fg = c.faint },
    ["@markup.heading"] = { fg = c.bright, bold = true },
    ["@markup.strong"] = { bold = true },
    ["@markup.italic"] = { italic = true },
    ["@markup.link"] = { fg = c.blue },
    ["@markup.link.url"] = { fg = c.foam, underline = true },
    ["@markup.raw"] = { fg = c.green },
    ["@markup.list"] = { fg = c.accent },

    -- Diagnostics and LSP
    DiagnosticError = { fg = c.red },
    DiagnosticWarn = { fg = c.gold },
    DiagnosticInfo = { fg = c.blue },
    DiagnosticHint = { fg = c.faint },
    DiagnosticOk = { fg = c.green },
    DiagnosticUnderlineError = { sp = c.red, undercurl = true },
    DiagnosticUnderlineWarn = { sp = c.gold, undercurl = true },
    DiagnosticUnderlineInfo = { sp = c.blue, undercurl = true },
    DiagnosticUnderlineHint = { sp = c.faint, undercurl = true },
    LspReferenceText = { bg = c.ink3 },
    LspReferenceRead = { bg = c.ink3 },
    LspReferenceWrite = { bg = c.ink3 },
    LspInlayHint = { fg = c.faint },
    LspSignatureActiveParameter = { fg = c.bright, bold = true },

    -- Git signs
    GitSignsAdd = { fg = c.green },
    GitSignsChange = { fg = c.gold },
    GitSignsDelete = { fg = c.red },

    -- File tree: the deepest surface, like Zed's panels.
    NeoTreeNormal = { fg = c.text, bg = c.ink0 },
    NeoTreeNormalNC = { fg = c.text, bg = c.ink0 },
    NeoTreeWinSeparator = { fg = c.ink0, bg = c.ink0 },
    NeoTreeEndOfBuffer = { fg = c.ink0, bg = c.ink0 },
    NeoTreeRootName = { fg = c.muted, bold = true },
    NeoTreeDirectoryName = { fg = c.text },
    NeoTreeDirectoryIcon = { fg = c.blue },
    NeoTreeGitModified = { fg = c.gold },
    NeoTreeGitAdded = { fg = c.green },
    NeoTreeGitDeleted = { fg = c.red },
    NeoTreeGitUntracked = { fg = c.faint },
    NeoTreeCursorLine = { bg = c.ink2 },

    -- Pickers and popups
    WhichKey = { fg = c.accent },
    WhichKeyGroup = { fg = c.blue },
    WhichKeyDesc = { fg = c.text },
    WhichKeySeparator = { fg = c.faint },
    SnacksPickerMatch = { fg = c.accent },
    TelescopeMatching = { fg = c.accent },
    TelescopeSelection = { fg = c.bright, bg = c.ink3 },
    TelescopeBorder = { fg = c.line, bg = c.ink2 },
    TelescopeNormal = { fg = c.text, bg = c.ink2 },
}

for group, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, group, spec)
end

-- The terminal inside Neovim uses the same sixteen colours as Ghostty.
local terminal = {
    c.ink3, c.red, c.green, c.gold, c.blue, c.iris, c.foam, c.muted,
    c.faint, p["red-bright"], p["green-bright"], p["gold-bright"],
    p["blue-bright"], p["iris-bright"], p["foam-bright"], c.bright,
}
for i, color in ipairs(terminal) do
    vim.g["terminal_color_" .. (i - 1)] = color
end
