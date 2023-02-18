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
vim.o.cmdheight = 0

vim.opt.listchars:append("tab:» ")
vim.opt.listchars:append("eol:¬")

vim.cmd.packadd("packer.nvim")

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

require("packer").startup(function(use)
  use("wbthomason/packer.nvim")
  use({
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
  })
  use("tpope/vim-surround")
  use("tpope/vim-sleuth")
  use("tpope/vim-rhubarb")
  use({
    "numtostr/BufOnly.nvim",
    cmd = "BufOnly",
    config = function()
      vim.keymap.set("n", "<Leader>o", ":BufOnly<CR>")
    end
  })
  use({
    "neovim/nvim-lspconfig",
    after = "cmp-nvim-lsp",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")
      lspconfig.tsserver.setup({
        flags = {
          debounce_text_changes = 500,
          allow_incremental_sync = false
        },
        capabilities = capabilities,
        init_options = {
          disableAutomaticTypingAcquisitioninitializationOptions  = true,
        },
        on_attach = function(client)
          -- I use prettier for formatting
          client.server_capabilities.document_formatting = false
        end
      })

      -- keep track of the last gopls root so we can re-use it when entering $GOPATH/pkg/mod
      local prev_gopls_root = nil
      local go_mod_cache = vim.trim(vim.fn.system("go env GOPATH")) .. '/pkg/mod'

      lspconfig.gopls.setup({
        capabilities = capabilities,

        -- See: https://github.com/neovim/nvim-lspconfig/issues/804
        root_dir = function(fname)
          local fullpath = vim.fn.expand(fname, ':p')
          if string.find(fullpath, go_mod_cache) and prev_gopls_root ~= nil then
              return prev_gopls_root
          end
          local root = lspconfig.util.root_pattern("go.mod", ".git")(fname)
          if root ~= nil then
            prev_gopls_root = root
          end
          return root
        end
      })
      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.rust_analyzer.setup({ capabilities = capabilities })

      local runtime_path = vim.split(package.path, ";")
      table.insert(runtime_path, "lua/?.lua")
      table.insert(runtime_path, "lua/?/init.lua")
      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = "LuaJIT",
              -- Setup your lua path
              path = runtime_path,
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = {"vim"},
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
    end
  })
  -- use("rafamadriz/friendly-snippets")
  use({
      "hrsh7th/nvim-cmp",
      requires = {
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
      vim.keymap.set("n", "gd", ":Telescope lsp_definitions<CR>")
      vim.keymap.set("n", "gt", ":Telescope lsp_type_definitions<CR>")
      vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>")
    end
  })
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
          highlight = {
            enable = true,
            disable = function(_, bufnr)
              local name = vim.api.nvim_buf_get_name(bufnr)
              local size = vim.fn.getfsize(name)
              return size > bit.lshift(1, 20)
            end,
          },
          indent = {
            enable = false,
            disable = {}
          },
          ensure_installed = {
            "go",
            "javascript",
            "typescript",
            "json",
            "lua",
            "bash"
          },
        })
    end
  })
  use({
    "ishan9299/nvim-solarized-lua",
    config = function()
      vim.cmd.colorscheme("solarized")
    end
  })
  use({
    "nvim-lualine/lualine.nvim",
    requires = {
        "kyazdani42/nvim-web-devicons",
        "arkav/lualine-lsp-progress"
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
  })
  use({
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup()

      -- update the default diagnostic signs to match trouble
      vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define("DiagnosticSignWarning", { text = "", texthl = "DiagnosticWarning" })
      vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticHint" })
      vim.fn.sign_define("DiagnosticSignInformation", { text = "", texthl = "DiagnosticInformation" })

        vim.keymap.set("n", "<Leader>d", ":TroubleToggle workspace_diagnostics<CR>")
      end
    })
    use({
      "kyazdani42/nvim-tree.lua",
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
        require("nvim-tree").setup({
          -- I keep accidentally hitting 's' and opening libreoffice ...
          system_open = { cmd = "echo" },
        })
        vim.keymap.set("n", "<Leader>n", ":NvimTreeToggle<CR>")
        vim.keymap.set("n", "<Leader>m", ":NvimTreeFindFile<CR>")
      end
    })
    use({
      "terrortylor/nvim-comment",
      config = function()
        require("nvim_comment").setup({ create_mappings = false })
        vim.keymap.set("n", "<Leader>k", ":CommentToggle<CR>")
        vim.keymap.set("x", "<Leader>k", ":CommentToggle<CR>gv")
      end
    })
    use({
      "iamcco/markdown-preview.nvim",
      run = "cd app && npm install",
      config = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
      ft = { "markdown" },
    })
  end)

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = true,
    update_in_insert = false,
    severity_sort = true,
  }
)

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
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l")
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<Leader>s", ":%s/<C-r><C-w>/")
vim.keymap.set("n", "<C-e>", "3<C-e>")
vim.keymap.set("n", "<C-y>", "3<C-y>")
vim.keymap.set("n", "]q", ":cnext<CR>")
vim.keymap.set("n", "[q", ":cprev<CR>")
vim.keymap.set("n", "]b", ":bnext<CR>")
vim.keymap.set("n", "[b", ":bprev<CR>")
vim.keymap.set("n", "]t", ":tabnext<CR>")
vim.keymap.set("n", "[t", ":tabprev<CR>")
vim.keymap.set("n", "]e", function () vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set("n", "[e", function () vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set("n", "]d", function () vim.diagnostic.goto_next() end)
vim.keymap.set("n", "[d", function () vim.diagnostic.goto_prev() end)
vim.keymap.set("n", "<Leader>f", function () vim.lsp.buf.format({ async = true }) end)
vim.keymap.set("n", "<Leader>r", vim.lsp.buf.rename)
vim.keymap.set("", "K", vim.lsp.buf.hover)
vim.keymap.set("", "KK", function() vim.diagnostic.open_float(nil, {focus=false}) end)
vim.keymap.set("n", "<Leader>.", vim.lsp.buf.code_action)
vim.keymap.set("n", "<Leader>l", ":set list!<CR>")
vim.keymap.set("n", "<Leader>t", ":belowright split | resize 20 | terminal<CR>")
vim.keymap.set("n", "<Leader>x", ":let @+ = expand(\"%:p\")<CR>")
vim.keymap.set("n", "<MiddleMouse>", "<Nop>")
vim.keymap.set("i", "<MiddleMouse>", "<Nop>")

