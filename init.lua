local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2
-- Line numbers
vim.opt.number = true
-- Centered search navigation
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Disable diagnostics
vim.diagnostic.enable(false)

-- R directive highlighting (#> comments)
vim.api.nvim_set_hl(0, "@keyword.directive.r", { fg = "#7A7A7A", bold = true })

if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with plugins
require("lazy").setup({
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			ensure_installed = { "vim", "lua", "vimdoc", "html", "css", "go", "javascript", "r", "c" },
			highlight = { enable = true },
		},
	},
	{
		"devOpifex/veem",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("veem")
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>fw", builtin.live_grep, { desc = "Telescope live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- optional but recommended
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
	},

	-- File tree
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
		},
		opts = {
			view = {
				width = 30,
			},
			filters = {
				dotfiles = false,
				custom = {},
				git_ignored = false,
			},
			renderer = {
				icons = {
					show = {
						file = true,
						folder = true,
						folder_arrow = false,
						git = false,
					},
				},
			},
			git = {
				enable = false,
			},
		},
	},
	-- Mason: LSP server installer
	{
		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason.nvim" },
		opts = {
			ensure_installed = { "gopls", "ts_ls" },
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason.nvim" },
		opts = {
			ensure_installed = { "eslint_d", "prettier" },
		},
	},

	-- LSP configuration (nvim 0.11+ native API)
	{
		"neovim/nvim-lspconfig",
		dependencies = { "mason-lspconfig.nvim", "blink.cmp" },
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			vim.lsp.config("gopls", { capabilities = capabilities })
			vim.lsp.config("ts_ls", { capabilities = capabilities })

			-- R language server (formatting disabled, air handles it)
			vim.lsp.config("r_language_server", {
				capabilities = capabilities,
				on_attach = function(client, _)
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
				end,
			})

			-- Air formatter for R (with 3s timeout for format-on-save)
			vim.lsp.config("air", {
				capabilities = capabilities,
				on_attach = function(_, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ timeout_ms = 3000 })
						end,
					})
				end,
			})

			vim.lsp.enable({ "gopls", "ts_ls", "r_language_server", "air" })
		end,
	},

	-- Supermaven AI completion (ghost text, Alt+x to accept)
	{
		"supermaven-inc/supermaven-nvim",
		opts = {
			keymaps = {
				accept_suggestion = "<M-x>",
			},
		},
	},

	-- Completion
	{
		"saghen/blink.cmp",
		version = "*",
		opts = {
			keymap = {
				preset = "none",
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<C-Space>"] = { "show" },
				["<C-e>"] = { "hide" },
			},
			completion = {
				list = {
					selection = { preselect = true, auto_insert = false },
				},
			},
			sources = {
				default = { "lsp", "path", "buffer" },
			},
		},
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "eslint_d" },
				css = { "prettier" },
			},
			format_on_save = {
				timeout_ms = 2000,
				lsp_fallback = false,
			},
		},
	},
})
