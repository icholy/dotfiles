vim.o.shell = "zsh"
vim.o.foldmethod = "indent"
vim.o.foldlevel = 100
vim.o.foldlevelstart = 100
vim.o.relativenumber = true
vim.o.number = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.breakindent = true
vim.cmd("set complete-=i")
vim.o.completeopt = "menu,menuone,noselect"
vim.o.autoindent = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.wrap = false
vim.o.backup = true
vim.opt.undofile = true
vim.cmd("set backupdir-=.")
vim.cmd("set backupdir^=~/tmp,/tmp")
vim.o.swapfile = false
vim.o.writebackup = false
vim.o.autoread = true
vim.o.mouse = "a"
-- vim.o.t_Co = 256
vim.o.termguicolors = true
vim.o.tgc = true
vim.o.timeoutlen = 300
vim.o.updatetime = 250
vim.o.background = "light"
vim.o.fixendofline = false
vim.o.cmdheight = 0
vim.o.clipboard=unnamedplus
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.listchars:append("tab:» ")
vim.opt.listchars:append("eol:¬")

local group = vim.api.nvim_create_augroup("MyGroup", { clear = true })

-- format go files on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = group,
	pattern = "*.go",
	callback = function () vim.lsp.buf.format() end,
})

-- automatically enter insert mode
vim.api.nvim_create_autocmd({"BufWinEnter", "WinEnter", "TermOpen"}, {
	command = "startinsert",
	pattern = "term://*",
})

-- don't auto-indent when typing ':'
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = {"yml", "yaml"},
	callback = function()
		vim.cmd("setlocal indentkeys-=<:>")
		vim.cmd("setlocal indentkeys-=:")
	end
})

