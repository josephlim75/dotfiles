-- call plug#begin()

-- Plug 'vim-airline/vim-airline'
-- Plug 'vim-airline/vim-airline-themes'

-- call plug#end()

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.cmd("set cursorline")

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

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

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			"LazyVim/LazyVim",
			import = "lazyvim.plugins",
		},
		{ import = "plugins" }, -- This line imports all files in lua/plugins
		-- {
		-- 	"nvim-telescope/telescope.nvim",
		-- 	tag = "0.1.8",
		-- 	dependencies = { "nvim-lua/plenary.nvim" },
		-- },
		--{ "nvim-treesitter/nvim-treesitter", branch = "master", lazy = false, build = ":TSUpdate" }
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	--  install = { colorscheme = { "catpuccin" } },
	-- automatically check for plugin updates
	defaults = {
		lazy = false, -- every plugin is lazy-loaded by default
		version = false, -- always use the latest git commit
	},
	checker = { enabled = true },
})

--require("catppuccin").setup()
--vim.cmd.colorscheme("catppuccin-frappe")
--vim.cmd.colorscheme("tokyonight")
-- vim.cmd.colorscheme("material-deep-ocean")
vim.cmd.colorscheme("nord")

-- Telescope
-- local builtin = require("telescope.builtin")
-- vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
-- vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
-- vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
-- vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

-- Treesitter
-- local config = require("nvim-treesitter.configs")
-- config.setup({
-- 	-- A list of parser names, or "all" (the listed parsers MUST always be installed)
-- 	ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
-- 	highlight = { enable = true },
-- 	indent = { enable = true },
-- })

-- -- Statusbar lualine
--require("lualine").setup()

-- vim.cmd("highlight CursorLine guibg=DarkGrey ctermbg=DarkGrey")
