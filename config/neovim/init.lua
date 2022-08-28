require("onedarkpro").setup({
	theme = "onedark_dark",
})

require("nvim-treesitter.configs").setup({
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
