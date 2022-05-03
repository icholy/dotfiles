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
vim.o.expandtab = true
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
vim.o.t_Co = 256
vim.o.termguicolors = true
vim.o.tgc = true
vim.o.timeoutlen = 300
vim.o.updatetime = 250
vim.o.background = "light"
vim.o.fixendofline = false

vim.opt.listchars:append("tab:» ")
vim.opt.listchars:append("eol:¬")

vim.cmd("packadd packer.nvim")

-- automatically recompile when config is changed
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | PackerCompile',
  group = packer_group,
  pattern = 'init.lua',
})

require("packer").startup(function(use)
  use("wbthomason/packer.nvim")
  use("tpope/vim-fugitive")
  use("tpope/vim-surround")
  use("tpope/vim-sleuth")
  use("tpope/vim-rhubarb")
  use({"numtostr/BufOnly.nvim", cmd = "BufOnly" })
  use({
    "neovim/nvim-lspconfig",
    after = "cmp-nvim-lsp",
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      require('cmp_nvim_lsp').update_capabilities(capabilities)

      local lspconfig = require('lspconfig')
      lspconfig.tsserver.setup({
        capabilities = capabilities,
        init_options = {
          disableAutomaticTypingAcquisitioninitializationOptions  = true,
        },
        on_attach = function(client)
          -- I use prettier for formatting
          client.server_capabilities.document_formatting = false
        end
      })
      lspconfig.gopls.setup({ capabilities = capabilities })
      lspconfig.jedi_language_server.setup({ capabilities = capabilities })

      local runtime_path = vim.split(package.path, ';')
      table.insert(runtime_path, "lua/?.lua")
      table.insert(runtime_path, "lua/?/init.lua")
      lspconfig.sumneko_lua.setup({
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
              -- Setup your lua path
              path = runtime_path,
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = {'vim'},
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
              enable = false,
            },
          },
        },
      })
      lspconfig.eslint.setup({})
    end
  })
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use("hrsh7th/cmp-cmdline")
  use("hrsh7th/vim-vsnip")
  use("rafamadriz/friendly-snippets")
  use({
      "hrsh7th/nvim-cmp",
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
            ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), {'i','c'}),
            ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'i','c'}),
            ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
            ['<Tab>'] = cmp.mapping(cmp.mapping.confirm({ select = true }), { 'i', 'c' }),
            ['<CR>'] = cmp.mapping(cmp.mapping.confirm(), { 'i', 'c' }),
            ['<Esc>'] = cmp.mapping(cmp.mapping.abort(), { 'i', 'c' }),
          },
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'vsnip' },
          }, {
            { name = 'buffer' },
          })
        })

        -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline('/', {
          sources = {
            { name = 'buffer' }
          }
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(':', {
          sources = cmp.config.sources({
            { name = 'path' }
          }, {
            { name = 'cmdline' }
          })
        })
      end
  })
  use("nvim-telescope/telescope-ui-select.nvim")
  use({
    "nvim-telescope/telescope.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          mappings = {
            n = {
              ["<C-Space>"] = actions.close,
              ["<C-c>"] = actions.close
            },
            i = {
              ["<C-Space>"] = actions.close,
              ["<C-c>"] = actions.close
            }
          }
        }
      })
      require("telescope").load_extension("ui-select")
    end
  })
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
          highlight = {
            enable = true,
            disable = {}
          },
          indent = {
            enable = true,
            disable = {}
          },
          ensure_installed = {
            "go",
            "javascript",
            "typescript",
            "json",
            "lua",
            "bash"
          }
        })
    end
  })
  use({
    "RRethy/nvim-treesitter-textsubjects",
    config = function()
      require('nvim-treesitter.configs').setup({
          textsubjects = {
              enable = true,
              prev_selection = ',',
              keymaps = {
                  ['.'] = 'textsubjects-smart',
              },
          },
      })
    end
  })
  use({
    "ishan9299/nvim-solarized-lua",
    config = function()
      vim.cmd("colorscheme solarized")
    end
  })
  use({
    "nvim-lualine/lualine.nvim",
    requires = {
        "kyazdani42/nvim-web-devicons",
        "arkav/lualine-lsp-progress"
    },
    config = function()
        require("lualine").setup({
            options = {
                globalstatus = true,
            },
            sections = {
                lualine_c = {
                    "lsp_progress"
                }
            }
        })
    end
  })
  use({
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup()
    end
  })
  use({
      "kyazdani42/nvim-tree.lua",
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
        require("nvim-tree").setup()
      end
  })
  use("dstein64/vim-startuptime")
  use({
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      dap.adapters.node2 = {
        type = "executable",
        command = "node",
        args = {"/home/icholy/src/github.com/microsoft/vscode-node-debug2/out/src/nodeDebug.js"}
      }
      dap.configurations.javascript = {
        {
          name = "Launch Test",
          type = "node2",
          request = "launch",
          env = { MOCHA_OPTIONS = "--inspect-brk" },
          cwd = vim.fn.getcwd(),
          runtimeExecutable = "npm",
          runtimeArgs = { "test" },
          sourceMaps = true,
          protocol = "inspector",
          noDebug = true,
          skipFiles = {"<node_internals>/**/*.js"},
          console = "integratedTerminal",
          port = 9229
        },
        {
          name = 'Attach',
          type = 'node2',
          request = 'attach',
          processId = require('dap.utils').pick_process,
        }
      }
    end
  })
  use({
    "terrortylor/nvim-comment",
    config = function()
      local comment = require("nvim_comment")
      comment.setup({ create_mappings = false })
      vim.keymap.set("n", "<C-c>", "<Cmd>set operatorfunc=CommentOperator<CR>g@l")
      vim.keymap.set("x", "<C-c>", ":<C-u>call CommentOperator(visualmode())<CR>")
    end
  })
