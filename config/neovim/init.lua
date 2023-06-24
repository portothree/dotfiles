require("onedarkpro").setup({
	theme = "onedark_dark",
})

-- Defines a rw for treesitter in the cache dir
local parser_install_dir = vim.fn.stdpath("cache") .. "/treesitters"
vim.fn.mkdir(parser_install_dir, "p")
vim.opt.runtimepath:append(parser_install_dir)

require("nvim-treesitter.configs").setup({
	parser_install_dir = parser_install_dir,
	ensure_installed = {
		"bash",
		"c",
		"javascript",
		"jsdoc",
		"typescript",
		"tsx",
		"json",
		"jq",
		"html",
		"graphql",
		"gitcommit",
		"elm",
		"dockerfile",
		"vim",
		"diff",
		"ledger",
		"lua",
		"markdown",
		"nix",
		"python",
		"rust",
		"haskell",
		"perl",
		"terraform",
		"vim",
		"yaml",
		"prisma",
		"sql",
		"mermaid"
	},
})