-- setup lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"tpope/vim-fugitive",
		config = function()
			vim.g.fugitive_legacy_commands = false

			vim.keymap.set("n", "<Leader>gs", ":Git status<CR>")
			vim.keymap.set("n", "<Leader>gd", ":Git vdiff<CR>")
			vim.keymap.set("n", "<Leader>gc", ":Git commit<CR>")
			vim.keymap.set("n", "<Leader>ge", ":Gedit<CR>")
			vim.keymap.set("n", "<Leader>gr", ":Gread<CR>")
			vim.keymap.set("n", "<Leader>gw", ":Gwrite<CR>")
			vim.keymap.set("n", "<Leader>gp", ":Git push<CR>")
		end
	},
	{
		"nyngwang/NeoZoom.lua",
		config = function()
			require("neo-zoom").setup()
			vim.keymap.set("n", "<C-w><C-w>", ":NeoZoomToggle<CR>")
		end
	},
	"tpope/vim-surround",
	"tpope/vim-rhubarb",
	"tpope/vim-sleuth",
	"wsdjeg/vim-fetch",
	{
		"numtostr/BufOnly.nvim",
		cmd = "BufOnly",
		config = function()
			vim.keymap.set("n", "<Leader>o", ":BufOnly<CR>")
		end
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "cmp-nvim-lsp" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")
			lspconfig.tsserver.setup({
				capabilities = capabilities,
				init_options = {
					disableAutomaticTypingAcquisitioninitializationOptions = true
				},
				on_attach = function(client)
					-- I use prettier for formatting
					client.server_capabilities.document_formatting = false
				end
			})

			lspconfig.gopls.setup({ capabilities = capabilities })
			lspconfig.pyright.setup({ capabilities = capabilities })
			lspconfig.rust_analyzer.setup({ capabilities = capabilities })
			lspconfig.clangd.setup({ capabilities = capabilities })
			lspconfig.yamlls.setup({ capabilities = capabilities })

			-- I don't want eslint to use my project local config for
			-- dependencies in node_modules
			local eslint_root_pattern = lspconfig.util.root_pattern(
			".eslintrc",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.yaml",
			".eslintrc.yml",
			".eslintrc.json"
			-- "package.json"
			)
			lspconfig.eslint.setup({
				root_dir = function(fname)
					local fullpath = vim.fn.expand(fname, ":p")
					if string.find(fullpath, "node_modules") then
						return nil
					end
					return eslint_root_pattern(fname)
				end
			})

			vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
			vim.lsp.diagnostic.on_publish_diagnostics,
			{
				virtual_text = false,
				signs = true,
				update_in_insert = false,
				severity_sort = true,
			})
		end
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/vim-vsnip",
		},
		config = function()
			-- Setup nvim-cmp.
			local cmp = require("cmp")

			cmp.setup({
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body)
					end,
				},
				mapping = {
					["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), {"i","c"}),
					["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), {"i","c"}),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
					["<Tab>"] = cmp.mapping(cmp.mapping.confirm({ select = true }), { "i", "c" }),
					["<CR>"] = cmp.mapping(cmp.mapping.confirm(), { "i", "c" }),
					["<Esc>"] = cmp.mapping({
						i = cmp.mapping.abort(),
						c = function()
							-- https://github.com/hrsh7th/nvim-cmp/issues/1033
							vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-c>", true, true, true), "n", true)
						end
					}),
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
				}, {
					{ name = "vsnip" },
					{ name = "buffer" },
				})
			})

			-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline("/", {
				sources = {
					{ name = "buffer" }
				}
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				sources = cmp.config.sources({
					{ name = "path" }
				}, {
					{ name = "cmdline" }
				})
			})
		end
	},
	"nvim-telescope/telescope-ui-select.nvim",
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local actions = require("telescope.actions")
			require("telescope").setup({
				defaults = {
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--fixed-strings"
					},
					mappings = {
						n = {
							["<C-Space>"] = actions.close,
						},
						i = {
							["<C-Space>"] = actions.close,
						}
					}
				}
			})
			require("telescope").load_extension("ui-select")
			vim.keymap.set("n", "<C-Space><C-Space>", ":Telescope buffers<CR>")
			vim.keymap.set("n", "<C-Space><C-g>", ":Telescope live_grep<CR>")
			vim.keymap.set("n", "<C-Space><C-f>", ":Telescope find_files<CR>")
			vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>")
			vim.keymap.set("n", "<C-Space><C-t>", ":Telescope diagnostics<CR>")
			vim.keymap.set("n", "<C-Space><C-m>", ":Telescope marks<CR>")
			vim.keymap.set("n", "gd", ":Telescope lsp_definitions<CR>")
			vim.keymap.set("n", "gt", ":Telescope lsp_type_definitions<CR>")
			vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>")
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
					disable = function(_, bufnr)
						local name = vim.api.nvim_buf_get_name(bufnr)
						local size = vim.fn.getfsize(name)
						return size > bit.lshift(1, 20)
					end,
				},
				indent = {
					enable = true,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = '<CR>',
						node_incremental = '<CR>',
						node_decremental = '<BS>',
					},
				},
			})
		end
	},
	{
		"ishan9299/nvim-solarized-lua",
		config = function()
			vim.cmd.colorscheme("solarized")
		end
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"kyazdani42/nvim-web-devicons",
			"WhoIsSethDaniel/lualine-lsp-progress.nvim"
		},
		config = function()

			local function recording_macro()
				local letter = vim.fn.reg_recording()
				if letter == "" then
					return ""
				end
				return "RECORDING:" .. letter
			end

			require("lualine").setup({
				options = {
					globalstatus = true,
				},
				sections = {
					lualine_a = { recording_macro, "mode" },
					lualine_c = { "lsp_progress" }
				}
			})
		end
	},
	{
		"folke/trouble.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("trouble").setup()

			-- update the default diagnostic signs to match trouble
			vim.fn.sign_define("DiagnosticSignError", { text = "⚠", texthl = "DiagnosticError" })
			vim.fn.sign_define("DiagnosticSignWarning", { text = "⚠", texthl = "DiagnosticWarning" })
			vim.fn.sign_define("DiagnosticSignHint", { text = "⚠", texthl = "DiagnosticHint" })
			vim.fn.sign_define("DiagnosticSignInformation", { text = "", texthl = "DiagnosticInformation" })

			vim.keymap.set("n", "<Leader>d", ":TroubleToggle workspace_diagnostics<CR>")
		end
	},
	{
		"kyazdani42/nvim-tree.lua",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				-- I keep accidentally hitting 's' and opening libreoffice ...
				system_open = { cmd = "echo" },
				sync_root_with_cwd = true,
				actions = {
					open_file = {
						resize_window = false,
					},
				},
			})
			vim.keymap.set("n", "<Leader>n", ":NvimTreeToggle<CR>")
			vim.keymap.set("n", "<Leader>m", ":NvimTreeFindFile<CR>")
			vim.keymap.set("n", "<Leader>c", ":cd %:p:h<CR>")
		end
	},
	{
		"terrortylor/nvim-comment",
		config = function()
			require("nvim_comment").setup({ create_mappings = false })
			vim.keymap.set("n", "<Leader>k", ":CommentToggle<CR>")
			vim.keymap.set("x", "<Leader>k", ":CommentToggle<CR>gv")
		end
	},
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && yarn install",
		config = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")
			vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint)
			vim.keymap.set("n", "<F5>", dap.continue)

			-- nicer icons for breakpoints
			vim.fn.sign_define('DapBreakpoint',{ text ='○', texthl ='', linehl ='', numhl =''})
			vim.fn.sign_define('DapStopped',{ text ='➔', texthl ='', linehl ='', numhl =''})
		end
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function ()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			vim.keymap.set({"v", "n"}, "<Leader>e", dapui.eval)
			vim.keymap.set("n", "<F4>", dapui.toggle)
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("nvim-dap-virtual-text").setup()
		end
	},
	{
		"leoluz/nvim-dap-go",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("dap-go").setup()
		end
	},
	{
		"microsoft/vscode-js-debug",
		build = "npm ci --loglevel=error && npx gulp vsDebugServerBundle && rm -rf ./out && mv dist out",
	},
	{
		"mxsdev/nvim-dap-vscode-js",
		dependencies = {
			"mfussenegger/nvim-dap",
			"microsoft/vscode-js-debug",
		},
		config = function ()
			require("dap-vscode-js").setup({
				debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
				adapters = { 'pwa-node' },
			})
			for _, lang in ipairs({ "typescript", "javascript" }) do
				require("dap").configurations[lang] = {
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						cwd = "${workspaceFolder}",
						continueOnAttach = true,
						skipFiles = { "<node_internals>/**" },
					},
				}
			end
		end
	},
})

