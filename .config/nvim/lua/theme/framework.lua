local M = {}

function M.setup()
  vim.cmd("highlight clear")
  vim.o.termguicolors = true
  vim.g.colors_name = "framework_asuka"

  local hi = vim.api.nvim_set_hl

local p = {
  bg        = "#13121A",
  bg_alt    = "#0E5178",          -- Nutzen oft ein dunkles Grau/Secondary Background
  fg        = "#7CB2DE",
  red       = "#6C344B",          -- Standard-Rot in Themes
  orange    = "#5E5787",         -- Oder color3/color11 für Orange-Töne
  yellow    = "#5E5787",          -- Standard-Gelb
  blue      = "#5E223F",          -- Standard-Blau
  green     = "#747057",          -- Standard-Grün
  magenta   = "#787D86",          -- Standard-Magenta / Purple
  brown     = "#0D161F",  -- Falls du hier einen dunklen Erdton brauchst
  comment   = "#316A92",          -- Kommentare / Muted Text sind meistens color8 (bright black)
}

  -------------------------------------------------
  -- Base UI
  -------------------------------------------------
  hi(0, "Normal",       { fg = p.fg ,bg = p.bg})
  hi(0, "NormalFloat",  { fg = p.fg, bg = p.bg_alt })
  hi(0, "FloatBorder",  { fg = p.red, bg = p.bg_alt })
  hi(0, "WinSeparator", { fg = p.brown })

  hi(0, "CursorLine",   { bg = p.bg_alt })
  hi(0, "Visual",       { fg =p.fg ,bg = p.orange})

  hi(0, "StatusLine",   { fg = p.bg, bg = p.red, bold = true })
  hi(0, "StatusLineNC", { fg = p.comment, bg = p.bg_alt })

  -------------------------------------------------
  -- Lazy.nvim (fixes the pink issue)
  -------------------------------------------------
  hi(0, "LazyNormal", { fg = p.fg, bg = p.bg_alt })
  hi(0, "LazyButton", { fg = p.fg, bg = p.bg_alt })
  hi(0, "LazyH1",     { fg = p.orange, bold = true })
  hi(0, "LazySpecial",{ fg = p.red })

  -------------------------------------------------
  -- Syntax
  -------------------------------------------------
  hi(0, "Comment",  { fg = p.green, italic = true })
  hi(0, "String",   { fg = p.orange })
  hi(0, "Function", { fg = p.yellow })
  hi(0, "Keyword",  { fg = p.red, bold = true })
  hi(0, "Type",     { fg = p.magenta })
  hi(0, "Constant", { fg = p.orange })
  hi(0, "Number",   { fg = p.blue })
  hi(0, "Identifier",{ fg = p.fg })

  -------------------------------------------------
  -- Diagnostics
  -------------------------------------------------
  hi(0, "DiagnosticError", { fg = p.red })
  hi(0, "DiagnosticWarn",  { fg = p.yellow })
  hi(0, "DiagnosticInfo",  { fg = p.magenta })
  hi(0, "DiagnosticHint",  { fg = p.comment })

 -------------------------------------------------
  -- Mini
  -------------------------------------------------
  hi(0,"MiniTablineCurrent", {fg = p.blue,bg = p.orange , bold = true})

end

return M
