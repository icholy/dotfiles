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
vim.opt.complete:remove({ "i" })
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.o.autoindent = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.wrap = false
vim.o.backup = true
vim.opt.undofile = true
vim.opt.backupdir:remove({ "." })
vim.opt.backupdir:prepend({ "~/tmp", "/tmp" })
vim.o.swapfile = false
vim.o.writebackup = false
vim.o.autoread = true
vim.o.mouse = "a"
vim.o.termguicolors = true
vim.o.tgc = true
vim.o.timeoutlen = 300
vim.o.updatetime = 250
vim.o.background = "light"
vim.o.fixendofline = false
vim.o.cmdheight = 0
vim.o.clipboard = unnamedplus
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.listchars:append("tab:» ")
vim.opt.listchars:append("eol:¬")

local group = vim.api.nvim_create_augroup("MyGroup", { clear = true })

-- format go files on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = group,
	pattern = "*.go",
	callback = function() vim.lsp.buf.format() end,
})

-- automatically switch sublime merge projects
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	group = group,
	callback = function()
		-- Check if in git directory
		local dir = vim.fn.expand("%:p:h")
		local is_git = vim.fn.system({ "git", "-C", dir, "rev-parse", "--is-inside-work-tree" }):match("true")
		if not is_git then
			return
		end
		-- Check if sublime merge is running
		local has_smerge = vim.fn.system("pgrep -x sublime_merge"):match("%d+")
		if not has_smerge then
			return
		end
		-- Open sublime merge
		vim.fn.system({ "smerge", dir })
	end
})

vim.api.nvim_create_autocmd('ColorScheme', {
	group = group,
	pattern = 'solarized*',
	callback = function()
		-- fix the nvim-dap-ui bar
		-- See: https://github.com/rcarriga/nvim-dap-ui/issues/315
		vim.cmd('highlight! link StatusLineNC NormalNC')
		vim.cmd('highlight! link StatusLine Normal')
		-- used to darken the line background when hitting a breakpoint
		vim.cmd('highlight DapStoppedLine guibg=#eee8d5')
	end,
})

vim.api.nvim_create_user_command("LLM", function(opts)
	local system = [[
	You are a neovim expert.
	You help users write commands.
	When a user asks a question, your output will be copied directly into the neovim command prompt.
	Do not add any explanation.
	Since the output is being copied in the command line, it should all be on a single line.
	]]
	local output = vim.system(
		{ "llm", "prompt", "--system", system, opts.args },
		{ text = true }
	):wait()
	if output.code ~= 0 then
		vim.notify(output.stderr, vim.log.levels.ERROR)
	end
	local command = output.stdout
	if string.sub(command, 1, 1) ~= ":" then
		command = ":" .. command
	end
	command = string.gsub(command, "\n*$", "")
	vim.api.nvim_feedkeys(command, "n", {})
end, { nargs = '?' })

-- automatically enter insert mode
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "TermOpen" }, {
	command = "startinsert",
	pattern = "term://*",
})

-- don't auto-indent when typing ':'
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "yml", "yaml" },
	callback = function()
		vim.opt_local.indentkeys:remove({ "<:>", ":" })
	end
})

