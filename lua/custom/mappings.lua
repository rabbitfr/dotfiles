---@type MappingsTable
local M = {}

M.general = {
	n = {
		[";"] = { ":", "enter command mode", opts = { nowait = true } },

		-- window management
		["<leader>sv"] = { "<C-w>v", "Split window vertically" },
		["<leader>sh"] = { "<C-w>s", "Split window horizontally" },
		["<leader>se"] = { "<C-w>=", "Make splits equal size" },
		["<leader>sx"] = { "<cmd>close<CR>", "Close current split" },

		-- tab management
		["<leader>to"] = { "<cmd>tabnew<CR>", "Open new tab" },
		["<leader>tx"] = { "<cmd>tabclose<CR>", "Close current tab" },
		["<leader>tn"] = { "<cmd>tabn<CR>", "Go to next tab" },
		["<leader>tp"] = { "<cmd>tabp<CR>", "Go to previous tab" },
		["<leader>tf"] = { "<cmd>tabnew %<CR>", "Open current buffer in new tab" },

    -- maximize split 
		["<leader>sm"] = { "<cmd>MaximizerToggle<CR>", "Maximize/minimize a split" },
	},

	v = {
		[">"] = { ">gv", "indent" },
	},
}

-- more keybinds!

return M