local function idtool_data(stage)
	local id = vim.fn.expand("<cword>")
	vim.cmd.new()
	local res = vim.fn.system("idtool -e " .. stage .. " " .. id)
	vim.api.nvim_buf_set_lines(0, 0, -1, true, vim.split(res, "\n"))
	vim.cmd.setfiletype("json")
end

local function idtool_info()
	local id = vim.fn.expand("<cword>")
	vim.cmd.new()
	local res = vim.fn.system("idtool -i " .. id)
	vim.api.nvim_buf_set_lines(0, 0, -1, true, vim.split(res, "\n"))
	vim.cmd.setfiletype("text")
end

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("n", "<Leader>id", function() idtool_data("dev") end)
vim.keymap.set("n", "<Leader>is", function() idtool_data("staging") end)
vim.keymap.set("n", "<Leader>ip", function() idtool_data("v1") end)
vim.keymap.set("n", "<Leader>ii", idtool_info)

-- https://github.com/nvim-lualine/lualine.nvim/issues/122
vim.keymap.set("n", "<C-c>", "<Nop>")
vim.keymap.set("c", "<C-c>", "<Nop>")
vim.keymap.set("i", "<C-c>", "<Nop>")
vim.keymap.set("n", "<Space>", "<Nop>")
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("t", "kj", "<C-\\><C-n>")
vim.keymap.set("t", "jk", "<C-\\><C-n>")
vim.keymap.set("n", "Q", "<Nop>")
vim.keymap.set("n", "gp", "`[v`]")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k")
-- vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l")
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<Leader>s", ":%s/<C-r><C-w>/")
vim.keymap.set("n", "<C-e>", "3<C-e>")
vim.keymap.set("n", "<C-y>", "3<C-y>")
vim.keymap.set("n", "]q", ":silent cnext<CR>")
vim.keymap.set("n", "[q", ":silent cprev<CR>")
vim.keymap.set("n", "]b", ":bnext<CR>")
vim.keymap.set("n", "[b", ":bprev<CR>")
vim.keymap.set("n", "]t", ":tabnext<CR>")
vim.keymap.set("n", "[t", ":tabprev<CR>")
vim.keymap.set("n", "]e", function () vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set("n", "[e", function () vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set("n", "]d", function () vim.diagnostic.goto_next() end)
vim.keymap.set("n", "[d", function () vim.diagnostic.goto_prev() end)
vim.keymap.set("n", "<Leader>r", vim.lsp.buf.rename)
-- vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "KK", function() vim.diagnostic.open_float(nil, {focus=false}) end)
vim.keymap.set("n", "<Leader>.", vim.lsp.buf.code_action)
vim.keymap.set("n", "<Leader>l", ":set list!<CR>")
vim.keymap.set("n", "<Leader>t", ":belowright split | resize 20 | terminal<CR>")
vim.keymap.set("n", "<Leader>x", ":let @+ = expand(\"%:p\")<CR>")
vim.keymap.set("n", "<MiddleMouse>", "<Nop>")
vim.keymap.set("i", "<MiddleMouse>", "<Nop>")

vim.keymap.set("n", "<Leader>f", function ()
	for _, client in ipairs(vim.lsp.get_active_clients()) do
		if client.name == "eslint" then
			vim.cmd.EslintFixAll()
			return
		end
	end
	vim.lsp.buf.format({ async = true })
end)
