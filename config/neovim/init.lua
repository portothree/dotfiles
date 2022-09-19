require("onedarkpro").setup({
	theme = "onedark_dark",
})

-- Defines a rw for treesitter in the cache dir
local parser_install_dir = vim.fn.stdpath("cache") .. "/treesitters"
vim.fn.mkdir(parser_install_dir, "p")

require("nvim-treesitter.configs").setup({
	parser_install_dir = parser_install_dir,
	ensure_installed = {
		"bash",
		"typescript",
		"javascript",
		"json",
		"ledger",
		"lua",
		"markdown",
		"nix",
		"python",
		"rust",
		"vim",
		"yaml",
	},
})
