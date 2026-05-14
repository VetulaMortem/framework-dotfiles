return {
	{
		enabled = true,
		'nvim-mini/mini.nvim',  
		version = '*', 
		config = function()
		require('mini.basics').setup()
		-- require('mini.starter').setup()
		require('mini.animate').setup()
		require('mini.extra').setup()
		require('mini.git').setup()
		require('mini.diff').setup()
		require('mini.colors').setup()
		-- require('mini.indentscope').setup()
		require('mini.trailspace').setup()
		require('mini.cmdline').setup()
		require('mini.tabline').setup()
		require('mini.map').setup()
		require('mini.icons').setup()
		require('mini.keymap').setup()
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
		local f = function(args) vim.b[args.buf].minitrailspace_disable = true end
		vim.api.nvim_create_autocmd('User', { pattern = 'SnacksDashboardOpened', callback = f })
		end,
	}

}
