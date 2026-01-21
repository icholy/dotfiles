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
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"ts_ls",
					"gopls",
					"pyright",
					"rust_analyzer",
					"clangd",
					"yamlls",
					"jsonls",
					"terraformls",
					"lua_ls",
					"marksman",
					"zls",
					"prismals",
					"eslint",
				},
			})
		end
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
		config = function()
			require("mason-nvim-dap").setup({
				ensure_installed = { "js-debug-adapter", "debugpy" },
			})
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
	"prisma/vim-prisma",
	"tpope/vim-surround",
	"tpope/vim-rhubarb",
	"tpope/vim-sleuth",
	"wsdjeg/vim-fetch",
	{
		"FabijanZulj/blame.nvim",
		config = function()
			local blame = require("blame")
			blame.setup({
				date_format = "%r",
				relative_date_if_recent = false
			})
			vim.keymap.set("n", "<Leader>b", ":BlameToggle<CR>")
			vim.keymap.set('n', '<leader>g', function()
				if not blame.is_open() then
					vim.notify("Blame view is not open", vim.log.levels.WARN)
					return
				end

				local current_win = vim.api.nvim_get_current_win()
				if current_win ~= blame.last_opened_view.blame_window then
					vim.notify("Not in blame window", vim.log.levels.WARN)
					return
				end

				local row, _ = unpack(vim.api.nvim_win_get_cursor(current_win))
				local commit = blame.last_opened_view.blamed_lines[row]
				local commit_hash = commit and commit.hash

				if not commit_hash then
					vim.notify("No commit found", vim.log.levels.WARN)
					return
				end

				-- Get git remote URL
				vim.fn.jobstart({ 'git', 'config', '--get', 'remote.origin.url' }, {
					stdout_buffered = true,
					on_stdout = function(_, data)
						if data and data[1] then
							local remote_url = data[1]:gsub('%.git$', '')
							-- Convert SSH to HTTPS if needed
							remote_url = remote_url:gsub('^git@github%.com:', 'https://github.com/')

							local github_url = remote_url .. '/commit/' .. commit_hash
							vim.schedule(function()
								vim.ui.open(github_url)
							end)
						end
					end,
					on_exit = function(_, exit_code)
						if exit_code ~= 0 then
							vim.notify("Failed to get Github Remote", vim.log.levels.ERROR)
						end
					end,
				})
			end, { desc = "Open commit in GitHub" })
		end
	},
	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		config = true
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "blink.cmp", "williamboman/mason-lspconfig.nvim" },
		config = function()
			local capabilities = require('blink.cmp').get_lsp_capabilities()

			vim.lsp.enable('ts_ls', {
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

			vim.lsp.enable('gopls', { capabilities = capabilities })
			vim.lsp.enable('pyright', { capabilities = capabilities })
			vim.lsp.enable('rust_analyzer', { capabilities = capabilities })
			vim.lsp.enable('clangd', { capabilities = capabilities })
			vim.lsp.enable('yamlls', { capabilities = capabilities })
			vim.lsp.enable('jsonls', { capabilities = capabilities })
			vim.lsp.enable('terraformls', { capabilities = capabilities })
			vim.lsp.enable('lua_ls', { capabilities = capabilities })
			vim.lsp.enable('marksman', { capabilities = capabilities })
			vim.lsp.enable('zls', { capabilities = capabilities })
			vim.lsp.enable('prismals', { capabilities = capabilities })
			vim.lsp.enable('eslint', { capabilities = capabilities })
			vim.lsp.enable('ast-grep', { capabilities = capabilities })
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
		"saghen/blink.compat",
		version = "2.*",
		lazy = true,
		opts = {},
	},
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = { "saghen/blink.compat", "rcarriga/cmp-dap" },
		config = function()
			require("blink.cmp").setup({
				enabled = function()
					return vim.bo.buftype ~= "prompt" or require("cmp_dap").is_dap_buffer()
				end,
				keymap = {
					preset = "none",
					["<C-n>"] = { "select_next", "fallback" },
					["<C-p>"] = { "select_prev", "fallback" },
					["<C-Space>"] = { "show" },
					["<Tab>"] = { "select_and_accept", "fallback" },
					["<CR>"] = { "accept", "fallback" },
					["<C-d>"] = { "scroll_documentation_down", "fallback" },
					["<C-u>"] = { "scroll_documentation_up", "fallback" },
				},
				cmdline = {
					enabled = true,
					completion = { menu = { auto_show = true } },
					keymap = {
						preset = "none",
						["<C-n>"] = { "select_next", "fallback" },
						["<C-p>"] = { "select_prev", "fallback" },
						["<C-Space>"] = { "show" },
						["<Tab>"] = { "select_and_accept", "fallback" },
					},
					sources = function()
						local type = vim.fn.getcmdtype()
						if type == "/" or type == "?" then
							return { "buffer" }
						end
						if type == ":" then
							return { "cmdline", "path" }
						end
						return {}
					end,
				},
				completion = {
					list = {
						selection = {
							preselect = false,
							auto_insert = false,
						},
					},
					menu = {
						auto_show = true,
						draw = {
							columns = {
								{ "kind_icon" },
								{ "label", "label_description", gap = 1 },
								{ "source_name" },
							},
							components = {
								source_name = {
									width = { max = 30 },
									text = function(ctx)
										return "[" .. ctx.source_name .. "]"
									end,
									highlight = "BlinkCmpSource",
								},
							},
						},
					},
					documentation = {
						auto_show = true,
						auto_show_delay_ms = 200,
					},
				},
				snippets = {
					preset = "default",
				},
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
					-- DAP-specific sources
					per_filetype = {
						["dap-repl"] = { "dap", "buffer" },
					},
					providers = {
						lsp = {
							name = "LSP",
							module = "blink.cmp.sources.lsp",
							score_offset = 100,
						},
						path = {
							name = "Path",
							module = "blink.cmp.sources.path",
						},
						buffer = {
							name = "Buffer",
							module = "blink.cmp.sources.buffer",
							score_offset = -50,
						},
						snippets = {
							name = "Snippets",
							module = "blink.cmp.sources.snippets",
							score_offset = -50,
						},
						-- DAP source via compat layer
						dap = {
							name = "DAP",
							module = "blink.compat.source",
							enabled = function()
								return require("cmp_dap").is_dap_buffer()
							end,
						},
					},
				},
				signature = {
					enabled = true,
				},
				appearance = {
					use_nvim_cmp_as_default = true, -- Use nvim-cmp highlight groups for theme compat
					nerd_font_variant = "mono",
				},
			})
		end,
	},
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
						command = { "ast-grep", "--json=stream" },
						grep_open_files = false,
						lang = nil,
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
		"igorlfs/nvim-dap-view",
		opts = {},
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
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = false,
			},
		},
		keys = {
			{
				"<C-l>",
				function()
					local suggestion = require("copilot.suggestion")
					if suggestion.is_visible() then
						suggestion.accept()
					else
						suggestion.next()
					end
				end,
				mode = "i",
				desc = "Copilot trigger/accept",
			},
		},
	}
})

local function idtool_data(stage)
	local id = vim.fn.expand("<cword>")
	vim.cmd.new()
	local res = vim.fn.system("idtool -s " .. stage .. " " .. id)
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
vim.keymap.set("n", "gs", ":LspTypescriptGoToSourceDefinition<CR>")
vim.keymap.set("n", "<Leader>l", ":set list!<CR>")
vim.keymap.set("n", "<Leader>t", ":belowright split | resize 20 | terminal<CR>")
vim.keymap.set("n", "<Leader>x", ":let @+ = expand(\"%:p\")<CR>")
vim.keymap.set("n", "<MiddleMouse>", "<Nop>")
vim.keymap.set("i", "<MiddleMouse>", "<Nop>")
vim.keymap.set("n", "<F4>", ":DapViewToggle<CR>")

vim.keymap.set("n", "<Leader>f", function()
	local bufnr = vim.api.nvim_get_current_buf()
	if #vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" }) > 0 then
		vim.cmd.LspEslintFixAll()
	else
		vim.lsp.buf.format({ async = true })
	end
end)
