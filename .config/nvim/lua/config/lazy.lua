-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
   os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

local hipatterns = require('mini.hipatterns')
hipatterns.setup({
  highlighters = {
    -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
    fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
    hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
    todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
    note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
-- Next buffer
vim.keymap.set('n', '<Tab>', '<Cmd>bnext<CR>', { silent = true })

-- Previous buffer
vim.keymap.set('n', '<S-Tab>', '<Cmd>bprevious<CR>', { silent = true })

-- Previous buffer
vim.keymap.set('n', '<S-c>', '<Cmd>bd<CR>', { silent = true })

require("clock").setup(
{
  auto_start = false,
  float = {
    border = "single",
    col_offset = 1,
    padding = { 0, 0, 0, 0 }, -- left, right, top, bottom padding, respectively
    position = "top", -- or "top"
    row_offset = 0,
    zindex = 10,
  },
  font = {
    -- the "font" of the clock text
    -- see lua/clock/config.lua for details
  },
  -- fun(c: string, time: string, position: integer): string
  -- <c> is the character to be highlighted
  -- <time> is the time represented in a string
  -- <position> is the position of <c> in <time>
  hl_group = function(c, time, position)
    return "NormalText"
  end,
  -- nil | fun(c: string, time: string, position: integer, pixel_row: integer, pixel_col: integer): string
  -- This function has higher priority than hl_group.
  hl_group_pixel = nil,
  separator = "  ", -- separator of two characters
  separator_hl = "NormalText",
  time_format = "%H:%M",
  update_time = 500, -- update the clock text once per <update_time> (in ms)
}
)
local async = require "plenary.async"

require("theme.framework").setup()
require('mini.basics').setup()
require('mini.starter').setup()
require('mini.animate').setup()
require('mini.extra').setup()
require('mini.git').setup()
require('mini.notify').setup()
require('mini.diff').setup()
require('mini.colors').setup()
require('mini.indentscope').setup()
require('mini.trailspace').setup()
require('mini.cmdline').setup()
require('mini.tabline').setup()
require('mini.map').setup()
require('mini.icons').setup()
require('mini.keymap').setup()
--require('mini.statusline').setup()
local battery = require("battery")
battery.setup({
    update_rate_seconds = 30,           -- Number of seconds between checking battery status
    show_status_when_no_battery = true, -- Don't show any icon or text when no battery found (desktop for example)
    show_plugged_icon = true,           -- If true show a cable icon alongside the battery icon when plugged in
    show_unplugged_icon = true,         -- When true show a diconnected cable icon when not plugged in
    show_percent = true,                -- Whether or not to show the percent charge remaining in digits
    vertical_icons = true,              -- When true icons are vertical, otherwise shows horizontal battery icon
    multiple_battery_selection = 1,     -- Which battery to choose when multiple found. "max" or "maximum", "min" or "minimum" or a number to pick the nth battery found (currently linux acpi only)
})

local statusline = require("mini.statusline")

statusline.setup({
  content = {
    active = function()
      local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
      local git           = statusline.section_git({ trunc_width = 75 })
      local diagnostics   = statusline.section_diagnostics({ trunc_width = 75 })
      local filename      = statusline.section_filename({ trunc_width = 140 })
      local fileinfo      = statusline.section_fileinfo({ trunc_width = 120 })
      local location      = statusline.section_location({ trunc_width = 75 })

      -- Battery component
      local battery = require("battery").get_status_line()

      return statusline.combine_groups({
        { hl = mode_hl,                 strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
        "%<", -- truncate point
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=",
        { hl = "MiniStatuslineFileinfo", strings = { battery, fileinfo } },
        { hl = mode_hl,                 strings = { location } },
      })
    end,
  },
})

require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})


require('nvim-treesitter').setup {
  -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
  install_dir = vim.fn.stdpath('data') .. '/site'
}

require('nvim-treesitter').install { 'rust', 'javascript', 'zig' }
