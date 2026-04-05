return
{
	{'registerGen/clock.nvim',
	version='*',
	config = function()
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
	end,
	},
}