-- make for typescript
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "typescript", "typescriptreact" },
	command = "compiler tsc | setlocal makeprg=npx\\ tsc",
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
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end
	},
	{
		"tpope/vim-fugitive",
		init = function()
			vim.g.fugitive_legacy_commands = false
		end,
		config = function()
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
		"FabijanZulj/blame.nvim",
		config = function()
			local blame = require("blame")
			blame.setup()
			vim.keymap.set("n", "<Leader>b", ":BlameToggle<CR>")
		end
	},
	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		config = true
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "cmp-nvim-lsp" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")

			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				init_options = {
					disableAutomaticTypingAcquisitioninitializationOptions = true,
					importModuleSpecifierPreference = "relative",
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
			lspconfig.jsonls.setup({ capabilities = capabilities })
			lspconfig.terraformls.setup({ capabilities = capabilities })
			lspconfig.lua_ls.setup({ capabilities = capabilities })
			lspconfig.marksman.setup({ capabilities = capabilities })
			lspconfig.zls.setup({ capabilities = capabilities })

			-- I don't want eslint to use my project local config for
			-- dependencies in node_modules
			local eslint_root_pattern = lspconfig.util.root_pattern(
				".eslintrc",
				".eslintrc.js",
				".eslintrc.cjs",
				".eslintrc.yaml",
				".eslintrc.yml",
				".eslintrc.json",
				"eslint.config.js"
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
			"rcarriga/cmp-dap",
		},
		config = function()
			-- Setup nvim-cmp.
			local cmp = require("cmp")

			local abort_esc = function()
				-- https://github.com/hrsh7th/nvim-cmp/issues/1033
				cmp.confirm()
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, true, true), "n",
					true)
			end

			cmp.setup({
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body)
					end,
				},
				mapping = {
					["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
					["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
					["<Tab>"] = cmp.mapping(cmp.mapping.confirm({ select = true }), { "i", "c" }),
					["<CR>"] = cmp.mapping(cmp.mapping.confirm(), { "i", "c" }),
					-- ["<Esc>"] = cmp.mapping(abort_esc, { "i", "c" }),
					-- ["<C-a>"] = cmp.mapping(
					-- 	cmp.mapping.complete({
					-- 		config = {
					-- 			sources = {
					-- 				{ name = "codeium" }
					-- 			}
					-- 		}
					-- 	}),
					-- 	{ "i", "c" }
					-- ),
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
				}, {
					-- { name = "vsnip" },
					-- { name = "buffer" },
				}),
				preselect = cmp.PreselectMode.None,
				sorting = {
					comparators = {
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						cmp.config.compare.score,
						cmp.config.compare.recently_used,
						cmp.config.compare.kind,
					},
				},
				enabled = function()
					return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or
						require("cmp_dap").is_dap_buffer()
				end,
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

			-- Use dap source for dap-repl
			require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
				sources = {
					{ name = "dap" },
				},
			})
		end
	},
	-- {
	-- 	"Exafunction/codeium.nvim",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"hrsh7th/nvim-cmp",
	-- 	},
	-- 	config = function()
	-- 		require("codeium").setup({})
	-- 	end
	-- },
	{
		"icholy/lsplinks.nvim",
		config = function()
			local lsplinks = require("lsplinks")
			lsplinks.setup()
			vim.keymap.set("n", "gx", lsplinks.gx)
		end
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			"nvim-telescope/telescope-dap.nvim",
			"Marskey/telescope-sg",
		},
		config = function()
			local actions = require("telescope.actions")
			require("telescope").setup({
				defaults = {
					shorten_path = true,
					layout_strategy = "vertical",
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
				},
				extensions = {
					ast_grep = {
						command = {
							"sg",
							"--json=stream",
						},     -- must have --json=stream
						grep_open_files = false, -- search in opened files
						lang = nil, -- string value, specify language for ast-grep `nil` for default
					}
				}
			})
			require("telescope").load_extension("ui-select")
			require('telescope').load_extension('dap')
			vim.keymap.set("n", "<C-Space><C-b>", ":Telescope buffers<CR>")
			vim.keymap.set("n", "<C-Space><C-g>", ":Telescope live_grep<CR>")
			vim.keymap.set("n", "<C-Space><C-f>", ":Telescope find_files<CR>")
			vim.keymap.set("n", "<C-Space><C-a>", ":Telescope ast_grep<CR>")
			vim.keymap.set("n", "<C-Space><C-h>", ":Telescope help_tags<CR>")
			vim.keymap.set("n", "<C-Space><C-t>", ":Telescope lsp_workspace_symbols<CR>")
			vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>")
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
		"linrongbin16/lsp-progress.nvim",
		config = function()
			require("lsp-progress").setup({})
			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = "LspProgressStatusUpdated",
				callback = require("lualine").refresh,
			})
		end
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"kyazdani42/nvim-web-devicons",
			"linrongbin16/lsp-progress.nvim"
		},
		config = function()
			local function recording_macro()
				local letter = vim.fn.reg_recording()
				if letter == "" then
					return ""
				end
				return "RECORDING:" .. letter
			end

			local lualine = require("lualine")

			lualine.setup({
				options = {
					globalstatus = true,
				},
				sections = {
					lualine_a = { recording_macro, "mode" },
					lualine_c = {
						function()
							return require('lsp-progress').progress()
						end
					}
				}
			})

			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = "LspProgressStatusUpdated",
				callback = lualine.refresh,
			})
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


			dap.adapters["local-lua"] = {
				type = "executable",
				command = "node",
				args = {
					"/home/icholy/src/github.com/tomblind/local-lua-debugger-vscode/extension/debugAdapter.js"
				},
				enrich_config = function(config, on_config)
					if not config["extensionPath"] then
						local c = vim.deepcopy(config)
						-- 💀 If this is missing or wrong you'll see
						-- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
						c.extensionPath =
						"/home/icholy/src/github.com/tomblind/local-lua-debugger-vscode/"
						on_config(c)
					else
						on_config(config)
					end
				end,
			}

			-- setup nlua debugger
			dap.configurations.lua = {
				{
					name = 'Current file (local-lua-dbg, nlua)',
					type = 'local-lua',
					request = 'launch',
					cwd = '${workspaceFolder}',
					program = {
						lua = 'nlua',
						file = '${file}',
					},
					verbose = true,
					args = {},
				},
			}

			dap.configurations.python = {
				{
					name = 'Current file (python)',
					type = 'python',
					request = 'launch',
					cwd = '${workspaceFolder}',
					program = 'python3',
					verbose = true,
					args = { '${file}' },
				},
			}

			dap.adapters.python = {
				type = "executable",
				command = "python3",
				args = { "-m", "debugpy.adapter" },
				options = {
					source_filetype = "python",
				},
			}

			dap.adapters.lldb = {
				type = "executable",
				command = "/usr/lib/llvm-14/bin/lldb-vscode",
			}

			dap.adapters["pwa-node"] = {
				type = "server",
				port = "${port}",
				host = "localhost",
				executable = {
					command = "js-debug-adapter",
					args = { "${port}" },
				}
			}

			for _, lang in ipairs({ "typescript", "javascript" }) do
				dap.configurations[lang] = {
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						cwd = "${workspaceFolder}",
						continueOnAttach = true,
						skipFiles = {
							"<node_internals>/**",
							"**/cls-hooked/**",
						},
					},
				}
			end

			-- filter out source map errors
			dap.defaults.fallback.on_output = function(session, event)
				local repl = require("dap.repl")
				if event.category == "stdout" and not string.find(event.output, "Could not read source map for file") then
					repl.append(event.output, "$", { newline = false })
				end
			end

			vim.keymap.set("n", "<F5>", dap.continue)

			vim.keymap.set("n", "<Left>", dap.toggle_breakpoint)
			vim.keymap.set("n", "<Right>", dap.step_over)
			vim.keymap.set("n", "<Down>", dap.step_into)
			vim.keymap.set("n", "<Up>", dap.step_out)

			-- nicer icons for breakpoints
			vim.fn.sign_define('DapBreakpoint', { text = '○', texthl = '', linehl = '', numhl = '' })
			vim.fn.sign_define('DapStopped',
				{ text = '➔', texthl = '', linehl = 'DapStoppedLine', numhl = '' })
		end
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dapui = require("dapui")

			dapui.setup({
				layouts = {
					{
						elements = {
							{ id = "repl", size = 1 },
						},
						size = 0.3,
						position = "bottom",
					},
					{
						elements = {
							{ id = "scopes",      size = 0.25 },
							{ id = "breakpoints", size = 0.25 },
							{ id = "stacks",      size = 0.25 },
							{ id = "watches",     size = 0.25 },
						},
						size = 40,
						position = "left",
					},
				},
			})

			vim.keymap.set({ "v", "n" }, "<Leader>e", dapui.eval)
			vim.keymap.set("n", "<F3>", function()
				dapui.toggle({ layout = 2 })
			end)
			vim.keymap.set("n", "<F4>", function()
				dapui.toggle({ layout = 1 })
			end)
		end,
	},
	{
		"leoluz/nvim-dap-go",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("dap-go").setup()
		end
	},
	{
		"Funk66/jira.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			domain = "teamideaworks.atlassian.net",
			user = "ilia.choly@compassdigital.io",
			token = vim.env.JIRA_API_TOKEN,
			key = { "CDL", "SRE", "OD", "CPLAT" },
			format = function(issue)
				local utils = require("jira.utils")
				local assignee = vim.tbl_get(issue.fields, { 'assignee', 'displayName' }) or 'None'
				return {
					issue.fields.summary,
					"---",
					"Status:   " .. issue.fields.status.name,
					"Assignee: " .. assignee,
					"---",
					utils.adf_to_markdown(issue.fields.description),
					"---",
					"Created:  " .. issue.fields.created,
					"Updated:  " .. issue.fields.updated,
				}
			end
		},
		keys = {
			{ "<leader>jj", ":JiraView<cr>", desc = "View Jira issue",            silent = true },
			{ "<leader>jo", ":JiraOpen<cr>", desc = "Open Jira issue in browser", silent = true },
		},
	},
	{
		"olimorris/codecompanion.nvim",
		opts = {
			strategies = {
				chat = {
					adapter = "anthropic",
				},
				inline = {
					adapter = "anthropic",
				},
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
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
vim.keymap.set("t", "<C-[>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-[>", "<C-\\><C-n>")
vim.keymap.set("n", "Q", "<Nop>")
vim.keymap.set("n", "gp", "`[v`]")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
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
vim.keymap.set("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set("n", "<Leader>r", vim.lsp.buf.rename)
vim.keymap.set("n", "KK", function() vim.diagnostic.open_float(nil, { focus = false }) end)
vim.keymap.set("n", "<Leader>.", function()
	vim.lsp.buf.code_action({
		filter = function(action)
			-- See: https://github.com/golang/go/issues/72742
			if string.find(action.title, "feature documentation") then
				return false
			end
			return true
		end
	})
end)
vim.keymap.set("n", "gs", function()
	-- find tsserver client
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local tsserver = vim.iter(clients):find(function(c)
		return c.name == "tsserver" or c.name == "typescript-tools" or c.name == "ts_ls"
	end)
	if not tsserver then
		vim.notify("No TypeScript LSP client found", vim.log.levels.WARN)
		return
	end
	-- go to source defintiion
	local win = vim.api.nvim_get_current_win()
	local params = vim.lsp.util.make_position_params(win, tsserver.offset_encoding or "utf-16")
	tsserver.request("workspace/executeCommand", {
		command = "_typescript.goToSourceDefinition",
		arguments = { params.textDocument.uri, params.position },
	}, function(err, result)
		if err then
			vim.notify("Go to source definition failed: " .. err.message, vim.log.levels.ERROR)
			return
		end
		if not result or vim.tbl_isempty(result) then
			vim.notify("No source definition found", vim.log.levels.INFO)
			return
		end
		vim.lsp.util.jump_to_location(result[1], tsserver.offset_encoding)
	end, 0)
end)
vim.keymap.set("n", "<Leader>l", ":set list!<CR>")
vim.keymap.set("n", "<Leader>t", ":belowright split | resize 20 | terminal<CR>")
vim.keymap.set("n", "<Leader>x", ":let @+ = expand(\"%:p\")<CR>")
vim.keymap.set("n", "<MiddleMouse>", "<Nop>")
vim.keymap.set("i", "<MiddleMouse>", "<Nop>")

vim.keymap.set("n", "<Leader>f", function()
	local bufnr = vim.api.nvim_get_current_buf()
	if #vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" }) > 0 then
		vim.cmd.EslintFixAll()
	else
		vim.lsp.buf.format({ async = true })
	end
end)
