return {
	{
	'seandewar/killersheep.nvim',
	version = '*',
	enabled = true,
	config = function()
	require("killersheep").setup {
	  gore = true,           -- Enables/disables blood and gore.
	  keymaps = {
	    move_left = "k",     -- Keymap to move cannon to the left.
	    move_right = "l",    -- Keymap to move cannon to the right.
	    shoot = "<Space>",   -- Keymap to shoot the cannon.
	  },
	}
	end,
	}
}