end)

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.cmd("source ~/.config/nvim/idtool.vim")

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = true,
    update_in_insert = false,
  }
)

vim.keymap.set("n", "<Space>", "<Nop>")
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("n", "Q", "<Nop>")
vim.keymap.set("n", "gp", "`[v`]")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<Leader>s", ":%s/<C-r><C-w>/")
vim.keymap.set("n", "<Leader>gs", ":Git status<CR>")
vim.keymap.set("n", "<Leader>gd", ":Git vdiff<CR>")
vim.keymap.set("n", "<Leader>gc", ":Git commit<CR>")
vim.keymap.set("n", "<Leader>ge", ":Gedit<CR>")
vim.keymap.set("n", "<Leader>gr", ":Gread<CR>")
vim.keymap.set("n", "<Leader>gw", ":Gwrite<CR>")
vim.keymap.set("n", "<Leader>gp", ":Git push<CR>")
vim.keymap.set("n", "<C-e>", "3<C-e>")
vim.keymap.set("n", "<C-y>", "3<C-y>")
vim.keymap.set("n", "]q", ":cnext<CR>")
vim.keymap.set("n", "[q", ":cprev<CR>")
vim.keymap.set("n", "]b", ":bnext<CR>")
vim.keymap.set("n", "[b", ":bprev<CR>")
vim.keymap.set("n", "]t", ":tabnext<CR>")
vim.keymap.set("n", "[t", ":tabprev<CR>")
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<Leader>n", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<Leader>m", ":NvimTreeFindFile<CR>")
vim.keymap.set("n", "gd", ":Telescope lsp_definitions<CR>")
vim.keymap.set("n", "gt", ":Telescope lsp_type_definitions<CR>")
vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>")
vim.keymap.set("n", "<Leader>f", function () vim.lsp.buf.format({ async = true }) end)
vim.keymap.set("", "K", vim.lsp.buf.hover)
vim.keymap.set("", "KK", function() vim.diagnostic.open_float(nil, {focus=false}) end)
vim.keymap.set("n", "<Leader>.", vim.lsp.buf.code_action)
vim.keymap.set("n", "<Leader>d", ":TroubleToggle<CR>")
vim.keymap.set("n", "<C-Space><C-Space>", ":Telescope buffers<CR>")
vim.keymap.set("n", "<C-Space><C-g>", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<C-Space><C-f>", ":Telescope find_files<CR>")
vim.keymap.set("n", "<Leader>l", ":set list!<CR>")

local dap = require("dap")

vim.keymap.set("n", "<Leader>b", function()
    dap.toggle_breakpoint()
end)

vim.keymap.set("n", "<Leader>c", function()
    dap.continue()
end)

vim.keymap.set("n", "<Leader>t", function()
  dap.run({
    type = "node2",
    request = "launch",
    env = { MOCHA_OPTIONS = "--inspect-brk=9229" },
    cwd = vim.fn.getcwd(),
    runtimeExecutable = "npm",
    runtimeArgs = { "test" },
    sourceMaps = true,
    protocol = "inspector",
    noDebug = true,
    skipFiles = {"<node_internals>/**/*.js"},
    console = "integratedTerminal",
    port = 9229
  })
end)
